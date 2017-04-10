@isTest
private with sharing class LNE_PromoterCreateEventResults_CC_Test {
	class TestSettings {
        Event__c testEvent;
        
        public TestSettings() {

        }
        
        public void typicalSetup(){
            
            Event__c e = new Event__c(
              ProjectedPaidTickets__c = 20000,
              ProjectedDropCount__c = 30000
            );
            
            insert e;
            testEvent = e;
        }
        
        public void finalize(){}
    }

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    static testMethod void testController() {
    	TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

    	LNE_PromoterCreateEventResults_CC controller = new LNE_PromoterCreateEventResults_CC();
    	controller.gotoEventPage();
    	system.assertEquals(ts.testEvent.Id, controller.newEventId);
    }

    static testMethod void testController_Error() {
    	TestSettings ts = new TestSettings();

    	LNE_PromoterCreateEventResults_CC controller = new LNE_PromoterCreateEventResults_CC();
    	controller.gotoEventPage();
    	system.assertEquals(null, controller.newEventId);
    }
}