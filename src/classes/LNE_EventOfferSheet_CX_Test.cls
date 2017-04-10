@IsTest
private class LNE_EventOfferSheet_CX_Test {
	
	@testSetup
	static void setup(){
		LNE_TestObjectFactory.prepStandardCustomSettings();
		LNE_TestObjectFactory.createStandardDataSet();
	}

	class TestSettings {
		
		public TestSettings() {
			//-- global setup here
			
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_EventOfferSheet_CX_Test' );
		}
		
		public TestSettings typicalSetup(){

			// nothing to do
			
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
	
	static testMethod void testScenario() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();
		
		Event__c testEvent = [select Id from Event__c limit 1];
		Deal__c testDeal = [select Id from Deal__c where Event__c = :testEvent.Id limit 1];

		PageReference pr = Page.LNE_EventOfferSheet;
		pr.getParameters().put('id', testEvent.Id);
		Test.setCurrentPage(pr);

		ApexPages.StandardController sc = new ApexPages.StandardController(testEvent);
		LNE_EventOfferSheet_CX cx = new LNE_EventOfferSheet_CX(sc);

		cx.selectedDealIds = testDeal.Id;
		cx.saveDeals();
		
	}

}