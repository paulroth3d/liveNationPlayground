/**
 *  Router for all Deal triggers.
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/

trigger LNE_Deal on Deal__c (before insert, before update, before delete, after insert, after update, after delete) {

    if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }
    
    //We need to pass in the trigger name as a String because Apex doesn't have a way
	//to grab the current name of the trigger class
    LNE_FinancialCalculator.pushRunningTrigger('LNE_Deal.trigger');
    
    if( Trigger.isBefore ){
        if (Trigger.isInsert) {
            LNE_DealPrimaryHeadlinerArtist_T.execute( Trigger.new, Trigger.oldMap );
            LNE_DealMetrics_T.execute(Trigger.new, Trigger.oldMap);
            new LNE_InclusiveArtistExpensesPerDealCalc_T().execute(Trigger.oldMap, Trigger.new);
        } else if (Trigger.isUpdate) {
            LNE_DealPrimaryHeadlinerArtist_T.execute( Trigger.new, Trigger.oldMap );
            LNE_DealMetrics_T.execute(Trigger.new, Trigger.oldMap);
            new LNE_InclusiveArtistExpensesPerDealCalc_T().execute(Trigger.oldMap, Trigger.new);
        } else if (Trigger.isDelete) {
            LNE_DealCoPromoter_T.checkDeletePermission( Trigger.old );
            LNE_DealMetrics_T.execute(Trigger.old);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LNE_SupportDealsSummary_T.execute(Trigger.new, Trigger.oldMap);
            LNE_DealCoPromoter_T.createDealSettlementLedgers( Trigger.new, Trigger.oldMap );
            LNE_CopyPrimaryHeadlinerToCoHeadliners_T.execute( Trigger.new, Trigger.oldMap );
            LNE_EventAssociatedArtists_T.execute( Trigger.new, Trigger.old, Trigger.oldMap );
            LNE_DealMetrics_T.findPreviousEventInMarket(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isUpdate) {
        	LNE_SupportDealsSummary_T.execute(Trigger.new, Trigger.oldMap);
        	LNE_DSLFieldCopy_T.recalculateDealChildren(Trigger.new, Trigger.oldMap);
        	LNE_CopyPrimaryHeadlinerToCoHeadliners_T.execute( Trigger.new, Trigger.oldMap );
        	LNE_EventAssociatedArtists_T.execute( Trigger.new, Trigger.old, Trigger.oldMap );
        	LNE_DealMetrics_T.findPreviousEventInMarket(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            LNE_SupportDealsSummary_T.execute(Trigger.new, Trigger.oldMap);
            LNE_DealCoPromoter_T.updateRemainderOnDelete(Trigger.old);
            LNE_DSLFieldCopy_T.recalculateDealChildren(Trigger.new, Trigger.oldMap);
            LNE_EventAssociatedArtists_T.execute( Trigger.new, Trigger.old, Trigger.oldMap );
            LNE_DealMetrics_T.findPreviousEventInMarket(Trigger.new, Trigger.oldMap);
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
