/**
 *  Router for all Ledger Entry Breakout triggers.
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/
trigger LNE_LedgerEntryBreakout on LedgerEntryBreakout__c (before insert, before update, before delete, after insert, after update, after delete) {

    if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }

    //We need to pass in the trigger name as a String because Apex doesn't have a way
    //to grab the current name of the trigger class
    LNE_FinancialCalculator.pushRunningTrigger('LNE_LedgerEntryBreakout.trigger');
    
    if( Trigger.isBefore ){
        if( GeneralSettings__c.getInstance().BypassAutomationFinancialCalculator__c != true ){
            if (Trigger.isInsert) {
                LNE_LedgerEntryBreakoutMetrics_T.execute(Trigger.new, Trigger.oldMap);
                LNE_LedgerEntryBreakoutMetrics_T.checkSettleAtActual(Trigger.new);
                
            } 
            else if (Trigger.isUpdate) {
                LNE_LedgerEntryBreakoutMetrics_T.execute(Trigger.new, Trigger.oldMap);
    
            }
            else if (Trigger.isDelete) {
                LNE_BlockLedgerEntryBreakoutDelete_T.execute(Trigger.old);
            }
        }
    } else if( Trigger.isAfter ){
        if( Trigger.isInsert ){
        } 
        else if( Trigger.isUpdate ){
        }
        else if( Trigger.isDelete){
        }        
    }

    //System.debug('fd04e071-4ad2-4aea-bd70-b536a0686ccb - LNE_LedgerEntryBreakout trigger before running financial Calculator' );

    LNE_FinancialCalculator.popRunningTrigger();
    
    //System.debug('649f2b8d-cf0d-4b26-85de-29701b2a9eed - LNE_LedgerEntryBreakout trigger before running financial Calculator' );

    // We need to do this after we pop the current running trigger from the stack,
    // so that any changes are done already by this and other triggers
    if (Trigger.isAfter) {
        LNE_FinancialCalculator.checkIfCanRunCalculations();
        //US751
        if(LNE_FinancialCalculator.hasIdsToProcess() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){
            System.enqueueJob(new LNE_FinancialCalculatorQueueable(LNE_FinancialCalculator.getEventIDsToProcess(), 'RecalcuatePromotedShowLedgerEntries'));
        }
        //US746
        if(LNE_FinancialCalculator.hasIdsToProcess() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){
            System.enqueueJob(new LNE_FinancialCalculatorQueueable(LNE_FinancialCalculator.getEventIDsToProcess(), 'RecalculateBuySellLedgerEntries'));
        }
    }
    
    //System.debug( '7850c197-e533-4a37-a913-86fe3bef8ff2 - LNE_LedgerEntryBreakout after financial Calculator' );
}
