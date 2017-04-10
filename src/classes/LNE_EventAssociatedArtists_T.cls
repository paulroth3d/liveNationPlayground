public class LNE_EventAssociatedArtists_T {
    static final String RT_Deal_Artist = 'Deal__c.Artist';
    
    /**
    *  Build and update Event Artist(s) field contains all the names of the Artists with Deal records for the Event
    *  @param newList Deal__c[]
    *  @param oldMap Map<Id,Deal__c>
    *  @return Deal__c[] - list of ledger entries updated.
    **/
    public static Deal__c[] execute( Deal__c[] newList, Deal__c[] oldList, Map<Id,Deal__c> oldMap ){
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{ RT_Deal_Artist }
		);
		Id RT_DEAL_ARTIST_ID = recordTypeMap.get( RT_Deal_Artist );
		
		List<Deal__c> triggerList = new List<Deal__c>();
        Set<Id> eventIds = new Set<Id>();
        
        /**
        *    All the deals that were added/changed
        */
        if (Trigger.isDelete) {
            triggerList = oldList;
        } else if( Trigger.isInsert ){
            triggerList = newList;
        } else {
        	triggerList = new Deal__c[]{};
        	Deal__c oldDeal;
        	
        	//-- PR: can we have this work only if something changes on the deal? perhaps no? based on the comment below?
        	//-- all of them will be filtered to only those by the deal artist id below anyway.
        	for( Deal__c newDeal : newList ){
        		if( oldMap.containsKey( newDeal.Id )){
        			oldDeal = oldMap.get( newDeal.Id );
        			if((oldDeal.RecordTypeId != newDeal.RecordTypeId ||
                        oldDeal.Artist__c != newDeal.Artist__c) &&
                        newDeal.RecordTypeId == RT_DEAL_ARTIST_ID) {

        				triggerList.add( newDeal );
        			}
        		}
        	}
        }
        
        //-- short circuit if no changes
        if( triggerList == null || triggerList.size() < 1 ){
        	return null;
        }

        for (Deal__c d : triggerList) {
            if (d.Event__c != null) {
                eventIds.add(d.Event__c);
            }
        }
        
        List<Event__c> events = [SELECT Id, (SELECT Artist__c, Artist__r.Name, Event__c
                                             FROM Deals__r
                                             WHERE Type__c IN ('Primary Headliner','Co-Headliner','Support') 
                                             AND StageType__c = 'Plan'
                                             ORDER BY Rank__c)
                                 FROM Event__c
                                 WHERE Id IN :eventIds];

        for (Event__c e : events) {
            //-- we use a List to keep the original order of the Deals/Artists
            //-- (SOQL query ordered by Rank__c)
            List<String> artists = new List<String>();

            //-- we use a Set to keep the potential duplicates out
            Set<String> artistSet = new Set<String>();

            for (Deal__c d : e.Deals__r) {
                if (!artistSet.contains(d.Artist__r.Name)) {
                    artistSet.add(d.Artist__r.Name);
                    artists.add(d.Artist__r.Name);
                }
            }

            e.Artists__c = String.join(artists, '\n');
        }

        update events;

        return null;
    }
}