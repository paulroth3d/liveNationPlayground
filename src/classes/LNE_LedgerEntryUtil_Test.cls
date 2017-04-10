@isTest
private class LNE_LedgerEntryUtil_Test {

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
    private class TestSettings {
        public Map<String, Id> objectToId {get; set;}
        public GLAccount__c gl50499 {get; set;}
        public GLAccount__c glX50148X {get; set;}
        
        public void initialize() {
            objectToId = LNE_TestObjectFactory.createStandardDataSet();  
            
            List<GLAccount__c> gls = new List<GLAccount__c>();
            
            gl50499 = LNE_TestObjectFactory.createGLAccount('TEST GL ACCOUNT 50499', '50499');
            gls.add(gl50499);
            
            glX50148X = LNE_TestObjectFactory.createGLAccount('TEST GL ACCOUNT X50148X', 'X50148X');
            gls.add(glX50148X);
            
            insert gls;            
        }
    }

	private static testMethod void testCreate50499() {
        TestSettings settings = new TestSettings();
        settings.initialize();
        
        Test.startTest();
        
        System.assertEquals(0, [SELECT count() FROM LedgerEntry__c]);
        
        update new Event__c(
            Id = settings.objectToId.get('event-0'),
            AdvertisingBudget__c = 100
        ); 
        
        List<LedgerEntry__c> results = 
            [SELECT OfferRateType__c, InHouseRateType__c FROM LedgerEntry__c];
            
        System.assertEquals(1, results.size());
        System.assertEquals('Flat', results.get(0).OfferRateType__c);
        System.assertEquals('Flat', results.get(0).InHouseRateType__c);
        
        Test.stopTest();
	}
	
	private static testMethod void testDelete50499ByAdvertisement() {
        TestSettings settings = new TestSettings();
        settings.initialize();
        
        Test.startTest();
        
        System.assertEquals(0, [SELECT count() FROM LedgerEntry__c]);
        
        update new Event__c(
            Id = settings.objectToId.get('event-0'),
            AdvertisingBudget__c = 100
        ); 
        
        List<LedgerEntry__c> results = 
            [SELECT OfferRateType__c, InHouseRateType__c FROM LedgerEntry__c];
            
        System.assertEquals(1, results.size());
        System.assertEquals('Flat', results.get(0).OfferRateType__c);
        System.assertEquals('Flat', results.get(0).InHouseRateType__c);
        
        Tour__c testTour = LNE_TestObjectFactory.createTour('Test Tour', settings.objectToId.get('artist'));
        insert testTour;
        
        AdPlan__c testAdPlan = LNE_TestObjectFactory.createAdPlan('Test Ad Plan', 10, settings.objectToId.get('event-0'), testTour.Id);
        insert testAdPlan;
        
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{'Account.Vendor'});
    	Id vendorRecordType = recordTypeMap.get('Account.Vendor');        
        
        Account vendor = LNE_TestObjectFactory.createAccount('Test Vendor');
        vendor.RecordTypeId = vendorRecordType;
        vendor.Format__c = 'Country';
        insert vendor;        
        
        insert LNE_TestObjectFactory.createAdvertisement(testAdPlan.Id, vendor.Id, System.today(), System.today().addDays(1), 100);
        
        System.assertEquals(0, [SELECT count() FROM LedgerEntry__c]);
        
        Test.stopTest();
	}
	
	private static testMethod void testDelete50499ByTourCampaignAdPlan() {
        TestSettings settings = new TestSettings();
        settings.initialize();
        
        Test.startTest();
        
        System.assertEquals(0, [SELECT count() FROM LedgerEntry__c]);
        
        update new Event__c(
            Id = settings.objectToId.get('event-0'),
            AdvertisingBudget__c = 100
        ); 
        
        List<LedgerEntry__c> results = 
            [SELECT OfferRateType__c, InHouseRateType__c FROM LedgerEntry__c];
            
        System.assertEquals(1, results.size());
        System.assertEquals('Flat', results.get(0).OfferRateType__c);
        System.assertEquals('Flat', results.get(0).InHouseRateType__c);
        
        Tour__c testTour = LNE_TestObjectFactory.createTour('Test Tour', settings.objectToId.get('artist'));
        insert testTour;
        
        AdPlan__c testAdPlan = LNE_TestObjectFactory.createAdPlan('Test Ad Plan', 10, settings.objectToId.get('event-0'), testTour.Id);
        insert testAdPlan;

        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{'TourCampaign__c.Digital'});
    	Id tourCampaignRecordType = recordTypeMap.get('TourCampaign__c.Digital');      
    	
    	TourCampaign__c testTourCampaign = LNE_TestObjectFactory.createTourCampaign(testTour.Id, tourCampaignRecordType);
    	insert testTourCampaign;
    	
    	TourCampaignAdPlan__c tcap = LNE_TestObjectFactory.createTourCampaignAdPlan(testTourCampaign.Id, testAdPlan.Id, null);
    	insert tcap;
    	
        tcap.AllocatedAmount__c = 200;
        update tcap;
 
        System.assertEquals(0, [SELECT count() FROM LedgerEntry__c]);
        
        Test.stopTest();
	}	
	
	private static testMethod void testCreateAndDeleteX50148X() {
        TestSettings settings = new TestSettings();
        settings.initialize();
        
        Test.startTest();
        
        System.assertEquals(0, [SELECT count() FROM LedgerEntry__c]);
        
        update new Event__c(
            Id = settings.objectToId.get('event-0'),
            UsingHouseNut__c = true
        ); 
        
        List<LedgerEntry__c> results = 
            [SELECT OfferRateType__c, SettlementRateType__c FROM LedgerEntry__c];
            
        System.assertEquals(1, results.size());
        System.assertEquals('Flat', results.get(0).OfferRateType__c);
        System.assertEquals('Flat', results.get(0).SettlementRateType__c);
        
        update new Event__c(
            Id = settings.objectToId.get('event-0'),
            UsingHouseNut__c = false
        );         
        
        System.assertEquals(0, [SELECT count() FROM LedgerEntry__c]);
        
        Test.stopTest();
	}
}