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
public class LNE_LedgerEntryFieldCalculation_Test {
    
    static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';
    
    class TestSettings {
        
        public TestSettings() {

        }
        
        
        public List<LedgerEntry__c> typicalSetup(){
            
            List<GLAccount__c> glAccounts = new List<GLAccount__c>();
            List<Event__c> evntList = new List<Event__c>();
            List<LedgerEntry__c> savedLedgerEntries = new List<LedgerEntry__c>();
            
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
                new String[]{ RT_Ancillary }
            );
            Id RT_ANCILLARY_ID = recordTypeMap.get( RT_Ancillary );
            
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
            
            Event__c Evt1 = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                status__c = 'Draft',
                Geography__c = 'North America'
            );
            evntList.add(Evt1);
            
            Event__c Evt2 = new Event__c(
                ProjectedDropCount__c = 30000,
                status__c = 'Draft',
                Geography__c = 'North America'
            );
            evntList.add(Evt2);
            
            Event__c Evt3 = new Event__c(
                ProjectedPaidTickets__c = 20000,
                status__c = 'Draft',
                Geography__c = 'North America'
            );                        
            evntList.add(Evt3);
            System.debug('--1 '+ evntList);
            
            //Database.insert(evntList, false);
            LNE_TestObjectFactory.createStandardDataSetList( evntList );
            System.debug('--2 '+ evntList);         
            
