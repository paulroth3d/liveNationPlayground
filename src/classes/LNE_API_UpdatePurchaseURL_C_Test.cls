@isTest
private class LNE_API_UpdatePurchaseURL_C_Test {

    @testSetup
    static void setup() {
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    private class TestSettings {
        public Map<String, Id> setupData() {
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{'Account.Venue', 'Event__c.PromotedShow'});   
            Id rtPromotedId = recordTypeMap.get('Event__c.PromotedShow');
            
    		Event__c testEvent = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Status__c = 'Pending Likely',
               	RecordTypeId = rtPromotedId,
               	EventLastDate__c = System.today().addDays(-1)
            );
            
            List<Event__c> events = new List<Event__c>{testEvent};
            return LNE_TestObjectFactory.createStandardDataSetList(events);
        }
    }

	private static testMethod void testSetEventLiveNationId() {
	    TestSettings ts = new TestSettings();
	    Map<String, Id> objectToId = ts.setupData();
        
        Test.startTest();
        
        Tour__c tour = LNE_TestObjectFactory.createTour('test tour', objectToId.get('artist'));
        insert tour;
        
        AdPlan__c plan = LNE_TestObjectFactory.createAdPlan('test ad plan', 10000, objectToId.get('event-0'), tour.Id);
        insert plan;      
        
        LNE_API_UpdatePurchaseURL_C.setEventLiveNationId(plan.Id, 'some-fake|;test-data');
        
        AdPlan__c updatedPlan = [SELECT PurchaseURL__c, Event__c FROM AdPlan__c WHERE Id = :plan.Id];
        Event__c updatedEvent = [SELECT PurchaseURL__c, LNEAPIID__c FROM Event__c WHERE Id = :updatedPlan.Event__c];
        
        System.assertEquals('some-fake', updatedPlan.PurchaseURL__c);
        System.assertEquals('some-fake', updatedEvent.PurchaseURL__c);
        System.assertEquals('test-data', updatedEvent.LNEAPIID__c);
        Test.stopTest();
	}
	
	private static testMethod void testSearchEvents() {
	    TestSettings ts = new TestSettings();
	    Map<String, Id> objectToId = ts.setupData();
        
        Test.startTest();
        
        Tour__c tour = LNE_TestObjectFactory.createTour('test tour', objectToId.get('artist'));
        insert tour;
        
        AdPlan__c plan = LNE_TestObjectFactory.createAdPlan('test ad plan', 10000, objectToId.get('event-0'), tour.Id);
        insert plan;  
        
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{'Account.Venue', 'Event__c.PromotedShow', 'Account.Artist'}); 
        Id rtVenueId = recordTypeMap.get('Account.Venue');	    
        Id rtArtistId = recordTypeMap.get('Account.Artist');
        
	    List<Account> venues = [SELECT Id FROM Account WHERE RecordTypeId = :rtVenueId];
	    List<Account> artists = [SELECT Id FROM Account WHERE RecordTypeId = :rtArtistId];
	    
	    venues.get(0).LNEAPIID__c = 'ven_15056';
	    update venues;
	    
	    artists.get(0).LNEAPIID__c = 'art_15056';
	    update artists;        
        
        List<LNE_API_UpdatePurchaseURL_C.EventResult> results = LNE_API_UpdatePurchaseURL_C.searchEvents(plan.Id);
        System.assertNotEquals(0, results.size());	   
        Test.stopTest();
	}
	
	private static testMethod void testCheckIfUserCanEditCurrentRecord() {
	    TestSettings ts = new TestSettings();
	    Map<String, Id> objectToId = ts.setupData();
        
        Test.startTest();
        
        Tour__c tour = LNE_TestObjectFactory.createTour('test tour', objectToId.get('artist'));
        insert tour;
        
        AdPlan__c plan = LNE_TestObjectFactory.createAdPlan('test ad plan', 10000, objectToId.get('event-0'), tour.Id);
        insert plan;  
        
        Boolean result = LNE_API_UpdatePurchaseURL_C.checkIfUserCanEditCurrentRecord(plan.Id);
        System.assertEquals(true, result);	    
        Test.stopTest();
	}

}