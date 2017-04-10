@isTest
private class LNE_EventDateTimeUtil_T_Test {
	@testSetup
	static void setup(){
		LNE_TestObjectFactory.prepStandardCustomSettings();
		LNE_TestObjectFactory.createStandardDataSet();
	}

	class TestSettings {
		Event__c event;
		EventDateTime__c eventDateTime;
		DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
		
		public TestSettings() {
			//-- global setup here
			
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_EventDateTimeUtil_T_Test' );
			LNE_GeneralSettingsUtil.setLocalBypassSettings(false, true, false);

			event = [SELECT Id FROM Event__c];
			event.UsingMultiScale__c = true;
			update event;

			eventDateTime = new EventDateTime__c(
            	Event__c = event.Id, 
            	EventYear__c = String.valueOf(System.now().year() + 2),
            	EventDate__c = System.today().addDays(10),
            	StartTime__c = '6:00 PM');

			EventDateTime__c eventDateTime2 = new EventDateTime__c(
            	Event__c = event.Id, 
            	EventYear__c = String.valueOf(System.now().year() + 2),
            	EventDate__c = System.today().addDays(11),
            	StartTime__c = '8:00 PM');

        	insert new List<EventDateTime__c>{eventDateTime,eventDateTime2};

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
			ticketScale.EventDateTime__c = eventDateTime.Id;

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
			ticketScale2.EventDateTime__c = eventDateTime.Id;

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
			ticketScale3.EventDateTime__c = eventDateTime.Id;

			insert new List<TicketScale__c>{ticketScale,ticketScale2,ticketScale3};

			String ticketScaleList = ticketScale.Id + DATA_SETTINGS.CombinedKeyDelimiter__c + ticketScale2.Id + DATA_SETTINGS.CombinedKeyDelimiter__c + ticketScale3.Id;

			Deduction__c deduction = new Deduction__c();
			deduction.BeforeAfter__c = 'Before Adjusted';
			deduction.Event__c = event.Id;
			deduction.RateType__c = 'Primary Multiplier Tax';
			deduction.AmountRate__c = 10;
			deduction.TicketScaleList__c = ticketScaleList;

			Deduction__c deduction2 = new Deduction__c();
			deduction2.BeforeAfter__c = 'Before Adjusted';
			deduction2.Event__c = event.Id;
			deduction2.RateType__c = 'Primary Divider Tax';
			deduction2.AmountRate__c = 10;
			deduction2.TicketScaleList__c = ticketScaleList;

			insert new List<Deduction__c>{deduction,deduction2};
		}
		
		public void typicalSetup(){
			
		}
		
		public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
		}
	}

	static testMethod void testCheckForMultiScale() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		Test.startTest();

		List<TicketScale__c> scales = [SELECT EventDateTime__c FROM TicketScale__c WHERE Event__c = :ts.event.Id];
		system.assertEquals(3, scales.size());

		EventDateTime__c eventDateTime = new EventDateTime__c(
            	Event__c = ts.event.Id, 
            	EventYear__c = String.valueOf(System.now().year() + 2),
            	EventDate__c = System.today().addDays(12),
            	StartTime__c = '9:00 PM');
        insert eventDateTime;

        scales = [SELECT EventDateTime__c FROM TicketScale__c WHERE Event__c = :ts.event.Id];
		system.assertEquals(6, scales.size());

		scales = [SELECT EventDateTime__c FROM TicketScale__c WHERE EventDateTime__c = :eventDateTime.Id];
		system.assertEquals(3, scales.size());
	}

	static testMethod void testDelete() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		Test.startTest();

		List<TicketScale__c> scales = [SELECT EventDateTime__c FROM TicketScale__c WHERE Event__c = :ts.event.Id];
		system.assertEquals(3, scales.size());

		EventDateTime__c eventDateTime = new EventDateTime__c(
            	Event__c = ts.event.Id, 
            	EventYear__c = String.valueOf(System.now().year() + 2),
            	EventDate__c = System.today().addDays(12),
            	StartTime__c = '9:00 PM');
        insert eventDateTime;

        scales = [SELECT EventDateTime__c FROM TicketScale__c WHERE Event__c = :ts.event.Id];
		system.assertEquals(6, scales.size());

		delete eventDateTime;

		scales = [SELECT EventDateTime__c FROM TicketScale__c WHERE Event__c = :ts.event.Id];
		system.assertEquals(3, scales.size());

		scales = [SELECT EventDateTime__c FROM TicketScale__c WHERE EventDateTime__c = :eventDateTime.Id];
		system.assertEquals(0, scales.size());
	}
}