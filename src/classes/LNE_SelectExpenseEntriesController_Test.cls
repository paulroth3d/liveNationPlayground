@isTest
public class LNE_SelectExpenseEntriesController_Test {

	@TestSetup
    static void setup() {
		LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
    private class TestSettings {
    	
        public Event__c myEvent { get; private set; }
        Id RT_EXPENSES_ID;
        
        public TestSettings() {
        	Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
				new String[]{ 'LedgerEntry__c.Expenses' }
			);
			RT_EXPENSES_ID = recordTypeMap.get( 'LedgerEntry__c.Expenses' );
        	
        	//-- we don't need the financial calculator to run until we're done with all this
        	LNE_FinancialCalculator.currentlyRunning = true;
        	LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
        	
        	//-- assert there should only be one event.
			this.myEvent = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Status__c = 'Draft'
            );
			
			Map<String, Id> objectToId = LNE_TestObjectFactory.createStandardDataSet( this.myEvent );
			
			LNE_FinancialCalculator.currentlyRunning = true;
			
			LedgerEntry__c ledger = new LedgerEntry__c (
				GLAccount__c = objectToId.get('ancillary'),
				BaseAmount__c = 100,
				RateType__c = 'Flat', 
				RecordTypeId = RT_EXPENSES_ID,
				OfferRate__c = 123,
				Event__c = myEvent.Id
			); 

			insert ledger;
			
			LedgerEntryBreakout__c breakout = new LedgerEntryBreakout__c(LedgerEntry__c=ledger.Id,OfferRate__c = 123);
			insert breakout;
        }
        
        
        public TestSettings typicalSetup(){
        	
        	//-- is any of this background, something we can assume will be there always?            
            LNE_Util.refreshGLAccountCache();

            return this;

        }
        
        public TestSettings finalize(){
        	//-- now we're done with updating everything, have the financial calculator run.
        	LNE_FinancialCalculator.currentlyRunning = false;
        	LNE_FinancialCalculator.popRunningTrigger();
            return this;
        }
    }

	static testMethod void test_SelectExpenseEntries() {

        TestSettings ts = new TestSettings().typicalSetup().finalize();

        //GLAccount__c acct = LNE_TestObjectFactory.createGLAccount('LA National Touring Allocation', '50360');
        GLAccount__c acct = [select ApplyToPromotedEvent__c from GLAccount__c limit 1];
        acct.ApplyToPromotedEvent__c = true;
        update acct;

        PageReference pr = Page.LNE_SelectExpenseEntries;
        pr.getParameters().put('type', 'foo');
        Test.setCurrentPage(pr);        

        LNE_SelectExpenseEntriesController con = new LNE_SelectExpenseEntriesController();
        con.eventId = ts.myEvent.Id;
        List<GLAccount__c> expenseEntries = (List<GLAccount__c>)JSON.deserialize(con.expenseEntriesJson, List<GLAccount__c>.class);
        con.selectedEntriesJson = JSON.serialize(new List<Id> { expenseEntries[0].Id });
        con.addOrRemoveExpenseEntries();
        con.getRelatedExpenses();
        con.addOrRemoveExpenseEntries();
    }

    static testMethod void test_SelectExpenseEntries2() {

        TestSettings ts = new TestSettings().typicalSetup().finalize();

        //GLAccount__c acct = LNE_TestObjectFactory.createGLAccount('LA National Touring Allocation', '50360');
        GLAccount__c acct = [select ApplyToPromotedEvent__c from GLAccount__c limit 1];
        acct.ApplyToPromotedEvent__c = true;
        update acct;

        PageReference pr = Page.LNE_SelectExpenseEntries;
        pr.getParameters().put('type', 'foo');
        pr.getParameters().put('event_id', ts.myEvent.Id);
        Test.setCurrentPage(pr);        

        LNE_SelectExpenseEntriesController con = new LNE_SelectExpenseEntriesController();

    }

}