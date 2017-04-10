/**
 *  Router for all Contact triggers.
 *  @author Paul Roth <proth@salesforce.com>
 **/
trigger LNE_Contact on Contact (after insert, after update){
	
	if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
		return;
	}
		
	if( Trigger.isAfter ){
    	if( Trigger.isInsert || Trigger.isUpdate ){
    		LNE_ContactCreate_T.updateContactRelationships( Trigger.new, Trigger.oldMap );
    	}
	}
}