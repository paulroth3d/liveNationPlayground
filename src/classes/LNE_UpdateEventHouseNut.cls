/**
 * Used on the expenseTab page to update the event__c. UsingHouseNut__c and HouseNutAmount__c values
 * @author Dominic Aveyard <daveyard@salesforce.com>
 **/
global class LNE_UpdateEventHouseNut {
    public LNE_UpdateEventHouseNut(ApexPages.StandardController controller) {}
    
    /** 
     *  Remote action to update the event UsingHouseNut__c and BookingHouseNut__c
     **/
    @RemoteAction
    global static Event__c updateEvent(Id eventId, Boolean UsingHouseNut, Decimal HouseNutAmount ){
        return updateEvent(eventId, UsingHouseNut, HouseNutAmount, 'BookingHouseNut__c');
    }

    @RemoteAction
    global static Event__c updateEventSettlement(Id eventId, Boolean UsingHouseNut, Decimal HouseNutAmount ){
        return updateEvent(eventId, UsingHouseNut, HouseNutAmount, 'SettlementHouseNut__c');
    }

    private static Event__c updateEvent(Id eventId, Boolean usingHouseNut, Decimal houseNutAmount, String field) {
        Event__c updateEvent = new Event__c(Id=eventId, UsingHouseNut__c=UsingHouseNut);
        updateEvent.put(field, HouseNutAmount);
        update updateEvent;

        return updateEvent ;
    }
}