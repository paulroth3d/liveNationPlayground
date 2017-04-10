/** 
 *	Batch to automatically remove any Notification records that are old than the allowed age.
 *  <p>Age Limit is defined in GeneralSettings__c.NotificationAgeLimit__c</p>
 *  <p>
 *  LNE_EventAlertsRemoval_Batch b = new LNE_EventAlertsRemoval_Batch();
 *  System.Schedule( LNE_EventAlertsRemoval_Batch.DEFAULT_JOB_NAME, LNE_EventAlertsRemoval_Batch.DEFAULT_SCHEDULE, b );
 *  </p>
 *	@author Scott Will
 *  @group Batch
 **/
global with sharing class LNE_EventAlertsRemoval_Batch implements Database.Batchable<SObject>, Schedulable {
	
	/** default name for the job **/
	public static final String DEFAULT_JOB_NAME = 'LNE_EventAlertsRemoval_Batch';
	
	/** default schedule for running the job **/
	public static final String DEFAULT_SCHEDULE = '0 0 0 * * ?';

	private final static String QUERY = 'select Id from Notification__c where CreatedDate < :AGE_LIMIT';
	private final static DateTime AGE_LIMIT;

	static {

		GeneralSettings__c settings = GeneralSettings__c.getInstance();
		Integer maxAge = settings.NotificationAgeLimit__c.intValue();
    	// set the age limit as today - max number of days
    	AGE_LIMIT = System.now().addDays(-maxAge);

	}
	
	public LNE_EventAlertsRemoval_Batch() {}

	global Database.QueryLocator start( Database.BatchableContext context ){
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext context, List<SObject> scope) {
    	// just need to remove
    	Database.delete(scope, false);
    }

    global void finish(Database.BatchableContext context) {
    	// nothing to do, required for implements Database.Batchable<SObject>
    }

	global void execute(SchedulableContext sc) {
		// schedule will execute batch @2000 scope
		Database.executeBatch(this, 2000);
	}

}