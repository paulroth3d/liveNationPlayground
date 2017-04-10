/**
 *  TourCampaignAdPlan__c trigger
 *  @author Phil Rymek <prymek@salesforce.com>
 **/
trigger LNE_TourCampaignAdPlan on TourCampaignAdPlan__c(before update, before insert) {
    
    if (GeneralSettings__c.getInstance().BypassAutomation__c || LNE_Util.IS_CURRENTLY_CLONING) {
        return;
    }

    if (Trigger.isBefore) {
    	if (Trigger.isUpdate) {
    	    LNE_TourCampaignAdPlan_T.onUpdate(Trigger.oldMap, Trigger.new);
    	} else if(Trigger.isInsert) {
    	   LNE_TourCampaignAdPlan_T.onInsert(Trigger.new);
    	}
    }

}