@isTest
private class LNE_AdPlanLogic_T_Test {

	class TestSettings {
        public Tour__c testTour;
        public Tour__c testTour2;
        public Event__c testEvent;
        public AdPlan__c testAdPlan;
        public Id tourCampaignRecordTypeMisc;
        public TestSettings(Boolean insertAdPlanBeforeCampaign) {
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue', 'Account.Office', 'Account.Artist', 'Event__c.PromotedShow', 'Event__c.Rental', 'Event__c.Hold', 'TourCampaign__c.Digital'});         
            Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
            Id RT_ACCOUNT_OFFICE_ID = recordTypeMap.get( 'Account.Office' );
            Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );
            Id RT_EVENT_PROMOTEDSHOW_ID = recordTypeMap.get( 'Event__c.PromotedShow' );	
			Id RT_Rental_ID = recordTypeMap.get( 'Event__c.Rental' );
			Id RT_Hold_ID = recordTypeMap.get( 'Event__c.Hold' );
			Id RT_TOUR_CAMPAIGN_DIGITAL = recordTypeMap.get( 'TourCampaign__c.Digital' );
            tourCampaignRecordTypeMisc = recordTypeMap.get('TourCampaign__c.Misc');

			Account artist = LNE_TestObjectFactory.createAccount( 'Artist1' );
			insert artist;

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

			Tour__c tour = new Tour__c();
			tour.TourName__c = 'Test';
			tour.TourHeadliner__c = artist.Id;
			tour.BuyingGroup__c = 'Local Offer';
			insert tour;

			testEvent = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Office__c = office.Id,
                Status__c = 'Draft',
               	RecordTypeId = RT_Rental_ID,
               	Venue__c = venue.Id,
               	Tour__c = tour.Id
            );
            insert testEvent;

			Tour__c tour2 = new Tour__c();
			tour2.TourName__c = 'Test2';
			tour2.TourHeadliner__c = artist.Id;
			tour2.BuyingGroup__c = 'Local Offer';
			insert tour2;

			testTour = tour;
			testTour2 = tour2;

            if(insertAdPlanBeforeCampaign){
                AdPlan__c adPlan = new AdPlan__c(
                    AdPlanName__c = 'Test Ad Plan',
                    LNEAdPlanBudget__c = 1000000,
                    Tour__c = testTour.Id,
                    Event__c = testEvent.Id
                );
                insert adPlan;
                testAdPlan = adPlan;
            }

			TourCampaign__c tc = new TourCampaign__c();
			tc.RecordTypeId = RT_TOUR_CAMPAIGN_DIGITAL;
			tc.Tour__c = tour.Id;
			insert tc;
        }

        public void typicalSetup() {

        }


        public void finalize() {
        }
    }

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    @isTest
    static void test_TourCampaignInsert(){
        TestSettings ts = new TestSettings(true);
        ts.typicalSetup();

        List<TourCampaignAdPlan__c> tcap = [SELECT Id FROM TourCampaignAdPlan__c];
        system.assertEquals(1, tcap.size());
    }

    @isTest
    static void test_TourCampaignUpdateNonLNETourBudget(){
        TestSettings ts = new TestSettings(true);
        ts.typicalSetup();

        List<TourCampaignAdPlan__c> tcap = [SELECT Id, TourCampaign__c FROM TourCampaignAdPlan__c];
        system.assertEquals(1, tcap.size());
        
        TourCampaign__c tc = [select Id, NonLNETourBudget__c, Tour__c from TourCampaign__c where id =: tcap[0].TourCampaign__c];
        NonLNETourBudget__c tb = new NonLNETourBudget__c(
            Tour__c = tc.Tour__c,
            Budget__c = 1000000
        );

        insert tb;

        tc.NonLNETourBudget__c = tb.Id;
        update tc;

        tcap = [SELECT Id, HasNonLNETourBudget__c FROM TourCampaignAdPlan__c where TourCampaign__c =: tc.Id];
        System.assertEquals(tcap[0].HasNonLNETourBudget__c,true);
    }

    @isTest
    static void test_TourCampaignUpdateRecordType(){
        TestSettings ts = new TestSettings(true);
        ts.typicalSetup();

        List<TourCampaignAdPlan__c> tcap = [SELECT Id, TourCampaign__c FROM TourCampaignAdPlan__c];
        system.assertEquals(1, tcap.size());
        
        TourCampaign__c tc = [select Id, RecordTypeId, RecordType.Name from TourCampaign__c where id =: tcap[0].TourCampaign__c];
        System.assertEquals(tc.RecordType.Name,'Digital');

        tc.RecordTypeId = [select Id from RecordType where SObjectType = 'TourCampaign__c' and DeveloperName = 'Misc'].Id;
        update tc;

        tcap = [SELECT Id, TourCampaignType__c FROM TourCampaignAdPlan__c where TourCampaign__c =: tc.Id];
        System.assertEquals(tcap[0].TourCampaignType__c,'Misc');
    }

    @isTest
    static void test_createTourCampaignAdPlanRecordsOnInsert() {
    	TestSettings ts = new TestSettings(false);
        ts.typicalSetup();

        List<TourCampaignAdPlan__c> tcap = [SELECT Id FROM TourCampaignAdPlan__c];
        system.assertEquals(0, tcap.size());

    	Test.startTest();

    	AdPlan__c adPlan = new AdPlan__c(
            AdPlanName__c = 'Test Ad Plan',
            LNEAdPlanBudget__c = 1000000,
            Tour__c = ts.testTour.Id,
            Event__c = ts.testEvent.Id
        );

        insert adPlan;

    	Test.stopTest();

    	tcap = [SELECT Id FROM TourCampaignAdPlan__c];
        system.assertEquals(1, tcap.size());
    }

    @isTest
    static void test_manageTourCampaignAdPlanRecordsOnUpdate() {
    	TestSettings ts = new TestSettings(false);
        ts.typicalSetup();

        List<TourCampaignAdPlan__c> tcap = [SELECT Id FROM TourCampaignAdPlan__c];
        system.assertEquals(0, tcap.size());

    	AdPlan__c adPlan = new AdPlan__c(
            AdPlanName__c = 'Test Ad Plan',
            LNEAdPlanBudget__c = 1000000,
            Tour__c = ts.testTour.Id,
            Event__c = ts.testEvent.Id
        );

        insert adPlan;

    	tcap = [SELECT Id FROM TourCampaignAdPlan__c];
        system.assertEquals(1, tcap.size());

        Test.startTest();

        adPlan.Tour__c = ts.testTour2.Id;
        update adPlan;

        Test.stopTest();

        tcap = [SELECT TourCampaign__c FROM TourCampaignAdPlan__c];
        system.assertEquals(1, tcap.size());
    }
}