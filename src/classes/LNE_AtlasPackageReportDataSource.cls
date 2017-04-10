/*
 * Data for Atlas Package Report
*/
global class LNE_AtlasPackageReportDataSource implements Loop.IApexDataSource{
    private class DataSourceInputs {
        public String tourId;
        public String reportRunId;
        //public List<String> vendorNames;
        //public String announceType;
    }
    
    public Set<string> getGlobalDescribe() {
        return new Set<String>{
            'PackageDetails'
        };
    }    
    
    private Loop.ExternalData.QueryRequestInfo loopRequestInfo;

    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objNames) {
        List<Loop.ExternalData.DataObject> output = new List<Loop.ExternalData.DataObject>();
        
        for (string objName : objNames) {
            List<Loop.ExternalData.FieldInfo> outputFields = new List<Loop.ExternalData.FieldInfo>();
            
            if (objName == 'PackageDetails') {
                outputFields.add(new Loop.ExternalData.FieldInfo('FormattedPackageName',    Schema.DisplayType.STRING));
                outputFields.add(new Loop.ExternalData.FieldInfo('TrackingCustomParameter', Schema.DisplayType.STRING));
                outputFields.add(new Loop.ExternalData.FieldInfo('TrackingDomain',          Schema.DisplayType.STRING));
                outputFields.add(new Loop.ExternalData.FieldInfo('ShortUrl',                Schema.DisplayType.STRING));
            }

            output.add(new Loop.ExternalData.DataObject(objName, outputFields));
        }
        return output;
    }    
    
    
    public Set<string> getChildRelationships(string objectName) {
        Set<string> childObjectNames = new Set<string>();

        return childObjectNames;
    }    
    
    
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        this.loopRequestInfo = requestInfo;
        
        Loop.ExternalData.QueryResultSet results = new Loop.ExternalData.QueryResultSet();
        
        Loop.ExternalData.QueryResult packageDetails = new Loop.ExternalData.QueryResult('PackageDetails', new List<string> { 'FormattedPackageName', 'TrackingCustomParameter', 'TrackingDomain', 'ShortUrl' });

        for (string objectName : requestInfo.GetObjectNames()) {
            if (objectName == 'PackageDetails') {
                processPackageDetails(packageDetails);
                results.add(packageDetails);
            }
        }
        
        return results;
    }
    
    private void processPackageDetails(Loop.ExternalData.QueryResult packageDetails){
        DataSourceInputs inputVals = getInputs();
        List<TourCampaignAdPlan__c> tcapItems = getTourCampaignAdPlanItems(inputVals);
        
        for (TourCampaignAdPlan__c curItem : tcapItems){
            packageDetails.rows.add(new List<string>{ 
                getFormattedPackageName(curItem), 
                curItem.TrackingCustomParameter__c, 
                curItem.TrackingDomain__c, 
                curItem.ShortURL__c });        
        }
    }
    
    private string getFormattedPackageName(TourCampaignAdPlan__c srcItem){
        return
            srcItem.TourName__c + '_' + 
            srcItem.Vendor__c + '_' + 
            srcItem.City__c + '_' + 
            srcItem.State__c + '_' + 
            srcItem.AnnouncementType__c + '_' + 
            'SFID' + srcItem.Id;
    }
    
    private DataSourceInputs getInputs(){
        DataSourceInputs inputs = new DataSourceInputs();
        
        // this is going to not work well if there are simultaneous users trying to run that report
        inputs.tourId = this.loopRequestInfo.RecordId;
        inputs.reportRunId = [select RequestId__c from Tour__c where id = :inputs.tourId].RequestId__c;
        
        
        //inputs.tourId = 'a19R00000022Y9O';
        //inputs.vendorNames = new List<string> ();
        //inputs.vendorNames = new List<string> {'Google'};
        //inputs.vendorNames = new List<string> {'Google', 'Email Smoke Test Vendor'};
        //inputs.vendorNames = new List<string> {'Email Smoke Test Vendor'};
        //inputs.announceType = null;
        //inputs.announceType = 'Announce';
        
        return inputs;
        
    }
    
    private List<TourCampaignAdPlan__c> getTourCampaignAdPlanItems(DataSourceInputs inputs){
        List<TourCampaignAdPlan__c> data = [
           SELECT
                Id, TourName__c, City__c, State__c,
                Vendor__c, AnnouncementType__c,
                TrackingCustomParameter__c, TrackingDomain__c, ShortURL__c
            FROM
                TourCampaignAdPlan__c
            WHERE
            	RequestId__c = :inputs.reportRunId
        ];
        
        return data;
    }

	/*    
    private List<TourCampaignAdPlan__c> getTourCampaignAdPlanItems(DataSourceInputs inputs){
        List<TourCampaign__c> campaigns = [
            select Id from TourCampaign__c where Tour__c = :inputs.tourId
        ];
        
        string announceType;
        List<string> vendors;
        
        string soql = 
            'SELECT ' + 
                'Id, TourName__c, City__c, State__c, ' + 
                'Vendor__c, AnnouncementType__c, ' + 
                'TrackingCustomParameter__c, TrackingDomain__c, ShortURL__c ' + 
            'FROM ' + 
                'TourCampaignAdPlan__c ' + 
            'WHERE ' + 
                'TourCampaign__c in :campaigns '
            ;
            
        if (inputs.announceType != null) {
            announceType = inputs.announceType;
            
            soql += 'and AnnouncementType__c = :announceType ';
        }
        
        if (inputs.vendorNames.size() > 0) {
            vendors = inputs.vendorNames;
            
            soql += 'and Vendor__c IN :vendors ';
        }
        
        return (List<TourCampaignAdPlan__c>) Database.query(soql);
    }
	*/
}