/**
 *  Controller for the LNE_LiveNationAPI_UpdatePurchaseURL lightning component.
 *  @author Phil Rymek (prymek@salesforce.com)
 **/
public with sharing class LNE_API_UpdatePurchaseURL_C {
    
    /**
     *  Sets the purchase url for the particular event/ad plan
     *  @param recordId (Id)
     *  @param livenationId (String)
     *  @return Boolean - whether succeeded (true) or not (false)
     **/
    @AuraEnabled
    public static Boolean setEventLiveNationId( Id recordId, String liveNationData ){
    	if (!String.isBlank(liveNationData)) {
    		List<String> values = liveNationData.split('\\|;');
    		
    		String buyLink = values.get(0);
            String eventAPIId = values.get(1);
            
            update new AdPlan__c(
                Id = recordId,
                PurchaseURL__c = buyLink
            );
            
            List<AdPlan__c> temp = 
                [SELECT Event__c FROM AdPlan__c WHERE Id = :recordId];
                
            if(!temp.isEmpty()) {
                update new Event__c(
                    Id = temp.get(0).Event__c,
                    PurchaseURL__c = buyLink,
                    LNEAPIId__c = eventAPIId
                );
            }
            
            return true;
    	}

    	return false;
    }    
    
    /**
     *  Performs the rest call to the LiveNation API.
     *  @param searchQuery
     *  @return SelectOption[]
     **/
    @AuraEnabled
    public static List<EventResult> searchEvents( String adPlanId ) {
        List<EventResult> results = new List<EventResult>();
        AdPlan__c current;
        Deal__c primary;
        
        List<AdPlan__c> adPlans = 
            [SELECT Event__c, Event__r.Venue__r.LNEAPIId__c
               FROM AdPlan__c
              WHERE Id = :adPlanId];
        
        if(adPlans.isEmpty()) {
            return results;
        }
        
        current = adPlans.get(0);
        
        List<Deal__c> primaryDeal = 
            [SELECT Artist__r.LNEAPIId__c
               FROM Deal__c
              WHERE Event__c = :current.Event__c AND Type__c = 'Primary Headliner'];        
        
        if(primaryDeal.isEmpty()) {
            return results;
        }        
        
        primary = primaryDeal.get(0);
        
        LNE_API_EventSearchResp response = LNE_EventSearch.getEventsByVenue(
            primary.Artist__r.LNEAPIId__c, 
            '', 
            current.Event__r.Venue__r.LNEAPIId__c);
        
        if(response != null && response.data != null && !response.data.isEmpty()) {
            results = createResponseOptions(response);
        }
        
        return results;
    }

    /**
     * Checks if the current user can edit this Ad Plan and related Event record.
     * Normally we would use a SOQL query on Account:
     * SELECT UserRecordAccess.HasEditAccess FROM AdPlan__c
     * But that won't tell us if any validation rules would stop the current user from
     * editing this record.
     * @param recordId (Id)
     * @return Boolean
     **/
    @AuraEnabled
    public static Boolean checkIfUserCanEditCurrentRecord(Id recordId) {
    	Boolean success = false;
    	Savepoint sp = Database.setSavepoint();

    	try {
    		AdPlan__c plan = new AdPlan__c(Id=recordId,PurchaseURL__c='test23423423test234234242test23423423test234234242');
    		Database.SaveResult sr = Database.update(plan);
    		
    		List<AdPlan__c> plans = [SELECT Id, Event__c FROM AdPlan__c WHERE Id = :recordId AND Event__c != null];
    		
    		if(plans.isEmpty()) {
    		    success = false;
    		} else {
    		    success = LNE_Util.isEventEditable(plans.get(0).Event__c);
    		}
    	} catch (DMLException e) {
    		success = false;
    	}

    	Database.rollback(sp);

    	return success;
    }
    
    /**
     *  Creates a set of options from an LNE_API_EventSearchResponse
     *  @param response (LNE_API_EventSearchResp)
     *  @returns SelectOption[]
     **/
    private static List<EventResult> createResponseOptions( LNE_API_EventSearchResp response ){
        List<EventResult> results = new List<EventResult>();
    
        for( LNE_API_EventSearchResp.Data result : response.data ){
            results.add(new EventResult(result.name, result.local_start_time, result.buy_link, result.id));
        }
        
        return results;
    }

    public class EventResult {
        
    	@AuraEnabled
    	public String name {get;set;}
    	
    	@AuraEnabled
    	public String purchaseURL {get;set;}    	

    	public EventResult(String eventName, String eventDate, String buyLink, String eventAPIId) {
    		name = eventName + ' - ' + getFormattedStartTime(eventDate);
    		purchaseURL = buyLink + '|;' + eventAPIId;
    	}
    	
    	private String getFormattedStartTime(String eventDate) {
    	    if(String.isNotBlank(eventDate)) {
    	        eventDate = eventDate.replace('T', ' ');
    	        DateTime startTime = DateTime.valueOf(eventDate);
    	        return startTime.format();
    	    }
    	    
    	    return '';
    	}


    }
}