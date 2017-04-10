/**
 *  Trigger logic to validate the finance totalPrice & totalCost against the 
 *  CatereaseEventStaging for mismatch.
 *  
 *  @author Henry Akpala
 **/
public class LNE_CatereaseFinanceStaging_T {

  /**
     *  Excute on after insert or after update
     *  @param newList CatereaseFinanceStaging__c[]
     *  @param oldMap Map<Id,CatereaseFinanceStaging__c>
     *  @return CatereaseFinanceStaging__c[] - list of CatereaseFinanceStaging__c updated and also update CatereaseEventStaging__c.
    **/
    
    public static CatereaseFinanceStaging__c[] check( CatereaseFinanceStaging__c[] newList, Map<Id,CatereaseFinanceStaging__c> oldMap ){
        CatereaseFinanceStaging__c[] results = new CatereaseFinanceStaging__c[]{};
        Boolean chkFlag = false;
            
        if( newList == null || newList.size() < 1 ){
             return( results );
        }else {
            
            for (CatereaseFinanceStaging__c c: newList){
               if( oldMap != null ){
                  
                    CatereaseFinanceStaging__c OldbState = oldMap.get(c.Id);
                    if(OldbState!= null){
                        Decimal OldboomiState = OldbState.BoomiState__c;
                        Decimal NewboomiState = c.BoomiState__c;
                        if( OldboomiState == 0 && (NewboomiState == 1 || NewboomiState == 2)){
                             chkFlag = true;
                         } 
                     }         
                }
            }
            
            System.debug(chkFlag);
            if (chkFlag)
                return newList;
            else {
                  
                  return LNE_CatereaseFinanceStaging_T.execute( newList, oldMap ) ;
              
            }
        }
        
    }
    
    
    /**
     *  Excute on after insert or after update
     *  @param newList CatereaseFinanceStaging__c[]
     *  @param oldMap Map<Id,CatereaseFinanceStaging__c>
     *  @return CatereaseFinanceStaging__c[] - list of CatereaseFinanceStaging__c updated and also update CatereaseEventStaging__c.
    **/
    
