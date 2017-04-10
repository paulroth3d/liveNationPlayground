/** 
 *  Batch Class that populates the Purchase URL field on Events and Ad Plans.
 *  
 *  @Example
 *  LNE_PurchaseURL_Batch b = new LNE_PurchaseURL_Batch();
 *  Id batchProcessId = Database.executeBatch(b, LNE_PurchaseURL_Batch.BATCH_SIZE);
 *  System.debug('batchProcessId:' + batchProcessId);
 *  
 *  @author Phil Rymek <prymek@salesforce.com>
 **/
global with sharing class LNE_PurchaseURL_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global static final Integer BATCH_SIZE = 10;

    global static final String DEFAULT_QUERY = 
        'SELECT Id, ' +
               'Venue__r.LNEAPIID__c, ' +
               'EventFirstDate__c, ' +
               'EventLastDate__c, ' +
               'Venue__r.BillingCountryCode ' +
          'FROM Event__c ' +
         'WHERE (Status__c = \'Pending Likely\' OR Status__c = \'Confirmed\') AND  ' +
               'PurchaseURL__c = null AND ' +
               'Venue__r.LNEAPIID__c != null AND ' +
               'EventLastDate__c >= TODAY';
    
    global String query {get; set;}
    
    private static final String COUNTRY_CODE_CANADA = 'CA';
    private static final String PURCHASE_URL_CANADA = 'http://ticketmaster.ca/event/';
    private static final String PURCHASE_URL_NON_CA = 'http://ticketmaster.com/event/';

    global LNE_PurchaseURL_Batch() {
        this.query = null;
    }
    
    global LNE_PurchaseURL_Batch(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        if(String.isBlank(query)) {
            query = DEFAULT_QUERY;
        }
        
        return(Database.getQueryLocator(query));
    }
    
    global void execute(Database.BatchableContext context, List<sObject> scope) {
        List<Event__c> events = (List<Event__c>) scope;
        List<Event__c> urlFromAPI = new List<Event__c>();
        List<Event__c> urlFromSFDC = new List<Event__c>();
        Map<Id, Deal__c> eventToPrimaryDeal = getPrimaryDeals(events);
        LNE_API_EventSearchResp response;
        URLSearchInfo info;
        Deal__c primaryDeal;
        
        for(Event__c evt : events) {
            info = new URLSearchInfo(evt);
            primaryDeal = eventToPrimaryDeal.get(evt.Id);
            
            if(primaryDeal != null) {
                response = LNE_EventSearch.getEventsByVenue(
                    primaryDeal.Artist__r.LNEAPIId__c, 
                    '?since=' + info.since + '&until=' + info.until, 
                    info.venueId);  
                
                if(response == null || response.data == null || response.data.isEmpty()) {
                    urlFromSFDC.add(evt);
                    continue;
                }
                    
                String purchaseURL = response.data.get(0).buy_link;
                if(String.isNotBlank(purchaseURL)) {
                    evt.PurchaseURL__c = purchaseURL;
                    urlFromAPI.add(evt);
                } else {
                    urlFromSFDC.add(evt);
                }
            }
        }

        List<Event__c> needsAdPlanUpdated = new List<Event__c>();
        needsAdPlanUpdated.addAll(updateAPIEvents(urlFromAPI));
        needsAdPlanUpdated.addAll(updateUsingAgencyId(urlFromSFDC));
        updateAdPlans(needsAdPlanUpdated);
    }
    
    private void updateAdPlans(List<Event__c> events) {
        List<AdPlan__c> plans = [SELECT Id, Event__c FROM AdPlan__c WHERE Event__c in :events];
        Map<Id, Event__c> idToEvent = new Map<Id, Event__c>(events);
        List<AdPlan__c> toUpdate = new List<AdPlan__c>();
        Event__c evt;
        
        for(AdPlan__c plan : plans) {
            evt = idToEvent.get(plan.Event__c);
            
            if(evt != null && String.isNotBlank(evt.PurchaseURL__c)) {
                plan.PurchaseURL__c = evt.PurchaseURL__c;
                toUpdate.add(plan);
            }
        }
        
        if(!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
    
    private List<Event__c> updateAPIEvents(List<Event__c> events) {
        if(!events.isEmpty()) {
            update events;
        }        
        
        return events;
    }
    
    private List<Event__c> updateUsingAgencyId(List<Event__c> events) {
        List<Event__c> toUpdate = new List<Event__c>();
        
        if(!events.isEmpty()) {
            Map<Id, String> idToSystemId = new Map<Id, String>();
            String purchaseURL;
            String systemId;
            
            List<EventTicketAgency__c> agencies = 
                [SELECT Id, EventDateTime__r.Event__c, AgencySystemID__c
                   FROM EventTicketAgency__c
                  WHERE EventDateTime__r.Event__c in :events AND 
                        AgencySystemID__c != ''];            
            
            for(EventTicketAgency__c agency : agencies) {
                idToSystemId.put(agency.EventDateTime__r.Event__c, agency.AgencySystemID__c);
            }
            
            for(Event__c evt : events) {
                systemId = idToSystemId.get(evt.Id);
                purchaseURL = generatePurchaseURL(evt, systemId);
                
                if(String.isNotBlank(purchaseURL)) {
                    evt.PurchaseURL__c = purchaseURL;
                    toUpdate.add(evt);
                }
            }
            
            update toUpdate;
        }          
        
        return toUpdate;
    }
    
    public String generatePurchaseURL(Event__c evt, String systemId) {
        if(String.isNotBlank(systemId)) {
            return (evt.Venue__r.BillingCountryCode == COUNTRY_CODE_CANADA ?
                   PURCHASE_URL_CANADA : PURCHASE_URL_NON_CA) + systemId;
        }
        
        return null;
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
    
    private Map<Id, Deal__c> getPrimaryDeals(List<Event__c> events) {
        Map<Id, Deal__c> primaryDeals = new Map<Id, Deal__c>();
        List<Deal__c> deals = 
            [SELECT Id, 
                    Event__c, 
                    Artist__c,
                    Artist__r.LNEAPIId__c,
                    Artist__r.LNEAPITicketMasterId__c
               FROM Deal__c
              WHERE Event__c in :events AND 
                    Type__c = 'Primary Headliner'];
              
        for(Deal__c deal : deals) {
            primaryDeals.put(deal.Event__c, deal);
        }
        
        return primaryDeals;
    }
    
    public class URLSearchInfo {
        public String venueId {get; set;}
        public String since {get; set;}
        public String until {get; set;}
        public Event__c evt {get; set;}
        
        public URLSearchInfo(Event__c evt) {
            this.evt = evt;
        
            venueId = getVenueId();
            since = getSinceDate();
            until = getUntilDate();
        }
        
        private String getVenueId() {
            return evt.Venue__r.LNEAPIID__c;
        }
        
        private String getSinceDate() {
            return String.valueOf(evt.EventFirstDate__c) + 'T00:00:00';
        }
        
        private String getUntilDate() {
            return String.valueOf(evt.EventLastDate__c) + 'T23:59:59';
        }
    }
}