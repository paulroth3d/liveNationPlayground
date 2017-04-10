/**
*  Class that contains the Logic to calculate the Current Flash on the LedgerEntry__c and LedgerEntryBreakout__c Object
*  <p>This class should have the least amount of code possible to reduce security concerns.</p>
*  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
**/
public class LNE_LedgerCalculateCurrentFlash {

    public static final string RATE_TYPE_FLAT = 'Flat';
    public static final string RATE_TYPE_PER_DROP_COUNT = 'Per Drop Count';
    public static final string RATE_TYPE_PER_PAID_TICKET = 'Per Paid Ticket';
    public static final string RATE_TYPE_PERCENTAGE_OF_GROSS = '% of Net Gross';
    public static final string RATE_TYPE_PERCENTAGE_BASE_GROSS = '% of Gross';
    public static final string RATE_TYPE_PERCENTAGE_ADJ_GROSS = '% of Adjusted Gross';
    
    public static final string ERR_NO_RELATED_EVENT = 'No Related Event';
    
    class CustomException extends Exception{}
       
    public static LedgerEntry__c calculateFieldsOnGridLE (LedgerEntry__c ledgerEntry){
        if(ledgerEntry.FlashRateAmount__c == null){
            return ledgerEntry;
        }
        LedgerEntry__c savedLedgerEntry = [SELECT Id, Event__c FROM LedgerEntry__c WHERE Id =:ledgerEntry.Id];
        Event__c relatedEvent = [SELECT Id, SettlementNetGross__c, SettlementPaidTickets__c, PaidAttendance__c, ActualDropCount__c FROM Event__c WHERE Id =:savedLedgerEntry.Event__c ];
        if( relatedEvent == null ){
            throw( new CustomException( ERR_NO_RELATED_EVENT ));
        }

        ledgerEntry = calculateCurrentFlashLE(ledgerEntry, relatedEvent);
        return ledgerEntry;
    }
    
    /**
*  Method to calculate the CurrentFlash on LedgerEntry__c Object.
*  @param LedgerEntryBreakout__c, Event__c
*  @return LedgerEntryBreakout__c
**/
    public static LedgerEntryBreakout__c calculateCurrentFlashLEB(LedgerEntryBreakout__c ledgerEntryBreakout, Event__c relatedEvent){
        Double flashRateAmount = ledgerEntryBreakout.FlashRateAmount__c == null ? 0.0 : ledgerEntryBreakout.FlashRateAmount__c;
        
        if(ledgerEntryBreakout.FlashRateType__c == RATE_TYPE_FLAT){
            ledgerEntryBreakout.CurrentFlash__c = flashRateAmount;
        }
        else{
            if(ledgerEntryBreakout.FlashRateType__c == RATE_TYPE_PER_DROP_COUNT && relatedEvent.ActualDropCount__c != null){
                ledgerEntryBreakout.CurrentFlash__c =  flashRateAmount * relatedEvent.ActualDropCount__c;
            }else if(ledgerEntryBreakout.FlashRateType__c == RATE_TYPE_PER_PAID_TICKET && relatedEvent.PaidAttendance__c != null){
                ledgerEntryBreakout.CurrentFlash__c = flashRateAmount * relatedEvent.PaidAttendance__c;
            }else if(ledgerEntryBreakout.FlashRateType__c == RATE_TYPE_PERCENTAGE_OF_GROSS && relatedEvent.SettlementNetGross__c != null){
                ledgerEntryBreakout.CurrentFlash__c = (flashRateAmount /100)* relatedEvent.SettlementNetGross__c;
            }else{
                ledgerEntryBreakout.CurrentFlash__c = 0;
            }
            
        }
        
        //-- round it to 2 decimal points
        if( ledgerEntryBreakout.CurrentFlash__c != null ){
            ledgerEntryBreakout.CurrentFlash__c = ledgerEntryBreakout.CurrentFlash__c.setScale( 2, RoundingMode.HALF_UP );
        }
        System.debug(ledgerEntryBreakout);
        return ledgerEntryBreakout;
        
    }

