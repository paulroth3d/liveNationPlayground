/**
 *  Trigger logic to check for changes on any fields that would cause the
 *  financial calculator to fire off
 *  @author Daniel Nakonieczny
 **/
public with sharing class LNE_EventMetrics_T {

    private static final DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
    static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';
    static final String RT_COGS = 'LedgerEntry__c.COGS';
    static final String RT_PROMOTEDSHOW = 'Event__c.PromotedShow';
    static final String RT_RENTAL = 'Event__c.Rental';
    static final String RT_BUYSELL = 'Event__c.BuySell';
    static final String RT_EXPENSES = 'LedgerEntry__c.Expenses';
    static final String RT_DEAL_ARTIST = 'Deal__c.Artist';

    static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_Ancillary, RT_COGS, RT_PROMOTEDSHOW, RT_RENTAL, RT_BUYSELL, RT_EXPENSES, RT_DEAL_ARTIST }
    );
    static Id RT_Ancillary_ID = recordTypeMap.get( RT_Ancillary );
    static Id RT_COGS_ID = recordTypeMap.get( RT_COGS );
    static Id RT_PROMOTEDSHOW_ID = recordTypeMap.get( RT_PROMOTEDSHOW );
    static Id RT_RENTAL_ID = recordTypeMap.get( RT_RENTAL );
    static Id RT_BUYSELL_ID = recordTypeMap.get( RT_BUYSELL );
    static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    static Id RT_DEAL_ARTIST_ID = recordTypeMap.get( RT_DEAL_ARTIST );
    
    static Set<String> statusesForVenueChanged = new Set<String>{'Draft', 'Pending Unlikely', 'Pending Likely', 'Cancelled', 'Postponed'};

    /**
     *  Checks if any fields changed that would require a recalculation of event totals
     *  @param newList Event__c[]
     *  @param oldMap Map<Id,Event__c>
     *  @return Event__c[] - list of events updated.
    **/
    
    public static Event__c[] execute( Event__c[] newList, Map<Id,Event__c> oldMap ){
        List<Event__c> changedEvents = new List<Event__c>();
        List<Event__c> eventsChangedToProjection = new List<Event__c>();
        List<Event__c> eventsChangedBackToPlan = new List<Event__c>();
        List<Event__c> eventsChangedToFlashIntegrated = new List<Event__c>();
        List<Event__c> venueChanged = new List<Event__c>();

        Set<Id> listOfRelatedEventIds = new Set<Id>();
        ChangedEvent objChange = null;

        if (oldMap == null){
            oldMap = new Map<Id, Event__c>();
        }

        for (Event__c newEvent : newList ){
            if(oldMap.containsKey(newEvent.Id)){
                
                Event__c oldEvent = oldMap.get(newEvent.Id);
                objChange = new ChangedEvent(oldEvent, newEvent);
                
                if(
                    objChange.notEquals('ProjectedDropCountPct__c') ||
                    objChange.notEquals('DropCountAdjustment__c') ||
                    objChange.notEquals('Tour__c') ||
                    objChange.notEquals('ActualDropCount__c') ||
                    objChange.notEquals('PaidAttendance__c') ||
                    objChange.notEquals('SettlementNetGross__c') ||
                    objChange.notEquals('ShowCount__c') || 
                    objChange.notEquals('NumberofTrucks__c')
                ) {
                    if (objChange.getNewEvent().Id != null) {
                        listOfRelatedEventIds.add(objChange.getNewEvent().Id);  
                    }
                    changedEvents.add(objChange.getNewEvent());
                  }

                //- Check if the status stage changed
                if(
                    objChange.notEqualsStr('StatusStage__c', false) 
                ) {
                    if (oldEvent.StatusStage__c == 'Plan' && newEvent.StatusStage__c == 'Projection') {
                        eventsChangedToProjection.add(newEvent);
                    }

                    if (oldEvent.StatusStage__c == 'Projection' && newEvent.StatusStage__c == 'Plan') {
                        eventsChangedBackToPlan.add(newEvent);
                    }

                    if (objChange.getNewEvent().Id != null) {
                        listOfRelatedEventIds.add(objChange.getNewEvent().Id);  
                    }
                    changedEvents.add(objChange.getNewEvent());
                  }
                  
                if(objChange.notEqualsStr('FlashIntegrationStatus__c', false)) {
                	
                	if (newEvent.FlashIntegrationStatus__c == 'Integrated' && newEvent.OriginalFlashCaptured__c == false) {
                		newEvent.OriginalFlashCaptured__c = true;
                		eventsChangedToFlashIntegrated.add(newEvent);
                	}
                    changedEvents.add(objChange.getNewEvent());
                  }
                  
				if(objChange.notEquals('Venue__c') && statusesForVenueChanged.contains(newEvent.Status__c)) {
					venueChanged.add(objChange.getNewEvent());
					changedEvents.add(objChange.getNewEvent());
				}
                
            } else {
                if (newEvent.Id != null) {
                    listOfRelatedEventIds.add(newEvent.Id); 
                }
                changedEvents.add(newEvent);
            }

            if (newEvent.Tour__c != null) {
                newEvent.DoNotAutoAssociateWithTour__c = true;
            }
        }
        
        if( eventsChangedToProjection.isEmpty() &&
            changedEvents.isEmpty()
        ){
            //-- then we short circuit and close
            return( changedEvents );
        }

        if (!eventsChangedToProjection.isEmpty()) {
            cloneRelatedRecords(eventsChangedToProjection);
        }

        if (!eventsChangedBackToPlan.isEmpty()) {
            cleanupRecords(eventsChangedBackToPlan);
            checkUsingTicketFeed(eventsChangedBackToPlan);
        }
        
        if (!eventsChangedToFlashIntegrated.isEmpty()) {
            processFlash(eventsChangedToFlashIntegrated);
        }
        
        if (!venueChanged.isEmpty()) {
            findPreviousEvent(venueChanged);
        }

        LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

        return changedEvents;
    }

    /**
     *  Sets Settle at Actual to true or false on all child ledger entries if AdvertisingSettlementPlan__c changes
     *  SHOULD ONLY RUN BEFORE UPDATE
     *  @param newList Event__c[]
     *  @param oldMap Map<Id,Event__c>
    **/
    public static void checkSettleAtActual(Event__c[] newList, Map<Id,Event__c> oldMap) {
        Set<Id> eventsToProcess = new Set<Id>();

        for (Event__c newEvent : newList ){
            if(oldMap.containsKey(newEvent.Id)){
                Event__c oldEvent = oldMap.get(newEvent.Id);
                ChangedEvent objChange = new ChangedEvent(oldEvent, newEvent);

                if (objChange.notEqualsStr('AdvertisingSettlementPlan__c', false)) {
                    eventsToProcess.add(newEvent.Id);
                }
            }
        }

        if (eventsToProcess.size() > 0) {
            Map<Id, Event__c> eventMap = new Map<Id, Event__c>(newList);
            List<sObject> toUpdate = new List<sObject>();

            List<LedgerEntry__c> ledgers = [SELECT SettleAtActual__c, Event__c, (SELECT SettleAtActual__c FROM LedgerEntryBreakouts__r) FROM LedgerEntry__c WHERE Event__c IN :eventsToProcess AND RecordTypeId = :RT_EXPENSES_ID AND Category__c = 'Advertising Expense'];

            for (LedgerEntry__c l : ledgers) {
                Event__c parent = eventMap.get(l.Event__c);

                processSettleAtActual(parent, l, toUpdate);

                for (LedgerEntryBreakout__c b : l.LedgerEntryBreakouts__r) {
                    processSettleAtActual(parent, b, toUpdate);
                }
            }

            if (toUpdate.size() > 0) {
                update toUpdate;
            }
        }
    }

    private static void processSettleAtActual(Event__c parent, sObject ledger, List<sObject> toUpdate) {
        if (parent.AdvertisingSettlementPlan__c == 'Settle at Actual' && ((Boolean)ledger.get('SettleAtActual__c')) == false) {
            ledger.put('SettleAtActual__c', true);
            toUpdate.add(ledger);
        }

        if (parent.AdvertisingSettlementPlan__c == 'Settle at Offer' && ((Boolean)ledger.get('SettleAtActual__c')) == true) {
            ledger.put('SettleAtActual__c', false);
            toUpdate.add(ledger);
        }
    }
    
    private static void checkUsingTicketFeed(List<Event__c> eventsChangedBackToPlan){
        for(Event__c e : eventsChangedBackToPlan){
            if(e.UsingTicketFeed__c){
                    e.UsingTicketFeed__c = false;
            } 
        }
    }

    private static void cloneRelatedRecords(List<Event__c> eventsChangedToProjection) {
        List<TicketScale__c> scales = [SELECT   ActualGrossToDate__c,
                                                ActualSalesToDate__c,
                                                AfterAdjustedDeductions__c,
                                                AverageLiftPerTicket__c,
                                                BeforeAdjustedDeductions__c,
                                                Capacity__c,
                                                Comps__c,
                                                CurrencyIsoCode,
                                                Event__c,
                                                EventDateTime__c,
                                                EventIDStageType__c,
                                                ForecastGrossToGo__c,
                                                ForecastSalesToGo__c,
                                                GrossSales__c,
                                                Holds__c,
                                                Kills__c,
                                                LiftBeforeFee__c,
                                                LiftBeforeTaxes__c,
                                                Notes__c,
                                                PlatinumAfterAdjusted_Deductions__c,
                                                PlatinumBeforeAdjustedDeductions__c,
                                                Price__c,
                                                PriceLevel__c,
                                                ProjectedGrossSales__c,
                                                ProjectedPaidTickets__c,
                                                SellableCapacity__c,
                                                ShowOnOffer__c,
                                                ShowPlatinumOnOffer__c,
                                                StageType__c,
                                                TicketScaleType__c,
                                                TMFee__c,
                                                TMFeePercent__c,
                                                TotalPlatinumSeatProceeds__c,
                                                Type__c,
                                                Unsold__c
                                       FROM TicketScale__c
                                       WHERE Event__c IN :eventsChangedToProjection
                                       AND StageType__c = 'Plan'];

        List<TicketScale__c> clonedScales = new List<TicketScale__c>();
        Map<Id, TicketScale__c> clonedMap = new Map<Id, TicketScale__c>();
        
        for (TicketScale__c ts : scales) {
            TicketScale__c newScale = ts.clone(false, true, false, false);
            newScale.StageType__c = 'Projection';
            setEventIdStageType(newScale);
            clonedScales.add(newScale);
            clonedMap.put(ts.Id, newScale);
        }

        LNE_FinancialCalculator.runUpdates = false;

        insert clonedScales;

        List<Deduction__c> deductions = [SELECT   AmountRate__c,
                                                    ApplyTicketScale__c,
                                                    BeforeAfter__c,
                                                    CurrencyIsoCode,
                                                    DeductionAtProjection__c,
                                                    DeductionAtSellout__c,
                                                    Description__c,
                                                    Event__c,
                                                    EventDateTime__c,
                                                    EventIDStageType__c,
                                                    IncludeInAuditPrice__c,
                                                    Notes__c,
                                                    OwnerId,
                                                    RateType__c,
                                                    SourceSystemId__c,
                                                    StageType__c,
                                                    TicketScaleList__c,
                                                    Type__c
                                           FROM Deduction__c
                                           WHERE Event__c IN :eventsChangedToProjection
                                           AND StageType__c = 'Plan'];

        List<Deduction__c> clonedDeductions = new List<Deduction__c>();

        String ESCAPED_DELIMITER = DATA_SETTINGS.CombinedKeyDelimiter__c;
        if (ESCAPED_DELIMITER == '|') {
            ESCAPED_DELIMITER = '\\|';
        }
        
        for (Deduction__c d : deductions) {
            Deduction__c newDeduction = d.clone(false, true, false, false);
            newDeduction.StageType__c = 'Projection';
            setEventIdStageType(newDeduction);

            if (!String.isEmpty(d.TicketScaleList__c)) {
                List<String> ids = d.TicketScaleList__c.split(ESCAPED_DELIMITER);
                if (ids.size() > 0) {
                    String newIDs = '|';
                    for (String s : ids) {
                        if (!String.isBlank(s)) {
                            String newID;

                            if (clonedMap.get(s) != null && clonedMap.get(s).Id != null) {
                                newID = clonedMap.get(s).Id;
                            } else if (clonedMap.get(s.substring(0,15)) != null && clonedMap.get(s.substring(0,15)).Id != null) {
                                newID = clonedMap.get(s.substring(0,15)).Id;
                            }

                            if (!String.isBlank(newID)) {
                                newIDs += newID + DATA_SETTINGS.CombinedKeyDelimiter__c;
                            }
                        }
                    }
                    newDeduction.TicketScaleList__c = newIDs;
                }
            }
            
            clonedDeductions.add(newDeduction);
        }

        insert clonedDeductions;

        Set<Id> rtsToQuery = new Set<Id>{RT_Ancillary_ID,RT_COGS_ID};

        List<sObject> allLedgers = new List<sObject>();
        allLedgers.addAll(((List<sObject>)[SELECT TicketScaleList__c, PlanAmount__c, RecordTypeId FROM LedgerEntry__c WHERE Event__c IN :eventsChangedToProjection]));
        allLedgers.addAll(((List<sObject>)[SELECT TicketScaleList__c, PlanAmount__c, ParentRecordTypeID__c FROM LedgerEntryBreakout__c WHERE LedgerEntry__c IN :allLedgers]));

        for (sObject so : allLedgers) {
        	Id recordTypeId;
        	
        	if (so.getSObjectType() == Schema.LedgerEntry__c.SObjectType) {
        		recordTypeId = (Id)so.get('RecordTypeId');
        	}
        	
        	if (so.getSObjectType() == Schema.LedgerEntryBreakout__c.SObjectType) {
        		recordTypeId = (Id)so.get('ParentRecordTypeID__c');
        	}
        	
        	if (rtsToQuery.contains(recordTypeId)) {
	            String ticketScaleList = (String)so.get('TicketScaleList__c');
	
	            if (!String.isEmpty(ticketScaleList)) {
	                List<String> ids = ticketScaleList.split(ESCAPED_DELIMITER);
	                if (ids.size() > 0) {
	                    String newIDs = '|';
	                    for (String s : ids) {
	                        if (!String.isBlank(s)) {
	                            String newID;
	
	                            if (clonedMap.get(s) != null && clonedMap.get(s).Id != null) {
	                                newID = clonedMap.get(s).Id;
	                            } else if (clonedMap.get(s.substring(0,15)) != null && clonedMap.get(s.substring(0,15)).Id != null) {
	                                newID = clonedMap.get(s.substring(0,15)).Id;
	                            }
	
	                            if (!String.isBlank(newID)) {
	                                newIDs += newID + DATA_SETTINGS.CombinedKeyDelimiter__c;
	                            }
	                        }
	                    }
	                    so.put('TicketScaleList__c', newIDs);
	                }
	            }
        	}
            
            //-- US747
            copyField(so, 'PlanAmount__c', 'ProjectionAmount__c');
        }

        update allLedgers;

        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.checkIfCanRunCalculations();
    }

    private static void cleanupRecords(List<Event__c> eventsChangedBackToPlan) {
        List<TicketScale__c> scales = [SELECT StageType__c,
                                              Event__c
                                       FROM TicketScale__c
                                       WHERE Event__c IN :eventsChangedBackToPlan
                                       AND (StageType__c = 'Plan' OR StageType__c = 'Projection')];

        List<TicketScale__c> scalesToDelete = new List<TicketScale__c>();
        List<TicketScale__c> scalesToUpdate = new List<TicketScale__c>();

        for (TicketScale__c ts : scales) {
            if (ts.StageType__c == 'Plan') {
                scalesToDelete.add(ts);
            }

            if (ts.StageType__c == 'Projection') {
                ts.StageType__c = 'Plan';
                setEventIdStageType(ts);
                scalesToUpdate.add(ts);
            }
        }

        List<Deduction__c> deductions = [SELECT StageType__c,
                                                Event__c
                                         FROM Deduction__c
                                         WHERE Event__c IN :eventsChangedBackToPlan
                                         AND (StageType__c = 'Plan' OR StageType__c = 'Projection')];

        List<Deduction__c> deductionsToDelete = new List<Deduction__c>();
        List<Deduction__c> deductionsToUpdate = new List<Deduction__c>();

        for (Deduction__c d : deductions) {
            if (d.StageType__c == 'Plan') {
                deductionsToDelete.add(d);
            }

            if (d.StageType__c == 'Projection') {
                d.StageType__c = 'Plan';
                setEventIdStageType(d);
                deductionsToUpdate.add(d);
            }
        }

        List<sObject> allLedgers = new List<sObject>();
        allLedgers.addAll(((List<sObject>)[SELECT ProjectionAmount__c FROM LedgerEntry__c WHERE Event__c IN :eventsChangedBackToPlan]));
        allLedgers.addAll(((List<sObject>)[SELECT ProjectionAmount__c FROM LedgerEntryBreakout__c WHERE LedgerEntry__c IN :allLedgers]));
        
        for (sObject so : allLedgers) { 
        	//-- US747
            copyField(so, 'ProjectionAmount__c', 'PlanAmount__c');
        }
        
        LNE_FinancialCalculator.runUpdates = false;

        delete scalesToDelete;
        delete deductionsToDelete;
        update scalesToUpdate;
        update deductionsToUpdate;
        update allLedgers;
        
        LNE_FinancialCalculator.runUpdates = true;
    }
    
    private static void processFlash(List<Event__c> eventsChangedToFlashIntegrated) {
    	List<sObject> allLedgers = new List<sObject>();
        allLedgers.addAll(((List<sObject>)[SELECT CurrentFlash__c FROM LedgerEntry__c WHERE Event__c IN :eventsChangedToFlashIntegrated]));
        allLedgers.addAll(((List<sObject>)[SELECT CurrentFlash__c FROM LedgerEntryBreakout__c WHERE LedgerEntry__c IN :allLedgers]));
        
        for (sObject so : allLedgers) {
            copyField(so, 'CurrentFlash__c', 'OriginalFlash__c');
        }
        
        LNE_FinancialCalculator.runUpdates = false;
        
        update allLedgers;
        
        LNE_FinancialCalculator.runUpdates = true;
    }
    
    private static void copyField(sObject so, String source, String destination) {
    	so.put(destination, so.get(source));
    }

    private static void setEventIdStageType(sObject so) {
        if (so.get('StageType__c') != null && so.get('Event__c') != null) {
            String stageType = (String)so.get('StageType__c');
            String eventId = (String)so.get('Event__c');
            String newEventIDStageType = ((String)eventId).substring(0,15) + DATA_SETTINGS.CombinedKeyDelimiter__c + stageType;

            so.put('EventIDStageType__c', newEventIDStageType);

            if (so.getSObjectType() == Schema.TicketScale__c.SObjectType && so.get('EventDateTime__c') != null) {
                String eventDateTimeId = (String)so.get('EventDateTime__c');

                so.put('EventIDStageTypeDateTime__c', newEventIDStageType + DATA_SETTINGS.CombinedKeyDelimiter__c + ((String)eventDateTimeId).substring(0,15));
            }
        }
    }
    
    /**
     *  Updates/finds the PreviousEventInMarket__c for Events on which Venue__c changed
    **/
    public static List<Event__c> findPreviousEvent(List<Event__c> events) {
    	
    	for (Event__c e : events) {
    		e.PreviousEventInMarket__c = null;
    	}
    	
    	List<Deal__c> deals = [SELECT Event__c, Event__r.Venue__c, Event__r.Venue__r.Market__c, Artist__c, Event__r.EventFirstDate__c FROM Deal__c WHERE Event__c IN :events AND RecordTypeId = :RT_DEAL_ARTIST_ID AND Type__c = 'Primary Headliner' AND Event__r.EventFirstDate__c > TODAY];
    	
    	Map<Id, Event__c> eventMap = new Map<Id, Event__c>(events);
    	Set<Id> artistIDs = new Set<Id>();
    	Set<String> markets = new Set<String>();
    	Set<String> eventStatuses = new Set<String>{'Confirmed', 'Flash Started', 'Flash Complete'};
    	Map<String, Event__c> newDealMap = new Map<String, Event__c>();
    	
    	for (Deal__c d : deals) {
    		Event__c e = eventMap.get(d.Event__c);
    		
    		if (String.isNotBlank(e.Market__c)) {
    			String key = '' + d.Artist__c + e.Market__c;
    		
	    		if (d.Artist__c != null) {
	    			artistIDs.add(d.Artist__c);
	    		}
	    		
	    		markets.add(e.Market__c);
	    		
	    		newDealMap.put(key, eventMap.get(d.Event__c));
    		}
    	}
    	
    	List<Deal__c> oldDeals = [SELECT Event__c, Artist__c, Event__r.Venue__r.Market__c, Event__r.EventLastDate__c FROM Deal__c WHERE Artist__c IN :artistIDs AND (NOT Event__c IN :events) AND Event__r.Status__c IN :eventStatuses AND Event__r.Venue__r.Market__c IN :markets ORDER BY Event__r.EventLastDate__c DESC]; 
    	
    	Map<String, Deal__c> dealMap = new Map<String, Deal__c>();
    	
    	for (Deal__c d : oldDeals) {
    		String key = '' + d.Artist__c + d.Event__r.Venue__r.Market__c;
    		if (dealMap.get(key) == null) {
    			Event__c currentEvent = newDealMap.get(key);
    		
	    		if (currentEvent != null) {
	    			if (currentEvent.EventFirstDate__c > d.Event__r.EventLastDate__c) {
	    				dealMap.put(key, d);
	    			}
	    		}
    		}
    	}
    	
    	Map<Id, Event__c> eventsToUpdate = new Map<Id, Event__c>();
    	
    	for (Deal__c d : deals) {
    		Event__c e = eventMap.get(d.Event__c);
    		
    		if (String.isNotBlank(e.Market__c)) {
    			String key = '' + d.Artist__c + e.Market__c;
    		
	    		if (dealMap.get(key) != null) {
	    			if (e != null) {
	    				e.PreviousEventInMarket__c = dealMap.get(key).Event__c;
	    			}
	    		}
    		}
    	}
    	
    	return events;
    }

    /**
     *  Validates recordtype change - going from rental to promoted show is now allowed. US751
    **/
    public static void validateRecordTypeChange( Event__c[] newList, Map<Id,Event__c> oldMap ){
        GeneralSettings__c gs = GeneralSettings__c.getInstance(UserInfo.getProfileId());

        if(newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty() ){
            for(Event__c event : newList){
                //Exclude global data admin for all the below validations.
                if(gs.GlobalDataAdministrator__c != true){
                    if( oldMap.containsKey(event.Id) && oldMap.get(event.Id).RecordTypeId == RT_RENTAL_ID 
                        && event.RecordTypeId != oldMap.get(event.Id).RecordTypeId ){
                       event.addError('Event of rental recordtype cannot be changed to other recordtype');
                    }
                    /* The Rental Build Option field can only be changed from Build as a Promoted Show to Build Using Rental Accounts 
                        for a Rental record type (Build Using Rental Accounts->Build as a Promoted Show is not allowed) */
                    if(event.RecordTypeId == RT_RENTAL_ID && oldMap.containsKey(event.Id) 
                        && event.RentalBuildOption__c != oldMap.get(event.Id).RentalBuildOption__c 
                        && oldMap.get(event.Id).RentalBuildOption__c == 'Build Using Rental Accounts' 
                        && event.RentalBuildOption__c == 'Build as a Promoted Show'){
                        event.addError('For rental event, rental build option cannot be changed from Build Using Rental Accounts to Build as a Promoted Show');
                    }
                }
            }
        }
    }

    /**
     *  Checks if recordtype changed from Promoted Show to Rental and trigger LE creation. US751
    **/
    public static void checkRentalSwitchAndBuildLE( Event__c[] newList, Map<Id,Event__c> oldMap ){
        if(newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty() ){
            Set<Id> eventIDsToProcess = new Set<Id>();
            for(Event__c event : newList){
                if(oldMap.containsKey(event.Id) 
                    && ((event.RecordTypeId == RT_RENTAL_ID && oldMap.get(event.Id).RecordTypeId == RT_PROMOTEDSHOW_ID)
                        || (event.RentalBuildOption__c == 'Build Using Rental Accounts' && oldMap.get(event.Id).RentalBuildOption__c == 'Build as a Promoted Show'))
                ){
                    eventIDsToProcess.add(event.Id);
                }
            }

            if(eventIDsToProcess != null && !eventIDsToProcess.isEmpty()){
                System.enqueueJob(new LNE_FinancialCalculatorQueueable(eventIDsToProcess, 'BuildRentalLedgerEntries'));
            }
        }
    }

    /**
     *  Checks if recordtype is rental and triggers LE creation based on the rental build option. US751
    **/
    public static void buildRentalLE( Event__c[] newList, Map<Id,Event__c> oldMap ){
        //Run only on insert.
        if(newList != null && !newList.isEmpty() && (oldMap == null || oldMap.isEmpty()) ){
            Set<Id> eventIDsforRentalProcess = new Set<Id>();
            Set<Id> eventIDsforPromotedProcess = new Set<Id>();
            
            for(Event__c event : newList){
                if (event.RecordTypeId == RT_RENTAL_ID){
                    if (event.RentalBuildOption__c == 'Build Using Rental Accounts'){
                        eventIDsforRentalProcess.add(event.Id);
                    }else if (event.RentalBuildOption__c == 'Build as a Promoted Show') {
                        eventIDsforPromotedProcess.add(event.Id);
                    }
                }
            }

            if(eventIDsforRentalProcess != null && !eventIDsforRentalProcess.isEmpty()){
                System.enqueueJob(new LNE_FinancialCalculatorQueueable(eventIDsforRentalProcess, 'RecalcuateRentalSpecialLedgerEntry'));
            }
            if(eventIDsforPromotedProcess != null && !eventIDsforPromotedProcess.isEmpty()){
                System.enqueueJob(new LNE_FinancialCalculatorQueueable(eventIDsforPromotedProcess, 'RecalcuatePromotedShowLedgerEntries'));
            }
        }
    }

    /**
     *  Checks if recordtype is Buy Sell and ProjectedContributionMargin is changed to trigger LE recalculation. US746
    **/
    public static void buildBuySellLE( Event__c[] newList, Map<Id,Event__c> oldMap ){
        //Run only on insert.
        if(newList != null && !newList.isEmpty() && (oldMap == null || oldMap.isEmpty()) ){
            Set<Id> eventIDsforBuySellProcess = new Set<Id>();
            ChangedEvent objChange = null;
            if (oldMap == null){
                oldMap = new Map<Id, Event__c>();
            }

            for(Event__c newEvent : newList){
                if(oldMap.containsKey(newEvent.Id)){
                    Event__c oldEvent = oldMap.get(newEvent.Id);
                    objChange = new ChangedEvent(oldEvent, newEvent); 
                    if (newEvent.RecordTypeId == RT_BUYSELL_ID && objChange.notEquals('ProjectedContributionMargin__c') ){
                        eventIDsforBuySellProcess.add(newEvent.Id);
                    }
                }
            }

            if(eventIDsforBuySellProcess != null && !eventIDsforBuySellProcess.isEmpty()){
                System.enqueueJob(new LNE_FinancialCalculatorQueueable(eventIDsforBuySellProcess, 'RecalculateBuySellLedgerEntries'));
            }
        }
    }


    /**
     *  Internal class to represent the changes from the object.
    **/
    class ChangedEvent extends LNE_SObjectChange {
        
        ChangedEvent( Event__c oldObject, Event__c newObject ){
            super( oldObject, newObject );
        }
        
        Event__c getNewEvent(){
            return( (Event__c)this.newObject );
        }
        
        Event__c getOldEvent(){
            return( (Event__c)this.oldObject );
        }
    }
}