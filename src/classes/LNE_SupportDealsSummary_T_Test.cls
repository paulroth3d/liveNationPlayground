@isTest
private class LNE_SupportDealsSummary_T_Test {
    static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';
    static final String RT_VENDOR = 'Account.Vendor';
    
    class TestSettings {
        Event__c Evt1;
        Account venue;
        List<Account> artists;
        
        List<Event__c> primaryHeadlinerEvents;
        List<EventDateTime__c> primaryHeadlinerEventDateTimes;

        List<Event__c> rentalEvents;
        List<EventDateTime__c> rentalEventDateTimes;
        
        public TestSettings() {
        
            //-- global setup here

            //create account__c(venue)
            venue = LNE_TestObjectFactory.createAccount('Test Venue');
            Id venueRecordTypeId = [select Id from RecordType where Name = 'Venue' and SobjectType = 'Account'].Id;
            venue.RecordTypeId = venueRecordTypeId;
            venue.Format__c = 'Country';
            venue.Market__c = 'San Francisco';
            venue.BillingStreet = 'One Market';
            venue.BillingCity = 'San Francisco';
            venue.BillingState = 'California';
            venue.BillingPostalCode = '94105';
            insert venue;

            //create artists
            artists = new Account[]{
				LNE_TestObjectFactory.createAccount( 'Artist1' ),
				LNE_TestObjectFactory.createAccount( 'Artist2' ),
                LNE_TestObjectFactory.createAccount( 'Artist3' )
			};  
            insert artists;

            //----------------------------------------------------------------------------------------
            //create primary headliner events
            primaryHeadlinerEvents = new List<Event__c>();
            Id promotedShowRecordId = [select Id from RecordType where Name = 'Promoted Show' and SobjectType = 'Event__c'].Id;
            for(Account a : artists){
                Event__c event = new Event__c(
                    ProjectedPaidTickets__c = 20000,
                    ProjectedDropCount__c = 30000,
                    status__c = 'Draft',
                    Venue__c = venue.Id,
                    RecordTypeId = promotedShowRecordId
                );
                primaryHeadlinerEvents.add(event);
            }
            insert primaryHeadlinerEvents;

            //create primary headliner event date times
            primaryHeadlinerEventDateTimes = new List<EventDateTime__c>();
            Integer index = 0;
            for(Event__c e : primaryHeadlinerEvents){
                EventDateTime__c edt = new EventDateTime__c(
                    EventName__c = 'Test Event',
                    EventDate__c = Date.today() + 14,
                    Event__c = e.Id,
                    PrimaryHeadlinerArtist__c = artists[index].Id,
                    Venue__c = venue.Id
                );
                primaryHeadlinerEventDateTimes.add(edt);
            }

            //----------------------------------------------------------------------------------------
            //create rental events
            rentalEvents = new List<Event__c>();
            Id rentalRecordId = [select Id from RecordType where Name = 'Rental' and SobjectType = 'Event__c'].Id;
            for(Account a : artists){
                Event__c event = new Event__c(
                    ProjectedPaidTickets__c = 20000,
                    ProjectedDropCount__c = 30000,
                    status__c = 'Draft',
                    Venue__c = venue.Id,
                    RecordTypeId = rentalRecordId
                );
                rentalEvents.add(event);
            }
            insert rentalEvents;

            //create rental event date times
            rentalEventDateTimes = new List<EventDateTime__c>();
            index = 0;
            for(Event__c e : rentalEvents){
                EventDateTime__c edt = new EventDateTime__c(
                    EventName__c = 'Test Event',
                    EventDate__c = Date.today() + 14,
                    Event__c = e.Id,
                    PrimaryHeadlinerArtist__c = artists[index].Id,
                    Venue__c = venue.Id
                );
                rentalEventDateTimes.add(edt);
                index += 1;
            }
            insert rentalEventDateTimes;

            //TODO: This needs to be moved down the the testMethod, apply adequate and appropriate assertions
            Deal__c testDeal1 = new Deal__c(Type__c='Primary Headliner',  Artist__c = primaryHeadlinerEventDateTimes[0].PrimaryHeadlinerArtist__c, GuaranteeAmount__c = 200, DealType__c = 'Flat', DealCalculation__c = 'Guarantee Only', Event__c = primaryHeadlinerEventDateTimes[0].Event__c, StageType__c = 'Plan');
           	
            insert testDeal1;
            
            Deal__c testDeal2 = new Deal__c(Type__c='Support', Artist__c = rentalEventDateTimes[0].PrimaryHeadlinerArtist__c, GuaranteeAmount__c = 200, DealType__c = 'Flat', DealCalculation__c = 'Guarantee Only', Event__c = rentalEventDateTimes[0].Event__c);
            
            insert testDeal2;
           
        }
        
        public List<EventDateTime__c> typicalSetup(){
            return rentalEventDateTimes;
                
        }
        
        public void finalize(){
        }
    }
    
    //-- test functionality here
    
    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
    static testMethod void testPrimaryHeadliner() {
        TestSettings ts = new TestSettings();
        List<EventDateTime__c> rentalEventDateTimes = ts.typicalSetup();
        
        Test.startTest();
        Deal__c testDeal3 = new Deal__c(Type__c='Support', StageType__c='Plan', Artist__c = rentalEventDateTimes[1].PrimaryHeadlinerArtist__c, GuaranteeAmount__c = 200, DealType__c = 'Flat', DealCalculation__c = 'Guarantee Only', Event__c = rentalEventDateTimes[1].Event__c);
        Deal__c testDeal4 = new Deal__c(Type__c='Support', StageType__c='Settlement', Artist__c = rentalEventDateTimes[1].PrimaryHeadlinerArtist__c, GuaranteeAmount__c = 444, DealType__c = 'Flat', DealCalculation__c = 'Guarantee Only', Event__c = rentalEventDateTimes[1].Event__c);
		insert new List<Deal__c>{testDeal3,testDeal4};
       
        Test.stopTest();
        
        Event__c newEvt1 = [SELECT TotalSupportActExpenses__c, SettlementTotalSupportActExpenses__c FROM Event__c WHERE Id =: rentalEventDateTimes[1].Event__c ];
        System.assertEquals(newEvt1.TotalSupportActExpenses__c, 200);
        System.assertEquals(newEvt1.SettlementTotalSupportActExpenses__c, 444);
    }
}