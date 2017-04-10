/**
 *  Financial logic to calculate Before Adjusted Deductions Totals
 *  @author Daniel Nakonieczny
**/
public without sharing class LNE_FinancialCalculator {
    // This will control whether to perform calculations again, after all the triggers run and our stack
    // is empty, we perform the calculations, which then update Deductions, Ticket Scales, and Events, and we don't 
    // want calculations to run again after those updates
    public static Boolean runUpdates = true;
    public static Boolean currentlyRunning = false;
    
    private static List<String> runningTriggers = new List<String>();
    private static Set<Id> eventIDsToProcess = new Set<Id>();
    private static Map<String, Id> glAccountMap = new Map<String, Id>();
    
    //- We do not want to run any calculations on Events that have a status in the list below.
    private static List<String> statusesToSkip = new List<String>{'Flash Started', 'Flash Complete'};

    private static String RT_TICKET_REVENUE = 'LedgerEntry__c.TicketRevenue';
    private static String RT_EXPENSES = 'LedgerEntry__c.Expenses';
    private static String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
    private static String RT_COGS = 'LedgerEntry__c.COGS';
    private static String RT_OTHER = 'LedgerEntry__c.Other';
    private static String RT_TALENT_FEES = 'LedgerEntry__c.TalentFees';
    private static String RT_GOSPEL_BRUNCH = 'Event__c.GospelBrunch';
    private static String RT_COPROMOTER = 'Deal__c.CoPromoter';
    private static String RT_DEAL_ARTIST = 'Deal__c.Artist';

    private static final string DELIMITER = DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;
      
    /** LA National Touring Allocation GL CODE **/
    public static final String TOUR_GL_CODE='50360';
     /** Co-Promote Expense GL CODE **/
    public static final String COPRO_EXPENSE_GL_CODE='50302';
     /** Building Co-Promote GL CODE **/
    public static final String COPRO_BOOKING_GL_CODE='50339';

    // US 651
     /** Building Primary Guarantee Expense GL CODE **/
    public static final String PRIMARY_GUARANTEE_EXPENSE_GL_CODE='50002';
     /** Building SFX Event Guarantee GL CODE **/
    public static final String SFX_EVENT_GUARANTEE_GL_CODE='50003';
     /** Building Sharing GL CODE **/
    public static final String SHARING_GL_CODE='50004';
     /** Building SFX Event Saring GL CODE **/
    public static final String SFX_EVENT_SHARING_GL_CODE='50005';
     /** Building Sound & Lights Expense GL CODE **/
    public static final String SOUND_LIGHTS_GL_CODE='50006';
     /** Building Secondary Guarantee GL CODE **/
    public static final String SECONDARY_GUARANTEE_GL_CODE='50007';
     /** Building Other Talent Fee Expense GL CODE **/
    public static final String OTHER_TALENT_FEE_EXPENSE_GL_CODE='50099';

    // US 691
    /** This is used to control ad plan LE recalculation. Set when ad plan attributes are changed by adPlan trigger **/
    public static Boolean runAdPLanLECalculation = false;
    /** Building Advertising Production Expense GL CODE **/
    public static final String ADVERTISING_PRODUCTION_EXPENSE_GL_CODE ='50402';
     /** Building Billboard Advertising Expense GL CODE **/
    public static final String BILLBOARD_ADVERTISING_EXPENSE_GL_CODE='50404';
     /** Building Print Advertising Expense GL CODE **/
    public static final String PRINT_ADVERTISING_EXPENSE_GL_CODE='50408';
     /** Building Radio Advertising Expense GL CODE **/
    public static final String RADIO_ADVERTISING_EXPENSE_GL_CODE='50410';
     /** Building TV Advertising Expense GL CODE **/
    public static final String TV_ADVERTISING_EXPENSE_GL_CODE='50412';
     /** Building Website Advertising GL CODE **/
    public static final String WEBSITE_ADVERTISING_GL_CODE='50419';
     /** Building National Pushdown - Digital GL CODE **/
    public static final String NATIONAL_PUSHDOWN_DIGITAL_GL_CODE='50441';
     /** Building Other National Pushdown - Misc GL CODE **/
    public static final String NATIONAL_PUSHDOWN_MISC_GL_CODE='50446';

    //US752
    /** Gospel Brunch Revenue GL_CODE **/
    public static final String GOSPEL_BRUNCH_REVENUE_GL_CODE = '40264';
    /** Gospel Brunch Food Revenue GL_CODE **/
    public static final String GOSPEL_BRUNCH_FOOD_REVENUE_GL_CODE = '40265';
    /** Gospel Brunch Costs GL_CODE **/
    public static final String GOSPEL_BRUNCH_COSTS_GL_CODE = '50368';
    /** Gospel Brunch Band GL_CODE **/
    public static final String GOSPEL_BRUNCH_BAND_GL_CODE = '50369';
    
    private static String RATE_TYPE_FLAT = 'Flat';  
    private static String RATE_TYPE_PER_TRUCK = 'Per Truck';
    private static String RATE_TYPE_PER_DROP_COUNT = 'Per Drop Count';
    private static String RATE_TYPE_PER_PAID_TICKET = 'Per Paid Ticket';
    private static String RATE_TYPE_NET_GROSS = '% of Net Gross';
    private static String RATE_TYPE_GROSS = '% of Gross';
    private static String RATE_TYPE_ADJUSTED_GROSS = '% of Adjusted Gross';
    
    private static final string TICKET_SCALE_ALL_PAID_TICKETS = 'All Paid Tickets';
    private static final string TICKET_SCALE_ALL_DROP_COUNT = 'All Drop Count';
    private static final string TICKET_SCALE_SELECTED_TICKETS = 'Selected Tickets';
    
    private static final string DEAL_PRIMARY_HEADLINER = 'Primary Headliner';
    private static final string DEAL_TYPE_ARTIST = 'Artist'; //US651 - Deal type Artist
    private static final string DEAL_TYPE_CO_HEADLINER = 'Co-Headliner'; //US651 - Deal type  Co-Headliner
    private static final string DEAL_TYPE_SUPPORT = 'Support'; //US651 - Deal type Support
    
    private static final string DEAL_STAGE_TYPE_SETLLEMENT = 'Settlement';
    
    private static final string DEAL_TYPE_GROSS_SPLIT_POINT = 'Gross Split Point';
    private static final string DEAL_TYPE_PROMOTER_PROFIT = 'Promoter Profit';

    private static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_TICKET_REVENUE, RT_EXPENSES, RT_ANCILLARY, RT_COGS, RT_OTHER, RT_TALENT_FEES, RT_GOSPEL_BRUNCH, RT_COPROMOTER
                        , RT_DEAL_ARTIST}
    );

    private static Id RT_TICKET_REVENUE_ID = recordTypeMap.get( RT_TICKET_REVENUE );
    private static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    private static Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );
    private static Id RT_COGS_ID = recordTypeMap.get( RT_COGS );
    private static Id RT_LEDGER_ENTRY_OTHER_ID = recordTypeMap.get( RT_OTHER );
    private static Id RT_TALENT_FEES_ID = recordTypeMap.get( RT_TALENT_FEES );
    private static Id RT_GOSPEL_BRUNCH_ID = recordTypeMap.get( RT_GOSPEL_BRUNCH );
    private static Id RT_COPROMOTER_ID = recordTypeMap.get( RT_COPROMOTER );
    private static Id RT_DEAL_ARTIST_ID = recordTypeMap.get( RT_DEAL_ARTIST );

    private static Map<String,GLAccount__c> glAccountsMap = LNE_Util.getGLAccounts(new String[] {'40100','40116', '40102','50103','50302','50339'
                                                                                                    ,'50002','50003','50004','50005','50006'
                                                                                                    ,'50007','50099','50402','50404','50408'
                                                                                                    ,'50410','50412','50419','50441','50446'
                                                                                                    ,'40264','40265','50368','50369'});

    public static Boolean hasRunningTriggers() {
        return !runningTriggers.isEmpty();
    }

    public static Boolean hasIdsToProcess() {
        return !eventIDsToProcess.isEmpty();
    }

    public static void addEventId(Id recordId) {
        eventIDsToProcess.add(recordId);
    }

    public static void addEventIdList(List<Id> recordIds) {
        eventIDsToProcess.addAll(recordIds);
    }

    public static void addEventIdSet(Set<Id> recordIds) {
        eventIDsToProcess.addAll(recordIds);
    }


    public static Set<Id> getEventIDsToProcess() {
        return eventIDsToProcess;
    }
    
    public static void pushRunningTrigger(String triggerName) {
        if (hasRunningTriggers() == false && runUpdates == false && currentlyRunning == false) {
            runUpdates = true;
        }

        if (Trigger.isBefore != null && Trigger.isBefore == true) {
            runningTriggers.add(triggerName);
            
            //-- DE397
            if (Trigger.new != null) {
            	runningList.add(new RunningTrigger(triggerName, Trigger.new.size()));
            }
        }
    }

    public static String popRunningTrigger() {
        
        if (Trigger.isAfter != null && Trigger.isAfter == true) {
        	
        	//-- DE397
            if (Trigger.new != null && runningList.size() > 0) {
            	RunningTrigger rt = runningList.remove(runningList.size()-1);
            	
            	if (rt.numberOfRecords != Trigger.new.size()) {
            		currentlyRunning = true;
            	}
            }
            //-- END DE397
            
            if (hasRunningTriggers()) {
                return runningTriggers.remove(runningTriggers.size()-1);
            }
            
        }

        return null;
    }
    
    
    //-- DE397
    static List<RunningTrigger> runningList = new List<RunningTrigger>();
    
    public class RunningTrigger {
    	public String name;
    	public Integer numberOfRecords;
    	
    	public RunningTrigger(String n, Integer i) {
    		this.name = n;
    		this.numberOfRecords = i;
    	}
    }
    //-- END DE397

    public static void checkIfCanRunCalculations() {
        System.debug(LoggingLevel.INFO, (!hasRunningTriggers() && hasIdsToProcess() && runUpdates && currentlyRunning == false) + ' Will FC run? ' );
        if (!hasRunningTriggers() && hasIdsToProcess() && runUpdates && currentlyRunning == false) {
            runUpdates = false;
            currentlyRunning = true;
            performCalculations();
            currentlyRunning = false;
        }
    }
    
    /* Financial calculations */

    private static void performCalculations() {
        LNE_GeneralSettingsUtil.setLocalBypassSettings(false, true, false, true);
        
        System.debug('LNE_FinancialCalculator: Start performing calculations');
        
        //-- now all the triggers and everything else has completed, now we will start monitoring changes
        TEST_SObjectChangeDescriber.shouldDescribe = true;

        for (GLAccount__c g : glAccountsMap.values()) {
            glAccountMap.put(g.GLCode__c, g.Id);
        }

        List<Event__c> events = [SELECT Id,
                                        AdjustedGrossPotential__c,
                                        GrossPotential__c,
                                        ProjectedAdjustedGross__c,
                                        ProjectedGross__c,
                                        ProjectedDropCount__c,
                                        SelloutDropCount__c,
                                        ProjectedDropCountPct__c,
                                        DropCountAdjustment__c,
                                        SelloutGrossSales__c,
                                        PlatinumLift__c,
                                        Status__c,
                                        NumberofTrucks__c,
                                        SelloutPaidTickets__c,
                                        UsingTicketFeed__c,
                                        ProjectedToBeSharedAmount__c,
                                        PotentialToBeSharedAmount__c,
                                        PotentialSplitPoint__c,
                                        ProjectedSplitPoint__c,
                                        ProjectedNetPot__c,
                                        NetPotPotential__c,
                                        ProjectedNetGross__c,
                                        NetGrossPotential__c,
                                        Tour__c,
                                        SettlementDealType__c,
                                        SettlementDealCalculation__c,
                                        SettlementBackendPercentage__c,
                                        SettlementArtistSuppliedSL__c,
                                        SettlementGuarantee__c,
                                        SettlementOtherTalentAmount__c,
                                        StatusStage__c,
                                        Venue__r.OwnershipType__c,
                                        SettlementGrossSales__c,
                                        SettlementPaidTickets__c,
                                        ActualDropCount__c,
                                        SettlementNetGross__c,
                                        PaidAttendance__c,
                                        ShowCount__c,
                                        UsingMultiScale__c,
                                        RecordTypeId,
                                        TotalSupportActExpenses__c,

                                        (SELECT Id,
                                                ProjectedPaidTickets__c,
                                                SellableCapacity__c,
                                                ProjectedGrossSales__c,
                                                LiftBeforeTaxes__c,
                                                GrossSales__c,
                                                BeforeAdjustedDeductions__c,
                                                PlatinumBeforeAdjustedDeductions__c,
                                                Comps__c,
                                                Type__c,
                                                Price__c,
                                                StageType__c,
                                                ActualSalesToDate__c,
                                                ActualGrossToDate__c,
                                                MatchesEventStage__c
                                         FROM TicketScales__r),
                                         
                                         (SELECT Id
                                         FROM EventDateTimes__r),

                                        (SELECT Id,
                                                DeductionAtSellout__c,
                                                DeductionAtProjection__c,
                                                RateType__c,
                                                AmountRate__c,
                                                ApplyTicketScale__c,
                                                TicketScaleList__c,
                                                BeforeAfter__c,
                                                StageType__c,
                                                IncludeInAuditPrice__c,
                                                TotalBaseAmount__c,
                                                MatchesEventStage__c,
                                                Adjustment__c
                                         FROM Deductions__r
                                         WHERE BeforeAfter__c = 'Before Adjusted' OR
                                               BeforeAfter__c = 'After Adjusted'),

                                        (SELECT Id,
                                                GLAccount__c,
                                                GLAccount__r.GLCode__c,
                                                OfferAtSellout__c,
                                                OfferAtProjection__c,
                                                RecordTypeId,
                                                InHouseRate__c,
                                                InHouseRateType__c,
                                                InHouseMax__c,
                                                InHouseMin__c,
                                                InHouseatSellout__c,
                                                SettleAtActual__c,
                                                ExpenseAdjustmentatSellout__c,
                                                ExpenseAdjustment__c,
                                                BaseAmount__c,
                                                TicketScaleList__c,
                                                Min__c,
                                                Max__c,
                                                ContraAmount__c,
                                                RateType__c,
                                                ContraType__c,
                                                ApplyTicketScale__c,
                                                ContraPercent__c,
                                                X3rdPartyPercent__c,
                                                GrossRevenueatSellout__c,
                                                ContraatSellout__c,
                                                NetRevenueatSellout__c,
                                                ContraAtForecast__c,
                                                GrossRevenue__c,
                                                COGSAtSellout__c,
                                                COGSAtForecast__c,
                                                NetRevenue__c,
                                                PrimaryCoProShareAtProjection__c,
                                                PrimaryCoProShareAtSellout__c,
                                                EndofTourDinner__c,
                                                PerDiems__c,
                                                TE__c,
                                                TourRep__c,
                                                GLCode__c,
                                                MiscExpense__c,
                                                RollUpCount__c,
                                                Settlement__c,
                                                FlashRateAmount__c,
                                                FlashRateType__c,
                                                CurrentFlash__c,
                                                OfferRateType__c,
                                                OfferRate__c,
                                                OfferMin__c,
                                                OfferMax__c,
                                                PlanAmount__c,
                                                ProjectionAmount__c
                                         FROM LedgerEntries__r),

                                        (SELECT Id,
                                                InclusiveArtistExpensesPerDealCalc__c,
                                                PotentialInclusiveArtistExpenses__c,
                                                Event__c,
                                                EventProfit__c,
                                                EventLoss__c,
                                                ArtistWalkoutPotential__c,
                                                RollUpTalentOverheadAmount__c,
                                                ShareInTalentOverhead__c,
                                                ProjectedArtistWalkout__c,
                                                ProfitShareAmountAtSellout__c,
                                                ProfitShareAmountAtProjection__c,
                                                ExpenseAdjustmentShareAmountAtSell__c,
                                                ExpenseAdjustmentShareAmountAtProj__c,
                                                AncillaryShareAmountAtSellout__c,
                                                AncillaryShareAmountAtProjection__c,
                                                CoPromoterBonusAtSellout__c,
                                                CoPromoterBonusAtProjection__c,
                                                CoPromoterWalkoutAtSellout__c,
                                                CoPromoterWalkoutAtProjection__c,
                                                Type__c,
                                                PrimarySecondaryCoPromoter__c,
                                                GuaranteeAmount__c,
                                                ArtistSuppliedSL__c,
                                                OtherTalentAmount__c,
                                                DealType__c,
                                                BackendPercent__c,
                                                Rank__c,
                                                DealCalculation__c,
                                                StageType__c,
                                                RollUpBonusDetailsCount__c,
                                                ProjectedOverage__c,
                                                BackendPotential__c,
                                                SettlementBackend__c,
                                                ProjectedBackend__c,
                                                ArtistBackendCalculationPotential__c,
                                                ProjectedArtistBackendCalculation__c,
                                                SettlementArtistBackendCalculation__c,
                                                SplitBackendPercent__c,
                                                ProjectedBonus__c,
                                                RecordTypeId
                                         FROM Deals__r),

                                        (SELECT Id,
                                                Event__c,
                                                RadioSpendPercent__c,
                                                DigitalSpendPercent__c,
                                                OutdoorSpendPercent__c,
                                                PrintSpendPercent__c,
                                                ProductionMiscellaneousSpendPercent__c,
                                                TelevisionSpendPercent__c,
                                                TourDigitalSpendPercent__c,
                                                TourOtherSpendPercent__c,
                                                LNEAdPlanBudget__c,
                                                RadioSpend__c,
                                                DigitalSpend__c,
                                                OutdoorSpend__c,
                                                PrintSpend__c,
                                                ProductionMiscellaneousSpend__c,
                                                TelevisionSpend__c,
                                                TourDigitalSpend__c,
                                                TourOtherSpend__c,
                                                TotalLNESpend__c,
                                                LastModifiedDate  
                                        FROM AdPlans__r
                                        )

                                 FROM Event__c
                                 WHERE Id IN :eventIDsToProcess
                                 AND (NOT Status__c IN :statusesToSkip)];
        
        eventIDsToProcess = new Set<Id>();
        
        Map<Id, List<Event__c>> eventsPerTour = new Map<Id,List<Event__c>>();
        Map<Id, LedgerEntry__c> tourLEPerEvent = new Map<Id, LedgerEntry__c>();
        Map<Id, Integer> showCountMultipliers = new Map<Id,Integer>();
        
        for(Event__c evt : events){
            tourLEPerEvent.put(evt.Id, null);
            
    		// a utility method/class that will default all fields to 0 if the type is a number and the value is null.
            LNE_SObjectFieldDefaulter.defaultDecimalFields(evt);

            for(LedgerEntry__c le : evt.LedgerEntries__r){
                if(le.GLCode__c == TOUR_GL_CODE){
                    LNE_SObjectFieldDefaulter.defaultDecimalFields(le);
                    tourLEPerEvent.put(evt.Id, le); 
                }
            }

            if(evt.Tour__c != null){
                if (!eventsPerTour.containsKey(evt.Tour__c)){
                    eventsPerTour.put(evt.Tour__c, new List<Event__c>());
                }
                eventsPerTour.get(evt.Tour__c).add(evt);
            }

            showCountMultipliers.put(evt.Id, !evt.UsingMultiScale__c && evt.ShowCount__c != null ? evt.ShowCount__c.intValue() : 1);

        }
        
        //-- Tour TSO is now calculated within the LNE_TourTSO_T class.

        List<LNE_Event> eventsToProcess = new List<LNE_Event>();
        List<TicketScale__c> ticketScalesToUpdate = new List<TicketScale__c>();
        List<Deduction__c> deductionsToUpdate = new List<Deduction__c>();
        List<LedgerEntry__c> ledgersToUpdate = new List<LedgerEntry__c>();
        List<Deal__c> dealsToUpdate = new List<Deal__c>();
        Set<Id> ledgerIdsToUpdate = new Set<Id>();
        Set<Id> ledgerBreakoutIdsToUpdate = new Set<Id>();
        List<LedgerEntryBreakout__c> ledgersBreakoutsToUpdate = new List<LedgerEntryBreakout__c>();
        Set<Id> dealIds = new Set<Id>();
        Map<Id, List<LedgerEntryBreakout__c>> ancillaryBreakoutsPerId = new Map<Id,List<LedgerEntryBreakout__c>>();
        List<Id> ancillaryLE = new List<Id>();
        Map<Id, List<LedgerEntryBreakout__c>> expenseBreakoutsPerId = new Map<Id,List<LedgerEntryBreakout__c>>();
        List<Id> expenseLE = new List<Id>();
        Map<Id, List<LedgerEntryBreakout__c>> cogsBreakoutsPerId = new Map<Id,List<LedgerEntryBreakout__c>>();
        List<Id> cogsLE = new List<Id>();
        
        Set<id> leIds = new Set<id>();
        for(Event__c e : events){
            for(LedgerEntry__c le : e.LedgerEntries__r){
                if(le.RecordTypeId == RT_EXPENSES_ID || le.RecordTypeId == RT_ANCILLARY_ID || le.RecordTypeId == RT_COGS_ID){
                    if (le.RollUpCount__c > 0)
                        leIds.add(le.Id);
                }
            }
        }
        
        if (leIds.size() > 0){
            for (LedgerEntryBreakout__c leb : [SELECT   ApplyTicketScale__c,
                                                        BaseAmount__c,
                                                        COGSAtForecast__c,
                                                        COGSAtSellout__c,
                                                        ContraAmount__c,
                                                        ContraAtForecast__c,
                                                        ContraatSellout__c,
                                                        ContraPercent__c,
                                                        ContraType__c,
                                                        CurrentFlash__c,
                                                        ExpenseAdjustment__c,
                                                        ExpenseAdjustmentatSellout__c,
                                                        FlashRateAmount__c,
                                                        FlashRateType__c,
                                                        GrossRevenue__c,
                                                        GrossRevenueatSellout__c,
                                                        InHouseatSellout__c,
                                                        InHouseMax__c,
                                                        InHouseMin__c,
                                                        InHouseRate__c,
                                                        InHouseRateType__c,
                                                        LedgerEntry__c,
                                                        LedgerEntry__r.Event__c,
                                                        LedgerEntry__r.GLAccount__c,
                                                        LedgerEntry__r.GLAccount__r.GLCode__c,
                                                        LedgerEntry__r.GLCode__c,
                                                        LedgerEntry__r.RecordTypeId,
                                                        Max__c,
                                                        Min__c,
                                                        NetRevenueatSellout__c,
                                                        OfferAtProjection__c,
                                                        OfferAtSellout__c,
                                                        OfferMax__c,
                                                        OfferMin__c,
                                                        OfferRate__c,
                                                        OfferRateType__c,
                                                        RateType__c,
                                                        SettleAtActual__c,
                                                        Settlement__c,
                                                        TicketScaleList__c,
                                                        X3rdPartyPercent__c
                                                FROM LedgerEntryBreakout__c
                                                WHERE LedgerEntry__c IN :leIds] 
            ){
                LNE_SObjectFieldDefaulter.defaultDecimalFields(leb);
                if (leb.ledgerEntry__r.RecordTypeId  == RT_EXPENSES_ID){
                    if (!expenseBreakoutsPerId.containsKey(leb.LedgerEntry__c)){
                        expenseBreakoutsPerId.put(leb.LedgerEntry__c, new List<LedgerEntryBreakout__c>());
                    }
                    expenseBreakoutsPerId.get(leb.LedgerEntry__c).add(leb);
                } else if (leb.ledgerEntry__r.RecordTypeId  == RT_ANCILLARY_ID){
                    if (!ancillaryBreakoutsPerId.containsKey(leb.LedgerEntry__c)){
                        ancillaryBreakoutsPerId.put(leb.LedgerEntry__c, new List<LedgerEntryBreakout__c>());
                    }
                    ancillaryBreakoutsPerId.get(leb.LedgerEntry__c).add(leb);
                } else if (leb.ledgerEntry__r.RecordTypeId  == RT_COGS_ID){
                    if (!cogsBreakoutsPerId.containsKey(leb.LedgerEntry__c)){
                        cogsBreakoutsPerId.put(leb.LedgerEntry__c, new List<LedgerEntryBreakout__c>());
                    }
                    cogsBreakoutsPerId.get(leb.LedgerEntry__c).add(leb);
                }
            }
        }

        for (Event__c e : events) {
            LNE_Event evt = new LNE_Event(e);
            Integer showCountMultiplier = showCountMultipliers.get(e.Id);

            for (TicketScale__c t : e.TicketScales__r) {
                Boolean processThisRecord = false;

                if (t.MatchesEventStage__c) {
                    processThisRecord = true;
                }

                if (processThisRecord == true) {

                    LNE_SObjectFieldDefaulter.defaultDecimalFields(t);

                    evt.ticketScales.add(new LNE_TicketScale(t));

                    if (t.ProjectedPaidTickets__c != null && t.StageType__c == evt.eventRecord.StatusStage__c && t.Price__c != null && t.Price__c != 0) {
                        evt.sumProjectedTickets += t.ProjectedPaidTickets__c;
                    }

                    if (t.SellableCapacity__c != null && t.StageType__c == evt.eventRecord.StatusStage__c && t.Price__c != null && t.Price__c != 0) {
                        evt.sumSelloutTickets += t.SellableCapacity__c;
                    }

                    if (t.ActualSalesToDate__c != null && t.StageType__c == 'Settlement') {
                        evt.sumSettlementPaidTickets += t.ActualSalesToDate__c;
                    }

                    if (t.ActualGrossToDate__c != null && t.StageType__c == 'Settlement') {
                        evt.sumSettlementGrossSales += t.ActualGrossToDate__c; 
                    }
                    
                    if (t.Comps__c != null && t.StageType__c == evt.eventRecord.StatusStage__c){
                        evt.sumComps += t.Comps__c;
                    }
                    
                    if (t.GrossSales__c != null && t.StageType__c == evt.eventRecord.StatusStage__c){
                        evt.eventRecord.SelloutGrossSales__c += t.GrossSales__c * showCountMultiplier;
                        evt.eventRecord.GrossPotential__c += t.GrossSales__c * showCountMultiplier;
                    }
                    
                    if (t.ProjectedGrossSales__c != null && t.StageType__c == evt.eventRecord.StatusStage__c){
                        evt.eventRecord.ProjectedGrossSales__c += t.ProjectedGrossSales__c * showCountMultiplier;
                        evt.eventRecord.ProjectedGross__c += t.ProjectedGrossSales__c * showCountMultiplier;
                    }
                    
                    if(t.LiftBeforeTaxes__c != null && t.Type__c == 'Platinum'){
                        if (t.StageType__c == 'Settlement') {
                            e.SettlementPlatinumLift__c += t.LiftBeforeTaxes__c;
                        } else {
                            evt.eventRecord.PlatinumLift__c += t.LiftBeforeTaxes__c * showCountMultiplier;
                            evt.eventRecord.ProjectedGross__c += t.LiftBeforeTaxes__c * showCountMultiplier;
                            evt.eventRecord.GrossPotential__c += t.LiftBeforeTaxes__c * showCountMultiplier;
                        }
                    }

                    if (t.StageType__c == 'Plan') {
                        evt.hasPlan = true;
                    }

                    if (t.StageType__c == 'Projection') {
                        evt.hasProjection = true;
                    }

                    ticketScalesToUpdate.add(t);
                }
            }

            for (Deduction__c d : e.Deductions__r) {
                Boolean processThisRecord = false;

                if (d.MatchesEventStage__c && d.IncludeInAuditPrice__c != 'Excluded/Fee On Top') {
                    processThisRecord = true;
                }

                if (d.IncludeInAuditPrice__c == 'Excluded/Fee On Top') {
                    d.DeductionAtProjection__c = 0.0;
                    d.DeductionAtSellout__c = 0.0;
                    d.DeductionatSettlement__c = 0.0;
                    deductionsToUpdate.add(d);
                }

                if (processThisRecord == true) {

                    LNE_SObjectFieldDefaulter.defaultDecimalFields(d);
                    
                    if (d.BeforeAfter__c == 'Before Adjusted') {
                        evt.beforeDeductions.add(new LNE_Deduction(d));
                    } else if (d.BeforeAfter__c == 'After Adjusted') {
                        evt.afterDeductions.add(new LNE_Deduction(d));
                    }

                    if (d.StageType__c == 'Plan') {
                        evt.hasPlan = true;
                    }

                    if (d.StageType__c == 'Projection') {
                        evt.hasProjection = true;
                    }
                    
                    deductionsToUpdate.add(d);
                }
            }

            for (LedgerEntry__c l : e.LedgerEntries__r) {
                LNE_SObjectFieldDefaulter.defaultDecimalFields(l);
                evt.ledgers.put(l.GLAccount__r.GLCode__c, l);
            }

            for (Deal__c d : e.Deals__r) {
                LNE_SObjectFieldDefaulter.defaultDecimalFields(d);
                dealIds.add(d.Id); // used to pull bonus details
            }

            e.ProjectedPaidTickets__c = evt.sumProjectedTickets * showCountMultiplier;
            e.SelloutPaidTickets__c = evt.sumSelloutTickets * showCountMultiplier;
            e.SettlementPaidTickets__c = evt.sumSettlementPaidTickets;
            e.SettlementGrossSales__c = evt.sumSettlementGrossSales;

            if (e.SettlementPaidTickets__c != 0) {
                e.SettlementAverageTicketPrice__c = e.SettlementGrossSales__c / e.SettlementPaidTickets__c;
            }

            Decimal SettlementGrossSales = e.SettlementGrossSales__c == null ? 0.0 : e.SettlementGrossSales__c;
            Decimal SettlementPlatinumLift = e.SettlementPlatinumLift__c == null ? 0.0 : e.SettlementPlatinumLift__c;

            e.SettlementGross__c = SettlementGrossSales + SettlementPlatinumLift;
            
            eventsToProcess.add(evt);
        }

        //- Before adjusted deductions
        for (LNE_Event event : eventsToProcess) {

            Integer showCountMultiplier = showCountMultipliers.get(event.eventRecord.Id);

            for (LNE_TicketScale ticketScale : event.ticketScales) {

                Decimal ProjectedPaidTickets = getDecimal(ticketScale.ticketScaleRecord.ProjectedPaidTickets__c);
                Decimal SellableCapacity = getDecimal(ticketScale.ticketScaleRecord.SellableCapacity__c);
                Decimal ActualSalesToDate = getDecimal(ticketScale.ticketScaleRecord.ActualSalesToDate__c);
                Decimal ActualGrossToDate = getDecimal(ticketScale.ticketScaleRecord.ActualGrossToDate__c);
                Decimal LiftBeforeTaxes = getDecimal(ticketScale.ticketScaleRecord.LiftBeforeTaxes__c);
                Decimal ProjectedGrossSales = getDecimal(ticketScale.ticketScaleRecord.ProjectedGrossSales__c);
                Decimal GrossSales = getDecimal(ticketScale.ticketScaleRecord.GrossSales__c);

                // first deduction loop
                for (LNE_Deduction deduction : event.beforeDeductions) {
                    if (deduction.deductionRecord.RateType__c != null && deduction.deductionRecord.StageType__c == ticketScale.ticketScaleRecord.StageType__c) {
                        String rateType = deduction.deductionRecord.RateType__c;
                        String stageType = deduction.deductionRecord.StageType__c;

                        Decimal AmountRate = getDecimal(deduction.deductionRecord.AmountRate__c);
                        Decimal AppliedTicketsCount = ActualSalesToDate;
                        Decimal TotalBaseAmount = (ActualGrossToDate + LiftBeforeTaxes);

                        if (rateType == 'Flat') {
                            Decimal sumFees = 0.0;
                            Decimal sumSelloutFees = 0.0;

                            if (stageType == 'Settlement') {
                                if (event.sumSettlementPaidTickets != 0) {
                                    sumFees = AmountRate * ActualSalesToDate / event.sumSettlementPaidTickets;
                                }
                            } else {
                                if (event.sumProjectedTickets != 0) {
                                    sumFees = AmountRate * ProjectedPaidTickets / event.sumProjectedTickets;
                                }
                                
                                if (event.sumSelloutTickets != 0) {
                                    sumSelloutFees = AmountRate * SellableCapacity / event.sumSelloutTickets;
                                }
                            }

                            ticketScale.sumFees += sumFees;
                            ticketScale.sumSelloutFees += sumSelloutFees;
                            deduction.sumFees += sumFees;
                            deduction.sumSelloutFees += sumSelloutFees;
                        }

                        if (rateType == 'Amount Per Ticket' && deduction.deductionRecord.ApplyTicketScale__c != null) {
                            AppliedTicketsCount = 0;
                            TotalBaseAmount = 0;

                            String applyTicketScale = deduction.deductionRecord.ApplyTicketScale__c;

                            if (applyTicketScale == 'All Paid Tickets') {
                                Decimal sumFees = 0.0;
                                Decimal sumSelloutFees = 0.0;

                                if (stageType == 'Settlement') {
                                    sumFees = AmountRate * ActualSalesToDate;
                                } else {
                                    sumFees = AmountRate * ProjectedPaidTickets;
                                    sumSelloutFees = AmountRate * SellableCapacity;
                                }

                                ticketScale.sumFees += sumFees;
                                ticketScale.sumSelloutFees += sumSelloutFees;
                                deduction.sumFees += sumFees;
                                deduction.sumSelloutFees += sumSelloutFees;

                                AppliedTicketsCount = ActualSalesToDate;
                                TotalBaseAmount = (ActualGrossToDate + LiftBeforeTaxes);
                            }

                            if (applyTicketScale == 'Selected Tickets' && 
                                    deduction.deductionRecord.TicketScaleList__c != null &&
                                    deduction.deductionRecord.TicketScaleList__c.contains(((String)ticketScale.ticketScaleRecord.Id).substring(0,15))) {

                                Decimal sumFees = 0.0;
                                Decimal sumSelloutFees = 0.0;

                                if (stageType == 'Settlement') {
                                    sumFees = AmountRate * ActualSalesToDate;
                                } else {
                                    sumFees = AmountRate * ProjectedPaidTickets;
                                    sumSelloutFees = AmountRate * SellableCapacity;
                                }

                                ticketScale.sumFees += sumFees;
                                ticketScale.sumSelloutFees += sumSelloutFees;
                                deduction.sumFees += sumFees;
                                deduction.sumSelloutFees += sumSelloutFees;

                                AppliedTicketsCount = ActualSalesToDate;
                                TotalBaseAmount = (ActualGrossToDate + LiftBeforeTaxes);
                            }
                        }

                        if (rateType == 'Primary Divider Tax') {
                            Decimal sumPrimaryDividers = 0.0;
                            Decimal sumPlatinumPrimaryDividers = 0.0;
                            Decimal sumSelloutPrimaryDividers = 0.0;

                            if (stageType == 'Settlement') {
                                sumPrimaryDividers = ActualGrossToDate - (ActualGrossToDate / (1 + (AmountRate / 100)));
                                sumPlatinumPrimaryDividers = LiftBeforeTaxes - (LiftBeforeTaxes / (1 + (AmountRate / 100)));
                            } else {
                                sumPrimaryDividers = ProjectedGrossSales - (ProjectedGrossSales / (1 + (AmountRate / 100)));
                                sumPlatinumPrimaryDividers = LiftBeforeTaxes - (LiftBeforeTaxes / (1 + (AmountRate / 100)));
                                sumSelloutPrimaryDividers = GrossSales - (GrossSales / (1 + (AmountRate / 100)));
                            }

                            ticketScale.sumPrimaryDividers += sumPrimaryDividers;
                            ticketScale.sumPlatinumPrimaryDividers += sumPlatinumPrimaryDividers;
                            ticketScale.sumSelloutPrimaryDividers += sumSelloutPrimaryDividers;
                            deduction.sumPrimaryDividers += sumPrimaryDividers + sumPlatinumPrimaryDividers;
                            deduction.sumSelloutPrimaryDividers += sumSelloutPrimaryDividers + sumPlatinumPrimaryDividers;
                        }

                        if (rateType == 'Primary Multiplier Tax') {
                            Decimal sumPrimaryMultipliers = 0.0;
                            Decimal sumPlatinumPrimaryMultipliers = 0.0;
                            Decimal sumSelloutPrimaryMultipliers = 0.0;

                            if (stageType == 'Settlement') {
                                sumPrimaryMultipliers = ActualGrossToDate * AmountRate / 100;
                                sumPlatinumPrimaryMultipliers = LiftBeforeTaxes * AmountRate / 100;
                            } else {
                                sumPrimaryMultipliers = ProjectedGrossSales * AmountRate / 100;
                                sumPlatinumPrimaryMultipliers = LiftBeforeTaxes * AmountRate / 100;
                                sumSelloutPrimaryMultipliers = GrossSales * AmountRate / 100;
                            }

                            ticketScale.sumPrimaryMultipliers += sumPrimaryMultipliers;
                            ticketScale.sumPlatinumPrimaryMultipliers += sumPlatinumPrimaryMultipliers;
                            ticketScale.sumSelloutPrimaryMultipliers += sumSelloutPrimaryMultipliers;
                            deduction.sumPrimaryMultipliers += sumPrimaryMultipliers + sumPlatinumPrimaryMultipliers;
                            deduction.sumSelloutPrimaryMultipliers += sumSelloutPrimaryMultipliers + sumPlatinumPrimaryMultipliers;
                        }

                        deduction.totalBaseAmount += TotalBaseAmount;
                        deduction.appliedTicketsCount += AppliedTicketsCount;
                    }
                }

                // loop through deductions again
                for (LNE_Deduction deduction : event.beforeDeductions) {
                    if (deduction.deductionRecord.RateType__c != null && deduction.deductionRecord.StageType__c == ticketScale.ticketScaleRecord.StageType__c) {
                        String rateType = deduction.deductionRecord.RateType__c;
                        String stageType = deduction.deductionRecord.StageType__c;

                        Decimal AmountRate = getDecimal(deduction.deductionRecord.AmountRate__c);

                        if (rateType == 'Secondary Divider Tax') {
                            Decimal sumSecondaryDividers = 0.0;
                            Decimal sumPlatinumSecondaryDividers = 0.0;
                            Decimal sumSelloutSecondaryDividers = 0.0;

                            if (stageType == 'Settlement') {
                                sumSecondaryDividers = (ActualGrossToDate - ticketScale.sumPrimaryDividers) - ((ActualGrossToDate - ticketScale.sumPrimaryDividers) / (1 + (AmountRate / 100)));
                                sumPlatinumSecondaryDividers = (LiftBeforeTaxes - ticketScale.sumPlatinumPrimaryDividers) - ((LiftBeforeTaxes - ticketScale.sumPlatinumPrimaryDividers) / (1 + (AmountRate / 100)));
                            } else {
                                sumSecondaryDividers = (ProjectedGrossSales - ticketScale.sumPrimaryDividers) - ((ProjectedGrossSales - ticketScale.sumPrimaryDividers) / (1 + (AmountRate / 100)));
                                sumPlatinumSecondaryDividers = (LiftBeforeTaxes - ticketScale.sumPlatinumPrimaryDividers) - ((LiftBeforeTaxes - ticketScale.sumPlatinumPrimaryDividers) / (1 + (AmountRate / 100)));
                                sumSelloutSecondaryDividers = (GrossSales - ticketScale.sumSelloutPrimaryDividers) - ((GrossSales - ticketScale.sumSelloutPrimaryDividers) / (1 + (AmountRate / 100))) + sumPlatinumSecondaryDividers;
                            }

                            ticketScale.sumSecondaryDividers += sumSecondaryDividers;
                            ticketScale.sumPlatinumSecondaryDividers += sumPlatinumSecondaryDividers;
                            ticketScale.sumSelloutSecondaryDividers += sumSelloutSecondaryDividers;
                            deduction.sumSecondaryDividers += sumSecondaryDividers + sumPlatinumSecondaryDividers;
                            deduction.sumSelloutSecondaryDividers += (GrossSales - ticketScale.sumSelloutPrimaryDividers) - ((GrossSales - ticketScale.sumSelloutPrimaryDividers) / (1 + (AmountRate / 100))) + sumPlatinumSecondaryDividers;
                        }

                        if (rateType == 'Secondary Multiplier Tax') {
                            Decimal sumSecondaryMultipliers = 0.0;
                            Decimal sumPlatinumSecondaryMultipliers = 0.0;
                            Decimal sumSelloutSecondaryMultipliers = 0.0;

                            if (stageType == 'Settlement') {
                                sumSecondaryMultipliers = (ActualGrossToDate - ticketScale.sumPrimaryMultipliers) * AmountRate / 100;
                                sumPlatinumSecondaryMultipliers = (LiftBeforeTaxes - ticketScale.sumPlatinumPrimaryMultipliers) * AmountRate / 100;
                            } else {
                                sumSecondaryMultipliers = (ProjectedGrossSales - ticketScale.sumPrimaryMultipliers) * AmountRate / 100;
                                sumPlatinumSecondaryMultipliers = (LiftBeforeTaxes - ticketScale.sumPlatinumPrimaryMultipliers) * AmountRate / 100;
                                sumSelloutSecondaryMultipliers = (GrossSales - ticketScale.sumSelloutPrimaryMultipliers) * AmountRate / 100 + sumPlatinumSecondaryMultipliers;
                            }

                            ticketScale.sumSecondaryMultipliers += sumSecondaryMultipliers;
                            ticketScale.sumPlatinumSecondaryMultipliers += sumPlatinumSecondaryMultipliers;
                            ticketScale.sumSelloutSecondaryMultipliers += sumSelloutSecondaryMultipliers;
                            deduction.sumSecondaryMultipliers += sumSecondaryMultipliers + sumPlatinumSecondaryMultipliers;
                            deduction.sumSelloutSecondaryMultipliers += (GrossSales - ticketScale.sumSelloutPrimaryMultipliers) * AmountRate / 100 + sumPlatinumSecondaryMultipliers;
                        }
                    }
                }

                Decimal BeforeAdjustedDeductions = (ticketScale.sumFees + ticketScale.sumPrimaryDividers + ticketScale.sumPrimaryMultipliers + ticketScale.sumSecondaryDividers + ticketScale.sumSecondaryMultipliers);

                ticketScale.ticketScaleRecord.BeforeAdjustedDeductions__c = BeforeAdjustedDeductions.setScale(2, RoundingMode.HALF_UP);
                ticketScale.projectedAdjustedGross = ProjectedGrossSales - BeforeAdjustedDeductions;
                ticketScale.sumSelloutDeductions = ticketScale.sumSelloutFees + ticketScale.sumSelloutPrimaryDividers + ticketScale.sumSelloutPrimaryMultipliers + ticketScale.sumSelloutSecondaryDividers + ticketScale.sumSelloutSecondaryMultipliers + ticketScale.sumPlatinumPrimaryDividers + ticketScale.sumPlatinumPrimaryMultipliers; 
                ticketScale.adjustedGross = (GrossSales + LiftBeforeTaxes) - ticketScale.sumSelloutDeductions;
                ticketScale.ticketScaleRecord.PlatinumBeforeAdjustedDeductions__c = (ticketScale.sumPlatinumPrimaryDividers + ticketScale.sumPlatinumPrimaryMultipliers + ticketScale.sumPlatinumSecondaryDividers + ticketScale.sumPlatinumSecondaryMultipliers).setScale(2, RoundingMode.HALF_UP);
                ticketScale.settlementAdjustedGross = (ActualGrossToDate - ticketScale.ticketScaleRecord.BeforeAdjustedDeductions__c);
            }

            for (LNE_Deduction deduction : event.beforeDeductions) {
                deduction.deductionRecord.DeductionAtSellout__c = (deduction.sumSelloutFees + deduction.sumSelloutPrimaryDividers + deduction.sumSelloutPrimaryMultipliers + deduction.sumSelloutSecondaryDividers + deduction.sumSelloutSecondaryMultipliers).setScale(2, RoundingMode.HALF_UP) * showCountMultiplier;
                deduction.deductionRecord.DeductionAtProjection__c = (deduction.sumFees + deduction.sumPrimaryDividers + deduction.sumPrimaryMultipliers + deduction.sumSecondaryDividers + deduction.sumSecondaryMultipliers).setScale(2, RoundingMode.HALF_UP) * showCountMultiplier;

                if (deduction.deductionRecord.StageType__c == 'Settlement') {
                    deduction.deductionRecord.DeductionatSettlement__c = (deduction.sumFees + deduction.sumPrimaryDividers + deduction.sumPrimaryMultipliers + deduction.sumSecondaryDividers + deduction.sumSecondaryMultipliers).setScale(2, RoundingMode.HALF_UP);
                    
                    if (deduction.deductionRecord.Adjustment__c != null) {
                        deduction.deductionRecord.DeductionatSettlement__c -= deduction.deductionRecord.Adjustment__c;
                    }

                    deduction.deductionRecord.TotalBaseAmount__c = deduction.totalBaseAmount;
                    deduction.deductionRecord.AppliedTicketsCount__c = deduction.appliedTicketsCount;
                }
                
                if (deduction.deductionRecord.StageType__c == event.eventRecord.StatusStage__c) {
                    event.selloutDeduction += deduction.deductionRecord.DeductionAtSellout__c;
                    event.projectedDeduction += deduction.deductionRecord.DeductionAtProjection__c;
                }

                if (deduction.deductionRecord.DeductionatSettlement__c != null) {
                    event.settlementDeduction += deduction.deductionRecord.DeductionatSettlement__c;
                    event.settlementTotalDeduction += deduction.deductionRecord.DeductionatSettlement__c;
                }
            }

            event.eventRecord.AdjustedGrossPotential__c = (event.eventRecord.GrossPotential__c - event.selloutDeduction);
            event.eventRecord.ProjectedAdjustedGross__c = (event.eventRecord.ProjectedGross__c - event.projectedDeduction);
            if (event.eventRecord.ProjectedDropCountPct__c != null && event.eventRecord.DropCountAdjustment__c != null) {
                event.eventRecord.ProjectedDropCount__c = (showCountMultiplier * event.eventRecord.ProjectedDropCountPct__c * .01) * (event.sumProjectedTickets + event.sumComps) + event.eventRecord.DropCountAdjustment__c;
            }
            event.eventRecord.SelloutDropCount__c = (event.sumSelloutTickets + event.sumComps) * showCountMultiplier;

            if (event.eventRecord.ProjectedGrossSales__c != null && event.sumProjectedTickets != 0) {
                event.eventRecord.ProjectedAverageTicketPrice__c = (event.eventRecord.ProjectedGrossSales__c / event.sumProjectedTickets).setScale(2, RoundingMode.HALF_UP);
            }

            if (event.eventRecord.SelloutGrossSales__c != null && event.sumSelloutTickets != 0) {
                event.eventRecord.SelloutAverageTicketPrice__c = (event.eventRecord.SelloutGrossSales__c / event.sumSelloutTickets).setScale(2, RoundingMode.HALF_UP);
            }
        }

        //- After adjusted deductions
        for (LNE_Event event : eventsToProcess) {

            Integer showCountMultiplier = showCountMultipliers.get(event.eventRecord.Id);

            for (LNE_TicketScale ticketScale : event.ticketScales) {

                Decimal ProjectedPaidTickets = getDecimal(ticketScale.ticketScaleRecord.ProjectedPaidTickets__c);
                Decimal SellableCapacity = getDecimal(ticketScale.ticketScaleRecord.SellableCapacity__c);
                Decimal ActualSalesToDate = getDecimal(ticketScale.ticketScaleRecord.ActualSalesToDate__c);
                Decimal ActualGrossToDate = getDecimal(ticketScale.ticketScaleRecord.ActualGrossToDate__c);
                Decimal LiftBeforeTaxes = getDecimal(ticketScale.ticketScaleRecord.LiftBeforeTaxes__c);
                Decimal ProjectedGrossSales = getDecimal(ticketScale.ticketScaleRecord.ProjectedGrossSales__c);
                Decimal GrossSales = getDecimal(ticketScale.ticketScaleRecord.GrossSales__c);
                Decimal BeforeAdjustedDeductions = getDecimal(ticketScale.ticketScaleRecord.BeforeAdjustedDeductions__c);
                Decimal PlatinumBeforeAdjustedDeductions = getDecimal(ticketScale.ticketScaleRecord.PlatinumBeforeAdjustedDeductions__c);

                // first deduction loop
                for (LNE_Deduction deduction : event.afterDeductions) {
                    if (deduction.deductionRecord.RateType__c != null && deduction.deductionRecord.StageType__c == ticketScale.ticketScaleRecord.StageType__c) {
                        String rateType = deduction.deductionRecord.RateType__c;
                        String stageType = deduction.deductionRecord.StageType__c;

                        Decimal AmountRate = getDecimal(deduction.deductionRecord.AmountRate__c);
                        Decimal AppliedTicketsCount = ActualSalesToDate;
                        Decimal TotalBaseAmount = (ActualGrossToDate + LiftBeforeTaxes - BeforeAdjustedDeductions - PlatinumBeforeAdjustedDeductions);

                        if (rateType == 'Flat') {

                            Decimal sumAfterFees = 0.0;
                            Decimal sumSelloutFees = 0.0;

                            if (stageType == 'Settlement') {
                                if (event.sumSettlementPaidTickets != 0) {
                                    sumAfterFees = AmountRate * ActualSalesToDate / event.sumSettlementPaidTickets;
                                }
                            } else {
                                if (event.sumProjectedTickets != 0) {
                                    sumAfterFees = AmountRate * ProjectedPaidTickets / event.sumProjectedTickets;
                                }
                            }

                            if (event.sumSelloutTickets != 0) {
                                sumSelloutFees += AmountRate * SellableCapacity / event.sumSelloutTickets;
                            }

                            ticketScale.sumAfterFees += sumAfterFees;
                            deduction.sumFees += sumAfterFees;
                            deduction.sumSelloutFees += sumSelloutFees;
                        }

                        if (rateType == 'Amount Per Ticket' && deduction.deductionRecord.ApplyTicketScale__c != null) {
                            AppliedTicketsCount = 0;
                            TotalBaseAmount = 0;

                            String applyTicketScale = deduction.deductionRecord.ApplyTicketScale__c;

                            if (applyTicketScale == 'All Paid Tickets') {
                                
                                Decimal sumAfterFees = 0.0;

                                if (stageType == 'Settlement') {
                                    sumAfterFees = AmountRate * ActualSalesToDate;
                                } else {
                                    sumAfterFees = AmountRate * ProjectedPaidTickets;
                                }

                                ticketScale.sumAfterFees += sumAfterFees;
                                deduction.sumFees += sumAfterFees;
                                deduction.sumSelloutFees += AmountRate * SellableCapacity;

                                AppliedTicketsCount = ActualSalesToDate;
                                TotalBaseAmount = (ActualGrossToDate + LiftBeforeTaxes - BeforeAdjustedDeductions - PlatinumBeforeAdjustedDeductions);
                            }

                            if (applyTicketScale == 'Selected Tickets' && 
                                    deduction.deductionRecord.TicketScaleList__c != null &&
                                    deduction.deductionRecord.TicketScaleList__c.contains(((String)ticketScale.ticketScaleRecord.Id).substring(0,15))) {

                                Decimal sumAfterFees = 0.0;

                                if (stageType == 'Settlement') {
                                    sumAfterFees = AmountRate * ActualSalesToDate;
                                } else {
                                    sumAfterFees = AmountRate * ProjectedPaidTickets;
                                }

                                ticketScale.sumAfterFees += sumAfterFees;
                                deduction.sumFees += sumAfterFees;
                                deduction.sumSelloutFees += AmountRate * SellableCapacity;

                                AppliedTicketsCount = ActualSalesToDate;
                                TotalBaseAmount = (ActualGrossToDate + LiftBeforeTaxes - BeforeAdjustedDeductions - PlatinumBeforeAdjustedDeductions);
                            }
                        }

                        if (rateType == 'Primary Divider Tax') {
                            Decimal sumAfterPrimaryDividers = 0.0;
                            Decimal sumAfterPlatinumPrimaryDividers = 0.0;
                            Decimal sumAfterSelloutPrimaryDividers = 0.0;

                            if (stageType == 'Settlement') {
                                sumAfterPrimaryDividers = ticketScale.settlementAdjustedGross - (ticketScale.settlementAdjustedGross / (1 + (AmountRate / 100)));
                                sumAfterPlatinumPrimaryDividers = (LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions) - ((LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions) / (1 + (AmountRate / 100)));
                            } else {
                                sumAfterPrimaryDividers = ticketScale.projectedAdjustedGross - (ticketScale.projectedAdjustedGross / (1 + (AmountRate / 100)));
                                sumAfterPlatinumPrimaryDividers = (LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions) - ((LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions) / (1 + (AmountRate / 100)));
                                sumAfterSelloutPrimaryDividers = ticketScale.adjustedGross - (ticketScale.adjustedGross / (1 + (AmountRate / 100)));
                            }

                            ticketScale.sumAfterPrimaryDividers += sumAfterPrimaryDividers;
                            ticketScale.sumAfterPlatinumPrimaryDividers += sumAfterPlatinumPrimaryDividers;
                            ticketScale.sumAfterSelloutPrimaryDividers += sumAfterSelloutPrimaryDividers;
                            deduction.sumPrimaryDividers += sumAfterPrimaryDividers + sumAfterPlatinumPrimaryDividers;
                            deduction.sumSelloutPrimaryDividers += sumAfterSelloutPrimaryDividers;
                        }

                        if (rateType == 'Primary Multiplier Tax') {
                            Decimal sumAfterPrimaryMultipliers = 0.0;
                            Decimal sumAfterPlatinumPrimaryMultipliers = 0.0;
                            Decimal sumAfterSelloutPrimaryMultipliers = 0.0;

                            if (stageType == 'Settlement') {
                                sumAfterPrimaryMultipliers = ticketScale.settlementAdjustedGross * AmountRate / 100;
                                sumAfterPlatinumPrimaryMultipliers = (LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions) * AmountRate / 100;
                            } else {
                                sumAfterPrimaryMultipliers = ticketScale.projectedAdjustedGross * AmountRate / 100;
                                sumAfterPlatinumPrimaryMultipliers = (LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions) * AmountRate / 100;
                                sumAfterSelloutPrimaryMultipliers = ticketScale.adjustedGross * AmountRate / 100;
                            }

                            ticketScale.sumAfterPrimaryMultipliers += sumAfterPrimaryMultipliers;
                            ticketScale.sumAfterPlatinumPrimaryMultipliers += sumAfterPlatinumPrimaryMultipliers;
                            ticketScale.sumAfterSelloutPrimaryMultipliers += sumAfterSelloutPrimaryMultipliers;
                            deduction.sumPrimaryMultipliers += sumAfterPrimaryMultipliers + sumAfterPlatinumPrimaryMultipliers;
                            deduction.sumSelloutPrimaryMultipliers += sumAfterSelloutPrimaryMultipliers;
                        }

                        deduction.appliedTicketsCount += AppliedTicketsCount;
                        deduction.totalBaseAmount += TotalBaseAmount;
                    }
                }

                // loop through deductions again
                for (LNE_Deduction deduction : event.afterDeductions) {
                    if (deduction.deductionRecord.RateType__c != null && deduction.deductionRecord.StageType__c == ticketScale.ticketScaleRecord.StageType__c) {
                        String rateType = deduction.deductionRecord.RateType__c;
                        String stageType = deduction.deductionRecord.StageType__c;

                        Decimal AmountRate = getDecimal(deduction.deductionRecord.AmountRate__c);

                        if (rateType == 'Secondary Divider Tax') {
                            Decimal sumAfterSecondaryDividers = 0.0;
                            Decimal sumAfterPlatinumSecondaryDividers = 0.0;

                            if (stageType == 'Settlement') {
                                sumAfterSecondaryDividers = (ticketScale.settlementAdjustedGross - ticketScale.sumAfterPrimaryDividers) - ((ticketScale.settlementAdjustedGross - ticketScale.sumAfterPrimaryDividers) / (1 + (AmountRate / 100)));
                                sumAfterPlatinumSecondaryDividers = (LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions - ticketScale.sumAfterPlatinumPrimaryDividers) - ((LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions - ticketScale.sumAfterPlatinumPrimaryDividers)/ (1 + (AmountRate / 100)));
                            } else {
                                sumAfterSecondaryDividers = (ticketScale.projectedAdjustedGross - ticketScale.sumAfterPrimaryDividers) - ((ticketScale.projectedAdjustedGross - ticketScale.sumAfterPrimaryDividers) / (1 + (AmountRate / 100)));
                                sumAfterPlatinumSecondaryDividers = (LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions - ticketScale.sumAfterPlatinumPrimaryDividers) - ((LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions - ticketScale.sumAfterPlatinumPrimaryDividers)/ (1 + (AmountRate / 100)));
                            }

                            ticketScale.sumAfterSecondaryDividers += sumAfterSecondaryDividers;
                            ticketScale.sumAfterPlatinumSecondaryDividers += sumAfterPlatinumSecondaryDividers;
                            deduction.sumSecondaryDividers += sumAfterSecondaryDividers + sumAfterPlatinumSecondaryDividers;
                            deduction.sumSelloutSecondaryDividers += (ticketScale.adjustedGross - ticketScale.sumAfterSelloutPrimaryDividers) - ((ticketScale.adjustedGross - ticketScale.sumAfterSelloutPrimaryDividers) / (1 + (AmountRate / 100)));
                        }

                        if (rateType == 'Secondary Multiplier Tax') {
                            Decimal sumAfterSecondaryMultipliers = 0.0;
                            Decimal sumAfterPlatinumSecondaryMultipliers = 0.0;

                            if (stageType == 'Settlement') {
                                sumAfterSecondaryMultipliers = (ticketScale.settlementAdjustedGross - ticketScale.sumAfterPrimaryMultipliers) * AmountRate / 100;
                                sumAfterPlatinumSecondaryMultipliers = (LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions - ticketScale.sumAfterPlatinumPrimaryMultipliers) * AmountRate / 100;
                            } else {
                                sumAfterSecondaryMultipliers = (ticketScale.projectedAdjustedGross - ticketScale.sumAfterPrimaryMultipliers) * AmountRate / 100;
                                sumAfterPlatinumSecondaryMultipliers = (LiftBeforeTaxes - PlatinumBeforeAdjustedDeductions - ticketScale.sumAfterPlatinumPrimaryMultipliers) * AmountRate / 100;
                            }

                            ticketScale.sumAfterSecondaryMultipliers += sumAfterSecondaryMultipliers;
                            ticketScale.sumAfterPlatinumSecondaryMultipliers += sumAfterPlatinumSecondaryMultipliers;
                            deduction.sumSecondaryMultipliers += sumAfterSecondaryMultipliers + sumAfterPlatinumSecondaryMultipliers;
                            deduction.sumSelloutSecondaryMultipliers += (ticketScale.adjustedGross - ticketScale.sumAfterSelloutPrimaryMultipliers) * AmountRate / 100;
                        }

                        
                    }
                }

                ticketScale.ticketScaleRecord.AfterAdjustedDeductions__c = (ticketScale.sumAfterFees + ticketScale.sumAfterPrimaryDividers + ticketScale.sumAfterPrimaryMultipliers + ticketScale.sumAfterSecondaryDividers + ticketScale.sumAfterSecondaryMultipliers).setScale(2, RoundingMode.HALF_UP);
                ticketScale.ticketScaleRecord.PlatinumAfterAdjusted_Deductions__c = (ticketScale.sumAfterPlatinumPrimaryDividers + ticketScale.sumAfterPlatinumPrimaryMultipliers + ticketScale.sumAfterPlatinumSecondaryDividers + ticketScale.sumAfterPlatinumSecondaryMultipliers).setScale(2, RoundingMode.HALF_UP);
            }

            for (LNE_Deduction deduction : event.afterDeductions) {
                if (deduction.deductionRecord.StageType__c == event.eventRecord.StatusStage__c) {
                    deduction.deductionRecord.DeductionAtSellout__c = (deduction.sumSelloutFees + deduction.sumSelloutPrimaryDividers + deduction.sumSelloutPrimaryMultipliers + deduction.sumSelloutSecondaryDividers + deduction.sumSelloutSecondaryMultipliers).setScale(2, RoundingMode.HALF_UP) * showCountMultiplier;
                    deduction.deductionRecord.DeductionAtProjection__c = (deduction.sumFees + deduction.sumPrimaryDividers + deduction.sumPrimaryMultipliers + deduction.sumSecondaryDividers + deduction.sumSecondaryMultipliers).setScale(2, RoundingMode.HALF_UP) * showCountMultiplier;
                    event.selloutAfterDeduction += deduction.deductionRecord.DeductionAtSellout__c;
                    event.projectedAfterDeduction += deduction.deductionRecord.DeductionAtProjection__c;
                }
                
                if (deduction.deductionRecord.StageType__c == 'Settlement') {
                    deduction.deductionRecord.DeductionatSettlement__c = (deduction.sumFees + deduction.sumPrimaryDividers + deduction.sumPrimaryMultipliers + deduction.sumSecondaryDividers + deduction.sumSecondaryMultipliers).setScale(2, RoundingMode.HALF_UP);
                    if (deduction.deductionRecord.Adjustment__c != null) {
                        deduction.deductionRecord.DeductionatSettlement__c -= deduction.deductionRecord.Adjustment__c;
                    }

                    deduction.deductionRecord.TotalBaseAmount__c = deduction.totalBaseAmount;
                    deduction.deductionRecord.AppliedTicketsCount__c = deduction.appliedTicketsCount;
                }

                if (deduction.deductionRecord.DeductionatSettlement__c != null) {
                    event.settlementAfterDeduction += deduction.deductionRecord.DeductionatSettlement__c;
                    event.settlementTotalDeduction += deduction.deductionRecord.DeductionatSettlement__c;
                }
            }
            
            event.eventRecord.NetGrossPotential__c = event.eventRecord.AdjustedGrossPotential__c - event.selloutAfterDeduction;
            event.eventRecord.ProjectedNetGross__c = event.eventRecord.ProjectedAdjustedGross__c - event.projectedAfterDeduction;
            event.eventRecord.SettlementDeductions__c = event.settlementTotalDeduction;
            event.eventRecord.SettlementAdjustedGross__c = event.eventRecord.SettlementGross__c - event.settlementDeduction;
            event.eventRecord.SettlementNetGross__c = event.eventRecord.SettlementGross__c - event.settlementTotalDeduction;
        }

        for (LNE_Event event : eventsToProcess) {
            for (Deal__c deal : event.eventRecord.Deals__r) {
                Decimal PotentialInclusiveArtistExpenses = deal.PotentialInclusiveArtistExpenses__c == null ? 0.0 : deal.PotentialInclusiveArtistExpenses__c;
                Decimal InclusiveArtistExpensesPerDealCalc = deal.InclusiveArtistExpensesPerDealCalc__c == null ? 0.0 : deal.InclusiveArtistExpensesPerDealCalc__c;
                Decimal GuaranteeAmount = deal.GuaranteeAmount__c == null ? 0.0 : deal.GuaranteeAmount__c;
                Decimal ArtistSuppliedSL = deal.ArtistSuppliedSL__c == null ? 0.0 : deal.ArtistSuppliedSL__c;
                Decimal OtherTalentAmount = deal.OtherTalentAmount__c == null ? 0.0 : deal.OtherTalentAmount__c;
                Decimal ArtistWalkoutPotential = deal.ArtistWalkoutPotential__c == null ? 0.0 : deal.ArtistWalkoutPotential__c;
                Decimal RollUpTalentOverheadAmount = deal.RollUpTalentOverheadAmount__c == null ? 0.0 : deal.RollUpTalentOverheadAmount__c;
                Decimal ProjectedArtistWalkout = deal.ProjectedArtistWalkout__c == null ? 0.0 : deal.ProjectedArtistWalkout__c;

                if (deal.StageType__c == 'Plan') {
                    event.sumDealPotentialInclusiveArtistExpenses += PotentialInclusiveArtistExpenses;
                    event.sumInclusiveArtistExpensesPerDealCalculation += InclusiveArtistExpensesPerDealCalc;
                    event.sumArtistGuarantees += GuaranteeAmount + ArtistSuppliedSL + OtherTalentAmount;
                    if(deal.Type__c == DEAL_PRIMARY_HEADLINER){
                        event.primaryDealType = deal.DealType__c;
                        event.primaryDealBackendPercent = deal.BackendPercent__c;
                        event.primaryDealCalculation = deal.DealCalculation__c;
                    }
                    event.eventRecord.ArtistCostsPotential__c += ArtistWalkoutPotential;
                    event.eventRecord.TalentOverhead__c += RollUpTalentOverheadAmount;
                    event.eventRecord.ProjectedArtistCosts__c += ProjectedArtistWalkout;
                }

                if (deal.StageType__c == DEAL_STAGE_TYPE_SETLLEMENT) {
                    event.sumDealPotentialInclusiveArtistExpensesSettlement += PotentialInclusiveArtistExpenses;
                    event.sumInclusiveArtistExpensesPerDealCalculationSettlement += InclusiveArtistExpensesPerDealCalc;
                    event.sumArtistGuaranteesSettlement += GuaranteeAmount + ArtistSuppliedSL + OtherTalentAmount;
                    if(deal.Type__c == DEAL_PRIMARY_HEADLINER){
                        event.primaryDealTypeSettlement = deal.DealType__c;
                        event.primaryDealBackendPercentSettlement = deal.BackendPercent__c;
                        event.primaryDealCalculationSettlement = deal.DealCalculation__c;
                    }
                    event.eventRecord.SettlementArtistSuppliedSL__c += ArtistSuppliedSL;
                    event.eventRecord.SettlementGuarantee__c += GuaranteeAmount;
                    event.eventRecord.SettlementOtherTalentAmount__c += OtherTalentAmount;
                }
            }
        }

        for (LNE_Event event : eventsToProcess) {
            event.eventRecord.NetPotPotential__c = event.eventRecord.NetGrossPotential__c - event.sumLedgerOfferAtSellout - (event.sumDealPotentialInclusiveArtistExpenses - event.sumInclusiveArtistExpensesPerDealCalculation);
            event.eventRecord.ProjectedNetPot__c = event.eventRecord.ProjectedNetGross__c - event.sumLedgerOfferAtProjection - (event.sumDealPotentialInclusiveArtistExpenses - event.sumInclusiveArtistExpensesPerDealCalculation);
            event.eventRecord.SettlementNetPot__c = event.eventRecord.SettlementNetGross__c - event.sumLedgerSettlement - (event.sumDealPotentialInclusiveArtistExpensesSettlement - event.sumInclusiveArtistExpensesPerDealCalculationSettlement);
        }

        for (LNE_Event event : eventsToProcess) {
            if(event.ticketScales != null && !event.ticketScales.isEmpty()){
                LedgerEntry__c ticketRev = getLedgerForEvent(event, '40100');
                LedgerEntry__c lawnRev = getLedgerForEvent(event, '40116');
                LedgerEntry__c groupRev = getLedgerForEvent(event, '40102');
                
                ticketRev.PlanAmount__c = 0.0;
                lawnRev.PlanAmount__c = 0.0;
                groupRev.PlanAmount__c = 0.0;
                ticketRev.ProjectionAmount__c = 0.0;
                lawnRev.ProjectionAmount__c = 0.0;
                groupRev.ProjectionAmount__c = 0.0;
                
                Decimal potentialPromoterProfitAtSplit;
                Decimal potentialSplitPoint;

                for (LNE_TicketScale ticketScale : event.ticketScales) {
                    if (event.hasPlan == true) {
                        if (ticketScale.ticketScaleRecord.StageType__c == 'Plan') {
                            if (ticketScale.ticketScaleRecord.Type__c != null && ticketScale.ticketScaleRecord.Type__c.startsWith('Lawn') == false) {
                                ticketRev.PlanAmount__c += (ticketScale.ticketScaleRecord.ProjectedGrossSales__c - ticketScale.ticketScaleRecord.BeforeAdjustedDeductions__c - ticketScale.ticketScaleRecord.AfterAdjustedDeductions__c);
                            } 

                            if (ticketScale.ticketScaleRecord.Type__c != null && ticketScale.ticketScaleRecord.Type__c.startsWith('Lawn') == true) {
                                lawnRev.PlanAmount__c += (ticketScale.ticketScaleRecord.ProjectedGrossSales__c - ticketScale.ticketScaleRecord.BeforeAdjustedDeductions__c - ticketScale.ticketScaleRecord.AfterAdjustedDeductions__c);
                            } 

                            groupRev.PlanAmount__c += (ticketScale.ticketScaleRecord.LiftBeforeTaxes__c - ticketScale.ticketScaleRecord.PlatinumBeforeAdjustedDeductions__c - ticketScale.ticketScaleRecord.PlatinumAfterAdjusted_Deductions__c);
                        }
                    }

                    if (event.hasProjection == true) {
                        if (ticketScale.ticketScaleRecord.StageType__c == 'Projection') {
                            if (ticketScale.ticketScaleRecord.Type__c != null && ticketScale.ticketScaleRecord.Type__c.startsWith('Lawn') == false) {
                                ticketRev.ProjectionAmount__c += (ticketScale.ticketScaleRecord.ProjectedGrossSales__c - ticketScale.ticketScaleRecord.BeforeAdjustedDeductions__c - ticketScale.ticketScaleRecord.AfterAdjustedDeductions__c);
                            } 

                            if (ticketScale.ticketScaleRecord.Type__c != null && ticketScale.ticketScaleRecord.Type__c.startsWith('Lawn') == true) {
                                lawnRev.ProjectionAmount__c += (ticketScale.ticketScaleRecord.ProjectedGrossSales__c - ticketScale.ticketScaleRecord.BeforeAdjustedDeductions__c - ticketScale.ticketScaleRecord.AfterAdjustedDeductions__c);
                            } 

                            groupRev.ProjectionAmount__c += (ticketScale.ticketScaleRecord.LiftBeforeTaxes__c - ticketScale.ticketScaleRecord.PlatinumBeforeAdjustedDeductions__c - ticketScale.ticketScaleRecord.PlatinumAfterAdjusted_Deductions__c);
                        }
                    }
                }

                if (ticketRev.GLAccount__c != null) {
                    ledgerIdsToUpdate.add(ticketRev.Id);
                    ledgersToUpdate.add(ticketRev); 
                }

                if (lawnRev.GLAccount__c != null) {
                    ledgerIdsToUpdate.add(lawnRev.Id);
                    ledgersToUpdate.add(lawnRev);
                }

                if (groupRev.GLAccount__c != null) {
                    ledgerIdsToUpdate.add(groupRev.Id);
                    ledgersToUpdate.add(groupRev);
                }
            }

            System.debug(event.eventRecord);
            System.debug(event.eventRecord.LedgerEntries__r.size());
            for(LedgerEntry__c le : event.eventRecord.LedgerEntries__r) {
                     if(le.FlashRateType__c != null && le.FlashRateAmount__c != null){
                        System.debug('Flash Rate Type' + le.FlashRateType__c);
                        System.debug('Flash Rate Amount ' + le.FlashRateAmount__c);
                        le.CurrentFlash__c = LNE_LedgerCalculateCurrentFlash.calculateCurrentFlashLE(le, event.eventRecord).CurrentFlash__c;
                        if (!ledgerIdsToUpdate.contains(le.Id)) {
                            ledgerIdsToUpdate.add(le.Id);
                            ledgersToUpdate.add(le);
                        }
                    }
                    List<LedgerEntryBreakout__c> leBreakouts = ancillaryBreakoutsPerId.get(le.Id);
                    if (leBreakouts != null){
                        for(LedgerEntryBreakout__c lebr : leBreakouts){
                            if(lebr.FlashRateType__c != null && lebr.FlashRateAmount__c != null){
                                 System.debug('Flash Rate Type' + lebr.FlashRateType__c);
                                 System.debug('Flash Rate Amount ' + lebr.FlashRateAmount__c);
                                lebr.CurrentFlash__c = LNE_LedgerCalculateCurrentFlash.calculateCurrentFlashLEB(lebr, event.eventRecord).CurrentFlash__c;
                                if(!ledgerBreakoutIdsToUpdate.contains(lebr.Id)){
                                    ledgerBreakoutIdsToUpdate.add(lebr.Id);
                                    ledgersBreakoutsToUpdate.add(lebr);
                                }
                            }
                            
                        }
                    }

                
            }
            
            for (LedgerEntry__c le : event.eventRecord.LedgerEntries__r) {
                
               
                
                if (le.RecordTypeId == RT_EXPENSES_ID || le.RecordTypeId == RT_ANCILLARY_ID || le.RecordTypeId == RT_COGS_ID){
                    event.eventRecord.PLAfterPrimaryCoProsAtProjection__c += le.PrimaryCoProShareAtProjection__c;
                    event.eventRecord.PLAfterPrimaryCoProsAtSellout__c += le.PrimaryCoProShareAtSellout__c;
                }
                
                if (le.RecordTypeId == RT_EXPENSES_ID) {
                    expenseCalculation(event, le);
                    List<LedgerEntryBreakout__c> leBreakouts = expenseBreakoutsPerId.get(le.Id);
                    if (leBreakouts != null){
                        for(LedgerEntryBreakout__c lebr : leBreakouts){
                            expenseBreakoutCalculation(event, lebr);
                            if(!ledgerBreakoutIdsToUpdate.contains(lebr.Id)){
                                    ledgerBreakoutIdsToUpdate.add(lebr.Id);
                                    ledgersBreakoutsToUpdate.add(lebr);
                            }
                        }
                    }

                    if (!ledgerIdsToUpdate.contains(le.Id)) {
                        ledgerIdsToUpdate.add(le.Id);
                        ledgersToUpdate.add(le);
                    }
                }
                if (le.RecordTypeId == RT_ANCILLARY_ID) {
                    ancillaryCalculation(event, le);
                    List<LedgerEntryBreakout__c> leBreakouts = ancillaryBreakoutsPerId.get(le.Id);
                    if (leBreakouts != null){
                        for(LedgerEntryBreakout__c lebr : leBreakouts){
                            ancillaryBreakoutCalculation(event, lebr);
                            if(!ledgerBreakoutIdsToUpdate.contains(lebr.Id)){
                                    ledgerBreakoutIdsToUpdate.add(lebr.Id);
                                    ledgersBreakoutsToUpdate.add(lebr);
                            }
                        }
                    }

                    if (!ledgerIdsToUpdate.contains(le.Id)) {
                        ledgerIdsToUpdate.add(le.Id);
                        ledgersToUpdate.add(le);
                    }
                }
                if (le.RecordTypeId == RT_COGS_ID) {
                    cogsCalculation(event, le);
                    List<LedgerEntryBreakout__c> leBreakouts = cogsBreakoutsPerId.get(le.Id);
                    if (leBreakouts != null){
                        for(LedgerEntryBreakout__c lebr : leBreakouts){
                            cogsBreakoutCalculation(event, lebr);
                            if(!ledgerBreakoutIdsToUpdate.contains(lebr.Id)){
                                    ledgerBreakoutIdsToUpdate.add(lebr.Id);
                                    ledgersBreakoutsToUpdate.add(lebr);
                            }
                        }
                    }

                    if (!ledgerIdsToUpdate.contains(le.Id)) {
                        ledgerIdsToUpdate.add(le.Id);
                        ledgersToUpdate.add(le);
                    }
                }
            }
            
            //- Plan deals
            if(event.primaryDealType == DEAL_TYPE_GROSS_SPLIT_POINT ){
                event.eventRecord.PotentialToBeSharedAmount__c = event.eventRecord.NetGrossPotential__c - event.sumLedgerOfferAtSellout - event.sumArtistGuarantees;
                event.eventRecord.PotentialSplitPoint__c = event.sumLedgerOfferAtSellout + event.sumArtistGuarantees;
                event.eventRecord.ProjectedToBeSharedAmount__c = event.eventRecord.ProjectedNetGross__c - event.sumLedgerOfferAtProjection + event.sumArtistGuarantees;
                event.eventRecord.ProjectedSplitPoint__c = event.sumLedgerOfferAtProjection + event.sumArtistGuarantees;
            }

            if(event.primaryDealType == DEAL_TYPE_PROMOTER_PROFIT ){
                event.projectedPromoterProfitAtSplit = ((1 - (event.primaryDealBackendPercent /100)) * (event.sumLedgerOfferAtProjection + event.sumArtistGuarantees ));
                event.eventRecord.ProjectedToBeSharedAmount__c = event.eventRecord.ProjectedNetPot__c - event.sumArtistGuarantees - event.projectedPromoterProfitAtSplit;
                event.eventRecord.ProjectedSplitPoint__c = ((2 - (event.primaryDealBackendPercent /100)) * (event.sumLedgerOfferAtProjection + event.sumArtistGuarantees ));
                event.potentialPromoterProfitAtSplit = ((1 - (event.primaryDealBackendPercent /100)) * (event.sumLedgerOfferAtSellout + event.sumArtistGuarantees ));
                event.eventRecord.PotentialToBeSharedAmount__c = event.eventRecord.NetPotPotential__c - event.sumArtistGuarantees - event.potentialPromoterProfitAtSplit;
                event.eventRecord.PotentialSplitPoint__c = ((2 - (event.primaryDealBackendPercent / 100)) * (event.sumLedgerOfferAtSellout + event.sumArtistGuarantees ));
            }

            //- Settlement deals
            if(event.primaryDealTypeSettlement == DEAL_TYPE_GROSS_SPLIT_POINT ){
                event.eventRecord.SettlementToBeSharedAmount__c = event.eventRecord.SettlementNetGross__c - event.sumLedgerSettlement + event.sumArtistGuaranteesSettlement;
                event.eventRecord.SettlementSplitPoint__c = event.sumLedgerSettlement + event.sumArtistGuaranteesSettlement;
            }
            
            if(event.primaryDealTypeSettlement == DEAL_TYPE_PROMOTER_PROFIT ){
                event.settlementPromoterProfitAtSplit = ((1 - (event.primaryDealBackendPercentSettlement /100)) * (event.sumLedgerSettlement + event.sumArtistGuaranteesSettlement ));
                event.eventRecord.SettlementToBeSharedAmount__c = event.eventRecord.SettlementNetPot__c - event.sumArtistGuaranteesSettlement - event.settlementPromoterProfitAtSplit;
                event.eventRecord.SettlementSplitPoint__c = ((2 - (event.primaryDealBackendPercentSettlement /100)) * (event.sumLedgerSettlement + event.sumArtistGuaranteesSettlement ));
            }
            
            event.eventRecord.SettlementDealType__c = event.primaryDealTypeSettlement;
            event.eventRecord.SettlementBackendPercentage__c = event.primaryDealBackendPercentSettlement;
            event.eventRecord.SettlementDealCalculation__c = event.primaryDealCalculationSettlement; 

        }

        update ticketScalesToUpdate;
        update deductionsToUpdate;
        update events;
        upsert ledgersToUpdate;
        update ledgersBreakoutsToUpdate;

        if (dealIds.size() > 0) {
            List<BonusDetail__c> bonusRecords = [SELECT BonusPotentialatProjectionRetro__c,
                                                        BonusPotentialatProjectionStepUp__c,
                                                        BonusPotentialatSelloutRetro__c,
                                                        BonusPotentialatSelloutStepUp__c,
                                                        SettlementBonusRetro__c,
                                                        SettlementBonusStepUp__c
                                                 FROM BonusDetail__c
                                                 WHERE Deal__c IN :dealIds];
    
            for (BonusDetail__c bd : bonusRecords) {
                bd.BonusPotentialatProjection__c = bd.BonusPotentialatProjectionRetro__c + bd.BonusPotentialatProjectionStepUp__c;
                bd.BonusPotentialatSellout__c = bd.BonusPotentialatSelloutRetro__c + bd.BonusPotentialatSelloutStepUp__c;
                bd.SettlementBonus__c = bd.SettlementBonusRetro__c + bd.SettlementBonusStepUp__c;
            }
    
            update bonusRecords;
        }
        
        List<LedgerEntry__c> ledgersToUpsert = new List<LedgerEntry__c>();
        for (LNE_Event event : eventsToProcess) {
            decimal sumDealProfitSellout = 0.0;
            decimal sumDealProfitProjection = 0.0;
            decimal sumDealExpenseSellout = 0.0;
            decimal sumDealExpenseProjection = 0.0;
            decimal sumLedgerExpenseSellout = 0.0;
            decimal sumLedgerExpenseProjection = 0.0;
            decimal sumDealAncillarySellout = 0.0;
            decimal sumDealAncillaryProjection = 0.0;
            decimal sumLedgerNetRevenueAtSellout = 0.0;
            decimal sumLedgerNetRevenueAtProjection = 0.0;
            decimal sumCOGSAtSellout = 0.0;
            decimal sumCOGSAtForecast = 0.0;
            decimal sumDealBonusSellout = 0.0;
            decimal sumDealBonusProjection = 0.0;
            decimal sumSecondaryDealProfitSellout = 0.0;
            decimal sumSecondaryDealProfitProjection = 0.0;
            decimal sumSecondaryDealExpenseSellout = 0.0;
            decimal sumSecondaryDealExpenseProjection = 0.0;
            decimal sumSecondaryLedgerExpenseSellout = 0.0;
            decimal sumSecondaryLedgerExpenseProjection = 0.0;
            decimal sumSecondaryDealAncillarySellout = 0.0;
            decimal sumSecondaryDealAncillaryProjection = 0.0;
            decimal sumSecondaryLedgerNetRevenueAtSellout = 0.0;
            decimal sumSecondaryLedgerNetRevenueAtProjection = 0.0;
            decimal sumSecondaryCOGSAtSellout = 0.0;
            decimal sumSecondaryCOGSAtForecast = 0.0;
            decimal sumSecondaryDealBonusSellout = 0.0;
            decimal sumSecondaryDealBonusProjection = 0.0;
             
            // Ledger Entries for Co-Promoter Payouts
            decimal sumPlanOwnedOperated = 0.0;
            decimal sumProjectionOwnedOperated = 0.0;
            decimal sumPlanExclusivelyBooked = 0.0;
            decimal sumProjectionExclusivelyBooked = 0.0;
            //decimal sumCoProShareExclusivelyBooked = 0.0;

            // US651 - Ledger Entries for Guarantee
            decimal sumPrimaryGuarantee = 0.0;
            decimal sumPrimaryArtistSuppliedSL = 0.0;
            decimal sumOtherTalentFeeExpenses = 0.0;
            decimal sumSecondaryGuarantee = 0.0;
            decimal sumSharingProjectedOverage = 0.0;

            // US752 - Ledger Entries for gospel Brunch
            decimal gospelBrunchRevenueAmount = 0.0;
            decimal gospelBrunchFoodRevenueAmount = 0.0;
            decimal gospelBrunchCostsAmount = 0.0;
            decimal gospelBrunchBandAmount = 0.0;
             
            Deal__c LNPrimaryCoProRow = new Deal__c();
            Deal__c LNSecondaryCoProRow = new Deal__c();
             
            if (event.eventRecord.LedgerEntries__r != null){
                for (LedgerEntry__c le : event.eventRecord.LedgerEntries__r) {
                    if (le.RecordTypeId == RT_EXPENSES_ID) {
                        if (le.ExpenseAdjustmentatSellout__c != null) {
                            sumledgerExpenseSellout += le.ExpenseAdjustmentatSellout__c;
                        }
                           
                        if (le.ExpenseAdjustment__c != null) {
                            sumLedgerExpenseProjection += le.ExpenseAdjustment__c;
                        }
                    }
                    
                    if (le.RecordTypeId == RT_ANCILLARY_ID) {
                        if (le.NetRevenueatSellout__c != null)
                            sumLedgerNetRevenueAtSellout += le.NetRevenueatSellout__c;
                           
                        if (le.NetRevenue__c != null)
                            sumLedgerNetRevenueAtProjection += le.NetRevenue__c;
                    }
                    
                    if (le.RecordTypeId == RT_COGS_ID) {
                        if (le.COGSAtSellout__c != null)
                            sumCOGSAtSellout += le.COGSAtSellout__c;
                           
                        if (le.COGSAtForecast__c != null)
                            sumCOGSAtForecast += le.COGSAtForecast__c;
                    }
                }
            }
              
            if (event.eventRecord.Deals__r != null){
                for (Deal__c deal : event.eventRecord.Deals__r) {
            		
            		if(
            			//-- 2017-03-31: primary and co should be updated to ensure ArtistBackendCalculations are updated.
            			( deal.Type__c == DEAL_PRIMARY_HEADLINER || deal.Type__c == DEAL_TYPE_CO_HEADLINER )
            		){
						dealsToUpdate.add(deal);
            		}

                    //-- PR 2017-03-31: separate the percent (0.20) and percentage (20%)
                    deal.SplitBackendPercent__c = getDecimal(deal.SplitBackendPercent__c, 1);
                    Decimal splitBackendPercentage = getDecimal(deal.SplitBackendPercent__c/ 100.0, 1);

                     // SW 23/02/17 US739 TA3129: additional Deals calculations.  cannot be added above as there would be dependency conflicts
                    if (deal.DealType__c == 'Percentage of Gross') {

                        deal.ArtistBackendCalculationPotential__c = getDecimal(event.eventRecord.NetGrossPotential__c) * splitBackendPercentage;
                        deal.ProjectedArtistBackendCalculation__c = getDecimal(event.eventRecord.ProjectedNetGross__c) * splitBackendPercentage;
                        deal.SettlementArtistBackendCalculation__c = getDecimal(event.eventRecord.SettlementNetGross__c) * splitBackendPercentage;

                    }
                    else if (deal.DealType__c == 'Percentage of Net') {

                        deal.ArtistBackendCalculationPotential__c = getDecimal(event.eventRecord.NetPotPotential__c) * splitBackendPercentage;
                        deal.ProjectedArtistBackendCalculation__c = getDecimal(event.eventRecord.ProjectedNetPot__c) * splitBackendPercentage;
                        deal.SettlementArtistBackendCalculation__c = getDecimal(event.eventRecord.SettlementNetPot__c) * splitBackendPercentage;
						
                    }
                    else if (deal.DealType__c == 'Promoter Profit') {
						
                        deal.ArtistBackendCalculationPotential__c = getDecimal(event.eventRecord.PotentialToBeSharedAmount__c) * splitBackendPercentage;
                        deal.ProjectedArtistBackendCalculation__c = getDecimal(event.eventRecord.ProjectedToBeSharedAmount__c) * splitBackendPercentage;
                        deal.SettlementArtistBackendCalculation__c = getDecimal(event.eventRecord.SettlementToBeSharedAmount__c) * splitBackendPercentage;

                    }
                    else if (deal.DealType__c == 'Gross Split Point') {

                        deal.ArtistBackendCalculationPotential__c = getDecimal(deal.InclusiveArtistExpensesPerDealCalc__c) + getDecimal(event.eventRecord.PotentialToBeSharedAmount__c) * splitBackendPercentage;
                        deal.ProjectedArtistBackendCalculation__c = getDecimal(deal.InclusiveArtistExpensesPerDealCalc__c) + getDecimal(event.eventRecord.ProjectedToBeSharedAmount__c) * splitBackendPercentage;
                        deal.SettlementArtistBackendCalculation__c =getDecimal( deal.InclusiveArtistExpensesPerDealCalc__c) + getDecimal(event.eventRecord.SettlementToBeSharedAmount__c) * splitBackendPercentage;

                    }
                    else {

                        // set defaults
                        deal.ArtistBackendCalculationPotential__c = getDecimal(deal.BackendPotential__c);
                        deal.ProjectedArtistBackendCalculation__c = getDecimal(deal.ProjectedBackend__c);
                        deal.SettlementArtistBackendCalculation__c = getDecimal(deal.SettlementBackend__c);

                    }

                    if ((deal.Type__c == 'Venue' || deal.Type__c == '3rd Party') && event.eventRecord.Venue__r.OwnershipType__c == 'Owned/Operated'){
                        if (event.eventRecord.StatusStage__c == 'Plan'){
                            sumPlanOwnedOperated += deal.ProfitShareAmountAtProjection__c + deal.ExpenseAdjustmentShareAmountAtProj__c + deal.AncillaryShareAmountAtProjection__c;
                        } else if (event.eventRecord.StatusStage__c == 'Projection'){
                            sumProjectionOwnedOperated += deal.ProfitShareAmountAtProjection__c + deal.ExpenseAdjustmentShareAmountAtProj__c + deal.AncillaryShareAmountAtProjection__c;
                        }
                    } else if ((deal.Type__c == 'Venue' && (event.eventRecord.Venue__r.OwnershipType__c == 'Third Party') || event.eventRecord.Venue__r.OwnershipType__c == 'Exclusively Booked')) {
                        if (event.eventRecord.StatusStage__c == 'Plan'){
                            sumPlanExclusivelyBooked += deal.ProfitShareAmountAtProjection__c + deal.ExpenseAdjustmentShareAmountAtProj__c;
                        } else if (event.eventRecord.StatusStage__c == 'Projection'){
                            sumProjectionExclusivelyBooked += deal.ProfitShareAmountAtProjection__c + deal.ExpenseAdjustmentShareAmountAtProj__c;
                        }
                    }
            
                    if (deal.Type__c == 'Internal' && deal.PrimarySecondaryCoPromoter__c == 'Primary' && deal.Id != null){
                        LNPrimaryCoProRow = deal;
                    } else if (deal.Type__c == 'Internal' && deal.PrimarySecondaryCoPromoter__c == 'Secondary' && deal.Id != null) {
                        LNSecondaryCoProRow = deal;
                    } else if (deal.PrimarySecondaryCoPromoter__c == 'Primary' && deal.Type__c != 'Internal') {
                        if (deal.ShareInTalentOverhead__c == TRUE){
                            deal.ProfitShareAmtAtSellFC__c = event.eventRecord.NetPotPotential__c - event.eventRecord.ArtistCostsPotential__c - event.eventRecord.TalentOverhead__c;
                            deal.ProfitShareAmtAtProjFC__c = event.eventRecord.ProjectedNetPot__c - event.eventRecord.ProjectedArtistCosts__c - event.eventRecord.TalentOverhead__c;
                        } else {
                            deal.ProfitShareAmtAtSellFC__c = event.eventRecord.NetPotPotential__c - event.eventRecord.ArtistCostsPotential__c;
                            deal.ProfitShareAmtAtProjFC__c = event.eventRecord.ProjectedNetPot__c - event.eventRecord.ProjectedArtistCosts__c;
                        }
                
                        if (deal.ProfitShareAmountAtSellout__c != null)
                            sumDealProfitSellout += deal.ProfitShareAmountAtSellout__c;
                
                        if (deal.ProfitShareAmountAtProjection__c != null)
                            sumDealProfitProjection += deal.ProfitShareAmountAtProjection__c;
                
                        if (deal.ExpenseAdjustmentShareAmountAtSell__c != null)
                            sumDealExpenseSellout += deal.ExpenseAdjustmentShareAmountAtSell__c;
                        
                        if (deal.ExpenseAdjustmentShareAmountAtProj__c != null)
                            sumDealExpenseProjection += deal.ExpenseAdjustmentShareAmountAtProj__c;
                        
                        if (deal.AncillaryShareAmountAtSellout__c != null)
                            sumDealAncillarySellout += deal.AncillaryShareAmountAtSellout__c;
                        
                        if (deal.AncillaryShareAmountAtProjection__c != null)
                            sumDealAncillaryProjection += deal.AncillaryShareAmountAtProjection__c;
                        
                        if (deal.CoPromoterBonusAtSellout__c != null)
                            sumDealBonusSellout += deal.CoPromoterBonusAtSellout__c;
                        
                        if (deal.CoPromoterBonusAtProjection__c != null)
                            sumDealBonusProjection += deal.CoPromoterBonusAtProjection__c;
                        
                        dealsToUpdate.add(deal);
                    } 

                    // US651 - if deal is primary headliner get the guarantee amount for ledger entry.
                    if(deal.StageType__c == 'Plan'){
                        if(deal.Type__c == DEAL_PRIMARY_HEADLINER){
                            if(deal.GuaranteeAmount__c != null ) sumPrimaryGuarantee += deal.GuaranteeAmount__c;
                            if(deal.ArtistSuppliedSL__c != null ) sumPrimaryArtistSuppliedSL += deal.ArtistSuppliedSL__c;
                            if(deal.OtherTalentAmount__c != null ) sumOtherTalentFeeExpenses += deal.OtherTalentAmount__c;
                            if(deal.ProjectedBonus__c != null ) sumOtherTalentFeeExpenses += deal.ProjectedBonus__c;
                            if(deal.RollUpTalentOverheadAmount__c != null ) sumOtherTalentFeeExpenses += deal.RollUpTalentOverheadAmount__c;
                            if(deal.ProjectedOverage__c != null ) sumSharingProjectedOverage += deal.ProjectedOverage__c;
                        }else if(deal.Type__c  == DEAL_TYPE_ARTIST){
                            if(deal.ProfitShareAmountAtProjection__c != null) sumOtherTalentFeeExpenses += deal.ProfitShareAmountAtProjection__c ;
                            if(deal.ExpenseAdjustmentShareAmountAtProj__c != null) sumOtherTalentFeeExpenses += deal.ExpenseAdjustmentShareAmountAtProj__c ;
                            if(deal.AncillaryShareAmountAtProjection__c != null) sumOtherTalentFeeExpenses += deal.AncillaryShareAmountAtProjection__c ;
                        }else if(deal.Type__c  == DEAL_TYPE_CO_HEADLINER){
                            if(deal.GuaranteeAmount__c != null) sumSecondaryGuarantee +=  deal.GuaranteeAmount__c;
                            if(deal.ArtistSuppliedSL__c != null) sumSecondaryGuarantee +=  deal.ArtistSuppliedSL__c;
                            if(deal.OtherTalentAmount__c != null) sumSecondaryGuarantee +=  deal.OtherTalentAmount__c ;
                            if(deal.RollUpTalentOverheadAmount__c != null) sumSecondaryGuarantee += deal.RollUpTalentOverheadAmount__c;
                            if(deal.ProjectedBonus__c != null ) sumSecondaryGuarantee += deal.ProjectedBonus__c;
                            
                            if(deal.ProjectedOverage__c != null) sumSharingProjectedOverage += deal.ProjectedOverage__c;
                        }else if(deal.Type__c  == DEAL_TYPE_SUPPORT){
                            if(deal.GuaranteeAmount__c != null) sumSecondaryGuarantee +=  deal.GuaranteeAmount__c;
                            if(deal.ArtistSuppliedSL__c != null) sumSecondaryGuarantee +=  deal.ArtistSuppliedSL__c;
                            if(deal.OtherTalentAmount__c != null) sumSecondaryGuarantee +=  deal.OtherTalentAmount__c ;
                            if(deal.RollUpTalentOverheadAmount__c != null) sumSecondaryGuarantee += deal.RollUpTalentOverheadAmount__c;
                            if(deal.ProjectedBonus__c != null ) sumSecondaryGuarantee += deal.ProjectedBonus__c;
                        }
                    }
                } // end for loop on deals
            }// end if

            // US752 - Amount calculation for gospel Brunch  Ledger Entries 
            if(event.eventRecord.RecordTypeId == RT_GOSPEL_BRUNCH_ID){
                gospelBrunchRevenueAmount += (event.eventRecord.ProjectedNetGross__c == NULL ? 0.0 : event.eventRecord.ProjectedNetGross__c );
                if (event.eventRecord.Deals__r != null){
                    Boolean eventExpenseIncluded_Guarantee = false;
                    Boolean eventExpenseIncluded_OtherTalent = false;
                    Boolean eventExpenseIncluded_Sound = false;
                    Boolean eventExpenseIncluded_SoundAndOtherTalent = false;

                    for (Deal__c deal : event.eventRecord.Deals__r) {
                        if(deal.RecordTypeId == RT_COPROMOTER_ID && deal.Type__c != 'Internal') {
                            gospelBrunchRevenueAmount -= (deal.CoPromoterWalkoutAtProjection__c == NULL ? 0.0 : deal.CoPromoterWalkoutAtProjection__c );
                        }

                        if(deal.RecordTypeId == RT_DEAL_ARTIST_ID){
                            gospelBrunchBandAmount += (deal.ProjectedArtistWalkout__c == NULL ? 0.0 : deal.ProjectedArtistWalkout__c );
                            
                            if(deal.DealCalculation__c == 'Guarantee Only'){
                                gospelBrunchBandAmount += (deal.ArtistSuppliedSL__c + deal.OtherTalentAmount__c);
                                if(eventExpenseIncluded_Guarantee == false){
                                   gospelBrunchBandAmount += event.eventRecord.TotalSupportActExpenses__c; 
                                   eventExpenseIncluded_Guarantee = true;
                                }
                            }
                            if(deal.DealCalculation__c == 'Inclusive of Other Talent Amount'){
                                gospelBrunchBandAmount += (deal.ArtistSuppliedSL__c);
                                if(eventExpenseIncluded_OtherTalent == false){
                                   gospelBrunchBandAmount += event.eventRecord.TotalSupportActExpenses__c; 
                                   eventExpenseIncluded_OtherTalent = true;
                                }
                            }
                            if(deal.DealCalculation__c == 'Inclusive of Sound & Lights'){
                                gospelBrunchBandAmount += (deal.OtherTalentAmount__c);
                                if(eventExpenseIncluded_Sound == false){
                                   gospelBrunchBandAmount += event.eventRecord.TotalSupportActExpenses__c; 
                                   eventExpenseIncluded_Sound = true;
                                }
                            }
                            if(deal.DealCalculation__c == 'Inclusive of Sound & Lights & Other Talent Amount'){
                                if(eventExpenseIncluded_SoundAndOtherTalent == false){
                                   gospelBrunchBandAmount += event.eventRecord.TotalSupportActExpenses__c; 
                                   eventExpenseIncluded_SoundAndOtherTalent = true;
                                }
                            }
                            if(deal.DealCalculation__c == 'Inclusive of Sound & Lights & Support'){
                                gospelBrunchBandAmount += (deal.OtherTalentAmount__c);
                            }
                            if(deal.DealCalculation__c == 'Inclusive of Support'){
                                gospelBrunchBandAmount += (deal.ArtistSuppliedSL__c + deal.OtherTalentAmount__c);
                            }
                            if(deal.DealCalculation__c == 'Inclusive of Support And Other Talent Amount'){
                                gospelBrunchBandAmount += (deal.ArtistSuppliedSL__c);
                            }
                        }
                    }
                }
                system.debug(LoggingLevel.Error, '@@@ event.eventRecord.LedgerEntries__r - '+ event.eventRecord.LedgerEntries__r);
                
                if (event.eventRecord.LedgerEntries__r != null){
                    for (LedgerEntry__c le : event.eventRecord.LedgerEntries__r) {
                        system.debug(LoggingLevel.Error, '@@@ gospalBruch le  - '+ le.Id + ' - ' + le.InHouseProjection__c + ' - ' + le.COGSAtForecast__c + ' - ' + le.GLCode__c + ' - ' + le);
                        if(le.RecordTypeId == RT_ANCILLARY_ID) {
                            gospelBrunchFoodRevenueAmount += (le.NetRevenue__c == NULL ? 0.0 : le.NetRevenue__c );
                        }
                        if(le.RecordTypeId == RT_EXPENSES_ID) {
                            gospelBrunchCostsAmount += (le.InHouseProjection__c == NULL ? 0.0 : le.InHouseProjection__c );
                        }
                        if(le.RecordTypeId == RT_COGS_ID) {
                            gospelBrunchCostsAmount += (le.COGSAtForecast__c == NULL ? 0.0 : le.COGSAtForecast__c );
                        }
                    }
                }
                system.debug(LoggingLevel.Error, '@@@ gospelBrunchCostsAmount - '+ gospelBrunchCostsAmount);
            }
            //end if - US752 
            
            // Primary
            if (LNPrimaryCoProRow.Id != null){
                LNPrimaryCoProRow.LNEProfitShareAmountAtSellout__c =       event.eventRecord.NetPotPotential__c - event.eventRecord.ArtistCostsPotential__c - 
                                                                             event.eventRecord.TalentOverhead__c - sumDealProfitSellout - sumDealBonusSellout;
                LNPrimaryCoProRow.LNEProfitShareAmountAtProjection__c =    event.eventRecord.ProjectedNetPot__c - event.eventRecord.ProjectedArtistCosts__c - 
                                                                             event.eventRecord.TalentOverhead__c - sumDealProfitProjection - sumDealBonusProjection;
                LNPrimaryCoProRow.LNEExpenseAdjShareAmountAtSell__c =      sumLedgerExpenseSellout - sumDealExpenseSellout;
                
                LNPrimaryCoProRow.LNEExpenseAdjShareAmountAtProj__c =      sumledgerExpenseProjection - sumDealExpenseProjection;
                LNPrimaryCoProRow.LNEAncillaryShareAmountAtSellout__c =    sumLedgerNetRevenueAtSellout - sumCOGSAtSellout - sumDealAncillarySellout;
                LNPrimaryCoProRow.LNEAncillaryShareAmountAtProjection__c = sumLedgerNetRevenueAtProjection - sumCOGSAtForecast - sumDealAncillaryProjection;
                LNPrimaryCoProRow.LNECoPromoterWalkoutAtSellout__c =       LNPrimaryCoProRow.LNEProfitShareAmountAtSellout__c + LNPrimaryCoProRow.LNEExpenseAdjShareAmountAtSell__c + LNPrimaryCoProRow.LNEAncillaryShareAmountAtSellout__c + 0;
                LNPrimaryCoProRow.LNECoPromoterWalkoutAtProjection__c =    LNPrimaryCoProRow.LNEProfitShareAmountAtProjection__c + LNPrimaryCoProRow.LNEExpenseAdjShareAmountAtProj__c + LNPrimaryCoProRow.LNEAncillaryShareAmountAtProjection__c + 0;
                event.eventRecord.PLAfterPrimaryCoProsAtSellout__c =    LNPrimaryCoProRow.LNEProfitShareAmountAtSellout__c;
                event.eventRecord.PLAfterPrimaryCoProsAtProjection__c = LNPrimaryCoProRow.LNEProfitShareAmountAtProjection__c;
                dealsToUpdate.add(LNPrimaryCoProRow);
            }
            
            if (event.eventRecord.Deals__r != null){
                for (Deal__c deal : event.eventRecord.Deals__r) {
                    if (deal.PrimarySecondaryCoPromoter__c == 'Secondary' && deal.Type__c != 'Internal') {
                        if (deal.ShareInTalentOverhead__c == FALSE){
                            deal.ProfitShareAmtAtSellFC__c = event.eventRecord.PLAfterPrimaryCoProsAtSellout__c + event.eventRecord.TalentOverhead__c;
                            deal.ProfitShareAmtAtProjFC__c = event.eventRecord.PLAfterPrimaryCoProsAtProjection__c + event.eventRecord.TalentOverhead__c;
                        } else {
                            deal.ProfitShareAmtAtSellFC__c = event.eventRecord.PLAfterPrimaryCoProsAtSellout__c;
                            deal.ProfitShareAmtAtProjFC__c = event.eventRecord.PLAfterPrimaryCoProsAtProjection__c;
                        }
            
                        if (deal.ProfitShareAmountAtSellout__c != null){
                            if (deal.ProfitShareAmtAtSellFC__c != null && deal.ProfitShareAmtAtSellFC__c >= 0){
                                sumSecondaryDealProfitSellout += deal.EventProfit__c / 100 * deal.ProfitShareAmtAtSellFC__c;
                            } else {
                                sumSecondaryDealProfitSellout += deal.EventLoss__c / 100 * deal.ProfitShareAmtAtSellFC__c;
                            }    
                        }
                        
                        if (deal.ProfitShareAmountAtProjection__c != null){
                            if (deal.ProfitShareAmtAtProjFC__c != null && deal.ProfitShareAmtAtProjFC__c >= 0){
                                sumSecondaryDealProfitProjection += deal.EventProfit__c / 100 * deal.ProfitShareAmtAtProjFC__c;
                            } else {
                                sumSecondaryDealProfitProjection += deal.EventLoss__c / 100 * deal.ProfitShareAmtAtProjFC__c;
                            }
                        }
                        
                        if (deal.ExpenseAdjustmentShareAmountAtSell__c != null)
                            sumSecondaryDealExpenseSellout += deal.ExpenseAdjustmentShareAmountAtSell__c;
                        
                        if (deal.ExpenseAdjustmentShareAmountAtProj__c != null)
                            sumSecondaryDealExpenseProjection += deal.ExpenseAdjustmentShareAmountAtProj__c;
                        
                        if (deal.AncillaryShareAmountAtSellout__c != null)
                            sumSecondaryDealAncillarySellout += deal.AncillaryShareAmountAtSellout__c;
                        
                        if (deal.AncillaryShareAmountAtProjection__c != null)
                            sumSecondaryDealAncillaryProjection += deal.AncillaryShareAmountAtProjection__c;
                        
                        if (deal.CoPromoterBonusAtSellout__c != null)
                            sumSecondaryDealBonusSellout += deal.CoPromoterBonusAtSellout__c;
                        
                        if (deal.CoPromoterBonusAtProjection__c != null)
                            sumSecondaryDealBonusProjection += deal.CoPromoterBonusAtProjection__c;
                        
                        dealsToUpdate.add(deal);
                    }
                } // end for loop on deals
            }// end if
            
            if (LNSecondaryCoProRow.Id != null){
                LNSecondaryCoProRow.LNEProfitShareAmountAtSellout__c =       LNPrimaryCoProRow.LNEProfitShareAmountAtSellout__c - sumSecondaryDealProfitSellout - sumSecondaryDealBonusSellout;
                LNSecondaryCoProRow.LNEProfitShareAmountAtProjection__c =    LNPrimaryCoProRow.LNEProfitShareAmountAtProjection__c - sumSecondaryDealProfitProjection - sumSecondaryDealBonusProjection;
                LNSecondaryCoProRow.LNEExpenseAdjShareAmountAtSell__c =      LNPrimaryCoProRow.LNEExpenseAdjShareAmountAtSell__c - sumSecondaryDealExpenseSellout;
                LNSecondaryCoProRow.LNEExpenseAdjShareAmountAtProj__c =      LNPrimaryCoProRow.LNEExpenseAdjShareAmountAtProj__c - sumSecondaryDealExpenseProjection;
                LNSecondaryCoProRow.LNEAncillaryShareAmountAtSellout__c =    LNPrimaryCoProRow.LNEAncillaryShareAmountAtSellout__c - sumSecondaryDealAncillarySellout;
                LNSecondaryCoProRow.LNEAncillaryShareAmountAtProjection__c = LNPrimaryCoProRow.LNEAncillaryShareAmountAtProjection__c - sumSecondaryDealAncillaryProjection; 
                LNSecondaryCoProRow.LNECoPromoterWalkoutAtSellout__c =       LNSecondaryCoProRow.LNEProfitShareAmountAtSellout__c + LNSecondaryCoProRow.LNEExpenseAdjShareAmountAtSell__c + LNSecondaryCoProRow.LNEAncillaryShareAmountAtSellout__c + 0;
                LNSecondaryCoProRow.LNECoPromoterWalkoutAtProjection__c =    LNSecondaryCoProRow.LNEProfitShareAmountAtProjection__c + LNSecondaryCoProRow.LNEExpenseAdjShareAmountAtProj__c + LNSecondaryCoProRow.LNEAncillaryShareAmountAtProjection__c + 0;
                dealsToUpdate.add(LNSecondaryCoProRow);
            }
            
            if (sumPlanOwnedOperated != 0.0 || sumProjectionOwnedOperated != 0.0 || sumPlanExclusivelyBooked != 0.0 || sumProjectionExclusivelyBooked != 0.0){
                // check if LEs exist already
                boolean hasExpenseGL = false;
                boolean hasBookingGL = false;
                if (event.ledgers.containsKey(COPRO_EXPENSE_GL_CODE))
                    hasExpenseGL = true;
                if (event.ledgers.containsKey(COPRO_BOOKING_GL_CODE))
                    hasBookingGL = true;
    
                
                LedgerEntry__c CoProExpenseLE = new LedgerEntry__c();
                LedgerEntry__c CoProBookingLE = new LedgerEntry__c();
                if (hasExpenseGL == true){
                    CoProExpenseLE.id = event.ledgers.get(COPRO_EXPENSE_GL_CODE).id;
                } else {
                    CoProExpenseLE.Event__c = event.eventRecord.id;
                    CoProExpenseLE.GLAccount__c = glAccountMap.get(COPRO_EXPENSE_GL_CODE);
                    CoProExpenseLE.RecordTypeId = RT_LEDGER_ENTRY_OTHER_ID;
                }
                
                if (hasBookingGL == true){
                    CoProBookingLE.id = event.ledgers.get(COPRO_BOOKING_GL_CODE).id;
                } else {
                    CoProBookingLE.Event__c = event.eventRecord.id;
                    CoProBookingLE.GLAccount__c = glAccountMap.get(COPRO_BOOKING_GL_CODE);
                    CoProBookingLE.RecordTypeId = RT_LEDGER_ENTRY_OTHER_ID;
                }
                
                if (event.eventRecord.StatusStage__c == 'Plan'){
                    CoProExpenseLE.PlanAmount__c = sumPlanOwnedOperated;
                    CoProBookingLE.PlanAmount__c = sumPlanExclusivelyBooked;
                } else if (event.eventRecord.StatusStage__c == 'Projection'){
                    CoProExpenseLE.ProjectionAmount__c = sumProjectionOwnedOperated;
                    CoProBookingLE.ProjectionAmount__c = sumProjectionExclusivelyBooked;
                }
                
                ledgersToUpsert.add(CoProExpenseLE);
                ledgersToUpsert.add(CoProBookingLE);
                system.debug('*** CAS *** ' + ledgersToUpsert);
            }
            // US651 - create/update ledger entry for guarantee. 
            if(sumPrimaryGuarantee != 0.0){
                LedgerEntry__c guaranteeLedgerEntry = new LedgerEntry__c();
                LedgerEntry__c guaranteeLedgerEntryToReset = new LedgerEntry__c();
                if(event.eventRecord.Tour__c != null){
                    guaranteeLedgerEntry = getLedgerForEvent(event, SFX_EVENT_GUARANTEE_GL_CODE);
                    guaranteeLedgerEntryToReset = getLedgerForEvent(event, PRIMARY_GUARANTEE_EXPENSE_GL_CODE);
                }else{
                    guaranteeLedgerEntry = getLedgerForEvent(event, PRIMARY_GUARANTEE_EXPENSE_GL_CODE);
                    guaranteeLedgerEntryToReset = getLedgerForEvent(event, SFX_EVENT_GUARANTEE_GL_CODE);
                }

                if(guaranteeLedgerEntry.GLAccount__c != null){
                   if(event.eventRecord.StatusStage__c == 'Plan'){
                        guaranteeLedgerEntry.PlanAmount__c = sumPrimaryGuarantee;
                   }else if(event.eventRecord.StatusStage__c == 'Projection'){
                        guaranteeLedgerEntry.ProjectionAmount__c = sumPrimaryGuarantee;
                   }
                   guaranteeLedgerEntry.RecordTypeId = RT_TALENT_FEES_ID;   
                   ledgersToUpsert.add(guaranteeLedgerEntry);   
                }  
                if(guaranteeLedgerEntryToReset.GLAccount__c != null){
                   guaranteeLedgerEntryToReset.PlanAmount__c = 0;
                   guaranteeLedgerEntryToReset.ProjectionAmount__c = 0;
                   guaranteeLedgerEntryToReset.RecordTypeId = RT_TALENT_FEES_ID;   
                   ledgersToUpsert.add(guaranteeLedgerEntryToReset);   
                }               
            }
            // US651 - create/update ledger entry for ArtistSupplied SL.
            if(sumPrimaryArtistSuppliedSL != 0.0){
                LedgerEntry__c artistSuppliedSLLedgerEntry = new LedgerEntry__c();
                artistSuppliedSLLedgerEntry = getLedgerForEvent(event, SOUND_LIGHTS_GL_CODE);

                if(artistSuppliedSLLedgerEntry.GLAccount__c != null){
                   if(event.eventRecord.StatusStage__c == 'Plan'){
                        artistSuppliedSLLedgerEntry.PlanAmount__c = sumPrimaryArtistSuppliedSL;
                   }else if(event.eventRecord.StatusStage__c == 'Projection'){
                        artistSuppliedSLLedgerEntry.ProjectionAmount__c = sumPrimaryArtistSuppliedSL;
                   }   
                   artistSuppliedSLLedgerEntry.RecordTypeId = RT_TALENT_FEES_ID;  
                   ledgersToUpsert.add(artistSuppliedSLLedgerEntry);   
                }                
            }
            // US651 - create/update ledger entry for OTHER_TALENT_FEE_EXPENSE_GL_CODE.
            if(sumOtherTalentFeeExpenses != 0.0){
                LedgerEntry__c otherTalentFeeExpensesLedgerEntry = new LedgerEntry__c();
                otherTalentFeeExpensesLedgerEntry = getLedgerForEvent(event, OTHER_TALENT_FEE_EXPENSE_GL_CODE);

                if(otherTalentFeeExpensesLedgerEntry.GLAccount__c != null){
                   if(event.eventRecord.StatusStage__c == 'Plan'){
                        otherTalentFeeExpensesLedgerEntry.PlanAmount__c = sumOtherTalentFeeExpenses;
                   }else if(event.eventRecord.StatusStage__c == 'Projection'){
                        otherTalentFeeExpensesLedgerEntry.ProjectionAmount__c = sumOtherTalentFeeExpenses;
                   }  
                   otherTalentFeeExpensesLedgerEntry.RecordTypeId = RT_TALENT_FEES_ID;   
                   ledgersToUpsert.add(otherTalentFeeExpensesLedgerEntry);   
                }                
            }
            // US651 - create/update ledger entry for SECONDARY_GUARANTEE_GL_CODE.
            if(sumSecondaryGuarantee != 0.0){
                LedgerEntry__c secondayGuaranteeLedgerEntry = new LedgerEntry__c();
                secondayGuaranteeLedgerEntry = getLedgerForEvent(event, SECONDARY_GUARANTEE_GL_CODE);

                if(secondayGuaranteeLedgerEntry.GLAccount__c != null){
                   if(event.eventRecord.StatusStage__c == 'Plan'){
                        secondayGuaranteeLedgerEntry.PlanAmount__c = sumSecondaryGuarantee;
                   }else if(event.eventRecord.StatusStage__c == 'Projection'){
                        secondayGuaranteeLedgerEntry.ProjectionAmount__c = sumSecondaryGuarantee;
                   }  
                   secondayGuaranteeLedgerEntry.RecordTypeId = RT_TALENT_FEES_ID;   
                   ledgersToUpsert.add(secondayGuaranteeLedgerEntry);   
                }                
            }
            // US651 - create/update ledger entry for Sharing GL
            if(sumSharingProjectedOverage != 0.0){
                LedgerEntry__c sharingLedgerEntry = new LedgerEntry__c();
                LedgerEntry__c sharingLedgerEntryToReset = new LedgerEntry__c();
                if(event.eventRecord.Tour__c != null){
                    sharingLedgerEntry = getLedgerForEvent(event, SFX_EVENT_SHARING_GL_CODE);
                    sharingLedgerEntryToReset = getLedgerForEvent(event, SHARING_GL_CODE);
                }else{
                    sharingLedgerEntry = getLedgerForEvent(event, SHARING_GL_CODE);
                    sharingLedgerEntryToReset = getLedgerForEvent(event, SFX_EVENT_SHARING_GL_CODE);
                }

                if(sharingLedgerEntry.GLAccount__c != null){
                   if(event.eventRecord.StatusStage__c == 'Plan'){
                        sharingLedgerEntry.PlanAmount__c = sumSharingProjectedOverage;
                   }else if(event.eventRecord.StatusStage__c == 'Projection'){
                        sharingLedgerEntry.ProjectionAmount__c = sumSharingProjectedOverage;
                   }  
                   sharingLedgerEntry.RecordTypeId = RT_TALENT_FEES_ID;   
                   ledgersToUpsert.add(sharingLedgerEntry);   
                }  
                if(sharingLedgerEntryToReset.GLAccount__c != null){
                   sharingLedgerEntryToReset.PlanAmount__c = 0;
                   sharingLedgerEntryToReset.ProjectionAmount__c = 0;
                   sharingLedgerEntryToReset.RecordTypeId = RT_TALENT_FEES_ID;  
                   ledgersToUpsert.add(sharingLedgerEntryToReset);   
                }               
            }

            // US752 - create/update ledger entry for GOSPEL_BRUNCH_REVENUE_GL_CODE.
            if(gospelBrunchRevenueAmount != 0.0){
                LedgerEntry__c gospelBrunchRevenueLedgerEntry = new LedgerEntry__c();
                gospelBrunchRevenueLedgerEntry = getLedgerForEvent(event, GOSPEL_BRUNCH_REVENUE_GL_CODE);

                if(gospelBrunchRevenueLedgerEntry.GLAccount__c != null){
                   if(event.eventRecord.StatusStage__c == 'Plan'){
                        gospelBrunchRevenueLedgerEntry.PlanAmount__c = gospelBrunchRevenueAmount;
                   }else if(event.eventRecord.StatusStage__c == 'Projection'){
                        gospelBrunchRevenueLedgerEntry.ProjectionAmount__c = gospelBrunchRevenueAmount;
                   }  
                   gospelBrunchRevenueLedgerEntry.RecordTypeId = RT_ANCILLARY_ID;   
                   ledgersToUpsert.add(gospelBrunchRevenueLedgerEntry);   
                }                
            }
            // US752 - create/update ledger entry for GOSPEL_BRUNCH_FOOD_REVENUE_GL_CODE.
            if(gospelBrunchFoodRevenueAmount != 0.0){
                LedgerEntry__c gospelBrunchFoodRevenueLedgerEntry = new LedgerEntry__c();
                gospelBrunchFoodRevenueLedgerEntry = getLedgerForEvent(event, GOSPEL_BRUNCH_FOOD_REVENUE_GL_CODE);

                if(gospelBrunchFoodRevenueLedgerEntry.GLAccount__c != null){
                   if(event.eventRecord.StatusStage__c == 'Plan'){
                        gospelBrunchFoodRevenueLedgerEntry.PlanAmount__c = gospelBrunchFoodRevenueAmount;
                   }else if(event.eventRecord.StatusStage__c == 'Projection'){
                        gospelBrunchFoodRevenueLedgerEntry.ProjectionAmount__c = gospelBrunchFoodRevenueAmount;
                   }  
                   gospelBrunchFoodRevenueLedgerEntry.RecordTypeId = RT_ANCILLARY_ID;   
                   ledgersToUpsert.add(gospelBrunchFoodRevenueLedgerEntry);   
                }                
            }
            // US752 - create/update ledger entry for GOSPEL_BRUNCH_COSTS_GL_CODE.
            if(gospelBrunchCostsAmount != 0.0){
                LedgerEntry__c gospelBrunchCostsLedgerEntry = new LedgerEntry__c();
                gospelBrunchCostsLedgerEntry = getLedgerForEvent(event, GOSPEL_BRUNCH_COSTS_GL_CODE);

                if(gospelBrunchCostsLedgerEntry.GLAccount__c != null){
                   if(event.eventRecord.StatusStage__c == 'Plan'){
                        gospelBrunchCostsLedgerEntry.PlanAmount__c = gospelBrunchCostsAmount;
                   }else if(event.eventRecord.StatusStage__c == 'Projection'){
                        gospelBrunchCostsLedgerEntry.ProjectionAmount__c = gospelBrunchCostsAmount;
                   }  
                   gospelBrunchCostsLedgerEntry.RecordTypeId = RT_EXPENSES_ID;   
                   ledgersToUpsert.add(gospelBrunchCostsLedgerEntry);   
                }                
            }
            // US752 - create/update ledger entry for GOSPEL_BRUNCH_BAND_GL_CODE.
            if(gospelBrunchBandAmount != 0.0){
                LedgerEntry__c gospelBrunchBandLedgerEntry = new LedgerEntry__c();
                gospelBrunchBandLedgerEntry = getLedgerForEvent(event, GOSPEL_BRUNCH_BAND_GL_CODE);

                if(gospelBrunchBandLedgerEntry.GLAccount__c != null){
                   if(event.eventRecord.StatusStage__c == 'Plan'){
                        gospelBrunchBandLedgerEntry.PlanAmount__c = gospelBrunchBandAmount;
                   }else if(event.eventRecord.StatusStage__c == 'Projection'){
                        gospelBrunchBandLedgerEntry.ProjectionAmount__c = gospelBrunchBandAmount;
                   }  
                   gospelBrunchBandLedgerEntry.RecordTypeId = RT_EXPENSES_ID;   
                   ledgersToUpsert.add(gospelBrunchBandLedgerEntry);   
                }                
            }

            //  US 691 - Create/Update ledger entries for Ad Plan - '50402','50404','50408','50410','50412','50419','50441','50446'
            if(runAdPLanLECalculation == true && event.eventRecord.AdPlans__r != null){
                Decimal radioSpendPropotional = 0.0;
                Decimal digitalSpendPropotional = 0.0;
                Decimal televisionSpendPropotional = 0.0;
                Decimal printSpendPropotional = 0.0;
                Decimal outdoorSpendPropotional = 0.0;
                Decimal miscSpendPropotional = 0.0;
                Decimal tourDigitalSpendPropotional = 0.0;
                Decimal tourOtherSpendPropotional = 0.0;
                String notes = '';

                for(AdPlan__c adPlan : event.eventRecord.AdPlans__r){
                    if(adPlan.LNEAdPlanBudget__c != null && adPlan.TotalLNESpend__c != null && adPLan.TotalLNESpend__c != 0){
                        radioSpendPropotional       += (adPlan.RadioSpend__c == null ? 0 : (adPlan.RadioSpend__c * adPlan.LNEAdPlanBudget__c / adPlan.TotalLNESpend__c));
                        digitalSpendPropotional     += (adPlan.DigitalSpend__c == null ? 0 : (adPlan.DigitalSpend__c * adPlan.LNEAdPlanBudget__c / adPlan.TotalLNESpend__c));
                        televisionSpendPropotional  += (adPlan.TelevisionSpend__c == null ? 0 : (adPlan.TelevisionSpend__c * adPlan.LNEAdPlanBudget__c / adPlan.TotalLNESpend__c));
                        printSpendPropotional       += (adPlan.PrintSpend__c == null ? 0 : (adPlan.PrintSpend__c * adPlan.LNEAdPlanBudget__c / adPlan.TotalLNESpend__c));
                        outdoorSpendPropotional     += (adPlan.OutdoorSpend__c == null ? 0 : (adPlan.OutdoorSpend__c * adPlan.LNEAdPlanBudget__c / adPlan.TotalLNESpend__c));
                        miscSpendPropotional        += (adPlan.ProductionMiscellaneousSpend__c == null ? 0 : (adPlan.ProductionMiscellaneousSpend__c * adPlan.LNEAdPlanBudget__c  / adPlan.TotalLNESpend__c));
                        tourDigitalSpendPropotional += (adPlan.TourDigitalSpend__c == null ? 0 : (adPlan.TourDigitalSpend__c * adPlan.LNEAdPlanBudget__c / adPlan.TotalLNESpend__c));
                        tourOtherSpendPropotional   += (adPlan.TourOtherSpend__c == null ? 0 : (adPlan.TourOtherSpend__c * adPlan.LNEAdPlanBudget__c / adPlan.TotalLNESpend__c));
                        notes = 'Updated from Ad Plan on ' + String.ValueOf(adPlan.LastModifiedDate.Date());
                    }
                }

                LedgerEntry__c radioAdvertisingExpenseLedgerEntry = getLedgerForEvent(event, RADIO_ADVERTISING_EXPENSE_GL_CODE);
                LedgerEntry__c websiteAdvertisingExpenseLedgerEntry = getLedgerForEvent(event, WEBSITE_ADVERTISING_GL_CODE);
                LedgerEntry__c tvAdvertisingExpenseLedgerEntry = getLedgerForEvent(event, TV_ADVERTISING_EXPENSE_GL_CODE);
                LedgerEntry__c printAdvertisingExpenseLedgerEntry = getLedgerForEvent(event, PRINT_ADVERTISING_EXPENSE_GL_CODE);
                LedgerEntry__c billboardAdvertisingExpenseLedgerEntry = getLedgerForEvent(event, BILLBOARD_ADVERTISING_EXPENSE_GL_CODE);
                LedgerEntry__c productionAdvertisingExpenseLedgerEntry = getLedgerForEvent(event, ADVERTISING_PRODUCTION_EXPENSE_GL_CODE);
                LedgerEntry__c nationalPushdownDigitalLedgerEntry = getLedgerForEvent(event, NATIONAL_PUSHDOWN_DIGITAL_GL_CODE);
                LedgerEntry__c nationalPushdownMiscLedgerEntry = getLedgerForEvent(event, NATIONAL_PUSHDOWN_MISC_GL_CODE);

                if(radioAdvertisingExpenseLedgerEntry.GLAccount__c != null){
                   radioAdvertisingExpenseLedgerEntry = adPLanCalculation(event, radioAdvertisingExpenseLedgerEntry, radioSpendPropotional, notes);
                   ledgersToUpsert.add(radioAdvertisingExpenseLedgerEntry);   
                }  
                if(websiteAdvertisingExpenseLedgerEntry.GLAccount__c != null){
                   websiteAdvertisingExpenseLedgerEntry = adPLanCalculation(event, websiteAdvertisingExpenseLedgerEntry, digitalSpendPropotional, notes);
                   ledgersToUpsert.add(websiteAdvertisingExpenseLedgerEntry);   
                }
                if(tvAdvertisingExpenseLedgerEntry.GLAccount__c != null){
                   tvAdvertisingExpenseLedgerEntry = adPLanCalculation(event, tvAdvertisingExpenseLedgerEntry, televisionSpendPropotional, notes);
                   ledgersToUpsert.add(tvAdvertisingExpenseLedgerEntry);   
                }
                if(printAdvertisingExpenseLedgerEntry.GLAccount__c != null){
                   printAdvertisingExpenseLedgerEntry = adPLanCalculation(event, printAdvertisingExpenseLedgerEntry, printSpendPropotional, notes);
                   ledgersToUpsert.add(printAdvertisingExpenseLedgerEntry);   
                }
                if(billboardAdvertisingExpenseLedgerEntry.GLAccount__c != null){
                   billboardAdvertisingExpenseLedgerEntry = adPLanCalculation(event, billboardAdvertisingExpenseLedgerEntry, outdoorSpendPropotional, notes);
                   ledgersToUpsert.add(billboardAdvertisingExpenseLedgerEntry);   
                }
                if(productionAdvertisingExpenseLedgerEntry.GLAccount__c != null){
                   productionAdvertisingExpenseLedgerEntry = adPLanCalculation(event, productionAdvertisingExpenseLedgerEntry, miscSpendPropotional, notes);
                   ledgersToUpsert.add(productionAdvertisingExpenseLedgerEntry);   
                }
                if(nationalPushdownDigitalLedgerEntry.GLAccount__c != null){
                   nationalPushdownDigitalLedgerEntry = adPLanCalculation(event, nationalPushdownDigitalLedgerEntry, tourDigitalSpendPropotional, notes);
                   ledgersToUpsert.add(nationalPushdownDigitalLedgerEntry);   
                }
                if(nationalPushdownMiscLedgerEntry.GLAccount__c != null){
                   nationalPushdownMiscLedgerEntry = adPLanCalculation(event, nationalPushdownMiscLedgerEntry, tourOtherSpendPropotional, notes);
                   ledgersToUpsert.add(nationalPushdownMiscLedgerEntry);   
                }
            }
        } // end for loop on events
        
        if (dealsToUpdate.size() > 0){
            upsert dealsToUpdate;
            update events;
        }
        
        if (ledgersToUpsert.size() > 0){
            upsert ledgersToUpsert;
        }
        
        LNE_GeneralSettingsUtil.removeCurrentUserOverride();
    }
    
    private static LedgerEntry__c adPLanCalculation (LNE_Event event, LedgerEntry__c le, Decimal proportionalSpend, String notes){
        if(event != null && le != null){
            // set the default values that don't change if blank
            if(le.OfferRateType__c == null) le.OfferRateType__c = 'Flat';
            if(le.InHouseRateType__c == null) le.InHouseRateType__c = 'Flat';
            if(le.RecordTypeId != RT_EXPENSES_ID) le.RecordTypeId = RT_EXPENSES_ID;
            if(le.GLCode__c != null) le.Category__c = glAccountsMap.get(le.GLCode__c).Category__c;

            // always set the calculated fields
            le.Notes__c = notes;
            le.OfferRate__c = proportionalSpend;
            le.InHouseRate__c = proportionalSpend;
            le.OfferAtSellout__c = proportionalSpend;
            le.OfferAtProjection__c = proportionalSpend;
            le.InHouseatSellout__c = proportionalSpend;
            le.InHouseProjection__c = proportionalSpend;

            // Set the AdPlanManaged to true (if false) to disable deletion -  handled by trigger code on Ledger Entry.
            if(le.AdPlanManaged__c == null || le.AdPlanManaged__c == FALSE) le.AdPlanManaged__c = TRUE;
        }
        return le;
    }

    private static LedgerEntry__c ancillaryCalculation (LNE_Event event, LedgerEntry__c le){

        if (le.RollupCount__c > 0) return le;

         Decimal ticketRule = 0;

         List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
         if(le.TicketScaleList__c != null){
            String[]listOfTicketScaleIds = le.TicketScaleList__c.split('\\' + DELIMITER);
            for(TicketScale__c tscale :event.eventRecord.TicketScales__r){
                for(String tsId : listOfTicketScaleIds){
                    if(tsId != null && tsId.length() >= 15 && tsId == tscale.Id){
                        listOfTicketScales.add(tscale);
                    }
                }
            }
        }

        //If the Rate Type of the Ledger Entry is FLat, then the Gross Revenue at Sellout is equals to Base Amount.
        if(le.RateType__c != null){
            Double BaseAmount = le.BaseAmount__c == null ? 0.0 : le.BaseAmount__c;
            Double SelloutPaidTickets = event.eventRecord.SelloutPaidTickets__c == null ? 0.0 : event.eventRecord.SelloutPaidTickets__c;
            Double SelloutDropCount = event.eventRecord.SelloutDropCount__c == null ? 0.0 : event.eventRecord.SelloutDropCount__c;

            if(le.RateType__c == RATE_TYPE_FLAT){
                le.GrossRevenueatSellout__c = BaseAmount;
            }
            //If the Rate Type of the Ledger Entry is Per Cap, then the Gross Revenue at Sellout is calculated applying the ticket scale rule.
            else{
                if(le.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                    le.GrossRevenueatSellout__c = BaseAmount * SelloutPaidTickets;
                }else if(le.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
                    le.GrossRevenueatSellout__c = BaseAmount * SelloutDropCount;
                }else if(le.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                    ticketRule = 0;
                    if(le.TicketScaleList__c != null){
                        //String[] listOfTicketScaleIds = le.TicketScaleList__c.split('\\' + DELIMITER);
                        //List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
                        //for(TicketScale__c tscale :event.eventRecord.TicketScales__r){
                        //    for(String tsId : listOfTicketScaleIds){
                        //        if(tsId != null && tsId.length() >= 15 && tsId == tscale.Id){
                        //            listOfTicketScales.add(tscale);
                        //        }
                        //    }
                        //}
                        for(TicketScale__c ticketScale : listOfTicketScales){
                            if( ticketScale.SellableCapacity__c != null ){
                                ticketRule += ticketScale.SellableCapacity__c;
                            }
                        }
                    }
                    le.GrossRevenueatSellout__c = BaseAmount * ticketRule;
                }else{
                    le.GrossRevenueatSellout__c = BaseAmount;
                }
            }
        }
        
        // If the resulting Gross Revenue at Sellout is below the min or above the max, it takes the value of those fields.
        if((le.Min__c != null && le.Min__c > 0) && le.GrossRevenueatSellout__c != null && le.GrossRevenueatSellout__c <  le.Min__c){
            le.GrossRevenueatSellout__c = le.Min__c;
        }
        if((le.Max__c != null && le.Max__c > 0) && le.GrossRevenueatSellout__c != null && le.GrossRevenueatSellout__c >  le.Max__c){
            le.GrossRevenueatSellout__c = le.Max__c;
        }
        
        ticketRule = 0;
        Double ContraAmount = le.ContraAmount__c == null ? 0.0 : le.ContraAmount__c;
        Double GrossRevenueatSellout = le.GrossRevenueatSellout__c == null ? 0.0 : le.GrossRevenueatSellout__c;
        Double ContraPercent = le.ContraPercent__c == null ? 0.0 : le.ContraPercent__c/100;
        Double X3rdPartyPercent = le.X3rdPartyPercent__c == null ? 0.0 : le.X3rdPartyPercent__c/100;
        Double SelloutPaidTickets = event.eventRecord.SelloutPaidTickets__c == null ? 0.0 : event.eventRecord.SelloutPaidTickets__c;
        Double SelloutDropCount = event.eventRecord.SelloutDropCount__c == null ? 0.0 : event.eventRecord.SelloutDropCount__c;

        //If the Rate Type of the Ledger Entry is Flat, then the Contra at Sellout is equals to Contra Amount.
        if(!String.isBlank(le.ContraType__c)){

            if(le.ContraType__c == RATE_TYPE_FLAT){
                le.ContraatSellout__c = ContraAmount + ((GrossRevenueatSellout - ContraAmount) * (ContraPercent + X3rdPartyPercent));
            }
            //If the Rate Type of the Ledger Entry is Per Cap, then the Contra at Sellout is calculated applying the ticket scale rule.
            else{
                if(le.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                    le.ContraatSellout__c = (ContraAmount * SelloutPaidTickets) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenueatSellout - (ContraAmount * SelloutPaidTickets)));
                }else if(le.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
                    le.ContraatSellout__c = (ContraAmount * SelloutDropCount) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenueatSellout - (ContraAmount * SelloutDropCount)));
                }else if(le.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                    ticketRule = 0;
                    if(le.TicketScaleList__c != null){
                        //String[] listOfTicketScaleIds = le.TicketScaleList__c.split('\\' + DELIMITER);
                        //List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
                        //for(TicketScale__c tscale :event.eventRecord.TicketScales__r){
                        //    for(String tsId : listOfTicketScaleIds){
                        //        if(tsId != null && tsId.length() >= 15 && tsId == tscale.Id){
                        //            listOfTicketScales.add(tscale);
                        //        }
                        //    }
                        //}
                        for(TicketScale__c ticketScale : listOfTicketScales){
                            if( ticketScale.SellableCapacity__c != null ){
                                ticketRule += ticketScale.SellableCapacity__c;
                            }
                        }
                    }
                    le.ContraatSellout__c = (ContraAmount * ticketRule) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenueatSellout - (ContraAmount * ticketRule)));
                }else{
                    le.ContraatSellout__c = ContraAmount;
                }
            
            }
        } else {
            le.ContraatSellout__c = GrossRevenueatSellout * (ContraPercent + X3rdPartyPercent);
        }

        Double ContraatSellout = le.ContraatSellout__c == null ? 0.0 : le.ContraatSellout__c;

        le.NetRevenueatSellout__c = GrossRevenueatSellout - ContraatSellout;

        le = calculateGrossRevenue(le, listOfTicketScales, event.eventRecord);
        le = calculateGrossPerPaid(le, event.eventRecord);
        le = calculateContraAtForecast(le, listOfTicketScales, event.eventRecord);
        le = calculateContraPercentAtForecast(le);
        le = calculateNetRevenue(le);
        le = calculateNetPerPaid(le, event.eventRecord);
        
        return le;
    }

    /**
*  Method to calculate the Gross Revenue field on LedgerEntry__c Object.
*  @param LedgerEntry__c, List<TicketScale__c>, Event__c
*  @return LedgerEntry__c
**/
    public static LedgerEntry__c calculateGrossRevenue(LedgerEntry__c ledgerEntry, List<TicketScale__c> listOfTicketScales, Event__c relatedEvent){
        
        Decimal ticketRule = 0;
        Double BaseAmount = ledgerEntry.BaseAmount__c == null ? 0.0 : ledgerEntry.BaseAmount__c;
        Double ProjectedPaidTickets = relatedEvent.ProjectedPaidTickets__c == null ? 0.0 : relatedEvent.ProjectedPaidTickets__c;
        Double ProjectedDropCount = relatedEvent.ProjectedDropCount__c == null ? 0.0 : relatedEvent.ProjectedDropCount__c;

        //If the Rate Type of the Ledger Entry is FLat, then the Gross Revenue is equals to Base Amount.
        if(ledgerEntry.RateType__c == RATE_TYPE_FLAT){
            ledgerEntry.GrossRevenue__c = BaseAmount;
        }
        //If the Rate Type of the Ledger Entry is Per Cap, then the Gross Revenue is calculated applying the ticket scale rule.
        else{
            if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                ledgerEntry.GrossRevenue__c = BaseAmount * ProjectedPaidTickets;
            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT ){
                ledgerEntry.GrossRevenue__c = BaseAmount * ProjectedDropCount;
            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                ticketRule = 0;
                for(TicketScale__c ticketScale : listOfTicketScales){
                    if( ticketScale.ProjectedPaidTickets__c != null ){
                        ticketRule += ticketScale.ProjectedPaidTickets__c;
                    }
                }
                ledgerEntry.GrossRevenue__c = BaseAmount * ticketRule;
            }else{
                ledgerEntry.GrossRevenue__c = BaseAmount;
            }
            
        }
        
        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        if((ledgerEntry.Min__c != null && ledgerEntry.Min__c > 0) && ledgerEntry.GrossRevenue__c <  ledgerEntry.Min__c){
            ledgerEntry.GrossRevenue__c = ledgerEntry.Min__c;
        }
        if((ledgerEntry.Max__c != null && ledgerEntry.Max__c > 0) && ledgerEntry.GrossRevenue__c >  ledgerEntry.Max__c){
            ledgerEntry.GrossRevenue__c = ledgerEntry.Max__c;
        }
        
        return ledgerEntry;
    }
    
