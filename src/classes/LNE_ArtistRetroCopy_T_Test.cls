@isTest
public class LNE_ArtistRetroCopy_T_Test {

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    @isTest
    static void testArtistRetroFieldsCopied(){

    	LNE_TestObjectFactory.createStandardDataSet();
    	LNE_ArtistRetroCopy_T.execute(null);

    	List<ArtistRetroStepUpDetail__c> detailList = new List<ArtistRetroStepUpDetail__c>();
    	detailList.add(new ArtistRetroStepUpDetail__c());
    	detailList.add(new ArtistRetroStepUpDetail__c());
    	detailList.add(new ArtistRetroStepUpDetail__c());
    	ArtistRetroStepUpDetail__c[] results = new ArtistRetroStepUpDetail__c[]{};
		results = LNE_ArtistRetroCopy_T.execute(detailList);

		//TODO: add assertions to test business logic as needed
		
		for (ArtistRetroStepUpDetail__c ar : results){
		    System.assertEquals(ar.BackendPotentialNonFormula__c, ar.BackendPotential__c);
		    System.assertEquals(ar.ProjectedBackendNonFormula__c, ar.ProjectedBackend__c);
		    System.assertEquals(ar.SettlementBackendNonFormula__c, ar.SettlementBackend__c);
		}
	    
    }
}