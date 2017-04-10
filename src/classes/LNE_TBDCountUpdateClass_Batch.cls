/**
 * This invokes the LNE_TBDCountUpdateClass class to get the count of all 
   confirmed count for all venues that are TBD related
 * 
 * @author Henry Akpala (hakpala@salesforce.com);
 * 
 **/
global class LNE_TBDCountUpdateClass_Batch implements Database.Batchable<SObject>{
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    global Date myDate = Date.today();
    global Integer intYear = myDate.Year();
    global String TBDEvents = 'TBDEvents';
    global String  PendingLikely = 'Pending Likely' ;
    global String Confirmed ='Confirmed';
    global String FillerShow ='Filler Show';
    global String Year = String.valueof(intYear) ;
    
    global LNE_TBDCountUpdateClass tbdCountUpdate = new LNE_TBDCountUpdateClass();
   
   global LNE_TBDCountUpdateClass_Batch(String q){
       //String q = 'SELECT Id, Venue__c, TBDConfirmedCount__c,TBDMonth__c, TBDYear__c, TBDVenue__c, TBDMonthValue__c, TBDYearValue__c, EventLastDate__c from Event__c WHERE  RecordTypeName__c!=:TBDEvents  AND SubType__c!=:FillerShow AND TBDVenue__c=True AND TBDMonthValue__c != null AND  TBDYearValue__c =: Year AND (Status__c  =: PendingLikely  OR Status__c  =:Confirmed) '
       Query =    q; 
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       
           LNE_TBDCountUpdateClass tbdCountUpdate = new LNE_TBDCountUpdateClass();
            tbdCountUpdate.TBDCountUpdateClass(scope);          
   }

   global void finish(Database.BatchableContext BC){
        
   }

}