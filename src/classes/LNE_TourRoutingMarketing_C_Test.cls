@IsTest
private class LNE_TourRoutingMarketing_C_Test {
	
	final static Id ACCOUNT_VENUE_RECTYPE_ID;

	static {

		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 
			'Account.Venue'
		});

		ACCOUNT_VENUE_RECTYPE_ID = recordTypeMap.get('Account.Venue');

	}
	
	@testSetup
	static void setup(){
		LNE_TestObjectFactory.prepStandardCustomSettings();
		LNE_TestObjectFactory.createStandardDataSet();
	}

	class TestSettings {

		public Tour__c tour {get;set;}
		public AdPlan__c adplan {get;set;}
		
		public TestSettings() {
			//-- global setup here
			
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
		}
		
		public TestSettings typicalSetup(){

			// create Account Artist
			Account artist = [select Id from Account where Name = 'Pennyback'];
			Event__c event = [select Id from Event__c limit 1];

			// create a Tour__c
			this.tour = LNE_TestObjectFactory.createTour('Name', artist.Id);
			insert this.tour;

			// create ad plan
			this.adplan = LNE_TestObjectFactory.createAdPlan('Name', 10000, event.Id, this.tour.Id);
			insert this.adplan;

			this.adplan = [select Name from AdPlan__c where Id = :this.adplan.Id];

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
	static testMethod void test_TourRoutingMarketing_Instance() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();
		
		PageReference pr = Page.LNE_TourRoutingMarketing;
		pr.getParameters().put('id', ts.tour.Id);
		Test.setCurrentPage(pr);

		ApexPages.StandardController sc = new ApexPages.StandardController(ts.tour);
		LNE_TourRoutingMarketing_C cx = new LNE_TourRoutingMarketing_C(sc);

		List<SelectOption> divisions = cx.getDivisions();
		System.assert(!divisions.isEmpty());

		List<SelectOption> venues = cx.getVenueTypes();
		System.assert(!venues.isEmpty());

	}

	static testMethod void test_TourRoutingMarketing_Assoc() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();
		Map<Id,String> result = LNE_TourRoutingMarketing_C.associateAdPlansToTour(new List<Id> { ts.adplan.Id }, ts.tour.Id);

	}

	static testMethod void test_TourRoutingMarketing_Artists() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();
		List<String> artists = LNE_TourRoutingMarketing_C.searchArtists('Penny');

	}

	static testMethod void test_TourRoutingMarketing_SOSL() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		List<AdPlan__c> adplans = LNE_TourRoutingMarketing_C.getAdPlans(ts.tour.Id);
		//System.assert(!adplans.isEmpty());

		LNE_TourRoutingMarketing_C.SearchTerms terms = new LNE_TourRoutingMarketing_C.SearchTerms();
		terms.adplanName = 'Name';

		List<AdPlan__c> searchSOSL = LNE_TourRoutingMarketing_C.searchAdPlans(terms, null);
		////System.assert(!searchSOSL.isEmpty());
		
	}

	static testMethod void test_TourRoutingMarketing_SOQL1() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		LNE_TourRoutingMarketing_C.SearchTerms terms = new LNE_TourRoutingMarketing_C.SearchTerms();
		terms.adplanId = ts.adplan.Name;

		List<AdPlan__c> searchSOQL0 = LNE_TourRoutingMarketing_C.searchAdPlans(terms, null);

	}

	static testMethod void test_TourRoutingMarketing_SOQL2() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		Account venue = [select Type from Account where RecordTypeId = :ACCOUNT_VENUE_RECTYPE_ID];
		LNE_TourRoutingMarketing_C.SearchTerms terms = new LNE_TourRoutingMarketing_C.SearchTerms();
		terms.venueType = venue.Type;

		List<AdPlan__c> searchSOQL1 = LNE_TourRoutingMarketing_C.searchAdPlans(terms, null);

	}

}