/**
*  Method to calculate the Gross Per Paid field on LedgerEntry__c Object.
*  @param LedgerEntry__c, Event__c
*  @return LedgerEntry__c
**/
    public static LedgerEntry__c calculateGrossPerPaid(LedgerEntry__c ledgerEntry, Event__c relatedEvent){
        Double GrossRevenue = ledgerEntry.GrossRevenue__c == null ? 0.0 : ledgerEntry.GrossRevenue__c;
        
        //If Projected Paid Tickets = 0, then Gross Per Paid = Gross Revenue / Projected Drop Count otherwise use Projected Paid Tickets
        if(relatedEvent.ProjectedPaidTickets__c == 0 && relatedEvent.ProjectedDropCount__c != 0){
            ledgerEntry.GrossPerPaid__c = GrossRevenue / relatedEvent.ProjectedDropCount__c;
        }else if( relatedEvent.ProjectedPaidTickets__c != 0 ){
            ledgerEntry.GrossPerPaid__c = GrossRevenue / relatedEvent.ProjectedPaidTickets__c;
        }
        
        return ledgerEntry;
    }
    
/**
*  Method to calculate the Contra at Forecast field on LedgerEntry__c Object.
*  @param LedgerEntry__c, List<TicketScale__c>, Event__c
*  @return LedgerEntry__c
**/
    public static LedgerEntry__c calculateContraAtForecast(LedgerEntry__c ledgerEntry, List<TicketScale__c> listOfTicketScales,  Event__c relatedEvent){

        Decimal ticketRule = 0;
        Double ContraAmount = ledgerEntry.ContraAmount__c == null ? 0.0 : ledgerEntry.ContraAmount__c;
        Double GrossRevenue = ledgerEntry.GrossRevenue__c == null ? 0.0 : ledgerEntry.GrossRevenue__c;
        Double ContraPercent = ledgerEntry.ContraPercent__c == null ? 0.0 : ledgerEntry.ContraPercent__c/100;
        Double X3rdPartyPercent = ledgerEntry.X3rdPartyPercent__c == null ? 0.0 : ledgerEntry.X3rdPartyPercent__c/100;
        Double ProjectedPaidTickets = relatedEvent.ProjectedPaidTickets__c == null ? 0.0 : relatedEvent.ProjectedPaidTickets__c;
        Double ProjectedDropCount = relatedEvent.ProjectedDropCount__c == null ? 0.0 : relatedEvent.ProjectedDropCount__c;
        
        if (String.isBlank(ledgerEntry.ContraType__c)) {
            ledgerEntry.ContraAtForecast__c = GrossRevenue * (ContraPercent + X3rdPartyPercent);
        }
        //If the Rate Type of the Ledger Entry is Flat, then the Contra At Forecast = Contra Amount + ((Gross Revenue - Contra Amount) * (Contra % + 3rd Party %))
        else if(ledgerEntry.ContraType__c == RATE_TYPE_FLAT){
            ledgerEntry.ContraAtForecast__c = ContraAmount + ((GrossRevenue - ContraAmount) * (ContraPercent + X3rdPartyPercent));
        }
        //If the Rate Type of the Ledger Entry is Per Cap, then the Contra at Forecast is calculated applying the ticket scale rule.
        else{
            if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                ledgerEntry.ContraAtForecast__c = (ContraAmount * ProjectedPaidTickets) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ProjectedPaidTickets)));
            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
                ledgerEntry.ContraAtForecast__c = (ContraAmount * ProjectedDropCount) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ProjectedDropCount)));
            }else if(ledgerEntry.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                ticketRule = 0;
                for(TicketScale__c ticketScale : listOfTicketScales){
                   if( ticketScale.ProjectedPaidTickets__c != null ){
                        ticketRule += ticketScale.ProjectedPaidTickets__c;
                   }
                }
                ledgerEntry.ContraAtForecast__c = (ContraAmount * ticketRule) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ticketRule)));
            }else{
                ledgerEntry.ContraAtForecast__c = ContraAmount;
            }
            
        }
        return ledgerEntry;
        
    }
