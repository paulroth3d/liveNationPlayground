public with sharing class LNE_SettlementArtistDealTab_CX {
	private final SObject parent;

	public Event__c eventRecord {get;set;}

	public LNE_SettlementArtistDealTab_CX(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        eventRecord = [SELECT SettlementStarted__c FROM Event__c WHERE Id = :parent.Id];
    }

    public void startSettlement() {
        LNE_SettlementUtil.startSettlementProcess(eventRecord.Id);
    }
}