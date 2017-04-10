/**
 * Created by JK on 12/16/16.
 */

trigger LNE_PromoScale on PromoScale__c (after update) {
	
	if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }

    LNE_PromoScale_T.calculateTotalTicketValues(Trigger.newMap);
    
}