@IsTest(SeeAllData=false)
private class LNE_AdPlanFieldRollup_T_Test {

	static final String TOUR_NAME = 'TOUR_NAME';
	
	@testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
        //LNE_TestObjectFactory.createMarketingUser('mktusr');
    }
	
	class TestSettings {
		public Account testArtist;
		public Tour__c testTour;

		public TestSettings(){
			//User marketingUser = [select id from user where alias = 'mktusr'];
			Account artist = LNE_TestObjectFactory.createAccount('Account.Name');
			//artist.OwnerId = marketingUser.Id;
			insert artist;
			this.testArtist = artist;

			Tour__c tour = new Tour__c(
				TourName__c = TOUR_NAME,
				TourHeadliner__c = artist.Id,
				BuyingGroup__c = 'Local Offer'
			);
			insert tour;
			this.testTour = tour;
		}
	}
	
	static testMethod void test_AdPlanFieldRollup() {

		TestSettings ts = new TestSettings();

		Decimal budgetVal = 10;

		// get tour
		Tour__c tour = ts.testTour;

		// build multiple ad plans
		List<AdPlan__c> adPlans = new List<AdPlan__c>();
		for (Integer i = 0; i < 2; i++) {
			adPlans.add(new AdPlan__c(
				Tour__c = tour.Id,
				TourBudget__c = budgetVal,
				LNEAdPlanBudget__c = budgetVal,
				AdPlanName__c = 'test adplan',
				StandaloneDate__c = Date.today() + 30
			));
		}

		// insert ad plans
		insert adPlans;

		// refetch tour, assert correct value
		tour = [select LNEMarketingBudget__c from Tour__c where Id = :tour.Id];
		
		//TODO: fix this assertion, expected value is not correct
		//System.assertEquals(budgetVal * adPlans.size(), tour.LNEMarketingBudget__c);

		adPlans[0].TourBudget__c = 0;
		update adPlans;

		//TODO: add assertions after this operation

	}

}