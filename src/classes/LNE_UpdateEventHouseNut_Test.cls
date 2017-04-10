@isTest
public class LNE_UpdateEventHouseNut_Test {
    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    @isTest
    static void testUpdateHouseNutValues(){

    	LNE_TestObjectFactory.createStandardDataSet();
        
        List<Event__c> events = new List<Event__c>([SELECT Id FROM Event__c WHERE Status__c = 'Draft' LIMIT 1]);
        Id eventId = events[0].Id;

        Event__c ev = events[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(ev);
        LNE_UpdateEventHouseNut controller = new LNE_UpdateEventHouseNut(sc);

        Boolean UsingHouseNut = true;
        Decimal HouseNutAmount = 500;
        Event__c updatedEvent = LNE_UpdateEventHouseNut.updateEvent(eventId, UsingHouseNut, HouseNutAmount);
        System.assertEquals(500, updatedEvent.BookingHouseNut__c);
        System.assertEquals(true, updatedEvent.UsingHouseNut__c);
        Boolean UsingHouseNut2 = false;
        Decimal HouseNutAmount2 = 999;
        Event__c updatedEvent2 = LNE_UpdateEventHouseNut.updateEvent(eventId, UsingHouseNut2, HouseNutAmount2);
        System.assertEquals(999, updatedEvent2.BookingHouseNut__c);
        System.assertEquals(false, updatedEvent2.UsingHouseNut__c);    
        Event__c updatedEvent3 = LNE_UpdateEventHouseNut.updateEventSettlement(eventId, UsingHouseNut2, HouseNutAmount2);
        System.assertEquals(999, updatedEvent3.SettlementHouseNut__c);
        System.assertEquals(false, updatedEvent3.UsingHouseNut__c);
    }
}