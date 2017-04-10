/** 
 *  Batch Class that finds/populates PreviousEventInMarket__c on Event records 
 *  
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 *	To Run:
 *	Database.executeBatch(new LNE_FindPreviousEventInMarketBatch(), LNE_FindPreviousEventInMarketBatch.BATCH_SIZE);
 **/
public without sharing class LNE_FindPreviousEventInMarketBatch implements Database.Batchable<sObject> {
	public static final Integer BATCH_SIZE = 1;

	public Database.QueryLocator start(Database.BatchableContext context) {
		Set<String> statuses = new Set<String>{'Draft', 'Pending Unlikely', 'Pending Likely', 'Cancelled', 'Postponed'};
        return(Database.getQueryLocator([SELECT EventFirstDate__c, Market__c FROM Event__c WHERE Status__c IN :statuses AND EventLastDate__c > TODAY]));
    }

    public void execute(Database.BatchableContext context, List<sObject> scope) {
    	LNE_FinancialCalculator.runUpdates = false;

		Set<String> statusesForVenueChanged = new Set<String>{'Draft', 'Pending Unlikely', 'Pending Likely', 'Cancelled', 'Postponed'};
		
		List<Event__c> toUpdate = LNE_EventMetrics_T.findPreviousEvent([SELECT EventFirstDate__c, Market__c FROM Event__c WHERE Id IN :scope AND Status__c IN :statusesForVenueChanged]);
		
		if (toUpdate != null && toUpdate.size() > 0) {
			update toUpdate;
		}
    }

    public void finish(Database.BatchableContext context) {}
}