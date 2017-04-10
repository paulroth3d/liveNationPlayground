/**
 *  Router for all BonusDetail triggers.
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/

trigger LNE_BonusDetail on BonusDetail__c (before insert, before update, before delete, after insert, after update, after undelete) {

    System.debug('BonusDetail trigger fired');
    if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
    	return;
    }

    //We need to pass in the trigger name as a String because Apex doesn't have a way
    //to grab the current name of the trigger class
    LNE_FinancialCalculator.pushRunningTrigger('LNE_BonusDetail.trigger');
    
     if( Trigger.isBefore ){
        if (Trigger.isInsert) {
            LNE_BonusStartPointValidation_T.execute( Trigger.new, Trigger.oldMap );  
            LNE_BonusMetrics_T.execute( Trigger.new, Trigger.oldMap );
        } 
        if (Trigger.isUpdate) {
            LNE_BonusStartPointValidation_T.execute( Trigger.new, Trigger.oldMap );
            LNE_BonusMetrics_T.execute( Trigger.new, Trigger.oldMap );
        }
        if (Trigger.isDelete) {
            LNE_BonusMetrics_T.executeDelete( Trigger.old );
        }
    }

    LNE_FinancialCalculator.popRunningTrigger();

    // We need to do this after we pop the current running trigger from the stack,
    // so that any changes are done already by this and other triggers
    if (Trigger.isAfter) {
        LNE_FinancialCalculator.checkIfCanRunCalculations();
    }
    
}