/** 
 *	Trigger to handle management of Advertisement__c splits
 *
 *	@author Scott Will
 *  @group Controller
 **/
 public with sharing class LNE_AdvertisementSplits_T {

	public static Boolean RUN_DELETE_ROLLUP = true;
	
	/**
	 *  runs the delete events
	 *  @param oldAdvertisements Map - map of old advertisements begin removed
	**/
	public static void onDelete(Map<Id,Advertisement__c> oldAdvertisements) {		

		Set<Id> masterIds = new Set<Id>();
		Map<Id,Rollup> rollupValues = new Map<Id,Rollup>();

		for (Advertisement__c ad : oldAdvertisements.values()) {
			// ignore non-split records
			if (ad.IsSplit__c) {
				if (ad.MasterAdForSplit__c == null) {
					// if it's a master then also need to remove the children
					masterIds.add(ad.Id);
				}
				else if (RUN_DELETE_ROLLUP && !oldAdvertisements.containsKey(ad.MasterAdForSplit__c)) {
					// if it's a child then need to move amount to master
					// as long as the master isnt also being deleted
					Rollup r = new Rollup(ad.SplitAmount__c, ad.SplitPct__c);
					if (rollupValues.containsKey(ad.MasterAdForSplit__c)) {
						rollupValues.get(ad.MasterAdForSplit__c).add(r);
					}
					else {
						rollupValues.put(ad.MasterAdForSplit__c, r);
					}
				}
			}

		}

		// do rollups first
		if (!rollupValues.isEmpty()) {

			// for each master ad, rollup values of removed children
			List<Advertisement__c> masters = new List<Advertisement__c>();
			for (Advertisement__c master : [
				select
					SplitAmount__c,
					SplitPct__c
				from Advertisement__c
				where Id in :rollupValues.keySet()
			]) {

				Rollup r = rollupValues.get(master.Id);
				master.SplitAmount__c += r.amount;
				master.SplitPct__c += r.pct;
				masters.add(master);

			}

			update masters;

		}

		if (!masterIds.isEmpty()) {
			// then the master cascading deletes to supress rollups
			RUN_DELETE_ROLLUP = false;
			// delete children who are not also already being deleted
			delete [
				select Id 
				from Advertisement__c 
				where MasterAdForSplit__c in :masterIds 
				and Id not in :oldAdvertisements.keySet()
			];
		}

	}

	/**
	 *  Runs the update events
	 *  @param oldAdvertisements Map - old ads 
	 *  @param newAdvertisements Advertisement__c[] - new ads
	 *  @return Account[] - list of accounts updated.
	**/
	public static void onUpdate(Map<Id,Advertisement__c> oldAdvertisements, List<Advertisement__c> newAdvertisements) {

		// if a master's Net__c changes, then the delta needs to be evenly applied to the children

		// filter to masters with a change to net
		Map<Id,Delta> masters = new Map<Id,Delta>();
		for (Advertisement__c newAd : newAdvertisements) {

			Advertisement__c oldAd = oldAdvertisements.get(newAd.Id);

			if (newAd.IsSplit__c
			 && newAd.MasterAdForSplit__c == null
			) {

				Decimal d = safeDecimal(newAd.CalculatedNet__c) - safeDecimal(oldAd.CalculatedNet__c);
				if (d != 0) {
					newAd.SplitAmount__c += d;
					masters.put(newAd.Id, new Delta(newAd));
				}
			}

		}

		if (!masters.isEmpty()) {

			// retreive children
			for (Advertisement__c child : [
				select
					MasterAdForSplit__c,
					SplitAmount__c,
					SplitPct__c
				from Advertisement__c
				where MasterAdForSplit__c in :masters.keySet()
			]) {
				masters.get(child.MasterAdForSplit__c).ads.add(child);
			}

			Map<Id,Advertisement__c> allads = new Map<Id,Advertisement__c>();
			for (Delta adgroup : masters.values()) {
				adgroup.redistribute();
				allads.putAll(adgroup.ads);
			}

			// remove any records that are in the trigger
			for (Id adId : allads.keySet()) {
				if (oldAdvertisements.containsKey(adId)) {
					allads.remove(adId);
				}
			}

			// update children
			update allads.values();

		}


	}

	private static Decimal safeDecimal(Decimal d) {
		return d == null ? 0 : d;
	}

	private class Delta {

		private Decimal total;
		public List<Advertisement__c> ads { get; private set; }

		public Delta(Advertisement__c master) {
			this.ads = new List<Advertisement__c> { master };
			this.total = master.CalculatedNet__c;
		}

		public void redistribute() {

			for (Advertisement__c ad : this.ads) {
				ad.SplitPct__c = (ad.SplitAmount__c / this.total * 100).setScale(1);
			}

		}

	}

	private class Rollup {

		public Decimal amount {get;set;}
		public Decimal pct {get;set;}

		public Rollup(Decimal amount, Decimal pct) {
			this.amount = safeDecimal(amount);
			this.pct = safeDecimal(pct);
		}

		public void add(Rollup r) {
			this.amount += r.amount;
			this.pct += r.pct;
		}

	}

}