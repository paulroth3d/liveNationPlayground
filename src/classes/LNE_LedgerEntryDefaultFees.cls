/**
 * Logic to default the Performing Right Fees on Finance > Event Metrics subtab
 * @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/
 
 public class LNE_LedgerEntryDefaultFees {
     
    public static final string DELIMITER = DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;
    public static final String FOR_SETTLEMENT_EXPENSES = 'for_se';

    public static void defaultFees(String evtId) {
        defaultFees(evtId, null);
    }

    public static void defaultFees(String evtId, String defaultFor) {
        System.debug(evtId);
        
        if(evtId != null && evtId != ''){
            Event__c event = [SELECT EventLastDate__c, 
                                     Name, 
                                     SettlementNetGross__c, 
                                     SettlementAdjustedGross__c,
                                     SettlementGross__c,
                                     SettlementPaidTickets__c,
                                     PaidAttendance__c, 
                                     ActualDropCount__c, 
                                     SelloutDropCount__c, 
                                     Venue__r.BillingCountryCode, 
                                     Venue__r.BillingCountry 
                                FROM Event__c 
                               WHERE Id =:evtId];
                               
            Map<Id,PerformingRightsFee__c> usedPrfIds = new Map<Id,PerformingRightsFee__c>();
            Date eventLastDate = event.EventLastDate__c;
            List<LedgerEntry__c> leToUpsert = new List<LedgerEntry__c>();
            List<LedgerEntryBreakout__c> lebToUpsert = new List<LedgerEntryBreakout__c>();
            Map<String,LedgerEntry__c> breakoutExternalIds = new Map<String,LedgerEntry__c>();
            List<PerformingRightsFee__c> addedPrfs = new List<PerformingRightsFee__c>();
            
            Map<Id, PerformingRightsFee__c> performingRightFeesMap = new Map<Id, PerformingRightsFee__c>(
                [SELECT Id, 
                        Type__c, 
                        RateType__c, 
                        RateAmount__c, 
                        Breakout__c, 
                        Country__c, 
                        CapacityRange__c, 
                        CapacityRangeStart__c,
                        CapacityRangeEnd__c, 
                        GLAccount__r.GLCode__c, 
                        GLAccount__c
                   FROM PerformingRightsFee__c 
                  WHERE StartDate__c <= :eventLastDate AND EndDate__c >= :eventLastDate]);
                  
            Set<String> glAccountCodes = new Set<String>();
            for(PerformingRightsFee__c prf : performingRightFeesMap.values()){
                
                if(prf.Country__c != null && prf.Country__c == event.Venue__r.BillingCountryCode + ' - ' + event.Venue__r.BillingCountry){
     
                    usedPrfIds.put(prf.Id, prf);
                    glAccountCodes.add(usedPrfIds.get(prf.Id).GLAccount__r.GLCode__c);
                    
                }
                
                if(!usedPrfIds.keySet().contains(prf.Id) && prf.CapacityRangeStart__c != null && prf.CapacityRangeStart__c <= event.SelloutDropCount__c && 
                    ( prf.CapacityRangeEnd__c == null || event.SelloutDropCount__c <= prf.CapacityRangeEnd__c)){
                
                    usedPrfIds.put(prf.Id, prf);
                    glAccountCodes.add(usedPrfIds.get(prf.Id).GLAccount__r.GLCode__c);

                }
        
        
                if(!usedPrfIds.keySet().contains(prf.Id) && prf.Country__c == null && prf.CapacityRangeStart__c == null && prf.CapacityRangeEnd__c == null){
                
                    usedPrfIds.put(prf.Id, prf);
                    glAccountCodes.add(usedPrfIds.get(prf.Id).GLAccount__r.GLCode__c);

                }
                
                
                
            }
                                                                                                          
            List<LedgerEntry__c> setExternalIds = 
                [Select Id, 
                        Event__r.Name, 
                        GLAccount__r.GLCode__c, 
                        ExternalId__c, 
                        Description__c 
                   from LedgerEntry__c 
                  where Event__c = :evtId and GLAccount__r.GLCode__c in :glAccountCodes];
                  
            for(LedgerEntry__c le : setExternalIds){
                if(le.ExternalId__c != null)
                    le.ExternalId__c =  le.Event__r.Name + DELIMITER + le.GLAccount__r.GLCode__c;
            }
            
            update setExternalIds;
        
            Set<String> createdLedgers = new Set<String>();
            for(Id prfId : usedPrfIds.keySet()){
                  
                if(usedPrfIds.get(prfId).Breakout__c){
                    LedgerEntry__c addedLe = new LedgerEntry__c(
                        Event__c = evtId, 
                        GLAccount__c = usedPrfIds.get(prfId).GLAccount__c, 
                        ExternalId__c = event.Name + DELIMITER + usedPrfIds.get(prfId).GLAccount__r.GLCode__c, 
                        RecordTypeId = LNE_RT.RT_EXPENSES_ID);
                        
                    if(!createdLedgers.contains(addedLe.ExternalId__c)){
                        leToUpsert.add(addedLe);
                        breakoutExternalIds.put(event.Name + DELIMITER + usedPrfIds.get(prfId).GLAccount__r.GLCode__c, addedLe );
                        createdLedgers.add(addedLe.ExternalId__c);
                    }
                } else {
                    LedgerEntry__c addedLe;
                    
                    if(defaultFor == FOR_SETTLEMENT_EXPENSES) {
                        addedLe = getSettlementExpenseLedgerEntry(evtId, prfId, usedPrfIds, event);
                    } else {
                        addedLe = getFlashLedgerEntry(evtId, prfId, usedPrfIds, event);
                    }
                    
                    leToUpsert.add(addedLe);
                }
            }
            
            System.debug(leToUpsert);
            upsert leToUpsert ExternalId__c;
            
            for(Id prfId : usedPrfIds.keySet()){
                if(usedPrfIds.get(prfId).Breakout__c) {
                    LedgerEntryBreakout__c addedLeb;
                    
                    if(defaultFor == FOR_SETTLEMENT_EXPENSES) {
                        addedLeb = getSettlementExpenseLedgerEntryBreakout(evtId, prfId, usedPrfIds, event, breakoutExternalIds);
                    } else {
                        addedLeb = getFlashLedgerEntryBreakout(evtId, prfId, usedPrfIds, event, breakoutExternalIds);
                    }

                    lebToUpsert.add(addedLeb);
                }   
            }
            
            upsert lebToUpsert ExternalId__c;
        }
    }
    
    private static LedgerEntry__c getFlashLedgerEntry(String evtId, 
                                               Id prfId,
                                               Map<Id,PerformingRightsFee__c> usedPrfIds, 
                                               Event__c event) {
                                                   
        LedgerEntry__c addedLe = new LedgerEntry__c(
            Event__c = evtId, 
            GLAccount__c = usedPrfIds.get(prfId).GLAccount__c, 
            FlashRateType__c = usedPrfIds.get(prfId).RateType__c, 
            FlashRateAmount__c  = usedPrfIds.get(prfId).RateAmount__c, 
            FlashCapacityRange__c = usedPrfIds.get(prfId).CapacityRange__c, 
            FlashOverridden__c = false, 
            ExternalId__c = event.Name + DELIMITER + usedPrfIds.get(prfId).GLAccount__r.GLCode__c, 
            CurrentFlash__c = null, 
            RecordTypeId = LNE_RT.RT_EXPENSES_ID);
        
        return LNE_LedgerCalculateCurrentFlash.calculateCurrentFlashLE(addedLe,event);
    }
    
    
    private static LedgerEntry__c getSettlementExpenseLedgerEntry(String evtId, 
                                                           Id prfId,
                                                           Map<Id,PerformingRightsFee__c> usedPrfIds, 
                                                           Event__c event) {
                                                   
        LedgerEntry__c addedLe = new LedgerEntry__c(
            Event__c = evtId, 
            GLAccount__c = usedPrfIds.get(prfId).GLAccount__c, 
            SettlementRateType__c = usedPrfIds.get(prfId).RateType__c, 
            PromoterAmountRate__c  = usedPrfIds.get(prfId).RateAmount__c, 
            ExternalId__c = event.Name + DELIMITER + usedPrfIds.get(prfId).GLAccount__r.GLCode__c, 
            RecordTypeId = LNE_RT.RT_EXPENSES_ID);
        
        addedLe.PromoterAmount__c = LNE_LedgerCalculateCurrentFlash.getSettlementExpensePromoterAmount(
            event, 
            addedLe.SettlementRateType__c, 
            addedLe.PromoterAmountRate__c);
            
        return LNE_LedgerCalculateCurrentFlash.calculateCurrentFlashLE(addedLe,event);
    }    
    
    private static LedgerEntryBreakout__c getFlashLedgerEntryBreakout(String evtId, 
                                                               Id prfId,
                                                               Map<Id,PerformingRightsFee__c> usedPrfIds, 
                                                               Event__c event,
                                                               Map<String,LedgerEntry__c> breakoutExternalIds) {
                                                                   
        LedgerEntryBreakout__c addedLeb = new LedgerEntryBreakout__c(
            LedgerEntry__c = breakoutExternalIds.get(event.Name +DELIMITER + usedPrfIds.get(prfId).GLAccount__r.GLCode__c).Id, 
            ExternalId__c = event.Name + DELIMITER + usedPrfIds.get(prfId).Type__c,  
            Description__c = usedPrfIds.get(prfId).Type__c, 
            FlashRateType__c = usedPrfIds.get(prfId).RateType__c, 
            FlashRateAmount__c  = usedPrfIds.get(prfId).RateAmount__c, 
            FlashCapacityRange__c = usedPrfIds.get(prfId).CapacityRange__c, 
            CurrentFlash__c = null, 
            FlashOverridden__c = false);
            
        addedLeb.PromoterAmount__c = LNE_LedgerCalculateCurrentFlash.getSettlementExpensePromoterAmount(
            event, 
            addedLeb.SettlementRateType__c, 
            addedLeb.PromoterAmountRate__c);
            
        return addedLeb;
    }    
    
    private static LedgerEntryBreakout__c getSettlementExpenseLedgerEntryBreakout(String evtId, 
                                                                                  Id prfId,
                                                                                  Map<Id,PerformingRightsFee__c> usedPrfIds, 
                                                                                  Event__c event,
                                                                                  Map<String,LedgerEntry__c> breakoutExternalIds) {
                                                                   
        LedgerEntryBreakout__c addedLeb = new LedgerEntryBreakout__c(
            LedgerEntry__c = breakoutExternalIds.get(event.Name +DELIMITER + usedPrfIds.get(prfId).GLAccount__r.GLCode__c).Id, 
            ExternalId__c = event.Name + DELIMITER + usedPrfIds.get(prfId).Type__c,  
            Description__c = usedPrfIds.get(prfId).Type__c, 
            SettlementRateType__c = usedPrfIds.get(prfId).RateType__c, 
            PromoterAmountRate__c  = usedPrfIds.get(prfId).RateAmount__c);
            
        addedLeb.PromoterAmount__c = LNE_LedgerCalculateCurrentFlash.getSettlementExpensePromoterAmount(
            event, 
            addedLeb.SettlementRateType__c, 
            addedLeb.PromoterAmountRate__c);
            
        return addedLeb;
    }
    
    
}