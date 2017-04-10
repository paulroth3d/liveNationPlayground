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
public class LNE_CogsExpensesAPI_CX_Test {
    
    static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';
    
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
    
        public LedgerEntry__c typicalSetup(){
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
                new String[]{ RT_Ancillary }
            );
            
            Id RT_ANCILLARY_ID = recordTypeMap.get( RT_Ancillary );

            LedgerEntry__c Ledger1 = new LedgerEntry__c (
                GLAccount__c = glAccountId,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                Event__c = testEvent.Id
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
        ledgerEntry.BaseAmount__c = 5;
        ledgerEntry.RateType__c = 'Per Cap';
        ledgerEntry.Min__c = 180000;
        ledgerEntry.Max__c = 300000;
        ledgerEntry.ApplyTicketScale__c = 'All Drop Count';
        
        
        PageReference pageRef = Page.LNE_CogsExpensesAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(ledgerEntry));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_CogsExpensesAPI_CX api = new LNE_CogsExpensesAPI_CX();
        api.processRequest();    
    }
    
    static testMethod void testLedgerEntryBreakoutAPI() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        LedgerEntry__c ledgerEntry = ts.typicalSetup();
        ledgerEntry.BaseAmount__c = 5;
        ledgerEntry.RateType__c = 'Per Cap';
        ledgerEntry.Min__c = 180000;
        ledgerEntry.Max__c = 300000;
        ledgerEntry.ApplyTicketScale__c = 'All Drop Count';
        update ledgerEntry;
        
        LedgerEntryBreakout__c leb = new LedgerEntryBreakout__c (
            BaseAmount__c = 33343,
            RateType__c = 'Flat', 
            LedgerEntry__c = ledgerEntry.Id,
            OfferRate__c  = 123.5,                  
            InHouseRateType__c = 'Flat',
            InHouseRate__c = 98         
        );
        
        PageReference pageRef = Page.LNE_CogsExpensesAPI;
        pageRef.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(leb));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_CogsExpensesAPI_CX api = new LNE_CogsExpensesAPI_CX();
        api.processRequest(); 
        
        Test.stopTest();
    }
}