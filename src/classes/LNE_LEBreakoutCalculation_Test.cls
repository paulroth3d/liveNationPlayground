/**
* 
*
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
public class LNE_LEBreakoutCalculation_Test {
    public static Event__c testEvent = null;
	
	class TestSettings {
	    
		
		public TestSettings() {
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
		}
		
		
		public List<LedgerEntryBreakout__c> typicalSetup(){
			List<LedgerEntryBreakout__c> savedLedgerEntries = new List<LedgerEntryBreakout__c>();
	  		
	  		//-- @TODO: can we just use the gl accounts from the createStandardDataSets here?
	  		
			GLAccount__c testGlaAcct1 = new GLAccount__c (
				Type__c = 'Ancillary',
				Name = 'Parking Revenue',
				Category__c = 'Other Event Revenue',
				GLCode__c = '12345'
			);
			
			GLAccount__c testGlaAcct2 = new GLAccount__c (
				Type__c = 'Ancillary',
				Name = 'Alcoholic Beverage Revenue',
				Category__c = 'Concession Revenue',
				GLCode__c = '12340'
			);
			
			GLAccount__c testGlaAcct3 = new GLAccount__c (
				Type__c = 'Ancillary',
				Name = 'Non-Alcoholic Beverage Revenue',
				Category__c = 'Other Event Revenue',
				GLCode__c = '12349'
			);
			
			GLAccount__c testGlaAcct4 = new GLAccount__c (
				Type__c = 'Ancillary',
				Name = 'Facility Maintenance Revenue',
				Category__c = 'Other Event Revenue',
				GLCode__c = '12348'
			);
			
			GLAccount__c testGlaAcct5 = new GLAccount__c (
				Type__c = 'Ancillary',
				Name = 'Premier Parking Revenue',
				Category__c = 'Other Event Revenue',
				GLCode__c = '12347'
			);
			
			insert new List<GLAccount__c>{testGlaAcct1,testGlaAcct2,testGlaAcct3,testGlaAcct4,testGlaAcct5};
			
			Event__c Evt1 = new Event__c(
				ProjectedPaidTickets__c = 20000,
				ProjectedDropCount__c = 30000
			);
			
			LNE_TestObjectFactory.createStandardDataSet( Evt1 );
			testEvent = Evt1;
			
			LedgerEntry__c ledgerEntry1 = new LedgerEntry__c(
				GLAccount__c = testGlaAcct1.Id,
				BaseAmount__c = 33343,
				RateType__c = 'Flat', 
				Event__c = Evt1.Id
			);
			
			insert ledgerEntry1;
			System.debug('EVENT ID = ' + Evt1.Id);
			System.debug('LE ID = ' + ledgerEntry1.Id);
			
			LedgerEntryBreakout__c Ledger1 = new LedgerEntryBreakout__c (
				BaseAmount__c = 33343,
				RateType__c = 'Flat', 
				LedgerEntry__c = ledgerEntry1.Id
				
			); 
			
			LedgerEntryBreakout__c Ledger2 = new LedgerEntryBreakout__c (
				BaseAmount__c = 33345,
				RateType__c = 'Flat', 
				LedgerEntry__c = ledgerEntry1.Id

			); 
			
			LedgerEntryBreakout__c Ledger3 = new LedgerEntryBreakout__c (
				BaseAmount__c = 333,
				RateType__c = 'Flat',				  
				LedgerEntry__c = ledgerEntry1.Id

				
			); 
			
			LedgerEntryBreakout__c Ledger4 = new LedgerEntryBreakout__c (
				BaseAmount__c = 333,
				RateType__c = 'Flat', 
				LedgerEntry__c = ledgerEntry1.Id

			); 
			
			LedgerEntryBreakout__c Ledger5 = new LedgerEntryBreakout__c (
				BaseAmount__c = 333,
				RateType__c = 'Flat', 
				LedgerEntry__c = ledgerEntry1.Id

			); 
			
			savedLedgerEntries.add(Ledger1);
			savedLedgerEntries.add(Ledger2);
			savedLedgerEntries.add(Ledger3);
			savedLedgerEntries.add(Ledger4);
			savedLedgerEntries.add(Ledger5);
			insert savedLedgerEntries;
			
			return savedLedgerEntries;
		}
		
		public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
		}
	}
	
	//-- test test methods here

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

	static testMethod void runSetupAWithoutException() {
		try {
			TestSettings ts = new TestSettings();
			ts.typicalSetup();
			ts.finalize();
		} catch( Exception err ){
			System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
		}
	}
	
	//-- test functionality here
	
	static testMethod void testCalculatedFields1() {
		TestSettings ts = new TestSettings();
		List<LedgerEntryBreakout__c> ledgerEntries = ts.typicalSetup();
		
		testEvent.ProjectedPaidTickets__c = 20000;
        testEvent.ProjectedDropCount__c = 30000;
		update testEvent;
		
		ledgerEntries.get(0).BaseAmount__c = 5;
		ledgerEntries.get(0).RateType__c = 'Per Cap';
		ledgerEntries.get(0).Min__c = 180000;
		ledgerEntries.get(0).Max__c = 300000;
		ledgerEntries.get(0).ApplyTicketScale__c = 'All Drop Count';
		ledgerEntries.get(0).ContraPercent__c = 44;
		ledgerEntries.get(0).ContraAmount__c = 0;
		ledgerEntries.get(0).X3rdPartyPercent__c = 0;
		ledgerEntries.get(0).ContraType__c = 'Per Cap';
		
		Test.startTest();
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_LEBreakoutCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(180000, updatedLedgerEntry.GrossRevenue__c);
		System.assertEquals(9, updatedLedgerEntry.GrossPerPaid__c);
		System.assertEquals(79200, updatedLedgerEntry.ContraAtForecast__c);
		System.assertEquals(0.44, updatedLedgerEntry.Contra_At_Forecast__c);
		System.assertEquals(100800, updatedLedgerEntry.Net_Revenue__c);
		System.assertEquals(5.04, updatedLedgerEntry.NetPerPaid__c);
	}
	
	// test min gross revenue
	static testMethod void testCalculatedFields2() {
		TestSettings ts = new TestSettings();
		List<LedgerEntryBreakout__c> ledgerEntries = ts.typicalSetup();
		ledgerEntries.get(0).BaseAmount__c = 1;
		ledgerEntries.get(0).RateType__c = 'Per Cap';
		ledgerEntries.get(0).Min__c = 180000;
		ledgerEntries.get(0).Max__c = 300000;
		ledgerEntries.get(0).ApplyTicketScale__c = 'All Drop Count';
		ledgerEntries.get(0).ContraPercent__c = 44;
		ledgerEntries.get(0).ContraAmount__c = 0;
		ledgerEntries.get(0).X3rdPartyPercent__c = 0;
		ledgerEntries.get(0).ContraType__c = 'Per Cap';
		
		Test.startTest();
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_LEBreakoutCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(180000, ledgerEntries.get(0).GrossRevenue__c);
		
	}
	
	// test All Paid Tickets
	static testMethod void testCalculatedFields3() {
		TestSettings ts = new TestSettings();
		List<LedgerEntryBreakout__c> ledgerEntries = ts.typicalSetup();
		
		TicketScale__c ticketScale1 = new TicketScale__c(
			Event__c = testEvent.ID,
			PriceLevel__c = 'Reserved',
			ProjectedPaidTickets__c = 15000,
			Kills__c = 0,
			Comps__c = 0,
			Capacity__c = 16000,
			Price__c = 2000
		);
		
		insert ticketScale1;
		
		ledgerEntries.get(0).BaseAmount__c = 5;
		ledgerEntries.get(0).RateType__c = 'Per Cap';
		ledgerEntries.get(0).Min__c = 0;
		ledgerEntries.get(0).Max__c = 75000;
		ledgerEntries.get(0).ApplyTicketScale__c = 'All Paid Tickets';
		ledgerEntries.get(0).ContraPercent__c = 0;
		ledgerEntries.get(0).ContraAmount__c = 0;
		ledgerEntries.get(0).X3rdPartyPercent__c = 0;
		ledgerEntries.get(0).ContraType__c = 'Flat';
		
		Test.startTest();
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_LEBreakoutCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(75000, updatedLedgerEntry.GrossRevenue__c);
		System.assertEquals(3.75, updatedLedgerEntry.GrossPerPaid__c, 'Gross Revenue 75k / Related Events Projected Paid Tickets 20k');
		System.assertEquals(0, updatedLedgerEntry.ContraAtForecast__c);
		System.assertEquals(0, updatedLedgerEntry.Contra_At_Forecast__c);
		System.assertEquals(75000, updatedLedgerEntry.Net_Revenue__c);
		System.assertEquals(3.75, updatedLedgerEntry.NetPerPaid__c, 'Net Revenue 75k / Related Events Projected Paid Tickets 20k');
	}
	
	static testMethod void testCalculatedFields4() {
		
		TestSettings ts = new TestSettings();
		List<LedgerEntryBreakout__c> ledgerEntries = ts.typicalSetup();
		LedgerEntry__c leGL = [SELECT Id,Event__c FROM LedgerEntry__c where Id =:ledgerEntries.get(0).LedgerEntry__c];
		TicketScale__c ticketScale1 = new TicketScale__c(
			Event__c = leGL.Event__c,
			PriceLevel__c = 'Reserved',
			ProjectedPaidTickets__c = 10000,
			Kills__c = 500,
			Comps__c = 5000,
			Capacity__c = 16000,
			Price__c = 2000
		);
		
		insert ticketScale1;
		ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
		upsert ledgerEntries.get(0);
		
		ledgerEntries.get(0).BaseAmount__c = 10;
		ledgerEntries.get(0).RateType__c = 'Per Cap';
		ledgerEntries.get(0).Min__c = 0;
		ledgerEntries.get(0).Max__c = 0;
		ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
		ledgerEntries.get(0).ContraPercent__c = 0;
		ledgerEntries.get(0).ContraAmount__c = 1000;
		ledgerEntries.get(0).X3rdPartyPercent__c = 0;
		ledgerEntries.get(0).ContraType__c = 'Flat';
		

		//- The financial calculator now updates the related Event__c with the ProjectedPaidTickets__c
		//- of the TicketScales, so we're calculating the values below based on ProjectedPaidTickets__c = 10000
		//- and not ProjectedPaidTickets__c = 20000 that were set on the Event__c initially
		Test.startTest();
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_LEBreakoutCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(100000, updatedLedgerEntry.GrossRevenue__c);
		System.assertEquals(5, updatedLedgerEntry.GrossPerPaid__c, 'Gross Revenue 100k / Related Events Projected Paid Tickets 20k');
		System.assertEquals(1000, updatedLedgerEntry.ContraAtForecast__c);
		System.assertEquals(0.01, updatedLedgerEntry.Contra_At_Forecast__c);
		System.assertEquals(99000, updatedLedgerEntry.Net_Revenue__c);
		System.assertEquals(4.95, updatedLedgerEntry.NetPerPaid__c, 'Gross Revenue 99k / Related Events Projected Paid Tickets 20k');
		
		
	}
	
	static testMethod void testCalculatedFields5() {
		
		TestSettings ts = new TestSettings();
		List<LedgerEntryBreakout__c> ledgerEntries = ts.typicalSetup();
		LedgerEntry__c leGL = [SELECT Id,Event__c FROM LedgerEntry__c where Id =:ledgerEntries.get(0).LedgerEntry__c];
		TicketScale__c ticketScale1 = new TicketScale__c(
			Event__c = leGL.Event__c,
			PriceLevel__c = 'Reserved',
			ProjectedPaidTickets__c = 10000,
			Kills__c = 500,
			Comps__c = 5000,
			Capacity__c = 16000,
			Price__c = 2000
		);
		
		insert ticketScale1;
		ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
		upsert ledgerEntries.get(0);
		ledgerEntries.get(0).BaseAmount__c = 10;
		ledgerEntries.get(0).RateType__c = 'Per Cap';
		ledgerEntries.get(0).Min__c = 0;
		ledgerEntries.get(0).Max__c = 0;
		ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
		ledgerEntries.get(0).ContraPercent__c = 0;
		ledgerEntries.get(0).ContraAmount__c = 1000;
		ledgerEntries.get(0).X3rdPartyPercent__c = 0;
		ledgerEntries.get(0).ContraType__c = 'Per Cap';
		
		//- The financial calculator now updates the related Event__c with the ProjectedPaidTickets__c
		//- of the TicketScales, so we're calculating the values below based on ProjectedPaidTickets__c = 10000
		//- and not ProjectedPaidTickets__c = 20000 that were set on the Event__c initially
		Test.startTest();
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_LEBreakoutCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(100000, updatedLedgerEntry.GrossRevenue__c);
		System.assertEquals(5, updatedLedgerEntry.GrossPerPaid__c, 'Gross Revenue 100k / Related Events Projected Paid Tickets 20k');
		System.assertEquals(10000000, updatedLedgerEntry.ContraAtForecast__c);
		System.assertEquals(100, updatedLedgerEntry.Contra_At_Forecast__c);
		System.assertEquals(-9900000, updatedLedgerEntry.Net_Revenue__c);
		System.assertEquals(-495, updatedLedgerEntry.NetPerPaid__c, 'Gross Revenue -9900000 / Related Events Projected Paid Tickets 20k');
	}
}