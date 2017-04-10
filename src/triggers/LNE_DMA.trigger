/**
 *  Router for all DMA triggers.
 *  @author Paul Roth <proth@salesforce.com>
 **/
trigger LNE_DMA on DMA__c (before insert, before update ){
	
	if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
		return;
	}
	
	if( Trigger.isBefore ){
    	if( Trigger.isInsert ||
    	    Trigger.isUpdate
    	){
    		LNE_DMA_NameDefinition_T.execute( Trigger.new, Trigger.oldMap );
    	}
	}
}