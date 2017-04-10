global with sharing class LNE_SettlementExpensesTab_CX {
	public String VIEW_CALCULATIONS = 'View Calculations';
	public String HIDE_CALCULATIONS = 'Hide Calculations';
	public String calculationsButtonValue {get;set;}
	private final SObject parent;

	public Event__c eventRecord {get;set;}

	global LNE_SettlementExpensesTab_CX(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        eventRecord = [SELECT SettlementStarted__c, AdvertisingBudget__c, AdvertisingSettlementPlan__c, NumberofTrucks__c 
                                FROM Event__c WHERE Id = :parent.Id];
        calculationsButtonValue = VIEW_CALCULATIONS;
    }

    global void startSettlement() {
        LNE_SettlementUtil.startSettlementProcess(eventRecord.Id);
    }

    global void showHideCalculations() {
    	if (calculationsButtonValue == VIEW_CALCULATIONS) {
    		calculationsButtonValue = HIDE_CALCULATIONS;
    	} else {
    		calculationsButtonValue = VIEW_CALCULATIONS;
    	}
    }
    
    @RemoteAction
    global static void defaultFees(String evtId) {
        LNE_LedgerEntryDefaultFees.defaultFees(evtId, LNE_LedgerEntryDefaultFees.FOR_SETTLEMENT_EXPENSES);
    }  

    @RemoteAction
    global static Boolean saveEvent(Id eventId, String advertisingsettlementplan) {
        Event__c updateEvent = new Event__c(Id=eventId, AdvertisingSettlementPlan__c=advertisingsettlementplan);

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