/**
 *	Trigger logic to rollup the values of child AdPlan__c.TourBudget__c to their parent Tour__c.LNEMarketingBudget__c field
 * 
 *	@author Scott Will
 *	@group Trigger
 **/
 public without sharing class LNE_AdPlanFieldRollup_T {

	/**
	 *	executes the logic of the trigger to rollup the Tour Budget fields to their parent Tour.LNE Marketing Budget
	 *	@param oldMap (Map<Id,AdPlan__c>)
	 *	@param newList (List<AdPlan__c>)
	 *	@return void
	 **/
	public static void execute(Map<Id,AdPlan__c> oldAdPlans, List<AdPlan__c> newAdPlans) {

		Set<Id> tourIds = new Set<Id>();

		// if null then the trigger is not an update, assume empty
		if (oldAdPlans == null) {
			oldAdPlans = new Map<Id,AdPlan__c>();
		}

		for (AdPlan__c newAdPlan : newAdPlans) {

			AdPlan__c oldAdPlan = oldAdPlans.get(newAdPlan.Id);
			// if no old plan (insert|delete) or there was a change
			if (oldAdPlan == null
			 || oldAdPlan.Tour__c != newAdPlan.Tour__c
			 || oldAdPlan.TourBudget__c != newAdPlan.TourBudget__c
			) {
				
				// add both parent Tour Ids

				if (oldAdPlan != null && oldAdPlan.Tour__c != null) {
					tourIds.add(oldAdPlan.Tour__c);
				}

				if (newAdPlan.Tour__c != null) {
					tourIds.add(newAdPlan.Tour__c);
				}

			}

		}

		if (!tourIds.isEmpty()) {

			// for the affected Tours, fetch their current children to get rollup

			List<Tour__c> tours = new List<Tour__c>();
			for (Tour__c tour : [
				select
					LNEMarketingBudget__c,
					(
						select
							TourBudget__c
						from Ad_Plans__r
					)
				from Tour__c
				where Id in :tourIds
			]) {

				Decimal sum = 0;

				// get the sum of child Tour budgets
				for (AdPlan__c adPlan : tour.Ad_Plans__r) {
					sum += adPlan.TourBudget__c != null ? adPlan.TourBudget__c : 0;
				}

				// only update if there is a change
				if (tour.LNEMarketingBudget__c != sum) {
					tour.LNEMarketingBudget__c = sum;
					tours.add(tour);
				}

			}

			// update the affected tours
			if (!tours.isEmpty()) {
				update tours;
			}

		}

	}

}