/** 
 *  Batch Class that will send notifications when the global terms are updated.
 *  <p>Suggested that the batch size be set to 1.</p>
 *  
 *  @Depends on EmailTemplate: EMAIL_TEMPLATE_NAME
 *  
 *  @Example
 *  String newQuery = 'select id, GlobalTermsUpdated__c, GlobalTerms__c, PreviousGlobalTerms__c ' +
 *  	'from Account ' +
 *  	'where GlobalTermsUpdated__c = true';
 *  LNE_AccountTermsUpdated_Batch b = new LNE_AccountTermsUpdated_Batch( newQuery );
 *  Id batchProcessId = Database.executeBatch( b );
 *  System.debug( 'batchProcessId:' + batchProcessId );
 *  
 *  @author Paul Roth <proth@salesforce.com>
 **/
global with sharing class LNE_AccountTermsUpdated_Batch
    implements Database.Batchable<sObject>
{
    
    static final String ROLE_GENERAL_MANAGER = 'Venue GM';
    
    static final String MULTI_PICKLIST_DELIMITER = ';';
    
    static final String EMAIL_TEMPLATE_NAME = 'Term_Updated_Notification';
    
    /** default query to run **/
    static final String DEFAULT_QUERY = 'select id, GlobalTermsUpdated__c, GlobalTerms__c, PreviousGlobalTerms__c ' +
        'from Account ' +
        'where GlobalTermsUpdated__c = true';
    
    /** Query to execute **/
    global String query;
    
    global LNE_AccountTermsUpdated_Batch(){
        this.query = null;
    }
    
    global LNE_AccountTermsUpdated_Batch( String query ){
        this.query = query;
    }
    
    global Database.QueryLocator start( Database.BatchableContext context ){
        if( this.query == null ){
            this.query = DEFAULT_QUERY;
        }
        
        return( Database.getQueryLocator( this.query ));
    }
    
    global void execute( Database.BatchableContext context, SObject[] scope ){
        Account[] updatedVenues = (Account[])scope;
        
        //-- determine the GM for the account based on the AccountContactRoles.
        Map<Id,Messaging.SingleEmailMessage> accountEmailMap = new Map<Id,Messaging.SingleEmailMessage>();
        
        EmailTemplate notificationTemplate = null;
        
        Messaging.SingleEmailMessage emailMessage = null;
        Messaging.SingleEmailMessage[] emailMessages = new Messaging.SingleEmailMessage[]{};
        
        //-- determine the email template;
        for( EmailTemplate myTemplate : [
            select id, developerName
            from EmailTemplate
            where DeveloperName = :EMAIL_TEMPLATE_NAME
            limit 1
        ]){
            notificationTemplate = myTemplate;
        }
        
        //-- the notification template must be found, or the email cannot be sent.
        System.assert( notificationTemplate != null, 'EMAIL TEMPLATE:' + EMAIL_TEMPLATE_NAME + ', could not be found' );
        
        //-- find the GM for the Account
        Set<String> relationRoles = null;
        for( AccountContactRelation validRelation : [
            select AccountId, Contact.Id, Contact.Name, Contact.Email, Roles
            from AccountContactRelation
            where AccountId in :updatedVenues
        ]){
            //-- becomes trickier since this is a multi-select picklist
            if( validRelation.Roles != null ){
                relationRoles = new Set<String>();
                relationRoles.addAll( validRelation.Roles.split( MULTI_PICKLIST_DELIMITER ) );
                
                //System.debug( 'checking email[' + relationRoles.contains( ROLE_GENERAL_MANAGER ) + '][' + (!String.isBlank( validRelation.Contact.Email )) + ']' );
                
                if( relationRoles.contains( ROLE_GENERAL_MANAGER ) &&
                    !String.isBlank( validRelation.Contact.Email )
                ){
                    
                    if( !accountEmailMap.containsKey( validRelation.AccountId )){
                        emailMessage = createEmailMessage( notificationTemplate.Id, validRelation.AccountId );
                    } else {
                        emailMessage = accountEmailMap.get( validRelation.AccountId );
                    }
                    
                    emailMessage.toAddresses.add( validRelation.Contact.Email );
                    emailMessage.setTargetObjectId( validRelation.Contact.Id );
                    
                    accountEmailMap.put( validRelation.AccountId, emailMessage );
                }
            }
        }
        
        
        //-- find the owner of the account
        for( Account extendedAccount : [
            select id, owner.name, owner.email
            from Account
            where id in :updatedVenues
        ]){
            //System.debug( 'checking owner[' + !String.isBlank( extendedAccount.Owner.Email )+ ']' );
            if( !String.isBlank( extendedAccount.Owner.Email )){
                if( !accountEmailMap.containsKey( extendedAccount.Id )){
                    //-- cannot be done. the what id is not valid for sending to user id
                    //19:41:49.0 (35803487)|EXCEPTION_THROWN|[143]|System.EmailException: SendEmail failed. First exception on row 0; first error: INVALID_ID_FIELD, WhatId is not available for sending emails to UserIds.: [whatId, 0016C000002GR10]
                    //emailMessage = createEmailMessage( notificationTemplate.Id, extendedAccount.Id );
                    //emailMessage.toAddresses.add( extendedAccount.Owner.Email );
                    //emailMessage.setTargetObjectId( extendedAccount.Owner.Id );
                    System.debug( 'unable to send emails to strictly extendedAccount, as no contact with an email is defined.' );
                } else {
                    emailMessage = accountEmailMap.get( extendedAccount.Id );
                    emailMessage.ccAddresses.add( extendedAccount.Owner.Email );
                    //accountEmailMap.put( extendedAccount.Id, emailMessage );
                }
            }
        }
        
        
        //-- Determine the list of emails to send
        emailMessages = accountEmailMap.values();
        
        //-- 
        
        //System.debug( 'emailMessages:' ); System.debug( emailMessages );
        
        //-- if there are messages, send them out.
        if( emailMessages.size() > 0 ){
            Messaging.sendEmail( emailMessages );
        }
        
        //-- now all the emails are sent, set the isUpdated to false
        for( Account updatedVenue : updatedVenues ){
        	updatedVenue.GlobalTermsUpdated__c = false;
        }
        update updatedVenues;
    }
    
    global void finish( Database.BatchableContext context ){
    }
    
	/**
	 *  Creates a stub email to work with.
	 *  @param templateId 
	 *  @param acountId
	 *  @return Messaging.SingleEmailMessage
	 *  
	 *  @Example:
	 *  Id templateId = '00XR0000000NAHzMAO';
	 *  Id targetObjId = '003R000001870rV';
	 *  Id accountId = '001R0000016f6uy';
	 *  String testEmailAddress = 'proth@salesforce.com';
	 *  
	 *  Messaging.SingleEmailMessage emailMessage = LNE_AccountTermsUpdated_Batch.createEmailMessage( templateId, accountId );
	 *  emailMessage.toAddresses.add( testEmailAddress );
	 *  emailMessage.setTargetObjectId( targetObjId );
	 *  
	 *  Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ emailMessage } );
	**/
    public static Messaging.SingleEmailMessage createEmailMessage( Id templateId, Id accountId ){
        Messaging.SingleEmailMessage result = new Messaging.SingleEmailMessage();
        result.toAddresses = new String[]{};
        result.bccAddresses = new String[]{};
        result.ccAddresses = new String[]{};
        result.setTemplateId( templateId );
        result.setWhatId( accountId );
        result.saveAsActivity = false;
        return( result );
    }
}