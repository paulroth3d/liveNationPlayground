@isTest
private class LNE_RetroStepUpStartRangeVal_T_Test {

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
    /**
     *  Test: The Artists__c string should be a line break delimited list of all artists involved (via associated deals) in order of deal rank
     */ 
    static testMethod void checkRange() {
		ArtistRetroStepUpDetail__c[] results = new ArtistRetroStepUpDetail__c[]{};

        LNE_TestObjectFactory.createStandardDataSet();

        List<Deal__c> testDeals = [SELECT Id FROM Deal__c];
		System.assertNotEquals(0, testDeals.size());

		ArtistRetroStepUpDetail__c det1 = new ArtistRetroStepUpDetail__c(
			Deal__c = testDeals[0].Id,
			StartingRange__c = 0,
			EndingRange__c = 5
		);
		ArtistRetroStepUpDetail__c det2 = new ArtistRetroStepUpDetail__c(
			Deal__c = testDeals[0].Id,
			StartingRange__c = 6,
			EndingRange__c = 10
		);
		ArtistRetroStepUpDetail__c det3 = new ArtistRetroStepUpDetail__c(
			Deal__c = testDeals[0].Id,
			StartingRange__c = 11,
			EndingRange__c = 15
		);
		ArtistRetroStepUpDetail__c det4 = new ArtistRetroStepUpDetail__c(
			Deal__c = testDeals[0].Id,
			StartingRange__c = 16,
			EndingRange__c = 20
		);
		ArtistRetroStepUpDetail__c det5 = new ArtistRetroStepUpDetail__c(
			Deal__c = testDeals[0].Id,
			StartingRange__c = 21,
			EndingRange__c = 22
		);

		insert det1;
		insert det2;
		insert det3;
		insert det4;
		insert det5;

		List<ArtistRetroStepUpDetail__c> insertedDets = new List<ArtistRetroStepUpDetail__c>();
		insertedDets = [SELECT Id, StartingRange__c, EndingRange__c FROM ArtistRetroStepUpDetail__c WHERE Deal__c = :testDeals[0].Id];
		System.assertEquals(5, insertedDets.size());
        
		Map<Id, ArtistRetroStepUpDetail__c> oldMap = new Map<Id, ArtistRetroStepUpDetail__c>();
		for (ArtistRetroStepUpDetail__c ard : insertedDets) {
			oldMap.put(ard.Id, ard);
		}

		System.assertEquals(5, oldMap.size());

		List<ArtistRetroStepUpDetail__c> newRetros = new List<ArtistRetroStepUpDetail__c>();
		det4.StartingRange__c = 40;
		det4.EndingRange__c = 45;
		det5.StartingRange__c = 50;
		det5.EndingRange__c = 55;
		newRetros.add(det4);
		newRetros.add(det5);

		results = LNE_RetroStepUpStartRangeValidation_T.execute(newRetros, oldMap);
		System.assertEquals(0, results.size());

		// pass in empty new list
		try {
			results = LNE_RetroStepUpStartRangeValidation_T.execute(null, oldMap);
		} catch(DmlException e) {

		}


		// Negative range should fail
/*
		det5.StartingRange__c = -50;
		det5.EndingRange__c = -30;
		try {
			results = LNE_RetroStepUpStartRangeValidation_T.execute(newRetros, oldMap);
		} catch (DmlException e) {
		}	
*/

    }

}