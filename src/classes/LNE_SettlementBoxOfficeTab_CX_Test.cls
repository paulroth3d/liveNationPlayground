@isTest
private class LNE_SettlementBoxOfficeTab_CX_Test {

	class TestSettings {
		public Event__c testEvent;
		DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
		EventDateTime__c eventDateTime;
		
		public TestSettings() {
			testEvent = [SELECT Id FROM Event__c LIMIT 1];
			
			eventDateTime = new EventDateTime__c(
                Event__c = testEvent.Id, 
                EventYear__c = String.valueOf(System.now().year() + 2),
                EventDate__c = System.today().addDays(10),
                StartTime__c = '6:00 PM');
        	insert eventDateTime;
		}
		public void typicalSetup(){}
		public void finalize(){}
	}

	@TestSetup static void setupTestData() {
    	LNE_TestObjectFactory.prepStandardCustomSettings();
    	LNE_TestObjectFactory.createStandardDataSet();
    }

    static LNE_SettlementBoxOfficeTab_CX setupController(Event__c event) {
        ApexPages.currentPage().getParameters().put('id', event.Id);
        ApexPages.StandardController standardEventCtlr = new ApexPages.StandardController(event);
        LNE_SettlementBoxOfficeTab_CX tabController = new LNE_SettlementBoxOfficeTab_CX(standardEventCtlr);

        return tabController;
    }

    static void setupPlatinumScales(Event__c event, Id eventDateTimeId) {
    	
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = event.id,
            Type__c = 'Platinum',
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Price__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            StageType__c = 'Settlement',
            EventDateTime__c = eventDateTimeId
        );
        insert ticketScale1;

        TicketScale__c ticketScale2 = new TicketScale__c(
            Event__c = event.id,
            Type__c = 'Platinum',
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 5000,
            Price__c = 250,
            Comps__c = 2500,
            Capacity__c = 8000,
            StageType__c = 'Settlement'
        );
        insert ticketScale2;
    }

    @isTest static void validateCheckPlatinumTicketScalesWNoScales() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();

        Test.startTest();
        LNE_SettlementBoxOfficeTab_CX tabController = setupController(ts.testEvent);
        tabController.checkPlatinumTicketScales();
        tabController.showBoxOfficeTab();
        System.assertEquals('box_office', tabController.tabToShow);
        tabController.showPlatinumAndDeductionsTab();
        System.assertEquals('platinum_and_deductions', tabController.tabToShow);
        Test.stopTest();

        System.assert(tabController.numPlatinumTicketScales == 0);
    }

    @isTest static void validateCheckPlatinumTicketScalesWScales() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();

        GeneralSettings__c gs = [SELECT Grid_Lost_Focus_Poll_Interval__c FROM GeneralSettings__c];
        gs.Grid_Lost_Focus_Poll_Interval__c = '234';
        update gs;

        setupPlatinumScales(ts.testEvent, ts.eventDateTime.Id);

        Test.startTest();

        LNE_SettlementBoxOfficeTab_CX tabController = setupController(ts.testEvent);
        tabController.checkPlatinumTicketScales();

        Test.stopTest();

        System.assert(tabController.numPlatinumTicketScales == 2);
        tabController.dropCountGridSave();
        System.assertEquals('234', tabController.getGridLostFocusPollInterval());
        system.assertEquals(ts.DATA_SETTINGS.CombinedKeyDelimiter__c, tabController.delimiter);
        system.assertEquals(1, LNE_SettlementBoxOfficeTab_CX.checkPlatinum(ts.eventDateTime.Id));
    }
}