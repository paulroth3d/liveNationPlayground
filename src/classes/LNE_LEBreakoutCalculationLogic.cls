/**
*  Class that contains the Logic to calculate fields on the LedgerEntryBreakout__c Object
*     Fields: Gross Revenue, Gross Per Paid, Contra at Forecast, Contra % at Forecast, Net Revenue and Net Per Paid
*  <p>This class should have the least amount of code possible to reduce security concerns.</p>
*  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
**/

public class LNE_LEBreakoutCalculationLogic {
    
    
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
*  Method to return a Ledger Entry Breakout with all updated fields to Grid Buddy
*  @param LedgerEntry__c
*  @return LedgerEntry__c
**/
    public static LedgerEntryBreakout__c calculateFieldsOnGrid(LedgerEntryBreakout__c ledgerEntryBreakout){
        
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
        
        ledgerEntryBreakout = LNE_FinancialCalculator.calculateGrossRevenue(ledgerEntryBreakout, listOfTicketScales, relatedEvent);
        ledgerEntryBreakout = LNE_FinancialCalculator.calculateGrossPerPaid(ledgerEntryBreakout, relatedEvent);
        ledgerEntryBreakout = LNE_FinancialCalculator.calculateContraAtForecast(ledgerEntryBreakout, listOfTicketScales, relatedEvent);
        ledgerEntryBreakout = LNE_FinancialCalculator.calculateContraPercentAtForecast(ledgerEntryBreakout);
        ledgerEntryBreakout = LNE_FinancialCalculator.calculateNetRevenue(ledgerEntryBreakout);
        ledgerEntryBreakout = LNE_FinancialCalculator.calculateNetPerPaid(ledgerEntryBreakout, relatedEvent);

        return ledgerEntryBreakout;
    }
    
///**
//*  Method to calculate the Gross Revenue field on ledgerEntryBreakout__c Object.
//*  @param ledgerEntryBreakout__c, List<TicketScale__c>, Event__c
//*  @return ledgerEntryBreakout__c
//**/
//    public static LedgerEntryBreakout__c calculateGrossRevenue(LedgerEntryBreakout__c ledgerEntryBreakout, List<TicketScale__c> listOfTicketScales, Event__c relatedEvent){
        
//        Decimal ticketRule = 0;
//        Double BaseAmount = ledgerEntryBreakout.BaseAmount__c == null ? 0.0 : ledgerEntryBreakout.BaseAmount__c;
//        Double ProjectedPaidTickets = relatedEvent.ProjectedPaidTickets__c == null ? 0.0 : relatedEvent.ProjectedPaidTickets__c;
//        Double ProjectedDropCount = relatedEvent.ProjectedDropCount__c == null ? 0.0 : relatedEvent.ProjectedDropCount__c;

//        //If the Rate Type of the Ledger Entry is FLat, then the Gross Revenue is equals to Base Amount.
//        if(ledgerEntryBreakout.RateType__c == RATE_TYPE_FLAT){
//            ledgerEntryBreakout.GrossRevenue__c = BaseAmount;
//        }
//        //If the Rate Type of the Ledger Entry is Per Cap, then the Gross Revenue is calculated applying the ticket scale rule.
//        else{
//            if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
//                ledgerEntryBreakout.GrossRevenue__c = BaseAmount * ProjectedPaidTickets;
//            }else if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT ){
//                ledgerEntryBreakout.GrossRevenue__c = BaseAmount * ProjectedDropCount;
//            }else if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
//                ticketRule = 0;
//                for(TicketScale__c ticketScale : listOfTicketScales){
//                    if( ticketScale.ProjectedPaidTickets__c != null ){
//                        ticketRule += ticketScale.ProjectedPaidTickets__c;
//                    }
//                }
//                ledgerEntryBreakout.GrossRevenue__c = BaseAmount * ticketRule;
//            }else{
//                ledgerEntryBreakout.GrossRevenue__c = BaseAmount;
//            }
            
//        }
        
//        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
//        if((ledgerEntryBreakout.Min__c != null && ledgerEntryBreakout.Min__c > 0) && ledgerEntryBreakout.GrossRevenue__c <  ledgerEntryBreakout.Min__c){
//            ledgerEntryBreakout.GrossRevenue__c = ledgerEntryBreakout.Min__c;
//        }
//        if((ledgerEntryBreakout.Max__c != null && ledgerEntryBreakout.Max__c > 0) && ledgerEntryBreakout.GrossRevenue__c >  ledgerEntryBreakout.Max__c){
//            ledgerEntryBreakout.GrossRevenue__c = ledgerEntryBreakout.Max__c;
//        }
        
//        return ledgerEntryBreakout;
//    }
    
///**
//*  Method to calculate the Gross Per Paid field on LedgerEntryBreakout__c Object.
//*  @param LedgerEntryBreakout__c, Event__c
//*  @return LedgerEntryBreakout__c
//**/
//    public static LedgerEntryBreakout__c calculateGrossPerPaid(LedgerEntryBreakout__c ledgerEntryBreakout, Event__c relatedEvent){
//        Double GrossRevenue = ledgerEntryBreakout.GrossRevenue__c == null ? 0.0 : ledgerEntryBreakout.GrossRevenue__c;
        
//        //If Projected Paid Tickets = 0, then Gross Per Paid = Gross Revenue / Projected Drop Count otherwise use Projected Paid Tickets
//        if(relatedEvent.ProjectedPaidTickets__c == 0 && relatedEvent.ProjectedDropCount__c != 0){
//            ledgerEntryBreakout.GrossPerPaid__c = GrossRevenue / relatedEvent.ProjectedDropCount__c;
//        }else if( relatedEvent.ProjectedPaidTickets__c != 0 ){
//            ledgerEntryBreakout.GrossPerPaid__c = GrossRevenue / relatedEvent.ProjectedPaidTickets__c;
//        }
        
//        return ledgerEntryBreakout;
//    }
    
///**
//*  Method to calculate the Contra at Forecast field on LedgerEntryBreakout__c Object.
//*  @param LedgerEntryBreakout__c, List<TicketScale__c>, Event__c
//*  @return LedgerEntryBreakout__c
//**/
//    public static LedgerEntryBreakout__c calculateContraAtForecast(LedgerEntryBreakout__c ledgerEntryBreakout, List<TicketScale__c> listOfTicketScales,  Event__c relatedEvent){
        
//        Decimal ticketRule = 0;
//        Double ContraAmount = ledgerEntryBreakout.ContraAmount__c == null ? 0.0 : ledgerEntryBreakout.ContraAmount__c;
//        Double GrossRevenue = ledgerEntryBreakout.GrossRevenue__c == null ? 0.0 : ledgerEntryBreakout.GrossRevenue__c;
//        Double ContraPercent = ledgerEntryBreakout.ContraPercent__c == null ? 0.0 : ledgerEntryBreakout.ContraPercent__c;
//        Double X3rdPartyPercent = ledgerEntryBreakout.X3rdPartyPercent__c == null ? 0.0 : ledgerEntryBreakout.X3rdPartyPercent__c;
//        Double ProjectedPaidTickets = relatedEvent.ProjectedPaidTickets__c == null ? 0.0 : relatedEvent.ProjectedPaidTickets__c;
//        Double ProjectedDropCount = relatedEvent.ProjectedDropCount__c == null ? 0.0 : relatedEvent.ProjectedDropCount__c;

//        //If the Rate Type of the Ledger Entry is Flat, then the Contra At Forecast = Contra Amount + ((Gross Revenue - Contra Amount) * (Contra % + 3rd Party %))
//        if(ledgerEntryBreakout.ContraType__c == RATE_TYPE_FLAT){
//            ledgerEntryBreakout.ContraAtForecast__c = ContraAmount + ((GrossRevenue - ContraAmount) * (ContraPercent + X3rdPartyPercent));
//        }
//        //If the Rate Type of the Ledger Entry is Per Cap, then the Contra at Forecast is calculated applying the ticket scale rule.
//        else{
//            if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
//                ledgerEntryBreakout.ContraAtForecast__c = (ContraAmount * ProjectedPaidTickets) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ProjectedPaidTickets)));
//            }else if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
//                ledgerEntryBreakout.ContraAtForecast__c = (ContraAmount * ProjectedDropCount) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ProjectedDropCount)));
//            }else if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
//                ticketRule = 0;
//                for(TicketScale__c ticketScale : listOfTicketScales){
//                   if( ticketScale.ProjectedPaidTickets__c != null ){
//                        ticketRule += ticketScale.ProjectedPaidTickets__c;
//                   }
//                }
//                ledgerEntryBreakout.ContraAtForecast__c = (ContraAmount * ticketRule) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ticketRule)));
//            }else{
//                ledgerEntryBreakout.ContraAtForecast__c = ContraAmount;
//            }
            
//        }
//        return ledgerEntryBreakout;
        
//    }
///**
//*  Method to calculate the Contra % at Forecast field on LedgerEntryBreakout__c Object.
//*  @param LedgerEntryBreakout__c
//*  @return LedgerEntryBreakout__c
//**/
//    public static LedgerEntryBreakout__c calculateContraPercentAtForecast(LedgerEntryBreakout__c ledgerEntryBreakout){
        
//        if( ledgerEntryBreakout != null &&
//        	  ledgerEntryBreakout.GrossRevenue__c != null &&
//        	  ledgerEntryBreakout.GrossRevenue__c != 0 ) {

//            Double ContraAtForecast = ledgerEntryBreakout.ContraAtForecast__c == null ? 0.0 : ledgerEntryBreakout.ContraAtForecast__c;
        			
//            ledgerEntryBreakout.Contra_At_Forecast__c = ContraAtForecast / ledgerEntryBreakout.GrossRevenue__c;
//        }
        
//        return ledgerEntryBreakout;
//    }
    
///**
//*  Method to calculate the Net Revenue field on LedgerEntryBreakout__c Object.
//*  @param LedgerEntryBreakout__c
//*  @return LedgerEntryBreakout__c
//**/
//    public static LedgerEntryBreakout__c calculateNetRevenue(LedgerEntryBreakout__c ledgerEntryBreakout){
        
//        if( ledgerEntryBreakout != null) {
//            Double ContraAtForecast = ledgerEntryBreakout.ContraAtForecast__c == null ? 0.0 : ledgerEntryBreakout.ContraAtForecast__c;
//            Double GrossRevenue = ledgerEntryBreakout.GrossRevenue__c == null ? 0.0 : ledgerEntryBreakout.GrossRevenue__c;
        
//        	ledgerEntryBreakout.Net_Revenue__c = GrossRevenue - ContraAtForecast;
//       	}
        
//        return ledgerEntryBreakout;
//    }
    
///**
//*  Method to calculate the Net Per Paid field on LedgerEntryBreakout__c Object.
//*  @param LedgerEntryBreakout__c, Event__c
//*  @return LedgerEntryBreakout__c
//**/
//    public static LedgerEntryBreakout__c calculateNetPerPaid(LedgerEntryBreakout__c ledgerEntryBreakout, Event__c relatedEvent){
        
//        if (ledgerEntryBreakout != null &&
//        	  relatedEvent != null &&
//        	  relatedEvent.ProjectedPaidTickets__c != null) {

//            Double NetRevenue = ledgerEntryBreakout.Net_Revenue__c == null ? 0.0 : ledgerEntryBreakout.Net_Revenue__c;
        	  	
//	        if(relatedEvent.ProjectedPaidTickets__c == 0 &&
//	        	 relatedEvent.ProjectedDropCount__c != null &&
//	             relatedEvent.ProjectedDropCount__c != 0 ) {
	             	
//	            ledgerEntryBreakout.NetPerPaid__c = NetRevenue / relatedEvent.ProjectedDropCount__c;
//	        } else if( relatedEvent.ProjectedPaidTickets__c != 0 ) {
	        	
//	            ledgerEntryBreakout.NetPerPaid__c = NetRevenue / relatedEvent.ProjectedPaidTickets__c;
//	        }
//        }
        
//        return ledgerEntryBreakout;
//    }
    
    
}