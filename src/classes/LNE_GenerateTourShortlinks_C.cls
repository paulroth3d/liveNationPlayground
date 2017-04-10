/**
 *  Controller for the LNE_GenerateTourShortlinks lightning component.
 *
 *  @author Scott Will
 *
 **/
public with sharing class LNE_GenerateTourShortlinks_C {

    /**
     * Returns a list of unique Vendors found under the Tour
     *
     * @param   tourId Id - the id of the Tour__c record
     * @return  String[] - list of unique vendor names
    **/
    @AuraEnabled
    public static List<String> getVendors(Id tourId) {

        List<String> vendors = new List<String>();

        if (tourId != null) {

            // Vendor__c is a formula and cannot be grouped in an aggregate
            Set<String> distincts = new Set<String>();

            for (TourCampaignAdPlan__c tcap : [
                select
                    Vendor__c
                from TourCampaignAdPlan__c
                where TourCampaign__r.Tour__c = :tourId
            ]) {
                distincts.add(tcap.Vendor__c);
            }

            vendors.addAll(distincts);
            vendors.sort();

        }

        return vendors;

    }

    /**
     * Returns a list of unique Announcement Types found under the Tour
     *
     * @param   tourId Id - the id of the Tour__c record
     * @return  String[] - list of unique type names
    **/
    @AuraEnabled
    public static List<String> getTypes(Id tourId) {

        List<String> types = new List<String>();

        if (tourId != null) {

            // AnnouncementType__c is a formula and cannot be grouped in an aggregate
            Set<String> distincts = new Set<String>();

            for (TourCampaignAdPlan__c tcap : [
                select
                    AnnouncementType__c
                from TourCampaignAdPlan__c
                where TourCampaign__r.Tour__c = :tourId
            ]) {
                distincts.add(tcap.AnnouncementType__c);
            }

            types.addAll(distincts);
            types.sort();

        }

        return types;

    }

    /**
     * Returns all TourCampaignAdPlan__c records associated to the tourId
     *
     * @param   tourId Id - the id of the Tour__c record
     * @param   vendors String[] - list of vendor names to filter by
     * @param   types String[] - list of type names to filter by
     * @return  TourCampaignAdPlan__c[]
    **/
    @AuraEnabled
    public static List<TourCampaignAdPlan__c> getTourCampaignAdPlans(Id tourId, List<String> vendors, List<String> types) {

        List<TourCampaignAdPlan__c> records = new List<TourCampaignAdPlan__c>();

        if (tourId != null) {

            Set<String> setVendors = new Set<String>(vendors);
            Set<String> setTypes = new Set<String>(types);
            // lightning component will send an array of [""] if no selection was made
            setVendors.remove('');
            setTypes.remove('');

            for (TourCampaignAdPlan__c record : (List<TourCampaignAdPlan__c>)Database.query(
                'select ' +
                    'ShortURL__c, ' +
                    'TrackingURL__c ' +
                'from TourCampaignAdPlan__c ' +
                'where TourCampaign__r.Tour__c = :tourId ' +
                (setTypes.isEmpty() ? '' : 'and AnnouncementType__c in :setTypes ') +
                (setVendors.isEmpty() ? '' : 'and Vendor__c in :setVendors ')
            )) {
                // since we dont know if the TrackingURL has changed, we will reset all Short URLs
                record.ShortURL__c = '';
                records.add(record);
            }

        }
        
        return records;

    }

    /**
     * Updates each TourCampaignAdPlan__c's ShortURL
     *
     * @param   tourId Id - the id of the Tour__c record
     * @param   requestId String - random value to be added to RequestId__c field
     * @return  Map - map of each updated ShortURL mapped by its record Id
    **/
    @AuraEnabled
    public static Map<Id,String> updateShortUrls(List<Id> recordIds, String requestId) {

        Map<Id,String> result = new Map<Id,String>();
        List<TourCampaignAdPlan__c> records = new List<TourCampaignAdPlan__c>();
        for (TourCampaignAdPlan__c record : [
            select
                RequestID__c,
                ShortURL__c,
                TrackingURL__c 
            from TourCampaignAdPlan__c 
            where Id in :recordIds
        ]) {

            LNE_ShortlinkService.BitlyResult bitly;
            if (!Test.isRunningTest()) {
                bitly = LNE_ShortlinkService.shortenUrl(record.TrackingURL__c);
            }
            else {
                bitly = new LNE_ShortlinkService.BitlyResult();
                bitly.errorCode = 0;
                bitly.errorMessage = '';
                bitly.shortenedUrl = 'foo';
            }

            record.RequestID__c = requestId;
            record.ShortURL__c = (bitly.errorCode == 0)
                ? bitly.shortenedUrl
                : '';

            if (bitly.errorCode == 0) {
                records.add(record);
            }
            else {
                System.debug('Bitly Error Encountered: ' + String.format('{0}-{1}', new List<String> {
                    String.valueOf(bitly.errorCode),
                    bitly.errorMessage
                }));
            }

            result.put(record.Id, record.ShortURL__c);

        }

        if (!records.isEmpty()) {
            List<Database.SaveResult> srs = Database.update(records, false);
            for (Integer i = 0; i < srs.size(); i++) {
                if (!srs[i].isSuccess()) {
                    result.put(records[i].Id, '');
                }
            }
        }

        return result;

    }

    /**
     * Updates the Tour's RequestId with the supplied value
     *
     * @param   tourId Id - the id of the Tour__c record
     * @param   requestId String - random value to be added to RequestId__c field
     * @return  Boolean - success of the save operation
    **/
    @AuraEnabled
    public static Boolean updateTour(Id tourId, String requestId) {

        Tour__c tour = new Tour__c(
            Id = tourId,
            RequestID__c = requestId
        );

        Database.SaveResult sr = Database.update(tour, false);
        return sr.isSuccess();

    }

}