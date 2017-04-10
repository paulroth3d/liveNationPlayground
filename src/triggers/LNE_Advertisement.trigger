/**
 * Created by JK on 11/4/16.
 */

trigger LNE_Advertisement on Advertisement__c (before delete, before update, before insert) {

    if (GeneralSettings__c.getInstance().BypassAutomation__c
     || LNE_Util.IS_CURRENTLY_CLONING
    ) {
        return;
    }

    if (Trigger.isBefore) {
    	if (Trigger.isUpdate) {
        	LNE_Advertisement_T.updateInsertions(Trigger.new);
        	LNE_Advertisement_T.onUpdate(Trigger.oldMap, Trigger.new);
        	LNE_AdvertisementSplits_T.onUpdate(Trigger.oldMap, Trigger.new);
    	} else if(Trigger.isInsert) {
    	    LNE_Advertisement_T.onInsert(Trigger.new);
    	} else if (Trigger.isDelete) {
    		LNE_AdvertisementSplits_T.onDelete(Trigger.oldMap);
    	}
    }

}