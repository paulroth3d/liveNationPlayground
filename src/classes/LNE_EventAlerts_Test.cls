@IsTest
private class LNE_EventAlerts_Test {
	
	public static GLAccount__c myGL_Account;
	
	@testSetup
	static void setup(){

		LNE_TestObjectFactory.prepStandardCustomSettings();
		//LNE_TestObjectFactory.createStandardDataSet();
		
	}

	class TestSettings {

		public Event__c myEvent { get; private set; }
		
		public TestSettings() {
			//-- global setup here
			
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_EventAlerts_Test' );

			this.myEvent = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Status__c = 'Draft'
            );
			
			LNE_TestObjectFactory.createStandardDataSet( this.myEvent );

			

		}
		
		public void typicalSetup() {

			GeneralSettings__c settings = new GeneralSettings__c(
				SetupOwnerId = UserInfo.getUserId(),
				NotificationAgeLimit__c = 7
			);
			insert settings;

			Integer maxAge = 0 - settings.NotificationAgeLimit__c.intValue();
			
			// create notifications
			insert new List<Notification__c> {
				new Notification__c(
					CreatedDate = System.now().addDays(maxAge - 1), // set date in past so batch can pick it up
					Status__c = 'Open',
					Type__c = 'Approval Flag',
					Description__c = 'description1',
					Event__c = this.myEvent.Id
				),
				new Notification__c(
					CreatedDate = System.now().addDays(maxAge + 1), // set date in past so batch wont pick it up
					Status__c = 'Open',
					Type__c = 'Acknowledgement Flag',
					Description__c = 'description2',
					Event__c = this.myEvent.Id
				)
			};

		}
		
		public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
		}
	}
	
	
	//-- test test methods here
	
	static testMethod void runSetupAWithoutException() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();
		System.assert( true, 'No Exceptions have occurred in getting here' );
	}
	
   	//-- test functionality here
	
	static testMethod void test_EventAlerts() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();
		
		Map<String,String> data = LNE_EventAlerts_C.getServerData();
		//System.assertEquals(UserInfo.getSessionId(), data.get('sessionId')); // this will fail if called from dev console
		System.assertEquals(UserInfo.getUserId(), data.get('userId'));

		List<Notification__c> notes = LNE_EventAlerts_C.getNotifications(ts.myEvent.Id);
		System.assert(!notes.isEmpty());

		Boolean success = LNE_EventAlerts_C.dismissNotifications(new List<Id> { notes[0].Id });
		System.assert(success);
		
	}

	static testMethod void test_EventAlerts_Batch() {

		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		List<Notification__c> notes = [select Id from Notification__c];
		System.assert(notes.size() == 2);

		Test.startTest();

		//run batch
		new LNE_EventAlertsRemoval_Batch().execute(null);

		Test.stopTest();

		// only 1 note should have been destroyed
		notes = [select Id from Notification__c];
		System.assert(notes.size() == 1);

	}

}