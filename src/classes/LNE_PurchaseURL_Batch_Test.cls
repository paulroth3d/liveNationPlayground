@isTest
private class LNE_PurchaseURL_Batch_Test {

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    private class TestSettings {
        public Map<String,Id> setupData() {
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{'Account.Venue', 'Event__c.PromotedShow'});   
            Id rtPromotedId = recordTypeMap.get('Event__c.PromotedShow');
            
    		Event__c testEvent = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Status__c = 'Pending Likely',
               	RecordTypeId = rtPromotedId,
               	EventLastDate__c = System.today().addDays(1)
            );
            
            List<Event__c> events = new List<Event__c>{testEvent};
            return LNE_TestObjectFactory.createStandardDataSetList(events);  
        }
    }

	private static testMethod void testUpdatePurchaseURLFromAPI() {
	    TestSettings ts = new TestSettings();
	    Map<String,Id> objectToId = ts.setupData();	    
	    
	    Test.startTest();
	    
	    update new List<Account>{
	        new Account(Id = objectToId.get('venue'), LNEAPIID__c = 'ven_15056'),
	        new Account(Id = objectToId.get('artist'), LNEAPIID__c = 'art_15056')
	    };
	    
        Tour__c tour = LNE_TestObjectFactory.createTour('test tour', objectToId.get('artist'));
        insert tour;	    
	    
	    insert LNE_TestObjectFactory.createAdPlan('test ad plan', 10000, objectToId.get('event-0'), tour.Id);  
        
        EventDateTime__c evtDateTime = LNE_TestObjectFactory.createEventDateTime(
            objectToId.get('event-0'), 
            System.today().addDays(1), 
            System.today().addDays(1), 
            String.valueOf(System.now().year()));
            
        insert evtDateTime;            
        
        insert LNE_TestObjectFactory.createEventTicketAgency(evtDateTime.Id, 'seed-with-this');
        
        LNE_PurchaseURL_Batch b = new LNE_PurchaseURL_Batch();
        Id batchProcessId = Database.executeBatch(b, LNE_PurchaseURL_Batch.BATCH_SIZE);
        Test.stopTest();
        
        List<Event__c> testEvents = [SELECT PurchaseURL__c FROM Event__c];
        List<AdPlan__c> testAdPlans = [SELECT PurchaseURL__c FROM AdPlan__c];
        
        System.assertNotEquals(null, batchProcessId);
        System.assertEquals(1, testEvents.size());
        
        System.assertEquals('http://ticketmaster.com/event/1B00522BCEF04D7F', testEvents.get(0).PurchaseURL__c);
        System.assertEquals(1, testAdPlans.size());
        System.assertEquals('http://ticketmaster.com/event/1B00522BCEF04D7F', testAdPlans.get(0).PurchaseURL__c);
	}
	
	private static testMethod void testUpdatePurchaseURLFromTicketAgency() {
	    TestSettings ts = new TestSettings();
	    Map<String,Id> objectToId = ts.setupData();	    
	    
	    Test.startTest();
	    
	    update new List<Account>{
	        new Account(Id = objectToId.get('venue'), LNEAPIID__c = 'ven_fake'),
	        new Account(Id = objectToId.get('artist'), LNEAPIID__c = 'art_fake')
	    };
	    
        Tour__c tour = LNE_TestObjectFactory.createTour('test tour', objectToId.get('artist'));
        insert tour;	    
	    
	    insert LNE_TestObjectFactory.createAdPlan('test ad plan', 10000, objectToId.get('event-0'), tour.Id);  
        
        EventDateTime__c evtDateTime = LNE_TestObjectFactory.createEventDateTime(
            objectToId.get('event-0'), 
            System.today().addDays(1), 
            System.today().addDays(1), 
            String.valueOf(System.now().year()));
            
        insert evtDateTime;            
        
        insert LNE_TestObjectFactory.createEventTicketAgency(evtDateTime.Id, 'seed-with-this');
        
        LNE_PurchaseURL_Batch b = new LNE_PurchaseURL_Batch();
        Id batchProcessId = Database.executeBatch(b, LNE_PurchaseURL_Batch.BATCH_SIZE);
        Test.stopTest();
        
        List<Event__c> testEvents = [SELECT PurchaseURL__c FROM Event__c];
        List<AdPlan__c> testAdPlans = [SELECT PurchaseURL__c FROM AdPlan__c];
        
        System.assertNotEquals(null, batchProcessId);
        System.assertEquals(1, testEvents.size());
        
        System.assertEquals('http://ticketmaster.com/event/seed-with-this', testEvents.get(0).PurchaseURL__c);
        System.assertEquals(1, testAdPlans.size());
        System.assertEquals('http://ticketmaster.com/event/seed-with-this', testAdPlans.get(0).PurchaseURL__c);
	}	

}