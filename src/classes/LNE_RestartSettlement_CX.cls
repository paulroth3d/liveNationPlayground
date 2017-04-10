public with sharing class LNE_RestartSettlement_CX {

    @AuraEnabled
    public static void restartSettlement(Id eventId) {
    	LNE_SettlementUtil.restartSettlement(eventId);
    }
}