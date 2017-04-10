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
public class LNE_EventExpenseCalculationAPI_CX_Test {

    @testSetup
    static void globalSetup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
    static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';

    class TestSettings {

        public TicketScale__c ticketScale1 = null;
        private Event__c event1 = null;
        //private List<GLAccount__c> glAccounts = new List<GLAccount__c>();
        private List<LedgerEntry__c> savedLedgerEntries = new List<LedgerEntry__c>();
        private List<LedgerEntryBreakout__c> savedLedgerEntryBreaks = new List<LedgerEntryBreakout__c>();
        
        public TestSettings() {
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
        }

        private Id getRTAncillaryId(){
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
                new String[]{ RT_Ancillary }
            );
            return recordTypeMap.get( RT_Ancillary );
        }

        public List<LedgerEntry__c> getLedgerEntries(){

            List<String> fieldNames = new List<String>(LedgerEntry__c.sObjectType.getDescribe().fields.getMap().keySet());
            String ledgerEntryQuery = 'select ' + String.join(fieldNames, ',') + ' from LedgerEntry__c';
            List<LedgerEntry__c> ledgerEntries = Database.query(ledgerEntryQuery);
            return ledgerEntries;
        }

        private void createEvent(){
            if(event1 == null){
                Event__c event = new Event__c(
                    status__c = 'Draft',
                    ProjectedPaidTickets__c = 20000,
                    ProjectedDropCount__c = 30000,
                    NumberofTrucks__c  = 12,
                    SelloutDropCount__c = 2,
                    SelloutPaidTickets__c = 2,
                    NetGrossPotential__c = 2,
                    ProjectedNetGross__c = 4,
                    GrossPotential__c = 5,
                    ProjectedGross__c  = 9,
                    AdjustedGrossPotential__c = 9,
                    ProjectedAdjustedGross__c  = 11
                );
                
                //insert event;
                LNE_TestObjectFactory.createStandardDataSet( event );
                
                event1 = event;
            }
        }

        private void createTicketScale(){
            if(ticketScale1 == null){
                TicketScale__c ticketScale = new TicketScale__c(
                    Event__c = event1.Id,
                    PriceLevel__c = 'Reserved',
                    ProjectedPaidTickets__c = 10000,
                    Kills__c = 500,
                    Comps__c = 5000,
                    Capacity__c = 16000,
                    Price__c = 2000
                );      
                insert ticketScale;
                ticketScale1 = ticketScale;
            }
        }

        public LedgerEntry__c setupTest1(){
            createEvent();
            createTicketScale();

            GLAccount__c testGlaAcct1 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12345'
            );
            insert testGlaAcct1;