/**
*  Method to calculate the Contra % at Forecast field on LedgerEntry__c Object.
*  @param LedgerEntry__c
*  @return LedgerEntry__c
**/
    public static LedgerEntry__c calculateContraPercentAtForecast(LedgerEntry__c ledgerEntry){
        
        if( ledgerEntry != null &&            
              ledgerEntry.GrossRevenue__c != null &&
              ledgerEntry.GrossRevenue__c != 0 ) {

            Double ContraAtForecast = ledgerEntry.ContraAtForecast__c == null ? 0.0 : ledgerEntry.ContraAtForecast__c;
                    
            ledgerEntry.ContraPercentAtForecast__c = ContraAtForecast / ledgerEntry.GrossRevenue__c;
        }
        
        return ledgerEntry;
    }
    
/**
*  Method to calculate the Net Revenue field on LedgerEntry__c Object.
*  @param LedgerEntry__c
*  @return LedgerEntry__c
**/
    public static LedgerEntry__c calculateNetRevenue(LedgerEntry__c ledgerEntry){
        
        if(ledgerEntry != null) {
            Double ContraAtForecast = ledgerEntry.ContraAtForecast__c == null ? 0.0 : ledgerEntry.ContraAtForecast__c;
            Double GrossRevenue = ledgerEntry.GrossRevenue__c == null ? 0.0 : ledgerEntry.GrossRevenue__c;
        
            ledgerEntry.NetRevenue__c = GrossRevenue - ContraAtForecast;
        }
        
        return ledgerEntry;
    }
    
