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
public class LNE_PerformingRightsFeesAPI_CX_Test {
	
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
		
			  GLAccount__c testGlaAcct1 = new GLAccount__c (
				Type__c = 'Expenses',
				Name = 'Parking Revenue',
				Category__c = 'Other Event Revenue',
					GLCode__c = '12345'
			);
			
			insert testGlaAcct1;
			
			Event__c Evt1 = new Event__c(
				ProjectedPaidTickets__c = 20000,
				ProjectedDropCount__c = 30000,
                ActualDropCount__c = 10,
                SettlementNetGross__c = 10
			);
			
			//insert Evt1;
			LNE_TestObjectFactory.createStandardDataSet( Evt1 );
			
			LedgerEntry__c Ledger1 = new LedgerEntry__c (
				GLAccount__c = testGlaAcct1.Id,
				BaseAmount__c = 33343,
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
	
	static testMethod void testLedgerEntryAPI() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
		ledgerEntry.FlashRateAmount__c = 5;
		ledgerEntry.FlashRateType__c = 'Flat';
		
		
		PageReference pageRef = Page.LNE_PerformingRightsFeesAPI;
		pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(ledgerEntry));
		pageRef.getParameters().put('callback', 'testApiCallback2');
		Test.setCurrentPageReference(pageRef);
		LNE_PerformingRightsFeesAPI_CX  api = new LNE_PerformingRightsFeesAPI_CX ();
		api.processRequest();
	}

	static testMethod void testLedgerEntryBreakoutAPI() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
		ledgerEntry.FlashRateAmount__c = 5;
		ledgerEntry.FlashRateType__c = 'Flat';
        
		update ledgerEntry;

		LedgerEntryBreakout__c leb = new LedgerEntryBreakout__c (
            FlashRateAmount__c = 33343,
            FlashRateType__c = 'Flat', 
            LedgerEntry__c = ledgerEntry.Id        
        );
        
        insert leb;
		
		PageReference pageRef = Page.LNE_PerformingRightsFeesAPI;
		pageRef.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(leb));
		pageRef.getParameters().put('callback', 'testApiCallback2');
		Test.setCurrentPageReference(pageRef);
		LNE_PerformingRightsFeesAPI_CX  api = new LNE_PerformingRightsFeesAPI_CX ();
		api.processRequest();
	}
}