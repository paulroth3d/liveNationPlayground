/**
*  Class that contains the Logic to calculate fields on the LedgerEntryBreakout__c Object
*     Fields: Gross Revenue, Gross Per Paid, Contra at Forecast, Contra % at Forecast, Net Revenue and Net Per Paid
*  <p>This class should have the least amount of code possible to reduce security concerns.</p>
*  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
**/

public class LNE_CogsBreakoutFieldCalculation {
    
    
    public static final string DELIMITER = DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;
    
    public static final string RATE_TYPE_FLAT = 'Flat';
    public static final string RATE_TYPE_PER_CAP = 'Per Cap';
    
    public static final string TICKET_SCALE_ALL_PAID_TICKETS = 'All Paid Tickets';
    public static final string TICKET_SCALE_ALL_DROP_COUNT = 'All Drop Count';
    public static final string TICKET_SCALE_SELECTED_TICKETS = 'Selected Tickets';
    
    public static final string ERR_NO_RELATED_EVENT = 'No Related Event';
    public static final string ERR_PROJECTED_PAID_TICKETS_NULL = 'Projected Paid Tickets on Related Event is not set';
    public static final string ERR_PROJECTED_DROP_COUNT_NULL = 'Projected Drop Count on Related Event is not set';
    
    class CustomException extends Exception{}
    
    
/**
*  Method to return a Ledger Entry with all updated fields to Grid Buddy
*  @param LedgerEntryBreakout__c
*  @return LedgerEntryBreakout__c
**/
    public static LedgerEntryBreakout__c calculateFieldsOnGrid(LedgerEntryBreakout__c ledgerEntryBreakout){

        System.debug(ledgerEntryBreakout);
        
        //-- handle any fields that are required, but were not blocked prior to coming here.
        if(
            ledgerEntryBreakout.BaseAmount__c == null
        ){
            return( ledgerEntryBreakout );
        }
        
        LedgerEntryBreakout__c savedLedgerEntryBreakout = [SELECT Id, TicketScaleList__c, LedgerEntry__c FROM LedgerEntryBreakout__c WHERE Id =:ledgerEntryBreakout.Id];
        LedgerEntry__c ledgerEntryGL = [SELECT Id, Event__c FROM LedgerEntry__c WHERE Id =:savedLedgerEntryBreakout.LedgerEntry__c];
        List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
        if(savedLedgerEntryBreakout.TicketScaleList__c != null){
           String[] listOfTicketScaleIds = savedLedgerEntryBreakout.TicketScaleList__c.split('\\' + DELIMITER);
            if(Test.isRunningTest()){
                listOfTicketScaleIds = savedLedgerEntryBreakout.TicketScaleList__c.split('\\|');
            }
        	listOfTicketScales = [SELECT Id, ProjectedPaidTickets__c, Comps__c, Event__c FROM TicketScale__c WHERE Id IN :listOfTicketScaleIds];     
        }
        Event__c relatedEvent = [SELECT Id, ProjectedPaidTickets__c, ProjectedDropCount__c FROM Event__c WHERE Id =:ledgerEntryGL.Event__c ];
        
        if( relatedEvent == null ){
            throw( new CustomException( ERR_NO_RELATED_EVENT ));
        } else if( relatedEvent.ProjectedPaidTickets__c == null ){
            throw( new CustomException( ERR_PROJECTED_PAID_TICKETS_NULL ));
        } else if( relatedEvent.ProjectedDropCount__c == null ){
            throw( new CustomException( ERR_PROJECTED_DROP_COUNT_NULL ));
        }
        
        //System.debug('query result ' + listOfTicketScales);
        ledgerEntryBreakout = calculateForecast(ledgerEntryBreakout, listOfTicketScales, relatedEvent);

        System.debug(ledgerEntryBreakout);
        return ledgerEntryBreakout;
    }

/**
*  Method to calculate the forecast field on LedgerEntryBreakout__c Object.
*  @param LedgerEntryBreakout__c, List<TicketScale__c>, Event__c
*  @return LedgerEntryBreakout__c
**/
    public static LedgerEntryBreakout__c calculateForecast(LedgerEntryBreakout__c ledgerEntry, List<TicketScale__c> listOfTicketScales, Event__c relatedEvent){
        
        Decimal ticketRule = 0;
        //If the Rate Type of the Ledger Entry is FLat, then the Gross Revenue is equals to Base Amount.
        if(ledgerEntry.RateType__c == RATE_TYPE_FLAT){
            ledgerEntry.COGSatForecast__c = ledgerEntry.BaseAmount__c;
            
        }
        //If the Rate Type of the Ledger Entry is Per Cap, then the Gross Revenue is calculated applying the ticket scale rule.
        else{
            if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                ledgerEntry.COGSatForecast__c = ledgerEntry.BaseAmount__c * relatedEvent.ProjectedPaidTickets__c;
            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT ){
                ledgerEntry.COGSatForecast__c = ledgerEntry.BaseAmount__c * relatedEvent.ProjectedDropCount__c;
            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                ticketRule = 0;
                for(TicketScale__c ticketScale : listOfTicketScales){
                    if( ticketScale.ProjectedPaidTickets__c != null ){
                        ticketRule += ticketScale.ProjectedPaidTickets__c;
                    }
                }
                ledgerEntry.COGSatForecast__c = ledgerEntry.BaseAmount__c * ticketRule;
            }else{
                ledgerEntry.COGSatForecast__c = ledgerEntry.BaseAmount__c;
            }
            
        }
        
        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        if((ledgerEntry.Min__c != null && ledgerEntry.Min__c > 0) && ledgerEntry.COGSAtForecast__c < ledgerEntry.Min__c){
            ledgerEntry.COGSatForecast__c = ledgerEntry.Min__c;
        }
        if((ledgerEntry.Max__c != null && ledgerEntry.Max__c > 0) && ledgerEntry.COGSAtForecast__c > ledgerEntry.Max__c){
            ledgerEntry.COGSatForecast__c = ledgerEntry.Max__c;
        }
        
        return ledgerEntry;
    }

}