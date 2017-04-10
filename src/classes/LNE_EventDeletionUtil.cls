/** 
 *  Utility class to delete an Event and its child records
 *  
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 **/
public without sharing class LNE_EventDeletionUtil {
	public static Boolean CURRENTLY_DELETING = false;
	
	private static final String RT_EVENT_HOLD = 'Event__c.Hold';

    private static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_EVENT_HOLD }
    );
    private static Id RT_EVENT_HOLD_ID = recordTypeMap.get( RT_EVENT_HOLD );
    private static final List<String> objectsToDelete = new List<String>{
    	'EventDateTime__c',
    	'TicketScale__c',
    	'Deduction__c',
    	'Deal__c',
    	'LedgerEntry__c'
    };

	public static void deleteEvents(List<Event__c> events) {
		CURRENTLY_DELETING = true;
		LNE_FinancialCalculator.currentlyRunning = true;
		
		for (String o : objectsToDelete) {
			String query = 'SELECT Id FROM ' + o + ' WHERE Event__c IN :events';
			delete Database.query(query);
		}

		delete [SELECT Id FROM Event__c WHERE Id IN :events];
	}
	
	public static void checkIfHoldEventShouldBeDeleted(List<EventDateTime__c> edtList) {
		Set<Id> eventIds = new Set<Id>();
		
		for (EventDateTime__c edt : edtList) {
			if (edt.Event__c != null) {
				eventIds.add(edt.Event__c);
			}
		}
		
		if (eventIds.size() > 0) {
			List<Event__c> events = [SELECT Id, (SELECT Id FROM EventDateTimes__r) FROM Event__c WHERE Id IN :eventIds AND RecordTypeId = :RT_EVENT_HOLD_ID];
			
			List<Event__c> toDelete = new List<Event__c>();
			
			for (Event__c e : events) {
				if (e.EventDateTimes__r.size() == 0) {
					toDelete.add(e);
				}
			}
			
			if (toDelete.size() > 0) {
				deleteEvents(toDelete);
			}
		}
	}
	
	@AuraEnabled
    public static void deleteHoldEvent(Id eventId) {
    	deleteEvents(new List<Event__c>{new Event__c(Id=eventId)});
    }
}