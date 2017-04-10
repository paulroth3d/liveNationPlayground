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
public class LNE_LedgerEntryDefaultFees_Test {
	
	static final String RT_Expenses = 'LedgerEntry__c.Expenses';
	
	class TestSettings {
		
		public TestSettings() {

		}
		
		
		public void typicalSetup(){
			
			
		 Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
				new String[]{ RT_Expenses }
			);
			Id RT_EXPENSES_ID = recordTypeMap.get( RT_Expenses );

            List<GLAccount__c> gls = new List<GLAccount__c>();
            GLAccount__c breakoutGL = LNE_TestObjectFactory.createGLAccount('ASCAP/BMI/SESAC/GMR/BUMA Expense', '50202');
            gls.add(breakoutGL);
            GLAccount__c eventInsuranceGL = LNE_TestObjectFactory.createGLAccount('Event Insurance Expense', '50306');
            gls.add(eventInsuranceGL);
            
            insert gls;
            
            List<PerformingRightsFee__c> prfs = new List<PerformingRIghtsFee__c>();
            
			PerformingRightsFee__c prf1 = new PerformingRightsFee__c(
            	ExternalId__c = 'ASCAP',
                Type__c = 'ASCAP',
                GLAccount__c = breakoutGL.Id,
                Breakout__c = true,
                CapacityRangeStart__c = 0,
                CapacityRangeEnd__c = 200000,
                RateType__c = '% of Net Gross',
                RateAmount__c = 0.45,
                StartDate__c =  date.ValueOf('2010-01-01'),
                EndDate__c =  date.ValueOf('2030-12-31')
            );
            
            prfs.add(prf1);
            
            PerformingRightsFee__c prf2 = new PerformingRightsFee__c(
            	ExternalId__c = 'EventInsurance',
                Type__c = 'Event Insurance Expense',
                GLAccount__c = eventInsuranceGL.Id,
                Breakout__c = false,
                RateType__c = 'Per Drop Count',
                RateAmount__c = 0.45,
                StartDate__c =  date.ValueOf('2010-01-01'),
                EndDate__c =  date.ValueOf('2030-12-31')
            );
            
            prfs.add(prf2);
            
            insert prfs;
            
			Event__c Evt1 = new Event__c(
				ProjectedPaidTickets__c = 10000,
				ProjectedDropCount__c = 10000,
                ActualDropCount__c = 10000,
                EventLastDate__c = date.today(),
                SelloutDropCount__c= 3000
                
			);
			
			Map<String, Id> objectToId = 
			    LNE_TestObjectFactory.createStandardDataSetList(new List<Event__c>{Evt1});
			
		   	LedgerEntry__c Ledger1 = new LedgerEntry__c (
				GLAccount__c = objectToId.get('ancillary'),
				BaseAmount__c = 100,
				RateType__c = 'Flat', 
				RecordTypeId = RT_EXPENSES_ID,
				Event__c = Evt1.Id
			); 

			insert Ledger1;
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
	
	static testMethod void testLedgerEntryDefaultFees() {
		TestSettings ts = new TestSettings();
	 	ts.typicalSetup();
        
        test.startTest();
        		
        	Event__c evt1 = [SELECT Id FROM Event__c LIMIT 1];
        	LNE_LedgerEntryDefaultFees.defaultFees(evt1.Id);
        	
        	
        test.stopTest();
        List<LedgerEntry__c> le = [SELECT Id FROM LedgerEntry__c];
      	System.assertEquals(3, le.size());
        
		
	}
    
    
}