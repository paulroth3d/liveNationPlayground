@IsTest
private class LNE_SelectFinanceAncCOGSEntries_CX_Test {

	static final Id RT_ANCILLARY_ID;
	static final Id RT_COGS_ID;

	static {
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{ 'LedgerEntry__c.Ancillary', 'LedgerEntry__c.COGS' }
		);
		RT_ANCILLARY_ID = recordTypeMap.get( 'LedgerEntry__c.Ancillary' );
		RT_COGS_ID = recordTypeMap.get( 'LedgerEntry__c.COGS' );
	}

	@TestSetup
	static void setup() {
		LNE_TestObjectFactory.prepStandardCustomSettings();
		LNE_TestObjectFactory.createStandardDataSet();
	}
 
	class TestSettings {

		public Event__c event {get;set;}
		
		public TestSettings() {
			//-- global setup here
			
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'TEST_CLASS' );
		}
		
		public TestSettings typicalSetup() {

			GLAccount__c ancillary = [select Id from GLAccount__c where GLCode__c = :LNE_TestObjectFactory.GL_ALCOHOLIC_REVENUE limit 1];
			GLAccount__c cogs = [select Id from GLAccount__c where GLCode__c = :LNE_TestObjectFactory.GL_AUTO_RENTAL_EXPENSE limit 1];
			
			this.event = [select Id from Event__c limit 1];

			LedgerEntry__c ledger0 = new LedgerEntry__c (
				GLAccount__c = ancillary.Id,
				BaseAmount__c = 100,
				RateType__c = 'Flat', 
				RecordTypeId = RT_ANCILLARY_ID,
				Event__c = event.Id
			);
			LedgerEntry__c ledger1 = new LedgerEntry__c (
				GLAccount__c = cogs.Id,
				BaseAmount__c = 100,
				RateType__c = 'Flat', 
				RecordTypeId = RT_COGS_ID,
				Event__c = event.Id
			);
			insert new List<LedgerEntry__c> { ledger0, ledger1 };



			return this;
		}
		
		public TestSettings finalize() {
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
			return this;
		}
	}

	static testMethod void test_SelectFinanceAncillaryCOGSEntries() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();
		Test.startTest();

		PageReference pr = Page.LNE_SelectFinanceAncillaryCOGSEntries;
		pr.getParameters().put('id', ts.event.Id);
		Test.setCurrentPage(pr);

		ApexPages.StandardController sc = new ApexPages.StandardController(ts.event);
		LNE_SelectFinanceAncillaryCOGSEntries_CX cx = new LNE_SelectFinanceAncillaryCOGSEntries_CX(sc);

		List<LNE_LedgerCategoryModel> ancillaries = cx.getAncillaries();
		List<LNE_LedgerCategoryModel> cogs = cx.getCOGs();

		cx.updateLedgerEntries();

	}
	
}