global class LNE_TicketRevenueTab_CX {
    private final SObject parent;

    public String eventId {get;set;}
    public Integer numPlatinumTicketScales {get;set;}
    public Event__c eventMetrics {get;set;}
    public String gridLostFocusPollInterval;
    public String gridBuddyRecordsToShow {get;set;}
    public Boolean showBothPlanAndProjectionButtons {get;set;}
    public Integer showGridsAsReadOnly {get;set;}
    public String currentGridType {get;set;}
    public Boolean showAuditAvailableMessage {get;set;}
    public Boolean showAuditAvailableMessageForSelectedDateTime {get;set;}
    public Boolean showConvertToMultiscaleButton {get;set;}
    public Boolean showRevertToSingleScaleButton {get;set;}
    public Boolean showEventDateTimeTabs {get;set;}
    public List<AggregateResult> dateTimeSummary {get;set;}
    public Map<Id, EventDateTime__c> dateTimeMap {get;set;}
    public String delimiter {get {
    	return DATA_SETTINGS.CombinedKeyDelimiter__c;
    }}
    public List<LNE_EventDateTimeUtil_T.EventDateTime> sortedEventDates {get;set;}
    public String edtAuditMap {get;set;}
    public String eventDateTimeToImport {get;set;}
    public Boolean multipleEventDateTimes {get;set;}
    public String dateTimeMapJSON {get;set;}
    public String fieldToHide {get;set;}
    
    private static final GeneralSettings__c GENERAL_SETTINGS = GeneralSettings__c.getInstance();
    private static final DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
    
    private static String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
    private static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_ANCILLARY }
    ); 

    private static Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );
    
    private Map<Id, Boolean> auditAvailableForEDT = new Map<Id, Boolean>();

    public LNE_TicketRevenueTab_CX(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        eventId = parent.Id;
        init();
    }
    
    public void init() {
        showAuditAvailableMessage = false;
        showAuditAvailableMessageForSelectedDateTime = false;
        multipleEventDateTimes = false;
        getEventMetrics();
        showBothPlanAndProjectionButtons = false;
        showConvertToMultiscaleButton = false;
        showRevertToSingleScaleButton = false;
        
        
        //- This is used in GridBuddy "ro" URL parameter. 0 = Editable, 1 = Read Only
        showGridsAsReadOnly = 0;
        
        if (!String.isBlank(eventId) && eventMetrics != null) {
            gridBuddyRecordsToShow = getGridBuddyDataTypeToShow(eventMetrics.StatusStage__c);
            showBothPlanAndProjectionButtons = eventMetrics.StatusStage__c == 'Projection';
            currentGridType = eventMetrics.StatusStage__c;
            
            if (eventMetrics.UsingTicketFeed__c == true) {
                gridBuddyRecordsToShow = getGridBuddyDataTypeToShow('Projection');
                currentGridType = 'Projection';
            }
            
            checkButtonAccess();
        }

        checkPlatinumTicketScales();
        getDateTimeSummary();
    }
    
    public void checkButtonAccess() {
    	showConvertToMultiscaleButton = eventMetrics.UsingMultiScale__c == false && eventMetrics.EventDateTimes__r.size() > 1;
        showRevertToSingleScaleButton = eventMetrics.UsingMultiScale__c == true && eventMetrics.UsingTicketFeed__c == false;
        showEventDateTimeTabs = eventMetrics.UsingMultiScale__c == true;
    }

    public void checkPlatinumTicketScales() {
        numPlatinumTicketScales = [SELECT COUNT() FROM TicketScale__c WHERE Event__c = :eventId AND Type__c = 'Platinum' AND StageType__c = :currentGridType];
    }
    
    public PageReference dropCountGridSave(){

        if (eventMetrics.ProjectedDropCountPct__c == null) {
            eventMetrics.ProjectedDropCountPct__c = 100;
        }

        if (eventMetrics.DropCountAdjustment__c == null) {
            eventMetrics.DropCountAdjustment__c = 0;
        }
            
        update eventMetrics;

        return( null );
    }

    public String getGridLostFocusPollInterval() {
        String res = GENERAL_SETTINGS.Grid_Lost_Focus_Poll_Interval__c;
        return res;
    }
    
    public PageReference getEventMetrics(){
        eventMetrics = [SELECT  ShowCount__c, SelloutGrossSales__c, PlatinumLift__c, GrossPotential__c, AdjustedGrossPotential__c, NetGrossPotential__c,
                                ProjectedGrossSales__c, ProjectedGross__c,ProjectedAdjustedGross__c, ProjectedNetGross__c, Status__c, StatusStage__c, UsingTicketFeed__c,
                                ProjectedPaidTickets__c, HidePreviouslyForecastedLiftBfrTxs__c, HidePreviouslyForecastedProjPdTkt__c, PreviouslyForecastedGrossSales__c,
                                PreviouslyForecastedLiftBeforeFee__c, PreviouslyForecastedProjPaidTickets__c, UsingMultiScale__c, ProjectedDropCountPct__c, DropCountAdjustment__c,
                                (SELECT EventDate__c, StartTime__c, PreviouslyForecastedGrossSales__c,PreviouslyForecastedProjPaidTickets__c,
                                        PrevForecastedPlatinumLiftbeforeFee__c, HidePreviouslyForecastedProjPdTkt__c,
                                        HidePreviouslyForecastedLiftBfrTxs__c, UsingTicketFeed__c
                                 FROM EventDateTimes__r ORDER BY EventDate__c ASC NULLS LAST)
                        FROM Event__c WHERE Id = :eventId][0]; 
            
        dateTimeMap = new Map<Id, EventDateTime__c>(eventMetrics.EventDateTimes__r);
        dateTimeMapJSON = JSON.serialize(dateTimeMap);
        
        sortedEventDates = new List<LNE_EventDateTimeUtil_T.EventDateTime>();

        multipleEventDateTimes = eventMetrics.EventDateTimes__r.size() > 1;
        
        for (EventDateTime__c edt : eventMetrics.EventDateTimes__r) {
        	sortedEventDates.add(new LNE_EventDateTimeUtil_T.EventDateTime(edt));
        }
        
        sortedEventDates.sort();
        
        if (eventMetrics.UsingMultiScale__c == false && eventMetrics.UsingTicketFeed__c == false && eventMetrics.StatusStage__c == 'Projection') {
            List<TicketScale__c> tsList = [SELECT Id FROM TicketScale__c WHERE Event__c = :eventMetrics.Id AND StageType__c = 'Audit' LIMIT 1];
            
            if (tsList.size() > 0) {
                showAuditAvailableMessage = true;
            }
        }

        if (eventMetrics.UsingMultiScale__c == true && eventMetrics.StatusStage__c == 'Projection') {
            List<TicketScale__c> tsList = [SELECT EventDateTime__c FROM TicketScale__c WHERE Event__c = :eventMetrics.Id AND StageType__c = 'Audit' AND EventDateTime__c <> NULL];
            
            if (tsList.size() > 0) {
                for (TicketScale__c ts : tsList) {
                    auditAvailableForEDT.put(ts.EventDateTime__c, true);
                }
            }
        }

        edtAuditMap = JSON.serialize(auditAvailableForEDT);

        return null;
    }
    
    public void showPlan() {
        gridBuddyRecordsToShow = getGridBuddyDataTypeToShow('Plan');
        
        //- If the Event is in the Projection stage type, show Plan grids in read only
        showGridsAsReadOnly = eventMetrics.StatusStage__c == 'Projection' ? 1 : 0;
        currentGridType = 'Plan';
        checkPlatinumTicketScales();
        checkButtonAccess();
        getDateTimeSummary();
    }
    
    public void showProjection() {
        gridBuddyRecordsToShow = getGridBuddyDataTypeToShow('Projection');
        showGridsAsReadOnly = 0;
        currentGridType = 'Projection';
        checkPlatinumTicketScales();
        checkButtonAccess();
        getDateTimeSummary();
    }

    public void hideFieldForEventDateTime() {
        String edtToImport = eventDateTimeToImport;
        String field = fieldToHide;

        if (String.isNotBlank(edtToImport) && String.isNotBlank(field)) {
            stopCalculator();

            EventDateTime__c edt = new EventDateTime__c(Id=edtToImport);
            edt.put(field, true);
            update edt;

            getEventMetrics();
        }
    }

    public void importAuditFeed() {
        if (multipleEventDateTimes == false) {
            importAuditFeedSingleScale();
        } else {
            importAuditFeedMultiscale(null);
        }
    }

    public void importAuditFeedForCurrentDateTime() {
        stopCalculator();

        String edtToImport = eventDateTimeToImport;

        if (String.isNotBlank(edtToImport)) {
            importAuditFeedMultiscale(edtToImport);
        }
    }



    //-- @TODO: Find a way to combine importAuditFeedSingleScale() and  importAuditFeedMultiscale()

    //-- SINGLE SCALE

    public void importAuditFeedSingleScale() {
        stopCalculator();
        Decimal platinumLiftBeforeFee = 0.0;
        
        List<TicketScale__c> tsList = [SELECT Event__c, StageType__c, LiftBeforeFee__c, Type__c FROM TicketScale__c WHERE Event__c = :eventMetrics.Id AND (StageType__c = 'Projection' OR StageType__c = 'Audit')];
        for (TicketScale__c ts : tsList) {
            if (ts.StageType__c == 'Projection') {
                ts.StageType__c = 'Obsolete';
                
                if (String.isNotBlank(ts.Type__c) && ts.Type__c.contains('Platinum') && ts.LiftBeforeFee__c != null) {
                	platinumLiftBeforeFee += ts.LiftBeforeFee__c;
                }
            }
            
            if (ts.StageType__c == 'Audit') {
                ts.StageType__c = 'Projection';    
            }

            LNE_EventDateTimeUtil_T.populateGridBuddyFilterFields(ts);
        }

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
                                           WHERE Event__c = :eventMetrics.Id
                                           AND StageType__c = 'Projection'];

        List<Deduction__c> clonedDeductions = new List<Deduction__c>();

        String ESCAPED_DELIMITER = DATA_SETTINGS.CombinedKeyDelimiter__c;
        if (ESCAPED_DELIMITER == '|') {
            ESCAPED_DELIMITER = '\\|';
        }
        
        for (Deduction__c d : deductions) {
            Deduction__c newDeduction = d.clone(false, true, false, false);
            newDeduction.StageType__c = 'Obsolete';
            LNE_EventDateTimeUtil_T.populateGridBuddyFilterFields(newDeduction);
            
            clonedDeductions.add(newDeduction);

            d.TicketScaleList__c = null;
        }

        List<LedgerEntry__c> ledgers = [SELECT TicketScaleList__c, (SELECT TicketScaleList__c FROM LedgerEntryBreakouts__r) FROM LedgerEntry__c WHERE Event__c = :eventMetrics.Id];
        List<LedgerEntryBreakout__c> breakouts = new List<LedgerEntryBreakout__c>();
        
        for (LedgerEntry__c le : ledgers) {
            le.TicketScaleList__c = null;
            
            for (LedgerEntryBreakout__c leb : le.LedgerEntryBreakouts__r) {
                leb.TicketScaleList__c = null;
                breakouts.add(leb);
            }
        }
        
        insert clonedDeductions;
        update tsList;
        update deductions;
        update ledgers;
        update breakouts;
        
        eventMetrics.UsingTicketFeed__c = true;
        eventMetrics.PreviouslyForecastedGrossSales__c  = eventMetrics.ProjectedGrossSales__c;
        eventMetrics.PreviouslyForecastedProjPaidTickets__c  = eventMetrics.ProjectedPaidTickets__c;
        eventMetrics.PreviouslyForecastedLiftBeforeFee__c  = platinumLiftBeforeFee;
        
        startCalculator();
    }





    //-- MULTI SCALE
    
    public void importAuditFeedMultiscale(String singleEventDateTimeId) {
        stopCalculator();

        if (eventMetrics.UsingMultiScale__c == false && multipleEventDateTimes == true) {
            convertToMultiScaleAndRunCalculator(false);
        }

        Set<Id> dateTimeIds = new Set<Id>();

        if (String.isNotBlank(singleEventDateTimeId)) {
            dateTimeIds.add(singleEventDateTimeId);
        } else {
            dateTimeIds.addAll(new Map<Id, EventDateTime__c>(eventMetrics.EventDateTimes__r).keySet());
        }
        
        Decimal platinumLiftBeforeFee = 0.0;

        List<TicketScale__c> tsList = [SELECT Event__c,
                                              StageType__c,
                                              EventDateTime__c,
                                              ProjectedGrossSales__c,
                                              ProjectedPaidTickets__c,
                                              LiftBeforeFee__c,
                                              Type__c
                                       FROM TicketScale__c
                                       WHERE Event__c = :eventMetrics.Id
                                       AND (StageType__c = 'Projection' OR StageType__c = 'Audit')
                                       AND EventDateTime__c IN :dateTimeIds];

        Map<Id, List<TicketScale__c>> eventDateTimeTicketScaleProjectionMap = new Map<Id, List<TicketScale__c>>();
        Map<Id, List<TicketScale__c>> eventDateTimeTicketScaleAuditMap = new Map<Id, List<TicketScale__c>>();
        Map<Id, Decimal> projectedGrossSales = new Map<Id, Decimal>();
        Map<Id, Decimal> projectedPaidTickets = new Map<Id, Decimal>();
        Map<Id, Decimal> liftBeforeFee = new Map<Id, Decimal>();

        for (TicketScale__c ts : tsList) {
            if (ts.EventDateTime__c != null) {
                if (eventDateTimeTicketScaleProjectionMap.get(ts.EventDateTime__c) == null) {
                    eventDateTimeTicketScaleProjectionMap.put(ts.EventDateTime__c, new List<TicketScale__c>());
                }

                if (eventDateTimeTicketScaleAuditMap.get(ts.EventDateTime__c) == null) {
                    eventDateTimeTicketScaleAuditMap.put(ts.EventDateTime__c, new List<TicketScale__c>());
                }

                if (ts.StageType__c == 'Projection') {
                    eventDateTimeTicketScaleProjectionMap.get(ts.EventDateTime__c).add(ts);

                    if (projectedGrossSales.get(ts.EventDateTime__c) == null) { projectedGrossSales.put(ts.EventDateTime__c, 0.0); }
                    if (projectedPaidTickets.get(ts.EventDateTime__c) == null) { projectedPaidTickets.put(ts.EventDateTime__c, 0.0); }
                    if (liftBeforeFee.get(ts.EventDateTime__c) == null) { liftBeforeFee.put(ts.EventDateTime__c, 0.0); }

                    if (ts.ProjectedGrossSales__c != null) {
                        Decimal d = projectedGrossSales.get(ts.EventDateTime__c);
                        projectedGrossSales.put(ts.EventDateTime__c, d + ts.ProjectedGrossSales__c);
                    }

                    if (ts.ProjectedPaidTickets__c != null) {
                        Decimal d = projectedPaidTickets.get(ts.EventDateTime__c);
                        projectedPaidTickets.put(ts.EventDateTime__c, d + ts.ProjectedPaidTickets__c);
                    }

                    if (ts.LiftBeforeFee__c != null) {
                        Decimal d = liftBeforeFee.get(ts.EventDateTime__c);
                        liftBeforeFee.put(ts.EventDateTime__c, d + ts.LiftBeforeFee__c);
                        platinumLiftBeforeFee += ts.LiftBeforeFee__c;
                    }
                }

                if (ts.StageType__c == 'Audit') {
                    eventDateTimeTicketScaleAuditMap.get(ts.EventDateTime__c).add(ts);
                }
            }
        }

        List<TicketScale__c> tsToUpdate = new List<TicketScale__c>();
        List<EventDateTime__c> edtToUpdate = new List<EventDateTime__c>();
        Set<Id> ticketScaleIdsToRemove = new Set<Id>();

        for (Id edtId : eventDateTimeTicketScaleAuditMap.keySet()) {
            if (eventDateTimeTicketScaleAuditMap.get(edtId) != null && eventDateTimeTicketScaleAuditMap.get(edtId).size() > 0) {
                if (eventDateTimeTicketScaleProjectionMap.get(edtId) != null && eventDateTimeTicketScaleProjectionMap.get(edtId).size() > 0) {
                    List<TicketScale__c> auditRecords = eventDateTimeTicketScaleAuditMap.get(edtId);
                    List<TicketScale__c> currentRecords = eventDateTimeTicketScaleProjectionMap.get(edtId);

                    for (TicketScale__c ts : auditRecords) {
                        ts.StageType__c = 'Projection';
                        LNE_EventDateTimeUtil_T.populateGridBuddyFilterFields(ts);
                        tsToUpdate.add(ts);
                    }

                    for (TicketScale__c ts : currentRecords) {
                        ts.StageType__c = 'Obsolete';
                        LNE_EventDateTimeUtil_T.populateGridBuddyFilterFields(ts);
                        tsToUpdate.add(ts);
                        ticketScaleIdsToRemove.add(ts.Id);
                    }

                    edtToUpdate.add(new EventDateTime__c(Id = edtId,
                                                         UsingTicketFeed__c = true,
                                                         PreviouslyForecastedGrossSales__c = projectedGrossSales.get(edtId),
                                                         PreviouslyForecastedProjPaidTickets__c = projectedPaidTickets.get(edtId),
                                                         PrevForecastedPlatinumLiftbeforeFee__c = liftBeforeFee.get(edtId)
                                                         ));
                }
            }
        }

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
                                           WHERE Event__c = :eventMetrics.Id
                                           AND StageType__c = 'Projection'];

        List<Deduction__c> clonedDeductions = new List<Deduction__c>();

        String ESCAPED_DELIMITER = DATA_SETTINGS.CombinedKeyDelimiter__c;
        if (ESCAPED_DELIMITER == '|') {
            ESCAPED_DELIMITER = '\\|';
        }
        
        for (Deduction__c d : deductions) {

            if (String.isNotBlank(singleEventDateTimeId)) {

            } else {
                Deduction__c newDeduction = d.clone(false, true, false, false);
                newDeduction.StageType__c = 'Obsolete';
                LNE_EventDateTimeUtil_T.populateGridBuddyFilterFields(newDeduction);
                clonedDeductions.add(newDeduction);
            }

            LNE_EventDateTimeUtil_T.removeDeletedIds(d, ticketScaleIdsToRemove);
        }

        List<LedgerEntry__c> ledgers = [SELECT TicketScaleList__c, (SELECT TicketScaleList__c FROM LedgerEntryBreakouts__r) FROM LedgerEntry__c WHERE Event__c = :eventMetrics.Id];
        List<LedgerEntryBreakout__c> breakouts = new List<LedgerEntryBreakout__c>();
        
        for (LedgerEntry__c le : ledgers) {
            LNE_EventDateTimeUtil_T.removeDeletedIds(le, ticketScaleIdsToRemove);
            
            for (LedgerEntryBreakout__c leb : le.LedgerEntryBreakouts__r) {
                LNE_EventDateTimeUtil_T.removeDeletedIds(leb, ticketScaleIdsToRemove);
                breakouts.add(leb);
            }
        }
        
        insert clonedDeductions;
        update tsToUpdate;
        update deductions;
        update ledgers;
        update breakouts;
        update edtToUpdate;

        if (eventMetrics.UsingTicketFeed__c == false) {
            eventMetrics.UsingTicketFeed__c = true;
            eventMetrics.PreviouslyForecastedGrossSales__c  = eventMetrics.ProjectedGrossSales__c;
            eventMetrics.PreviouslyForecastedProjPaidTickets__c = eventMetrics.ProjectedPaidTickets__c;
            eventMetrics.PreviouslyForecastedLiftBeforeFee__c = platinumLiftBeforeFee;
        }
        
        startCalculator();
    }
    
    public void getDateTimeSummary() {
    	List<AggregateResult> ar = 	 [SELECT SUM(Capacity__c) totalCapacity,
	    							  SUM(Comps__c) comps,
	    							  SUM(Kills__c) kills,
	    							  SUM(SellableCapacity__c) sellableCapacity,
	    							  SUM(GrossSales__c) grossSales,
	    							  SUM(ProjectedPaidTickets__c) projectedTickets,
	    							  SUM(ProjectedGrossSales__c) projectedSales,
	    							  SUM(ActualSalesToDate__c) actualSalesToDate,
	    							  SUM(ActualGrossToDate__c) actualGrossToDate,
	    							  EventDateTime__c Id
	    					   FROM TicketScale__c
	    					   WHERE Event__c = :eventId
	    					   AND StageType__c = :currentGridType
	    					   AND EventDateTime__c <> NULL
	    					   GROUP BY EventDateTime__c];
    					   
   		Map<Id, AggregateResult> arMap = new Map<Id, AggregateResult>(ar);
   		dateTimeSummary = new List<AggregateResult>();
   		
   		for (LNE_EventDateTimeUtil_T.EventDateTime e : sortedEventDates) {
   			if (arMap.get(e.edt.Id) != null) {
   				dateTimeSummary.add(arMap.get(e.edt.Id));
   			}
   		}
    }
    
    public void hideProjectedTickets() {
        eventMetrics.HidePreviouslyForecastedProjPdTkt__c = true;
        update eventMetrics;
    }
    
    public void hideLiftBeforeTaxes() {
        eventMetrics.HidePreviouslyForecastedLiftBfrTxs__c = true;
        update eventMetrics;
    }

    public void convertToMultiScale() {
        convertToMultiScaleAndRunCalculator(true);
    }
    
    public void convertToMultiScaleAndRunCalculator(Boolean runCalculator) {
    	stopCalculator();
    	
    	EventDateTime__c firstDateTime = sortedEventDates[0].edt;
    	
    	Set<String> ticketScaleFieldNames = getFieldNamesForObject(TicketScale__c.sObjectType.getDescribe());

		String queryFieldNames = String.join(new List<String>(ticketScaleFieldNames), ',');
		String ticketScaleQuery = 'SELECT ';
		ticketScaleQuery += queryFieldNames;
		ticketScaleQuery += ' FROM TicketScale__c';
		ticketScaleQuery += ' WHERE Event__c = :eventId AND StageType__c <> \'Audit\'';

		List<TicketScale__c> existingTicketScales = Database.query(ticketScaleQuery);
		List<TicketScale__c> scalesToInsert = new List<TicketScale__c>();
		Map<Id, LNE_EventDateTimeUtil_T.TicketScale> tsMap = new Map<Id, LNE_EventDateTimeUtil_T.TicketScale>();
		
		for (TicketScale__c ts : existingTicketScales) {
			ts.EventDateTime__c = firstDateTime.Id;
			LNE_EventDateTimeUtil_T.populateGridBuddyFilterFields(ts);
			tsMap.put(ts.Id, new LNE_EventDateTimeUtil_T.TicketScale(ts));
		}
		
		if (sortedEventDates.size() > 1) {
			for (Integer i = 1; i < sortedEventDates.size(); i++) {
				EventDateTime__c edt = sortedEventDates[i].edt;
				for (TicketScale__c ts : existingTicketScales) {
					TicketScale__c newTicketScale = ts.clone(false, true, false, false);
					newTicketScale.EventDateTime__c = edt.Id;
					LNE_EventDateTimeUtil_T.populateGridBuddyFilterFields(newTicketScale);
					scalesToInsert.add(newTicketScale);
					tsMap.get(ts.Id).clonedScales.add(newTicketScale);
				}
			}
		}
		
		update existingTicketScales;
		insert scalesToInsert;
		
		List<sObject> objectsToUpdate = getRelatedLedgersAndDeductions();
		
		for (sObject so : objectsToUpdate) {
			LNE_EventDateTimeUtil_T.addAdditionalIds(so, tsMap);
		}
		
		update objectsToUpdate;
    	
    	eventMetrics.UsingMultiScale__c = true;

        if (runCalculator == true) {
            startCalculator();
        }
    }
    
    public void revertToSingleScale() {
    	if (eventMetrics.EventDateTimes__r.size() > 0) {
    		stopCalculator();
	    	EventDateTime__c firstDateTime = sortedEventDates[0].edt;
	    	List<TicketScale__c> ticketScales = [SELECT EventDateTime__c FROM TicketScale__c WHERE Event__c = :eventMetrics.Id];
	    	Map<Id,TicketScale__c> toDelete = new Map<Id,TicketScale__c>();
	    	List<TicketScale__c> ticketScalesToUpdate = new List<TicketScale__c>();
	    	
	    	for (TicketScale__c ts : ticketScales) {
	    		if (ts.EventDateTime__c == firstDateTime.Id) {
	    			ts.EventDateTime__c = null;
	    			ticketScalesToUpdate.add(ts);
	    		} else {
	    			toDelete.put(ts.Id, ts);
	    		}
	    	}
	    	
	    	Set<Id> idsToCleanup = toDelete.keySet();
	    	
	    	List<sObject> objectsToUpdate = getRelatedLedgersAndDeductions();
	    	
	    	for (sObject so : objectsToUpdate) {
	    		LNE_EventDateTimeUtil_T.removeDeletedIds(so, idsToCleanup);
	    	}
	    	
	    	objectsToUpdate.addAll((List<sObject>)ticketScalesToUpdate);
	    	
	    	delete toDelete.values();
	    	update objectsToUpdate;
	    	
	    	eventMetrics.UsingMultiScale__c = false;
	    	startCalculator();
    	}
    }
    
    private void stopCalculator() {
    	LNE_FinancialCalculator.currentlyRunning = true;	
    }
    
    private void startCalculator() {
    	LNE_FinancialCalculator.currentlyRunning = false;
    	LNE_FinancialCalculator.addEventId(eventMetrics.Id);
    	update eventMetrics;
    	init();
    }
    
    private String getGridBuddyDataTypeToShow(String type) {
        return eventId.substring(0,15) + DATA_SETTINGS.CombinedKeyDelimiter__c + type;
    }
    
    private List<sObject> getRelatedLedgersAndDeductions() {
    	List<sObject> objectsToReturn = new List<sObject>();
    	objectsToReturn.addAll((List<sObject>)[SELECT TicketScaleList__c FROM LedgerEntry__c WHERE Event__c = :eventMetrics.Id]);
    	objectsToReturn.addAll((List<sObject>)[SELECT TicketScaleList__c FROM LedgerEntryBreakout__c WHERE LedgerEntry__c IN :objectsToReturn]);
    	objectsToReturn.addAll((List<sObject>)[SELECT TicketScaleList__c FROM Deduction__c WHERE Event__c = :eventMetrics.Id]);
    	
    	return objectsToReturn;
    }
    
    private static Set<String> getFieldNamesForObject(Schema.DescribeSObjectResult objectDescribe) {
		Map<String, Schema.SObjectField> objectFields = objectDescribe.fields.getMap();
		Set<String> fieldNames = new Set<String>();

		for(Schema.sObjectField field : objectFields.values()){
			Schema.DescribeFieldResult dfr = field.getDescribe();
			if (dfr.isCreateable()) {
				fieldNames.add(dfr.getName());
			}
		}

		return fieldNames;
	}
	
	@RemoteAction
    global static Integer checkPlatinum(String edtId, String stageType){
        return [SELECT COUNT() FROM TicketScale__c WHERE EventDateTime__c = :edtId AND Type__c = 'Platinum' AND StageType__c = :stageType];
    }
}