/**
*  Method to calculate the Net Per Paid field on LedgerEntry__c Object.
*  @param LedgerEntry__c, Event__c
*  @return LedgerEntry__c
**/
    public static LedgerEntry__c calculateNetPerPaid(LedgerEntry__c ledgerEntry, Event__c relatedEvent){
        
        if (ledgerEntry != null &&
              relatedEvent != null &&
              relatedEvent.ProjectedPaidTickets__c != null) {

            Double NetRevenue = ledgerEntry.NetRevenue__c == null ? 0.0 : ledgerEntry.NetRevenue__c;
                
            if(relatedEvent.ProjectedPaidTickets__c == 0 &&
                 relatedEvent.ProjectedDropCount__c != null &&
                 relatedEvent.ProjectedDropCount__c != 0 ) {
                    
                ledgerEntry.NetPerPaid__c = NetRevenue / relatedEvent.ProjectedDropCount__c;
            } else if( relatedEvent.ProjectedPaidTickets__c != 0 ) {
                
                ledgerEntry.NetPerPaid__c = NetRevenue / relatedEvent.ProjectedPaidTickets__c;
            }
        }
        
        return ledgerEntry;
    }
    
    private static LedgerEntryBreakout__c ancillaryBreakoutCalculation(LNE_Event event, LedgerEntryBreakout__c lebr){
        
        Decimal ticketRule = 0;

        List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
        if(lebr.TicketScaleList__c != null){
            String[] listOfTicketScaleIds = lebr.TicketScaleList__c.split('\\' + DELIMITER);
            for(TicketScale__c tscale :event.eventRecord.TicketScales__r){
                for(String tsId : listOfTicketScaleIds){
                    if(tsId != null && tsId.length() >= 15 && tsId == tscale.Id){
                        listOfTicketScales.add(tscale);
                    }
                }
            }
        }

        //If the Rate Type of the Ledger Entry is FLat, then the Gross Revenue at Sellout is equals to Base Amount.
        if(lebr.RateType__c != null){
            Double BaseAmount = lebr.BaseAmount__c == null ? 0.0 : lebr.BaseAmount__c;
            Double SelloutPaidTickets = event.eventRecord.SelloutPaidTickets__c == null ? 0.0 : event.eventRecord.SelloutPaidTickets__c;
            Double SelloutDropCount = event.eventRecord.SelloutDropCount__c == null ? 0.0 : event.eventRecord.SelloutDropCount__c;

            if(lebr.RateType__c == RATE_TYPE_FLAT){
                lebr.GrossRevenueatSellout__c = BaseAmount;
            }
            //If the Rate Type of the Ledger Entry is Per Cap, then the Gross Revenue at Sellout is calculated applying the ticket scale rule.
            else{
                if(lebr.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                    lebr.GrossRevenueatSellout__c = BaseAmount * SelloutPaidTickets;
                }else if(lebr.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
                    lebr.GrossRevenueatSellout__c = BaseAmount * SelloutDropCount;
                }else if(lebr.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                    ticketRule = 0;
                    if(lebr.TicketScaleList__c != null){
                        //String[] listOfTicketScaleIds = lebr.TicketScaleList__c.split('\\' + DELIMITER);
                        //List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
                        //for(TicketScale__c tscale :event.eventRecord.TicketScales__r){
                        //    for(String tsId : listOfTicketScaleIds){
                        //        if(tsId != null && tsId.length() >= 15 && tsId == tscale.Id){
                        //            listOfTicketScales.add(tscale);
                        //        }
                        //    }
                        //}
                        for(TicketScale__c ticketScale : listOfTicketScales){
                            if( ticketScale.SellableCapacity__c != null ){
                                ticketRule += ticketScale.SellableCapacity__c;
                            }
                        }
                    }
                    lebr.GrossRevenueatSellout__c = BaseAmount * ticketRule;
                }else{
                    lebr.GrossRevenueatSellout__c = BaseAmount;
                }
            }
        }
        
        // If the resulting Gross Revenue at Sellout is below the min or above the max, it takes the value of those fields.
        if((lebr.Min__c != null && lebr.Min__c > 0) && lebr.GrossRevenueatSellout__c != null && lebr.GrossRevenueatSellout__c < lebr.Min__c){
            lebr.GrossRevenueatSellout__c = lebr.Min__c;
        }
        if((lebr.Max__c != null && lebr.Max__c > 0) && lebr.GrossRevenueatSellout__c != null && lebr.GrossRevenueatSellout__c > lebr.Max__c){
            lebr.GrossRevenueatSellout__c = lebr.Max__c;
        }
        
        ticketRule = 0;
        Double ContraAmount = lebr.ContraAmount__c == null ? 0.0 : lebr.ContraAmount__c;
        Double GrossRevenueatSellout = lebr.GrossRevenueatSellout__c == null ? 0.0 : lebr.GrossRevenueatSellout__c;
        Double ContraPercent = lebr.ContraPercent__c == null ? 0.0 : lebr.ContraPercent__c/100;
        Double X3rdPartyPercent = lebr.X3rdPartyPercent__c == null ? 0.0 : lebr.X3rdPartyPercent__c/100;
        Double SelloutPaidTickets = event.eventRecord.SelloutPaidTickets__c == null ? 0.0 : event.eventRecord.SelloutPaidTickets__c;
        Double SelloutDropCount = event.eventRecord.SelloutDropCount__c == null ? 0.0 : event.eventRecord.SelloutDropCount__c;

        //If the Rate Type of the Ledger Entry is Flat, then the Contra at Sellout is equals to Contra Amount.
        if(!String.isBlank(lebr.ContraType__c)){

            if(lebr.ContraType__c == RATE_TYPE_FLAT){
                lebr.ContraatSellout__c = ContraAmount + ((GrossRevenueatSellout - ContraAmount) * (ContraPercent + X3rdPartyPercent));
            }
            //If the Rate Type of the Ledger Entry is Per Cap, then the Contra at Sellout is calculated applying the ticket scale rule.
            else{
                if(lebr.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                    lebr.ContraatSellout__c = (ContraAmount * SelloutPaidTickets) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenueatSellout - (ContraAmount * SelloutPaidTickets)));
                }else if(lebr.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
                    lebr.ContraatSellout__c = (ContraAmount * SelloutDropCount) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenueatSellout - (ContraAmount * SelloutDropCount)));
                }else if(lebr.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                    ticketRule = 0;
                    if(lebr.TicketScaleList__c != null){
                        //String[] listOfTicketScaleIds = lebr.TicketScaleList__c.split('\\' + DELIMITER);
                        //List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
                        //for(TicketScale__c tscale :event.eventRecord.TicketScales__r){
                        //    for(String tsId : listOfTicketScaleIds){
                        //        if(tsId != null && tsId.length() >= 15 && tsId == tscale.Id){
                        //            listOfTicketScales.add(tscale);
                        //        }
                        //    }
                        //}
                        for(TicketScale__c ticketScale : listOfTicketScales){
                            if( ticketScale.SellableCapacity__c != null ){
                                ticketRule += ticketScale.SellableCapacity__c;
                            }
                        }
                    }
                    lebr.ContraatSellout__c = (ContraAmount * ticketRule) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenueatSellout - (ContraAmount * ticketRule)));
            
                }else{
                    lebr.ContraatSellout__c = ContraAmount;
                }
            }
        } else {
            lebr.ContraatSellout__c = GrossRevenueatSellout * (ContraPercent + X3rdPartyPercent);
        }

        Double ContraatSellout = lebr.ContraatSellout__c == null ? 0.0 : lebr.ContraatSellout__c;

        lebr.NetRevenueatSellout__c = GrossRevenueatSellout - ContraatSellout;

        lebr = calculateGrossRevenue(lebr, listOfTicketScales, event.eventRecord);
        lebr = calculateGrossPerPaid(lebr, event.eventRecord);
        lebr = calculateContraAtForecast(lebr, listOfTicketScales, event.eventRecord);
        lebr = calculateContraPercentAtForecast(lebr);
        lebr = calculateNetRevenue(lebr);
        lebr = calculateNetPerPaid(lebr, event.eventRecord);
       
        return lebr;
    }

    /**
*  Method to calculate the Gross Revenue field on ledgerEntryBreakout__c Object.
*  @param ledgerEntryBreakout__c, List<TicketScale__c>, Event__c
*  @return ledgerEntryBreakout__c
**/
    public static LedgerEntryBreakout__c calculateGrossRevenue(LedgerEntryBreakout__c ledgerEntryBreakout, List<TicketScale__c> listOfTicketScales, Event__c relatedEvent){
        
        Decimal ticketRule = 0;
        Double BaseAmount = ledgerEntryBreakout.BaseAmount__c == null ? 0.0 : ledgerEntryBreakout.BaseAmount__c;
        Double ProjectedPaidTickets = relatedEvent.ProjectedPaidTickets__c == null ? 0.0 : relatedEvent.ProjectedPaidTickets__c;
        Double ProjectedDropCount = relatedEvent.ProjectedDropCount__c == null ? 0.0 : relatedEvent.ProjectedDropCount__c;

        //If the Rate Type of the Ledger Entry is FLat, then the Gross Revenue is equals to Base Amount.
        if(ledgerEntryBreakout.RateType__c == RATE_TYPE_FLAT){
            ledgerEntryBreakout.GrossRevenue__c = BaseAmount;
        }
        //If the Rate Type of the Ledger Entry is Per Cap, then the Gross Revenue is calculated applying the ticket scale rule.
        else{
            if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                ledgerEntryBreakout.GrossRevenue__c = BaseAmount * ProjectedPaidTickets;
            }else if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT ){
                ledgerEntryBreakout.GrossRevenue__c = BaseAmount * ProjectedDropCount;
            }else if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                ticketRule = 0;
                for(TicketScale__c ticketScale : listOfTicketScales){
                    if( ticketScale.ProjectedPaidTickets__c != null ){
                        ticketRule += ticketScale.ProjectedPaidTickets__c;
                    }
                }
                ledgerEntryBreakout.GrossRevenue__c = BaseAmount * ticketRule;
            }else{
                ledgerEntryBreakout.GrossRevenue__c = BaseAmount;
            }
            
        }
        
        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        if((ledgerEntryBreakout.Min__c != null && ledgerEntryBreakout.Min__c > 0) && ledgerEntryBreakout.GrossRevenue__c <  ledgerEntryBreakout.Min__c){
            ledgerEntryBreakout.GrossRevenue__c = ledgerEntryBreakout.Min__c;
        }
        if((ledgerEntryBreakout.Max__c != null && ledgerEntryBreakout.Max__c > 0) && ledgerEntryBreakout.GrossRevenue__c >  ledgerEntryBreakout.Max__c){
            ledgerEntryBreakout.GrossRevenue__c = ledgerEntryBreakout.Max__c;
        }
        
        return ledgerEntryBreakout;
    }
    
