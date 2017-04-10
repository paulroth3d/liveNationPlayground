/**
 * Test for LNE_TicketScalesToLedgerController.
 * @see US491
 * @see DE70
 * @see DE68
 * @see DE21
 * @see TA433
 **/
@isTest(SeeAllData=false)
public class LNE_TicketScalesToLedgerController_Test {
	
	static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';

    @TestSetup
    static void setup() {
		LNE_TestObjectFactory.prepStandardCustomSettings();

		//-- pr: can any of the items in the typical setup / global init be available here?
		
        //new TestSettings().typicalSetup();
        //// create event
        //Event__c e = new Event__c(
        //    Status__c = 'Draft'
        //);
        //insert e;

        //// create ticket scales
        //List<TicketScale__c> ticketScales = new List<TicketScale__c>();
        //for (Integer i = 0; i < 4; i++) {
        //    ticketScales.add(new TicketScale__c(
        //        Event__c = e.Id,
        //        ActualSalesToDate__c = 1,
        //        PriceLevel__c = 'PriceLevel__c',
        //        ProjectedPaidTickets__c = 1,
        //        StageType__c = 'Plan'
        //    ));
        //}
        //insert ticketScales;

        //// create ledger entry
        //LedgerEntry__c ledger = new LedgerEntry__c(
        //    Event__c = e.Id
        //);
        //insert ledger;
    }
    
    private class TestSettings {
    	
        public Event__c myEvent { get; private set; }
        public LedgerEntry__c testLedgerEntry { get; private set; }
        public LedgerEntryBreakout__c testLedgerEntryBreakout { get; private set; }
        public Deduction__c testDeduction { get; private set; }
        
        public TestSettings() {
        	
        	//-- we don't need the financial calculator to run until we're done with all this
        	LNE_FinancialCalculator.currentlyRunning = true;
        	LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
        	
        	//-- assert there should only be one event.
			this.myEvent = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Status__c = 'Draft'
            );
			
			LNE_TestObjectFactory.createStandardDataSet( this.myEvent );
        }
        
        
        public TestSettings typicalSetup(){
        	
        	//-- is any of this background, something we can assume will be there always?
            
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
                new String[]{ RT_Ancillary }
            );
            Id RT_ANCILLARY_ID = recordTypeMap.get( RT_Ancillary );
            
            LNE_Util.refreshGLAccountCache();
            
            Map<String,GLAccount__c> glAccountMap = LNE_Util.getGLAccounts(
            	new String[]{ LNE_TestObjectFactory.GL_ALCOHOLIC_REVENUE }
            );
            Id glAlcoholicRevenueId = glAccountMap.get( LNE_TestObjectFactory.GL_ALCOHOLIC_REVENUE ).Id;
        
            //GLAccount__c testGlaAcct1 = new GLAccount__c (
            //    Type__c = 'Ancillary',
            //    Name = 'Parking Revenue',
            //    Category__c = 'Other Event Revenue',
            //    GLCode__c = '12345'
            //);
            //insert testGlaAcct1;

            TicketScale__c ticketScale = new TicketScale__c(
                ActualSalesToDate__c = 10000,
                Event__c = this.myEvent.Id,
                PriceLevel__c = '1000',
                ProjectedPaidTickets__c = 10000,
                StageType__c = 'Plan'
            );
            insert ticketScale;
            
            LedgerEntry__c ledger1 = new LedgerEntry__c (
                GLAccount__c = glAlcoholicRevenueId,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                Event__c = this.myEvent.Id,
                TicketScaleList__c = '|' + ticketScale.Id + '|'
            ); 

            insert ledger1;

            LedgerEntryBreakout__c leb = new LedgerEntryBreakout__c();
            leb.LedgerEntry__c = ledger1.Id;
            insert leb;

            Deduction__c deduction = new Deduction__c();
            deduction.BeforeAfter__c = 'Before Adjusted';
            deduction.Event__c = this.myEvent.Id;
            deduction.RateType__c = 'Primary Multiplier Tax';
            deduction.AmountRate__c = 10;
            insert deduction;
           
