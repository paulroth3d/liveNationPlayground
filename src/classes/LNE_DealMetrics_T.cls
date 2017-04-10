/**
 *	Trigger logic to check for changes on any fields that would cause the
 *	financial calculator to fire off
 *	@author Sebastian Gutierrez
 **/
public with sharing class LNE_DealMetrics_T {
	static final String RT_DEAL_ARTIST = 'Deal__c.Artist';

    static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_DEAL_ARTIST }
    );
    static Id RT_DEAL_ARTIST_ID = recordTypeMap.get( RT_DEAL_ARTIST );
    
	/**
     *  Checks if any fields changed that would require a recalculation of event totals
     *  @param newList Deal__c[]
     *  @param oldMap Map<Id,Deal__c>
     *  @return Dealt__c[] - list of deals updated.
    **/
    
    public static Deal__c[] execute( Deal__c[] newList, Map<Id,Deal__C> oldMap ){
    	List<Deal__c> changedDeals = new List<Deal__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();
        ChangedDeal objChange = null;

 		if (oldMap == null){
            oldMap = new Map<Id, Deal__c>();
        }

        for (Deal__c newDeal : newList ){
            if(oldMap.containsKey(newDeal.Id)){
                
                Deal__c oldDeal = oldMap.get(newDeal.Id);
                objChange = new ChangedDeal(oldDeal, newDeal);
                
                if(
                    objChange.notEquals('GuaranteeAmount__c') ||
                    objChange.notEquals('BackendPotential__c') ||
                    objChange.notEquals('BackendPercent__c') ||
                    objChange.notEquals('OtherTalentAmount__c') ||
                    objChange.notEquals('ArtistSuppliedSL__c') ||
                    objChange.notEquals('DealType__c') ||
                    objChange.notEquals('DealCalculation__c') ||
                    objChange.notEquals('ShareInTalentOverhead__c') ||
                    objChange.notEquals('RollUpTalentOverheadAmount__c') ||
                    objChange.notEquals('ProfitShareAmountAtSellout__c') ||
                    objChange.notEquals('ProfitShareAmountAtProjection__c') ||
                    objChange.notEquals('ExpenseAdjustmentShareAmountAtSell__c') ||
                    objChange.notEquals('ExpenseAdjustmentShareAmountAtProj__c') ||
                    objChange.notEquals('CoPromoterBonusAtSellout__c') ||
                    objChange.notEquals('CoPromoterBonusAtProjection__c') ||
                    objChange.notEquals('CoPromoterWalkoutAtSellout__c') ||
                    objChange.notEquals('CoPromoterWalkoutAtProjection__c') ||
                    objChange.notEquals('AncillaryShareAmountAtSellout__c') ||
                    objChange.notEquals('AncillaryShareAmountAtProjection__c') ||
                    objChange.notEquals('StageType__c') ||
                    objChange.notEquals('SplitPercentage__c') ||
                    objChange.notEquals('ProjectedArtistEarnings__c') ||
                    objChange.notEquals('Type__c') 
                ) {
                  
                  listOfRelatedEventIds.add(newDeal.Event__c);
            	}
            }
            LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);
        }
		return changedDeals;
        
    }

    /**
     *  Recalculates for deleted Deals
     *  @param Deals[] - list of deleted Deals.
     *  @return Deals[] - list of Deals updated.
    **/
    
     public static Deal__c[] execute( Deal__c[] deletedList ){
    	List<Deal__c> ChangedDeals = new List<Deal__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();

 		for (Deal__c deletedDeal : deletedList){
 		    if (deletedDeal.Event__c != null) {
            	listOfRelatedEventIds.add(deletedDeal.Event__c);	
            }
            ChangedDeals.add(deletedDeal);
 		}
 		
 		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return ChangedDeals;
    }
    
    public static void findPreviousEventInMarket(Deal__c[] newList, Map<Id,Deal__C> oldMap) {
    	
    	Set<Id> eventIds = new Set<Id>();
    	
    	if (oldMap == null) {
    		for (Deal__c d : newList) {
    			if (d.RecordTypeId == RT_DEAL_ARTIST_ID && d.Type__c == 'Primary Headliner') {
    				eventIds.add(d.Event__c);
    			}
    		}
    	} else if (oldMap != null && newList != null) {
    		for (Deal__c d : newList) {
    			if (oldMap.get(d.Id) != null) {
    				Deal__c oldDeal = oldMap.get(d.Id);
    				
    				if (oldDeal.RecordTypeId != d.RecordTypeId || oldDeal.Artist__c != d.Artist__c) {
    					if (d.RecordTypeId == RT_DEAL_ARTIST_ID && d.Type__c == 'Primary Headliner') {
		    				eventIds.add(d.Event__c);
		    			}
    				}
    			}
    		}
    	} else if (oldMap != null && newList == null) {
    		for (Deal__c d : oldMap.values()) {
    			if (d.RecordTypeId == RT_DEAL_ARTIST_ID && d.Type__c == 'Primary Headliner') {
    				eventIds.add(d.Event__c);
    			}
    		}
    	}
    	
    	if (eventIds.size() > 0) {
    		LNE_FinancialCalculator.runUpdates = false;
    		Set<String> statusesForVenueChanged = new Set<String>{'Draft', 'Pending Unlikely', 'Pending Likely', 'Cancelled', 'Postponed'};
    		
    		List<Event__c> toUpdate = LNE_EventMetrics_T.findPreviousEvent([SELECT EventFirstDate__c, Market__c FROM Event__c WHERE Id IN :eventIds AND Status__c IN :statusesForVenueChanged]);
    		
    		if (toUpdate != null && toUpdate.size() > 0) {
    			update toUpdate;
    		}
    		
    		LNE_FinancialCalculator.runUpdates = true;
    	}
    }
    
    
    /**
     *  Internal class to represent the changes from the object.
    **/
    class ChangedDeal extends LNE_SObjectChange {
        
        ChangedDeal( Deal__c oldObject, Deal__c newObject ){
            super( oldObject, newObject );
        }
        
        Deal__c getNewDeal(){
            return( (Deal__c)this.newObject );
        }
    }
    
}