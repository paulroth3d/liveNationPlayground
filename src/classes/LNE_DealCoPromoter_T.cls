/** 
 *  Trigger logic to add validation to the CoPromoter(Deal__c) records.
 *  @author John Casimiro
 **/
 public class LNE_DealCoPromoter_T {
    
    /**
    *  Creates Deal Settlement Ledgers when a copromoter record is created.
    *  @param newList Deal__c[]
    *  @param oldMap Map<Id,Deal__c>
    *  @return Deal__c[] - list of ledger entries updated.
    **/
    public static Deal__c[] createDealSettlementLedgers( Deal__c[] newList, Map<Id,Deal__c> oldMap ){
        String RT_COPROMOTER = 'Deal__c.CoPromoter';
        String RT_EXPENSES = 'LedgerEntry__c.Expenses';
        String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
        String RT_COGS = 'LedgerEntry__c.COGS';
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
            new String[]{ RT_COPROMOTER, RT_EXPENSES, RT_ANCILLARY, RT_COGS}
        );
        Id RT_COPROMOTER_ID = recordTypeMap.get( RT_COPROMOTER );
        Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
        Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );
        Id RT_COGS_ID = recordTypeMap.get( RT_COGS );
        
        EnvironmentIds__c eids = EnvironmentIds__c.getInstance();
        String LIVENATIONACCOUNTID = eids.LiveNationAccountID__c;
        
        
        // filter only co-promoter deals
        set<Id> eventIds = new set<Id>();
        //map<Id,Id> eventIdDealIdMap = new map<Id,Id>();
        List<Deal__c> filteredDeals = new List<Deal__c>();
        for(Deal__c d : newList){
            if (d.RecordTypeId == RT_COPROMOTER_ID && d.CoPromoter__c != LIVENATIONACCOUNTID){
                eventIds.add(d.Event__c);
                //eventIdDealIdMap.put(d.Event__c, d.Id);
                filteredDeals.add(d);
            }
        }
        //system.debug('event to deal map = ' + eventIdDealIdMap);
        
        // query for ledger entries where (RT = Expense && settle at actual = false) || RT = Ancillary || RT = COGS && LE.Event = Deal.Event
        if (eventIds.size() >0){
            List<LedgerEntry__c> entries = new List<LedgerEntry__c>([Select Id, Event__c from LedgerEntry__c 
                where Event__c in :eventIds 
                and ((RecordTypeId = :RT_EXPENSES_ID and SettleAtActual__c = false) or RecordTypeId = :RT_ANCILLARY_ID or RecordTypeId = :RT_COGS_ID)]);
            system.debug('entries = ' + entries);  
            
            // if ledger entris exist, create a deal settlement-ledger
            if (entries.size() > 0){
                List<DealSettlementLedger__c> dsls = new List<DealSettlementLedger__c>();
                for(LedgerEntry__c entry : entries){
                    for (Deal__c d : filteredDeals){
                        DealSettlementLedger__c dsl = new DealSettlementLedger__c();
                        dsl.LedgerEntry__c = entry.Id;
                        dsl.Deal__c = d.Id;
                        dsl.share__c = true;
                        system.debug(dsl);
                        dsls.add(dsl);
                    }
                }
                if (dsls.size() > 0)
                    insert dsls;
            }
        }
        
        return ( null );
    }
    
    /**
    *  Prevent delete of Live Nation Co-Promoter Deals for users except system admins
    *  @param newList Deal__c[]
    *  @return Deal__c[] - list of ledger entries updated.
    **/
    public static Deal__c[] checkDeletePermission( Deal__c[] newList){
        GeneralSettings__c gs = GeneralSettings__c.getInstance(UserInfo.getProfileId());
        EnvironmentIds__c eids = EnvironmentIds__c.getInstance();
        String RT_COPROMOTER = 'Deal__c.CoPromoter';
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
            new String[]{ RT_COPROMOTER }
        );
        Id RT_COPROMOTER_ID = recordTypeMap.get( RT_COPROMOTER );
        
        for (Deal__c d : newList){
            if (d.CoPromoter__c != null && d.CoPromoter__c == eids.LiveNationAccountID__c && gs.GlobalDataAdministrator__c != true && d.RecordTypeId == RT_COPROMOTER_ID) {
            	if (LNE_EventDeletionUtil.CURRENTLY_DELETING == false) {
                	d.addError('Only Global Data Administrators are permitted to delete Live Nation Co-Promoter records.');
            	}
            }
        }
        
        return ( newList );
    }
    
    /**
    *  Updates remainder record on delete of a Co-Promoter Deal.
    *  @param newList Deal__c[]
    *  @return Deal__c[] - list of ledger entries updated.
    **/
    public static Deal__c[] updateRemainderOnDelete( Deal__c[] newList){
        system.debug('trigger size = '+ newList.size());
        EnvironmentIds__c eids = EnvironmentIds__c.getInstance();
        String LIVENATIONACCOUNTID = eids.LiveNationAccountID__c;
        String RT_COPROMOTER = 'Deal__c.CoPromoter';
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
            new String[]{ RT_COPROMOTER }
        );
        Id RT_COPROMOTER_ID = recordTypeMap.get( RT_COPROMOTER );
        
        Set<id> eventIds = new set<id>();
        Set<id> processedEventIds = new set<id>();
        Map<id, Deal__c> dealsMap = new map<id, Deal__c>();
        
        for(Deal__c d : newList){
            eventIds.add(d.Event__c);
            dealsMap.put(d.Id, d);
        }
        
        //get Co-Promoter Deals (primary and secondary)
        Map<Id, Event__c> events = new Map<Id, Event__c>([SELECT Id, (SELECT Id, CoPromoter__r.Name, Type__c, Event__c, EventLoss__c, EventProfit__c, ExpenseAdjustmentLoss__c, ExpenseAdjustmentProfit__c, AncillaryRevenue__c, PrimarySecondaryCoPromoter__c FROM Deals__r where recordTypeid = :RT_COPROMOTER_ID) FROM Event__c WHERE Id IN :eventIds]);
        List<Deal__c> updatedList = new List<Deal__c>();
        
        system.debug('events = ' + events);
        
        for(Deal__c d : newList) {
            system.debug('deleted deal = ' + d);
            if (d.recordTypeId != RT_COPROMOTER_ID || processedEventIds.contains(d.Event__r.Id)) {
                continue; // if there are multiple deals deleted on the same Event we only want to run once.
            } else {
                processedEventIds.add(d.Event__r.Id);
            }
            
            Decimal TotalPrimaryEventLoss = 0;
            Decimal TotalPrimaryEventProfit = 0;
            Decimal TotalPrimaryExpenseAdjustmentLoss = 0;
            Decimal TotalPrimaryExpenseAdjustmentProfit = 0;
            Decimal TotalPrimaryAncillaryRevenue = 0;
            Decimal TotalSecondaryEventLoss = 0;
            Decimal TotalSecondaryEventProfit = 0;
            Decimal TotalSecondaryExpenseAdjustmentLoss = 0;
            Decimal TotalSecondaryExpenseAdjustmentProfit = 0;
            Decimal TotalSecondaryAncillaryRevenue = 0;
            
            // calculate totals across all the sibling co-promoter deals
            if (events.size() > 0 ){
                for(Deal__c deal : events.get(d.Event__c).Deals__r){
                    if (deal.PrimarySecondaryCoPromoter__c == 'Primary' && deal.PrimarySecondaryCoPromoter__c != null && deal.CoPromoter__c != LIVENATIONACCOUNTID){
                        system.debug('primary sibling deal = ' + deal);
                        if (deal.EventLoss__c != null) {
                            TotalPrimaryEventLoss += deal.EventLoss__c;
                        }
                        if (deal.EventProfit__c != null) {
                            TotalPrimaryEventProfit += deal.EventProfit__c;
                        }
                        if (deal.ExpenseAdjustmentLoss__c != null) {
                            TotalPrimaryExpenseAdjustmentLoss += deal.ExpenseAdjustmentLoss__c;
                        }
                        if (deal.ExpenseAdjustmentProfit__c != null) {
                            TotalPrimaryExpenseAdjustmentProfit += deal.ExpenseAdjustmentProfit__c;
                        }
                        if (deal.AncillaryRevenue__c != null) {
                            TotalPrimaryAncillaryRevenue += deal.AncillaryRevenue__c;
                        }
                    } else if (deal.PrimarySecondaryCoPromoter__c == 'Secondary' && deal.PrimarySecondaryCoPromoter__c != null && deal.CoPromoter__c != LIVENATIONACCOUNTID) {
                        system.debug('secondary sibling deal = ' + deal);
                        if (deal.EventLoss__c != null) {
                            TotalSecondaryEventLoss += deal.EventLoss__c;
                        }
                        if (deal.EventProfit__c != null) {
                            TotalSecondaryEventProfit += deal.EventProfit__c;
                        }
                        if (deal.ExpenseAdjustmentLoss__c != null) {
                            TotalSecondaryExpenseAdjustmentLoss += deal.ExpenseAdjustmentLoss__c;
                        }
                        if (deal.ExpenseAdjustmentProfit__c != null) {
                            TotalSecondaryExpenseAdjustmentProfit += deal.ExpenseAdjustmentProfit__c;
                        }
                        if (deal.AncillaryRevenue__c != null) {
                            TotalSecondaryAncillaryRevenue += deal.AncillaryRevenue__c;
                        } 
                    }
                } // end loop of deals related to events
                
                // Update Live Nation Co-Promoter Deals
                for(Deal__c deal : events.get(d.Event__c).Deals__r){
                    if (deal.CoPromoter__c != null && deal.CoPromoter__c == LIVENATIONACCOUNTID && deal.PrimarySecondaryCoPromoter__c == 'Primary' && deal.PrimarySecondaryCoPromoter__c != null){
                        deal.EventLoss__c = 100 - TotalPrimaryEventLoss;
                        deal.EventProfit__c = 100 - TotalPrimaryEventProfit;
                        deal.ExpenseAdjustmentLoss__c = 100 - TotalPrimaryExpenseAdjustmentLoss;
                        deal.ExpenseAdjustmentProfit__c = 100 - TotalPrimaryExpenseAdjustmentProfit;
                        deal.AncillaryRevenue__c = 100 - TotalPrimaryAncillaryRevenue;
                        updatedList.add(deal);
                        system.debug('updated primary deal = ' + deal);
                    } else if (deal.CoPromoter__c != null && deal.CoPromoter__c == LIVENATIONACCOUNTID && deal.PrimarySecondaryCoPromoter__c == 'Secondary' && deal.PrimarySecondaryCoPromoter__c != null){
                        deal.EventLoss__c = 100 - TotalSecondaryEventLoss;
                        deal.EventProfit__c = 100 - TotalSecondaryEventProfit;
                        deal.ExpenseAdjustmentLoss__c = 100 - TotalSecondaryExpenseAdjustmentLoss;
                        deal.ExpenseAdjustmentProfit__c = 100 - TotalSecondaryExpenseAdjustmentProfit;
                        deal.AncillaryRevenue__c = 100 - TotalSecondaryAncillaryRevenue;
                        updatedList.add(deal);
                        system.debug('updated secondary deal = ' + deal); 
                    }
                }
            }
            
        } // end loop of trigger.new Deals
  
        if (updatedList.size() > 0 )
            update updatedList;
            
        return ( updatedList );
    }
    
}