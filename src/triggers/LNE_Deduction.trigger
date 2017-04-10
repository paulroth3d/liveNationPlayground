/**
 *  Router for all Deduction triggers.
 *  @author Daniel Nakonieczny
 **/
trigger LNE_Deduction on Deduction__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }

	//We need to pass in the trigger name as a String because Apex doesn't have a way
	//to grab the current name of the trigger class
	LNE_FinancialCalculator.pushRunningTrigger('LNE_Deduction.trigger');

	if( Trigger.isBefore ){
        if (Trigger.isInsert) {
        	LNE_BeforeAfterDeductionTotals_T.populateEventIfBlank(Trigger.new);
	        LNE_BeforeAfterDeductionTotals_T.execute( Trigger.new, Trigger.oldMap );
        } 
        if (Trigger.isUpdate) {
	        LNE_BeforeAfterDeductionTotals_T.execute( Trigger.new, Trigger.oldMap );
        }
        if (Trigger.isDelete){
            LNE_BeforeAfterDeductionTotals_T.execute(Trigger.old );
        }
    }

	LNE_FinancialCalculator.popRunningTrigger();

	// We need to do this after we pop the current running trigger from the stack,
	// so that any changes are done already by this and other triggers
	if (Trigger.isAfter) {
		LNE_FinancialCalculator.checkIfCanRunCalculations();
	}
}