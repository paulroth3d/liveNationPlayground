/**
 *  Router for all Accounts triggers.
 *  @author 
 **/
trigger LNE_CatereaseFinanceStaging on CatereaseFinanceStaging__c (before insert, before update, before delete, after insert, after update, after delete) {
      
   if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
   }
   
   if( Trigger.isBefore ){
        if(  Trigger.isUpdate ){
           LNE_CatereaseFinanceStaging_T.check(Trigger.new, Trigger.oldMap);
        } else if( Trigger.isInsert ){
           LNE_CatereaseFinanceStaging_T.execute(Trigger.new, Trigger.oldMap);
        }        
    }
    
    
 }