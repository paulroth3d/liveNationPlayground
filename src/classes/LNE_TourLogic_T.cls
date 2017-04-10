/** 
 *  Trigger logic to check for managing Tour Campaign-Ad Plan records 
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 *  @author Paul Roth <proth@salesforce.com>
 *  @see US689 / US146
 **/
public class LNE_TourLogic_T {
    
    /**
    *  Automatically creates new Tour Campaign-Ad Plan records on TourCampaign__c insert.
    *  This needs to run ONLY on AFTER insert of TourCampaign__c
    *  @param newList TourCampaign__c[]
    **/
    public static void createTourCampaignAdPlanRecords(TourCampaign__c[] newList){
        Set<Id> tourIDs = new Set<Id>();

        for (TourCampaign__c tc : newList) {
            if (tc.Tour__c != null) {
                tourIDs.add(tc.Tour__c);
            }
        }

        if (!tourIDs.isEmpty()) {
            
            //-- map the recordType Id to the name of the recordType for all tour campaigns
            Map<Id,String> tourCampaignRecordTypes = new Map<Id,String>();
            for( RecordType tourCampaignRT : [
                SELECT id, name
                FROM recordType
                WHERE SObjectType = 'TourCampaign__c'
            ]){
                tourCampaignRecordTypes.put( tourCampaignRT.Id, tourCampaignRT.Name );
            }
            
            //-- @TODO: investigate this further
            List<TourCampaignAdPlan__c> toInsert = new List<TourCampaignAdPlan__c>();
            Map<Id, Tour__c> tourMap = new Map<Id, Tour__c>([SELECT Id, (SELECT Tour__c FROM Ad_Plans__r) FROM Tour__c WHERE Id IN :tourIDs]);
            
            //-- Create a TourCampaignAdPlan (junction between touring and ad plan)
            //-- Once a tour campaign is associated to a tour
            //-- create a junction object (TourCampaignAdPlan__c) between the tour campaign and associated ad plans
            
            String tourCampaignType;
            for (TourCampaign__c tc : newList) {
                //-- determine the recordTypeName for the tourCampaign
                if( tc.RecordTypeId != null && tourCampaignRecordTypes.containsKey( tc.RecordTypeId )){
                    tourCampaignType = tourCampaignRecordTypes.get( tc.RecordTypeId );
                }
                for (AdPlan__c ap : tourMap.get(tc.Tour__c).Ad_Plans__r) {
                    TourCampaignAdPlan__c tcap = new TourCampaignAdPlan__c(
                        AdPlan__c=ap.Id,
                        TourCampaign__c=tc.Id,
                        TourCampaignType__c=tourCampaignType,
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
    }
}