            LedgerEntry__c ledgerEntry1 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct1.Id,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                RecordTypeId = getRTAncillaryId(),
                Event__c = event1.Id,
                OfferRate__c  = 123.9,
                InHouseRateType__c = 'Flat',
                InHouseRate__c = 98,
                OfferMin__c = 43.12,
                OfferAtSellout__c = 20.01,
                OfferAtProjection__c = 12.09,   
                InHouseMin__c = 20.09,
                InHouseProjection__c = 8.09,        
                TicketScaleList__c = '|' + ticketScale1.Id + '|'
            ); 
            insert ledgerEntry1;

            LedgerEntryBreakout__c leb1 = new LedgerEntryBreakout__c (
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                LedgerEntry__c = ledgerEntry1.Id,
                OfferRate__c  = 123.5,                  
                InHouseRateType__c = 'Flat',
                InHouseRate__c = 98         
            );    
            insert leb1;

            return ledgerEntry1;
        }

        public LedgerEntry__c setupTest2(){
            createEvent();
            createTicketScale();

            GLAccount__c testGlaAcct2 = new GLAccount__c (
                Type__c = 'Contra',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12346'
            );   
            insert testGlaAcct2;
                    
            LedgerEntry__c ledgerEntry2 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct2.Id,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                OfferRateType__c = 'Flat',
                RecordTypeId = getRTAncillaryId(),
                Event__c = event1.Id,
                OfferRate__c  = 123.5,
                InHouseRate__c = 21,
                InHouseRateType__c = 'Flat',
                OfferMax__c = 65.09,
                OfferAtSellout__c = 70.09,
                OfferAtProjection__c = 78.99,
                InHouseMax__c = 20.09,
                InHouseProjection__c = 22.09
            );       
            insert ledgerEntry2;

            LedgerEntryBreakout__c leb2 = new LedgerEntryBreakout__c (
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                LedgerEntry__c = ledgerEntry2.Id,
                OfferRate__c  = 123.8,
                OfferRateType__c = 'Flat',
                InHouseRate__c = 21,
                InHouseRateType__c = 'Flat'
            ); 
            insert leb2;

            return ledgerEntry2;
        }

        public LedgerEntry__c setupTest3(){
            createEvent();
            createTicketScale();
            
            GLAccount__c testGlaAcct3 = new GLAccount__c (
                Type__c = 'Contra',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12348'
            );    
            insert testGlaAcct3;

            LedgerEntry__c ledgerEntry3 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct3.Id,
                BaseAmount__c = 33333,
                RateType__c = 'Flat', 
                OfferRateType__c = 'Per Truck',
                RecordTypeId = getRTAncillaryId(),
                Event__c = event1.Id,
                OfferRate__c  = 123.5,
                InHouseRate__c = 22,
                InHouseRateType__c = 'Per Truck'
            );       
            insert ledgerEntry3;

            LedgerEntryBreakout__c leb3 = new LedgerEntryBreakout__c (
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                LedgerEntry__c = ledgerEntry3.Id,
                OfferRate__c  = 123.8,
                OfferRateType__c = 'Per Truck',
                InHouseRate__c = 22,
                InHouseRateType__c = 'Per Truck'
            );
            insert leb3;

            return ledgerEntry3;
        }

        public LedgerEntry__c setupTest4(){
            createEvent();
            createTicketScale();
            
            GLAccount__c testGlaAcct4 = new GLAccount__c (
                Type__c = 'Contra',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12318'
            );         
            insert testGlaAcct4;

            LedgerEntry__c ledgerEntry4 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct4.Id,
                BaseAmount__c = 33333,
                RateType__c = 'Flat', 
                OfferRateType__c = 'Per Drop Count',
                RecordTypeId = getRTAncillaryId(),
                Event__c = event1.Id,
                OfferRate__c  = 123.5,
                InHouseRate__c = 23,
                InHouseRateType__c = 'Per Drop Count'
            );     
            insert ledgerEntry4;

            LedgerEntryBreakout__c leb4 = new LedgerEntryBreakout__c (
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                LedgerEntry__c = ledgerEntry4.Id,
                OfferRate__c  = 123.51 ,
                OfferRateType__c = 'Per Drop Count',
                InHouseRate__c = 23,
                InHouseRateType__c = 'Per Drop Count'
            );    
            insert leb4;

            return ledgerEntry4; 
        }
        
        public LedgerEntry__c setupTest5(){
            createEvent();
            createTicketScale();
            
            GLAccount__c testGlaAcct5 = new GLAccount__c (
                Type__c = 'Contra',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12618'
            );     
            insert testGlaAcct5;

            LedgerEntry__c ledgerEntry5 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct5.Id,
                BaseAmount__c = 33333,
                RateType__c = 'Flat', 
                OfferRateType__c = 'Per Paid Ticket',
                RecordTypeId = getRTAncillaryId(),
                Event__c = event1.Id,
                OfferRate__c  = 123.5,
                InHouseRate__c = 25,
                InHouseRateType__c = 'Per Paid Ticket'
            );       
            insert ledgerEntry5;

            LedgerEntryBreakout__c leb5 = new LedgerEntryBreakout__c (
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                LedgerEntry__c = ledgerEntry5.Id,
                OfferRate__c  = 103.51,
                OfferRateType__c = 'Per Paid Ticket',
                InHouseRate__c = 25,
                InHouseRateType__c = 'Per Paid Ticket'
            ); 
            insert leb5; 

            return ledgerEntry5;
        }
        
        public LedgerEntry__c setupTest6(){
            createEvent();
            createTicketScale();
            
            GLAccount__c testGlaAcct6 = new GLAccount__c (
                Type__c = 'Contra',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '13618'
            );   
            insert testGlaAcct6;

            LedgerEntry__c ledgerEntry6 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct6.Id,
                BaseAmount__c = 33333,
                RateType__c = 'Flat', 
                OfferRateType__c = '% of Net Gross',
                RecordTypeId = getRTAncillaryId(),
                Event__c = event1.Id,
                OfferRate__c  = 1230.5,
                InHouseRate__c = 29,
                InHouseRateType__c = '% of Net Gross'
            );      
            insert ledgerEntry6;

            LedgerEntryBreakout__c leb6 = new LedgerEntryBreakout__c (
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                LedgerEntry__c = ledgerEntry6.Id,
                OfferRate__c  = 103.51,
                OfferRateType__c = '% of Net Gross',
                InHouseRate__c = 29,
                InHouseRateType__c = '% of Net Gross'                   
            ); 
            insert leb6;

            return ledgerEntry6;
        }
        
        public LedgerEntry__c setupTest7(){
            createEvent();
            createTicketScale();
            
            GLAccount__c testGlaAcct7 = new GLAccount__c (
                Type__c = 'Contra',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '19618'
            );      
            insert testGlaAcct7;

            LedgerEntry__c ledgerEntry7 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct7.Id,
                BaseAmount__c = 33333,
                RateType__c = 'Flat', 
                OfferRateType__c = '% of Gross',
                RecordTypeId = getRTAncillaryId(),
                Event__c = event1.Id,
                OfferRate__c  = 1230.5,
                InHouseRate__c = 299,
                InHouseRateType__c = '% of Gross'
            );     
            insert ledgerEntry7; 

            LedgerEntryBreakout__c leb7 = new LedgerEntryBreakout__c (
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                LedgerEntry__c = ledgerEntry7.Id,
                OfferRate__c  = 103.51,
                OfferRateType__c = '% of Gross',
                InHouseRate__c = 299,
                InHouseRateType__c = '% of Gross'                
            );
            insert leb7;

            return ledgerEntry7;
        }
        
        public LedgerEntry__c setupTest8(){
            createEvent();
            createTicketScale();
            
            GLAccount__c testGlaAcct8 = new GLAccount__c (
                Type__c = 'Contra',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '18618'
            );    
            insert testGlaAcct8;

            LedgerEntry__c ledgerEntry8 = new LedgerEntry__c (
                GLAccount__c = testGlaAcct8.Id,
                BaseAmount__c = 33333,
                RateType__c = 'Flat', 
                OfferRateType__c = '% of Adjusted Gross',
                RecordTypeId = getRTAncillaryId(),
                Event__c = event1.Id,
                OfferRate__c  = 1230.5,
                InHouseRate__c = 290,
                InHouseRateType__c = '% of Adjusted Gross'
            );   
            insert ledgerEntry8;

            LedgerEntryBreakout__c leb8 = new LedgerEntryBreakout__c (
                BaseAmount__c = 333,
                RateType__c = 'Flat', 
                LedgerEntry__c = ledgerEntry8.Id,
                OfferRate__c  = 103.51 ,
                OfferRateType__c = '% of Adjusted Gross',
                InHouseRate__c = 290,
                InHouseRateType__c = '% of Adjusted Gross'            
            );
            insert leb8;

            return ledgerEntry8;
        }
        
        public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
        }
    }
    
    //-- test test methods here
  
    static testMethod void testAPI() {
        TestSettings ts = new TestSettings();
        LedgerEntry__c ledgerEntry = ts.setupTest1();
        ledgerEntry.BaseAmount__c = 5;
        ledgerEntry.RateType__c = 'Flat';
        ledGerEntry.OfferRate__c= 123.32;
        ledgerEntry.Min__c = 180000;
        ledgerEntry.Max__c = 300000;
        ledgerEntry.ApplyTicketScale__c = 'All Drop Count';
        
        LedgerEntryBreakout__C LEBreakout = [SELECT Id, InHouseRate__c, InHouseRateType__c, BaseAmount__c, RateType__c, Min__c, Max__c,OfferRatetype__c, ApplyTicketScale__c, GrossRevenue__c, GrossPerPaid__c, ContraAtForecast__c, Contra_At_Forecast__c, Net_Revenue__c, NetPerPaid__c FROM LedgerEntryBreakout__c WHERE LedgerEntry__c =:ledgerEntry.Id LIMIT 1];
         
        LEBreakout.BaseAmount__c = 5;
        LEBreakout.RateType__c = 'Flat';
        LEBreakout.Min__c = 180000;
        LEBreakout.Max__c = 300000;
        LEBreakout.ApplyTicketScale__c = 'All Drop Count';
        
        ts.finalize();
             
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(ledgerEntry));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
        PageReference pageRef2 = Page.LNE_EventExpenseCalculationAPI;
        pageRef2.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(LEBreakout));
        pageRef2.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef2);
        api.processRequest();
        
    }
    
    static testMethod void testCalculatedFields1() {
        TestSettings ts = new TestSettings();
        LedgerEntry__c leGL = ts.setupTest1();
        List<LedgerEntryBreakout__c> ledgerEntries = [SELECT Id, InHouseRate__c, InHouseRateType__c, BaseAmount__c, RateType__c, Min__c, Max__c, ApplyTicketScale__c, TicketScaleList__c, ContraPercent__c, ContraAmount__c, X3rdPartyPercent__c, ContraType__c FROM LedgerEntryBreakout__c where LedgerEntry__c =:leGL.Id];
       
        ledgerEntries.get(0).TicketScaleList__c = ts.ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).OfferRate__c = 1009.98;
        ledgerEntries.get(0).RateType__c = 'Flat';
        ledgerEntries.get(0).OfferRateType__c = 'Flat';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 1000;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Flat';
        
        ts.finalize();
        
        Test.startTest();
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(leGL));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
        PageReference pageRef2 = Page.LNE_EventExpenseCalculationAPI;
        pageRef2.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(ledgerEntries.get(0)));
        pageRef2.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef2);
        api.processRequest();
        Test.stopTest();
        
    }
        
    static testMethod void testCalculatedFields2() {
        TestSettings ts = new TestSettings();
        LedgerEntry__c leGL = ts.setupTest2();
        List<LedgerEntryBreakout__c> ledgerEntries= [SELECT Id, InHouseRate__c, InHouseRateType__c, BaseAmount__c, OfferRateType__c, RateType__c, Min__c, Max__c, ApplyTicketScale__c, TicketScaleList__c, ContraPercent__c, ContraAmount__c, X3rdPartyPercent__c, ContraType__c FROM LedgerEntryBreakout__c where LedgerEntry__c =:leGL.Id];
       
        ledgerEntries.get(0).TicketScaleList__c = ts.ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).OfferRate__c = 1009.98;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 1000;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Flat';
        
        ts.finalize();
        
        Test.startTest();
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(leGL));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
        PageReference pageRef2 = Page.LNE_EventExpenseCalculationAPI;
        pageRef2.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(ledgerEntries.get(0)));
        pageRef2.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef2);
        api.processRequest();
        Test.stopTest();
        
    }
    
    static testMethod void testCalculatedFields() {
        TestSettings ts = new TestSettings();
        ts.finalize();
               
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize('aBC'));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
    }  
    
    static testMethod void testCalculatedFields3() { 
        TestSettings ts = new TestSettings();
        LedgerEntry__c leGL = ts.setupTest3();
        List<LedgerEntryBreakout__c> ledgerEntries= [SELECT Id, InHouseRate__c, InHouseRateType__c, BaseAmount__c, OfferRateType__c, RateType__c, Min__c, Max__c, ApplyTicketScale__c, TicketScaleList__c, ContraPercent__c, ContraAmount__c, X3rdPartyPercent__c, ContraType__c FROM LedgerEntryBreakout__c where LedgerEntry__c =:leGL.Id];
        
        ledgerEntries.get(0).TicketScaleList__c = ts.ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).OfferRate__c = 1009.98;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 1000;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Flat';
        
        ts.finalize();

        Test.startTest();
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(leGL));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
        PageReference pageRef2 = Page.LNE_EventExpenseCalculationAPI;
        pageRef2.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(ledgerEntries.get(0)));
        pageRef2.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef2);
        api.processRequest();
        Test.stopTest();
        
    }   
    
    static testMethod void testCalculatedFields4() {
        TestSettings ts = new TestSettings();
        LedgerEntry__c leGL = ts.setupTest4();
        List<LedgerEntryBreakout__c> ledgerEntries= [SELECT Id, InHouseRate__c, InHouseRateType__c, BaseAmount__c, OfferRateType__c, RateType__c, Min__c, Max__c, ApplyTicketScale__c, TicketScaleList__c, ContraPercent__c, ContraAmount__c, X3rdPartyPercent__c, ContraType__c FROM LedgerEntryBreakout__c where LedgerEntry__c =:leGL.Id];
        
        ledgerEntries.get(0).TicketScaleList__c = ts.ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).OfferRate__c = 1009.98;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 1000;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Flat';
        
        ts.finalize();
        
        Test.startTest();
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(leGL));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
        PageReference pageRef2 = Page.LNE_EventExpenseCalculationAPI;
        pageRef2.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(ledgerEntries.get(0)));
        pageRef2.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef2);
        api.processRequest();
        Test.stopTest();
        
    }   
    
    static testMethod void testCalculatedFields5() {
        TestSettings ts = new TestSettings();
        LedgerEntry__c leGL = ts.setupTest5();
        List<LedgerEntryBreakout__c> ledgerEntries= [SELECT Id, InHouseRate__c, InHouseRateType__c, BaseAmount__c, OfferRateType__c, RateType__c, Min__c, Max__c, ApplyTicketScale__c, TicketScaleList__c, ContraPercent__c, ContraAmount__c, X3rdPartyPercent__c, ContraType__c FROM LedgerEntryBreakout__c where LedgerEntry__c =:leGL.Id];
       
        ledgerEntries.get(0).TicketScaleList__c = ts.ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).OfferRate__c = 1009.98;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 1000;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Flat';
        
        ts.finalize();
        
        Test.startTest();
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(leGL));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
        PageReference pageRef2 = Page.LNE_EventExpenseCalculationAPI;
        pageRef2.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(ledgerEntries.get(0)));
        pageRef2.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef2);
        api.processRequest();
        Test.stopTest();
        
    }
    
    static testMethod void testCalculatedFields6() {
        TestSettings ts = new TestSettings();
        LedgerEntry__c leGL = ts.setupTest6();
        List<LedgerEntryBreakout__c> ledgerEntries= [SELECT Id, InHouseRate__c, InHouseRateType__c, BaseAmount__c, OfferRateType__c, RateType__c, Min__c, Max__c, ApplyTicketScale__c, TicketScaleList__c, ContraPercent__c, ContraAmount__c, X3rdPartyPercent__c, ContraType__c FROM LedgerEntryBreakout__c where LedgerEntry__c =:leGL.Id];
      
        ledgerEntries.get(0).TicketScaleList__c = ts.ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).OfferRate__c = 1009.98;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 1000;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Flat';
        
        ts.finalize();
        
        Test.startTest();
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(leGL));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
        PageReference pageRef2 = Page.LNE_EventExpenseCalculationAPI;
        pageRef2.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(ledgerEntries.get(0)));
        pageRef2.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef2);
        api.processRequest();       
        Test.stopTest();
        
    }   
    
    static testMethod void testCalculatedFields7() {
        TestSettings ts = new TestSettings();
        LedgerEntry__c leGL = ts.setupTest7();
        List<LedgerEntryBreakout__c> ledgerEntries= [SELECT Id, InHouseRate__c, InHouseRateType__c, BaseAmount__c, OfferRateType__c, RateType__c, Min__c, Max__c, ApplyTicketScale__c, TicketScaleList__c, ContraPercent__c, ContraAmount__c, X3rdPartyPercent__c, ContraType__c FROM LedgerEntryBreakout__c where LedgerEntry__c =:leGL.Id];
        
        ledgerEntries.get(0).TicketScaleList__c = ts.ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).OfferRate__c = 1009.98;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 1000;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Flat';
        
        ts.finalize();
        
        Test.startTest();
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(leGL));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
        PageReference pageRef2 = Page.LNE_EventExpenseCalculationAPI;
        pageRef2.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(ledgerEntries.get(0)));
        pageRef2.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef2);
        api.processRequest();       
        Test.stopTest();
        
    }   
    
    static testMethod void testCalculatedFields8() {
        TestSettings ts = new TestSettings();
        LedgerEntry__c leGL = ts.setupTest8();
        List<LedgerEntryBreakout__c> ledgerEntries= [SELECT Id, InHouseRate__c, InHouseRateType__c, BaseAmount__c, OfferRateType__c, RateType__c, Min__c, Max__c, ApplyTicketScale__c, TicketScaleList__c, ContraPercent__c, ContraAmount__c, X3rdPartyPercent__c, ContraType__c FROM LedgerEntryBreakout__c where LedgerEntry__c =:leGL.Id];
        
        ledgerEntries.get(0).TicketScaleList__c = ts.ticketScale1.Id;
        upsert ledgerEntries.get(0);
        ledgerEntries.get(0).BaseAmount__c = 10;
        ledgerEntries.get(0).OfferRate__c = 1009.98;
        ledgerEntries.get(0).RateType__c = 'Per Cap';
        ledgerEntries.get(0).Min__c = 0;
        ledgerEntries.get(0).Max__c = 0;
        ledgerEntries.get(0).ApplyTicketScale__c = 'Selected Tickets';
        ledgerEntries.get(0).ContraPercent__c = 0;
        ledgerEntries.get(0).ContraAmount__c = 1000;
        ledgerEntries.get(0).X3rdPartyPercent__c = 0;
        ledgerEntries.get(0).ContraType__c = 'Flat';
        
        ts.finalize();
        
        Test.startTest();
        PageReference pageRef = Page.LNE_EventExpenseCalculationAPI;
        pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(leGL));
        pageRef.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef);
        LNE_EventExpenseCalculationAPI_CX api = new LNE_EventExpenseCalculationAPI_CX();
        api.processRequest();
        
        PageReference pageRef2 = Page.LNE_EventExpenseCalculationAPI;
        pageRef2.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(ledgerEntries.get(0)));
        pageRef2.getParameters().put('callback', 'testApiCallback2');
        Test.setCurrentPageReference(pageRef2);
        api.processRequest();       
        Test.stopTest();
        
    } 
    
}