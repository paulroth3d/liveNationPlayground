/**
 *  Router for all Ad Plan triggers.
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 **/
trigger LNE_AdPlan on AdPlan__c (before insert, after insert, before update, after update, before delete, after delete) {
	if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }
    
    //We need to pass in the trigger name as a String because Apex doesn't have a way
    //to grab the current name of the trigger class
    LNE_FinancialCalculator.pushRunningTrigger('LNE_AdPlan.trigger');

    if( Trigger.isBefore ){
        if( Trigger.isUpdate ){
            LNE_AdPlanLogic_T.execute(Trigger.new, Trigger.oldMap);
        } else if( Trigger.isInsert ){  
            LNE_AdPlanLogic_T.execute(Trigger.new, Trigger.oldMap);
        } else if( Trigger.isDelete ){  
            LNE_AdPlanLogic_T.execute(Trigger.old);
        }
    } else if( Trigger.isAfter ){
        if( Trigger.isInsert ){
        	LNE_AdPlanLogic_T.createTourCampaignAdPlanRecordsOnInsert(Trigger.new);
            LNE_AdPlanFieldRollup_T.execute(null, trigger.new);
        } else if( Trigger.isUpdate ){
        	LNE_AdPlanLogic_T.manageTourCampaignAdPlanRecordsOnUpdate(Trigger.new, Trigger.oldMap);
            LNE_AdPlanFieldRollup_T.execute(trigger.oldMap, trigger.new);
        }
        else if (Trigger.isDelete) {
            LNE_AdPlanFieldRollup_T.execute(null, trigger.old);
        }
    }

    LNE_FinancialCalculator.popRunningTrigger();
    

    // We need to do this after we pop the current running trigger from the stack,
    // so that any changes are done already by this and other triggers
    if (Trigger.isAfter) {
        LNE_FinancialCalculator.checkIfCanRunCalculations();
    }
}