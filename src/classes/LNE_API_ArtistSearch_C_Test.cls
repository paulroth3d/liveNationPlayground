@isTest
private class LNE_API_ArtistSearch_C_Test {
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

        System.assertEquals(LNE_API_ArtistSearch_C.getAPI_Settings().LiveNationAPI_Endpoint__c,'http://api.livenation.com');

        Id artistRecordTypeId = [select Id from RecordType where developername = 'artist' and SobjectType = 'Account'].Id;
        list<Account> artists = [select id from Account where RecordTypeid =: artistRecordTypeId];
        System.assertNotEquals(0, artists.size());

        LNE_API_ArtistSearch_C controller = new LNE_API_ArtistSearch_C();
        Boolean canEdit = LNE_API_ArtistSearch_C.checkIfUserCanEditCurrentRecord(artists[0].id);
        system.assertEquals(true, canEdit);

        Test.startTest();

        Account testAcct = LNE_API_ArtistSearch_C.getArtistById(artists[0].id);
        System.assertNotEquals(null, testAcct);
        System.assertEquals(artists[0].id, testAcct.id);

        List<LNE_API_ArtistSearch_C.ArtistResult> results = LNE_API_ArtistSearch_C.searchArtists('pink');
        system.assertEquals(2, results.size());

        LNE_API_ArtistSearch_C.ArtistResult artist = results[0];

        LNE_API_ArtistSearch_C.setArtistLiveNationId(artists[0].Id, artist.name + '|;|' + artist.id + '|;|' + artist.urlSlug);

        testAcct = [SELECT LNEAPIId__c, LNEAPIName__c, LNEUrlSlug__c FROM Account WHERE Id = :artists[0].Id];
        system.assertEquals('art_51068', testAcct.LNEAPIId__c);
        system.assertEquals('P!NK', testAcct.LNEAPIName__c);
        system.assertEquals('p-nk', testAcct.LNEUrlSlug__c);
    }

}