            LedgerEntry__c Ledger1 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct1.Id,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                Event__c = evntList.get(0).Id
            ); 
            savedLedgerEntries.add(Ledger1);
            
            LedgerEntry__c Ledger2 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct2.Id,
                BaseAmount__c = 33345,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                Event__c = evntList.get(0).Id
            ); 
            savedLedgerEntries.add(Ledger2);
            
            LedgerEntry__c Ledger3 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct3.Id,
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                Event__c = evntList.get(1).Id                
            ); 
            savedLedgerEntries.add(Ledger3);
            
            LedgerEntry__c Ledger4 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct4.Id,
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID
            ); 
            savedLedgerEntries.add(Ledger4);
            
            LedgerEntry__c Ledger5 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct5.Id,
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                RecordTypeId = RT_ANCILLARY_ID,
                Event__c = evntList.get(2).Id
            ); 
            savedLedgerEntries.add(Ledger5);
            System.debug('--3 '+savedLedgerEntries);
            Database.insert(savedLedgerEntries, false);
            System.debug('--4 '+savedLedgerEntries);
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
            ts.typicalSetup();
            ts.finalize();
        } catch( Exception err ){
            System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
        }
    }
    
    //-- test functionality here
    
    static testMethod void testCalculatedFields1() {
        TestSettings ts = new TestSettings();
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        ledgerEntries.get(0).BaseAmount__c = 5;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 180000;
        ledgerEntries.get(0).Max__c = 300000;
        ledgerEntries.get(0).ApplyTicketScale__c = 'All Drop Count';
        ledgerEntries.get(0).ContraPercent__c = 0.44;
        ledgerEntries.get(0).ContraAmount__c = 0;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Per Cap';
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(0));
            System.assertEquals(180000, updatedLedgerEntry.GrossRevenue__c);
            System.assertEquals(9, updatedLedgerEntry.GrossPerPaid__c);
            System.assertEquals(79200, updatedLedgerEntry.ContraAtForecast__c);
            System.assertEquals(0.44, updatedLedgerEntry.ContraPercentAtForecast__c);
            System.assertEquals(100800, updatedLedgerEntry.NetRevenue__c);
            System.assertEquals(5.04, updatedLedgerEntry.NetPerPaid__c);
        }
        catch(Exception e){
        }    


    }
    
    
    static testMethod void testCalculatedFields2() {
        TestSettings ts = new TestSettings();
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        ledgerEntries.get(0).BaseAmount__c = null;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 180000;
        ledgerEntries.get(0).Max__c = 300000;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0.44;
        ledgerEntries.get(0).ContraAmount__c = 0;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Per Cap';
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(0));
            
        }
        catch(Exception e){
        }   
        
    }
    
    
    static testMethod void testCalculatedFields3() {
        TestSettings ts = new TestSettings();
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        ledgerEntries.get(0).BaseAmount__c = 5;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 75000;
        ledgerEntries.get(0).ApplyTicketScale__c = 'All Paid Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 0;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Flat';
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(0));
            System.assertEquals(75000, updatedLedgerEntry.GrossRevenue__c);
            System.assertEquals(3.75, updatedLedgerEntry.GrossPerPaid__c);
            System.assertEquals(0, updatedLedgerEntry.ContraAtForecast__c);
            System.assertEquals(0, updatedLedgerEntry.ContraPercentAtForecast__c);
            System.assertEquals(75000, updatedLedgerEntry.NetRevenue__c);
            System.assertEquals(3.75, updatedLedgerEntry.NetPerPaid__c);
        }
        catch(Exception e){
        }
        
        
    }
    
    
    static testMethod void testCalculatedFields4() {
        
        TestSettings ts = new TestSettings();
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(4).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 123.21
        );
        
        Test.startTest();
        
        insert ticketScale1;
        ledgerEntries.get(4).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(4);
        ledgerEntries.get(4).BaseAmount__c = 10;
        ledgerEntries.get(4).RateType__c = 'Per Cap';
        ledgerEntries.get(4).Min__c = 0;
        ledgerEntries.get(4).Max__c = 0;
        ledgerEntries.get(4).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(4).ContraPercent__c = 0;
        ledgerEntries.get(4).ContraAmount__c = 1000;
        ledgerEntries.get(4).X3rdPartyPercent__c = 0;
        ledgerEntries.get(4).ContraType__c = 'Flat';
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(4));
            System.assertEquals(100000, updatedLedgerEntry.GrossRevenue__c);
            //System.assertEquals(10, updatedLedgerEntry.GrossPerPaid__c);
            System.assertEquals(1000, updatedLedgerEntry.ContraAtForecast__c);
            System.assertEquals(0.01, updatedLedgerEntry.ContraPercentAtForecast__c);
            System.assertEquals(99000, updatedLedgerEntry.NetRevenue__c);
            //System.assertEquals(9.9, updatedLedgerEntry.NetPerPaid__c);
        }
        catch(Exception e){
        }   
        
    }
    
    
    static testMethod void testCalculatedFields5() {
        
        TestSettings ts = new TestSettings();
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 124.98
        );
        
        insert ticketScale1;
        ledgerEntries.get(3).TicketScaleList__c = ticketScale1.Id;
        try{
            upsert ledgerEntries.get(3);
            ledgerEntries.get(3).BaseAmount__c = 10;
            ledgerEntries.get(3).RateType__c = 'Per Cap';
            ledgerEntries.get(3).Min__c = 0;
            ledgerEntries.get(3).Max__c = 0;
            ledgerEntries.get(3).ApplyTicketScale__c = 'Selected Tickets';
            ledgerEntries.get(3).ContraPercent__c = 0;
            ledgerEntries.get(3).ContraAmount__c = 1000;
            ledgerEntries.get(3).X3rdPartyPercent__c = 0;
            ledgerEntries.get(3).ContraType__c = 'Per Cap';
        
            LedgerEntry__c updatedLedgerEntry = LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(3));
            System.assertEquals(100000, updatedLedgerEntry.GrossRevenue__c);
            System.assertEquals(5, updatedLedgerEntry.GrossPerPaid__c);
            System.assertEquals(10000000, updatedLedgerEntry.ContraAtForecast__c);
            System.assertEquals(100, updatedLedgerEntry.ContraPercentAtForecast__c);
            System.assertEquals(-9900000, updatedLedgerEntry.NetRevenue__c);
            System.assertEquals(-495.00, updatedLedgerEntry.NetPerPaid__c);
        }
        catch(Exception e){
        }   
        
    }
    
    static testMethod void testCalculatedFields6() {
        
        TestSettings ts = new TestSettings();
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(2).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 124.98
        );
        
        Test.startTest();
        
        insert ticketScale1;
        ledgerEntries.get(2).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(2);
        ledgerEntries.get(2).BaseAmount__c = 10;
        ledgerEntries.get(2).RateType__c = 'Per Cap';
        ledgerEntries.get(2).Min__c = 0;
        ledgerEntries.get(2).Max__c = 0;
        ledgerEntries.get(2).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(2).ContraPercent__c = 0;
        ledgerEntries.get(2).ContraAmount__c = 1000;
        ledgerEntries.get(2).X3rdPartyPercent__c = 0;
        ledgerEntries.get(2).ContraType__c = 'Per Cap';
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(2));
            /*System.assertEquals(100000, updatedLedgerEntry.GrossRevenue__c);
            System.assertEquals(5, updatedLedgerEntry.GrossPerPaid__c);
            System.assertEquals(10000000, updatedLedgerEntry.ContraAtForecast__c);
            System.assertEquals(100, updatedLedgerEntry.ContraPercentAtForecast__c);
            System.assertEquals(-9900000, updatedLedgerEntry.NetRevenue__c);
            System.assertEquals(-495.00, updatedLedgerEntry.NetPerPaid__c);*/
        }
        catch(Exception e){
        }   
        
    }

    static testMethod void testCalculatedFields7() {
        TestSettings ts = new TestSettings();
        List<LedgerEntry__c> ledgerEntries = ts.typicalSetup();
        TicketScale__c ticketScale1 = new TicketScale__c(
            Event__c = ledgerEntries.get(0).Event__c,
            PriceLevel__c = 'Reserved',
            ProjectedPaidTickets__c = 10000,
            Kills__c = 500,
            Comps__c = 5000,
            Capacity__c = 16000,
            Price__c = 124.98
        );
        
        Test.startTest();
        
        insert ticketScale1;
        ledgerEntries.get(0).TicketScaleList__c = ticketScale1.Id;
        upsert ledgerEntries.get(0);    
        ledgerEntries.get(0).BaseAmount__c = 5;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 75000;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 0;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Per Cap';
        
        try{
            LedgerEntry__c updatedLedgerEntry = LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntries.get(0));

        }
        catch(Exception e){
        }
        
        
    }
    
}