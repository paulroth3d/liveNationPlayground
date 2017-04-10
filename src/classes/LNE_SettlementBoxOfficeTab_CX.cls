global class LNE_SettlementBoxOfficeTab_CX {
    
    public Event__c eventRecord {get;set;}
    public String eventId {get;set;}
    public Event__c eventMetrics {get;set;}
    public String gridLostFocusPollInterval;
    public String gridBuddyRecordsToShow {get;set;}
    public Integer showGridsAsReadOnly {get;set;}
    public String tabToShow {get;set;}
    public Integer numPlatinumTicketScales {get;set;}
    public Boolean multipleEventDateTimes {get;set;}
    public Boolean showEventDateTimeTabs {get;set;}
    public List<AggregateResult> dateTimeSummary {get;set;}
    public Map<Id, EventDateTime__c> dateTimeMap {get;set;}
    public List<LNE_EventDateTimeUtil_T.EventDateTime> sortedEventDates {get;set;}
    public static final String BOX_OFFICE_TAB = 'box_office';
    public static final String PLATINUM_AND_DEDUCTIONS_TAB = 'platinum_and_deductions';
    public String delimiter {get {
        return DATA_SETTINGS.CombinedKeyDelimiter__c;
    }}
    
    private final SObject parent;
    private static final GeneralSettings__c GENERAL_SETTINGS = GeneralSettings__c.getInstance();
    private static final DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
    
    private static String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
    private static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_ANCILLARY }
    );

    private static Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );

    public LNE_SettlementBoxOfficeTab_CX(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        eventId = parent.Id;
        init();
    }
    
    public void init() {
        tabToShow = BOX_OFFICE_TAB;
        checkPlatinumTicketScales();
        eventRecord = [SELECT SettlementStarted__c FROM Event__c WHERE Id = :parent.Id];
        gridBuddyRecordsToShow = getGridBuddyDataTypeToShow('Settlement');
        getBoxOfficeGrid();
        //- This is used in GridBuddy "ro" URL parameter. 0 = Editable, 1 = Read Only
        showGridsAsReadOnly = 0;
        getDateTimeSummary();
    }

    public void checkPlatinumTicketScales() {
        numPlatinumTicketScales = [SELECT COUNT() FROM TicketScale__c WHERE Event__c = :eventId AND Type__c = 'Platinum' AND StageType__c = 'Settlement'];
    }

    public PageReference dropCountGridSave(){
        update parent;
        
        return( null );
    }

    public String getGridLostFocusPollInterval() {
        String res = GENERAL_SETTINGS.Grid_Lost_Focus_Poll_Interval__c;
        return res;
    }
    
    public PageReference getBoxOfficeGrid(){
        eventMetrics = [SELECT  ShowCount__c, SelloutGrossSales__c, PlatinumLift__c, GrossPotential__c, AdjustedGrossPotential__c, NetGrossPotential__c,
                                ProjectedGrossSales__c, ProjectedGross__c,ProjectedAdjustedGross__c, ProjectedNetGross__c, Status__c, StatusStage__c, UsingTicketFeed__c,
                                ProjectedPaidTickets__c, HidePreviouslyForecastedLiftBfrTxs__c, HidePreviouslyForecastedProjPdTkt__c,
                                PrevioulsyForecastedLiftBeforeTaxes__c, PreviouslyForecastedProjPaidTickets__c,SettlementPaidTickets__c,SettlementGrossSales__c,
                                SettlementPlatinumLift__c, SettlementDeductions__c, SettlementNetGross__c,
                                (SELECT EventDate__c, StartTime__c, PreviouslyForecastedGrossSales__c,PreviouslyForecastedProjPaidTickets__c,
                                                            PrevForecastedPlatinumLiftbeforeFee__c, HidePreviouslyForecastedProjPdTkt__c,
                                                            HidePreviouslyForecastedLiftBfrTxs__c
                                 FROM EventDateTimes__r ORDER BY EventDate__c ASC NULLS LAST)
                        FROM Event__c WHERE Id = :eventId][0]; 

        dateTimeMap = new Map<Id, EventDateTime__c>(eventMetrics.EventDateTimes__r);
        multipleEventDateTimes = eventMetrics.EventDateTimes__r.size() > 1;
        showEventDateTimeTabs = multipleEventDateTimes;

        sortedEventDates = new List<LNE_EventDateTimeUtil_T.EventDateTime>();
        
        for (EventDateTime__c edt : eventMetrics.EventDateTimes__r) {
            sortedEventDates.add(new LNE_EventDateTimeUtil_T.EventDateTime(edt));
        }
        
        sortedEventDates.sort();

        return null;
    }

     public void getDateTimeSummary() {
        List<AggregateResult> ar =   [SELECT SUM(Capacity__c) totalCapacity,
                                      SUM(Kills__c) kills,
                                      SUM(Holds__c) holds,
                                      SUM(NetCapacity__c) netCapacity,
                                      SUM(Comps__c) comps,
                                      SUM(Unsold__c) unsold,
                                      SUM(ActualSalesToDate__c) actualSalesToDate,
                                      SUM(ActualGrossToDate__c) actualGrossToDate,
                                      EventDateTime__c Id
                               FROM TicketScale__c
                               WHERE Event__c = :eventId
                               AND StageType__c = 'Settlement'
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
 
    public void startSettlement() {
        LNE_SettlementUtil.startSettlementProcess(eventRecord.Id);
    }

    public void showBoxOfficeTab() {
        tabToShow = BOX_OFFICE_TAB;
        checkPlatinumTicketScales();
        getDateTimeSummary();
    }

    public void showPlatinumAndDeductionsTab() {
        tabToShow = PLATINUM_AND_DEDUCTIONS_TAB;
        checkPlatinumTicketScales();
        getDateTimeSummary();
    }

    @RemoteAction
    global static Integer checkPlatinum(String edtId){
        return [SELECT COUNT() FROM TicketScale__c WHERE EventDateTime__c = :edtId AND Type__c = 'Platinum' AND StageType__c = 'Settlement'];
    }
    
    private String getGridBuddyDataTypeToShow(String type) {
        return eventId.substring(0,15) + DATA_SETTINGS.CombinedKeyDelimiter__c + type;
    }
}