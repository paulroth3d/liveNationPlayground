/**
 *  Scheduler for the LNE_PurchaseURL_Batch
 *  
 *  LNE_PurchaseURL_BatchSchedule b = new LNE_PurchaseURL_BatchSchedule();
 *  System.Schedule(LNE_PurchaseURL_BatchSchedule.JOB_NAME, LNE_PurchaseURL_BatchSchedule.DEFAULT_SCHEDULE, b);
 *  
 *  @author Phil Rymek <prymek@salesforce.com>
**/
global class LNE_PurchaseURL_BatchSchedule implements Schedulable {
    
    /** Time when the job should execute **/
    global static String DEFAULT_SCHEDULE = '0 5 3 * * ?';
    
    /** Name of the Scheduled Job **/
    global static String JOB_NAME = 'UpdateEventPurchaseURL';
    
    global void execute(SchedulableContext sc) {
        LNE_PurchaseURL_Batch purchaseBatch = new LNE_PurchaseURL_Batch();
        Database.executeBatch(purchaseBatch);
    }
}