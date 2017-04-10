/**
 *	Trigger logic to check for changes on any fields that would cause the
 *	financial calculator to fire off
 *	@author Daniel Nakonieczny
 **/
public with sharing class LNE_LedgerEntryBreakoutMetrics_T {
    private static String RT_EXPENSES = 'LedgerEntry__c.Expenses';

    private static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_EXPENSES }
    );

    private static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    
	/**
     *  Checks if any fields changed that would require a recalculation of event totals
     *  @param newList LedgerEntryBreakout__c[]
     *  @param oldMap Map<Id,LedgerEntryBreakout__c>
     *  @return LedgerEntryBreakout__c[] - list of ledgers updated.
    **/
    
    public static LedgerEntryBreakout__c[] execute( LedgerEntryBreakout__c[] newList, Map<Id,LedgerEntryBreakout__c> oldMap ){
    	List<LedgerEntryBreakout__c> changedLedgers = new List<LedgerEntryBreakout__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();
        Set<Id> parentLedgersId = new Set<Id>();
        ChangedLedgerEntryBreakout objChange = null;

 		if (oldMap == null){
            oldMap = new Map<Id, LedgerEntryBreakout__c>();
        }

        for (LedgerEntryBreakout__c newLedger : newList ){
            if(oldMap.containsKey(newLedger.Id)){
                
                LedgerEntryBreakout__c oldLedger = oldMap.get(newLedger.Id);
                objChange = new ChangedLedgerEntryBreakout(oldLedger, newLedger);
                
                if(
                    objChange.notEquals('BaseAmount__c') ||
                    objChange.notEquals('Min__c') ||
                    objChange.notEquals('Max__c') ||
                    objChange.notEquals('ContraAmount__c') ||
                    objChange.notEquals('ContraPercent__c') ||
                    objChange.notEquals('X3rdPartyPercent__c') ||
                    objChange.notEquals('OfferRate__c') ||
                    objChange.notEquals('OfferMin__c') ||
                    objChange.notEquals('OfferMax__c') ||
                    objChange.notEquals('InHouseRate__c') ||
                    objChange.notEquals('InHouseMin__c') ||
                    objChange.notEquals('InHouseMax__c') ||
                    objChange.notEqualsStr('RateType__c', false) ||
                    objChange.notEqualsStr('ContraType__c', false) ||
                    objChange.notEqualsStr('ApplyTicketScale__c', false) ||
                    objChange.notEqualsStr('TicketScaleList__c', false) ||
                    objChange.notEqualsStr('OfferRateType__c', false) ||
                    objChange.notEqualsStr('InHouseRateType__c', false)
                ) {
                    if (objChange.getNewLedgerEntryBreakout().LedgerEntry__c != null) {
                        parentLedgersId.add(objChange.getNewLedgerEntryBreakout().LedgerEntry__c);  
                    }

                    changedLedgers.add(objChange.getNewLedgerEntryBreakout());
                  }

                processSettlementLedger(objChange);
            } else {
                if (newLedger.LedgerEntry__c != null) {
                    parentLedgersId.add(newLedger.LedgerEntry__c);  
                }
                changedLedgers.add(newLedger);
            }
        }

        if (!parentLedgersId.isEmpty()) {
            List<LedgerEntry__c> parentLedgers = [SELECT Id, Event__c FROM LedgerEntry__c WHERE Id IN :parentLedgersId];

            for (LedgerEntry__c newLedger : parentLedgers ){
                  listOfRelatedEventIds.add(newLedger.Event__c);
            }

            LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);
        }

		return changedLedgers;
    }

    /**
     *  Sets Settle at Actual to true if parent Event__r.AdvertisingSettlementPlan__c is Settle at Actual
     *  SHOULD ONLY RUN BEFORE INSERT
     *  @param newList LedgerEntryBreakout__c[]]
    **/
    public static void checkSettleAtActual(LedgerEntryBreakout__c[] newList) {
        for (LedgerEntryBreakout__c newLedger : newList ) {
            if (newLedger.ParentRecordTypeID__c == RT_EXPENSES_ID && String.isNotBlank(newLedger.EventAdvertisingSettlementPlan__c) && newLedger.Category__c == 'Advertising Expense') {
                if (newLedger.EventAdvertisingSettlementPlan__c == 'Settle at Actual' && newLedger.SettleAtActual__c == false) {
                    newLedger.SettleAtActual__c = true;
                }
                
                if (newLedger.EventAdvertisingSettlementPlan__c == 'Settle at Offer' && newLedger.SettleAtActual__c == true) {
                    newLedger.SettleAtActual__c = false;
                }
            }
        }
    }

    private static void processSettlementLedger(ChangedLedgerEntryBreakout ledger) {
        List<String> fieldsToCheck = new List<String>{'PromoterAmount','ArtistAmount','VenueAmount','LNTouringAmount'};
        Boolean settlementRateTypeChanged = ledger.notEqualsStr('SettlementRateType__c', true);

        for (String field : fieldsToCheck) {
            if (ledger.notEquals(field+'__c') && ledger.equals(field+'Rate__c') && settlementRateTypeChanged == false) {
                populateSettlementValue(ledger.getNewLedgerEntryBreakout(), field);
            }
        }
    }

    private static void populateSettlementValue(LedgerEntryBreakout__c l, String fieldName) {
        String source = fieldName + '__c';
        String destination = fieldName + 'Rate__c';
        l.put(destination, l.get(source));
        l.SettlementRateType__c = 'Flat';
    }

    /**
     *  Internal class to represent the changes from the object.
    **/
    class ChangedLedgerEntryBreakout extends LNE_SObjectChange {
        
        ChangedLedgerEntryBreakout( LedgerEntryBreakout__c oldObject, LedgerEntryBreakout__c newObject ){
            super( oldObject, newObject );
        }
        
        LedgerEntryBreakout__c getNewLedgerEntryBreakout(){
            return( (LedgerEntryBreakout__c)this.newObject );
        }
    }
    
}