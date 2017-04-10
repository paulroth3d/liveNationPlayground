@isTest
private with sharing class LNE_PlatinumLiftCalculatorAPI_CX_Test {

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
	class TestSettings {
		public Event__c testEvent;
		
		public TestSettings() {
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
		}
		
		public void typicalSetup(){
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
			    'NumberOfTrucks__c' => 5
			}).buildEvent();
			
			LNE_TestObjectFactory.createStandardDataSet( event );

			testEvent = event;
		}
		
		public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
		}
	}
	

	static void setupGLAccounts() {
		/*
		GLAccount__c revGL = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Ticket Revenue', '40100')).buildGLAccount();
		GLAccount__c lawnGL = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Lawn', '40116')).buildGLAccount();
		GLAccount__c groupGL = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Group', 'Group')).buildGLAccount();

		insert new List<GLAccount__c>{revGL,lawnGL,groupGL};
		*/
		GLAccount__c groupGL = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Group', 'Group')).buildGLAccount();
		insert groupGL;
	}

	static void setupData(Event__c event) {

		LNE_FinancialCalculator.runUpdates = true;

		TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Platinum';
		ticketScale.Capacity__c = 100;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 0;
		ticketScale.ProjectedPaidTickets__c = 100;
		ticketScale.Event__c = event.Id;
		ticketScale.LiftBeforeFee__c = 7420.00;
		ticketScale.TMFeePercent__c = 0.0;
		ticketScale.StageType__c = 'Projection';

		insert new List<TicketScale__c>{ticketScale};
	}

	@isTest static void testPlatinumLiftCalculator() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupGLAccounts();
		setupData(tsettings.testEvent);

		TicketScale__c testTS = [SELECT LiftBeforeFee__c, ProjectedPaidTickets__c, AverageLiftPerTicket__c FROM TicketScale__c WHERE Type__c = 'Platinum'];

		Test.startTest();

		PageReference pageRef = Page.LNE_PlatinumLiftCalculatorAPI;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('callback', 'test');
		ApexPages.currentPage().getParameters().put('TicketScale__c', JSON.serialize(testTS));

		LNE_PlatinumLiftCalculatorAPI_CX controller = new LNE_PlatinumLiftCalculatorAPI_CX();
		system.debug('**** CALLING processRequest');
		controller.processRequest();

		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(controller.jsonResponse);

		system.assert(String.valueOf(m.get('data')).contains('AverageLiftPerTicket__c=74.2'));  

		Test.stopTest();
	}

	@isTest static void testPlatinumLiftCalculator_Error() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupGLAccounts();
		setupData(tsettings.testEvent);

		TicketScale__c testTS = new TicketScale__c();

		Test.startTest();

		PageReference pageRef = Page.LNE_PlatinumLiftCalculatorAPI;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('callback', 'test');
		ApexPages.currentPage().getParameters().put('TicketScale__c', JSON.serialize(testTS));

		LNE_PlatinumLiftCalculatorAPI_CX controller = new LNE_PlatinumLiftCalculatorAPI_CX();
		controller.processRequest();

		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(controller.jsonResponse);
		system.assert(String.valueOf(m.get('message')).contains('List has no rows for assignment to SObject'));  

		Test.stopTest();
	}

	@isTest static void testPlatinumLiftCalculator_LiftBeforeFee() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();
		setupGLAccounts();
		setupData(tsettings.testEvent);

		TicketScale__c testTS = [SELECT LiftBeforeFee__c, ProjectedPaidTickets__c, AverageLiftPerTicket__c FROM TicketScale__c WHERE Type__c = 'Platinum'];
		testTS.AverageLiftPerTicket__c = 74.20;
		testTS.LiftBeforeFee__c = null;
		update testTS;

		Test.startTest();

		PageReference pageRef = Page.LNE_PlatinumLiftCalculatorAPI;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('callback', 'test');
		ApexPages.currentPage().getParameters().put('TicketScale__c', JSON.serialize(testTS));

		LNE_PlatinumLiftCalculatorAPI_CX controller = new LNE_PlatinumLiftCalculatorAPI_CX();
		system.debug('**** CALLING processRequest');
		controller.processRequest();

		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(controller.jsonResponse);

		system.assert(String.valueOf(m.get('data')).contains('LiftBeforeFee__c=7420'));  

		Test.stopTest();
	}

}