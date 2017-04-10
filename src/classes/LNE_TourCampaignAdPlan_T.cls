/**
 *  TourCampaignAdPlan__c trigger helper
 *  @author Phil Rymek <prymek@salesforce.com>
 **/
public class LNE_TourCampaignAdPlan_T {

    public static void onInsert(List<TourCampaignAdPlan__c> tcaps) {
        List<TourCampaignAdPlan__c> needsLedgerRemoval = new List<TourCampaignAdPlan__c>();
        
        for(TourCampaignAdPlan__c tcap : tcaps) {
            if(tcap.AllocatedAmount__c != null) {
                needsLedgerRemoval.add(tcap);
            }
        }
        
        if(!needsLedgerRemoval.isEmpty()) {
            removeLedgerEntry50499(needsLedgerRemoval);
        }        
    }
    
    public static void onUpdate(Map<Id, TourCampaignAdPlan__c> old, List<TourCampaignAdPlan__c> tcaps) {
        List<TourCampaignAdPlan__c> needsLedgerRemoval = new List<TourCampaignAdPlan__c>();
        TourCampaignAdPlan__c previous;
        
        for(TourCampaignAdPlan__c tcap : tcaps) {
            previous = old.get(tcap.Id);
            
            if(tcap.AllocatedAmount__c != previous.AllocatedAmount__c && tcap.AllocatedAmount__c != null) {
                needsLedgerRemoval.add(tcap);
            }
        }
        
        if(!needsLedgerRemoval.isEmpty()) {
            removeLedgerEntry50499(needsLedgerRemoval);
        }         
    }

    private static void removeLedgerEntry50499(List<TourCampaignAdPlan__c> tcaps) {
        List<Id> eventIds = new List<Id>();
        
        List<TourCampaignAdPlan__c> withEvents = 
            [SELECT AdPlan__r.Event__c 
               FROM TourCampaignAdPlan__c
              WHERE Id in :tcaps AND AdPlan__r.Event__c != null];
            
        for(TourCampaignAdPlan__c tcap : withEvents) {
            eventIds.add(tcap.AdPlan__r.Event__c);
        }
        
        LNE_LedgerEntryUtil.delete50499(eventIds);
    }

}