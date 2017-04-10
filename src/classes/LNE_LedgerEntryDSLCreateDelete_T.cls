/**
 *	Trigger logic to create and delete Deal Settlement Ledger records. (US75)
 *	@author John Casimiro
 **/
public with sharing class LNE_LedgerEntryDSLCreateDelete_T {
    private static String RT_COPROMOTER = 'Deal__c.CoPromoter';
    private static String RT_EXPENSES = 'LedgerEntry__c.Expenses';
    private static String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
    private static String RT_COGS = 'LedgerEntry__c.COGS';
    private static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_COPROMOTER, RT_EXPENSES, RT_ANCILLARY, RT_COGS}
    );
    private static Id RT_COPROMOTER_ID = recordTypeMap.get( RT_COPROMOTER );
    private static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    private static Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );
    private static Id RT_COGS_ID = recordTypeMap.get( RT_COGS );
	
	private static EnvironmentIds__c eids = EnvironmentIds__c.getInstance();
    private static String LIVENATIONACCOUNTID = eids.LiveNationAccountID__c;

	/**
     *  Creates Deal Settlement Ledger records on insert of a Ledger Entry
     *  @param newList LedgerEntry__c[]
     *  @param oldMap Map<Id,LedgerEntry__c>
     *  @return LedgerEntry__c[] - list of ledgers updated.
    **/
    
    public static LedgerEntry__c[] execute( LedgerEntry__c[] newList){
    	// loop ledger entries only use where (RT = Expense && settle at actual = false) || RT = Ancillary || RT = COGS
    	set<Id> eventIds = new set<Id>();
        map<Id,Id> eventIdEntryIdMap = new map<Id,Id>();
        List<LedgerEntry__c> filteredEntries = new List<LedgerEntry__c>();
    	for(LedgerEntry__c entry : newList){
    	    if ((entry.RecordTypeId == RT_EXPENSES_ID && entry.SettleAtActual__c == false) || entry.RecordTypeId == RT_ANCILLARY_ID || entry.RecordTypeId == RT_COGS_ID){
    	        eventIds.add(entry.Event__c);
    	        eventIdEntryIdMap.put(entry.Event__c, entry.Id);
    	        filteredEntries.add(entry);
    	    }
    	}
    	
    	// query for deals where RT = Co-Promoter and not Live Nation record.
    	if (eventIds.size() > 0){
    	    List<Deal__c> deals = new List<Deal__c>([select id, event__c from Deal__c where Event__c in :eventIds and RecordTypeId = :RT_COPROMOTER_ID and CoPromoter__c != :LIVENATIONACCOUNTID]);
    	    if (deals.size() > 0 ){
                List<DealSettlementLedger__c> dsls = new List<DealSettlementLedger__c>();
                for (Deal__c d : deals){
                    for (LedgerEntry__c entry : filteredEntries){
                        DealSettlementLedger__c dsl = new DealSettlementLedger__c();
                        dsl.LedgerEntry__c = entry.id;
                        dsl.Deal__c = d.Id;
                        dsl.Share__c = true;
                        dsls.add(dsl);
                    }
                }
    	        insert dsls;
    	    }
    	    
    	    // create DSLs related to entry and deal
    	}
    	
    	return ( null );
    	
    }
    
    /**
     *  Creates Deal Settlement Ledger records on update of a Ledger Entry
     *  @param newList LedgerEntry__c[]
     *  @param oldMap Map<Id,LedgerEntry__c>
     *  @return LedgerEntry__c[] - list of ledgers updated.
    **/
    
    public static LedgerEntry__c[] execute( Map<Id, LedgerEntry__c> newMap, Map<Id, LedgerEntry__c> oldMap){
    	set<Id> createEventIds = new set<Id>();
        map<Id,Id> createEventIdEntryIdMap = new map<Id,Id>();
        set<Id> deleteEntryIds = new set<Id>();
        set<Id> leIds = new set<Id>();
        List<LedgerEntry__c> filteredEntries = new List<LedgerEntry__c>();
        
        //check that dsls exist first
        for(LedgerEntry__c le : newMap.values()){
            if(le.RollUpDealSettlementLedgerCount__c > 0){
                leIds.add(le.Id);
            }
        }
        
        // Make dirty child DSLs to force recalculation (US632)
        if (leIds.size() > 0){
            DealSettlementLedger__c[] childDsls = [select Id from DealSettlementLedger__c where LedgerEntry__c in :leIds];
            if (childDsls.size() > 0){
                update childDsls;
            }
        }
        

        // filter only expenses
    	for(LedgerEntry__c entry : newMap.values()){
    	    if (entry.RecordTypeId == RT_EXPENSES_ID){
    	        if (entry.SettleAtActual__c == false && oldMap.get(entry.Id).SettleAtActual__c == true){ // true => false
    	            createEventIds.add(entry.Event__c);
    	            createEventIdEntryIdMap.put(entry.Event__c, entry.Id);
    	            filteredEntries.add(entry);
    	        } else if (entry.SettleAtActual__c == true && oldMap.get(entry.Id).SettleAtActual__c == false){ // false => true
    	            deleteEntryIds.add(entry.Id);
    	        }
    	    }
    	}
    	
    	// settle at actual from true => false -> create DSLs
    	if (createEventIds.size() > 0){
    	    List<Deal__c> deals = new List<Deal__c>([select id, event__c from Deal__c where Event__c in :createEventIds and RecordTypeId = :RT_COPROMOTER_ID and CoPromoter__c != :LIVENATIONACCOUNTID]);
    	    if (deals.size() > 0 ){
                List<DealSettlementLedger__c> dsls = new List<DealSettlementLedger__c>();
                
                for (Deal__c d : deals){
                    for(LedgerEntry__c entry : filteredEntries){
                        DealSettlementLedger__c dsl = new DealSettlementLedger__c();
                        dsl.LedgerEntry__c = entry.Id;
                        dsl.Deal__c = d.Id;
                        dsl.Share__c = true;
                        dsls.add(dsl);
                    }
                }
                
                if (dsls.size() > 0 )
    	            insert dsls;
    	    }
    	    // create DSLs related to entry and deal
    	}
    	
    	// settle at actual from false => true -> create DSLs
    	if (deleteEntryIds.size() > 0){
    	    List<DealSettlementLedger__c> dsls = new List<DealSettlementLedger__c>([select id from DealSettlementLedger__c where LedgerEntry__c in :deleteEntryIds]);
    	    if (dsls.size() > 0){
    	        delete dsls;
    	    }
    	}
    	
    	return ( null );
    }
    
    /**
     *  Deletes Deal Settlement Ledger records 
     *  @param LedgerEntries[] - list of deleted LedgerEntries.
     *  @return LedgerEntries[] - list of LedgerEntries updated.
    **/
    
     public static LedgerEntry__c[] executeDelete( LedgerEntry__c[] deletedList ){
    	List<LedgerEntry__c> changedLedgers = new List<LedgerEntry__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();

 		for (LedgerEntry__c deletedLedger : deletedList){
 		    if (deletedLedger.Event__c != null) {
            	listOfRelatedEventIds.add(deletedLedger.Event__c);	
            }
            changedLedgers.add(deletedLedger);
 		}
 		
 		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return changedLedgers;
    }
}