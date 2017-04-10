@isTest
private class LNE_TicketRevenueTab_CX_Test {

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet();
        
        LNE_Util.refreshGLAccountCache();
        glAccountsMap = LNE_Util.getGLAccounts(new String[] {'40100'});
    }

    static Map<String,GLAccount__c> glAccountsMap = LNE_Util.getGLAccounts(new String[] {'40100'});
    
    class TestSettings {
        Group testGroup;
        public Event__c testEvent {get; set;}
        DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
        EventDateTime__c testDateTime;
        
        public TestSettings() {}
        
        public void typicalSetup(Integer numberOfDateTimes, Boolean createAuditRecord){
            LNE_FinancialCalculator.currentlyRunning = true;
            LNE_FinancialCalculator.pushRunningTrigger( 'LNE_EventDateTimeUtil_T_Test' );

            GeneralSettings__c gs = [SELECT BypassPBFlow__c FROM GeneralSettings__c LIMIT 1];
            gs.BypassPBFlow__c = true;
            update gs;

            testEvent = [select Id, Venue__c from Event__c limit 1];
            
            List<EventDateTime__c> dateTimesToInsert = new List<EventDateTime__c>();

            EventDateTime__c eventDateTime = new EventDateTime__c(
                Event__c = testEvent.Id, 
                EventYear__c = String.valueOf(System.now().year() + 2),
                EventDate__c = System.today().addDays(10),
                StartTime__c = '6:00 PM');
            dateTimesToInsert.add(eventDateTime);
            
            testDateTime = eventDateTime;
            
            if (numberOfDateTimes > 1) {
            	EventDateTime__c eventDateTime2 = new EventDateTime__c(
	                Event__c = testEvent.Id, 
	                EventYear__c = String.valueOf(System.now().year() + 2),
	                EventDate__c = System.today().addDays(11),
	                StartTime__c = '8:00 PM');
	            dateTimesToInsert.add(eventDateTime2);
            }

			insert dateTimesToInsert;
			
			List<TicketScale__c> ticketScalesToInsert = new List<TicketScale__c>();
			
			String stageType = createAuditRecord == true ? 'Projection' : 'Plan';

            TicketScale__c ticketScale = new TicketScale__c();
            ticketScale.Type__c = 'Reserved';
            ticketScale.Capacity__c = 1000;
            ticketScale.Price__c = 100.00;
            ticketScale.Kills__c = 0;
            ticketScale.Comps__c = 0;
            ticketScale.ProjectedPaidTickets__c = 950;
            ticketScale.Event__c = testEvent.Id;
            ticketScale.LiftBeforeFee__c = 0;
            ticketScale.TMFeePercent__c = 0.0;
            ticketScale.StageType__c = stageType;
            ticketScale.EventDateTime__c = eventDateTime.Id;
            ticketScalesToInsert.add(ticketScale);

            TicketScale__c ticketScale2 = new TicketScale__c();
            ticketScale2.Type__c = 'Lawn';
            ticketScale2.Capacity__c = 1000;
            ticketScale2.Price__c = 100.00;
            ticketScale2.Kills__c = 0;
            ticketScale2.Comps__c = 0;
            ticketScale2.ProjectedPaidTickets__c = 950;
            ticketScale2.Event__c = testEvent.Id;
            ticketScale2.LiftBeforeFee__c = 0;
            ticketScale2.TMFeePercent__c = 0.0;
            ticketScale2.StageType__c = stageType;
            ticketScale2.EventDateTime__c = eventDateTime.Id;
            ticketScalesToInsert.add(ticketScale2);

            TicketScale__c ticketScale3 = new TicketScale__c();
            ticketScale3.Type__c = 'GA';
            ticketScale3.Capacity__c = 100;
            ticketScale3.Price__c = 100.00;
            ticketScale3.Kills__c = 0;
            ticketScale3.Comps__c = 0;
            ticketScale3.ProjectedPaidTickets__c = 100;
            ticketScale3.Event__c = testEvent.Id;
            ticketScale3.LiftBeforeFee__c = 7420.00;
            ticketScale3.TMFeePercent__c = 0.0;
            ticketScale3.StageType__c = stageType;
            ticketScale3.EventDateTime__c = eventDateTime.Id;
            ticketScalesToInsert.add(ticketScale3);
            
            if (createAuditRecord == true) {
            	TicketScale__c ticketScale4 = new TicketScale__c();
	            ticketScale4.Type__c = 'GA';
	            ticketScale4.Capacity__c = 100;
	            ticketScale4.Price__c = 100.00;
	            ticketScale4.Kills__c = 0;
	            ticketScale4.Comps__c = 0;
	            ticketScale4.ProjectedPaidTickets__c = 100;
	            ticketScale4.Event__c = testEvent.Id;
	            ticketScale4.LiftBeforeFee__c = 7420.00;
	            ticketScale4.TMFeePercent__c = 0.0;
	            ticketScale4.StageType__c = 'Audit';
	            ticketScale4.EventDateTime__c = eventDateTime.Id;
	            ticketScalesToInsert.add(ticketScale4);
            }
            
            insert ticketScalesToInsert;

            String ticketScaleList = ticketScale.Id + DATA_SETTINGS.CombinedKeyDelimiter__c + ticketScale2.Id + DATA_SETTINGS.CombinedKeyDelimiter__c + ticketScale3.Id;

            Deduction__c deduction = new Deduction__c();
            deduction.BeforeAfter__c = 'Before Adjusted';
            deduction.Event__c = testEvent.Id;
            deduction.RateType__c = 'Primary Multiplier Tax';
            deduction.AmountRate__c = 10;
            deduction.TicketScaleList__c = ticketScaleList;

            Deduction__c deduction2 = new Deduction__c();
            deduction2.BeforeAfter__c = 'Before Adjusted';
            deduction2.Event__c = testEvent.Id;
            deduction2.RateType__c = 'Primary Divider Tax';
            deduction2.AmountRate__c = 10;
            deduction2.TicketScaleList__c = ticketScaleList;

            insert new List<Deduction__c>{deduction,deduction2};
        }
        
        public void finalize(){}
    }

    static LNE_TicketRevenueTab_CX setupCtrls(Event__c evnt) {
        ApexPages.currentPage().getParameters().put('id', evnt.Id);
        ApexPages.StandardController standardEventCtlr = new ApexPages.StandardController(evnt);

        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = new LNE_TicketRevenueTab_CX(standardEventCtlr);

        return ticketRevenueTabCtlr;
    }

    @isTest static void validateCheckPlatinumTicketScalesWNoScales() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(1, false);
        ts.finalize();

        Event__c evnt = ts.testEvent;

        Test.startTest();
        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(evnt);

        ticketRevenueTabCtlr.checkPlatinumTicketScales();
        Test.stopTest();

        System.assert(ticketRevenueTabCtlr.numPlatinumTicketScales == 0);
    }

    @isTest static void validateCheckPlatinumTicketScalesWScales() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(1, false);
        ts.finalize();

        GeneralSettings__c gs = [SELECT Grid_Lost_Focus_Poll_Interval__c FROM GeneralSettings__c LIMIT 1];
        gs.Grid_Lost_Focus_Poll_Interval__c = '234';
        update gs;

        Event__c evnt = ts.testEvent;
        
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = evnt.id,
            Type__c = 'Platinum',
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Price__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            StageType__c = 'Plan'
        );
        insert ticketScale1;

        TicketScale__c ticketScale2 = new TicketScale__c(
            Event__c = evnt.id,
            Type__c = 'Platinum',
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 5000,
            Price__c = 250,
            Comps__c = 2500,
            Capacity__c = 8000,
            StageType__c = 'Plan'
        );
        insert ticketScale2;
        
        evnt.ProjectedDropCountPct__c = null;
        update evnt;

        Test.startTest();
        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(evnt);

        ticketRevenueTabCtlr.checkPlatinumTicketScales();
        ticketRevenueTabCtlr.dropCountGridSave();
        Test.stopTest();

        System.assert(ticketRevenueTabCtlr.numPlatinumTicketScales == 2);
        System.assertEquals('234', ticketRevenueTabCtlr.getGridLostFocusPollInterval());
    }
    
    /*
    * @description Testing showPlan() and showProjection()
    */
    @isTest static void testShows() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(1, false);
        ts.finalize();
        
        Event__c evnt = ts.testEvent;
        evnt.status__c = 'Flash Started'; //push to projection
        update evnt;
        

        Test.startTest();
        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(evnt);

        ticketRevenueTabCtlr.showPlan();
        system.assertEquals('Plan', ticketRevenueTabCtlr.currentGridType);
        
        ticketRevenueTabCtlr.showProjection();
        system.assertEquals('Projection', ticketRevenueTabCtlr.currentGridType);
        Test.stopTest();
    }
    
    /*
    * @description Testing importAuditFeed()
    */
    @isTest static void testImportAuditFeed1() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(2, false);
        ts.finalize();

        Event__c evnt = ts.testEvent;
        evnt.UsingTicketFeed__c = false;
        evnt.Status__c = 'Flash Started';
        update evnt;
        
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = evnt.id,
            Type__c = 'Platinum',
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Price__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            StageType__c = 'Audit'
        );

        TicketScale__c ticketScale2 = new TicketScale__c(
            Event__c = evnt.id,
            Type__c = 'Platinum',
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Price__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            StageType__c = 'Projection'
        );
        LNE_FinancialCalculator.runUpdates = false;
        insert new List<TicketScale__c>{ticketScale1,ticketScale2};

        Test.startTest();
        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(evnt);
        
        // test showAudit flag
        system.assertEquals(true, ticketRevenueTabCtlr.showAuditAvailableMessage);
        
        ticketRevenueTabCtlr.importAuditFeed();
        Test.stopTest();
    }
    
    /*
    * @description Testing importAuditFeed()
    */
    @isTest static void testImportAuditFeed2() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(1, false);
        ts.finalize();

        Event__c evnt = ts.testEvent;
        
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = evnt.id,
            Type__c = 'Platinum',
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Price__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            StageType__c = 'Audit'
        );
        LNE_FinancialCalculator.runUpdates = false;
        insert ticketScale1;
        
        Deduction__c d = new Deduction__c(Event__c = evnt.id, StageType__c = 'Projection');
        LNE_FinancialCalculator.runUpdates = false;
        insert d;
        
        Test.startTest();
        
        LedgerEntry__c le = new LedgerEntry__c(Event__c = evnt.id, GLAccount__c = glAccountsMap.get('40100').Id);
        LNE_FinancialCalculator.runUpdates = false;
        insert le;
        
        LedgerEntryBreakout__c leb = new LedgerEntryBreakout__c(LedgerEntry__c = le.id);
        LNE_FinancialCalculator.runUpdates = false;
        insert leb;

        
        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(evnt);
        ticketRevenueTabCtlr.importAuditFeed();
        
        // check that all TicketScaleList__c are null
        system.assertEquals(null, [select TicketScaleList__c from Deduction__c where Id =:d.Id].TicketScaleList__c);
        system.assertEquals(null, [select TicketScaleList__c from LedgerEntry__c where Id =:le.Id].TicketScaleList__c);
        system.assertEquals(null, [select TicketScaleList__c from LedgerEntryBreakout__c where Id =:leb.Id].TicketScaleList__c);

        Test.stopTest();
    }
    
    /*
    * @description Testing hideProjectedTickets() and hideLiftBeforeTaxes()
    */
    @isTest static void testHideProjectedTicketsAndLiftBeforeTaxes() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(1, false);
        ts.finalize();

        GeneralSettings__c gs = [SELECT Grid_Lost_Focus_Poll_Interval__c FROM GeneralSettings__c LIMIT 1];
        gs.Grid_Lost_Focus_Poll_Interval__c = '234';
        update gs;

        Event__c evnt = ts.testEvent;

        Test.startTest();
        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(evnt);

        ticketRevenueTabCtlr.hideProjectedTickets();
        system.assertEquals(true, ticketRevenueTabCtlr.eventMetrics.HidePreviouslyForecastedProjPdTkt__c);
        
        ticketRevenueTabCtlr.hideLiftBeforeTaxes();
        system.assertEquals(true, ticketRevenueTabCtlr.eventMetrics.HidePreviouslyForecastedLiftBfrTxs__c);
        Test.stopTest();
    }
    
    @isTest static void testImportAudit_SingleScale() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(1, true);
        ts.finalize();

        Test.startTest();

        Event__c event = ts.testEvent;

        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(event);
        ticketRevenueTabCtlr.importAuditFeed();

        List<TicketScale__c> tsList = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
        system.assertEquals(4, tsList.size());
    }
    
    @isTest static void testImportAudit_SingleDateTime() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(1, true);
        ts.finalize();

        Test.startTest();

        Event__c event = ts.testEvent;

        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(event);
        ticketRevenueTabCtlr.eventDateTimeToImport = ts.testDateTime.Id;
        ticketRevenueTabCtlr.importAuditFeedForCurrentDateTime();

        List<TicketScale__c> tsList = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
        system.assertEquals(4, tsList.size());
    }
    
    @isTest static void testImportAudit_HideDateTimeField() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(1, true);
        ts.finalize();

        Test.startTest();

        Event__c event = ts.testEvent;

        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(event);
        ticketRevenueTabCtlr.eventDateTimeToImport = ts.testDateTime.Id;
        ticketRevenueTabCtlr.fieldToHide = 'HidePreviouslyForecastedProjPdTkt__c';
        ticketRevenueTabCtlr.hideFieldForEventDateTime();

        EventDateTime__c testEdt = [SELECT HidePreviouslyForecastedProjPdTkt__c FROM EventDateTime__c WHERE Id = :ts.testDateTime.Id];
        system.assertEquals(true, testEdt.HidePreviouslyForecastedProjPdTkt__c);
    }

    @isTest static void testConvertToMultiScale() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(2, false);
        ts.finalize();

        Test.startTest();

        Event__c event = ts.testEvent;

        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(event);

        List<TicketScale__c> tsList = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
        system.assertEquals(3, tsList.size());

        ticketRevenueTabCtlr.convertToMultiScale();

        event = [SELECT UsingMultiScale__c FROM Event__c WHERE Id = :ts.testEvent.Id];
        system.assertEquals(true, event.UsingMultiScale__c);

        tsList = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
        system.assertEquals(6, tsList.size());
        
        system.assertEquals(ts.DATA_SETTINGS.CombinedKeyDelimiter__c, ticketRevenueTabCtlr.delimiter);
    }

    @isTest static void testRevertToSingleScale() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(2, false);
        ts.finalize();

        Event__c event = ts.testEvent;

        LNE_TicketRevenueTab_CX ticketRevenueTabCtlr = setupCtrls(event);

        List<TicketScale__c> tsList = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
        system.assertEquals(3, tsList.size());

        ticketRevenueTabCtlr.convertToMultiScale();

        Test.startTest();

        event = [SELECT UsingMultiScale__c FROM Event__c WHERE Id = :ts.testEvent.Id];
        system.assertEquals(true, event.UsingMultiScale__c);

        tsList = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
        system.assertEquals(6, tsList.size());

        ticketRevenueTabCtlr.revertToSingleScale();

        event = [SELECT UsingMultiScale__c FROM Event__c WHERE Id = :ts.testEvent.Id];
        system.assertEquals(false, event.UsingMultiScale__c);

        tsList = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
        system.assertEquals(3, tsList.size());
    }
}