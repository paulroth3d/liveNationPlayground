/**
 *  Router for all Ticket Scale triggers.
 *  @author John Casimiro
 **/
 trigger LNE_TicketScale on TicketScale__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }

	//We need to pass in the trigger name as a String because Apex doesn't have a way
	//to grab the current name of the trigger class
	LNE_FinancialCalculator.pushRunningTrigger('LNE_TicketScale.trigger');

	if( Trigger.isBefore ){
        if (Trigger.isInsert) {
        	LNE_TicketScaleMetrics_T.populateEventIfBlank(Trigger.new);
	        LNE_TicketScaleMetrics_T.execute( Trigger.new, Trigger.oldMap );
        } 
        if (Trigger.isUpdate) {
	        LNE_TicketScaleMetrics_T.execute( Trigger.new, Trigger.oldMap );
        }
        if (Trigger.isDelete){
            LNE_TicketScaleMetrics_T.execute(Trigger.old );
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
