/**
 *  Scheduler for the LNE_RunCatereaseCalculator_Batch
 *  
 *  LNE_RunCatereaseCalculator_BatchSchedule b = new LNE_RunCatereaseCalculator_BatchSchedule();
 *  System.Schedule(LNE_RunCatereaseCalculator_BatchSchedule.JOB_NAME, LNE_RunCatereaseCalculator_BatchSchedule.DEFAULT_SCHEDULE, b);
 *  
 *  @author Henry Akpala <hakpala@salesforce.com>
**/
global class LNE_RunCatereaseCalculator_BatchSchedule implements Schedulable {
    
    /** Time when the job should execute **/
    global static String DEFAULT_SCHEDULE = '0 5 3 * * ?'; //TODO set based on boomi job run.
    
    /** Name of the Scheduled Job **/
    global static String JOB_NAME = 'CatereaseFinancialCalculatorBatch';
    
    global void execute(SchedulableContext sc) {
        Date todayDate = Date.today()  ;
        String q1 = 'SELECT Id from  Event__c WHERE  CatereaseProcessDate__c >:todayDate';
        LNE_RunCatereaseCalculator_Batch catereaseCalculateBatch = new LNE_RunCatereaseCalculator_Batch(q1);
        Database.executeBatch(catereaseCalculateBatch);
    }
}