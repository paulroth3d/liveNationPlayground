public with sharing class LNE_BlockLedgerEntryBreakoutDelete_T {
	/**
    *  Prevents the delete of a Ledger Entry Breakout if it has OfferRate__c or InHouseRate__c
    *  populated and the related Event__r.SettlementStarted__c = true
    *  @param newList LedgerEntryBreakout__c[]
    *  @return LedgerEntryBreakout__c[] - list of ledger entries updated.
    **/
    public static LedgerEntryBreakout__c[] execute( LedgerEntryBreakout__c[] newList){
        
        List<Id> associatedParentIds = new List<Id>();
        for (LedgerEntryBreakout__c le : newList){
            associatedParentIds.add(le.LedgerEntry__c);
        }
        
        Map<Id,LedgerEntry__c> parents = new Map<Id,LedgerEntry__c>([SELECT Event__c, Event__r.SettlementStarted__c FROM LedgerEntry__c WHERE Id =: associatedParentIds ]);
        
        for (LedgerEntryBreakout__c le : newList){

            if (parents.get(le.LedgerEntry__c) != null &&
            	parents.get(le.LedgerEntry__c).Event__c != null &&
                    (le.OfferRate__c != null && le.OfferRate__c != 0) ||
                    (le.InHouseRate__c != null && le.InHouseRate__c != 0)) {

                if (parents.get(le.LedgerEntry__c).Event__r.SettlementStarted__c != null &&
                    parents.get(le.LedgerEntry__c).Event__r.SettlementStarted__c == true) {
                    le.addError('Cannot delete this Ledger Entry Breakout because the Settlement process has started on the Event');
                }
            }
        }
        
        return ( newList );
    }
}