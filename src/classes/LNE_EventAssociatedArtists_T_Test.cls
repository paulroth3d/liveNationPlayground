@isTest
public class LNE_EventAssociatedArtists_T_Test {
    static final String RT_Rental = '';
    static final String RT_Hold = '';
    
    class TestSettings {
        Deal__c[] newDeals;
        Deal__c[] oldDeals;        
        Map<Id, Deal__c> oldDealsMap;
        Account[] artists;
        Event__c Evt1;
        Deal__c testDeal1;
        Deal__c testDeal2;
        Deal__c testDeal3;

        public TestSettings() {
        	
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
        
            //-- global setup here
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue', 'Account.Office', 'Account.Artist', 'Event__c.PromotedShow', 'Event__c.Rental', 'Event__c.Hold', 'Deal__c.Artist'});         
            Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
            Id RT_ACCOUNT_OFFICE_ID = recordTypeMap.get( 'Account.Office' );
            Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );
            Id RT_EVENT_PROMOTEDSHOW_ID = recordTypeMap.get( 'Event__c.PromotedShow' );	
			Id RT_Rental_ID = recordTypeMap.get( 'Event__c.Rental' );
			Id RT_Hold_ID = recordTypeMap.get( 'Event__c.Hold' );
			Id RT_DEAL_ARTIST_ID = recordTypeMap.get( 'Deal__c.Artist' );
            
            newDeals = new List<Deal__c>(); 
            oldDeals = new List<Deal__c>();
            Map<Id, Deal__c> oldDealsMap = new Map<Id, Deal__c>();

            GLAccount__c testGlaAcct1 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12346'
            );
			
			insert testGlaAcct1;
			
			/**
			// create office
            Account office = new LNE_TestObjectFactory(LNE_TestObjectFactory.createAccount('The Office', RT_ACCOUNT_OFFICE_ID)).buildAccount();
            office.Type = 'Geography';
            office.BillingStreet = '123 main st.';
            office.BillingCity = 'chicago';
            office.BillingStateCode = 'IL';
            office.BillingPostalCode = '60654';
            office.BillingCountryCode = 'US';
            office.ShippingStreet = '123 main st.';
            office.ShippingCity = 'chicago';
            office.ShippingStateCode = 'IL';
            office.ShippingPostalCode = '60654';
            office.ShippingCountryCode = 'US';
            insert office;
            */
        
            // create venue
            Account venue = new LNE_TestObjectFactory(LNE_TestObjectFactory.createAccount('The Venue', RT_ACCOUNT_VENUE_ID)).buildAccount();
            venue.BillingStreet = '123 main st.';
            venue.BillingCity = 'chicago';
            venue.BillingStateCode = 'IL';
            venue.BillingPostalCode = '60654';
            venue.BillingCountryCode = 'US';
            venue.ShippingStreet = '123 main st.';
            venue.ShippingCity = 'chicago';
            venue.ShippingStateCode = 'IL';
            venue.ShippingPostalCode = '60654';
            venue.ShippingCountryCode = 'US';
            venue.Market__c = 'Chicago';
            venue.Capacity__c = 100;
            //venue.PrimaryOffice__c = office.id;
            //insert venue;
            
			LNE_TestObjectFactory.VenueHierarchy acctHierarchy = LNE_TestObjectFactory.createVenueHierarchy(
            	LNE_TestObjectFactory.ACCT_TYPE_DIVISION, null, venue
            );
            
            Evt1 = new Event__c(
                ProjectedPaidTickets__c = 50000,
                ProjectedDropCount__c = 50000,
                Status__c = 'Draft',
               	RecordTypeId = RT_Rental_ID,
               	Venue__c = venue.Id,
			    TotalSupportActExpenses__c = 0.0,
			    Office__c = acctHierarchy.division.Id
            );
            insert Evt1;
        
            Account[] artists = new Account[]{
				LNE_TestObjectFactory.createAccount( 'Artist1' ),
				LNE_TestObjectFactory.createAccount( 'Artist2' ),
                LNE_TestObjectFactory.createAccount( 'Artist3' )
			};
                
           	insert artists;
            
            Deal__c testDeal1 = new Deal__c(Type__c='Primary Headliner',
                                            Rank__c = 1,
                                            Artist__c = artists[0].Id,
                                            GuaranteeAmount__c = 200,
                                            DealType__c = 'Flat',
                                            DealCalculation__c = 'Guarantee Only',
                                            Event__c = Evt1.Id,
                                            StageType__c = 'Plan',
                                            RecordTypeId=RT_DEAL_ARTIST_ID);
            insert testDeal1;
            newDeals.add(testDeal1);
            
            Deal__c testDeal2 = new Deal__c(Type__c='Support',
                                            Rank__c = 2,
                                            Artist__c = artists[1].Id,
                                            GuaranteeAmount__c = 200,
                                            DealCalculation__c = 'Guarantee Only',
                                            Event__c = Evt1.Id,
                                            StageType__c = 'Plan',
                                            RecordTypeId=RT_DEAL_ARTIST_ID);
            insert testDeal2;
            newDeals.add(testDeal2);

            Deal__c testDeal3 = new Deal__c(Type__c='Primary Headliner',
                                            Rank__c = 3,
                                            Artist__c = artists[2].Id,
                                            GuaranteeAmount__c = 200,
                                            DealCalculation__c = 'Guarantee Only',
                                            Event__c = Evt1.Id,
                                            StageType__c = 'Settlement',
                                            RecordTypeId=RT_DEAL_ARTIST_ID);
            insert testDeal3;
            newDeals.add(testDeal3);

            Deal__c testDeal4 = new Deal__c(Type__c='Primary Headliner',
                                            Rank__c = 3,
                                            Artist__c = artists[2].Id,
                                            GuaranteeAmount__c = 200,
                                            DealCalculation__c = 'Guarantee Only',
                                            Event__c = Evt1.Id,
                                            StageType__c = 'Plan',
                                            RecordTypeId=RT_DEAL_ARTIST_ID);
            
            try{
                 insert testDeal4;
            }catch(Exception e){
                Boolean expectedExceptionThrown = e.getMessage().contains('You can only select one Primary Headliner per Event.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
        }
        
        public void typicalSetup(){
                
        }
        
        public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
        }
    }
     
    //-- test functionality here

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
    /**
     *  Test: The Artists__c string should be a line break delimited list of all artists involved (via associated deals) in order of deal rank
     */ 
    static testMethod void testInsertPrimaryHeadliner() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        
        Test.startTest();
        List<Deal__c> results = [SELECT Id, Type__c FROM Deal__c WHERE Event__c = :ts.Evt1.Id AND Type__c IN ('Primary Headliner','Support')];
        System.assertEquals(3, results.size());

        Event__c newEvent = [SELECT Artists__c FROM Event__c WHERE Id = :ts.Evt1.Id];
        String expString = 'Artist1\nArtist2';
        System.assertEquals(expString, newEvent.Artists__c);
        Test.stopTest();
    }

}