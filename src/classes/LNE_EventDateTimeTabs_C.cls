/**
*  Controller class for the LNE_EventDateTimeTabs VF Component
*
*	@group Controller
*	@author Scott Will
**/
public with sharing class LNE_EventDateTimeTabs_C {

	// list of EventDateTimes for the UI to consume
	public List<EventDateTime__c> eventDateTimes { get; private set; }
	public Id event_Id {
		get;
		set {
			// set components load funky need to set the list here
			this.eventDateTimes = getSortedEventDateTimes(value);
		}
	}	

	// empty constructor to make tests and compilers happy
	public LNE_EventDateTimeTabs_C() {}
	
	//- sorts EventDateTime__c by Event Date and Start Time (e.g. 3/15/2017 8:00 AM, 3/15/2017 2:00 PM)
	private List<EventDateTime__c> getSortedEventDateTimes(String eventId) {
		List<EventDateTime__c> edtList =  [SELECT EventDate__c,
												  StartTime__c
										   FROM EventDateTime__c
										   WHERE Event__c = :eventId];
										   
		List<LNE_EventDateTimeUtil_T.EventDateTime> listToSort = new List<LNE_EventDateTimeUtil_T.EventDateTime>();										   
										   
		for (EventDateTime__c edt : edtList) {
			listToSort.add(new LNE_EventDateTimeUtil_T.EventDateTime(edt));
		}
		
		listToSort.sort();
		
		List<EventDateTime__c> returnList = new List<EventDateTime__c>();
		
		for (LNE_EventDateTimeUtil_T.EventDateTime e : listToSort) {
			returnList.add(e.edt);
		}
		
		return returnList;
	}

}