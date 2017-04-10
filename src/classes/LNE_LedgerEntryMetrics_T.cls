/**
 *	Trigger logic to check for changes on any fields that would cause the
 *	financial calculator to fire off
 *	@author Daniel Nakonieczny
 **/
public with sharing class LNE_LedgerEntryMetrics_T {
    private static String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
    private static String RT_COGS = 'LedgerEntry__c.COGS';
    private static String RT_CONTRA = 'LedgerEntry__c.Contra';
    private static String RT_TICKETREVENUE = 'LedgerEntry__c.TicketRevenue';
    private static String RT_COPROMOTEREVENUE = 'LedgerEntry__c.CoPromoteRevenue';
    private static String RT_EXPENSES = 'LedgerEntry__c.Expenses';
    private static String RT_COPROMOTEEXPENSE = 'LedgerEntry__c.CoPromoteExpense';
    private static String RT_TALENTFEES = 'LedgerEntry__c.TalentFees';
    private static String RT_OTHER = 'LedgerEntry__c.Other';

    private static String RT_GOSPEL_BRUNCH = 'Event__c.GospelBrunch';
    private static String RT_BUYSELL = 'Event__c.BuySell';
    private static String RT_HOLD = 'Event__c.Hold';
    private static String RT_TBDEVENTS = 'Event__c.TBDEvents';
    private static String RT_RENTAL = 'Event__c.Rental';

	private static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
	    new String[]{ RT_EXPENSES, RT_GOSPEL_BRUNCH, RT_BUYSELL,  RT_ANCILLARY, RT_COGS, RT_CONTRA, RT_TICKETREVENUE
                        , RT_COPROMOTEREVENUE, RT_COPROMOTEEXPENSE, RT_TALENTFEES, RT_OTHER, RT_HOLD, RT_TBDEVENTS, RT_RENTAL}
    );

    private static Id RT_GOSPEL_BRUNCH_ID = recordTypeMap.get( RT_GOSPEL_BRUNCH );
    private static Id RT_BUYSELL_ID = recordTypeMap.get( RT_BUYSELL );
    private static Id RT_HOLD_ID = recordTypeMap.get( RT_HOLD );
    private static Id RT_TBDEVENTS_ID = recordTypeMap.get( RT_TBDEVENTS );
    private static Id RT_RENTAL_ID = recordTypeMap.get( RT_RENTAL );
    private static Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );
    private static Id RT_COGS_ID = recordTypeMap.get( RT_COGS );
    private static Id RT_CONTRA_ID = recordTypeMap.get( RT_CONTRA );
    private static Id RT_TICKETREVENUE_ID = recordTypeMap.get( RT_TICKETREVENUE );
    private static Id RT_COPROMOTEREVENUE_ID = recordTypeMap.get( RT_COPROMOTEREVENUE );
    private static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    private static Id RT_COPROMOTEEXPENSE_ID = recordTypeMap.get( RT_COPROMOTEEXPENSE );
    private static Id RT_TALENTFEES_ID = recordTypeMap.get( RT_TALENTFEES );
    private static Id RT_OTHER_ID = recordTypeMap.get( RT_OTHER );


	/**
     *  Checks if any fields changed that would require a recalculation of event totals
     *  @param newList LedgerEntry__c[]
     *  @param oldMap Map<Id,LedgerEntry__c>
     *  @return LedgerEntry__c[] - list of ledgers updated.
    **/
    
    public static LedgerEntry__c[] execute( LedgerEntry__c[] newList, Map<Id,LedgerEntry__c> oldMap ){
    	List<LedgerEntry__c> changedLedgers = new List<LedgerEntry__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();
    	Set<Id> flashEventIds = new Set<Id>();
        ChangedLedgerEntry objChange = null;

 		if (oldMap == null){
            oldMap = new Map<Id, LedgerEntry__c>();
        }

        for (LedgerEntry__c newLedger : newList ){
            if(oldMap.containsKey(newLedger.Id)){
                
                LedgerEntry__c oldLedger = oldMap.get(newLedger.Id);
                objChange = new ChangedLedgerEntry(oldLedger, newLedger);
                
                if(
                    objChange.notEquals('BaseAmount__c') ||
                    objChange.notEquals('Min__c') ||
                    objChange.notEquals('Max__c') ||
                    objChange.notEquals('ContraAmount__c') ||
                    objChange.notEquals('ContraPercent__c') ||
                    objChange.notEquals('X3rdPartyPercent__c') ||
                    objChange.notEquals('OfferRate__c') ||
                    objChange.notEquals('OfferMin__c') ||
                    objChange.notEquals('OfferMax__c') ||
                    objChange.notEquals('InHouseRate__c') ||
                    objChange.notEquals('InHouseMin__c') ||
                    objChange.notEquals('InHouseMax__c') ||
                    objChange.notEqualsStr('RateType__c', false) ||
                    objChange.notEqualsStr('ContraType__c', false) ||
                    objChange.notEqualsStr('ApplyTicketScale__c', false) ||
                    objChange.notEqualsStr('TicketScaleList__c', false) ||
                    objChange.notEqualsStr('OfferRateType__c', false) ||
                    objChange.notEqualsStr('InHouseRateType__c', false) ||
                    objChange.notEquals('EndofTourDinner__c') ||
                    objChange.notEquals('PerDiems__c') ||
                    objChange.notEquals('TE__c') ||
                    objChange.notEquals('TourRep__c') ||
                    objChange.notEquals('MiscExpense__c') || 
                    objChange.notEquals('InHouseProjection__c') || 
                    objChange.notEquals('COGSAtForecast__c')
                ) {
                    if (objChange.getNewLedgerEntry().Event__c != null) {
                        listOfRelatedEventIds.add(objChange.getNewLedgerEntry().Event__c);  
                    }
                    changedLedgers.add(objChange.getNewLedgerEntry());
                  }
                // US635  
                if (objChange.notEquals('CurrentFlash__c')){
                    flashEventIds.add(objChange.getNewLedgerEntry().Event__c);
                }

                processSettlementLedger(objChange);
            } else {
                if (newLedger.Event__c != null) {
                    listOfRelatedEventIds.add(newLedger.Event__c); 
                }
                changedLedgers.add(newLedger);
            }

            
        }
        
        //US635 - reset flash complete flag so the button is reactivated.
        if (flashEventIds.size() > 0){
            List<Event__c> updatedEvents = new List<Event__c>();
            for(Event__c evt : [select id, FlashComplete__c from Event__c where Id in :flashEventIds]){
                if (evt.FlashComplete__c == true){
                    evt.FlashComplete__c = false;
                    updatedEvents.add(evt);
                }
            }
            if(updatedEvents.size() > 0)
                update updatedEvents;
        }
		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return changedLedgers;
    }

    /**
     *  Sets Settle at Actual to true if parent Event__r.AdvertisingSettlementPlan__c is Settle at Actual
     *  SHOULD ONLY RUN BEFORE INSERT
     *  @param newList LedgerEntry__c[]]
    **/
    public static void checkSettleAtActual(LedgerEntry__c[] newList) {
        for (LedgerEntry__c newLedger : newList ) {
            if (newLedger.RecordTypeId == RT_EXPENSES_ID && String.isNotBlank(newLedger.EventAdvertisingSettlementPlan__c) && newLedger.Category__c == 'Advertising Expense') {
                if (newLedger.EventAdvertisingSettlementPlan__c == 'Settle at Actual' && newLedger.SettleAtActual__c == false) {
                    newLedger.SettleAtActual__c = true;
                }
                
                if (newLedger.EventAdvertisingSettlementPlan__c == 'Settle at Offer' && newLedger.SettleAtActual__c == true) {
                    newLedger.SettleAtActual__c = false;
                }
            }
        }
    }

    /**
     *  On Ledger Entry Insert - Sets Ledger Entry defaults based on Related Event. 
     *  On Ledger Entry Update - Sets Ledger Entry fields based on changed rollup fields.
     *  For Ledger Entry on a Gospel Brunch event, the Plan Amount and Projection Amount should be set to 0, Except for GL Accounts 42019, 40265, 50368, 50369
     *  For Ledger Entry on a Buy event, the Plan Amount and Projection Amount should be set to 0, Except for GL Accounts 42019 
     *  @param newList LedgerEntry__c[]]
    **/
    public static void setLEDefaults(LedgerEntry__c[] newList, Map<Id,LedgerEntry__c> oldMap ) {
        if(newList != null && !newList.isEmpty()){
            set<Id> eventIds = new set<Id>();
            set<Id> glAccountIds = new set<Id>();
            //If the event or GL Account is populated on LE, collect the Ids to get the related object attributes.
            for (LedgerEntry__c newLedger : newList ) {
                if(newLedger.Event__c != null){
                    eventIds.add(newLedger.Event__c);    
                } 
                if(newLedger.GLAccount__c != null){
                    glAccountIds.add(newLedger.GLAccount__c);  
                }
            }

            set<String> gospelGLs = new set<String>{'40264','40265','50368','50369'};
            set<String> buySellGLs = new set<String>{'42019'};
            Map<Id, Event__c> eventMap = new Map<Id, Event__c>();
            Map<Id, GLAccount__c> glAccountMap = new Map<Id, GLAccount__c>();
            if(!eventIds.isEmpty()){
                eventMap = new Map<Id, Event__c>([Select Id, RecordTypeId, Geography__c, Division__c, OfficeName__c 
                                                            , Venue__r.PrimaryOffice__r.Name, Venue__r.OwnershipType__c
                                                            , RentalBuildOption__c , Status__c  
                                                            from Event__c where Id IN :eventIds]);
            }
            if(!glAccountIds.isEmpty()){
                glAccountMap = new Map<Id, GLAccount__c>([Select Id, Category__c 
                                                            from GLAccount__c where Id IN :glAccountIds]);
            }
            system.debug(LoggingLevel.Error, '@@@ glAccountMap - '+ glAccountMap);

            //now loop through ledger entries and if event is Populated set defaults 
            
            for (LedgerEntry__c newLedger : newList ) {
                if (newLedger.Event__c != NULL){
                    //If insert set the LE defaults
                    if((oldMap == NULL || oldMap.isEmpty()) && eventMap.get(newLedger.Event__c) != null 
                        && eventMap.get(newLedger.Event__c).Geography__c != NULL){
                        newLedger.Geography__c = eventMap.get(newLedger.Event__c).Geography__c;
                        newLedger.Division__c = eventMap.get(newLedger.Event__c).Division__c;
                        newLedger.OfficeName__c = eventMap.get(newLedger.Event__c).OfficeName__c;
                        newLedger.PrimaryVenueOffice__c = eventMap.get(newLedger.Event__c).Venue__r.PrimaryOffice__r.Name;
                        newLedger.VenueOwnerShip__c = eventMap.get(newLedger.Event__c).Venue__r.OwnershipType__c;
                    }

                    //If event recordtype is Gospel Bruch then reset Plan and Projection amount to 0, except for GL Accounts 40264, 40265, 50368, 50369
                    if(eventMap.get(newLedger.Event__c) != null  && ((eventMap.get(newLedger.Event__c).RecordTypeId == RT_GOSPEL_BRUNCH_ID && !gospelGLs.contains(newLedger.GLCode__c))
                        || (eventMap.get(newLedger.Event__c).RecordTypeId == RT_BUYSELL_ID && !buySellGLs.contains(newLedger.GLCode__c))
                        || (eventMap.get(newLedger.Event__c).RecordTypeId == RT_RENTAL_ID)
                        )
                    ) {
                        newLedger.PlanAmount__c = 0;
                        newLedger.ProjectionAmount__c = 0;
                    }
                }

                if(newLedger.RecordTypeId != NULL){
                    if(newLedger.RecordTypeId == RT_ANCILLARY_ID || newLedger.RecordTypeId == RT_COGS_ID 
                        || newLedger.RecordTypeId == RT_CONTRA_ID || newLedger.RecordTypeId == RT_TICKETREVENUE_ID
                        || newLedger.RecordTypeId == RT_COPROMOTEREVENUE_ID){
                        newLedger.HighLevelType__c = 'Revenues';
                    }else if( newLedger.RecordTypeId == RT_EXPENSES_ID || newLedger.RecordTypeId == RT_COPROMOTEEXPENSE_ID 
                                || newLedger.RecordTypeId == RT_TALENTFEES_ID || newLedger.RecordTypeId == RT_OTHER_ID){
                        newLedger.HighLevelType__c = 'Expenses';
                    }
                }

                //set LE category based on GL Account
                if(oldMap == NULL || (newLedger.Category__c ==null && newLedger.GLAccount__c != null ) 
                    || (oldMap != NULL && !oldMap.isEmpty() && oldMap.containsKey(newLedger.Id) 
                    && newLedger.GLAccount__c != null && newLedger.GLAccount__c != oldMap.get(newLedger.Id).GLAccount__c)
                    ){
                    system.debug(LoggingLevel.Error, '@@@ GLAccount.Category__c - '+ glAccountMap.get(newLedger.GLAccount__c));
                    if(glAccountMap.get(newLedger.GLAccount__c) != null){
                        newLedger.Category__c = glAccountMap.get(newLedger.GLAccount__c).Category__c;
                    }
                    system.debug(LoggingLevel.Error, '@@@ newLedger.Category__c before - '+ newLedger.Category__c + ' - '+newLedger.GLAccount__c + ' - '+newLedger.Id);

                }
                system.debug(LoggingLevel.Error, '@@@ newLedger.Category__c after - '+ newLedger.Category__c + ' - '+newLedger.GLAccount__c + ' - '+newLedger.Id);

                ChangedLedgerEntry objChange = null;
                if (oldMap == null){
                	//-- Initializing oldMap to a new blank map here will make the code run the 'else' part when iterating over
                	//-- the second (and more) records, so this would only work correctly for one LedgerEntry__c in 'newList'
                    //oldMap = new Map<Id, LedgerEntry__c>();
                }else{
                    LedgerEntry__c oldLedger = oldMap.get(newLedger.Id);
                    objChange = new ChangedLedgerEntry(oldLedger, newLedger);
                }

                //If Update set the values based on changed rollups.
                if(oldMap != NULL && !oldMap.isEmpty() && oldMap.containsKey(newLedger.Id) && objChange != null ){
                
                    if(objChange.notEquals('RollUpOfferAtSellout__c')){
                        newLedger.OfferAtSellout__c = newLedger.RollUpOfferAtSellout__c;
                    }

                    if(objChange.notEquals('RollUpOfferAtProjection__c')){
                        newLedger.OfferAtProjection__c = newLedger.RollUpOfferAtProjection__c;
                    }
                    if(objChange.notEquals('RollUpInHouseAtSellout__c')){
                        newLedger.InHouseAtSellout__c = newLedger.RollUpInHouseAtSellout__c;
                    }
                    if(objChange.notEquals('RollUpExpenseAdjustmentAtSellout__c')){
                        newLedger.ExpenseAdjustmentAtSellout__c = newLedger.RollUpExpenseAdjustmentAtSellout__c;
                    }
                    if(objChange.notEquals('RollUpExpenseAdjustment__c')){
                        newLedger.ExpenseAdjustment__c = newLedger.RollUpExpenseAdjustment__c;
                    }

                    if(objChange.notEquals('RollUpGrossRevenue__c')){
                        newLedger.GrossRevenue__c = newLedger.RollUpGrossRevenue__c;
                        if(newLedger.RollUpGrossRevenue__c != null && newLedger.RollUpGrossRevenue__c != 0){
                            newLedger.ContraPercentAtForecast__c = (newLedger.RollUpContraAtForecast__c / newLedger.RollUpGrossRevenue__c * 100);
                        }
                    }
                    
                    if(objChange.notEquals('RollUpGrossPerPaid__c')){
                        newLedger.GrossPerPaid__c = newLedger.RollUpGrossPerPaid__c;
                    }
                    if(objChange.notEquals('RollUpContraAtForecast__c')){
                        newLedger.ContraAtForecast__c = newLedger.RollUpContraAtForecast__c;
                        if(newLedger.RollUpGrossRevenue__c != null && newLedger.RollUpGrossRevenue__c != 0){
                            newLedger.ContraPercentAtForecast__c = (newLedger.RollUpContraAtForecast__c / newLedger.RollUpGrossRevenue__c * 100);
                        }
                    }
                    if(objChange.notEquals('RollUpNetRevenue__c')){
                        newLedger.NetRevenue__c = newLedger.RollUpNetRevenue__c;
                    }
                    if(objChange.notEquals('RollUpNetPerPaid__c')){
                        newLedger.NetPerPaid__c = newLedger.RollUpNetPerPaid__c;
                    }
                    if(objChange.notEquals('RollUpCOGSAtForecast__c')){
                        newLedger.COGSAtForecast__c = newLedger.RollUpCOGSAtForecast__c;
                    }
                    if(objChange.notEquals('RollUpPromoterAmount__c')){
                        newLedger.PromoterAmount__c = newLedger.RollUpPromoterAmount__c;
                    }
                    if(objChange.notEquals('RollUpArtistAmount__c')){
                        newLedger.ArtistAmount__c = newLedger.RollUpArtistAmount__c;
                    }
                    if(objChange.notEquals('RollUpVenueAmount__c')){
                        newLedger.VenueAmount__c = newLedger.RollUpVenueAmount__c;
                    }
                    if(objChange.notEquals('RollUpLNTouringAmount__c')){
                        newLedger.LNTouringAmount__c = newLedger.RollUpLNTouringAmount__c;
                    }
                    if(objChange.notEquals('RollUpSettlement__c')){
                        newLedger.Settlement__c = newLedger.RollUpSettlement__c;
                    }
                    if(objChange.notEquals('RollUpCOGSAtSellout__c')){
                        newLedger.COGSAtSellout__c = newLedger.RollUpCOGSAtSellout__c;
                    }
                    if(objChange.notEquals('RollUpContraAtSellout__c')){
                        newLedger.ContraatSellout__c = newLedger.RollUpContraAtSellout__c;
                    }
                    if(objChange.notEquals('RollUpGrossRevenueAtSellout__c')){
                        newLedger.GrossRevenueatSellout__c = newLedger.RollUpGrossRevenueAtSellout__c;
                    }
                    if(objChange.notEquals('RollUpNetRevenueAtSellout__c')){
                        newLedger.NetRevenueatSellout__c = newLedger.RollUpNetRevenueAtSellout__c;
                    }
                    if(objChange.notEquals('RollUpCurrentFlash__c')){
                        newLedger.CurrentFlash__c = newLedger.RollUpCurrentFlash__c;
                    }
                    if(objChange.notEquals('RollUpOriginalFlash__c')){
                        newLedger.OriginalFlash__c = newLedger.RollUpOriginalFlash__c;
                    }    
                    if(objChange.notEquals('RollUpInHouseProjection__c')){
                        newLedger.InHouseProjection__c = newLedger.RollUpInHouseProjection__c;
                    }
                }

                
                if((newLedger.Event__c != null && newLedger.Event__r.RecordTypeId != RT_HOLD_ID
                    && newLedger.Event__r.RecordTypeId != RT_GOSPEL_BRUNCH_ID
                    && newLedger.Event__r.RecordTypeId != RT_TBDEVENTS_ID
                    && newLedger.Event__r.RecordTypeId != RT_BUYSELL_ID
                    && ( !( newLedger.Event__r.RecordTypeId == RT_RENTAL_ID
                                && eventMap.get(newLedger.Event__c).RentalBuildOption__c == 'Build as a Promoted Show'
                            )
                        )
                    )
                    || newLedger.RecordTypeId == RT_ANCILLARY_ID
                    || newLedger.RecordTypeId == RT_CONTRA_ID
                    || newLedger.RecordTypeId == RT_COGS_ID
                    || newLedger.RecordTypeId == RT_EXPENSES_ID
                ){
                    if(newLedger.RecordTypeId == RT_ANCILLARY_ID && newLedger.Event__c != null 
                        && eventMap.get(newLedger.Event__c) != null &&  eventMap.get(newLedger.Event__c).Status__c != null
                        && (oldMap == null || (oldMap != null && objChange != null && 
                                (   objChange.notEquals('GrossRevenue__c')
                                    || objChange.notEquals('NetRevenue__c')
                                    || objChange.notEquals('NonLNEVenueCoProShareAtProjection__c')
                                )
                            )
                        )
                    ){
                        //With Contra - Plan
                        if(newLedger.ContraAccount__c == TRUE && newLedger.EventStatusStage__c == 'Plan'){
                        	if (newLedger.GrossRevenue__c != null && newLedger.NonLNEVenueCoProShareAtProjection__c != null) {
                            	newLedger.PlanAmount__c = newLedger.GrossRevenue__c - newLedger.NonLNEVenueCoProShareAtProjection__c;
                        	}
                        }
                        //Without Contra - Plan
                        else if(newLedger.ContraAccount__c == FALSE && newLedger.EventStatusStage__c == 'Plan'){
                        	if (newLedger.NetRevenue__c != null && newLedger.NonLNEVenueCoProShareAtProjection__c != null) {
                            	newLedger.PlanAmount__c = newLedger.NetRevenue__c - newLedger.NonLNEVenueCoProShareAtProjection__c;
                        	}
                        }
                        //With Contra - Projection
                        if(newLedger.ContraAccount__c == TRUE && newLedger.EventStatusStage__c == 'Projection'){
                        	if (newLedger.GrossRevenue__c != null && newLedger.NonLNEVenueCoProShareAtProjection__c != null) {
                        		newLedger.ProjectionAmount__c = newLedger.GrossRevenue__c - newLedger.NonLNEVenueCoProShareAtProjection__c;
                        	}
                        }
                        //Without Contra - Projection
                        else if(newLedger.ContraAccount__c == FALSE && newLedger.EventStatusStage__c == 'Projection'){
                        	if (newLedger.NetRevenue__c != null && newLedger.NonLNEVenueCoProShareAtProjection__c != null) {
                            	newLedger.ProjectionAmount__c = newLedger.NetRevenue__c - newLedger.NonLNEVenueCoProShareAtProjection__c;
                        	}
                        }
                    }
                    else if( newLedger.RecordTypeId == RT_CONTRA_ID && newLedger.Event__c != null 
                        && eventMap.get(newLedger.Event__c) != null &&  eventMap.get(newLedger.Event__c).Status__c != null
                        && (oldMap == null || (oldMap != null && objChange != null && objChange.notEquals('ContraAtForecast__c')))
                    ){
                        if(newLedger.EventStatusStage__c == 'Plan'){
                            newLedger.PlanAmount__c = newLedger.ContraAtForecast__c;
                        }else if(newLedger.EventStatusStage__c == 'Projection'){
                            newLedger.ProjectionAmount__c = newLedger.ContraAtForecast__c;
                        }
                    } 
                    else if( newLedger.RecordTypeId == RT_COGS_ID && newLedger.Event__c != null 
                        && eventMap.get(newLedger.Event__c) != null &&  eventMap.get(newLedger.Event__c).Status__c != null
                        && (oldMap == null || (oldMap != null && objChange != null && (
                                objChange.notEquals('COGSAtForecast__c') || objChange.notEquals('NonLNEVenueCoProShareAtProjection__c'))
                            )
                        )
                    ){
                        if(newLedger.EventStatusStage__c == 'Plan'){
                        	if (newLedger.COGSAtForecast__c != null && newLedger.NonLNEVenueCoProShareAtProjection__c != null) {
                        		newLedger.PlanAmount__c = newLedger.COGSAtForecast__c - newLedger.NonLNEVenueCoProShareAtProjection__c;	
                        	}
                        }else if(newLedger.EventStatusStage__c == 'Projection'){
                        	if (newLedger.COGSAtForecast__c != null && newLedger.NonLNEVenueCoProShareAtProjection__c != null) {
                            	newLedger.ProjectionAmount__c = newLedger.COGSAtForecast__c - newLedger.NonLNEVenueCoProShareAtProjection__c;
                        	}
                        }
                    } 
                    else if( newLedger.RecordTypeId == RT_EXPENSES_ID && newLedger.Event__c != null 
                        && eventMap.get(newLedger.Event__c) != null &&  eventMap.get(newLedger.Event__c).Status__c != null
                        && (oldMap == null || (oldMap != null && objChange != null && objChange.notEquals('InHouseProjection__c')))
                    ){
                        if(newLedger.EventStatusStage__c == 'Plan'){
                            newLedger.PlanAmount__c = newLedger.InHouseProjection__c;
                        }else if(newLedger.EventStatusStage__c == 'Projection'){
                            newLedger.ProjectionAmount__c = newLedger.InHouseProjection__c;
                        }
                    }
                }
            }
        }
    }

    private static void processSettlementLedger(ChangedLedgerEntry ledger) {
        List<String> fieldsToCheck = new List<String>{'PromoterAmount','ArtistAmount','VenueAmount','LNTouringAmount'};
        Boolean settlementRateTypeChanged = ledger.notEqualsStr('SettlementRateType__c', true);

        for (String field : fieldsToCheck) {
            if (ledger.notEquals(field+'__c') && ledger.equals(field+'Rate__c') && settlementRateTypeChanged == false) {
                populateSettlementValue(ledger.getNewLedgerEntry(), field);
            }
        }
    }

    private static void populateSettlementValue(LedgerEntry__c l, String fieldName) {
        String source = fieldName + '__c';
        String destination = fieldName + 'Rate__c';
        l.put(destination, l.get(source));
        l.SettlementRateType__c = 'Flat';
    }
    
    /**
     *  Recalculates for deleted LedgerEntries
     *  @param LedgerEntries[] - list of deleted LedgerEntries.
     *  @return LedgerEntries[] - list of LedgerEntries updated.
    **/
    
     public static LedgerEntry__c[] executeDelete( LedgerEntry__c[] deletedList ){
    	List<LedgerEntry__c> changedLedgers = new List<LedgerEntry__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();

 		for (LedgerEntry__c deletedLedger : deletedList){
 		    if (deletedLedger.Event__c != null) {
            	listOfRelatedEventIds.add(deletedLedger.Event__c);	
            }
            changedLedgers.add(deletedLedger);
 		}
 		
 		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return changedLedgers;
    }

    /**
     *  Internal class to represent the changes from the object.
    **/
    class ChangedLedgerEntry extends LNE_SObjectChange {
        
        ChangedLedgerEntry( LedgerEntry__c oldObject, LedgerEntry__c newObject ){
            super( oldObject, newObject );
        }
        
        LedgerEntry__c getNewLedgerEntry(){
            return( (LedgerEntry__c)this.newObject );
        }
    }
}
