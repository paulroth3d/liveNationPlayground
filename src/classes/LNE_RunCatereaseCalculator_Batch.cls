/**
 * This invokes the LNE_FinancialCalculator class to run the Calculator for the
 * events created by the Caterease Integration process
 * 
 * String q = 'select  Id from Event__c where CatereaseProcessDate__c  >:TODAY';
 *
 * @author Henry Akpala (hakpala@salesforce.com);
 * 
 **/
 
 global class LNE_RunCatereaseCalculator_Batch implements Database.Batchable<SObject>{
   global final String Query;
   global final String Field;
   global final String Value;
   global Date todayDate = Date.today()  ;
     
   /* script to call the batch class from an Ananymous block
       //String q = 'select  Id from Event__c where CatereaseProcessDate__c  >:todayDate';
       // Id batchInstanceId = Database.executeBatch(new LNE_RunCatereaseCalculator_Batch(q)); 
   */
   global LNE_RunCatereaseCalculator_Batch(String q){
              //String q = 'select  Id from Event__c where CatereaseProcessDate__c  >:todayDate';
              Query=q;                
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       
            Set<Id> Ids = new Map<Id, sObject>(scope).keySet();
            LNE_FinancialCalculator.addEventIdSet(Ids);
            LNE_FinancialCalculator.checkIfCanRunCalculations();
   }

   global void finish(Database.BatchableContext BC){
        
   }

}