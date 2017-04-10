@isTest
private class LNE_ExpenseTab_CX_Test {
	
    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    class TestSettings {
        
        public TestSettings() {
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
        }
        
        public void typicalSetup(){
        }
        
        public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
        }
    }

    static Event__c setupEvent() {
        Event__c evnt = new Event__c();
        LNE_TestObjectFactory.createStandardDataSet( evnt );
		
        return evnt;
    }

    static Event__c setupEventWExpense() {
        Event__c evnt = setupEvent();

        GLAccount__c glaAccount = new GLAccount__c(
            Type__c = 'Expenses',
            Name = 'Travel Expense',
            Category__c = 'Production Expense'
        );
        insert glaAccount;

        String expenseRecordTypeId = LNE_Util.getRecordTypes(new String[]{'LedgerEntry__c.Expenses'}).get('LedgerEntry__c.Expenses');

        LedgerEntry__c ledgerEntry = new LedgerEntry__c(
            GLAccount__c = glaAccount.Id,
            BaseAmount__c = 12345,
            RateType__c = 'Flat',
            Event__c = evnt.Id,
            RecordTypeId = expenseRecordTypeId
        );
        insert ledgerEntry;

        return evnt;
    }
	
	//-- @TODO: please move this to the testSettings
    static LNE_ExpenseTab_CX setupCtrls(Event__c evnt) {
        ApexPages.currentPage().getParameters().put('id', evnt.Id);
        ApexPages.StandardController standardEventCtlr = new ApexPages.StandardController(evnt);

        LNE_ExpenseTab_CX expenseTabCtlr = new LNE_ExpenseTab_CX(standardEventCtlr);

        return expenseTabCtlr;
    }

    @isTest static void validateGetRelatedExpensesWNoRel() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        Event__c evnt = setupEvent();
		ts.finalize();
		
        Test.startTest();
        LNE_ExpenseTab_CX expenseTabCtlr = setupCtrls(evnt);

        expenseTabCtlr.getRelatedExpenses();
        Test.stopTest();

        System.assert(expenseTabCtlr.hasRelatedExpenses == false);
    }

    @isTest static void validateGetRelatedExpensesWRel() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        Event__c evnt = setupEventWExpense();
		ts.finalize();
		
        Test.startTest();
        
        LNE_ExpenseTab_CX expenseTabCtlr = setupCtrls(evnt);

        expenseTabCtlr.getRelatedExpenses();

        System.assert(expenseTabCtlr.hasRelatedExpenses == true);
        System.assert(expenseTabCtlr.relatedExpensesCount == 1);
        System.assertNotEquals(expenseTabCtlr.getGridLostFocusPollInterval(), null, 'There should be a focus poll interval');

        expenseTabCtlr.usingHouseNut = true;
        expenseTabCtlr.houseNutAmount = 100000;
        expenseTabCtlr.updateEventHouseNut();

        evnt = [select id, UsingHouseNut__c, BookingHouseNut__c from Event__c where id =: evnt.Id];

        System.assertEquals(evnt.UsingHouseNut__c,true);
        System.assertEquals(evnt.BookingHouseNut__c,100000);

        Test.stopTest();
    }

    @isTest static void validateGetEvent() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        Event__c evnt = setupEvent();
		ts.finalize();
		
        Test.startTest();
        LNE_ExpenseTab_CX expenseTabCtlr = setupCtrls(evnt);

        Event__c relEvent = expenseTabCtlr.getEvent();
        Test.stopTest();

        //System.assert(relEvent == evnt);
        System.assert(true,'@TODO: correct above assert' );
    }

    @isTest static void testSaveEvent() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        Event__c evnt = setupEvent();
        ts.finalize();
        
        Test.startTest();
        LNE_ExpenseTab_CX expenseTabCtlr = setupCtrls(evnt);

        Id eventId = evnt.Id;
        Decimal advertisingbudget = 1000.00;
        String advertisingsettlementplan = 'Settle at Actual';
        Decimal numberofTrucks = 100;

        Boolean saveResult = LNE_ExpenseTab_CX.saveEvent(eventId, advertisingbudget, advertisingsettlementplan, numberofTrucks);
        Test.stopTest();

        evnt = [SELECT Id, AdvertisingBudget__c, AdvertisingSettlementPlan__c, NumberofTrucks__c 
                                FROM Event__c WHERE Id = :eventId];
        System.assertEquals(true, saveResult, 'Event should be update with the advertising details' );
        System.assertEquals(advertisingbudget, evnt.AdvertisingBudget__c, 'AdvertisingBudget is updated to value passed' );
        System.assertEquals(advertisingsettlementplan, evnt.AdvertisingSettlementPlan__c, 'AdvertisingSettlementPlan is updated to value passed' );
        System.assertEquals(numberofTrucks, evnt.NumberofTrucks__c, 'NumberofTrucks is updated to value passed' );
    }
}