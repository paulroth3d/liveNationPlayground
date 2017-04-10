/**
*  Class that contains the Logic to calculate fields on the LedgerEntry__c Object
*     Fields: Gross Revenue, Gross Per Paid, Contra at Forecast, Contra % at Forecast, Net Revenue and Net Per Paid
*  <p>This class should have the least amount of code possible to reduce security concerns.</p>
*  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
**/

public class LNE_LedgerEntryFieldCalculationLogic {
    
    
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
*  @param LedgerEntry__c
*  @return LedgerEntry__c
**/
    public static LedgerEntry__c calculateFieldsOnGrid(LedgerEntry__c ledgerEntry){
        
        //-- handle any fields that are required, but were not blocked prior to coming here.
        if(
        	ledgerEntry.BaseAmount__c == null
        ){
        	return( ledgerEntry );
        }
        
        LedgerEntry__c savedLedgerEntry = [SELECT Id, TicketScaleList__c, Event__c FROM LedgerEntry__c WHERE Id =:ledgerEntry.Id];
        List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
        if(savedLedgerEntry.TicketScaleList__c != null){
           String[] listOfTicketScaleIds = savedLedgerEntry.TicketScaleList__c.split('\\' + DELIMITER);
            if(Test.isRunningTest()){
                listOfTicketScaleIds = savedLedgerEntry.TicketScaleList__c.split('\\|');
            }
        	listOfTicketScales = [SELECT Id, ProjectedPaidTickets__c, Comps__c, Event__c FROM TicketScale__c WHERE Id IN :listOfTicketScaleIds];     
        }
        Event__c relatedEvent = [SELECT Id, ProjectedPaidTickets__c, ProjectedDropCount__c FROM Event__c WHERE Id =:savedLedgerEntry.Event__c ];
        
        if( relatedEvent == null ){
            throw( new CustomException( ERR_NO_RELATED_EVENT ));
        } else if( relatedEvent.ProjectedPaidTickets__c == null ){
            throw( new CustomException( ERR_PROJECTED_PAID_TICKETS_NULL ));
        } else if( relatedEvent.ProjectedDropCount__c == null ){
            throw( new CustomException( ERR_PROJECTED_DROP_COUNT_NULL ));
        }
        
        ledgerEntry = LNE_FinancialCalculator.calculateGrossRevenue(ledgerEntry, listOfTicketScales, relatedEvent);
        ledgerEntry = LNE_FinancialCalculator.calculateGrossPerPaid(ledgerEntry, relatedEvent);
        ledgerEntry = LNE_FinancialCalculator.calculateContraAtForecast(ledgerEntry, listOfTicketScales, relatedEvent);
        ledgerEntry = LNE_FinancialCalculator.calculateContraPercentAtForecast(ledgerEntry);
        ledgerEntry = LNE_FinancialCalculator.calculateNetRevenue(ledgerEntry);
        ledgerEntry = LNE_FinancialCalculator.calculateNetPerPaid(ledgerEntry, relatedEvent);

        return ledgerEntry;
    }
    
///**
//*  Method to calculate the Gross Revenue field on LedgerEntry__c Object.
//*  @param LedgerEntry__c, List<TicketScale__c>, Event__c
//*  @return LedgerEntry__c
//**/
//    public static LedgerEntry__c calculateGrossRevenue(LedgerEntry__c ledgerEntry, List<TicketScale__c> listOfTicketScales, Event__c relatedEvent){
        
//        Decimal ticketRule = 0;
//        Double BaseAmount = ledgerEntry.BaseAmount__c == null ? 0.0 : ledgerEntry.BaseAmount__c;
//        Double ProjectedPaidTickets = relatedEvent.ProjectedPaidTickets__c == null ? 0.0 : relatedEvent.ProjectedPaidTickets__c;
//        Double ProjectedDropCount = relatedEvent.ProjectedDropCount__c == null ? 0.0 : relatedEvent.ProjectedDropCount__c;

//        //If the Rate Type of the Ledger Entry is FLat, then the Gross Revenue is equals to Base Amount.
//        if(ledgerEntry.RateType__c == RATE_TYPE_FLAT){
//            ledgerEntry.GrossRevenue__c = BaseAmount;
//        }
//        //If the Rate Type of the Ledger Entry is Per Cap, then the Gross Revenue is calculated applying the ticket scale rule.
//        else{
//            if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
//                ledgerEntry.GrossRevenue__c = BaseAmount * ProjectedPaidTickets;
//            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT ){
//                ledgerEntry.GrossRevenue__c = BaseAmount * ProjectedDropCount;
//            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
//                ticketRule = 0;
//                for(TicketScale__c ticketScale : listOfTicketScales){
//                    if( ticketScale.ProjectedPaidTickets__c != null ){
//                        ticketRule += ticketScale.ProjectedPaidTickets__c;
//                    }
//                }
//                ledgerEntry.GrossRevenue__c = BaseAmount * ticketRule;
//            }else{
//                ledgerEntry.GrossRevenue__c = BaseAmount;
//            }
            
//        }
        
//        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
//        if((ledgerEntry.Min__c != null && ledgerEntry.Min__c > 0) && ledgerEntry.GrossRevenue__c <  ledgerEntry.Min__c){
//            ledgerEntry.GrossRevenue__c = ledgerEntry.Min__c;
//        }
//        if((ledgerEntry.Max__c != null && ledgerEntry.Max__c > 0) && ledgerEntry.GrossRevenue__c >  ledgerEntry.Max__c){
//            ledgerEntry.GrossRevenue__c = ledgerEntry.Max__c;
//        }
        
//        return ledgerEntry;
//    }
    
///**
//*  Method to calculate the Gross Per Paid field on LedgerEntry__c Object.
//*  @param LedgerEntry__c, Event__c
//*  @return LedgerEntry__c
//**/
//    public static LedgerEntry__c calculateGrossPerPaid(LedgerEntry__c ledgerEntry, Event__c relatedEvent){
//        Double GrossRevenue = ledgerEntry.GrossRevenue__c == null ? 0.0 : ledgerEntry.GrossRevenue__c;
        
//        //If Projected Paid Tickets = 0, then Gross Per Paid = Gross Revenue / Projected Drop Count otherwise use Projected Paid Tickets
//        if(relatedEvent.ProjectedPaidTickets__c == 0 && relatedEvent.ProjectedDropCount__c != 0){
//            ledgerEntry.GrossPerPaid__c = GrossRevenue / relatedEvent.ProjectedDropCount__c;
//        }else if( relatedEvent.ProjectedPaidTickets__c != 0 ){
//            ledgerEntry.GrossPerPaid__c = GrossRevenue / relatedEvent.ProjectedPaidTickets__c;
//        }
        
//        return ledgerEntry;
//    }
    
///**
//*  Method to calculate the Contra at Forecast field on LedgerEntry__c Object.
//*  @param LedgerEntry__c, List<TicketScale__c>, Event__c
//*  @return LedgerEntry__c
//**/
//    public static LedgerEntry__c calculateContraAtForecast(LedgerEntry__c ledgerEntry, List<TicketScale__c> listOfTicketScales,  Event__c relatedEvent){

//        Decimal ticketRule = 0;
//        Double ContraAmount = ledgerEntry.ContraAmount__c == null ? 0.0 : ledgerEntry.ContraAmount__c;
//        Double GrossRevenue = ledgerEntry.GrossRevenue__c == null ? 0.0 : ledgerEntry.GrossRevenue__c;
//        Double ContraPercent = ledgerEntry.ContraPercent__c == null ? 0.0 : ledgerEntry.ContraPercent__c;
//        Double X3rdPartyPercent = ledgerEntry.X3rdPartyPercent__c == null ? 0.0 : ledgerEntry.X3rdPartyPercent__c;
//        Double ProjectedPaidTickets = relatedEvent.ProjectedPaidTickets__c == null ? 0.0 : relatedEvent.ProjectedPaidTickets__c;
//        Double ProjectedDropCount = relatedEvent.ProjectedDropCount__c == null ? 0.0 : relatedEvent.ProjectedDropCount__c;
        
//        //If the Rate Type of the Ledger Entry is Flat, then the Contra At Forecast = Contra Amount + ((Gross Revenue - Contra Amount) * (Contra % + 3rd Party %))
//        if(ledgerEntry.ContraType__c == RATE_TYPE_FLAT){
//            ledgerEntry.ContraAtForecast__c = ContraAmount + ((GrossRevenue - ContraAmount) * (ContraPercent + X3rdPartyPercent));
//        }
//        //If the Rate Type of the Ledger Entry is Per Cap, then the Contra at Forecast is calculated applying the ticket scale rule.
//        else{
//            if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
//                ledgerEntry.ContraAtForecast__c = (ContraAmount * ProjectedPaidTickets) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ProjectedPaidTickets)));
//            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
//                ledgerEntry.ContraAtForecast__c = (ContraAmount * ProjectedDropCount) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ProjectedDropCount)));
//            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
//                ticketRule = 0;
//                for(TicketScale__c ticketScale : listOfTicketScales){
//                   if( ticketScale.ProjectedPaidTickets__c != null ){
//                        ticketRule += ticketScale.ProjectedPaidTickets__c;
//                   }
//                }
//                ledgerEntry.ContraAtForecast__c = (ContraAmount * ticketRule) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ticketRule)));
//            }else{
//                ledgerEntry.ContraAtForecast__c = ContraAmount;
//            }
            
//        }
//        return ledgerEntry;
        
//    }
///**
//*  Method to calculate the Contra % at Forecast field on LedgerEntry__c Object.
//*  @param LedgerEntry__c
//*  @return LedgerEntry__c
//**/
//    public static LedgerEntry__c calculateContraPercentAtForecast(LedgerEntry__c ledgerEntry){
        
//        if( ledgerEntry != null &&        	  
//        	  ledgerEntry.GrossRevenue__c != null &&
//        	  ledgerEntry.GrossRevenue__c != 0 ) {

//            Double ContraAtForecast = ledgerEntry.ContraAtForecast__c == null ? 0.0 : ledgerEntry.ContraAtForecast__c;
        			
//            ledgerEntry.ContraPercentAtForecast__c = ContraAtForecast / ledgerEntry.GrossRevenue__c;
//        }
        
//        return ledgerEntry;
//    }
    
///**
//*  Method to calculate the Net Revenue field on LedgerEntry__c Object.
//*  @param LedgerEntry__c
//*  @return LedgerEntry__c
//**/
//    public static LedgerEntry__c calculateNetRevenue(LedgerEntry__c ledgerEntry){
        
//        if(ledgerEntry != null) {
//            Double ContraAtForecast = ledgerEntry.ContraAtForecast__c == null ? 0.0 : ledgerEntry.ContraAtForecast__c;
//            Double GrossRevenue = ledgerEntry.GrossRevenue__c == null ? 0.0 : ledgerEntry.GrossRevenue__c;
        
//        	ledgerEntry.NetRevenue__c = GrossRevenue - ContraAtForecast;
//       	}
        
//        return ledgerEntry;
//    }
    
///**
//*  Method to calculate the Net Per Paid field on LedgerEntry__c Object.
//*  @param LedgerEntry__c, Event__c
//*  @return LedgerEntry__c
//**/
//    public static LedgerEntry__c calculateNetPerPaid(LedgerEntry__c ledgerEntry, Event__c relatedEvent){
        
//        if (ledgerEntry != null &&
//        	  relatedEvent != null &&
//        	  relatedEvent.ProjectedPaidTickets__c != null) {

//            Double NetRevenue = ledgerEntry.NetRevenue__c == null ? 0.0 : ledgerEntry.NetRevenue__c;
        	  	
//	        if(relatedEvent.ProjectedPaidTickets__c == 0 &&
//	        	 relatedEvent.ProjectedDropCount__c != null &&
//	             relatedEvent.ProjectedDropCount__c != 0 ) {
	             	
//	            ledgerEntry.NetPerPaid__c = NetRevenue / relatedEvent.ProjectedDropCount__c;
//	        } else if( relatedEvent.ProjectedPaidTickets__c != 0 ) {
	        	
//	            ledgerEntry.NetPerPaid__c = NetRevenue / relatedEvent.ProjectedPaidTickets__c;
//	        }
//        }
        
//        return ledgerEntry;
//    }
    
    
}