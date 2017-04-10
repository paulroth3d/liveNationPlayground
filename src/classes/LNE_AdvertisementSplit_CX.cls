/** 
 *	Controller Extension for the LNE_AdvertisementSplit VF page
 *
 *	@author Scott Will
 *  @group Controller
 **/
 public with sharing class LNE_AdvertisementSplit_CX {

	public Advertisement__c masterAdvertisement { get; private set; }

	/**
	 *  Constructor
	 *  @param sc ApexPages.StandardController
	 *  @return n/a
	**/
	public LNE_AdvertisementSplit_CX(ApexPages.StandardController sc) {

		// we need to work from the Master Advertisement's perspective.  if the sc record has
		// a MasterAdForSplit__c value then use that record instead.
		Advertisement__c ad = (Advertisement__c)sc.getRecord();
		Id recordId = ad.MasterAdForSplit__c == null
			? ad.Id
			: ad.MasterAdForSplit__c;

		this.masterAdvertisement = getMasterAdvertisement(recordId);

	}

	/**
	 *  Returns the "master" advertisement record
	 *  @param recordId Id
	 *  @return Advertisement__c - the Master Advertisement
	**/
	private static Advertisement__c getMasterAdvertisement(Id recordId) {
		return [
			select
				AAARate__c,
				AdSize__c,
				AnnouncementType__c,
				ApplyNet__c,
				BuyType__c,
				CalculatedGross__c,
				CampaignType__c,
				Channel__c,
				Commission__c,
				Date__c,
				EffectiveCommission__c,
				EndDate__c,
				EndTime__c,
				ExpenseType__c,
				Format__c,
				FormatSize__c,
				Gross__c,
				HasNonLNEBudget__c,
				Market__c,
				MediaTypeFormat__c,
				Net__c,
				Notes__c,
				NumberofClicks__c,
				NumberofImpressions__c,
				NumberofLocations__c,
				NumberofSpots__c,
				Program__c,
				Rate__c,
				RecordTypeId,
				Section__c,
				SpotType__c,
				StartDate__c,
				StartTime__c,
				Vendor__c,
				Vendor__r.Name
			from Advertisement__c
			where Id = :recordId
		];
	}

	/**
	 *  Returns a package of related Advertisements
	 *  @param masterAdvertisementId Id
	 *  @return AdvertisementPackage
	**/
	@RemoteAction
	public static AdvertisementPackage getRelatedAdvertisements(Id masterAdvertisementId) {

		Decimal netAmount = 0;
		List<Advertisement> advertisements = new List<Advertisement>();
		for (Advertisement__c ad : [
			select
				AdPlan__c,
				AdPlan__r.AdPlanName__c,
				AdPlan__r.Event__r.Status__c,
				AdPlan__r.EventName__c,
				AdPlan__r.PublicOnSale__c,
				AdPlan__r.Venue__c,
				MasterAdForSplit__c,
				CalculatedNet__c,
				SplitAmount__c,
				SplitPct__c,
				Vendor__c,
				(
					select
						AdPlan__c,
						AdPlan__r.AdPlanName__c,
						AdPlan__r.Event__r.Status__c,
						AdPlan__r.EventName__c,
						AdPlan__r.PublicOnSale__c,
						AdPlan__r.Venue__c,
						MasterAdForSplit__c,
						SplitAmount__c,
						SplitPct__c,
						Vendor__c
					from SplitWithAds__r
					order by AdPlan__r.AdPlanName__c
				)
			from Advertisement__c
			where Id = :masterAdvertisementId
		]) {

			// if no children and splitamount is empty then make it ready
			if (ad.SplitAmount__c == null && ad.SplitWithAds__r.isEmpty()) {
				ad.SplitAmount__c = ad.CalculatedNet__c;
				ad.SplitPct__c = 100;
			}
			// add master ad as first item
			advertisements.add(new Advertisement(ad));
			// set expected total
			netAmount = ad.CalculatedNet__c;
			// add ad splits to list
			for (Advertisement__c child : ad.SplitWithAds__r) {
				advertisements.add(new Advertisement(child));				
			}

		}

		return new AdvertisementPackage(advertisements, netAmount);

	}

	/**
	 *  Returns a list of new instances of Advertisements
	 *  @param adplanIdsList Id[] - list of related adplans to associate
	 *  @param masterAdvertisementId Id - the master advertisement
	 *  @return Advertisement[] - list of new Advertisement instances
	**/
	@RemoteAction
	public static List<Advertisement> createAdvertisements(List<Id> adplanIdsList, Id masterAdvertisementId) {

		Advertisement__c masterAdvertisement = getMasterAdvertisement(masterAdvertisementId);
		
		Set<Id> adplanIds = new Set<Id>(adplanIdsList);
		List<Advertisement> advertisements = new List<Advertisement>();
		for (AdPlan__c adplan : [
			select
				AdPlanName__c,
				Event__r.Status__c,
				EventName__c,
				PublicOnSale__c,
				Venue__c
			from AdPlan__c
			where Id in :adplanIds
			order by AdPlanName__c
		]) {
			advertisements.add(new Advertisement(adplan, masterAdvertisement));
		}

		return advertisements;

	}

	/**
	 *  Saves the list of Advertisements to the database
	 *  @param advertisements Advertisement[] - list of advertisements to upsert or delete
	 *  @param masterAdvertisementId - the master advertisement id
	 *  @return Boolean - success of save
	**/
	@RemoteAction
	public static Boolean saveAdvertisements(List<Advertisement> advertisements, Id masterAdvertisementId) {

		Advertisement__c masterAd = getMasterAdvertisement(masterAdvertisementId);

		List<Advertisement__c> upsertAdvertisements = new List<Advertisement__c>();
		List<Advertisement__c> deleteAdvertisements = new List<Advertisement__c>();

		for (Advertisement ad : advertisements) {

			Advertisement__c advertisement = ad.toAdvertisementSObject();
			// if add is not marked deleted
			if (!ad.isDeleted) {
				// if record id is null then copy from master ad
				if (ad.recordId == null) {
					advertisement.AAARate__c = masterAd.AAARate__c; 
					advertisement.AdSize__c = masterAd.AdSize__c; 
					advertisement.AnnouncementType__c = masterAd.AnnouncementType__c; 
					advertisement.ApplyNet__c = masterAd.ApplyNet__c; 
					advertisement.BuyType__c = masterAd.BuyType__c; 
					advertisement.CampaignType__c = masterAd.CampaignType__c; 
					advertisement.Channel__c = masterAd.Channel__c; 
					advertisement.Commission__c = masterAd.Commission__c; 
					advertisement.Date__c = masterAd.Date__c; 
					advertisement.EffectiveCommission__c = masterAd.EffectiveCommission__c; 
					advertisement.EndDate__c = masterAd.EndDate__c;
					advertisement.EndTime__c = masterAd.EndTime__c; 
					advertisement.ExpenseType__c = masterAd.ExpenseType__c; 
					advertisement.Format__c = masterAd.Format__c; 
					advertisement.FormatSize__c = masterAd.FormatSize__c; 
					advertisement.Gross__c = masterAd.Gross__c; 
					advertisement.HasNonLNEBudget__c = masterAd.HasNonLNEBudget__c; 
					advertisement.Market__c = masterAd.Market__c;  
					advertisement.MediaTypeFormat__c = masterAd.MediaTypeFormat__c; 
					advertisement.Net__c = masterAd.Net__c; 
					advertisement.Notes__c = masterAd.Notes__c; 
					advertisement.NumberofClicks__c = masterAd.NumberofClicks__c; 
					advertisement.NumberofImpressions__c = masterAd.NumberofImpressions__c; 
					advertisement.NumberofLocations__c = masterAd.NumberofLocations__c; 
					advertisement.NumberofSpots__c = masterAd.NumberofSpots__c; 
					advertisement.Program__c = masterAd.Program__c; 
					advertisement.Rate__c = masterAd.Rate__c; 
					advertisement.RecordTypeId = masterAd.RecordTypeId;
					advertisement.Section__c = masterAd.Section__c; 
					advertisement.SpotType__c = masterAd.SpotType__c; 
					advertisement.StartDate__c = masterAd.StartDate__c;
					advertisement.StartTime__c = masterAd.StartTime__c; 
					advertisement.Vendor__c = masterAd.Vendor__c;
				}
				upsertAdvertisements.add(advertisement);
			}
			// only remove if it also has a record id
			else if (ad.recordId != null) {
				deleteAdvertisements.add(advertisement);
			}

		}

		Boolean success = true;
		System.savepoint sp = Database.setSavepoint();

		try {
			if (!upsertAdvertisements.isEmpty()) {
				upsert upsertAdvertisements;
			}

			if (!deleteAdvertisements.isEmpty()) {
				// since the front end already updated the master value then
				// dont allow the trigger to do the same
				LNE_AdvertisementSplits_T.RUN_DELETE_ROLLUP = false;
				delete deleteAdvertisements;
			}
		}
		catch (System.DmlException de) {
			Database.rollback(sp);
			success = false;
		}

		return success;

	}

	/**
	 *  Performs the auto assignment.
	 *  @param term String - the search term
	 *  @param ignoredIdsList Id[] - array of adplan ids to ignore
	 *  @return String[] - a formatted list of found Ad Plans
	**/
	@RemoteAction
	public static List<String> searchAdPlans(String term, List<Id> ignoredIdsList) {

		List<String> results = new List<String>();

		if (String.isNotBlank(term)) {

			String fuzzedTerm = '%' + term + '%';
			Set<Id> ignoredIds = new Set<Id>(ignoredIdsList);

			for (AdPlan__c adplan : [
				select
					AdPlanName__c,
					EventName__c
				from AdPlan__c
				where (AdPlanName__c like :fuzzedTerm or EventName__c like :fuzzedTerm)
				and Id not in :ignoredIds
				order by
					EventName__c,
					AdPlanName__c
			]) {

				// result of "recordID|Event Name - AdPlan Name"
				results.add(String.format('{0}|{1} - {2}', new List<String> {
					adplan.Id,
					adplan.EventName__c,
					adplan.AdPlanName__c
				}));

			}

		}

		return results;

	}

	/**
	 *  Wrapper class for Advertisement__c
	**/
	public class Advertisement {

		public Boolean isDeleted { get; set; }
		public Boolean isMaster { get; set; }
		public Decimal splitAmount { get; set; }
		public Decimal splitPct { get; set; }
		public Id masterId { get; set; }
		public Id parentId { get; set; }
		public Id recordId { get; set; }
		public Id vendorId { get; set; }
		public String adPlanName { get; set; }
		public String eventName { get; set; }
		public String eventStatus { get; set; }
		public String onSaleDate { get; set; }
		public String recUrl { get; set; }
		public String venue { get; set; }

		public Advertisement(Advertisement__c ad) {

			this.adPlanName = ad.AdPlan__r.AdPlanName__c;
			this.eventName = ad.AdPlan__r.EventName__c;
			this.eventStatus = ad.AdPlan__r.Event__r.Status__c;
			this.isDeleted = false;
			this.isMaster = ad.MasterAdForSplit__c == null;
			this.masterId = ad.MasterAdForSplit__c;
			this.onSaleDate = safeDateTimeFormat(ad.AdPlan__r.PublicOnSale__c);
			this.parentId = ad.AdPlan__c;
			this.recordId = ad.Id;
			this.recUrl = new ApexPages.StandardController(new AdPlan__c(Id = ad.AdPlan__c)).view().getUrl();
			this.splitAmount = safeDecimal(ad.SplitAmount__c);
			this.splitPct = safeDecimal(ad.SplitPct__c);
			this.venue = ad.AdPlan__r.Venue__c;

		}

		public Advertisement(AdPlan__c adplan, Advertisement__c masterAd) {

			this.adPlanName = adplan.AdPlanName__c;
			this.eventName = adplan.EventName__c;
			this.eventStatus = adplan.Event__r.Status__c;
			this.isDeleted = false;
			this.isMaster = false;
			this.masterId = masterAd.Id;
			this.onSaleDate = safeDateTimeFormat(adplan.PublicOnSale__c);
			this.parentId = adplan.Id;
			this.recordId = null;
			this.recUrl = '';
			this.splitAmount = 0;
			this.splitPct = 0;
			this.venue = adplan.Venue__c;

		}

		public Advertisement__c toAdvertisementSObject() {

			return new Advertisement__c(
				Id = this.recordId,
				AdPlan__c = this.parentId,
				MasterAdForSplit__c = this.masterId,
				SplitAmount__c = this.splitAmount,
				SplitPct__c = this.splitPct
			);

		}

	}

	/**
	 *  Represents a package of advertisements, along with aggregated metadata
	**/
	public class AdvertisementPackage {

		public List<Advertisement> advertisements { get; set; }
		public Decimal originalTotal { get; set; }

		public AdvertisementPackage(List<Advertisement> advertisements, Decimal netAmount) {

			this.advertisements = advertisements;
			this.originalTotal = netAmount == null ? 0 : netAmount;

		}

	}

	private static String safeDateTimeFormat(Date d) {
		return d == null ? '' : d.format();
	}

	private static Decimal safeDecimal(Decimal d) {
		return d == null ? 0 : d;
	}

}