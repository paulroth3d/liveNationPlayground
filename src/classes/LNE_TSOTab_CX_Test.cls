@isTest
public class LNE_TSOTab_CX_Test {
	class TestSettings {
    	public Tour__c testTour;
    	public Event__c testEvent;

    	public TestSettings() {
	        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue', 'Account.Office', 'Account.Artist', 'Event__c.PromotedShow', 'Event__c.Rental', 'Event__c.Hold', 'TourCampaign__c.Digital'});         
	        Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
	        Id RT_ACCOUNT_OFFICE_ID = recordTypeMap.get( 'Account.Office' );
	        Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );
	        Id RT_EVENT_PROMOTEDSHOW_ID = recordTypeMap.get( 'Event__c.PromotedShow' );	
			Id RT_Rental_ID = recordTypeMap.get( 'Event__c.Rental' );
			Id RT_Hold_ID = recordTypeMap.get( 'Event__c.Hold' );
			Id RT_TOUR_CAMPAIGN_DIGITAL = recordTypeMap.get( 'TourCampaign__c.Digital' );

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

			testTour = tour;

			TourCampaign__c tc = new TourCampaign__c();
			tc.RecordTypeId = RT_TOUR_CAMPAIGN_DIGITAL;
			tc.Tour__c = tour.Id;
			insert tc;
	    }
	}

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    @isTest
    static void testTSOTab(){
    	TestSettings ts = new TestSettings();
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.testTour);
        LNE_TSOTab_CX cx = new LNE_TSOTab_CX(sc);
        PageReference pr = cx.getTourTotals();

        //TODO: Add Assertions

    }
}