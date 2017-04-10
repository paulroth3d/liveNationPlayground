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
public class LNE_CogsBreakoutFieldCalculation_Test{

	class TestSettings {
	    
	    public Event__c testEvent {get; set;}
		private Id glAccountId;
		
		public TestSettings() {
			Event__c Evt1 = new Event__c(
				ProjectedPaidTickets__c = 20000,
				ProjectedDropCount__c = 30000
			);
			
			//insert Evt1;
			Map<String, Id> objectToId = LNE_TestObjectFactory.createStandardDataSet( Evt1 );
			testEvent = Evt1;
			glAccountId = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_PARKING);
		}
		
		
		public List<LedgerEntryBreakout__c> typicalSetup(){
			List<LedgerEntryBreakout__c> savedLedgerEntries = new List<LedgerEntryBreakout__c>();
			
			LedgerEntry__c ledgerEntry1 = new LedgerEntry__c(
				GLAccount__c = glAccountId,
				BaseAmount__c = 33343,
				RateType__c = 'Flat', 
				Event__c = testEvent.Id
			);
			
			insert ledgerEntry1;
			
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
		}
	}
	
	//-- test test methods here

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

	static testMethod void runSetupAWithoutException() {
		TestSettings ts = new TestSettings();
		Test.startTest();
		ts.typicalSetup();
		ts.finalize();
		Test.stopTest();
	}
	
	//-- test functionality here
	static testMethod void testCalculatedFields1() {
		TestSettings ts = new TestSettings();
		Test.startTest();
		List<LedgerEntryBreakout__c> ledgerEntries = ts.typicalSetup();
		
		ts.testEvent.ProjectedPaidTickets__c = 20000;
        ts.testEvent.ProjectedDropCount__c = 30000;
		update ts.testEvent;
		
		ledgerEntries.get(0).BaseAmount__c = 5;
		ledgerEntries.get(0).RateType__c = 'Per Cap';
		ledgerEntries.get(0).Min__c = 180000;
		ledgerEntries.get(0).Max__c = 300000;
		ledgerEntries.get(0).ApplyTicketScale__c = 'All Drop Count';
		ledgerEntries.get(0).ContraPercent__c = 0.44;
		ledgerEntries.get(0).ContraAmount__c = 0;
		ledgerEntries.get(0).X3rdPartyPercent__c = 0;
		ledgerEntries.get(0).ContraType__c = 'Per Cap';
		
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_CogsBreakoutFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(180000, updatedLedgerEntry.COGSAtForecast__c);
	}
	
	// test min gross revenue
	static testMethod void testCalculatedFields2() {
		TestSettings ts = new TestSettings();
		
		Test.startTest();
		
		List<LedgerEntryBreakout__c> ledgerEntries = ts.typicalSetup();
		ledgerEntries.get(0).BaseAmount__c = 1;
		ledgerEntries.get(0).RateType__c = 'Per Cap';
		ledgerEntries.get(0).Min__c = 180000;
		ledgerEntries.get(0).Max__c = 300000;
		ledgerEntries.get(0).ApplyTicketScale__c = 'All Drop Count';
		ledgerEntries.get(0).ContraPercent__c = 0.44;
		ledgerEntries.get(0).ContraAmount__c = 0;
		ledgerEntries.get(0).X3rdPartyPercent__c = 0;
		ledgerEntries.get(0).ContraType__c = 'Per Cap';
		
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_CogsBreakoutFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(180000, updatedLedgerEntry.COGSAtForecast__c);
		
	}
	
	// test All Paid Tickets
	static testMethod void testCalculatedFields3() {
	    LNE_FinancialCalculator.currentlyRunning = true;
	    
		TestSettings ts = new TestSettings();
		
		Test.startTest();
		
		List<LedgerEntryBreakout__c> ledgerEntries = ts.typicalSetup();
		
		TicketScale__c ticketScale1 = new TicketScale__c(
			Event__c = ts.testEvent.ID,
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
		
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_CogsBreakoutFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(75000, updatedLedgerEntry.COGSAtForecast__c);
	}
	
	static testMethod void testCalculatedFields4() {
		TestSettings ts = new TestSettings();
		
		Test.startTest();
		
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
		ledgerEntries.get(0).TicketScaleList__c = '|' + ticketScale1.Id + '|';
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
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_CogsBreakoutFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(100000, updatedLedgerEntry.COGSAtForecast__c);
		
		
	}
	
	
	static testMethod void testCalculatedFields5() {
		TestSettings ts = new TestSettings();
		
		Test.startTest();
		
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
		ledgerEntries.get(0).TicketScaleList__c = '|' + ticketScale1.Id + '|';
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
		LedgerEntryBreakout__c updatedLedgerEntry = LNE_CogsBreakoutFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
		Test.stopTest();
		System.assertEquals(100000, updatedLedgerEntry.COGSAtForecast__c);
		
		
	}
}