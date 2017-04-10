/**
 * This invokes the LNE_FinancialCalculator class to run the calulator for the
 * events return in the query below
 * 
 * String q = 'SELECT Id FROM Event__c WHERE batchFlag__c=False';
 *
 * @author Henry Akpala (hakpala@salesforce.com);
 * 
 **/
 
 global class LNE_RunCalculations_Batch implements Database.Batchable<SObject>{
   global final String Query;
   global final String Entity;
   global final String Field;
   global final String Value;
   
     /* script to call the batch class from an Ananymous block
        //String q = 'SELECT Id FROM Event__c WHERE batchFlag__c=False';
   		// Id batchInstanceId = Database.executeBatch(new LNE_RunCalculations_Batch(q)); 
     */
   
   global LNE_RunCalculations_Batch(String q){
             Query=q;    
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       try{
            Set<Id> Ids = new Map<Id, sObject>(scope).keySet();
            LNE_FinancialCalculator.addEventIdSet(Ids);
            LNE_FinancialCalculator.checkIfCanRunCalculations();
            List<Event__c> evt = [SELECT batchFlag__c from Event__c where Id=:Ids];
            //update the events that were process successfully
            for (Event__c a : evt){
                a.BatchFlag__c = true;
            }
            Database.update(evt);            
       }catch(exception e){
           
       }
   }

   global void finish(Database.BatchableContext BC){
        
   }
}