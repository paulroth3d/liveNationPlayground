/**
 *  Logic for creating various ledger entries
 *  @author Phil Rymek
 **/

public with sharing class LNE_LedgerEntryUtil {
    
    private static final String LEDGER_50499 = '50499';
    private static final String LEDGER_X50148X = 'X50148X';
    private static final String RATE_TYPE_FLAT = 'Flat';

    private static final Id RT_ANCILLARY_ID;
    private static final Id RT_COGS_ID;
    private static final Id RT_CONTRA_ID;
    private static final Id RT_EXPENSES_ID;

    static {

        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new List<String> {
            'LedgerEntry__c.Ancillary',
            'LedgerEntry__c.COGS',
            'LedgerEntry__c.Contra',
            'LedgerEntry__c.Expenses'
        });

        RT_ANCILLARY_ID = recordTypeMap.get('LedgerEntry__c.Ancillary'); 
        RT_COGS_ID = recordTypeMap.get('LedgerEntry__c.COGS'); 
        RT_CONTRA_ID = recordTypeMap.get('LedgerEntry__c.Contra'); 
        RT_EXPENSES_ID = recordTypeMap.get('LedgerEntry__c.Expenses'); 

    }
    
    public static List<LedgerEntry__c> create50499(List<Id> eventIds) {
        List<Event__c> events = getEvents(eventIds);
        return create50499(events);
    }
    
    public static List<LedgerEntry__c> create50499(List<Event__c> events) {

		List<LedgerEntry__c> entries = new List<LedgerEntry__c>();
        GLAccount__c glAccount = getGLAccount(LEDGER_50499);
        Set<Id> cannot50499 = get50499Omissions(events);
        String externalIdDelimiter = 
            DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;
        
        if(glAccount != null) {
            for(Event__c evt : events) {
                if(!cannot50499.contains(evt.Id)) {
                    entries.add(getEntry50499(evt, glACcount, RT_EXPENSES_ID, externalIdDelimiter));
                }
            }          
        }

        upsert entries ExternalId__c;
        return entries;
    }
    
    public static void delete50499(List<Id> eventIds) {
        GLAccount__c glAccount = getGLAccount(LEDGER_50499);
        
        if(glAccount != null) {
            delete [SELECT Id 
                      FROM LedgerEntry__c 
                     WHERE GLAccount__c = :glAccount.Id AND 
                           Event__c in :eventIds];   
        }
    }
    
    public static List<LedgerEntry__c> createX50148X(List<Id> eventIds) {
        List<Event__c> events = getEvents(eventIds);
        return createX50148X(events);
    }
    
    public static List<LedgerEntry__c> createX50148X(List<Event__c> events) {

        GLAccount__c glAccount = getGLAccount(LEDGER_X50148X);
        List<LedgerEntry__c> entries = new List<LedgerEntry__c>();
        String externalIdDelimiter = 
            DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;      
        
        if(glAccount != null) {
            for(Event__c evt : events) {
                entries.add(getEntryX50148X(evt, glACcount, RT_EXPENSES_ID, externalIdDelimiter));
            }          
        }

        upsert entries ExternalId__c;
        return entries;
    }
    
    public static void deleteX50148X(List<Id> eventIds) {
        GLAccount__c glAccount = getGLAccount(LEDGER_X50148X);
        
        if(glAccount != null) {
            List<LedgerEntry__c> toDelete = new List<LedgerEntry__c>();
            List<LedgerEntry__c> toUpdate = new List<LedgerEntry__c>();
            List<LedgerEntry__c> entries =
                [SELECT Id, Event__r.SettlementStarted__c
                   FROM LedgerEntry__c 
                  WHERE GLAccount__c = :glAccount.Id AND Event__c in :eventIds];  
                  
            for(LedgerEntry__c entry : entries) {
                if(entry.Event__r.SettlementStarted__c) {
                    entry.PromoterAmount__c = 0;
                    entry.PromoterAmountRate__c = 0;
                    entry.OfferRate__c = 0;
                    toUpdate.add(entry);
                } else {
                    toDelete.add(entry);
                }
            }
            
            update toUpdate;
            delete toDelete;
        }
    }

    private static LedgerEntry__c getEntryX50148X(Event__c evt, GLAccount__c glAccount, Id recordTypeId, String externalIdDelimiter) {
        return new LedgerEntry__c(
			GLAccount__c = glAccount.Id,
			OfferRateType__c = RATE_TYPE_FLAT,
			SettlementRateType__c = RATE_TYPE_FLAT,
			OfferRate__c = evt.BookingHouseNut__c,
			HouseNut__c = true,
			PromoterAmountRate__c = evt.SettlementHouseNut__c,
			RecordTypeId = recordTypeId,
			Event__c = evt.Id,
            SettleAtActual__c = false,
			ExternalId__c = evt.Name + externalIdDelimiter + glAccount.GLCode__c
        );
    }   
    
    private static LedgerEntry__c getEntry50499(Event__c evt, GLAccount__c glAccount, Id recordTypeId, String externalIdDelimiter) {
        return new LedgerEntry__c(
			GLAccount__c = glAccount.Id,
			OfferRateType__c = RATE_TYPE_FLAT,
			OfferRate__c = evt.AdvertisingBudget__c,
			InHouseRateType__c = RATE_TYPE_FLAT,
            InHouseRate__c = evt.AdvertisingBudget__c,
			RecordTypeId = recordTypeId,
			Event__c = evt.Id,
			ExternalId__c = evt.Name + externalIdDelimiter + glAccount.GLCode__c
        );
    }    
    
    private static List<Event__c> getEvents(List<Id> eventIds) {
        return [SELECT Id,
                       Name,
                       AdvertisingBudget__c,
                       BookingHouseNut__c,
                       SettlementHouseNut__c
                  FROM Event__c
                 WHERE Id in :eventIds];
    }
    
    private static GLAccount__c getGLAccount(String glCode) {
        Map<String,GLAccount__c> codeToAccount = LNE_Util.refreshGLAccountCache();
            
        if(codeToAccount.isEmpty()) {
            return null;
        }
        
        return codeToAccount.get(glCode);
    }
    
    private static Set<Id> get50499Omissions(List<Event__c> events) {
        Set<Id> cannot50499 = new Set<Id>();
        
        List<Advertisement__c> ads = 
            [SELECT AdPlan__r.Event__c 
               FROM Advertisement__c
              WHERE AdPlan__r.Event__c in :events];
              
        List<TourCampaignAdPlan__c> tcaps =
            [SELECT AdPlan__r.Event__c 
               FROM TourCampaignAdPlan__c
              WHERE AdPlan__r.Event__c in :events];
              
        for(Advertisement__c ad : ads) {
            cannot50499.add(ad.AdPlan__r.Event__c);
        }
        
        for(TourCampaignAdPlan__c tcap : tcaps) {
            cannot50499.add(tcap.AdPlan__r.Event__c);
        }
              
        return cannot50499;
    }

    /**
    * Copies various amounts to the Current Flash
    *
    * @param eventId ID - the Id of the parent Event__c record
    **/
    public static void copyToFlash(Id eventId) {

        List<LedgerEntry__c> entries = new List<LedgerEntry__c>();
        for (LedgerEntry__c entry : [
            select 
                COGSAtFlash__c,
                ContraAtFlash__c,
                CurrentFlash__c,
                FlashGrossRevenue__c,
                FlashNetRevenue__c,
                GLAccount__r.Type__c,
                RecordTypeId
            from LedgerEntry__c
            where Event__c = :eventId
            and RecordTypeId in (:RT_ANCILLARY_ID, :RT_COGS_ID, :RT_CONTRA_ID)
        ]) {

            if (entry.RecordTypeId == RT_ANCILLARY_ID) {
                entry.CurrentFlash__c = entry.GLAccount__r.Type__c == 'Contra'
                    ? entry.FlashGrossRevenue__c
                    : entry.FlashNetRevenue__c;
                entries.add(entry);
            }
            else if (entry.RecordTypeId == RT_COGS_ID && hasNonZeroValue(entry.COGSAtFlash__c)) {
                entry.CurrentFlash__c = entry.COGSAtFlash__c;
                entries.add(entry);
            }
            else if (entry.RecordTypeId == RT_CONTRA_ID && hasNonZeroValue(entry.ContraAtFlash__c)) {
                entry.CurrentFlash__c = entry.ContraAtFlash__c;
                entries.add(entry);
            }

        }

        if (!entries.isEmpty()) {
            Database.update(entries, false);
        }

    }

    private static Boolean hasNonZeroValue(Decimal d) {
        return d != null && d != 0;
    }

}