/**
 * Created by JK on 11/4/16.
 */

public with sharing class LNE_Advertisement_T {

    public static void onInsert(List<Advertisement__c> ads) {
        List<Advertisement__c> needsLedgerRemoval = new List<Advertisement__c>();
        
        for(Advertisement__c ad : ads) {
            if(ad.NetCostToAdPlan__c != null) {
                needsLedgerRemoval.add(ad);
            }
        }
        
        if(!needsLedgerRemoval.isEmpty()) {
            removeLedgerEntry50499(needsLedgerRemoval);
        }
    }
    
    public static void onUpdate(Map<Id, Advertisement__c> old, List<Advertisement__c> ads) {
        List<Advertisement__c> needsLedgerRemoval = new List<Advertisement__c>();
        Advertisement__c previous;
        
        for(Advertisement__c ad : ads) {
            previous = old.get(ad.Id);
            
            if(ad.NetCostToAdPlan__c != previous.NetCostToAdPlan__c && ad.NetCostToAdPlan__c != null) {
                needsLedgerRemoval.add(ad);
            }
        }
        
        if(!needsLedgerRemoval.isEmpty()) {
            removeLedgerEntry50499(needsLedgerRemoval);
        }        
    }    
    
    private static void removeLedgerEntry50499(List<Advertisement__c> ads) {
        List<Id> eventIds = new List<Id>();
        
        List<Advertisement__c> withEvents = 
            [SELECT AdPlan__r.Event__c 
               FROM Advertisement__c
              WHERE Id in :ads AND AdPlan__r.Event__c != null];
            
        for(Advertisement__c ad : withEvents) {
            eventIds.add(ad.AdPlan__r.Event__c);
        }
        
        LNE_LedgerEntryUtil.delete50499(eventIds);
    }

    public static void updateInsertions(List<Advertisement__c> ads){

        Map<ID, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Advertisement__c.getRecordTypeInfosById();
        Integer recordCount = 0;
        Datetime startDate, endDate;

        List<Advertisement__c> tvpAds = new List<Advertisement__c>();
        Set<Id> tvpAdIds = new Set<Id>();
        String recordType;

        for(Advertisement__c ad : ads){

            recordType = recordTypeMap.get(ad.recordTypeId).getName();

            if(recordType == 'Television' || recordType == 'Radio' || recordType == 'Print'){
                tvpAds.add(ad);
                tvpAdIds.add(ad.Id);
            }
        }

        Integer totalRecords = tvpAds.size();

        if(totalRecords>0){

            //delete the appropriate insertions
            String soql = 'Select Id from Insertion__c where ';

            for(Advertisement__c ad : tvpAds){

                recordCount++;

                startDate = DateTime.newInstance(ad.StartDate__c.year(), ad.StartDate__c.month(),ad.StartDate__c.day());

                if(ad.BuyType__c == LNE_Constants.AD_BUY_TYPE_PKG_RANGE) {
                    endDate = startDate;
                }else{
                    endDate = DateTime.newInstance(ad.EndDate__c.year(), ad.EndDate__c.month(),ad.EndDate__c.day());
                }

                soql += '(Advertisement__c = \'' + ad.Id + '\' AND Advertisement__r.BuyType__c = \'' + ad.BuyType__c + '\'';

                if(ad.BuyType__c == LNE_Constants.AD_BUY_TYPE_REGULAR) {
                    //if regular buy, delete insertions that don't have a count and a date or whose dates are outside of the ads date range
                    soql += ' AND (Date__c < ' + startDate.format('yyyy-MM-dd') + ' OR Date__c > ' + endDate.format('yyyy-MM-dd') + ' OR Date__c = null OR NumberofSpots__c = null OR NumberofSpots__c < 1)';
                }else if(ad.BuyType__c == LNE_Constants.AD_BUY_TYPE_PKG_RANGE){
                    //if date range, delete insertions that have a date or that don't have a count
                    soql += ' AND (Date__c != null OR NumberofSpots__c = null OR NumberofSpots__c < 1)';
                }else if(ad.BuyType__c == LNE_Constants.AD_BUY_TYPE_PKG_DATES){
                    //if select dates, delete insertions that have a count and a date or whose dates are outside of the ads date range or (that have a date and are RunOnThisDate__c false)
                    soql += ' AND (Date__c < ' + startDate.format('yyyy-MM-dd') + ' OR Date__c > ' + endDate.format('yyyy-MM-dd') + ' OR (Date__c != null AND RunOnThisDate__c = false))';
                }

                soql += ')';

                if(recordCount<totalRecords){
                    soql += ' OR ';
                }
            }

            List<Insertion__c> insertionsToDelete = Database.query(soql);

            //this is causing the trigger to fire recursively because the deletion of an insertion causes the NumberOfSpots rollup summary field to update
            delete insertionsToDelete;

        }
    }
}