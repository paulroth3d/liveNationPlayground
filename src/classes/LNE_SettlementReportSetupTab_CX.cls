public with sharing class LNE_SettlementReportSetupTab_CX {

	final Event__c event;

	public String selectedDealIds {get;set;}
	public List<Deal__c> deals {get;private set;}

	public List<Schema.FieldSetMember> primaryOptionsLeft {get;private set;}
	public List<Schema.FieldSetMember> primaryOptionsRight {get;private set;}
	public List<Schema.FieldSetMember> supportOptions {get;private set;}

	public LNE_SettlementReportSetupTab_CX(ApexPages.StandardController sc) {
        this.event = (Event__c)sc.getRecord();

        this.selectedDealIds = '';
		this.deals = new List<Deal__c>([
			select
				Artist__r.Name,
				IncludeArtistExpenseColumn__c,
				IncludeBoxOfficeSummary__c,
				IncludeExpenseBreakoutDetails__c,
				IncludeExpenseNotes__c,
				IncludeExpenses__c,
				IncludeLNTouringExpenseColumn__c,
				IncludeMarketingBreakoutDetails__c,
				IncludeOfferExpenseColumn__c,
				IncludePromoterSummary__c,
				IncludeShowSummaryColumn__c,
				IncludeVarianceColumn__c,
				IncludeVenueExpenseColumn__c,
				Type__c
			from Deal__c
			where Event__c = :sc.getId()
			and Type__c in ('Primary Headliner', 'Co-Headliner', 'Support')
			and StageType__c = 'Settlement'
			order by 
				TypeSort__c,
				Artist__r.Name
		]);

		initFieldSets();

    }

    public void startSettlement() {
    	if (this.event != null) {
        	LNE_SettlementUtil.startSettlementProcess(this.event.Id);
    	}
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

		this.primaryOptionsLeft = fieldSets.get(settings.ArtistSettlementPrimaryOptionsLeft__c).getFields();
		this.primaryOptionsRight = fieldSets.get(settings.ArtistSettlementPrimaryOptionsRight__c).getFields();
		this.supportOptions = fieldSets.get(settings.ArtistSettlementSupportOptions__c).getFields();

	}

}