    public static LedgerEntryBreakout__c calculateFieldsOnGridLEB (LedgerEntryBreakout__c ledgerEntryBreakout){
        if(ledgerEntryBreakout.FlashRateAmount__c == null){
            return ledgerEntryBreakout;
        }
        
        LedgerEntryBreakout__c savedLedgerEntryBreakout = [SELECT Id, TicketScaleList__c, LedgerEntry__c FROM LedgerEntryBreakout__c WHERE Id =:ledgerEntryBreakout.Id];
        LedgerEntry__c ledgerEntryGL = [SELECT Id, Event__c FROM LedgerEntry__c WHERE Id =:savedLedgerEntryBreakout.LedgerEntry__c];
        Event__c relatedEvent = [SELECT Id, SettlementNetGross__c, SettlementPaidTickets__c, PaidAttendance__c, ActualDropCount__c FROM Event__c WHERE Id =:ledgerEntryGL.Event__c ];
        if( relatedEvent == null ){
            throw( new CustomException( ERR_NO_RELATED_EVENT ));
        }
        
        ledgerEntryBreakout = calculateCurrentFlashLEB(ledgerEntryBreakout, relatedEvent);


        return ledgerEntryBreakout;
    }
    
    /**
*  Method to calculate the CurrentFlash on LedgerEntry__c Object.
*  @param LedgerEntry__c, Event__c
*  @return LedgerEntry__c
**/
    public static LedgerEntry__c calculateCurrentFlashLE(LedgerEntry__c ledgerEntry, Event__c relatedEvent){
        Double flashRateAmount = ledgerEntry.FlashRateAmount__c == null ? 0.0 : ledgerEntry.FlashRateAmount__c;
 
        System.Debug('CurrentFlash Started ' + flashRateAmount + '  ' + ledgerEntry.FlashRateType__c);
        if(ledgerEntry.FlashRateType__c == RATE_TYPE_FLAT){
            ledgerEntry.CurrentFlash__c = flashRateAmount;
        }
        //If the Rate Type of the Ledger Entry is Per Cap, then the Contra at Forecast is calculated applying the ticket scale rule.
        else{
            if(ledgerEntry.FlashRateType__c == RATE_TYPE_PER_DROP_COUNT  && relatedEvent.ActualDropCount__c != null){
                ledgerEntry.CurrentFlash__c =  flashRateAmount * relatedEvent.ActualDropCount__c;
            }else if(ledgerEntry.FlashRateType__c == RATE_TYPE_PER_PAID_TICKET && relatedEvent.PaidAttendance__c != null ){
                ledgerEntry.CurrentFlash__c = flashRateAmount * relatedEvent.PaidAttendance__c;
            }else if(ledgerEntry.FlashRateType__c == RATE_TYPE_PERCENTAGE_OF_GROSS && relatedEvent.SettlementNetGross__c != null){
                ledgerEntry.CurrentFlash__c = (flashRateAmount / 100)* relatedEvent.SettlementNetGross__c;
            }else{
                ledgerEntry.CurrentFlash__c = 0;
            }
            
        }
        
        //-- round it to 2 decimal points
        if( ledgerEntry.CurrentFlash__c != null ){
            ledgerEntry.CurrentFlash__c = ledgerEntry.CurrentFlash__c.setScale( 2, RoundingMode.HALF_UP );
        }
        
        System.debug('CurrentFlash ' +  ledgerEntry.CurrentFlash__c);
        return ledgerEntry;
        
    }
    
    public static Double getSettlementExpensePromoterAmount(Event__c evt, String type, Decimal rateAmount) {
        if(rateAmount == null) {
            return null;
        }

        if(type == RATE_TYPE_PER_DROP_COUNT && evt.ActualDropCount__c != null) {
            return rateAmount * evt.ActualDropCount__c;
        } else if(type == RATE_TYPE_PER_PAID_TICKET && evt.SettlementPaidTickets__c != null) {
            return rateAmount * evt.SettlementPaidTickets__c;
        } else if(type == RATE_TYPE_PERCENTAGE_OF_GROSS && evt.SettlementNetGross__c != null) {
            return rateAmount / 100 * evt.SettlementNetGross__c;
        } else if(type == RATE_TYPE_PERCENTAGE_ADJ_GROSS && evt.SettlementAdjustedGross__c != null) {
            return rateAmount / 100 * evt.SettlementAdjustedGross__c;
        } else if(type == RATE_TYPE_PERCENTAGE_BASE_GROSS && evt.SettlementGross__c != null) {
            return rateAmount / 100 * evt.SettlementGross__c;
        } else if(type == RATE_TYPE_FLAT) {
            return rateAmount;
        }
        
        return null;
    }
}