            testLedgerEntry = ledger1;
            testLedgerEntryBreakout = leb;
            testDeduction = deduction;

            return this;

        }
        
        public TestSettings finalize(){
        	//-- now we're done with updating everything, have the financial calculator run.
        	LNE_FinancialCalculator.currentlyRunning = false;
        	LNE_FinancialCalculator.popRunningTrigger();
            return this;
        }
    }
    
    static testMethod void runSetupWithoutException() {
        try {
            TestSettings ts = new TestSettings();
            ts.typicalSetup();
            ts.finalize();
        } catch( Exception err ){
            //System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
        }
    }
    
    //-- test test methods here
    static testMethod void test_TicketScalesToLedgerController() {

        TestSettings ts = new TestSettings().typicalSetup().finalize();

        Event__c event = [select Id, ShowCount__c, UsingMultiScale__c, StatusStage__c from Event__c where id = :ts.myEvent.Id];
        System.debug(event);
    	
        PageReference pr = Page.LNE_AssignTicketScalesToLedgerEntries;
        pr.getParameters().putAll(new Map<String,String> {
            'id' => ts.myEvent.Id,
            'ledgerEntryId' => ts.testLedgerEntry.Id
        });
        Test.setCurrentPage(pr);

        ApexPages.StandardController sc = new ApexPages.StandardController(event);
        LNE_TicketScalesToLedgerController con = new LNE_TicketScalesToLedgerController(sc);

        LNE_TicketScalesToLedgerController.updateLedgerEntry(ts.testLedgerEntry.Id, '');

    }
  
    //@testSetup
    //static void setup(){
    //    LNE_TestObjectFactory.prepStandardCustomSettings();
    //}

    ////static testMethod void runSetupAWithoutException() {
    ////    try {
    ////        TestSettings ts = new TestSettings();
    ////        ts.typicalSetup();
    ////        ts.finalize();
    ////    } catch( Exception err ){
    ////        //System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
    ////    }
    ////}
    
    // //-- test functionality here
  
    //static testMethod void testAPI() {
    //    TestSettings ts = new TestSettings();
    //    ts.typicalSetup();
    //    LedgerEntry__c ledgerEntry = ts.testLedgerEntry;
    //    LedgerEntryBreakout__c ledgerEntryBreakout = ts.testLedgerEntryBreakout;
    //    Deduction__c deduction = ts.testDeduction;
             
    //    PageReference pageRef = Page.LNE_AssignTicketScalesToLedgerEntries;
    //    pageRef.getParameters().put('ledgerEntryId', ledgerEntry.Id);
    //    pageRef.getParameters().put('eventId', ledgerEntry.Event__c);
    //    Test.setCurrentPageReference(pageRef);
    //    LNE_TicketScalesToLedgerController api = new LNE_TicketScalesToLedgerController();
    //    api.updatedLedgerEntryId = ledgerEntry.Id;
    //    api.updateLedgerEntry();
    //    api.getMyUrl();
    //    system.assertEquals('true', api.updateLedgerSuccess);
    //    system.assertEquals(ledgerEntry.Event__c, api.getEventId());
    //    system.assertEquals(ledgerEntry.Id, api.getLedgerEntryId());

    //    List<TicketScale__c> ticketScaleList = api.getTicketScaleList();
    //    system.assertEquals(0, ticketScaleList.size());

    //    pageRef.getParameters().put('ledgerEntryId', ledgerEntryBreakout.Id);
    //    api = new LNE_TicketScalesToLedgerController();
    //    api.updatedLedgerEntryId = ledgerEntryBreakout.Id;
    //    api.updateLedgerEntry();

    //    pageRef.getParameters().put('ledgerEntryId', deduction.Id);
    //    api = new LNE_TicketScalesToLedgerController();
    //    api.updatedLedgerEntryId = deduction.Id;
    //    api.updateLedgerEntry();

    //    system.assertEquals('true', api.updateLedgerSuccess);
    //    system.assertEquals(ledgerEntry.Event__c, api.getEventId());
    //    system.assertEquals(deduction.Id, api.getLedgerEntryId());
    //}
}