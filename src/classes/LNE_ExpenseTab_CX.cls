/**
 *  Class that provides functionality for LNE_ExpenseTab.page
 *
 *  @author Brandon Robins <brobins@salesforce.com>
 *
 **/
global class LNE_ExpenseTab_CX {
    static final String RT_EXPENSES = 'LedgerEntry__c.Expenses';

    private final SObject parent;
    public Event__c relatedEvent {get;set;}

    public String eventId {get;set;}
    public Boolean hasRelatedExpenses {get;set;}
    public Integer relatedExpensesCount {get;set;}
    public Boolean usingHouseNut {get; set;}
    public Integer houseNutAmount {get; set;}

    private static final GeneralSettings__c GENERAL_SETTINGS = GeneralSettings__c.getInstance();
    public String gridLostFocusPollInterval; 

    Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_EXPENSES }
    );

    Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );

    public LNE_ExpenseTab_CX(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        relatedEvent = [SELECT Id, UsingHouseNut__c,AdvertisingBudget__c, AdvertisingSettlementPlan__c, NumberofTrucks__c 
                                FROM Event__c WHERE Id = :parent.id];
        eventId = parent.Id;

        getRelatedExpenses();
    }

    public void getRelatedExpenses() {
        Boolean show = false;

        List<LedgerEntry__c> expenses = [SELECT Id FROM LedgerEntry__c WHERE RecordTypeId IN (:RT_EXPENSES_ID) AND Event__c = :relatedEvent.Id];

        relatedExpensesCount = expenses.size();

        if (relatedExpensesCount > 0) {
            show = true;
        }

        hasRelatedExpenses = show;
    }

    public Event__c getEvent() {
        return relatedEvent;
    }

    public String getGridLostFocusPollInterval() {
        String res = GENERAL_SETTINGS.Grid_Lost_Focus_Poll_Interval__c;
        return res;
    }

    public String updateEventHouseNut() {
        Event__c event = getEvent();
        System.debug('human updateEventHouseNut()');
        System.debug('Event id is ' + event.Id);
        System.debug('event.UsingHouseNut__c is ' + event.UsingHouseNut__c);
        
        try {
            event.UsingHouseNut__c = usingHouseNut;
            event.BookingHouseNut__c = houseNutAmount;
            update event;
        } catch(DmlException e) {
            System.debug('human updating event house nut failed!');
            System.debug(e);
        }
        
        System.debug('post update event.UsingHouseNut__c is ' + event.UsingHouseNut__c);
        return null;
    }

    @RemoteAction
    global static Boolean saveEvent(Id eventId, Decimal advertisingbudget, String advertisingsettlementplan, Decimal numberofTrucks) {
        Event__c updateEvent = new Event__c(Id=eventId, AdvertisingBudget__c = advertisingbudget  
                                            ,AdvertisingSettlementPlan__c=advertisingsettlementplan 
                                            ,NumberofTrucks__c = numberofTrucks
                                            );

        Boolean success = true;
        System.savepoint sp = Database.setSavepoint();
        system.debug('@@@ updateEvent - '+ updateEvent);

        try {
            update updateEvent;
        }
        catch (System.DmlException de) {
            Database.rollback(sp);
            success = false;
        }

        return success;
    }  
}