@isTest
private class LNE_API_VenueSearch_C_Test {

    class TestSettings {
        
        
        public TestSettings() {
			//-- global setup here
            LNE_TestObjectFactory.createStandardDataSet();
        }
        
        public void typicalSetup(){

        }
		
		public void finalize(){
		}
    }

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
    //-- test test methods here
	
	static testMethod void runSetupAWithoutException() {
        TestSettings ts = new TestSettings();
    	ts.typicalSetup();
    	ts.finalize();

        System.assert( true, 'No Exceptions have occurred in getting here' );
	}
    
   	//-- test functionality here
	
    static testMethod void testScenario() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();

        System.assertEquals(LNE_API_VenueSearch_C.getAPI_Settings().LiveNationAPI_Endpoint__c,'http://api.livenation.com');

        Id venueRecordTypeId = [select Id from RecordType where developername = 'venue' and SobjectType = 'Account'].Id;
        list<Account> venues = [select id from Account where RecordTypeid =: venueRecordTypeId];
        System.assertNotEquals(0, venues.size());

        LNE_API_VenueSearch_C controller = new LNE_API_VenueSearch_C();
        Boolean canEdit = LNE_API_VenueSearch_C.checkIfUserCanEditCurrentRecord(venues[0].id);
        system.assertEquals(true, canEdit);

        Test.startTest();

        Account testAcct = LNE_API_VenueSearch_C.getVenueById(venues[0].id);
        System.assertNotEquals(null, testAcct);
        System.assertEquals(venues[0].id, testAcct.id);

        List<LNE_API_VenueSearch_C.VenueResult> results = LNE_API_VenueSearch_C.searchVenues('Fedex');
        system.assertEquals(1, results.size());

        LNE_API_VenueSearch_C.VenueResult venue = results[0];

        LNE_API_VenueSearch_C.setVenueLiveNationId(venues[0].Id, venue.name + '|;|' + venue.id + '|;|' + venue.urlSlug + '|;|' + venue.hostVenueId + '|;|' + venue.latitude + '|;|' + venue.longitude);

        testAcct = [SELECT LNEAPIId__c, LNEAPIName__c, LNEUrlSlug__c FROM Account WHERE Id = :venues[0].Id];
        system.assertEquals('ven_33251', testAcct.LNEAPIId__c);
        system.assertEquals('FEDEX Field - Lot D Green', testAcct.LNEAPIName__c);
        system.assertEquals('fedex-field-lot-d-green', testAcct.LNEUrlSlug__c);
    }

}