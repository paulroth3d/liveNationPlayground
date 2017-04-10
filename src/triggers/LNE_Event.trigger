/**
 *  Router for all Event triggers.
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/
trigger LNE_Event on Event__c (before insert, before update, after insert, after update) {


    if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }
    
	//We need to pass in the trigger name as a String because Apex doesn't have a way
	//to grab the current name of the trigger class
	LNE_FinancialCalculator.pushRunningTrigger('LNE_Event.trigger');

	if( Trigger.isBefore ){
        if (Trigger.isInsert) {
	        LNE_EventMetrics_T.execute( Trigger.new, Trigger.oldMap );
        } 
        if (Trigger.isUpdate) {
	        LNE_EventMetrics_T.execute( Trigger.new, Trigger.oldMap );
            LNE_EventMetrics_T.validateRecordTypeChange( Trigger.new, Trigger.oldMap ); //US751
            LNE_EventMetrics_T.checkSettleAtActual( Trigger.new, Trigger.oldMap );
        } 
    }

    if( Trigger.isAfter ){
        if (Trigger.isInsert) {
            System.debug('human - call LNE_UpdateLedgerHouseNut_T from trigger router');
	        LNE_UpdateLedgerHouseNut_T.execute( Trigger.new, Trigger.oldMap );
            LNE_EventMetrics_T.buildRentalLE(Trigger.new, Trigger.oldMap); //US751
            LNE_TourTSO_T.executeEventChanges( Trigger.new, Trigger.oldMap );
        }
        if(Trigger.isUpdate){
        	LNE_CheckFlashStarted_T.execute( Trigger.new, Trigger.oldMap);
        	LNE_CheckLinkedToTour_T.execute( Trigger.new, Trigger.oldMap);
        	System.debug('human - call LNE_UpdateLedgerHouseNut_T from trigger router');
            LNE_UpdateLedgerHouseNut_T.execute(Trigger.new, Trigger.oldMap);
        	new LNE_InclusiveArtistExpensesPerDealCalc_T().execute(Trigger.oldMap, Trigger.new);
            LNE_EventMetrics_T.checkRentalSwitchAndBuildLE(Trigger.new, Trigger.oldMap); //US751
            LNE_TourTSO_T.executeEventChanges( Trigger.new, Trigger.oldMap );
            LNE_EventMetrics_T.buildBuySellLE(Trigger.new, Trigger.oldMap); //US746
        }
        if( Trigger.isDelete ){
            LNE_TourTSO_T.executeEventChanges( Trigger.new, Trigger.oldMap );
        }
    }

	LNE_FinancialCalculator.popRunningTrigger();

	// We need to do this after we pop the current running trigger from the stack,
	// so that any changes are done already by this and other triggers
	if (Trigger.isAfter) {
		LNE_FinancialCalculator.checkIfCanRunCalculations();
	}
    
}