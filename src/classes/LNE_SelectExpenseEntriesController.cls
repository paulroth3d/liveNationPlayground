/**
 *  Class that provides functionality for LNE_SelectExpenseEntries.page
 *
 *  @author Brandon Robins <brobins@salesforce.com>
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 *
 **/
public class LNE_SelectExpenseEntriesController {
    static final String RT_EXPENSES = 'LedgerEntry__c.Expenses';
    static final String RT_PROMOTEDSHOW = 'Event__c.PromotedShow';
    static final String RT_RENTAL = 'Event__c.Rental';
    static final String PARAM_EVENT_ID = 'event_id';

    public String eventId {get;set;}
    public String expenseEntriesJson {get;set;}
    public String previousSelectedEntriesJson {get;set;}
    public String selectedEntriesJson {get;set;}
    public String saveSelectedExpensesSuccess {get;set;}
    public Boolean isSettlement {get;set;}

    private List<Id> previousSelectedGLAccountIds {get;set;}

    Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_EXPENSES, RT_PROMOTEDSHOW, RT_RENTAL }
    );

    Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    Id RT_PROMOTEDSHOW_ID = recordTypeMap.get( RT_PROMOTEDSHOW );
    Id RT_RENTAL_ID = recordTypeMap.get( RT_RENTAL );

    public LNE_SelectExpenseEntriesController() {
        isSettlement = false;
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if(params.containsKey('type') && params.get('type') != null){
            isSettlement = params.get('type') == 'Settlement';
        }
        eventId = ApexPages.currentPage().getParameters().get( PARAM_EVENT_ID );

        previousSelectedGLAccountIds = new List<Id>();
        getGLAccountListGroupedByCategory();
    }

    private void addLedgerEntries(List<Id> glAccountIds) {
        List<LedgerEntry__c> ledgerEntries = new List<LedgerEntry__c>();

        for (Id accountId : glAccountIds) {
            ledgerEntries.add(new LedgerEntry__c(
                GLAccount__c = accountId,
                Event__c = eventId,
                RecordTypeId = RT_EXPENSES_ID
            ));
        }

        insert ledgerEntries;
    }

    private void getGLAccountListGroupedByCategory() {
        List<GLAccount__c> expenseEntries = new List<GLAccount__c>();
        List<GLAccountWrapper> wrapperList = new List<GLAccountWrapper>();

        List<GLAccount__c> accountList = new List<GLAccount__c>();
        //accountList = [SELECT Name, Category__c, CategorySort__c, GLCode__c FROM GLAccount__c WHERE Type__c = 'Expenses' AND AvailableForForecast__c = true];
        
        // US751 - build dynamic soql for ancillaries and check for rental vs promoted based on event recordtype.
        String additionalFilter = '';
        if(eventId != null){
            List<Event__c> eventList = [Select Id, RecordTypeId, RentalBuildOption__c from Event__c where Id = :eventId];
            if(eventList != null && !eventList.isEmpty()){
                Event__c event = eventList[0];
                if(event.RecordTypeId == RT_PROMOTEDSHOW_ID){
                    additionalFilter = ' AND ApplyToPromotedEvent__c = true ';
                }else if(event.RecordTypeId == RT_RENTAL_ID){
                    if(event.RentalBuildOption__c == 'Build Using Rental Accounts' ){
                        additionalFilter = ' AND ApplyToRentalEvent__c = true ';
                    }else if(event.RentalBuildOption__c == 'Build as a Promoted Show'){
                        additionalFilter = ' AND ApplyToPromotedEvent__c = true ';
                    }
                }
            }
        }
        String accountSOQL = 'SELECT Name, Category__c, CategorySort__c, GLCode__c, Type__c FROM GLAccount__c'
                                    + ' WHERE Type__c = \'Expenses\' AND AvailableForForecast__c = true '
                                    + additionalFilter;
        accountList = Database.Query(accountSOQL);

        for (GLAccount__c account : accountList) {
            wrapperList.add(new GLAccountWrapper(account));
        }

        wrapperList.sort();

        for (GLAccountWrapper glAccountWrapper : wrapperList) {
            expenseEntries.add(glAccountWrapper.glAccount);
        }

        expenseEntriesJson = System.JSON.serialize(expenseEntries);
    }

    private void removeLedgerEntries(List<Id> glAccountIds) {
        List<LedgerEntry__c> ledgerEntries = [SELECT Id FROM LedgerEntry__c WHERE GLAccount__c IN :glAccountIds AND Event__c = :eventId];

        delete ledgerEntries;
    }

    public void addOrRemoveExpenseEntries() {
        List<Integer> elemToRemove = new List<Integer>();
        List<Id> glAccountsToAdd = new List<Id>();
        List<Id> glAccountsToRemove = new List<Id>();

        List<Id> selectedGLAccountIds = (List<Id>) System.JSON.deserialize(selectedEntriesJson, List<Id>.class);

        for (Integer i = 0; i < previousSelectedGLAccountIds.size(); i++) {
            Boolean isMissing = true;

            for (Id selElem : selectedGLAccountIds) {
                if (selElem == previousSelectedGLAccountIds[i]) {
                    isMissing = false;
                    break;
                }
            }

            if (isMissing) {
                glAccountsToRemove.add(previousSelectedGLAccountIds[i]);
                elemToRemove.add(i);
            }
        }

        for (Integer i = elemToRemove.size() - 1; i >= 0; i--) {
            previousSelectedGLAccountIds.remove(elemToRemove[i]);
        }

        for (Id elem : selectedGLAccountIds) {
            Boolean isAlreadyPresent = false;

            for (Id prevSelElem : previousSelectedGLAccountIds) {
                if (prevSelElem == elem) {
                    isAlreadyPresent = true;
                    break;
                }
            }

            if (!isAlreadyPresent) {
                glAccountsToAdd.add(elem);
            }
        }

        try {
            addLedgerEntries(glAccountsToAdd);
            removeLedgerEntries(glAccountsToRemove);

            saveSelectedExpensesSuccess = 'true';
        }
        catch (DmlException e) {
            System.debug(e);

            saveSelectedExpensesSuccess = 'false';
        }
    }

    public void getRelatedExpenses() {
        List<LedgerEntry__c> expenses = [SELECT GLAccount__c,
                                                OfferRate__c,
                                                InHouseRate__c,
                                                (SELECT OfferRate__c,
                                                        InHouseRate__c
                                                 FROM LedgerEntryBreakouts__r)
                                         FROM LedgerEntry__c
                                         WHERE RecordTypeId IN (:RT_EXPENSES_ID) AND Event__c = :eventId];

        if (expenses.size() > 0) {
            List<LedgerEntryWrapper> ledgers = new List<LedgerEntryWrapper>();
            

            for (LedgerEntry__c entry : expenses) {
                previousSelectedGLAccountIds.add(entry.GLAccount__c);
                ledgers.add(new LedgerEntryWrapper(entry));
            }

            previousSelectedEntriesJson = System.JSON.serialize(ledgers);
        } else {
            previousSelectedEntriesJson = '[]';
        }
    }

    public class LedgerEntryWrapper {
        public LedgerEntry__c ledger {get;set;}
        public Boolean disableSelection {get;set;}

        public LedgerEntryWrapper(LedgerEntry__c l) {
            this.ledger = l;
            disableSelection = false;

            for (LedgerEntryBreakout__c b : ledger.LedgerEntryBreakouts__r) {
                if ((b.OfferRate__c != null && b.OfferRate__c != 0) || (b.InHouseRate__c != null && b.InHouseRate__c != 0)) {
                    disableSelection = true;
                    break;
                }
            }

            if ((ledger.OfferRate__c != null && ledger.OfferRate__c != 0) || (ledger.InHouseRate__c != null && ledger.InHouseRate__c != 0)) {
                disableSelection = true;
            }
        }
    }
}