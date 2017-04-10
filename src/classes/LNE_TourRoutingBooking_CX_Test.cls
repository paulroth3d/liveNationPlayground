@IsTest
private class LNE_TourRoutingBooking_CX_Test {
	
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
		public Event__c event {get;set;}
		
		public TestSettings() {
			//-- global setup here
			
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'Test_Class' );
		}
		
		public TestSettings typicalSetup(){

			// create Account Artist
			Account artist = [select Id from Account where Name = 'Pennyback'];
			this.event = [select EventTitle__c, Name from Event__c limit 1];

			// create a Tour__c
			this.tour = LNE_TestObjectFactory.createTour('Name', artist.Id);
			this.tour.FilterExpirationDate__c = System.today().addDays(-1);
			insert this.tour;

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
	static testMethod void test_TourRoutingBooking_Instance() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		
		PageReference pr = Page.LNE_TourRoutingMarketing;
		pr.getParameters().put('id', ts.tour.Id);
		Test.setCurrentPage(pr);

		ApexPages.StandardController sc = new ApexPages.StandardController(ts.tour);
		LNE_TourRoutingBooking_CX cx = new LNE_TourRoutingBooking_CX(sc);

		List<SelectOption> divisions = cx.getDivisions();
		System.assert(!divisions.isEmpty());

		List<SelectOption> venues = cx.getVenueTypes();
		System.assert(!venues.isEmpty());

		String todayDate = cx.getTodayFormatted();
		String startDate = cx.getStartFormatted();
		String endDate = cx.getEndFormatted();

	}

	static testMethod void test_TourRoutingBooking_Assoc() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		Map<Id,String> result = LNE_TourRoutingBooking_CX.associateEventsToTour(new List<Id> { ts.event.Id }, ts.tour.Id);

	}

	static testMethod void test_TourRoutingBooking_Artists() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		List<String> artists = LNE_TourRoutingBooking_CX.searchArtists('Penny');

	}

	static testMethod void test_TourRoutingBooking_GetEvents() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		List<Event__c> events = LNE_TourRoutingBooking_CX.getEvents(ts.tour.Id);
		//System.assert(!adplans.isEmpty());		
	}

	static testMethod void test_TourRoutingBooking_PresearchEvents() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		List<Event__c> events = LNE_TourRoutingBooking_CX.presearchEvents(ts.tour.Id);
		//System.assert(!adplans.isEmpty());		
	}

	static testMethod void test_TourRoutingBooking_SOSL() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		LNE_TourRoutingBooking_CX.SearchTerms terms = new LNE_TourRoutingBooking_CX.SearchTerms();
		terms.eventTitle = 'EventTitle__c';
		terms.eventBegin = System.today();

		List<Event__c> searchSOSL = LNE_TourRoutingBooking_CX.searchEvents(terms, null);
		////System.assert(!searchSOSL.isEmpty());
		
	}

	static testMethod void test_TourRoutingBooking_SOQL1() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		LNE_TourRoutingBooking_CX.SearchTerms terms = new LNE_TourRoutingBooking_CX.SearchTerms();
		terms.eventId = ts.event.Name;
		terms.eventBegin = System.today();

		List<Event__c> searchSOQL0 = LNE_TourRoutingBooking_CX.searchEvents(terms, null);

	}

	static testMethod void test_TourRoutingBooking_SOQL2() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		Account venue = [select Type from Account where RecordTypeId = :ACCOUNT_VENUE_RECTYPE_ID];
		LNE_TourRoutingBooking_CX.SearchTerms terms = new LNE_TourRoutingBooking_CX.SearchTerms();
		terms.venueType = venue.Type;
		terms.eventBegin = System.today();

		List<Event__c> searchSOQL1 = LNE_TourRoutingBooking_CX.searchEvents(terms, null);

	}

	static testMethod void test_TourRoutingBooking_UpdateFilter() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		LNE_TourRoutingBooking_CX.SearchFilters filters = new LNE_TourRoutingBooking_CX.SearchFilters();
		LNE_TourRoutingBooking_CX.updateTourFilters(ts.tour.Id, filters);

	}

}