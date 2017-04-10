/**
 *  Scheduler for the LNE_AccountTermsUpdated_Batch
 *  
 *  LNE_AccountTermsUpdated_BatchSchedule b = new LNE_AccountTermsUpdated_BatchSchedule();
 *  System.Schedule( LNE_AccountTermsUpdated_BatchSchedule.JOB_NAME, LNE_AccountTermsUpdated_BatchSchedule.DEFAULT_SCHEDULE, b );
 *  
 *  @author Paul Roth <proth@salesforce.com>
**/
global class LNE_AccountTermsUpdated_BatchSchedule
    implements Schedulable
{
    
    /** Time when the job should execute **/
    global static String DEFAULT_SCHEDULE = '0 0 3 * * ?';
    
    /** Name of the Scheduled Job **/
    global static String JOB_NAME = 'GlobalTermsUpdateNotification';
    
    global void execute( SchedulableContext sc ){
        LNE_AccountTermsUpdated_Batch b = new LNE_AccountTermsUpdated_Batch();
        database.executeBatch(b);
    }
}