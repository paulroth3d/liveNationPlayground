/** 
 *  Trigger logic to check for existing Event__c with more than one  Primary Headliner Artist 
 *  <p>Assumes that the trigger will be run on a before update or before insert</p>
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 **/
 public class LNE_DealPrimaryHeadlinerArtist_T {

    private static Set<Id> dealsCurrentlyInTrigger = new Set<Id>();

  /**
   *  Looks if there is another Primary Headliner Artist Deal within an Event
   *  @param newList Deal__c[]
   *  @param oldMap Map<Id,Deal__c>
   *  @return Deal__c[] - list of ledger entries updated.
  **/
    
    public static Deal__c[] execute( Deal__c[] newList, Map<Id,Deal__c> oldMap ){
       
        Deal__c[] results = new Deal__c[]{};
        Deal__c[] existingDeals = new Deal__c[]{};
        Set<Id> dealsInThisExecution = new Set<Id>();
        
        if ( newList == null ){ // would this ever happen?
            return( results );
        }
        
        // get RTs
        String RT_CoPromoter = 'Deal__c.CoPromoter';
        String RT_Rental = 'Event__c.Rental';
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
            new String[]{ RT_Rental, RT_CoPromoter }
        );
        Id RT_Rental_ID = recordTypeMap.get( RT_Rental );
        Id RT_CoPromoter_ID = recordTypeMap.get( RT_CoPromoter );

        // filter out Co-Promoter Deals
        /*
        //-- @TODO: please talk with paul on how we can best filter here
        List<Deal__c> filteredDealList = new List<Deal__c>();
        for(Deal__c d : newList){
            if (d.recordTypeId != RT_CoPromoter_ID){
                filteredDealList.add(d);
            }

            if (d.Id != null && d.recordTypeId != RT_CoPromoter_ID) {
                dealsCurrentlyInTrigger.add(d.Id);
            }
        }
        */
        List<Deal__c> filteredDealList = new List<Deal__c>();
        Deal__c oldDeal;
        for(Deal__c d : newList){
        	//-- only continue if the recordTypeId has changed
        	if( oldMap != null && oldMap.containsKey( d.Id ) ){
        		oldDeal = oldMap.get( d.Id );
        		if( oldDeal.recordTypeId == d.recordTypeId ){
        			continue;
        		}
        	}
        	
            if (d.recordTypeId != RT_CoPromoter_ID){
                filteredDealList.add(d);
            }

            if (d.Id != null && d.recordTypeId != RT_CoPromoter_ID) {
                dealsCurrentlyInTrigger.add(d.Id);
            }
        }
        
        if(filteredDealList.size() > 0) {
            newList = filteredDealList;
        } else {
            return( results );
        }
        
        Set<Id> eventIds = new Set<Id>();
        Map<Id, List<Deal__c>> eventIdToDealList = new Map<Id, List<Deal__c>>();
        Map<Id, Deal__c> triggerEventToDealMap = new Map<Id, Deal__c>();
        List<Deal__c> dealsNotInTrigger = new List<Deal__c>();
        
        for(Deal__c d : newList){
            if (d.Event__c != null) {
                eventIds.add(d.Event__c);

                if (eventIdToDealList.get(d.Event__c) == null) {
                    eventIdToDealList.put(d.Event__c, new List<Deal__c>());
                }

                eventIdToDealList.get(d.Event__c).add(d);
            }

            dealsInThisExecution.add(d.Id);

            triggerEventToDealMap.put(d.Event__c, d);
        }

        Map<String, Id> eventStageTypeToEventIdMap = new Map<String, Id>();

        Map<Id, Event__c> events = new Map<Id, Event__c>([SELECT RecordTypeId, (SELECT StageType__c, Type__c, Event__c, Rank__c FROM Deals__r) FROM Event__c WHERE Id IN :eventIds]);
        Map<String, Integer> primaryHeadlinerMap = new Map<String, Integer>();

        for(Event__c evt : events.values()){
            for(Deal__c deal : evt.Deals__r){
                if (!dealsInThisExecution.contains(deal.Id)) {
                    eventIdToDealList.get(evt.Id).add(deal);
                }

                if (!dealsCurrentlyInTrigger.contains(deal.Id)) {
                    dealsNotInTrigger.add(deal);
                }
            }
        }

        for (Id eventId : eventIdToDealList.keySet()) {
            for (Deal__c deal : eventIdToDealList.get(eventId)) {
                primaryHeadlinerMap.put(eventId+deal.StageType__c, 0);
                eventStageTypeToEventIdMap.put(eventId+deal.StageType__c, eventId);
            }
        }

        for (Id eventId : eventIdToDealList.keySet()) {
            for (Deal__c deal : eventIdToDealList.get(eventId)) {
                if(deal.Type__c == 'Primary Headliner'){
                    Integer numberOfPrimaryHeadliners = primaryHeadlinerMap.get(eventId+deal.StageType__c);
                    numberOfPrimaryHeadliners++;
                    primaryHeadlinerMap.put(eventId+deal.StageType__c, numberOfPrimaryHeadliners);
                }
            }
        }

        for (String eventStageType : primaryHeadlinerMap.keySet()) {
            Id eventId = eventStageTypeToEventIdMap.get(eventStageType);

            if (events.get(eventId).RecordTypeId != RT_Rental_ID && primaryHeadlinerMap.get(eventStageType) < 1) {
                triggerEventToDealMap.get(eventId).addError('A Primary Headliner Artist must be selected for the event.');
            }

            if (primaryHeadlinerMap.get(eventStageType) > 1) {
                triggerEventToDealMap.get(eventId).DuplicatePrimaryHeadlinerArtist__c = true;
            }
        }

        if (!dealsNotInTrigger.isEmpty()) {
            //update dealsNotInTrigger; // Cas: commented out because it is causing a self referencing error.
        }
        
        return ( results );
    }
}