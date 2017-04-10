/** 
 *	Test class for the LNE_AdvertisementSplit VF page and LNE_AdvertisementSplit__T class
 *
 *	@author Scott Will
 *  @group Test
 **/
 @IsTest(SeeAllData=false)
private class LNE_AdvertisementSplits_Test {
	
	static final String RT_VENDOR = 'Account.Vendor';
	
	class TestSettings {

		public Advertisement__c masterAd {get;set;}
		public Account vendor {get;set;}
		public AdPlan__c adplan0 {get;set;}
		public AdPlan__c adplan1 {get;set;}
		
		public TestSettings() {

		}
		
		public void typicalSetup(String advertRecordType, Decimal commission){

			//insert vendor
			Map<String,Id> accountRecordTypeMap = LNE_Util.getRecordTypes(
				new String[]{RT_VENDOR}
			);

			ID RT_VENDOR_ID = accountRecordTypeMap.get(RT_VENDOR);

			vendor = LNE_TestObjectFactory.createAccount('Test Vendor');
			vendor.RecordTypeId = RT_VENDOR_ID;
			vendor.Format__c = 'Country';

			insert vendor;

			//insert adplan
			adPlan0 = new AdPlan__c(
				AdPlanName__c = 'Test Ad Plan',
				LNEAdPlanBudget__c = 1000000,
				StandaloneDate__c = Date.today().addDays(7)
			);

			insert adPlan0;

			//insert advertisement

			Id recordTypeId;
			if(advertRecordType != null) recordTypeId =
				[select Name, DeveloperName from RecordType where Name =: advertRecordType and SobjectType = 'Advertisement__c'].Id;
			Date startDate = Date.today();
			Date endDate = startDate.addDays(7);
			
			masterAd = new Advertisement__c(	            
				AdPlan__c =  adPlan0.Id,
				BuyType__c = LNE_Constants.AD_BUY_TYPE_REGULAR,
				StartDate__c = startDate,
				EndDate__c = endDate,
				StartTime__c = '6:00 AM',
				EndTime__c = '10:00 PM',
				Rate__c = 100,
				NumberofSpots__c = 10000,
				Format__c = 'Country',
				Vendor__c = vendor.Id,
				SplitAmount__c = 1000,
				SplitPct__c = 50
			);
			if(recordTypeId != null) masterAd.RecordTypeId = recordTypeId;
			if(commission != null) masterAd.Commission__c = commission;
			insert masterAd;
			
		}

	  public void finalize(){
	  
	  }
	}
	
  //-- test test methods here

	@testSetup
	static void setup(){
		LNE_TestObjectFactory.prepStandardCustomSettings();
	}

	static testMethod void test_AdvertisementSplits_CX() {

		TestSettings ts = new TestSettings();
		ts.typicalSetup('Radio', null);

		PageReference pr = Page.LNE_AdvertisementSplit;
		pr.getParameters().put('id', ts.masterAd.Id);
		Test.setCurrentPage(pr);

		ApexPages.StandardController sc = new ApexPages.StandardController(ts.masterAd);
		LNE_AdvertisementSplit_CX cx = new LNE_AdvertisementSplit_CX(sc);

		LNE_AdvertisementSplit_CX.AdvertisementPackage ap = LNE_AdvertisementSplit_CX.getRelatedAdvertisements(ts.masterAd.Id);
		ap.advertisements.addAll(LNE_AdvertisementSplit_CX.createAdvertisements(new List<Id> { ts.adplan0.Id }, ts.masterAd.Id));
		LNE_AdvertisementSplit_CX.saveAdvertisements(ap.advertisements, ts.masterAd.Id);

		LNE_AdvertisementSplit_CX.searchAdPlans('Test', new List<Id>());

	}

	static testMethod void test_AdvertisementSplits_T() {

		TestSettings ts = new TestSettings();
		ts.typicalSetup('Radio', null);

		//create child ad
		Advertisement__c child = new Advertisement__c(
			AdPlan__c = ts.adplan0.Id,
			MasterAdForSplit__c = ts.masterAd.Id,
			SplitAmount__c = 1000,
			SplitPct__c = 50,
			StartDate__c = System.today(),
			EndDate__c = System.today(),
			Vendor__c = ts.vendor.Id
		);
		insert child;

		//update master
		ts.masterAd.NumberofSpots__c += 1000;
		update ts.masterAd;

		//delete child
		delete child;
		delete ts.masterAd;

	}

}