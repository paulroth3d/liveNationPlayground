/**
 * Scheduler for the LNE_UserOfficeAccessBatch.
 * This assigns the list of offices that a user is associated with (used in Event__c and sub object security)
 * 
 * LNE_UserOfficeAccessBatchSchedule b = new LNE_UserOfficeAccessBatchSchedule();
 * System.Schedule( LNE_UserOfficeAccessBatchSchedule.JOB_NAME, LNE_UserOfficeAccessBatchSchedule.DEFAULT_SCHEDULE, b );
 * 
 * @author Daniel Nakonieczny (dnakonieczny@salesforce.com);
 * 
 **/
global class LNE_UserOfficeAccessBatchSchedule implements Schedulable {
	
	global static String DEFAULT_SCHEDULE = '0 0 2 ? * 1,2,3,4,5,6,7';
	
	global static String JOB_NAME = 'Office User Access Batch';
	
	global void execute(SchedulableContext ctx) {
		LNE_UserOfficeAccessBatch b = new LNE_UserOfficeAccessBatch();
		Database.executeBatch(b, 1);
	}   
}