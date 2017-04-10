/** 
 * <p>Assumes that the trigger will be run on a before update or before insert</p>
 *  @author Henry Akpala 
 *   
 **/
public class LNE_CatereaseEventStaging_T {
  
    
  /**
   *  Look for any existing LNE_CatereaseEventStaging__c records
   *  @param newList CatereaseEventStaging__c[]
   *  @param oldMap Map<Id,CatereaseEventStaging__c>
   *  @return CatereaseEventStaging__c[] - list of CatereaseEventStaging records.
  **/
  
    public static CatereaseEventStaging__c[] execute(List<CatereaseEventStaging__c> newList, Map<Id, CatereaseEventStaging__c> oldMap){
        if(newList.size()>0) {
            for (CatereaseEventStaging__c c : newList){
                    if (oldMap != null){
                        CatereaseEventStaging__c ces = oldMap.get(c.Id);
                        Integer agst = Integer.valueOf(c.actguests__c);
                        
                        //Integer ggst = Integer.valueOf(c.gtdguests__c);
                        //Integer pgst = Integer.valueOf(c.plnguests__c);
                        
                        c.actguests__c = (agst == 0 && ces.actguests__c!=0) ? c.actguests__c : ces.actguests__c;
                        /*   
                            if(c.actguests__c!=0 && ces.actguests__c==0){}
                            if(c.gtdguests__c!=0 && ces.gtdguests__c==0){}
                            if(c.plnguests__c!=0 && ces.plnguests__c==0){} 
                        
                        if (c.Status__c =='Cancelled'){
                        
                                                   
                        }   
                         */                
                    }   
            
            }
       }
       return newList;
    }
}

/*
actguests__c != 0 
gtdguests__c
plnguests__c 
*/