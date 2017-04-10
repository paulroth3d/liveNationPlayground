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
public class LNE_LedgerCalculateCurrentFlash_Test {
	
	static final String RT_Expenses = 'LedgerEntry__c.Expenses';
	
	class TestSettings {
		
		public TestSettings() {

		}
		
		
		public LedgerEntry__c typicalSetup(){
			
		    List<LedgerEntry__c> savedLedgerEntries = new List<LedgerEntry__c>();
			
		    Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
				new String[]{ RT_Expenses }
			);
			Id RT_EXPENSES_ID = recordTypeMap.get( RT_Expenses );
			
			Event__c Evt1 = new Event__c(
				ProjectedPaidTickets__c = 10000,
				ProjectedDropCount__c = 10000,
                ActualDropCount__c = 10000,
                SettlementNetGross__c = 10000
			);
			
		    Map<String, Id> objectToId = LNE_TestObjectFactory.createStandardDataSetList(new List<Event__c>{Evt1});
		    
		   	LedgerEntry__c Ledger1 = new LedgerEntry__c (
				GLAccount__c = objectToId.get('ancillary'),
				BaseAmount__c = 100,
				RateType__c = 'Flat', 
				RecordTypeId = RT_EXPENSES_ID,
				Event__c = Evt1.Id
			); 

			insert Ledger1;
			
			return Ledger1;
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
		try {
			TestSettings ts = new TestSettings();
			ts.typicalSetup();
			ts.finalize();
		} catch( Exception err ){
			System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
		}
	}
	
	//-- test functionality here
	
	static testMethod void testLedgerEntryFlat() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
        
        test.startTest();
        
		ledgerEntry.FlashRateAmount__c = 5;
		ledgerEntry.FlashRateType__c = 'Flat';
        
        LNE_LedgerCalculateCurrentFlash.calculateFieldsOnGridLE(ledgerEntry);
        
        test.stopTest();
        System.assertEquals(5, ledgerEntry.CurrentFlash__c);
        
        
		
	}
    
    static testMethod void testLedgerEntryPerDropCount() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
        test.startTest();
		ledgerEntry.FlashRateAmount__c = 5;
		ledgerEntry.FlashRateType__c = 'Per Drop Count';
        
        LNE_LedgerCalculateCurrentFlash.calculateFieldsOnGridLE(ledgerEntry);
        test.stopTest();
        System.assertEquals(50000, ledgerEntry.CurrentFlash__c);

		
	}
    
    static testMethod void testLedgerEntryPerPaidTicket() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
        test.startTest();

		ledgerEntry.FlashRateAmount__c = 5;
		ledgerEntry.FlashRateType__c = 'Per Paid Ticket';
        
        LNE_LedgerCalculateCurrentFlash.calculateFieldsOnGridLE(ledgerEntry);
                test.stopTest();

        System.assertEquals(0, ledgerEntry.CurrentFlash__c);
		
	}
    
    static testMethod void testLedgerEntryGross() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
        test.startTest();

		ledgerEntry.FlashRateAmount__c = 5;
		ledgerEntry.FlashRateType__c = '% of Net Gross';
        
        LNE_LedgerCalculateCurrentFlash.calculateFieldsOnGridLE(ledgerEntry);
                test.stopTest();

		System.assertEquals(0, ledgerEntry.CurrentFlash__c);

		
	}

	static testMethod void testLedgerEntryBreakoutFlat() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
        test.startTest();

		update ledgerEntry;

		LedgerEntryBreakout__c leb = new LedgerEntryBreakout__c (
            FlashRateAmount__c = 100,
            FlashRateType__c = 'Flat', 
            LedgerEntry__c = ledgerEntry.Id        
        );
        
        insert leb;
        
        LNE_LedgerCalculateCurrentFlash.calculateFieldsOnGridLEB(leb);
        test.stopTest();
        System.assertEquals(100, leb.CurrentFlash__c);


	}
    static testMethod void testLedgerEntryBreakoutPerDropCount() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
        test.startTest();
		update ledgerEntry;

		LedgerEntryBreakout__c leb = new LedgerEntryBreakout__c (
            FlashRateAmount__c = 100,
            FlashRateType__c = 'Per Drop Count', 
            LedgerEntry__c = ledgerEntry.Id        
        );
        
        insert leb;
        
        LNE_LedgerCalculateCurrentFlash.calculateFieldsOnGridLEB(leb);
        test.stopTest();

       	System.assertEquals(1000000, leb.CurrentFlash__c);


	}
    static testMethod void testLedgerEntryBreakoutPerPaidTicket() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
        test.startTest();

		update ledgerEntry;

		LedgerEntryBreakout__c leb = new LedgerEntryBreakout__c (
            FlashRateAmount__c = 100,
            FlashRateType__c = 'Per Paid Ticket', 
            LedgerEntry__c = ledgerEntry.Id        
        );
        
        insert leb;
        LNE_LedgerCalculateCurrentFlash.calculateFieldsOnGridLEB(leb);
        test.stopTest();

        System.assertEquals(0, leb.CurrentFlash__c);


	}
    static testMethod void testLedgerEntryBreakoutGross() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
        test.startTest();

		update ledgerEntry;

		LedgerEntryBreakout__c leb = new LedgerEntryBreakout__c (
            FlashRateAmount__c = 100,
            FlashRateType__c = '% of Net Gross', 
            LedgerEntry__c = ledgerEntry.Id        
        );
        
        insert leb;
        LNE_LedgerCalculateCurrentFlash.calculateFieldsOnGridLEB(leb);
        test.stopTest();

        System.assertEquals(0, leb.CurrentFlash__c);


	}
}