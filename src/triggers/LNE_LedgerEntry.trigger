/**
 *  Router for all Accounts triggers.
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/
trigger LNE_LedgerEntry on LedgerEntry__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }
    
	//We need to pass in the trigger name as a String because Apex doesn't have a way
    //to grab the current name of the trigger class
    LNE_FinancialCalculator.pushRunningTrigger('LNE_LedgerEntry.trigger');
    
    if( Trigger.isBefore ){
        //-- allow for bypassing financial calculator for data loads.
        if( GeneralSettings__c.getInstance().BypassAutomationFinancialCalculator__c != true ){
            if (Trigger.isInsert) {
                LNE_LedgerPreventDuplicates_T.execute(Trigger.new, Trigger.oldMap);  
                LNE_LedgerEntryMetrics_T.execute(Trigger.new, Trigger.oldMap);
                LNE_LedgerEntryMetrics_T.setLEDefaults(Trigger.new, Trigger.oldMap);
                LNE_LedgerEntryMetrics_T.checkSettleAtActual(Trigger.new);
            } 
            else if (Trigger.isUpdate) {
                LNE_LedgerEntryMetrics_T.execute(Trigger.new, Trigger.oldMap);
                LNE_LedgerEntryMetrics_T.setLEDefaults(Trigger.new, Trigger.oldMap);
            }
            else if (Trigger.isDelete) {
                LNE_LedgerEntryMetrics_T.executeDelete(Trigger.old);
                LNE_BlockDeletingTourLE_T.execute(Trigger.old);
                
            }
        }
    } else if( Trigger.isAfter ){
        if( Trigger.isInsert ){
            LNE_RollupContraForecast_T.execute(Trigger.new, Trigger.oldMap);
            LNE_LedgerEntryDSLCreateDelete_T.execute(Trigger.new);
            LNE_TourTSO_T.executeLedgerChanges( Trigger.new, Trigger.oldMap );
        } 
        else if( Trigger.isUpdate ){
            LNE_RollupContraForecast_T.execute(Trigger.new, Trigger.oldMap);
            LNE_LedgerEntryDSLCreateDelete_T.execute(Trigger.newMap, Trigger.oldMap);
            LNE_TourTSO_T.executeLedgerChanges( Trigger.new, Trigger.oldMap );
        }
        else if( Trigger.isDelete){
            LNE_RollupContraForecast_T.executeDelete(Trigger.old);
            LNE_TourTSO_T.executeLedgerChanges( Trigger.new, Trigger.oldMap );
        }        
    }

    LNE_FinancialCalculator.popRunningTrigger();

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
}