/**
*  Method to calculate the Gross Per Paid field on LedgerEntryBreakout__c Object.
*  @param LedgerEntryBreakout__c, Event__c
*  @return LedgerEntryBreakout__c
**/
    public static LedgerEntryBreakout__c calculateGrossPerPaid(LedgerEntryBreakout__c ledgerEntryBreakout, Event__c relatedEvent){
        Double GrossRevenue = ledgerEntryBreakout.GrossRevenue__c == null ? 0.0 : ledgerEntryBreakout.GrossRevenue__c;
        
        //If Projected Paid Tickets = 0, then Gross Per Paid = Gross Revenue / Projected Drop Count otherwise use Projected Paid Tickets
        if(relatedEvent.ProjectedPaidTickets__c == 0 && relatedEvent.ProjectedDropCount__c != 0){
            ledgerEntryBreakout.GrossPerPaid__c = GrossRevenue / relatedEvent.ProjectedDropCount__c;
        }else if( relatedEvent.ProjectedPaidTickets__c != 0 ){
            ledgerEntryBreakout.GrossPerPaid__c = GrossRevenue / relatedEvent.ProjectedPaidTickets__c;
        }
        
        return ledgerEntryBreakout;
    }
    
/**
*  Method to calculate the Contra at Forecast field on LedgerEntryBreakout__c Object.
*  @param LedgerEntryBreakout__c, List<TicketScale__c>, Event__c
*  @return LedgerEntryBreakout__c
**/
    public static LedgerEntryBreakout__c calculateContraAtForecast(LedgerEntryBreakout__c ledgerEntryBreakout, List<TicketScale__c> listOfTicketScales,  Event__c relatedEvent){
        
        Decimal ticketRule = 0;
        Double ContraAmount = ledgerEntryBreakout.ContraAmount__c == null ? 0.0 : ledgerEntryBreakout.ContraAmount__c;
        Double GrossRevenue = ledgerEntryBreakout.GrossRevenue__c == null ? 0.0 : ledgerEntryBreakout.GrossRevenue__c;
        Double ContraPercent = ledgerEntryBreakout.ContraPercent__c == null ? 0.0 : ledgerEntryBreakout.ContraPercent__c/100;
        Double X3rdPartyPercent = ledgerEntryBreakout.X3rdPartyPercent__c == null ? 0.0 : ledgerEntryBreakout.X3rdPartyPercent__c/100;
        Double ProjectedPaidTickets = relatedEvent.ProjectedPaidTickets__c == null ? 0.0 : relatedEvent.ProjectedPaidTickets__c;
        Double ProjectedDropCount = relatedEvent.ProjectedDropCount__c == null ? 0.0 : relatedEvent.ProjectedDropCount__c;
        
        if (String.isBlank(ledgerEntryBreakout.ContraType__c)) {
            ledgerEntryBreakout.ContraAtForecast__c = GrossRevenue * (ContraPercent + X3rdPartyPercent);
        }
        //If the Rate Type of the Ledger Entry is Flat, then the Contra At Forecast = Contra Amount + ((Gross Revenue - Contra Amount) * (Contra % + 3rd Party %))
        else if(ledgerEntryBreakout.ContraType__c == RATE_TYPE_FLAT){
            ledgerEntryBreakout.ContraAtForecast__c = ContraAmount + ((GrossRevenue - ContraAmount) * (ContraPercent + X3rdPartyPercent));
        }
        //If the Rate Type of the Ledger Entry is Per Cap, then the Contra at Forecast is calculated applying the ticket scale rule.
        else{
            if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                ledgerEntryBreakout.ContraAtForecast__c = (ContraAmount * ProjectedPaidTickets) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ProjectedPaidTickets)));
            }else if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
                ledgerEntryBreakout.ContraAtForecast__c = (ContraAmount * ProjectedDropCount) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ProjectedDropCount)));
            }else if(ledgerEntryBreakout.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                ticketRule = 0;
                for(TicketScale__c ticketScale : listOfTicketScales){
                   if( ticketScale.ProjectedPaidTickets__c != null ){
                        ticketRule += ticketScale.ProjectedPaidTickets__c;
                   }
                }
                ledgerEntryBreakout.ContraAtForecast__c = (ContraAmount * ticketRule) + ((ContraPercent + X3rdPartyPercent) * (GrossRevenue - (ContraAmount * ticketRule)));
            }else{
                ledgerEntryBreakout.ContraAtForecast__c = ContraAmount;
            }
            
        }
        return ledgerEntryBreakout;
        
    }
