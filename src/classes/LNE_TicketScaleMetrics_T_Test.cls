@isTest
private class LNE_TicketScaleMetrics_T_Test {
	@testSetup
	static void setup(){
		LNE_TestObjectFactory.prepStandardCustomSettings();
		LNE_TestObjectFactory.createStandardDataSet();
	}

	class TestSettings {
		Event__c event;
		DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
		
		public TestSettings() {
			//-- global setup here
			
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_EventDateTimeUtil_T_Test' );
			LNE_GeneralSettingsUtil.setLocalBypassSettings(false, true, false);

			event = [SELECT Id FROM Event__c];

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

			insert ticketScale;
		}
		
		public void typicalSetup(){
			
		}
		
		public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
		}
	}

	static testMethod void testFieldPopulation() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		Test.startTest();

		EventDateTime__c eventDateTime = new EventDateTime__c(
            	Event__c = ts.event.Id, 
            	EventYear__c = String.valueOf(System.now().year() + 2),
            	EventDate__c = System.today().addDays(12),
            	StartTime__c = '9:00 PM');
        insert eventDateTime;

		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Reserved';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 0;
		ticketScale.ProjectedPaidTickets__c = 950;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		ticketScale.StageType__c = 'Plan';
		ticketScale.EventIDStageType__c = ts.event.Id + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + 'Plan';
		ticketScale.EventIDStageTypeDateTime__c = ts.event.Id + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + 'Plan' + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + eventDateTime.Id;

		insert ticketScale;

		ticketScale = [SELECT Event__c, EventDateTime__c FROM TicketScale__c WHERE Id = :ticketScale.Id];
		system.assertEquals(ts.event.Id, ticketScale.Event__c);
		system.assertEquals(eventDateTime.Id, ticketScale.EventDateTime__c);
	}

	static testMethod void testUpdate() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		Test.startTest();

		EventDateTime__c eventDateTime = new EventDateTime__c(
            	Event__c = ts.event.Id, 
            	EventYear__c = String.valueOf(System.now().year() + 2),
            	EventDate__c = System.today().addDays(12),
            	StartTime__c = '9:00 PM');
        insert eventDateTime;

		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Reserved';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 0;
		ticketScale.ProjectedPaidTickets__c = 950;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		ticketScale.StageType__c = 'Plan';
		ticketScale.EventIDStageType__c = ts.event.Id + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + 'Plan';
		ticketScale.EventIDStageTypeDateTime__c = ts.event.Id + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + 'Plan' + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + eventDateTime.Id;

		insert ticketScale;

		ticketScale.StageType__c = 'Projection';
		update ticketScale;

		ticketScale = [SELECT EventIDStageType__c FROM TicketScale__c WHERE Id = :ticketScale.Id];
		system.assertEquals(((String)ts.event.Id).substring(0,15) + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + 'Projection', ticketScale.EventIDStageType__c);
	}

	static testMethod void testDelete() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		Test.startTest();

		EventDateTime__c eventDateTime = new EventDateTime__c(
            	Event__c = ts.event.Id, 
            	EventYear__c = String.valueOf(System.now().year() + 2),
            	EventDate__c = System.today().addDays(12),
            	StartTime__c = '9:00 PM');
        insert eventDateTime;

		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Reserved';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 0;
		ticketScale.ProjectedPaidTickets__c = 950;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		ticketScale.StageType__c = 'Plan';
		ticketScale.EventIDStageType__c = ts.event.Id + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + 'Plan';
		ticketScale.EventIDStageTypeDateTime__c = ts.event.Id + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + 'Plan' + ts.DATA_SETTINGS.CombinedKeyDelimiter__c + eventDateTime.Id;

		insert ticketScale;

		List<TicketScale__c> tList = [SELECT Id FROM TicketScale__c WHERE Id = :ticketScale.Id];
		system.assertEquals(1, tList.size());

		delete ticketScale;

		tList = [SELECT Id FROM TicketScale__c WHERE Id = :ticketScale.Id];
		system.assertEquals(0, tList.size());
	}
}