/**
 *  Trigger functionality for when a contact is created.
 *  @author Paul Roth <proth@salesforce.com
 *  @author Dominic Aveyard <daveyard@salesforce.com>
 *  @group RelationshipLogic
 *  @version - update logic to now create external Ids and assign roles on create and update.
**/
public with sharing class LNE_ContactCreate_T {
    
    private static final String UNIQUE_DELIMITER = ';';
    
    /**
     *  Updates the AccountContactRelation for contacts recently assigned to accounts.
     *  <p>Note, that this assumes AFTER trigger - so the AccountContactRelation (created automatically) is there.</p>
     *  @param Contact[] newContacts
     *  @return AccountContactRelation[] - updated AccountContactRelation updated
     **/
    public static AccountContactRelation[] updateContactRelationships( Contact[] newContacts, Map<Id,Contact> oldContacts ){
        AccountContactRelation[] newContactRelations = new AccountContactRelation[]{};
        AccountContactRelation newContactRelation = null;
        
        //-- map of contact relations by the contact id
        Map<Id,AccountContactRelation> contactRelationMap = new Map<Id,AccountContactRelation>();
        
        //-- set of accounts those contacts belong to. at least it reduces the list.
        Set<Id> contactAccounts = new Set<Id>();
        
        //-- collection of contacts that have been updated and should be investigated
        Contact[] updatedContacts;
        Contact oldContact, currentContact;
        
        ContactChangeObj contactChange;
        
        String contactUniqueId;
        Map<String,Contact> contactUniqueMap = new Map<String,Contact>();

        for( Contact newContact : newContacts ){
            contactUniqueId = createContactIdentifier( newContact.AccountId, newContact.Id );
            
            if( oldContacts != null && oldContacts.containsKey( newContact.Id )){
                contactChange = new ContactChangeObj( newContact, oldContacts.get( newContact.Id ) );
                
                if( contactChange.notEquals( 'AccountId' ) ){
                    //-- the account has changed
                    //-- how do you have a contact with a null account id?!
                    
                    contactUniqueMap.put( contactUniqueId, newContact );
                    contactAccounts.add( newContact.AccountId );
                }
            } else {
                contactUniqueMap.put( contactUniqueId, newContact );
                contactAccounts.add( newContact.AccountId );
            }
        }
        
        if( contactUniqueMap.size() < 1 ){
        	System.debug( 'no contacts were changed sufficiently enough. aborting' );
        	return( newContactRelations );
        }
        
        updatedContacts = contactUniqueMap.values();
        
        //-- @INVARIANT: contactUniqueMap has only contacts that have changed and by the unique id of the account/contact
        System.debug( 'contactUniqueMap' ); System.debug( contactUniqueMap );
        
        /*
		Note: What makes AccountContactRelation s unique is the combination of AccountId
		and contactId, which makes any request in bulk necessarily over greedy
		(more AccountContactRelationships will be returned then will be used
		because both the the contact and account clauses are independent.
		We can utilize only the contactId for now because the contact is just
		created and only one will exist. But this means this
		CANNOT BE USED FOR UPDATES without any form of externalId
		*/
		for( AccountContactRelation newAcr: [
		    select id, accountId, contactid, Account.SourceSystemId__c, Contact.SourceSystemId__c
		    from AccountContactRelation
		    where contactId in :updatedContacts and accountId in :contactAccounts
		]){
		    contactUniqueId = createContactIdentifier( newAcr.AccountId, newAcr.ContactId );
		    System.debug( 'ACR found:' + contactUniqueId );
		    
		    //-- @INVARIANT: you cannot have a contact account relation with the same account and contact.
		    if( contactUniqueMap.containsKey( contactUniqueId ) ){
		        currentContact = contactUniqueMap.get( contactUniqueId );
		        System.debug( 'matching contact found' );
		        
		        //-- copy the role placeholder over for the primary ACR
		        newAcr.Roles = currentContact.Roles__c;
		        
		        if(
		            newAcr.Account != null && !String.isEmpty( newAcr.Account.SourceSystemId__c ) &&
		            newAcr.Contact != null && !String.isEmpty( newAcr.Contact.SourceSystemId__c )
		        ){
		            newAcr.ExternalId__c = newAcr.Account.SourceSystemId__c + newAcr.Contact.SourceSystemId__c;
		        }
		        
		        System.debug( 'updatedAcr.Roles:' + newAcr.Roles + ', ExternalId__c:' + newAcr.ExternalId__c );
		        newContactRelations.add( newAcr );
		    }
		}
		
		System.debug( 'newContactRelations:' ); System.debug( newContactRelations );
		if( newContactRelations.size() > 0 ){
		    update newContactrelations;
		}
		
		return( newContactRelations );
    }
    
    /**
     *  Generates a unique id for a contact/account pair
     *  @param accountId (Id)
     *  @param contactId (Id)
     *  @return (String) - unique identifier
     **/
    private static String createContactIdentifier( Id accountId, Id contactId ){
        return( String.valueOf( '' + accountId + UNIQUE_DELIMITER + contactId ) );
    }
    
    /**
     *  Inner class that represents a changed Contact
     **/
    class ContactChangeObj extends LNE_SobjectChange {
        ContactChangeObj( Contact oldContact, Contact newContact ){
            super( oldContact, newContact );
        }
        Contact getOldContact(){
            return( (Contact)this.oldObject );
        }
        Contact getNewContact(){
            return((Contact)this.newObject);
        }
    }
}