/**
 *  Trigger class to determine the start and end times for an event.
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/
public with sharing class LNE_EventStartEndTimeCalc_T {
	
	public static final String ERROR_NODATETIMEFOUND = 'You may not delete the last Date associated with the Event.';
	
	/**
	 * Determines the starting and ending date times for related events.
	 * @return Event__c[] - list of events that have the show count changed.
	 **/
	public static Event__c[] execute( EventDateTime__c[] newEventDateTimes, Map<Id,EventDateTime__c> oldEventDateTimeMap ){
		
		Set<id> changedEventIds = new Set<id>();
		Event__c updatedEvent;
		Event__c[] results = new Event__c[]{};
		
		if( newEventDateTimes == null ){
			//-- we are deleting
			for( EventDateTime__c deletedEDT : oldEventDateTimeMap.values() ){
				changedEventIds.add( deletedEDT.Event__c );
			}
		} else if( oldEventDateTimeMap == null ){
			//-- we are inserting
			for( EventDateTime__c insertedEDT : newEventDateTimes ){
				changedEventIds.add( insertedEDT.Event__c );
			}
		} else {
			//-- we are updating
			EventDateTime__c oldEDT;
			
			for( EventDateTime__c updatedEDT : newEventDateTimes ){
				oldEDT = oldEventDateTimeMap.get( updatedEDT.Id );
				if( updatedEDT.EventDate__c != oldEDT.EventDate__c ){
					changedEventIds.add( updatedEDT.Event__c );
				}
			}
		}
		
		//-- @INVARIANT: we know the list of all events that have had the starting and ending dates possibly changed.
		System.debug( 'changedEventIds:' ); System.debug( changedEventIds );
		if( changedEventIds.size() < 1 ){
			return( results );
		}
		
		//-- update the events show counts
		for( Event__c changedEvent : [
			select id,EventFirstDate__c, EventLastDate__c, (select id, EventDate__c  from EventDateTimes__r order by EventDate__c ASC )
			from Event__c
			where id in :changedEventIds
		]){
			updatedEvent = new Event__c();
			updatedEvent.Id = changedEvent.Id;
			if(changedEvent.EventDateTimes__r.size() > 0){
			    updatedEvent.EventFirstDate__c = changedEvent.EventDateTimes__r[0].EventDate__c;
                updatedEvent.EventLastDate__c = changedEvent.EventDateTimes__r[ changedEvent.EventDateTimes__r.size()-1 ].EventDate__c;
			}else{
				if (LNE_EventDeletionUtil.CURRENTLY_DELETING == false) {
			    	throw (new CustomException (ERROR_NODATETIMEFOUND));
				}
			}
            results.add( updatedEvent );
		}
		
		System.debug( 'changedEvents:' ); System.debug( results );
		update results;
		
		return( results );
	}
	
	/** custom exception **/
    class CustomException extends Exception {}
    
    /**
     *  Internal class to represent the changes from the object.
    **/
    /*
    class ChangedDateTimes extends LNE_SObjectChange {
        
        ChangedDateTimes( EventDateTime__c oldObject, EventDateTime__c newObject ){
            super( oldObject, newObject );
        }
        
        EventDateTime__c getNewDeal(){
            return( (EventDateTime__c)this.newObject );
        }
    }
    */
}