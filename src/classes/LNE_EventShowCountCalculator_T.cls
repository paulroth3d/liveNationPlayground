/**
 *  Determines the number of shows for an event.
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 *  @author Paul Roth <proth@salesforce.com>
 **/
public with sharing class LNE_EventShowCountCalculator_T {
	
	/**
	 * Updates the show count on events based on the number of show counts.
	 * @return Event__c[] - list of events that have the show count changed.
	 **/
	public static Event__c[] execute( EventDateTime__c[] updatedOrDeletedEventDateTimes ){
		
		Set<id> changedEventIds = new Set<id>();
		Event__c[] results = new Event__c[]{};
		
		for( EventDateTime__c changedEvent : updatedOrDeletedEventDateTimes ){
			if( changedEvent.Event__c != null ){
				changedEventIds.add( changedEvent.Event__c );
			}
		}
		
		//-- short circuit if no events have changed
		System.debug( 'changedEvents:' ); System.debug( changedEventIds );
		if( changedEventIds.size() < 1 ){
			return( results );
		}
		
		//-- update the events show counts
		Event__c updatedEvent;
		for( Event__c changedEvent : [
			select id, ShowCount__c, (select id from EventDateTimes__r)
			from Event__c
			where id in :changedEventIds
		]){
			if( changedEvent.ShowCount__c != changedEvent.EventDateTimes__r.size() ){
				updatedEvent = new Event__c( id = changedEvent.Id, ShowCount__c = changedEvent.EventDateTimes__r.size() );
				System.debug( 'changedEvent[' + updatedEvent.id + '].showCount:' + updatedEvent.ShowCount__c );
				results.add( updatedEvent );
			}
		}
		
		System.debug( 'changedEvents:' ); System.debug( results );
		update results;
		
		return( results );
	}
}