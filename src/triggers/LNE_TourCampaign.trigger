/**
 *  Router for all Tour Campaign triggers.
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 **/
trigger LNE_TourCampaign on TourCampaign__c (before insert, after insert, before update, after update, before delete, after undelete) {
	
	if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }

    if( Trigger.isBefore ){
        if( Trigger.isUpdate ){

        } else if( Trigger.isInsert ){  

        }
    } else if( Trigger.isAfter ){
        if( Trigger.isInsert ){
        	LNE_TourLogic_T.createTourCampaignAdPlanRecords(Trigger.new);
        } else if( Trigger.isUpdate ){
			LNE_TourCampNonLNEBudgetAssign.execute( Trigger.new, Trigger.oldMap );
			LNE_TourCampaignAdPlanType.execute( Trigger.new, Trigger.oldMap );
        }
    }
}