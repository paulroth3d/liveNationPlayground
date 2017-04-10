/**
 * Created by JK on 12/11/16.
 */

global with sharing class LNE_MarketingPromotionsTab_CX {

    @testVisible
    private AdPlan__c adPlan{get; set;}
    @testVisible
    private List<TicketScale__c> ticketScales{get; set;}
    @testVisible
    private List<PromoScale__c> promoScales{get; set;}

    public LNE_MarketingPromotionsTab_CX(ApexPages.StandardController controller){

        adPlan = [Select Id, Event__c, Event__r.Status__c from AdPlan__c where Id = :controller.getRecord().Id];
        promoScales = [Select Name, Description__c, Price__c, TicketScale__c from PromoScale__c where AdPlan__c = :adPlan.Id];

        String stageType;

        if(LNE_Constants.TICKET_SCALE_PLAN_EVENT_STATUSES.contains(adPlan.Event__r.Status__c)){
            stageType = LNE_Constants.TICKET_SCALE_STAGE_TYPE_PLAN;
        }else if(LNE_Constants.TICKET_SCALE_PROJECTION_EVENT_STATUSES.contains(adPlan.Event__r.Status__c)){
            stageType = LNE_Constants.TICKET_SCALE_STAGE_TYPE_PROJECTION;
        }

        ticketScales = [Select Id, Name, Price__c, PriceLevel__c, Notes__c, Event__c, StageType__c from TicketScale__c where Event__c != null And Event__c = :adPlan.Event__c And StageType__c = :stageType];

    }

    public String getAdPlan_json() {
        return JSON.serialize(adPlan);
    }

    public String getTicketScales_json() {
        return JSON.serialize(ticketScales);
    }

    public String getPromoScales_json() {
        return JSON.serialize(promoScales);
    }

    /**
     * Saves a promoScale
     * @param promoScale (PromoScale__c) - promo scale to save
     * @throws DMLException
     **/
    @RemoteAction
    global static PromoScale__c savePromoScale(PromoScale__c promoScale){
        upsert promoScale;
        return(promoScale);
    }
}