/**
*  Method to calculate the Contra % at Forecast field on LedgerEntryBreakout__c Object.
*  @param LedgerEntryBreakout__c
*  @return LedgerEntryBreakout__c
**/
    public static LedgerEntryBreakout__c calculateContraPercentAtForecast(LedgerEntryBreakout__c ledgerEntryBreakout){
        
        if( ledgerEntryBreakout != null &&
              ledgerEntryBreakout.GrossRevenue__c != null &&
              ledgerEntryBreakout.GrossRevenue__c != 0 ) {

            Double ContraAtForecast = ledgerEntryBreakout.ContraAtForecast__c == null ? 0.0 : ledgerEntryBreakout.ContraAtForecast__c;
                    
            ledgerEntryBreakout.Contra_At_Forecast__c = ContraAtForecast / ledgerEntryBreakout.GrossRevenue__c;
        }
        
        return ledgerEntryBreakout;
    }
    
/**
*  Method to calculate the Net Revenue field on LedgerEntryBreakout__c Object.
*  @param LedgerEntryBreakout__c
*  @return LedgerEntryBreakout__c
**/
    public static LedgerEntryBreakout__c calculateNetRevenue(LedgerEntryBreakout__c ledgerEntryBreakout){
        
        if( ledgerEntryBreakout != null) {
            Double ContraAtForecast = ledgerEntryBreakout.ContraAtForecast__c == null ? 0.0 : ledgerEntryBreakout.ContraAtForecast__c;
            Double GrossRevenue = ledgerEntryBreakout.GrossRevenue__c == null ? 0.0 : ledgerEntryBreakout.GrossRevenue__c;
        
            ledgerEntryBreakout.Net_Revenue__c = GrossRevenue - ContraAtForecast;
        }
        
        return ledgerEntryBreakout;
    }
    
