@isTest
private with sharing class LNE_FinancialCalculator_Test {
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
			Event__c e = [SELECT Id FROM Event__c LIMIT 1];
			testEvent = e;
		}
		
		public void finalize(){
		}
	}

    @testSetup
    static void setup(){
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
			    'Status__c' => 'Draft'
			}).buildEvent();

        LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet(event);
    }

	static void setupGLAccounts() {
		GLAccount__c groupGL = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Group', 'Group')).buildGLAccount();

		//insert new List<GLAccount__c>{revGL,lawnGL,groupGL};
		insert new List<GLAccount__c>{groupGL};
	}

	static void setupData(Event__c event) {

		LNE_FinancialCalculator.runUpdates = true;
		
		Deal__c deal = [select id from Deal__c where Type__c = 'Primary Headliner'];

		BonusDetail__c bonus = new BonusDetail__c();
		bonus.Deal__c = deal.Id;
		bonus.BonusBase__c = 'Paid Tickets';
		bonus.StartPoint__c = 1000;
		bonus.Increment__c = 10;
		bonus.BonusAmount__c = 100;
		insert bonus;
		System.assertNotEquals(null, bonus.id);
		
		EventDateTime__c evtDateTime = new EventDateTime__c(
            event__c = event.Id, 
            EventYear__c = String.valueOf(System.now().year() + 2));
        insert evtDateTime;

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
		ticketScale.StageType__c = 'Plan';

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
		ticketScale2.StageType__c = 'Plan';

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
		ticketScale3.StageType__c = 'Plan';

		insert new List<TicketScale__c>{ticketScale,ticketScale2,ticketScale3};

		LNE_FinancialCalculator.runUpdates = true;

		Deduction__c deduction = new Deduction__c();
		deduction.BeforeAfter__c = 'Before Adjusted';
		deduction.Event__c = event.Id;
		deduction.RateType__c = 'Primary Multiplier Tax';
		deduction.AmountRate__c = 10;

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

	@isTest static void testFinancialCalculator() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupGLAccounts();

		Test.startTest();

		setupData(tsettings.testEvent);

		Event__c testEvent = [SELECT NetPotPotential__c,
									 ProjectedNetPot__c,
									 SelloutGrossSales__c,
									 PlatinumLift__c,
									 SelloutGrossLift__c,
									 ProjectedGross__c,
									 ProjectedGrossLift__c,
									 AdjustedGrossPotential__c,
									 ProjectedAdjustedGross__c,
									 ProjectedDropCount__c,
									 NetGrossPotential__c,
									 ProjectedNetGross__c,
									 DropCountAdjustment__c,
									 StatusStage__c,
									 ShowCount__c,
									 GrossPotential__c
							   FROM Event__c LIMIT 1];
		
		system.assertEquals(117376.15, testEvent.AdjustedGrossPotential__c.setScale(2, RoundingMode.HALF_UP));
		system.assertEquals(112011.69, testEvent.ProjectedAdjustedGross__c.setScale(2, RoundingMode.HALF_UP));
		system.assertEquals(53703.61, testEvent.NetGrossPotential__c.setScale(2, RoundingMode.HALF_UP));
		system.assertEquals(51289.43, testEvent.ProjectedNetGross__c.setScale(2, RoundingMode.HALF_UP));
		system.assertEquals(53703.61, testEvent.NetPotPotential__c.setScale(2, RoundingMode.HALF_UP));
		system.assertEquals(51289.43, testEvent.ProjectedNetPot__c.setScale(2, RoundingMode.HALF_UP));

		List<TicketScale__c> scales = [SELECT Type__c, AfterAdjustedDeductions__c, PlatinumAfterAdjusted_Deductions__c, BeforeAdjustedDeductions__c, PlatinumBeforeAdjustedDeductions__c FROM TicketScale__c];

		for (TicketScale__c ts : scales) {
			if (ts.Type__c == 'Reserved') {
				system.assertEquals(44037.60, ts.BeforeAdjustedDeductions__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(28027.57, ts.AfterAdjustedDeductions__c.setScale(2, RoundingMode.HALF_UP));
			}

			if (ts.Type__c == 'Lawn') {
				system.assertEquals(44037.60, ts.BeforeAdjustedDeductions__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(28027.57, ts.AfterAdjustedDeductions__c.setScale(2, RoundingMode.HALF_UP));
			}

			if (ts.Type__c == 'Platinum') {
				system.assertEquals(4635.54, ts.BeforeAdjustedDeductions__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(2697.57, ts.PlatinumBeforeAdjustedDeductions__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(2950.27, ts.AfterAdjustedDeductions__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(1716.86, ts.PlatinumAfterAdjusted_Deductions__c.setScale(2, RoundingMode.HALF_UP));
			}
		}

		List<Deduction__c> beforeDeductions = [SELECT RateType__c, BeforeAfter__c, DeductionAtSellout__c, DeductionAtProjection__c FROM Deduction__c WHERE BeforeAfter__c = 'Before Adjusted'];

		for (Deduction__c d : beforeDeductions) {
			if (d.RateType__c == 'Primary Multiplier Tax') {
				system.assertEquals(21742.00, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(20742.00, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
			}

			if (d.RateType__c == 'Primary Divider Tax') {
				system.assertEquals(19765.45, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(18856.36, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
			}

			if (d.RateType__c == 'Amount Per Ticket') {
				system.assertEquals(21000.00, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(20000.00, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
			}

			if (d.RateType__c == 'Secondary Multiplier Tax') {
				system.assertEquals(19567.80, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(18667.80, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
			}

			if (d.RateType__c == 'Secondary Divider Tax') {
				system.assertEquals(17968.60, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
				system.assertEquals(17142.15, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
			}
		}

		List<Deduction__c> afterDeductions = [SELECT RateType__c, BeforeAfter__c, DeductionAtSellout__c, DeductionAtProjection__c FROM Deduction__c WHERE BeforeAfter__c = 'After Adjusted'];

		for (Deduction__c d : afterDeductions) {
			if (d.BeforeAfter__c == 'After Adjusted') {
				if (d.RateType__c == 'Primary Multiplier Tax') {
					system.assertEquals(11737.62, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
					system.assertEquals(11201.17, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
				}

				if (d.RateType__c == 'Secondary Multiplier Tax') {
					system.assertEquals(10563.85, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
					system.assertEquals(10081.05, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
				}

				if (d.RateType__c == 'Amount Per Ticket') {
					system.assertEquals(21000.00, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
					system.assertEquals(20000.00, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
				}

				if (d.RateType__c == 'Primary Divider Tax') {
					system.assertEquals(10670.56, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
					system.assertEquals(10182.88, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
				}

				if (d.RateType__c == 'Secondary Divider Tax') {
					system.assertEquals(9700.51, d.DeductionAtSellout__c.setScale(2, RoundingMode.HALF_UP));
					system.assertEquals(9257.16, d.DeductionAtProjection__c.setScale(2, RoundingMode.HALF_UP));
				}
			}
		}

		List<LedgerEntry__c> ledgers = [SELECT RecordTypeId, GLAccount__r.GLCode__c, PlanAmount__c, ProjectionAmount__c FROM LedgerEntry__c WHERE Event__c = :testEvent.Id];

		for(LedgerEntry__c l : ledgers) {
			system.assertEquals(RT_TICKET_REVENUE_ID, l.RecordTypeId);

			if (l.GLAccount__r.GLCode__c == '40100') {
				system.assertEquals(25349.02, l.PlanAmount__c.setScale(2, RoundingMode.HALF_UP));
			}

			if (l.GLAccount__r.GLCode__c == '40116') {
				system.assertEquals(22934.83, l.PlanAmount__c.setScale(2, RoundingMode.HALF_UP));
			}

			if (l.GLAccount__r.GLCode__c == '40102') {
				system.assertEquals(3005.57, l.PlanAmount__c.setScale(2, RoundingMode.HALF_UP));
			}
		}

		List<BonusDetail__c> bonuses = [SELECT BonusPotentialatProjection__c,
											   BonusPotentialatSellout__c,
											   BonusPotentialatProjectionRetro__c,
											   BonusPotentialatProjectionStepUp__c
										FROM BonusDetail__c];
		system.assert(bonuses.size() > 0);
		system.assertEquals(0.0, bonuses[0].BonusPotentialatSellout__c);

		Test.stopTest();
	}

	@isTest static void testFinancialCalculator_FlatRate() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupGLAccounts();
		
		EventDateTime__c evtDateTime = new EventDateTime__c(
            event__c = tsettings.testEvent.Id, 
            EventYear__c = String.valueOf(System.now().year() + 2));
        insert evtDateTime;
		
		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Reserved';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 0;
		ticketScale.ProjectedPaidTickets__c = 950;
		ticketScale.Event__c = tsettings.testEvent.Id;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		ticketScale.StageType__c = 'Plan';
		insert ticketScale;

		Deduction__c deduction = new Deduction__c();
		deduction.BeforeAfter__c = 'Before Adjusted';
		deduction.Event__c = tsettings.testEvent.Id;
		deduction.RateType__c = 'Flat';
		deduction.AmountRate__c = 10;
		deduction.StageType__c = 'Plan';

		insert deduction;

		Test.startTest();

		Event__c testEvent = [SELECT AdjustedGrossPotential__c, ProjectedAdjustedGross__c FROM Event__c LIMIT 1];
		system.assertEquals(99990, testEvent.AdjustedGrossPotential__c.setScale(2, RoundingMode.HALF_UP));
		system.assertEquals(94990, testEvent.ProjectedAdjustedGross__c.setScale(2, RoundingMode.HALF_UP));

		Test.stopTest();
	}

	@isTest static void testFinancialCalculator_FlatRate_Update() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupGLAccounts();
		
		EventDateTime__c evtDateTime = new EventDateTime__c(
            event__c = tsettings.testEvent.Id, 
            EventYear__c = String.valueOf(System.now().year() + 2));
        insert evtDateTime;

		LNE_FinancialCalculator.runUpdates = true;
		
		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Reserved';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 0;
		ticketScale.ProjectedPaidTickets__c = 950;
		ticketScale.Event__c = tsettings.testEvent.Id;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		insert ticketScale;

		Deduction__c deduction = new Deduction__c();
		deduction.BeforeAfter__c = 'Before Adjusted';
		deduction.Event__c = tsettings.testEvent.Id;
		deduction.RateType__c = 'Flat';
		deduction.AmountRate__c = 11;

		insert deduction;

		LNE_FinancialCalculator.runUpdates = true;

		deduction.AmountRate__c = 10;
		update deduction;

		Test.startTest();

		Event__c testEvent = [SELECT AdjustedGrossPotential__c, ProjectedAdjustedGross__c FROM Event__c LIMIT 1];
		system.assertEquals(99990, testEvent.AdjustedGrossPotential__c.setScale(2, RoundingMode.HALF_UP));
		system.assertEquals(94990, testEvent.ProjectedAdjustedGross__c.setScale(2, RoundingMode.HALF_UP));

		Test.stopTest();
	}

	@isTest static void testFinancialCalculator_DropCountComps() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupGLAccounts();

		LNE_FinancialCalculator.currentlyRunning = true;
		Event__c event = tsettings.testEvent;
		event.SelloutDropCount__c = 0;
		event.ProjectedDropCount__c = 0;
		event.ProjectedDropCountPct__c = 0;
		event.DropCountAdjustment__c = 0;
		update event;
		
		EventDateTime__c evtDateTime = new EventDateTime__c(
            event__c = event.Id, 
            EventYear__c = String.valueOf(System.now().year() + 2));
        insert evtDateTime;
        
		LNE_FinancialCalculator.currentlyRunning = false;
		

		LNE_FinancialCalculator.runUpdates = true;
		
		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Reserved';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 100;
		ticketScale.ProjectedPaidTickets__c = 700;
		ticketScale.Event__c = event.Id;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		//sellable capacity = capacity - kills - comps (1000 - 0 - 100 = 900)
		//gross sales = sellable capacity * price (900*100.00 = 90000.00)
		// insert ticketScale;

		TicketScale__c ticketScale2 = new TicketScale__c();
		ticketScale2.Type__c = 'Lawn';
		ticketScale2.Capacity__c = 1000;
		ticketScale2.Price__c = 100.00;
		ticketScale2.Kills__c = 0;
		ticketScale2.Comps__c = 100;
		ticketScale2.ProjectedPaidTickets__c = 700;
		ticketScale2.Event__c = event.Id;
		ticketScale2.LiftBeforeFee__c = 0;
		ticketScale2.TMFeePercent__c = 0.0;
		//sellable capacity = capacity - kills - comps (1000 - 0 - 100 = 900)
		//gross sales = sellable capacity * price (900*100.00 = 90000.00)

		TicketScale__c ticketScale3 = new TicketScale__c();
		ticketScale3.Type__c = 'Platinum';
		ticketScale3.Capacity__c = 100;
		ticketScale3.Price__c = 100.00;
		ticketScale3.Kills__c = 0;
		ticketScale3.Comps__c = 0;
		ticketScale3.ProjectedPaidTickets__c = 100;
		ticketScale3.Event__c = event.Id;
		ticketScale3.AverageLiftPerTicket__c = 100.00;
		ticketScale3.LiftBeforeFee__c = 10000.00;
		ticketScale3.TMFeePercent__c = 0.0;
		//sellable capacity = capacity - kills - comps (100 - 0 - 0 = 100)
		//gross sales = sellable capacity * price (100*100.00 = 10000.00)

		insert new List<TicketScale__c>{ticketScale,ticketScale2,ticketScale3};

		LNE_FinancialCalculator.runUpdates = true;
		
		event.ProjectedDropCountPct__c = 100;
		event.DropCountAdjustment__c = 2;
		update event;
		
		Test.startTest();
	
		Event__c testEvent = [SELECT ProjectedDropCount__c, SelloutDropCount__c, SelloutGrossSales__c, PlatinumLift__c, GrossPotential__c, 
		    ProjectedGrossSales__c, ProjectedGross__c, ProjectedAverageTicketPrice__c, SelloutAverageTicketPrice__c, SelloutPaidTickets__c, ProjectedPaidTickets__c  FROM Event__c where Id =:event.Id LIMIT 1];

        //US109
        // SelloutDropCount__c = event.sumSelloutTickets + event.sumComps;
        system.assertEquals(2100,testEvent.SelloutDropCount__c); 
        // ProjectedDropCount__c = (event.eventRecord.ProjectedDropCountPct__c * .01) * (event.sumProjectedTickets + event.sumComps) + event.eventRecord.DropCountAdjustment__c;
		system.assertEquals(1702,testEvent.ProjectedDropCount__c); 
		
		//US450
		//SelloutGrossSales__c = sum(TicketScale.GrossSales__c)
		system.assertEquals(190000.00, testEvent.SelloutGrossSales__c.setScale(2, RoundingMode.HALF_UP));
        system.assertEquals(10000.00, testEvent.PlatinumLift__c.setScale(2, RoundingMode.HALF_UP));
        system.assertEquals(200000.00, testEvent.GrossPotential__c.setScale(2, RoundingMode.HALF_UP));
        system.assertEquals(150000.00, testEvent.ProjectedGrossSales__c.setScale(2, RoundingMode.HALF_UP));
        system.assertEquals(160000.00, testEvent.ProjectedGross__c.setScale(2, RoundingMode.HALF_UP));
        
        //US489
        system.assertEquals(1500, testEvent.ProjectedPaidTickets__c.setScale(2, RoundingMode.HALF_UP));
        system.assertEquals(1900, testEvent.SelloutPaidTickets__c.setScale(2, RoundingMode.HALF_UP));
        system.assertEquals(100.00, testEvent.ProjectedAverageTicketPrice__c.setScale(2, RoundingMode.HALF_UP));
        system.assertEquals(100.00, testEvent.SelloutAverageTicketPrice__c.setScale(2, RoundingMode.HALF_UP));

		Test.stopTest();
	}

	static testMethod void testBypassAutomation(){
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		GeneralSettings__c gs = [SELECT BypassAutomation__c FROM GeneralSettings__c];
		gs.BypassAutomation__c = true;
		update gs;

		setupGLAccounts();
		setupData(ts.testEvent);

		List<LedgerEntry__c> ledgers = [SELECT Id FROM LedgerEntry__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, ledgers.size());
	}

	static testMethod void testDeletes1(){ // delete scales
	    system.debug('TEST1');
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

        system.debug('TEST2');
		setupGLAccounts();
		Test.startTest();	
		system.debug('TEST3');
		setupData(ts.testEvent);
        
        	
			system.debug('TEST4');
        
		List<TicketScale__c> scales = [SELECT Id FROM TicketScale__c];
	    system.assert(scales.size() > 0);

		scales[0].Price__c = 123.0;
		update scales[0];
		system.debug('TEST5');

		TicketScale__c t = [SELECT Price__c FROM TicketScale__c WHERE Id = :scales[0].Id];
		system.assertEquals(123.0, t.Price__c);

		GeneralSettings__c gs = [SELECT GlobalDataAdministrator__c FROM GeneralSettings__c];
		gs.GlobalDataAdministrator__c = true;
		gs.BypassAutomation__c = false;
		update gs;
        		system.debug('TEST6');

        Test.stopTest();
        
        //ledgers = [SELECT Id FROM LedgerEntry__c WHERE Event__c = :ts.testEvent.Id];
                		
		
        system.debug('John delete scales');
		delete scales;
		


		//LNE_FinancialCalculator.runUpdates = false;
		//LNE_FinancialCalculator.pushRunningTrigger('testDeletes');
		//system.debug('delete ledgers');
		//delete ledgers;
		
		

		scales = [SELECT Id FROM TicketScale__c];
		system.assertEquals(0 ,scales.size());
	}
	
	static testMethod void testDeletes2(){ // delete ledgers
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		setupGLAccounts();

		Test.startTest();

		setupData(ts.testEvent);
        
		LedgerEntry__c testLE = new LedgerEntry__c();
		
		system.assertNotEquals(null, ts.testEvent.Id);
		testLE.Event__c = ts.testEvent.Id;
		testLE.GLAccount__c = [SELECT Id FROM GLAccount__c LIMIT 1].Id;
		testLE.RecordTypeId = RT_EXPENSES_ID;
		insert testLE;
		
		system.assertNotEquals(null, testLE.id);

		List<LedgerEntry__c> ledgers = [SELECT Id FROM LedgerEntry__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(3, ledgers.size());
		ledgers = [SELECT Id FROM LedgerEntry__c WHERE Event__c = :ts.testEvent.Id];
		system.debug('delete ledgers');
		delete ledgers;

        Test.stopTest();
	}
	
	static testMethod void testDeletes3(){ // delete deductions
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		setupGLAccounts();

		Test.startTest();
		setupData(ts.testEvent);
		
		List<Deduction__c> deductions = [SELECT Id FROM Deduction__c];
		system.assert(deductions.size() > 0);
		delete deductions;
		
		
		deductions = [SELECT Id FROM Deduction__c];
		system.assertEquals(0, deductions.size());
		Test.stopTest();
	}
	
	static testMethod void testDeletes4(){ // delete deals
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		setupGLAccounts();

		Test.startTest();
		setupData(ts.testEvent);
		
		GeneralSettings__c gs = [SELECT GlobalDataAdministrator__c FROM GeneralSettings__c];
		gs.GlobalDataAdministrator__c = true;
		gs.BypassAutomation__c = false;
		update gs;

		List<Deal__c> deals = [SELECT Id FROM Deal__c];
		system.assert(deals.size() > 0);
		delete deals;
		
		
		deals = [SELECT Id FROM Deal__c];
		system.assertEquals(0, deals.size());
		Test.stopTest();
	}
	
	@isTest static void testFinancialCalculator_SettlementMetrics() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupGLAccounts();
		
		LNE_FinancialCalculator.currentlyRunning = true;
		Event__c event = tsettings.testEvent;
		event.SettlementStarted__c = true;
		update event;
		LNE_FinancialCalculator.currentlyRunning = false;

		LNE_FinancialCalculator.runUpdates = true;
		
		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Reserved';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 100;
		ticketScale.ActualSalesToDate__c = 700;
		ticketScale.ActualGrossToDate__c = 100;
		ticketScale.Event__c = event.Id;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		ticketScale.StageType__c = 'Settlement';

		TicketScale__c ticketScale2 = new TicketScale__c();
		ticketScale2.Type__c = 'Lawn';
		ticketScale2.Capacity__c = 1000;
		ticketScale2.Price__c = 100.00;
		ticketScale2.Kills__c = 0;
		ticketScale2.Comps__c = 100;
		ticketScale2.ActualSalesToDate__c = 700;
		ticketScale2.ActualGrossToDate__c = 200;
		ticketScale2.Event__c = event.Id;
		ticketScale2.LiftBeforeFee__c = 0;
		ticketScale2.TMFeePercent__c = 0.0;
		ticketScale2.StageType__c = 'Settlement';

		TicketScale__c ticketScale3 = new TicketScale__c();
		ticketScale3.Type__c = 'Platinum';
		ticketScale3.Capacity__c = 100;
		ticketScale3.Price__c = 100.00;
		ticketScale3.Kills__c = 0;
		ticketScale3.Comps__c = 0;
		ticketScale3.ActualSalesToDate__c = 100;
		ticketScale3.ActualGrossToDate__c = 300;
		ticketScale3.Event__c = event.Id;
		ticketScale3.AverageLiftPerTicket__c = 100.00;
		ticketScale3.LiftBeforeFee__c = 10000.00;
		ticketScale3.TMFeePercent__c = 0.0;
		ticketScale3.StageType__c = 'Settlement';

		insert new List<TicketScale__c>{ticketScale,ticketScale2,ticketScale3};

		LNE_FinancialCalculator.runUpdates = true;
		
		Test.startTest();
	
		Event__c testEvent = [SELECT SettlementPaidTickets__c, SettlementGrossSales__c, SettlementPlatinumLift__c, SettlementNetGross__c  FROM Event__c where Id =:event.Id LIMIT 1];

        system.assertEquals(1500,testEvent.SettlementPaidTickets__c);
        system.assertEquals(600,testEvent.SettlementGrossSales__c);
        system.assertEquals(10000,testEvent.SettlementPlatinumLift__c);
        system.assertEquals(10600,testEvent.SettlementNetGross__c);

		Test.stopTest();
	}
}