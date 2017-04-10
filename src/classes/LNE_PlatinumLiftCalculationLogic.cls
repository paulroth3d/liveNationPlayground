/**
*  Class that contains the Logic to calculate fields on the LedgerEntry__c Object
*     Fields: Gross Revenue, Gross Per Paid, Contra at Forecast, Contra % at Forecast, Net Revenue and Net Per Paid
*  <p>This class should have the least amount of code possible to reduce security concerns.</p>
*  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
**/

public class LNE_PlatinumLiftCalculationLogic {
    
    
    public static final string DELIMITER = DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;

    
    public static final string ERR_NO_RELATED_EVENT = 'No Related Event';
    public static final string ERR_PROJECTED_PAID_TICKETS_NULL = 'Projected Paid Tickets on Related Event is not set';
    public static final string ERR_PROJECTED_DROP_COUNT_NULL = 'Projected Drop Count on Related Event is not set';
    
    class CustomException extends Exception{}
    
    
/**
*  Method to return a Ticket Scale with all updated fields to Grid Buddy
*  @param TicketScale__c
*  @return TicketScale__c
**/
    public static TicketScale__c calculateFieldsOnGrid(TicketScale__c ticketScale){
        System.debug(ticketScale);
        
        TicketScale__c savedTicketScale = 
            [SELECT Id, 
                    AverageLiftPerTicket__c, 
                    ProjectedGrossSales__c, 
                    ProjectedPaidTickets__c, 
                    Price__c, 
                    LiftBeforeFee__c  
               FROM TicketScale__c
              WHERE Id = :ticketScale.Id];
        
        if(ticketScale.AverageLiftPerTicket__c == null) {
            ticketScale.AverageLiftPerTicket__c = ticketScale.LiftBeforeFee__c / savedTicketScale.ProjectedPaidTickets__c;
        } else if(ticketScale.LiftBeforeFee__c == null) {
            ticketScale.LiftBeforeFee__c = ticketScale.AverageLiftPerTicket__c * savedTicketScale.ProjectedPaidTickets__c;
        }
        
        ticketScale.Price__c = savedTicketScale.Price__c;
        ticketScale.ProjectedPaidTickets__c = savedTicketScale.ProjectedPaidTickets__c;
        
        System.debug(ticketScale);
        return ticketScale;
    }
}