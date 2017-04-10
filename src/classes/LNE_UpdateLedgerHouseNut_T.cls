/**
 *	Trigger to set Ledger Entry.House Nut = false when unchecking Event.Using House Nut
 *	@author Dominic Aveyard
 **/
public with sharing class LNE_UpdateLedgerHouseNut_T {


	/**
     *  Checks if any fields changed that would require a recalculation of event totals
     *  @param newList Event__c[]
     *  @param oldMap Map<Id,Event__c>
     *  @return Event__c[] - list of events updated.
    **/
    
    public static Event__c[] execute( Event__c[] newList, Map<Id,Event__c> oldMap ){
        //-- all the events that have changed/valid for us to continue with.
        Event__c[] changedEvents = new Event__c[]{};
        List<Id> addLedgerX50148X = new List<Id>();
        List<Id> removeLedgerX50148X = new List<Id>();
        List<Id> addLedger50499 = new List<Id>();
        List<LedgerEntry__c> relatedLedgers = new List<LedgerEntry__c>();
        
        if( oldMap == null ){
        	oldMap = new Map<Id,Event__c>();
        }

		Event__c oldEvent =null;
        for( Event__c newEvent: newList ){
        	if( oldMap.containsKey( newEvent.Id )){
        		oldEvent = oldMap.get( newEvent.Id );
        		
        		if( newEvent.UsingHouseNut__c != oldEvent.UsingHouseNut__c || 
        		    newEvent.SettlementHouseNut__c != oldEvent.SettlementHouseNut__c ||
        		    newEvent.BookingHouseNut__c != oldEvent.BookingHouseNut__c) {
        		        
        		    removeLedgerX50148X.add(newEvent.Id); 
        		    
        			if(newEvent.UsingHouseNut__c) {
        			    addLedgerX50148X.add(newEvent.Id);
        			} else {
	        			changedEvents.add( newEvent );    			    
        			}
        		}
    			if(newEvent.AdvertisingBudget__c != oldEvent.AdvertisingBudget__c && newEvent.AdvertisingBudget__c != null) {
    			    addLedger50499.add(newEvent.Id);
    			}        		
        	} else {
        		//-- we are inserting
        		if( newEvent.UsingHouseNut__c == false ){
        			changedEvents.add( newEvent );
        			removeLedgerX50148X.add(newEvent.Id);
    			} else {
    			    addLedgerX50148X.add(newEvent.Id);
    			}
    			
    			if(newEvent.AdvertisingBudget__c != null) {
    			    addLedger50499.add(newEvent.Id);
    			}
        	}
        }
        
        if(!removeLedgerX50148X.isEmpty()) {
            LNE_LedgerEntryUtil.deleteX50148X(removeLedgerX50148X);
        }        
        
        if(!addLedgerX50148X.isEmpty()) {
            LNE_LedgerEntryUtil.createX50148X(addLedgerX50148X);
        }
        
        if(!addLedger50499.isEmpty()) {
            LNE_LedgerEntryUtil.create50499(addLedger50499);
        }        
        
        //-- short circuit if there are no changed events.
        if( changedEvents.isEmpty() ){
        	return( changedEvents );
        }
        
        relatedLedgers = new LedgerEntry__c[]{};
        for( LedgerEntry__c entry : [
        	SELECT Id, HouseNut__c
        	FROM LedgerEntry__c
        	WHERE Event__c IN :changedEvents
        ]){
        	entry.HouseNut__c = false;
        	relatedLedgers.add( entry );
        }
		
		if( relatedLedgers.isEmpty() ){
			return( changedEvents );
		}
		
		update relatedLedgers;
		
		//LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return changedEvents;
    }
    
}