/**
*  Method to calculate the Net Per Paid field on LedgerEntryBreakout__c Object.
*  @param LedgerEntryBreakout__c, Event__c
*  @return LedgerEntryBreakout__c
**/
    public static LedgerEntryBreakout__c calculateNetPerPaid(LedgerEntryBreakout__c ledgerEntryBreakout, Event__c relatedEvent){
        
        if (ledgerEntryBreakout != null &&
              relatedEvent != null &&
              relatedEvent.ProjectedPaidTickets__c != null) {

            Double NetRevenue = ledgerEntryBreakout.Net_Revenue__c == null ? 0.0 : ledgerEntryBreakout.Net_Revenue__c;
                
            if(relatedEvent.ProjectedPaidTickets__c == 0 &&
                 relatedEvent.ProjectedDropCount__c != null &&
                 relatedEvent.ProjectedDropCount__c != 0 ) {
                    
                ledgerEntryBreakout.NetPerPaid__c = NetRevenue / relatedEvent.ProjectedDropCount__c;
            } else if( relatedEvent.ProjectedPaidTickets__c != 0 ) {
                
                ledgerEntryBreakout.NetPerPaid__c = NetRevenue / relatedEvent.ProjectedPaidTickets__c;
            }
        }
        
        return ledgerEntryBreakout;
    }
    
    private static LedgerEntry__c cogsCalculation (LNE_Event event, LedgerEntry__c le){

        if (le.RollupCount__c > 0) return le;
        
        
        //If the Rate Type of the Ledger Entry is FLat, then the Gross Revenue is equals to Base Amount.
        if(le.RateType__c != null){
            Double BaseAmount = le.BaseAmount__c == null ? 0.0 : le.BaseAmount__c;
            Double SelloutPaidTickets = event.eventRecord.SelloutPaidTickets__c == null ? 0.0 : event.eventRecord.SelloutPaidTickets__c;
            Double SelloutDropCount = event.eventRecord.SelloutDropCount__c == null ? 0.0 : event.eventRecord.SelloutDropCount__c;

            if(le.RateType__c == RATE_TYPE_FLAT){
                le.COGSAtSellout__c = BaseAmount;
                le.COGSatForecast__c = BaseAmount;
            }
            //If the Rate Type of the Ledger Entry is Per Cap, then the Gross Revenue is calculated applying the ticket scale rule.
            else{
                if(le.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                    le.COGSAtSellout__c = BaseAmount * SelloutPaidTickets;
                    le.COGSatForecast__c = BaseAmount * event.eventRecord.ProjectedPaidTickets__c;
                }else if(le.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
                    le.COGSAtSellout__c = BaseAmount * SelloutDropCount;
                    le.COGSatForecast__c = BaseAmount * event.eventRecord.ProjectedDropCount__c;
                }else if(le.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                    Decimal ticketRuleSellout = 0;
                    Decimal ticketRuleForecast = 0;
                    if(le.TicketScaleList__c != null){
                        String[] listOfTicketScaleIds = le.TicketScaleList__c.split('\\' + DELIMITER);
                        List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
                        for(TicketScale__c tscale :event.eventRecord.TicketScales__r){
                            for(String tsId : listOfTicketScaleIds){
                                if(tsId != null && tsId.length() >= 15 && tsId == tscale.Id){
                                    listOfTicketScales.add(tscale);
                                }
                            }
                        }
                        for(TicketScale__c ticketScale : listOfTicketScales){
                            if( ticketScale.SellableCapacity__c != null ){
                                ticketRuleSellout += ticketScale.SellableCapacity__c;
                            }
                            if( ticketScale.ProjectedPaidTickets__c != null ){
                                ticketRuleForecast += ticketScale.ProjectedPaidTickets__c;
                            }
                        }
                    }
                    le.COGSAtSellout__c = BaseAmount * ticketRuleSellout;
                    le.COGSatForecast__c = BaseAmount * ticketRuleForecast;
                }else{
                    le.COGSAtSellout__c = BaseAmount;
                    le.COGSatForecast__c = BaseAmount;
                }
            }
        }
        
        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        if (le.Min__c != null && le.Min__c > 0) {

            if(le.COGSAtSellout__c != null && le.COGSAtSellout__c < le.Min__c) {
                le.COGSAtSellout__c = le.Min__c;
            }

            if(le.COGSAtForecast__c != null && le.COGSAtForecast__c < le.Min__c) {
                le.COGSatForecast__c = le.Min__c;
            }
            
        }

        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        if (le.Max__c != null && le.Max__c > 0) {

            if(le.COGSAtSellout__c != null && le.COGSAtSellout__c > le.Max__c){
                le.COGSAtSellout__c = le.Max__c;
            }
            
            if(le.COGSAtForecast__c != null && le.COGSAtForecast__c > le.Max__c){
                le.COGSatForecast__c = le.Max__c;
            }
            
        }
        
        return le;
    }
    
    private static LedgerEntryBreakout__c cogsBreakoutCalculation(LNE_Event event, LedgerEntryBreakout__c lebr){
       
        //If the Rate Type of the Ledger Entry is FLat, then the Gross Revenue is equals to Base Amount.
        if(lebr.RateType__c != null){
            Double BaseAmount = lebr.BaseAmount__c == null ? 0.0 : lebr.BaseAmount__c;
            Double SelloutPaidTickets = event.eventRecord.SelloutPaidTickets__c == null ? 0.0 : event.eventRecord.SelloutPaidTickets__c;
            Double SelloutDropCount = event.eventRecord.SelloutDropCount__c == null ? 0.0 : event.eventRecord.SelloutDropCount__c;

            if(lebr.RateType__c == RATE_TYPE_FLAT){
                lebr.COGSAtSellout__c = BaseAmount;
                lebr.COGSatForecast__c = BaseAmount;
            }
            //If the Rate Type of the Ledger Entry is Per Cap, then the Gross Revenue is calculated applying the ticket scale rule.
            else{
                if(lebr.ApplyTicketScale__c == TICKET_SCALE_ALL_PAID_TICKETS){
                    lebr.COGSAtSellout__c = BaseAmount * SelloutPaidTickets;
                    lebr.COGSatForecast__c = BaseAmount * event.eventRecord.ProjectedPaidTickets__c;
                }else if(lebr.ApplyTicketScale__c == TICKET_SCALE_ALL_DROP_COUNT){
                    lebr.COGSAtSellout__c = BaseAmount * SelloutDropCount;
                    lebr.COGSatForecast__c = BaseAmount * event.eventRecord.ProjectedDropCount__c;
                }else if(lebr.ApplyTicketScale__c == TICKET_SCALE_SELECTED_TICKETS){
                    Decimal ticketRuleSellout = 0;
                    Decimal ticketRuleForecast = 0;
                    if(lebr.TicketScaleList__c != null){
                        String[] listOfTicketScaleIds = lebr.TicketScaleList__c.split('\\' + DELIMITER);
                        List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>();
                        for(TicketScale__c tscale :event.eventRecord.TicketScales__r){
                            for(String tsId : listOfTicketScaleIds){
                                if(tsId != null && tsId.length() >= 15 && tsId == tscale.Id){
                                    listOfTicketScales.add(tscale);
                                }
                            }
                        }
                        for(TicketScale__c ticketScale : listOfTicketScales){
                            if( ticketScale.SellableCapacity__c  != null ){
                                ticketRuleSellout += ticketScale.SellableCapacity__c ;
                            }
                            if( ticketScale.ProjectedPaidTickets__c != null ){
                                ticketRuleForecast += ticketScale.ProjectedPaidTickets__c;
                            }
                        }
                    }
                    lebr.COGSAtSellout__c = BaseAmount * ticketRuleSellout;
                    lebr.COGSatForecast__c = BaseAmount * ticketRuleForecast;
                }else{
                    lebr.COGSAtSellout__c = BaseAmount;
                    lebr.COGSatForecast__c = BaseAmount;
                }
            }
        }
        
        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        if (lebr.Min__c != null && lebr.Min__c > 0) {

            if(lebr.COGSAtSellout__c != null && lebr.COGSAtSellout__c < lebr.Min__c) {
                lebr.COGSAtSellout__c = lebr.Min__c;
            }

            if(lebr.COGSAtForecast__c != null && lebr.COGSAtForecast__c < lebr.Min__c) {
                lebr.COGSatForecast__c = lebr.Min__c;
            }
            
        }

        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        if (lebr.Max__c != null && lebr.Max__c > 0) {

            if(lebr.COGSAtSellout__c != null && lebr.COGSAtSellout__c > lebr.Max__c){
                lebr.COGSAtSellout__c = lebr.Max__c;
            }
            
            if(lebr.COGSAtForecast__c != null && lebr.COGSAtForecast__c > lebr.Max__c){
                lebr.COGSatForecast__c = lebr.Max__c;
            }
            
        }
        
        return lebr;
    }
    
    public static LedgerEntry__c expenseCalculation(LNE_Event event, LedgerEntry__c le){

        if (le.RollupCount__c > 0) return le;


        String rateType = le.OfferRateType__c;
        String inHouseRateType = le.InHouseRateType__c;
        le.OfferAtSellout__c = null;
        le.OfferAtProjection__c = null;

        if (le.OfferRate__c == 0) {
            le.OfferAtSellout__c = 0;
            le.OfferAtProjection__c = 0;
        }
        
        if (le.InHouseRate__c == 0) {
            le.InHouseProjection__c = 0;
        }
        
        if (le.OfferRate__c != null) {
            if (rateType == 'Flat') {
                le.OfferAtSellout__c = le.OfferRate__c;
                le.OfferAtProjection__c = le.OfferRate__c;
            } else if (event.eventRecord != null) {
                if (rateType == 'Per Truck' && event.eventRecord.NumberofTrucks__c != null) {
                    le.OfferAtSellout__c = le.OfferRate__c * event.eventRecord.NumberofTrucks__c;
                    le.OfferAtProjection__c = le.OfferRate__c * event.eventRecord.NumberofTrucks__c;
                } else if (rateType == 'Per Drop Count') {
                    if (event.eventRecord.SelloutDropCount__c != null) {
                        le.OfferAtSellout__c = le.OfferRate__c * event.eventRecord.SelloutDropCount__c;    
                    }

                    if (event.eventRecord.ProjectedDropCount__c != null) {
                        le.OfferAtProjection__c = le.OfferRate__c * event.eventRecord.ProjectedDropCount__c;   
                    }
                } else if (rateType == 'Per Paid Ticket') {
                    if (event.eventRecord.SelloutPaidTickets__c != null) {
                        le.OfferAtSellout__c = le.OfferRate__c * event.eventRecord.SelloutPaidTickets__c;  
                    }

                    if (event.eventRecord.ProjectedPaidTickets__c != null) {
                        le.OfferAtProjection__c = le.OfferRate__c * event.eventRecord.ProjectedPaidTickets__c;
                    }
                } else if (rateType == '% of Net Gross') {
                    if (event.eventRecord.NetGrossPotential__c != null) {
                        le.OfferAtSellout__c = le.OfferRate__c / 100 * event.eventRecord.NetGrossPotential__c; 
                    }

                    if (event.eventRecord.ProjectedNetGross__c != null) {
                        le.OfferAtProjection__c = le.OfferRate__c / 100 * event.eventRecord.ProjectedNetGross__c;
                    }
                } else if (rateType == '% of Gross') {
                    if (event.eventRecord.GrossPotential__c != null) {
                        le.OfferAtSellout__c = le.OfferRate__c / 100 * event.eventRecord.GrossPotential__c;    
                    }

                    if (event.eventRecord.ProjectedGross__c != null) {
                        le.OfferAtProjection__c = le.OfferRate__c / 100 * event.eventRecord.ProjectedGross__c; 
                    }
                } else if (rateType == '% of Adjusted Gross') {
                    if (event.eventRecord.AdjustedGrossPotential__c != null) {
                        le.OfferAtSellout__c = le.OfferRate__c / 100 * event.eventRecord.AdjustedGrossPotential__c;    
                    }

                    if (event.eventRecord.ProjectedAdjustedGross__c != null) {
                        le.OfferAtProjection__c = le.OfferRate__c / 100 * event.eventRecord.ProjectedAdjustedGross__c; 
                    }
                }
            } 
        }

        le.InHouseProjection__c = null;

        if (le.InHouseRate__c != null) {
            if (inHouseRateType == 'Flat') {
                le.InHouseProjection__c = le.InHouseRate__c;
            } else if (inHouseRateType == 'Per Truck' && event.eventRecord.NumberofTrucks__c != null) {
                le.InHouseProjection__c = le.InHouseRate__c * event.eventRecord.NumberofTrucks__c;
            } else if (inHouseRateType == 'Per Drop Count' && event.eventRecord.ProjectedDropCount__c != null) {
                le.InHouseProjection__c = le.InHouseRate__c * event.eventRecord.ProjectedDropCount__c;
            } else if (inHouseRateType == 'Per Paid Ticket' && event.eventRecord.ProjectedPaidTickets__c != null) {
                le.InHouseProjection__c = le.InHouseRate__c * event.eventRecord.ProjectedPaidTickets__c;
            } else if (inHouseRateType == '% of Net Gross' && event.eventRecord.ProjectedNetGross__c != null) {
                le.InHouseProjection__c = le.InHouseRate__c / 100 * event.eventRecord.ProjectedNetGross__c;
            } else if (inHouseRateType == '% of Gross' && event.eventRecord.ProjectedGross__c != null) {
                le.InHouseProjection__c = le.InHouseRate__c / 100 * event.eventRecord.ProjectedGross__c;
            } else if (inHouseRateType == '% of Adjusted Gross' && event.eventRecord.ProjectedAdjustedGross__c != null) {
                le.InHouseProjection__c = le.InHouseRate__c / 100 * event.eventRecord.ProjectedAdjustedGross__c;
            }
        }

        
        
        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        //-- US473 - verify this works.
        
        //Offer min/max
        if(le.OfferMin__c != null && le.OfferMin__c > 0){
            if (le.OfferAtSellout__c != null && le.OfferAtSellout__c < le.OfferMin__c) {
                le.OfferAtSellout__c = le.OfferMin__c;
            }
            
            if (le.OfferAtProjection__c != null && le.OfferAtProjection__c < le.OfferMin__c) {
                le.OfferAtProjection__c = le.OfferMin__c;
            }
        }
        
        if(le.OfferMax__c != null && le.OfferMax__c > 0){
            if (le.OfferAtSellout__c != null && le.OfferAtSellout__c > le.OfferMax__c) {
                le.OfferAtSellout__c = le.OfferMax__c;
            }
            
            if (le.OfferAtProjection__c != null && le.OfferAtProjection__c > le.OfferMax__c) {
                le.OfferAtProjection__c = le.OfferMax__c;
            }
        }
        
        
        //In House min/max
        if(le.InHouseMin__c != null && le.InHouseMin__c > 0){
            if (le.InHouseProjection__c != null && le.InHouseProjection__c < le.InHouseMin__c) {
                le.InHouseProjection__c = le.InHouseMin__c;
            }
        }
        
        if(le.InHouseMax__c != null && le.InHouseMax__c > 0){
            if (le.InHouseProjection__c != null && le.InHouseProjection__c > le.InHouseMax__c) {
                le.InHouseProjection__c = le.InHouseMax__c;
            }
        }
        
        le.ExpenseAdjustment__c = null;

        if (le.SettleAtActual__c == true) {
            le.ExpenseAdjustment__c = 0;
        } else if (le.OfferAtProjection__c != null && le.InHouseProjection__c != null) {
            le.ExpenseAdjustment__c = le.OfferAtProjection__c - le.InHouseProjection__c;
        }

        if (le.InHouseRate__c != null) {
            if(le.InHouseRateType__c == RATE_TYPE_FLAT){
                le.InHouseatSellout__c = le.InHouseRate__c;
            }else if(le.InHouseRateType__c == RATE_TYPE_PER_TRUCK && event.eventRecord.NumberOfTrucks__c != null){
                le.InHouseatSellout__c = le.InHouseRate__c * event.eventRecord.NumberofTrucks__c;
            }else if(le.InHouseRateType__c == RATE_TYPE_PER_DROP_COUNT && event.eventRecord.SelloutDropCount__c != null){
                le.InHouseatSellout__c = le.InHouseRate__c * event.eventRecord.SelloutDropCount__c;
            }else if(le.InHouseRateType__c == RATE_TYPE_PER_PAID_TICKET && event.eventRecord.SelloutPaidTickets__c != null){
                le.InHouseatSellout__c = le.InHouseRate__c * event.eventRecord.SelloutPaidTickets__c;
            }else if(le.InHouseRateType__c == RATE_TYPE_NET_GROSS && event.eventRecord.NetGrossPotential__c != null){
                le.InHouseatSellout__c = le.InHouseRate__c / 100 * event.eventRecord.NetGrossPotential__c;
            }else if(le.InHouseRateType__c == RATE_TYPE_GROSS && event.eventRecord.GrossPotential__c != null){
                le.InHouseatSellout__c = le.InHouseRate__c / 100 * event.eventRecord.GrossPotential__c;
            }else if(le.InHouseRateType__c == RATE_TYPE_ADJUSTED_GROSS && event.eventRecord.AdjustedGrossPotential__c != null){
                le.InHouseatSellout__c = le.InHouseRate__c / 100 * event.eventRecord.AdjustedGrossPotential__c;
            }
        }


        if(le.InHouseMin__c != null && le.InHouseMin__c != 0 && le.InHouseatSellout__c != null && le.InHouseMin__c > le.InHouseatSellout__c){
            le.InHouseatSellout__c = le.InHouseMin__c;
        }
        if(le.InHouseMax__c != null && le.InHouseMax__c != 0 && le.InHouseatSellout__c != null && le.InHouseMax__c < le.InHouseatSellout__c){
            le.InHouseatSellout__c = le.InHousemax__c;
        }

        //System.debug(le.ExpenseAdjustmentatSellout__c);
        //System.debug(le.OfferAtSellout__c);
        //System.debug(le.InHouseatSellout__c);

        if(le.SettleAtActual__c){
            le.ExpenseAdjustmentatSellout__c = 0;
        }else{
            le.ExpenseAdjustmentatSellout__c = null;

            if (le.OfferAtSellout__c != null && le.InHouseatSellout__c != null) {
                le.ExpenseAdjustmentatSellout__c = le.OfferAtSellout__c - le.InHouseatSellout__c;
            }
        }
        if (le.OfferAtSellout__c != null) {
            event.sumLedgerOfferAtSellout += le.OfferAtSellout__c;
        }

        if (le.Settlement__c != null) {
            event.sumLedgerSettlement += le.Settlement__c;
        }

        if (le.OfferAtProjection__c != null) {
            event.sumLedgerOfferAtProjection += le.OfferAtProjection__c;
        }
        
        return le;
    }
    
    public static LedgerEntryBreakout__c expenseBreakoutCalculation(LNE_Event event, LedgerEntryBreakout__c lebr){

        

        String rateType = lebr.OfferRateType__c;
        String inHouseRateType = lebr.InHouseRateType__c;
        lebr.OfferAtSellout__c = null;
        lebr.OfferAtProjection__c = null;

        if (lebr.OfferRate__c == 0) {
            lebr.OfferAtSellout__c = 0;
            lebr.OfferAtProjection__c = 0;
        }
        
        if (lebr.InHouseRate__c == 0) {
            lebr.InHouseProjection__c = 0;
        }
        
        if (lebr.OfferRate__c != null) {
            if (rateType == 'Flat') {
                lebr.OfferAtSellout__c = lebr.OfferRate__c;
                lebr.OfferAtProjection__c = lebr.OfferRate__c;
            } else if (event.eventRecord != null) {
                if (rateType == 'Per Truck' && event.eventRecord.NumberofTrucks__c != null) {
                    lebr.OfferAtSellout__c = lebr.OfferRate__c * event.eventRecord.NumberofTrucks__c;
                    lebr.OfferAtProjection__c = lebr.OfferRate__c * event.eventRecord.NumberofTrucks__c;
                } else if (rateType == 'Per Drop Count') {
                    if (event.eventRecord.SelloutDropCount__c != null) {
                        lebr.OfferAtSellout__c = lebr.OfferRate__c * event.eventRecord.SelloutDropCount__c;    
                    }

                    if (event.eventRecord.ProjectedDropCount__c != null) {
                        lebr.OfferAtProjection__c = lebr.OfferRate__c * event.eventRecord.ProjectedDropCount__c;   
                    }
                } else if (rateType == 'Per Paid Ticket') {
                    if (event.eventRecord.SelloutPaidTickets__c != null) {
                        lebr.OfferAtSellout__c = lebr.OfferRate__c * event.eventRecord.SelloutPaidTickets__c;  
                    }

                    if (event.eventRecord.ProjectedPaidTickets__c != null) {
                        lebr.OfferAtProjection__c = lebr.OfferRate__c * event.eventRecord.ProjectedPaidTickets__c;
                    }
                } else if (rateType == '% of Net Gross') {
                    if (event.eventRecord.NetGrossPotential__c != null) {
                        lebr.OfferAtSellout__c = lebr.OfferRate__c / 100 * event.eventRecord.NetGrossPotential__c; 
                    }

                    if (event.eventRecord.ProjectedNetGross__c != null) {
                        lebr.OfferAtProjection__c = lebr.OfferRate__c / 100 * event.eventRecord.ProjectedNetGross__c;
                    }
                } else if (rateType == '% of Gross') {
                    if (event.eventRecord.GrossPotential__c != null) {
                        lebr.OfferAtSellout__c = lebr.OfferRate__c / 100 * event.eventRecord.GrossPotential__c;    
                    }

                    if (event.eventRecord.ProjectedGross__c != null) {
                        lebr.OfferAtProjection__c = lebr.OfferRate__c / 100 * event.eventRecord.ProjectedGross__c; 
                    }
                } else if (rateType == '% of Adjusted Gross') {
                    if (event.eventRecord.AdjustedGrossPotential__c != null) {
                        lebr.OfferAtSellout__c = lebr.OfferRate__c / 100 * event.eventRecord.AdjustedGrossPotential__c;    
                    }

                    if (event.eventRecord.ProjectedAdjustedGross__c != null) {
                        lebr.OfferAtProjection__c = lebr.OfferRate__c / 100 * event.eventRecord.ProjectedAdjustedGross__c; 
                    }
                }
            } 
        }

        lebr.InHouseProjection__c = null;

        if (lebr.InHouseRate__c != null) {
            if (inHouseRateType == 'Flat') {
                lebr.InHouseProjection__c = lebr.InHouseRate__c;
            } else if (inHouseRateType == 'Per Truck' && event.eventRecord.NumberofTrucks__c != null) {
                lebr.InHouseProjection__c = lebr.InHouseRate__c * event.eventRecord.NumberofTrucks__c;
            } else if (inHouseRateType == 'Per Drop Count' && event.eventRecord.ProjectedDropCount__c != null) {
                lebr.InHouseProjection__c = lebr.InHouseRate__c * event.eventRecord.ProjectedDropCount__c;
            } else if (inHouseRateType == 'Per Paid Ticket' && event.eventRecord.ProjectedPaidTickets__c != null) {
                lebr.InHouseProjection__c = lebr.InHouseRate__c * event.eventRecord.ProjectedPaidTickets__c;
            } else if (inHouseRateType == '% of Net Gross' && event.eventRecord.ProjectedNetGross__c != null) {
                lebr.InHouseProjection__c = lebr.InHouseRate__c / 100 * event.eventRecord.ProjectedNetGross__c;
            } else if (inHouseRateType == '% of Gross' && event.eventRecord.ProjectedGross__c != null) {
                lebr.InHouseProjection__c = lebr.InHouseRate__c / 100 * event.eventRecord.ProjectedGross__c;
            } else if (inHouseRateType == '% of Adjusted Gross' && event.eventRecord.ProjectedAdjustedGross__c != null) {
                lebr.InHouseProjection__c = lebr.InHouseRate__c / 100 * event.eventRecord.ProjectedAdjustedGross__c;
            }
        }

        lebr.ExpenseAdjustment__c = null;

        if (lebr.SettleAtActual__c == true) {
            lebr.ExpenseAdjustment__c = 0;
        } else if (lebr.OfferAtProjection__c != null && lebr.InHouseProjection__c != null) {
            lebr.ExpenseAdjustment__c = lebr.OfferAtProjection__c - lebr.InHouseProjection__c;
        }
        
        // If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        //-- US473 - verify this works.
        
        //Offer min/max
        if(lebr.OfferMin__c != null && lebr.OfferMin__c > 0){
            if (lebr.OfferAtSellout__c != null && lebr.OfferAtSellout__c < lebr.OfferMin__c) {
                lebr.OfferAtSellout__c = lebr.OfferMin__c;
            }
            
            if (lebr.OfferAtProjection__c != null && lebr.OfferAtProjection__c < lebr.OfferMin__c) {
                lebr.OfferAtProjection__c = lebr.OfferMin__c;
            }
        }
        
        if(lebr.OfferMax__c != null && lebr.OfferMax__c > 0){
            if (lebr.OfferAtSellout__c != null && lebr.OfferAtSellout__c > lebr.OfferMax__c) {
                lebr.OfferAtSellout__c = lebr.OfferMax__c;
            }
            
            if (lebr.OfferAtProjection__c != null && lebr.OfferAtProjection__c > lebr.OfferMax__c) {
                lebr.OfferAtProjection__c = lebr.OfferMax__c;
            }
        }
        
        
        //In House min/max
        if(lebr.InHouseMin__c != null && lebr.InHouseMin__c > 0){
            if (lebr.InHouseProjection__c != null && lebr.InHouseProjection__c < lebr.InHouseMin__c) {
                lebr.InHouseProjection__c = lebr.InHouseMin__c;
            }
        }
        
        if(lebr.InHouseMax__c != null && lebr.InHouseMax__c > 0){
            if (lebr.InHouseProjection__c != null && lebr.InHouseProjection__c > lebr.InHouseMax__c) {
                lebr.InHouseProjection__c = lebr.InHouseMax__c;
            }
        }

        if (lebr.InHouseRate__c != null) {
            if(lebr.InHouseRateType__c == RATE_TYPE_FLAT){
                lebr.InHouseatSellout__c = lebr.InHouseRate__c;    
            }else if(lebr.InHouseRateType__c == RATE_TYPE_PER_TRUCK && event.eventRecord.NumberOfTrucks__c != null){
                lebr.InHouseatSellout__c = lebr.InHouseRate__c * event.eventRecord.NumberofTrucks__c;
            }else if(lebr.InHouseRateType__c ==  RATE_TYPE_PER_DROP_COUNT && event.eventRecord.SelloutDropCount__c != null){
                lebr.InHouseatSellout__c = lebr.InHouseRate__c * event.eventRecord.SelloutDropCount__c;
            }else if(lebr.InHouseRateType__c == RATE_TYPE_PER_PAID_TICKET && event.eventRecord.SelloutPaidTickets__c != null){
                lebr.InHouseatSellout__c = lebr.InHouseRate__c * event.eventRecord.SelloutPaidTickets__c;
            }else if(lebr.InHouseRateType__c == RATE_TYPE_NET_GROSS && event.eventRecord.NetGrossPotential__c != null){
                lebr.InHouseatSellout__c = lebr.InHouseRate__c / 100 * event.eventRecord.NetGrossPotential__c;
            }else if(lebr.InHouseRateType__c == RATE_TYPE_GROSS && event.eventRecord.GrossPotential__c != null){
                lebr.InHouseatSellout__c = lebr.InHouseRate__c / 100 * event.eventRecord.GrossPotential__c;
            }else if(lebr.InHouseRateType__c == RATE_TYPE_ADJUSTED_GROSS && event.eventRecord.AdjustedGrossPotential__c != null){
                lebr.InHouseatSellout__c = lebr.InHouseRate__c / 100 * event.eventRecord.AdjustedGrossPotential__c;
            }
        }

        if(lebr.InHouseMin__c != null && lebr.InHouseMin__c != 0 && lebr.InHouseatSellout__c != null && lebr.InHouseMin__c > lebr.InHouseatSellout__c){
            lebr.InHouseatSellout__c = lebr.InHouseMin__c;
        }
        if(lebr.InHouseMax__c != null && lebr.InHouseMax__c != 0 && lebr.InHouseatSellout__c != null && lebr.InHouseMax__c < lebr.InHouseatSellout__c){
            lebr.InHouseatSellout__c = lebr.InHousemax__c;
        }
        if(lebr.SettleAtActual__c){
            lebr.ExpenseAdjustmentatSellout__c = 0;
        }else{
            lebr.ExpenseAdjustmentatSellout__c = null;

            if (lebr.OfferAtSellout__c != null && lebr.InHouseatSellout__c != null) {
                lebr.ExpenseAdjustmentatSellout__c = lebr.OfferAtSellout__c - lebr.InHouseatSellout__c;
            }
        }
        
        return lebr;
    }

    private static LedgerEntry__c getLedgerForEvent(LNE_Event e, String code) {
        LedgerEntry__c l = e.ledgers.get(code);

        if (l == null) {
            Id glAccountId = glAccountMap.get(code);
            l = new LedgerEntry__c(Event__c=e.eventRecord.Id,
                                   GLAccount__c=glAccountId,
                                   RecordTypeId=RT_TICKET_REVENUE_ID);
        }

        if(l.PlanAmount__c == NULL) l.PlanAmount__c = 0.0;
        if(l.ProjectionAmount__c == NULL) l.ProjectionAmount__c = 0.0;

        return l;
    }

    private static Decimal getDecimal(Decimal val) {
        return getDecimal(val, 0);
    }

    private static Decimal getDecimal(Decimal val, Decimal defval) {
        return val == null ? defval : val;
    }

    public class LNE_Event {
        public Event__c eventRecord;
        public List<LNE_TicketScale> ticketScales = new List<LNE_TicketScale>();
        public List<LNE_Deduction> beforeDeductions = new List<LNE_Deduction>();
        public List<LNE_Deduction> afterDeductions = new List<LNE_Deduction>();
        public Decimal sumProjectedTickets = 0.0;
        public Decimal sumSelloutTickets = 0.0;
        public Decimal sumSettlementPaidTickets = 0.0;
        public Decimal sumSettlementGrossSales = 0.0;
        public Decimal sumComps = 0.0;
        public Decimal selloutDeduction = 0.0;
        public Decimal projectedDeduction = 0.0;
        public Decimal selloutAfterDeduction = 0.0;
        public Decimal projectedAfterDeduction = 0.0;
        public Map<String, LedgerEntry__c> ledgers = new Map<String, LedgerEntry__c>();
        public Boolean hasPlan = false;
        public Boolean hasProjection = false;
        public Decimal sumLedgerOfferAtSellout = 0.0;
        public Decimal sumLedgerOfferAtProjection= 0.0;
        public Decimal sumLedgerSettlement= 0.0;
        public Decimal sumDealPotentialInclusiveArtistExpenses = 0.0;
        public Decimal sumInclusiveArtistExpensesPerDealCalculation = 0.0;
        public Decimal sumDealPotentialInclusiveArtistExpensesSettlement = 0.0;
        public Decimal sumInclusiveArtistExpensesPerDealCalculationSettlement = 0.0;
        public Decimal sumArtistGuarantees = 0.0;
        public Decimal sumArtistGuaranteesSettlement = 0.0;
        public String primaryDealType = '';
        public Decimal primaryDealBackendPercent = 0.0;
        public String primaryDealCalculation = '';
        public String primaryDealTypeSettlement = '';
        public Decimal primaryDealBackendPercentSettlement = 0.0;
        public String primaryDealCalculationSettlement = '';
        public Decimal potentialPromoterProfitAtSplit = 0.0;
        public Decimal projectedPromoterProfitAtSplit = 0.0;
        public Decimal settlementPromoterProfitAtSplit = 0.0;
        public Decimal settlementDeduction = 0.0;
        public Decimal settlementAfterDeduction = 0.0;
        public Decimal settlementTotalDeduction = 0.0;

        public LNE_Event(Event__c e) {
            e.SelloutGrossSales__c = 0.0;
            e.ProjectedGrossSales__c = 0.0;
            e.PlatinumLift__c = 0.0;
            e.ProjectedGross__c = 0.0;
            e.GrossPotential__c = 0.0;
            e.ProjectedAverageTicketPrice__c = 0.0;
            e.SelloutAverageTicketPrice__c = 0.0;
            e.ArtistCostsPotential__c = 0.0;
            e.TalentOverhead__c = 0.0;
            e.ProjectedArtistCosts__c = 0.0;
            e.PLAfterPrimaryCoProsAtProjection__c = 0.0;
            e.PLAfterPrimaryCoProsAtSellout__c = 0.0;
            e.SettlementArtistSuppliedSL__c = 0.0;
            e.SettlementGuarantee__c = 0.0;
            e.SettlementOtherTalentAmount__c = 0.0;
            e.SettlementPlatinumLift__c = 0.0;
            this.eventRecord = e;
        }
    }

    public class LNE_TicketScale {
        public TicketScale__c ticketScaleRecord;
        public Decimal sumFees = 0.0;
        public Decimal sumSelloutFees = 0.0;
        public Decimal sumPrimaryDividers = 0.0;
        public Decimal sumPrimaryMultipliers = 0.0;
        public Decimal sumSecondaryDividers = 0.0;
        public Decimal sumSecondaryMultipliers = 0.0;
        public Decimal sumPlatinumPrimaryDividers = 0.0;
        public Decimal sumPlatinumPrimaryMultipliers = 0.0;
        public Decimal sumPlatinumSecondaryDividers = 0.0;
        public Decimal sumPlatinumSecondaryMultipliers = 0.0;
        public Decimal sumSelloutPrimaryDividers = 0.0;
        public Decimal sumSelloutPrimaryMultipliers = 0.0;
        public Decimal sumSelloutSecondaryDividers = 0.0;
        public Decimal sumSelloutSecondaryMultipliers = 0.0;
        public Decimal sumSelloutDeductions = 0.0;
        public Decimal sumProjectedDeductions = 0.0;
        public Decimal projectedAdjustedGross = 0.0;
        public Decimal adjustedGross = 0.0;
        public Decimal settlementAdjustedGross = 0.0;

        //- for After Deductions:
        public Decimal sumAfterFees = 0.0;
        public Decimal sumAfterPrimaryDividers = 0.0;
        public Decimal sumAfterPrimaryMultipliers = 0.0;
        public Decimal sumAfterSecondaryDividers = 0.0;
        public Decimal sumAfterSecondaryMultipliers = 0.0;
        public Decimal sumAfterPlatinumPrimaryDividers = 0.0;
        public Decimal sumAfterPlatinumPrimaryMultipliers = 0.0;
        public Decimal sumAfterPlatinumSecondaryDividers = 0.0;
        public Decimal sumAfterPlatinumSecondaryMultipliers = 0.0;
        public Decimal sumAfterSelloutPrimaryDividers = 0.0;
        public Decimal sumAfterSelloutPrimaryMultipliers = 0.0;

        public LNE_TicketScale(TicketScale__c t) {
            this.ticketScaleRecord = t;
        }
    }

    public class LNE_Deduction {
        public Deduction__c deductionRecord;
        public Decimal sumFees = 0.0;
        public Decimal sumPrimaryDividers = 0.0;
        public Decimal sumPrimaryMultipliers = 0.0;
        public Decimal sumSecondaryDividers = 0.0;
        public Decimal sumSecondaryMultipliers = 0.0;
        public Decimal sumSelloutFees = 0.0;
        public Decimal sumSelloutPrimaryDividers = 0.0;
        public Decimal sumSelloutPrimaryMultipliers = 0.0;
        public Decimal sumSelloutSecondaryDividers = 0.0;
        public Decimal sumSelloutSecondaryMultipliers = 0.0;
        public Decimal totalBaseAmount = 0.0;
        public Decimal appliedTicketsCount = 0.0;

        public LNE_Deduction(Deduction__c d) {
            this.deductionRecord = d;
        }
    }
}
