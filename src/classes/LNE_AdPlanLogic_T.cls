/** 
 *  Trigger logic to check for managing Tour Campaign-Ad Plan records 
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 *  @author Paul Roth <proth@salesforce.com>
 *  @see US689 / US146
 **/
public class LNE_AdPlanLogic_T {

    /**
    *  Automatically creates new Tour Campaign-Ad Plan records when an AdPlan__c is
    *  associated with a Tour
    *  @param newList AdPlan__c[]
    **/
    public static void createTourCampaignAdPlanRecordsOnInsert(AdPlan__c[] newList){
        Set<Id> newTourIDs = new Set<Id>();

        for (AdPlan__c ap : newList) {
            if (ap.Tour__c != null) {
                newTourIDs.add(ap.Tour__c);
            }
        }

        if (!newTourIDs.isEmpty()) {
            createTourCampaignAdPlans(newTourIDs, newList);
        }
    }

    /**
    *  Automatically creates manages Tour Campaign-Ad Plan records when Tour__c
    *  is updated on an Ad Plan
    *  @param newList AdPlan__c[]
    *  @param oldMap AdPlan__c[]
    **/
    public static void manageTourCampaignAdPlanRecordsOnUpdate(AdPlan__c[] newList, Map<Id, AdPlan__c> oldMap){
        Set<Id> changedTourIDs = new Set<Id>();
        Set<Id> changedAdPlans = new Set<Id>();

        for (AdPlan__c ap : newList) {
            if (oldMap.get(ap.Id) != null) {
                if (oldMap.get(ap.Id).Tour__c != ap.Tour__c) {
                    if (ap.Tour__c != null) {
                        changedTourIDs.add(ap.Tour__c);
                    }
                    changedAdPlans.add(ap.Id);
                }
            }
        }

        if (!changedTourIDs.isEmpty()) {
            createTourCampaignAdPlans(changedTourIDs, newList);
        }

        if (!changedAdPlans.isEmpty()) {
            List<TourCampaignAdPlan__c> toCleanUp = [SELECT AdPlan__r.Tour__c, TourCampaign__r.Tour__c FROM TourCampaignAdPlan__c WHERE AdPlan__c IN :changedAdPlans];
            List<TourCampaignAdPlan__c> toDelete = new List<TourCampaignAdPlan__c>();

            for (TourCampaignAdPlan__c tcap : toCleanUp) {
                if (tcap.TourCampaign__r.Tour__c != tcap.AdPlan__r.Tour__c) {
                    toDelete.add(tcap);
                }
            }

            if (!toDelete.isEmpty()) {
                delete toDelete;
            }
        }
    }

    private static void createTourCampaignAdPlans(Set<Id> tourIDs, AdPlan__c[] newList) {
        //-- @TODO: investigate if there is a better way to do this.
        List<TourCampaignAdPlan__c> toInsert = new List<TourCampaignAdPlan__c>();
        Map<Id, Tour__c> tourMap = new Map<Id, Tour__c>([SELECT Id, (SELECT Tour__c, RecordType.Name, NonLNETourBudget__c, NonLNETourBudget__r.Type__r.Name FROM Tour_Campaigns__r) FROM Tour__c WHERE Id IN :tourIDs]);
        
        //-- Create a TourCampaignAdPlan (junction between touring and ad plan)
        //-- Once an ad plan is associated to a tour
        //-- create a junction object (TourCampaignAdPlan__c) between the tour campaign and associated ad plans

        for (AdPlan__c ap : newList) {
            for (TourCampaign__c tc : tourMap.get(ap.Tour__c).Tour_Campaigns__r) {
                TourCampaignAdPlan__c tcap = new TourCampaignAdPlan__c(
                    AdPlan__c=ap.Id,
                    TourCampaign__c=tc.Id,
                    TourCampaignType__c = tc.RecordType.Name,
                    HasNonLNETourBudget__c = (tc.NonLNETourBudget__c != null),
                    Sponsor__c = tc.NonLNETourBudget__r.Type__r.Name
                );
                toInsert.add(tcap);
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }

    /**
     *  US 691 - Checks if any fields changed that would require a recalculation of Ledger Entries.
     *  @param newList AdPlan__c[]
     *  @param oldMap Map<Id,AdPlan__c>
     *  @return AdPlan__c[] - list of AdPlans updated.
    **/
    
    public static AdPlan__c[] execute( AdPlan__c[] newList, Map<Id,AdPlan__c> oldMap ){
        List<AdPlan__c> changedLedgers = new List<AdPlan__c>();
        Set<Id> listOfRelatedEventIds = new Set<Id>();
        ChangedAdPlan objChange = null;

        if (oldMap == null){
            oldMap = new Map<Id, AdPlan__c>();
        }

        for (AdPlan__c newAdPlan : newList ){
            if(oldMap.containsKey(newAdPlan.Id)){
                
                AdPlan__c oldAdPlan = oldMap.get(newAdPlan.Id);
                objChange = new ChangedAdPlan(oldAdPlan, newAdPlan);
                
                if(
                    objChange.notEquals('RadioSpend__c') ||
                    objChange.notEquals('DigitalSpend__c') ||
                    objChange.notEquals('OutdoorSpend__c') ||
                    objChange.notEquals('PrintSpend__c') ||
                    objChange.notEquals('ProductionMiscellaneousSpend__c') ||
                    objChange.notEquals('TelevisionSpend__c') ||
                    objChange.notEquals('TourDigitalSpend__c') ||
                    objChange.notEquals('TourOtherSpend__c') || 
                    objChange.notEquals('LNEAdPlanBudget__c')
                ) {          
                  if(newAdPlan.Event__c != null){
                    if(LNE_FinancialCalculator.runAdPLanLECalculation == False){
                        LNE_FinancialCalculator.runAdPLanLECalculation = True;
                    }
                    listOfRelatedEventIds.add(newAdPlan.Event__c);
                  }
                }
            }
            LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);
        }
        return changedLedgers;
        
    }

    /**
     *  US 691 - Recalculates for deleted AdPlans
     *  @param AdPlan[] - list of deleted AdPlans.
     *  @return AdPlan[] - list of AdPlans updated.
    **/
    
     public static AdPlan__c[] execute( AdPlan__c[] deletedList ){
        List<AdPlan__c> ChangedAdPlans = new List<AdPlan__c>();
        Set<Id> listOfRelatedEventIds = new Set<Id>();

        for (AdPlan__c deletedAdPlan : deletedList){
            if (deletedAdPlan.Event__c != null) {
                listOfRelatedEventIds.add(deletedAdPlan.Event__c);    
            }
            ChangedAdPlans.add(deletedAdPlan);
        }
        
        LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

        return ChangedAdPlans;
    }
    
    /**
     *  US 691 - Internal class to represent the changes from the object.
    **/
    class ChangedAdPlan extends LNE_SObjectChange {
        
        ChangedAdPlan( AdPlan__c oldObject, AdPlan__c newObject ){
            super( oldObject, newObject );
        }
        
        AdPlan__c getNewAdPlan(){
            return( (AdPlan__c)this.newObject );
        }
    }
}