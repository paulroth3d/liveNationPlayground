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
public class LNE_CogsExpensesFieldCalculation_Test {
    
    static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';
    
    class TestSettings {
        
	    public Map<String, Id> objectToId {get; set;}
		private Id glAccountId;            
        
        public TestSettings() {
            List<Event__c> evntList = new List<Event__c>();   
            
            Event__c Evt1 = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Geography__c = 'North America',
                status__c = 'Draft'
            );
            evntList.add(Evt1);
            
            Event__c Evt2 = new Event__c(
                ProjectedDropCount__c = 30000,
                Geography__c = 'North America',
                status__c = 'Draft'
            );
            evntList.add(Evt2);
            
            Event__c Evt3 = new Event__c(
                ProjectedPaidTickets__c = 20000,
                Geography__c = 'North America',
                status__c = 'Draft'
            );
            
            evntList.add(Evt3);   
            objectToId = LNE_TestObjectFactory.createStandardDataSetList(evntList);
        }
        
        
        public List<LedgerEntry__c> typicalSetup(){
            
            List<GLAccount__c> glAccounts = new List<GLAccount__c>();
            //List<Event__c> evntList = new List<Event__c>();         
            List<LedgerEntry__c> savedLedgerEntries = new List<LedgerEntry__c>();
            
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
                new String[]{ RT_Ancillary }
            );
            
            Id RT_ANCILLARY_ID = recordTypeMap.get( RT_Ancillary );
            
