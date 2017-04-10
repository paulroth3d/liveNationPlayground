@isTest
private class LNE_BonusStartPointValidation_T_Test {
    class TestSettings {
        List<BonusDetail__c> newBonus = new List<BonusDetail__c>();
        Deal__c testDeal1;

    	

        public TestSettings() {

            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue', 'Account.Office', 'Account.Artist', 'Event__c.PromotedShow', 'Event__c.Rental', 'Event__c.Hold'});         
            Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
            Id RT_ACCOUNT_OFFICE_ID = recordTypeMap.get( 'Account.Office' );
            Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );
            Id RT_EVENT_PROMOTEDSHOW_ID = recordTypeMap.get( 'Event__c.PromotedShow' );	
			Id RT_Rental_ID = recordTypeMap.get( 'Event__c.Rental' );
			Id RT_Hold_ID = recordTypeMap.get( 'Event__c.Hold' );
			
			Event__c Evt1;

            GLAccount__c testGlaAcct1 = new GLAccount__c (
                Type__c = 'Ancillary',
                Name = 'Parking Revenue',
                Category__c = 'Other Event Revenue',
                GLCode__c = '12346'
            );
			
			insert testGlaAcct1;            

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
            venue.PrimaryOffice__c = office.id;
            insert venue;
            
            Evt1 = new Event__c(
                ProjectedPaidTickets__c = 50000,
                ProjectedDropCount__c = 50000,
                Status__c = 'Draft',
               	RecordTypeId = RT_Rental_ID,
               	Venue__c = venue.Id
            );
            //insert Evt1;
            LNE_TestObjectFactory.createStandardDataSet( Evt1 );
			System.assertNotEquals(null,Evt1.id);

            Account[] artists = new Account[]{
				LNE_TestObjectFactory.createAccount( 'Artist1' ),
				LNE_TestObjectFactory.createAccount( 'Artist2' ),
                LNE_TestObjectFactory.createAccount( 'Artist3' )
			};
                
           	insert artists;
            System.assertNotEquals(null,artists[0].id);
            System.assertNotEquals(null,artists[1].id);
            System.assertNotEquals(null,artists[2].id);
            
            List<Deal__c> testDealList = new List<Deal__c>([SELECT ID FROM DEAL__C WHERE TYPE__C='Primary Headliner' AND Event__c=:Evt1.Id]);
            testDeal1 = testDealList[0];
            //testDeal1 = new Deal__c(Type__c='Primary Headliner', Artist__c = artists[0].Id, GuaranteeAmount__c = 200, DealType__c = 'Flat', DealCalculation__c = 'Guarantee Only', Event__c = Evt1.Id, StageType__c = 'Plan' );
           	
           // insert testDeal1;
            System.assertNotEquals(null,testDeal1.id);
            
            BonusDetail__c bonusDetail1 = new BonusDetail__c(Deal__c = testDeal1.Id, Type__c = 'Step Up', ApplyTo__c = 'Guarantee', BonusAmount__c = 12, StartPoint__c = 23, EndPoint__c = 33, Increment__c = 1 );
            insert bonusDetail1;
            System.assertNotEquals(null, bonusDetail1.id);
            
            BonusDetail__c bonusDetail2 = new BonusDetail__c(Deal__c = testDeal1.Id, Type__c = 'Step Up', ApplyTo__c = 'Guarantee', BonusAmount__c = 12, StartPoint__c = 25, EndPoint__c = 30, Increment__c = 1 );
            try{
				insert bonusDetail2;            
            } catch(Exception e) {
                System.Debug('bonusDetail2 insert failed '+e);
                System.assert(false);
            }
            System.assertNotEquals(null, bonusDetail2.id);
            
            BonusDetail__c bonusDetail3 = new BonusDetail__c(Deal__c = testDeal1.Id, Type__c = 'Step Up', ApplyTo__c = 'Guarantee', BonusAmount__c = 12, StartPoint__c = 89, EndPoint__c = 91, Increment__c = 1 );
            BonusDetail__c bonusDetail4 = new BonusDetail__c(Deal__c = testDeal1.Id, Type__c = 'Step Up', ApplyTo__c = 'Guarantee', BonusAmount__c = 12, StartPoint__c = 90, EndPoint__c = 95, Increment__c = 1 );
            
            newBonus.add(bonusDetail3);
            newBonus.add(bonusDetail4);
            try {
               insert newBonus;
            } catch(Exception e) {
                System.Debug('newBonus insert failed '+e);
                System.assert(false);
            }
            System.assertNotEquals(null,newBonus[0].id);
            System.assertNotEquals(null,newBonus[1].id);
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
    
    static testMethod void testNewBonus() {
        
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        
        Test.startTest();
        
        Map<Id,BonusDetail__c> oldMap = new Map<Id,BonusDetail__c>();
        
        System.assert(ts.newBonus.size() > 0);
		BonusDetail__c[] results = LNE_BonusStartPointValidation_T.execute(ts.newBonus, oldMap);
   		System.assertNotEquals(0, results.size());
        
        Test.stopTest();
    }

}