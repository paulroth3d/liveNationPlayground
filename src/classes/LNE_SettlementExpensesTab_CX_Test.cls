@isTest
public class LNE_SettlementExpensesTab_CX_Test{
	static final String RT_VENDOR = 'Account.Vendor';
	static final String RT_Rental = 'Event__c.Rental';
    static final String RT_Hold = 'Event__c.Hold';

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    class TestSettings {
    	public Event__c event;
    	public LedgerEntry__c ledger;
    	public LedgerEntryBreakout__c breakout;

    	public TestSettings(){
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
			
			Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
				new String[]{ 'LedgerEntry__c.Expenses' }
			);
			Id RT_EXPENSES_ID = recordTypeMap.get( 'LedgerEntry__c.Expenses' );

            List<GLAccount__c> gls = new List<GLAccount__c>();
            GLAccount__c breakoutGL = LNE_TestObjectFactory.createGLAccount('ASCAP/BMI/SESAC/GMR/BUMA Expense', '50202');
            gls.add(breakoutGL);
            GLAccount__c eventInsuranceGL = LNE_TestObjectFactory.createGLAccount('Event Insurance Expense', '50306');
            gls.add(eventInsuranceGL);
            
            insert gls;
            
            List<PerformingRightsFee__c> prfs = new List<PerformingRIghtsFee__c>();
            
			PerformingRightsFee__c prf1 = new PerformingRightsFee__c(
            	ExternalId__c = 'ASCAP',
                Type__c = 'ASCAP',
                GLAccount__c = breakoutGL.Id,
                Breakout__c = true,
                CapacityRangeStart__c = 0,
                CapacityRangeEnd__c = 200000,
                RateType__c = '% of Net Gross',
                RateAmount__c = 0.45,
                StartDate__c =  date.ValueOf('2010-01-01'),
                EndDate__c =  date.ValueOf('2030-12-31')
            );
            
            prfs.add(prf1);
            
            PerformingRightsFee__c prf2 = new PerformingRightsFee__c(
            	ExternalId__c = 'EventInsurance',
                Type__c = 'Event Insurance Expense',
                GLAccount__c = eventInsuranceGL.Id,
                Breakout__c = false,
                RateType__c = 'Flat',
                RateAmount__c = 0.45,
                StartDate__c =  date.ValueOf('2010-01-01'),
                EndDate__c =  date.ValueOf('2030-12-31')
            );
            
            prfs.add(prf2);          
            
            insert prfs;
            
			Event__c Evt1 = new Event__c(
				ProjectedPaidTickets__c = 10000,
				ProjectedDropCount__c = 10000,
                ActualDropCount__c = 10000,
                EventLastDate__c = date.today(),
                SelloutDropCount__c= 3000
                
			);
			
			Map<String, Id> objectToId = 
			    LNE_TestObjectFactory.createStandardDataSetList(new List<Event__c>{Evt1});
			
		   	ledger = new LedgerEntry__c (
				GLAccount__c = objectToId.get('ancillary'),
				BaseAmount__c = 100,
				RateType__c = 'Flat', 
				RecordTypeId = RT_EXPENSES_ID,
				Event__c = Evt1.Id
			); 

			insert ledger;
			
			LNE_FinancialCalculator.currentlyRunning = true;
			
			breakout = new LedgerEntryBreakout__c(LedgerEntry__c=ledger.Id);
			insert breakout;
			
			this.event = Evt1;
	    }
	    
	    public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
	    }
    }

    
    private static testMethod void testSettlementExpensesTab(){
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.event);
        LNE_SettlementExpensesTab_CX cx = new LNE_SettlementExpensesTab_CX(sc);
        cx.startSettlement();

        System.assertNotEquals(3, [SELECT count() FROM Deal__c]);
        
        Test.stopTest();
    }
    
    private static testMethod void testShowHide() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.event);
        LNE_SettlementExpensesTab_CX cx = new LNE_SettlementExpensesTab_CX(sc);
        
        System.assertEquals(cx.VIEW_CALCULATIONS, cx.calculationsButtonValue);
        
        cx.showHideCalculations();
        System.assertEquals(cx.HIDE_CALCULATIONS, cx.calculationsButtonValue);
        
        cx.showHideCalculations();
        System.assertEquals(cx.VIEW_CALCULATIONS, cx.calculationsButtonValue);        
        
        Test.stopTest();
    }
    
    private static testMethod void defaultFees() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.event);
        LNE_SettlementExpensesTab_CX cx = new LNE_SettlementExpensesTab_CX(sc);
        
        LNE_SettlementExpensesTab_CX.defaultFees(ts.event.id);
        
        System.assertEquals(3, [SELECT count() FROM LedgerEntry__c]);
        
        Test.stopTest();        
    }
    
    private static testMethod void testLedgers() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.event);
        LNE_SettlementExpensesTab_CX cx = new LNE_SettlementExpensesTab_CX(sc);
        
        LNE_FinancialCalculator.currentlyRunning = true;
        ts.ledger.PromoterAmount__c = 123;
        update ts.ledger;
        
        LedgerEntry__c b = [SELECT PromoterAmountRate__c, SettlementRateType__c FROM LedgerEntry__c WHERE Id = :ts.ledger.Id];
        system.assertEquals(123, b.PromoterAmountRate__c);
        system.assertEquals('Flat', b.SettlementRateType__c);
        
        Test.stopTest();        
    }
    
    private static testMethod void testBreakouts() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.event);
        LNE_SettlementExpensesTab_CX cx = new LNE_SettlementExpensesTab_CX(sc);
        
        LNE_FinancialCalculator.currentlyRunning = true;
        ts.breakout.PromoterAmount__c = 123;
        update ts.breakout;
        
        LedgerEntryBreakout__c b = [SELECT PromoterAmountRate__c, SettlementRateType__c FROM LedgerEntryBreakout__c WHERE Id = :ts.breakout.Id];
        system.assertEquals(123, b.PromoterAmountRate__c);
        system.assertEquals('Flat', b.SettlementRateType__c);
        
        Test.stopTest();        
    }
}