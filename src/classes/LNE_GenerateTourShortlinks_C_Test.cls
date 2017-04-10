@IsTest
private class LNE_GenerateTourShortlinks_C_Test {

	final static Id RECTYPE_ID_TOURCAMPAIGN_MISC;

	static {

		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{'TourCampaign__c.Misc'}
		);

		RECTYPE_ID_TOURCAMPAIGN_MISC = recordTypeMap.get('TourCampaign__c.Misc');
	}
	
	@testSetup
	static void setup(){
		LNE_TestObjectFactory.prepStandardCustomSettings();
		//System.debug( '21567c5c-436d-48bc-ad4d-e7221a312181: before standard data set' );
		LNE_TestObjectFactory.createStandardDataSet();
		//System.debug( '21567c5c-436d-48bc-ad4d-e7221a312181: after standardDataSet. Should not count towards limits, no? :' + LNE_FinancialCalculator.currentlyRunning );
	}

	class TestSettings {

		public Tour__c testTour;
		
		public TestSettings() {
			//-- global setup here
			
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_GenerateTourShortlinks_C_Test' );
		}
		
		public TestSettings typicalSetup(){
			//System.debug( '21567c5c-436d-48bc-ad4d-e7221a312181: starting typical setup:' + LNE_FinancialCalculator.currentlyRunning );
			
			Account artist = LNE_TestObjectFactory.createAccount('Account.Name');
			insert artist;
			
			//System.debug( '21567c5c-436d-48bc-ad4d-e7221a312181: after artist:' + LNE_FinancialCalculator.currentlyRunning );
			
			this.testTour = LNE_TestObjectFactory.createTour('name', artist.Id);
			insert this.testTour;

			//System.debug( '21567c5c-436d-48bc-ad4d-e7221a312181: after tour:' + LNE_FinancialCalculator.currentlyRunning );
			
			Event__c event = [select Id, Tour__c from Event__c limit 1];
			event.Tour__c = this.testTour.Id;
			update event;

			// odd place for this statement, but it is being used to reset SOQL limits
			Test.startTest();
			
			//System.debug( '21567c5c-436d-48bc-ad4d-e7221a312181: after event, Prior to inserting Ad Plans:' + LNE_FinancialCalculator.currentlyRunning );
			AdPlan__c adplan = LNE_TestObjectFactory.createAdPlan('name', 100, event.Id, this.testTour.Id);
			insert adplan;

			TourCampaign__c tc = LNE_TestObjectFactory.createTourCampaign(this.testTour.Id, RECTYPE_ID_TOURCAMPAIGN_MISC);
			insert tc;

			//TourCampaignAdPlan__c tcap = LNE_TestObjectFactory.createTourCampaignAdPlan(tc.Id, adplan.Id, 100);
			//insert tcap;
			

			Test.stopTest();

			return this;
		}
		
		public TestSettings finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();

			return this;
		}
	}
	
	
	//-- test test methods here
	
	static testMethod void runSetupAWithoutException() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();
		System.assert( true, 'No Exceptions have occurred in getting here' );
	}
	
   	//-- test functionality here
	
	static testMethod void testScenario1() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();
		
		List<TourCampaignAdPlan__c> tcaps = LNE_GenerateTourShortlinks_C.getTourCampaignAdPlans(ts.testTour.Id, new List<String>(), new List<String>());
		System.assert(!tcaps.isEmpty());

		List<Id> recordIds = new List<Id> { tcaps[0].Id };
		Map<Id,String> result = LNE_GenerateTourShortlinks_C.updateShortUrls(recordIds, 'foo');

	}

	static testMethod void testScenario_Types() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();
		List<String> types = LNE_GenerateTourShortlinks_C.getTypes(ts.testTour.Id);
	}

	static testMethod void testScenario_Vendors() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();
		List<String> vendors = LNE_GenerateTourShortlinks_C.getVendors(ts.testTour.Id);
	}

	static testMethod void testScenario_Tour() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();
		LNE_GenerateTourShortlinks_C.updateTour(ts.testTour.Id, 'foo');
	}

}