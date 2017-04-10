/**
 *  Router for all DealSettlementLedger__c triggers.
 *  @author John Casimiro <jcasimiro@salesforce.com>
 **/
trigger LNE_DealSettlementLedger on DealSettlementLedger__c (before insert, before update) {
	
    System.debug('DealSettlementLedger__c trigger fired');
    if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }
    
     if( Trigger.isBefore ){
        if (Trigger.isInsert) {
            LNE_DSLFieldCopy_T.execute(Trigger.new);
            LNE_DealSettlementSSID.execute( Trigger.new, null );
        } else if (Trigger.isUpdate) {
            LNE_DSLFieldCopy_T.execute(Trigger.new);
            LNE_DealSettlementSSID.execute( Trigger.new, Trigger.oldMap );
        } else if (Trigger.isDelete) {
            
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
         
        } else if (Trigger.isUpdate) {
            
        } else if (Trigger.isDelete) {
            
        }
    }
}