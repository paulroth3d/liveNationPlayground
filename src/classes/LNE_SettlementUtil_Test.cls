@isTest
private class LNE_SettlementUtil_Test {
	static String RT_TICKET_REVENUE = 'LedgerEntry__c.TicketRevenue';
	static String RT_EXPENSES = 'LedgerEntry__c.Expenses';

	static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
	    new String[]{ RT_TICKET_REVENUE, RT_EXPENSES }
    );

    static Id RT_TICKET_REVENUE_ID = recordTypeMap.get( RT_TICKET_REVENUE );
    static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );

	class TestSettings {
		public Event__c testEvent;
		
		public TestSettings() {
		}
		
		public void typicalSetup(){
			testEvent = [SELECT Id FROM Event__c WHERE BookingHouseNut__c = 5555 LIMIT 1];
		}
		
		public void finalize(){
		}
	}

	static void setupData(Event__c event) {

		LNE_FinancialCalculator.runUpdates = true;

		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Reserved';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 0;
		ticketScale.ProjectedPaidTickets__c = 950;
		ticketScale.Event__c = event.Id;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		ticketScale.StageType__c = 'Projection';

		TicketScale__c ticketScale2 = new TicketScale__c();
		ticketScale2.Type__c = 'Lawn';
		ticketScale2.Capacity__c = 1000;
		ticketScale2.Price__c = 100.00;
		ticketScale2.Kills__c = 0;
		ticketScale2.Comps__c = 0;
		ticketScale2.ProjectedPaidTickets__c = 950;
		ticketScale2.Event__c = event.Id;
		ticketScale2.LiftBeforeFee__c = 0;
		ticketScale2.TMFeePercent__c = 0.0;
		ticketScale2.StageType__c = 'Projection';

		TicketScale__c ticketScale3 = new TicketScale__c();
		ticketScale3.Type__c = 'Platinum';
		ticketScale3.Capacity__c = 100;
		ticketScale3.Price__c = 100.00;
		ticketScale3.Kills__c = 0;
		ticketScale3.Comps__c = 0;
		ticketScale3.ProjectedPaidTickets__c = 100;
		ticketScale3.Event__c = event.Id;
		ticketScale3.LiftBeforeFee__c = 7420.00;
		ticketScale3.TMFeePercent__c = 0.0;
		ticketScale3.StageType__c = 'Projection';

		insert new List<TicketScale__c>{ticketScale,ticketScale2,ticketScale3};

		LNE_FinancialCalculator.runUpdates = true;

		Deduction__c deduction = new Deduction__c();
		deduction.BeforeAfter__c = 'Before Adjusted';
		deduction.Event__c = event.Id;
		deduction.RateType__c = 'Primary Multiplier Tax';
		deduction.AmountRate__c = 10;
		deduction.StageType__c = 'Projection';

		Deduction__c deduction2 = new Deduction__c();
		deduction2.BeforeAfter__c = 'Before Adjusted';
		deduction2.Event__c = event.Id;
		deduction2.RateType__c = 'Primary Divider Tax';
		deduction2.AmountRate__c = 10;

		Deduction__c deduction3 = new Deduction__c();
		deduction3.BeforeAfter__c = 'Before Adjusted';
		deduction3.Event__c = event.Id;
		deduction3.RateType__c = 'Amount Per Ticket';
		deduction3.AmountRate__c = 10;
		deduction3.ApplyTicketScale__c = 'All Paid Tickets';

		Deduction__c deduction4 = new Deduction__c();
		deduction4.BeforeAfter__c = 'Before Adjusted';
		deduction4.Event__c = event.Id;
		deduction4.RateType__c = 'Secondary Multiplier Tax';
		deduction4.AmountRate__c = 10;

		Deduction__c deduction5 = new Deduction__c();
		deduction5.BeforeAfter__c = 'Before Adjusted';
		deduction5.Event__c = event.Id;
		deduction5.RateType__c = 'Secondary Divider Tax';
		deduction5.AmountRate__c = 10;

		Deduction__c deduction6 = new Deduction__c();
		deduction6.BeforeAfter__c = 'After Adjusted';
		deduction6.Event__c = event.Id;
		deduction6.RateType__c = 'Primary Multiplier Tax';
		deduction6.AmountRate__c = 10;

		Deduction__c deduction7 = new Deduction__c();
		deduction7.BeforeAfter__c = 'After Adjusted';
		deduction7.Event__c = event.Id;
		deduction7.RateType__c = 'Secondary Multiplier Tax';
		deduction7.AmountRate__c = 10;

		Deduction__c deduction8 = new Deduction__c();
		deduction8.BeforeAfter__c = 'After Adjusted';
		deduction8.Event__c = event.Id;
		deduction8.RateType__c = 'Amount Per Ticket';
		deduction8.AmountRate__c = 10;
		deduction8.ApplyTicketScale__c = 'All Paid Tickets';

		Deduction__c deduction9 = new Deduction__c();
		deduction9.BeforeAfter__c = 'After Adjusted';
		deduction9.Event__c = event.Id;
		deduction9.RateType__c = 'Primary Divider Tax';
		deduction9.AmountRate__c = 10;

		Deduction__c deduction10 = new Deduction__c();
		deduction10.BeforeAfter__c = 'After Adjusted';
		deduction10.Event__c = event.Id;
		deduction10.RateType__c = 'Secondary Divider Tax';
		deduction10.AmountRate__c = 10;

		insert new List<Deduction__c>{deduction,deduction2,deduction3,deduction4,deduction5,
									  deduction6,deduction7,deduction8,deduction9,deduction10};
	}

	static void setupComps(Event__c event) {

		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Reserved';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 100;
		//sellable capacity = capacity - kills - comps = 900
		ticketScale.ProjectedPaidTickets__c = 950;
		ticketScale.Event__c = event.Id;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		insert ticketScale;

		TicketScale__c ticketScale2 = new TicketScale__c();
		ticketScale2.Type__c = 'Lawn';
		ticketScale2.Capacity__c = 1000;
		ticketScale2.Price__c = 100.00;
		ticketScale2.Kills__c = 0;
		ticketScale2.Comps__c = 100;
		//sellable capacity = capacity - kills - comps = 900
		ticketScale2.ProjectedPaidTickets__c = 950;
		ticketScale2.Event__c = event.Id;
		ticketScale2.LiftBeforeFee__c = 0;
		ticketScale2.TMFeePercent__c = 0.0;
		insert ticketScale2;

		TicketScale__c ticketScale3 = new TicketScale__c();
		ticketScale3.Type__c = 'Platinum';
		ticketScale3.Capacity__c = 100;
		ticketScale3.Price__c = 100.00;
		ticketScale3.Kills__c = 0;
		ticketScale3.Comps__c = 10;
		//sellable capacity = capacity - kills - comps = 90
		ticketScale3.ProjectedPaidTickets__c = 100;
		ticketScale3.Event__c = event.Id;
		ticketScale3.LiftBeforeFee__c = 7420.00;
		ticketScale3.TMFeePercent__c = 0.0;
		insert ticketScale3;
	}

	@TestSetup static void setupTestData() {
    	LNE_TestObjectFactory.prepStandardCustomSettings();
    //	LNE_TestObjectFactory.createStandardDataSet();

    	Event__c event = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createEvent()
			).addProperties( new Map<String,Object>{
			    'SelloutDropCount__c' => 2100,
			    'ProjectedDropCount__c' => 1940,
			    'SelloutPaidTickets__c' => 2100,
			    'ProjectedPaidTickets__c' => 2000,
			    'GrossPotential__c' => 217420,
			    'ProjectedGross__c' => 207420,
			    'NetGrossPotential__c' => 95074.68,
			    'ProjectedNetGross__c' => 90729.47,
			    'NumberOfTrucks__c' => 5,
			    'Status__c' => 'Draft',
			    'BookingHouseNut__c' => 5555
			}).buildEvent();
		//insert event;
		 LNE_TestObjectFactory.createStandardDataSet( event );
    }

	@isTest static void testStartSettlement() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupData(tsettings.testEvent);

		Test.startTest();

		LNE_SettlementUtil.startSettlementProcess(tsettings.testEvent.Id);

		Test.stopTest();

		Event__c finalEvent = [SELECT SettlementStarted__c, SettlementHouseNut__c FROM Event__c WHERE Id = :tsettings.testEvent.Id];
		system.assertEquals(true, finalEvent.SettlementStarted__c);
		system.assertEquals(5555, finalEvent.SettlementHouseNut__c);
		List<Deduction__c> settlementDeductions = [SELECT Id FROM Deduction__c WHERE StageType__c = 'Settlement' AND Event__c = :tsettings.testEvent.Id];
		system.assertEquals(1, settlementDeductions.size());
	}

	@isTest static void testReStartSettlement() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupData(tsettings.testEvent);
		Id eventId = tsettings.testEvent.Id;

		Test.startTest();

		LNE_SettlementUtil.startSettlementProcess(eventId);

		Event__c finalEvent = [SELECT SettlementStarted__c, SettlementHouseNut__c FROM Event__c WHERE Id = :eventId];
		system.assertEquals(true, finalEvent.SettlementStarted__c);
		system.assertEquals(5555, finalEvent.SettlementHouseNut__c);
		List<Deduction__c> settlementDeductions = [SELECT Id FROM Deduction__c WHERE StageType__c = 'Settlement' AND Event__c = :eventId];
		system.assertEquals(1, settlementDeductions.size());

		

		system.debug(LoggingLevel.INFO, 'BEFORE RESTART');
		LNE_SettlementUtil.restartSettlement(eventId);
		system.debug(LoggingLevel.INFO, 'AFTER RESTART');

		Test.stopTest();

		settlementDeductions = [SELECT BeforeAfter__c, RateType__c, AmountRate__c FROM Deduction__c WHERE StageType__c = 'Settlement' AND Event__c = :eventId];

		//Make sure there is still just one deduction. The initial settlement one was deleted, and 
		//the one in Projection stage was cloned into Settlement
		system.assertEquals(1, settlementDeductions.size());

		List<String> fieldsToErase = LNE_SettlementUtil.ledgerFieldsToErase;

		String query = 'SELECT ';
		query += String.join(fieldsToErase, ',');
		query += ' FROM LedgerEntry__c WHERE Event__c = :eventId';

		List<LedgerEntry__c> ledgers = Database.query(query);

		for (sObject so : ledgers) {
			for (String fieldName : fieldsToErase) {
				system.assertEquals(null, so.get(fieldName));
			}
		}
	}
}