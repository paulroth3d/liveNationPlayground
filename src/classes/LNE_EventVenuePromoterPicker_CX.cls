public with sharing class LNE_EventVenuePromoterPicker_CX {

	private final Id eventId;
	
	public Boolean isLocked {get;set;}
	public String eventOfficeId {get;set;}
	public String eventPromoterId {get;set;}
	public String eventVenueId {get;set;}

	public LNE_EventVenuePromoterPicker_CX(ApexPages.StandardController sc) {
		this.eventId = sc.getId();

		Event__c e = (Event__c)sc.getRecord();
		this.eventOfficeId = e.Office__c;
		this.eventPromoterId = e.Promoter__c;
		this.eventVenueId = e.Venue__c;
	}

	public void checkCanEdit() {
		this.isLocked = !LNE_Util.isEventEditable(this.eventId);
	}

	public void save() {

		try {
			update new Event__c(
				Id = this.eventId,
				Office__c = this.eventOfficeId,
				Promoter__c = this.eventPromoterId,
				Venue__c = this.eventVenueId
			);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Save Complete'));
		}
		catch (System.DmlException de) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getMessage()));
		}

	}

}