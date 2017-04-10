/**
 *  Class that provides functionality for LNE_AncillaryTab.page
 *
 *  @author Dominic Aveyard <daveyard@salesforce.com>
 *
 **/
global class LNE_FinanceAncillaryTab_CX {
	
	static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';
	static final String RT_COGS = 'LedgerEntry__c.COGS';

	private final SObject parent;
	private final Event__c relatedEvent;

	public Integer ancillaryCount {get;set;}
	public Integer cogCount {get;set;}
	public String eventId {get;set;}
	public Boolean eventNoExpectedAncillaries {get;set;}
	/**
	 *	hideToggle is a flag used by the VF page to know if any error/success messages
	 * 	should be the shown. In other words, was the form just submitted
	 *  TODO: There has to be a better name? even despite the inherint goofiness of naming toggles like this
	 **/
	public Boolean hideToggle {get; set;}

	public Boolean relatedAncillaries {get; set;}
	public Integer relatedAncillariesCount {get; set;}

	private static final GeneralSettings__c GENERAL_SETTINGS = GeneralSettings__c.getInstance();
	public String gridLostFocusPollInterval;

	Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
		new String[]{ RT_Ancillary, RT_COGS }
	);

	public String updateEventSuccess {get;set;}

	Id RT_Ancillary_ID = recordTypeMap.get( RT_Ancillary );
	Id RT_COGS_ID = recordTypeMap.get ( RT_COGS );

	public LNE_FinanceAncillaryTab_CX(ApexPages.StandardController controller){
		parent = controller.getRecord();
		relatedEvent = [SELECT Id FROM Event__c
						WHERE Id = :parent.id];
		hideToggle = true;
		getCountOfRelatedAncillaries();
		getRelatedAncillaries();
	}

	public void getCountOfRelatedAncillaries() {
	  LedgerEntry__c[] ancillaries = new LedgerEntry__c[] {};
	  ancillaries = [SELECT Id FROM LedgerEntry__c WHERE RecordTypeId = :RT_Ancillary_ID AND Event__c = :relatedEvent.Id];

	  ancillaryCount = ancillaries.size();

	  LedgerEntry__c[] cogs = new LedgerEntry__c[] {};
	  cogs = [SELECT Id FROM LedgerEntry__c WHERE RecordTypeId = :RT_COGS_ID AND Event__c = :relatedEvent.Id];

	  cogCount = cogs.size();
	}

	public Boolean determineRelatedAncillaries() {
		Boolean show = false;
		LedgerEntry__c[] exist = new LedgerEntry__c[] {};
		exist = [SELECT Id FROM LedgerEntry__c WHERE RecordTypeId IN (:RT_Ancillary_ID, :RT_COGS_ID) AND Event__c = :relatedEvent.Id];

		if ( exist.size() > 0 ) {
			System.debug('Candy: Ok so there were related ledger entries');
			show = true;
		} else {
		   System.debug('Candy: Ok so there were NO related ledger entries');
		}

		relatedAncillariesCount = exist.size();

		return ( show );
	}

	public Boolean getRelatedAncillaries() {
		relatedAncillaries = determineRelatedAncillaries();
		return ( relatedAncillaries );
	}

	public String getGridLostFocusPollInterval() {
		String res = GENERAL_SETTINGS.Grid_Lost_Focus_Poll_Interval__c;
		return res;
	}

	public Event__c getEvent() {
		return ( relatedEvent );
	}

	public void updateEvent() {
	  try {
		  Event__c evnt = [SELECT Id, NoExpectedAncillaries__c FROM Event__c WHERE Id = :eventId];
		  evnt.NoExpectedAncillaries__c = eventNoExpectedAncillaries;

		  Database.Update(evnt, true);

		  updateEventSuccess = 'true';
	  }
	  catch (DmlException e) {
		  System.debug(e);

		  updateEventSuccess = 'false';
	  }
	}

	@RemoteAction
	global static Boolean copyToFlash(Id eventId) {
		LNE_LedgerEntryUtil.copyToFlash(eventId);
		return true;
	}

}