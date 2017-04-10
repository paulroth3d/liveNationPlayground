@isTest
private class LNE_EventDeletionUtil_Test {
	final static Id RT_EVENT_HOLD_ID;

	static {

		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 
			'Event__c.Hold'
		});

		RT_EVENT_HOLD_ID = recordTypeMap.get('Event__c.Hold');
	}

	@testSetup
	static void setup(){
		LNE_FinancialCalculator.currentlyRunning = true;

		LNE_TestObjectFactory.prepStandardCustomSettings();

		Event__c event = new Event__c(
	        RecordTypeId = RT_EVENT_HOLD_ID
	    );

		LNE_TestObjectFactory.createStandardDataSet(event);
	}

	class TestSettings {
		public Event__c testEvent;
		
		public TestSettings() {
			LNE_FinancialCalculator.currentlyRunning = true;
			testEvent = [SELECT Id FROM Event__c LIMIT 1];
		}
		
		public TestSettings typicalSetup(){
			return this;
			
		}
		
		public TestSettings finalize(){
			LNE_FinancialCalculator.currentlyRunning = false;
			return this;
		}
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

	static testMethod void testDeletion() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();

		Test.startTest();
		setupData(ts.testEvent);

		List<Event__c> events = [SELECT Id FROM Event__c WHERE Id = :ts.testEvent.Id];
		system.assertEquals(1, events.size());

		List<EventDateTime__c> datetimes = [SELECT Id FROM EventDateTime__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(1, datetimes.size());

		List<Deduction__c> deductions = [SELECT Id FROM Deduction__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(10, deductions.size());

		List<TicketScale__c> ticketScales = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(3, ticketScales.size());

		LNE_EventDeletionUtil.deleteEvents(events);

		events = [SELECT Id FROM Event__c WHERE Id = :ts.testEvent.Id];
		system.assertEquals(0, events.size());

		datetimes = [SELECT Id FROM EventDateTime__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, datetimes.size());

		deductions = [SELECT Id FROM Deduction__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, deductions.size());

		ticketScales = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, ticketScales.size());
	}

	static testMethod void testDeletion_Aura() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();

		Test.startTest();
		setupData(ts.testEvent);

		List<Event__c> events = [SELECT Id FROM Event__c WHERE Id = :ts.testEvent.Id];
		system.assertEquals(1, events.size());

		List<EventDateTime__c> datetimes = [SELECT Id FROM EventDateTime__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(1, datetimes.size());

		List<Deduction__c> deductions = [SELECT Id FROM Deduction__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(10, deductions.size());

		List<TicketScale__c> ticketScales = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(3, ticketScales.size());

		LNE_EventDeletionUtil.deleteHoldEvent(ts.testEvent.Id);

		events = [SELECT Id FROM Event__c WHERE Id = :ts.testEvent.Id];
		system.assertEquals(0, events.size());

		datetimes = [SELECT Id FROM EventDateTime__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, datetimes.size());

		deductions = [SELECT Id FROM Deduction__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, deductions.size());

		ticketScales = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, ticketScales.size());
	}

	static testMethod void testDeletion_Trigger() {
		TestSettings ts = new TestSettings().typicalSetup().finalize();

		Test.startTest();
		setupData(ts.testEvent);

		List<Event__c> events = [SELECT Id FROM Event__c WHERE Id = :ts.testEvent.Id];
		system.assertEquals(1, events.size());

		List<EventDateTime__c> datetimes = [SELECT Id FROM EventDateTime__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(1, datetimes.size());

		List<Deduction__c> deductions = [SELECT Id FROM Deduction__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(10, deductions.size());

		List<TicketScale__c> ticketScales = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(3, ticketScales.size());

		delete datetimes;

		events = [SELECT Id FROM Event__c WHERE Id = :ts.testEvent.Id];
		system.assertEquals(0, events.size());

		datetimes = [SELECT Id FROM EventDateTime__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, datetimes.size());

		deductions = [SELECT Id FROM Deduction__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, deductions.size());

		ticketScales = [SELECT Id FROM TicketScale__c WHERE Event__c = :ts.testEvent.Id];
		system.assertEquals(0, ticketScales.size());
	}
}
