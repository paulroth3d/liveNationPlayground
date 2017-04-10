public with sharing class LNE_EventOfferSheet_CX {

	public String selectedDealIds {get;set;}
	public List<Deal__c> deals {get;private set;}

	public List<Schema.FieldSetMember> primaryEarnings {get;private set;}
	public List<Schema.FieldSetMember> primarySummary {get;private set;}
	public List<Schema.FieldSetMember> primaryTopLeft {get;private set;}
	public List<Schema.FieldSetMember> primaryTopRight {get;private set;}
	public List<Schema.FieldSetMember> supportEarnings {get;private set;}
	public List<Schema.FieldSetMember> supportTopLeft {get;private set;}
	public List<Schema.FieldSetMember> supportTopRight {get;private set;}
	
	public LNE_EventOfferSheet_CX(ApexPages.StandardController sc) {
		
		this.selectedDealIds = '';
		this.deals = new List<Deal__c>([
			select
				Artist__r.Name,
				IncludeArtistBonus__c,
				IncludeArtistEarnings__c,
				IncludeBonusWording__c,
				IncludeBreakeven__c,
				IncludeCoHeadliner__c,
				IncludeCoPromoters__c,
				IncludeDeductions__c,
				IncludeEarningsPotentialSection__c,
				IncludeExpenseBreakouts__c,
				IncludeExpenses__c,
				IncludeMarketingNotes__c,
				IncludeMerchDeal__c,
				IncludeNetGrossPotential__c,
				IncludeOfferNotes__c,
				IncludeOfferWording__c,
				IncludePromoterEarnings__c,
				IncludePromotersAddress__c,
				IncludeSummarySection__c,
				IncludeTalentGuarantee__c,
				IncludeTicketScaling__c,
				IncludeTicketScalingMergedTotals__c,
				IncludeToBeSharedAmount__c,
				IncludeTotalTalent__c,
				IncludeVenueNotes__c,
				Type__c
			from Deal__c
			where Event__c = :sc.getId()
			and Type__c in ('Primary Headliner', 'Co-Headliner', 'Support')
			and StageType__c = 'Plan'
			order by 
				TypeSort__c,
				Artist__r.Name
		]);

		initFieldSets();

	}

	public void saveDeals() {

		if (String.isNotBlank(this.selectedDealIds)) {

			Set<Id> dealIds = new Set<Id>((List<Id>)this.selectedDealIds.split(','));
			Map<Id,Deal__c> dealsMap = new Map<Id,Deal__c>(this.deals);
			List<Deal__c> selectedDeals = new List<Deal__c>();

			for (Id dealId : dealIds) {
				if (dealsMap.containsKey(dealId)) {
					selectedDeals.add(dealsMap.get(dealId));
				}
			}

			Database.update(selectedDeals, false);

		}

	}

	private void initFieldSets() {

		RomeFieldSetSettings__c settings = RomeFieldSetSettings__c.getInstance();
		Map<String,Schema.FieldSet> fieldSets = Schema.SObjectType.Deal__c.FieldSets.getMap();

		this.primaryEarnings = fieldSets.get(settings.ArtistOfferPrimaryEarnings__c).getFields();
		this.primarySummary = fieldSets.get(settings.ArtistOfferPrimarySummary__c).getFields();
		this.primaryTopLeft = fieldSets.get(settings.ArtistOfferPrimaryTopLeft__c).getFields();
		this.primaryTopRight = fieldSets.get(settings.ArtistOfferPrimaryTopRight__c).getFields();
		this.supportEarnings = fieldSets.get(settings.ArtistOfferSupportEarnings__c).getFields();
		this.supportTopLeft = fieldSets.get(settings.ArtistOfferSupportTopLeft__c).getFields();
		this.supportTopRight = fieldSets.get(settings.ArtistOfferSupportTopRight__c).getFields();

	}

}