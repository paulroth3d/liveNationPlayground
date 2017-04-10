@IsTest
private class LNE_EventVenuePromoterPicker_CX_Test {
	
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
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_EventVenuePromoterPicker_CX_Test' );
		}
		
		public void typicalSetup(){
			
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
	
	static testMethod void testScenario() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		Event__c event = [select Office__c, Venue__c, Promoter__c from Event__c limit 1];

		PageReference pr = Page.LNE_EventVenuePromoterPicker;
		pr.getParameters().put('id', event.Id);
		Test.setCurrentPage(pr);

		ApexPages.StandardController sc = new ApexPages.StandardController(event);
		LNE_EventVenuePromoterPicker_CX cx = new LNE_EventVenuePromoterPicker_CX(sc);

		cx.checkCanEdit();
		cx.save();
		
		//-- your logic off of any info from TS here
		System.assert( true, 'ts.account.DMA__c is not null, etc.' );
	}

}