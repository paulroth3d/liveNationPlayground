@IsTest
private class LNE_EventAutoMatchTour_Batch_Test {
	
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
			Account artist = [select Name from Account where Name = 'Pennyback'];
			this.event = [select EventTitle__c, Name, PrimaryHeadlinerArtist__c from Event__c limit 1];
			this.event.PrimaryHeadlinerArtist__c = artist.Name;
			this.event.EventFirstDate__c = System.today();
			update this.event;

			// create a Tour__c
			this.tour = LNE_TestObjectFactory.createTour('Name', artist.Id);
			this.tour.FilterExpirationDate__c = System.today().addDays(1);
			this.tour.FilterArtist__c = artist.Name;
			this.tour.FilterStartDate__c = System.today().addDays(-1);
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

	private static testMethod void test_EventAutoMatchTour_Batch() {

		TestSettings ts = new TestSettings().typicalSetup().finalize();

		Test.startTest();

		new LNE_EventAutoMatchTour_Batch().execute(null);

		Test.stopTest();

	}

}