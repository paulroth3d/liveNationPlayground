/**
 *  Scheduler for the LNE_TBDCountUpdateClass_Batch
 *  
 *  LNE_TBDCountUpdateClass_BatchSchedule b = new LNE_TBDCountUpdateClass_BatchSchedule();
 *  System.Schedule(LNE_TBDCountUpdateClass_BatchSchedule.JOB_NAME, LNE_TBDCountUpdateClass_BatchSchedule.DEFAULT_SCHEDULE, b);
 *  
 *  @author Henry Akpala <hakpala@salesforce.com>
**/ 
    global class LNE_TBDCountUpdateClass_BatchSchedule implements Schedulable {
    
    
    global Date myDate = Date.today();
    global Integer intYear = myDate.Year();
    global String TBDEvents = 'TBDEvents';
    global String  PendingLikely = 'Pending Likely' ;
    global String Confirmed ='Confirmed';
    global String FillerShow ='Filler Show';
    global String Year = String.valueof(intYear) ;
   
    /** Time when the job should execute **/
    global static String DEFAULT_SCHEDULE = '0 5 3 * * ?'; //TODO set based on boomi job run.
    
    /** Name of the Scheduled Job **/
    global static String JOB_NAME = 'TBDConfirmCountUpdate';
    
    global void execute(SchedulableContext sc) {
        
        String q = 'SELECT Id, Venue__c, TBDConfirmedCount__c,TBDMonth__c, TBDYear__c, TBDVenue__c, TBDMonthValue__c, TBDYearValue__c, EventLastDate__c from Event__c WHERE  RecordTypeName__c!=:TBDEvents  AND SubType__c!=:FillerShow AND TBDVenue__c=True AND TBDMonthValue__c != null AND  TBDYearValue__c =: Year AND (Status__c  =: PendingLikely  OR Status__c  =:Confirmed) ';
        LNE_TBDCountUpdateClass_Batch confirmCountBatch = new LNE_TBDCountUpdateClass_Batch(q);
        Database.executeBatch(confirmCountBatch);
    }
}