    public static CatereaseFinanceStaging__c[] execute( CatereaseFinanceStaging__c[] newList, Map<Id,CatereaseFinanceStaging__c> oldMap ){
      //  CatereaseFinanceStaging__c[] results = new CatereaseFinanceStaging__c[]{};
       //Check to make sure the list is not null or empty
        if( newList == null || newList.size() < 1 ){
              CatereaseFinanceStaging__c[] results = new CatereaseFinanceStaging__c[]{};
              return( results );
        }
         //TODO CHECK IF CHANGE IS INITIATED BY BOOMISTATE__C 
          
             Set<Id> evtSet = new  Set<Id> ();
              Set<Id> evtSetEF = new  Set<Id> ();
             
             for (CatereaseFinanceStaging__c c: newList){
                evtSet.add(c.EventStagingID__c);
                evtSetEF.add(c.Id);
             }
              List<CatereaseFinanceStaging__c> evtId = [SELECT Id, EventStagingID__c , AcctCode__c, TotalCost__c,TotalPrice__c, processstate__c  FROM CatereaseFinanceStaging__c WHERE Id IN :evtSetEF];
            
             //Set of valid Gl Codes.
             Set <String> gCd = new Set<String>{ '40223','40267','40270','40269','40271','40274','40275','40276','40277','40278','40268','40273','50341','50342','50343','50344','50370','50371','50372','50376','51121'};

             List<CatereaseEventStaging__c> evtAllId  = [SELECT EvtNum__c, FinTotalCost__c, FinTotalPrice__c , Profit__c , total__c, processmessage__c, (SELECT Id, AcctCode__c, TotalCost__c,TotalPrice__c, processstate__c  FROM CatereaseFinancesStaging__r) FROM CatereaseEventStaging__c Where Id IN  :  evtSet ];
             List<CatereaseFinanceStaging__c> evtF =new List<CatereaseFinanceStaging__c>();
             List<CatereaseEventStaging__c> evtUp =  new List<CatereaseEventStaging__c> ();
            
            for( CatereaseEventStaging__c e: evtAllId){
            
                List<CatereaseFinanceStaging__c> results = new  List<CatereaseFinanceStaging__c> ();
                for (CatereaseFinanceStaging__c s: newList){
                    if (e.Id == s.EventStagingID__c)
                        results.add(s);
                }
                if (results.size()>0){
                
                    evtF = results;
                    Decimal evtFP40 = 0;
                    Decimal evtFC40 = 0;
                    Decimal evtFC50 = 0;
                    Decimal evtFP50 = 0;
                    Decimal evtFPNull = 0.0;
                    Decimal evtFCNull = 0.0;
                    Boolean evtNull = false;
                    Boolean evtCd = false;
                    String errMsg = ' ';
            
                    CatereaseEventStaging__c c = new CatereaseEventStaging__c();
            
                    for(CatereaseFinanceStaging__c f : evtF){
            
                        String aCode = f.AcctCode__c;
                        String subCode;
                        Integer aCd = Integer.valueOf(aCode);
                        if(aCd > 0 ){
                            subCode= aCode.Substring(0,2)   ;
                            if(gCd.contains(aCode)){
                                    if(subCode == '40'){
                                        evtFC40 = evtFC40 +  f.TotalCost__c;
                                        evtFP40 = evtFP40 + f.TotalPrice__c;
                                    }else if (subCode =='50'){
                                        evtFC50 = evtFC50 + f.TotalCost__c;
                                        evtFP50 = evtFP50 + f.TotalPrice__c;
                                    }
                            }else {
                                errMsg = errMsg + ' Invalid GLCode: ' + aCode + '  TotalCost = ' +  f.TotalCost__c + '  TotalPrice = ' +  f.TotalPrice__c;
                                evtCd = true;
                            }
                        }else if ((aCd == 0) && (f.TotalPrice__c>0 ||  f.TotalCost__c > 0))  {
                             errMsg = errMsg + ' Invalid GLCode: ' + aCode + '  TotalCost = ' +  f.TotalCost__c + '  TotalPrice = ' +  f.TotalPrice__c;
                             evtCd = true;
                        }    
                    }//end  for(CatereaseFinanceStaging__c f : evtF)
                    
                    Decimal evtFPNull1= (evtFP40 - evtFC40) - (evtFC50 - evtFP50) ;
                    evtFPNull = evtFPNull1.setScale(2, System.RoundingMode.HALF_UP);
                    if( evtFPNull != e.Profit__c){ 
                        evtNull= true; 
                        errMsg = errMsg + ' : EvtNum: ' +  e.EvtNum__c + ' : Profit Mismatch: EventTotalProfit = ' +e.Profit__c + '   FinanceTotalProfit = ' + evtFPNull ;
                    }
                    if(evtNull || evtCd){
                        //System.debug(errMsg);
                        c.FinTotalPrice__c = evtFPNull;
                        c.Id = e.Id;
                        c.InvalidGLCode__c = evtCd;
                        c.ProfitMismatch__c = evtNull;
                        c.Processmessage__c = errMsg + ' | '  + c.Processmessage__c ;
                        evtUp.add(c);
                        c = new CatereaseEventStaging__c();
                    }else{
                    
                        for(CatereaseFinanceStaging__c f: newList){
                            if ((f.EventStagingID__c == e.Id) && (!Test.isRunningTest())){
                                    f.processstate__c = 1;
                            }    
                        }                       
                    }                
            }
            Database.update(evtUp);
            // if (!Test.isRunningTest())
              //  update evtId;
            
        }//end  for( CatereaseEventStaging__c e: evtAllId)     
        
        return newList;
    }

}