            /*
            GLAccount__c testGlaAcct1 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12345'
            );
            glAccounts.add(testGlaAcct1);
            
            GLAccount__c testGlaAcct2 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Alcoholic Beverage Revenue',
                Category__c = 'Concession Revenue',
                GLCode__c = '12340'
            );
            glAccounts.add(testGlaAcct2); 
            */
            GLAccount__c testGlaAcct3 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Non-Alcoholic Beverage Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12349'
            );
            glAccounts.add(testGlaAcct3);
            
            GLAccount__c testGlaAcct4 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Facility Maintenance Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12348'
            );
            glAccounts.add(testGlaAcct4);           
            
            GLAccount__c testGlaAcct5 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Premier Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12347'
            );
            glAccounts.add(testGlaAcct5); 
            Database.insert(glAccounts, false);
            /*
            Event__c Evt1 = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Geography__c = 'North America',
                status__c = 'Draft'
            );
            evntList.add(Evt1);
            
            Event__c Evt2 = new Event__c(
                ProjectedDropCount__c = 30000,
                Geography__c = 'North America',
                status__c = 'Draft'
            );
            evntList.add(Evt2);
            
            Event__c Evt3 = new Event__c(
                ProjectedPaidTickets__c = 20000,
                Geography__c = 'North America',
                status__c = 'Draft'
            );
            evntList.add(Evt3);
            Database.insert(evntList, false);
             */
             
            LedgerEntry__c Ledger1 = new LedgerEntry__c (
                GLAccount__c = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_PARKING),//testGlaAcct1.Id,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                GrossRevenue__c = 0,
                NetRevenue__c = 0,
                Event__c = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_EVENT + 0)//evntList.get(0).Id
            ); 
            savedLedgerEntries.add(Ledger1);
            
            LedgerEntry__c Ledger2 = new LedgerEntry__c (
                GLAccount__c = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_ANCILLARY),//testGlaAcct2.Id,
                BaseAmount__c = 33345,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                GrossRevenue__c = 0,
                NetRevenue__c = 0,                
                Event__c = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_EVENT + 0)//evntList.get(0).Id
            ); 
            savedLedgerEntries.add(Ledger2);
                        
            LedgerEntry__c Ledger3 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct3.Id,
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                GrossRevenue__c = 0,
                NetRevenue__c = 0,            
                Event__c = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_EVENT + 0)//was null
            );
            savedLedgerEntries.add(Ledger3);            
            
            LedgerEntry__c Ledger4 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct4.Id,
                BaseAmount__c = 0,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                GrossRevenue__c = 0,
                NetRevenue__c = 0,         
                Event__c = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_EVENT + 1)//evntList.get(1).Id
            ); 
            savedLedgerEntries.add(Ledger4);
            
            LedgerEntry__c Ledger5 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct5.Id,
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                GrossRevenue__c = 0,
                NetRevenue__c = 0,                
                Event__c = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_EVENT + 2)//evntList.get(2).Id
            ); 
            savedLedgerEntries.add(Ledger5);
            
            LedgerEntry__c Ledger6 = new LedgerEntry__c (
                GLAccount__c = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_PARKING),//testGlaAcct1.Id,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                GrossRevenue__c = 0,
                NetRevenue__c = 0,     
                BaseAmount__c = 0,
                Event__c = objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_EVENT + 0)//evntList.get(0).Id
            );
            
            savedLedgerEntries.add(Ledger6);
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
        try {
            TestSettings ts = new TestSettings();
            
            Test.startTest();
            ts.typicalSetup();
            ts.finalize();
            Test.stopTest();
        } catch( Exception err ){
            System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
        }
    }
    //-- test functionality here
    
    static testMethod void testCalculatedFields1() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 123.90
        );
        
        insert ticketScale1;
        ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
        update ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        
        LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
       /*
        System.assertEquals(100000, updatedLedgerEntry.GrossRevenue__c);
        */
        Test.stopTest();
    }
    
    static testMethod void testCalculatedFields2() {
        
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 121.09
        );
        
        insert ticketScale1;
        ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        
        LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
        
        Test.stopTest();
    }    
 
    
    static testMethod void testCalculatedFields3() {
        
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 321.09
        );
        
        insert ticketScale1;
        ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        
        LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
        
        Test.stopTest();
    }
    
    static testMethod void testCalculatedFields4() {
        
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(3).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 321.09
        );
        
        insert ticketScale1;
        ledgerEntries.get(3).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(3);
        ledgerEntries.get(3).BaseAmount__c = 10;
        ledgerEntries.get(3).RateType__c = 'Per Cap';
        ledgerEntries.get(3).Min__c = 0;
        ledgerEntries.get(3).Max__c = 0;
        ledgerEntries.get(3).ApplyTicketScale__c = 'Selected Tickets';
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(3));
        }
        catch(Exception e){
        }
        
        Test.stopTest();
    }    
    
    static testMethod void testCalculatedFields5() {
        
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(4).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 321.09
        );
        
        insert ticketScale1;
        ledgerEntries.get(4).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(4);
        ledgerEntries.get(4).BaseAmount__c = 10;
        ledgerEntries.get(4).RateType__c = 'Per Cap';
        ledgerEntries.get(4).Min__c = 0;
        ledgerEntries.get(4).Max__c = 0;
        ledgerEntries.get(4).ApplyTicketScale__c = 'Selected Tickets';
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(4));
        }
        catch(Exception e){
        }
        
        Test.stopTest();
    }
    
    static testMethod void testCalculatedFields6() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();        
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 321.09
        );
        
        insert ticketScale1;
        ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).RateType__c = 'Flat';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        
        LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
        
        Test.stopTest();
    }   
    
    static testMethod void testCalculatedFields7() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 321.09
        );
        
        insert ticketScale1;
        ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'All Paid Tickets';
        
        LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
        
        Test.stopTest();
    }   
    
    static testMethod void testCalculatedFields8() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 321.09
        );
        
        insert ticketScale1;
        ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'All Drop Count';
        
        LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
        
        Test.stopTest();
    }                
    
    static testMethod void testCalculatedFields9() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 321.09
        );
        
        insert ticketScale1;
        ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'All';
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
        }
        catch(Exception e){
        }        
        
        Test.stopTest();
    }    
     static testMethod void testCalculatedFields10() {
        TestSettings ts = new TestSettings();
        
        Test.startTest();
        
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 321.09
        );
        
        insert ticketScale1;
        ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = null;
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_CogsExpensesFieldCalculation.calculateFieldsOnGrid(ledgerEntries.get(0));
        }
        catch(Exception e){
        }        
        
        Test.stopTest();
    } 
}