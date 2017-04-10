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
private class LNE_LedgerPreventDuplicates_T_Test {
    static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';
    
    class TestSettings {
        LedgerEntry__c[] newLedgers;
        LedgerEntry__c[] oldLedgers;        
        Map<Id, LedgerEntry__c> oldLedgersMap;
        Event__c Evt1;
        Event__c Evt2;
        
        public TestSettings() {
        
            //-- global setup here

            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
                new String[]{ RT_Ancillary }
            );
            Id RT_ANCILLARY_ID = recordTypeMap.get( RT_Ancillary );
            newLedgers = new List<LedgerEntry__c>(); 
            oldLedgers = new List<LedgerEntry__c>();
            
            List<GLAccount__c> glAccounts = new List<GLAccount__c>();   
            List<Event__c> evntList = new List<Event__c>(); 
            
            GLAccount__c testGlaAcct1 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12346'
            );
            glAccounts.add(testGlaAcct1);
            
            GLAccount__c testGlaAcct2 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Food Revenue',
                Category__c = 'Concession Revenue',
                GLCode__c = '12345'
            );
            glAccounts.add(testGlaAcct2);
            
            Database.insert(glAccounts, false);    
            
           Evt1 = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                status__c = 'Draft'/*,
               	RecordTypeId = null*/
            );
            evntList.add(Evt1);
            
           Evt2 = new Event__c(
                ProjectedPaidTickets__c = 30000,
                ProjectedDropCount__c = 40000,
                status__c = 'Draft'
            );      
            evntList.add(Evt2);
           // Database.insert(evntList);
            LNE_TestObjectFactory.createStandardDataSetList( evntList );
            LedgerEntry__c newLedger1 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct1.Id,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                Event__c = Evt1.Id
            ); 

            LedgerEntry__c newLedger2 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct2.Id,
                BaseAmount__c = 33345,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                Event__c = Evt2.Id
            );  
            LedgerEntry__c newLedger3 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct2.Id,
                BaseAmount__c = 33345,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                Event__c = Evt2.Id
            );          
            
            insert newLedger1;
            insert newLedger2;  
            Database.insert(newLedger3, false); 
            newLedgers.add(newLedger1);
            newLedgers.add(newLedger2);            
           
        }
        
        public void typicalSetup(){
            Map<Id, LedgerEntry__c> oldLedgersMap = new Map<Id, LedgerEntry__c>(oldLedgers);    
                
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
    /*
    static testMethod void testPreventDuplicate() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        
        Test.startTest();
        
        Test.stopTest();

    }
    */
}