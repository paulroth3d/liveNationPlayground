/**
 * 
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LNE_CatereaseFinanceStaging_T_Test{

    @isTest
    public static void testValidateExecute(){

        CatereaseEventStaging__c evt ;
        CatereaseFinanceStaging__c cFS;
      
       
         evt = new CatereaseEventStaging__c(Location__c='LN - Atlanta',EvtNum__c= '1695',EventNum__c= 'AT01695',PartyName__c='Brightree MEDTRADE 2017 Convention Party',SalesRep__c= 'Karyn Kotler',SalesRepEmail__c='karynkotler@livenation.com', Operation__c= 'Tabernacle',Status__c= 'Cancelled',total__c= 47850.00,cost__c= 12321.00,profit__c= 35529.00,plnguests__c= 400,actguests__c= 0,gtdguests__c= 400,final__c=false);          
         list<CatereaseFinanceStaging__c> lstCFS = new list<CatereaseFinanceStaging__c>();
         Map<Id, CatereaseFinanceStaging__c> oldMap ;           
         
         LNE_CatereaseFinanceStaging_T.check(lstCFS, oldMap);                                                                   
                                                              
            insert evt;    
             
            cFS= new CatereaseFinanceStaging__c(EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='40223',TotalPrice__c=28150,TotalCost__c=-6486, BoomiState__c=0);
            
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='40267',TotalPrice__c=19700,TotalCost__c=0, BoomiState__c=0);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='40270',TotalPrice__c=0,TotalCost__c=2500, BoomiState__c=0);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='40276',TotalPrice__c=0,TotalCost__c=160, BoomiState__c=0);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='50341',TotalPrice__c=0,TotalCost__c=1584, BoomiState__c=0);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='50342',TotalPrice__c=0,TotalCost__c=1500, BoomiState__c=0);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='50343',TotalPrice__c=0,TotalCost__c=1299.2, BoomiState__c=0);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='50344',TotalPrice__c=0,TotalCost__c=2988.8, BoomiState__c=0);
            lstCFS.add(cFS);
            insert lstCFS;
                             


        List<CatereaseFinanceStaging__c> newList = LNE_CatereaseFinanceStaging_T.execute(lstCFS, oldMap);
        
        Map<Id, CatereaseFinanceStaging__c> historyMap = new Map<Id, CatereaseFinanceStaging__c>();
        for(CatereaseFinanceStaging__c oh : newList)
        {
             historyMap.put(oh.EventStagingID__c, oh);
        }
        
        /* Update Staging Record */
            cFS= new CatereaseFinanceStaging__c(EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='40223',TotalPrice__c=28150,TotalCost__c=-6486, BoomiState__c=0);
            insert cFS;
            lstCFS.add(cFS);
            cFS.BoomiState__c = 1;
            update cFS;
            String cFSId = cFS.Id;
            LNE_CatereaseFinanceStaging_T.check(lstCFS, historyMap);
            
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='52222',TotalPrice__c=0,TotalCost__c=8775, BoomiState__c=0);
            lstCFS.add(cFS);
            Upsert lstCFS;
            historyMap = new Map<Id, CatereaseFinanceStaging__c>();
            for(CatereaseFinanceStaging__c oh : newList)
            {
                 historyMap.put(oh.EventStagingID__c, oh);
            }
        
            LNE_CatereaseFinanceStaging_T.check(lstCFS, historyMap);
             
             
        //System.assert(, '');
    }
    
    @isTest
    public static void testInvalidateExecute(){

        CatereaseEventStaging__c evt ;
        CatereaseFinanceStaging__c cFS;
      
       
         evt = new CatereaseEventStaging__c(Location__c='LN - Atlanta',EvtNum__c= '1695',EventNum__c= 'AT01695',PartyName__c='Brightree MEDTRADE 2017 Convention Party',SalesRep__c= 'Karyn Kotler',SalesRepEmail__c='karynkotler@livenation.com', Operation__c= 'Tabernacle',Status__c= 'Cancelled',total__c= 27850.00,cost__c= 11321.00,profit__c= 55529.00,plnguests__c= 400,actguests__c= 0,gtdguests__c= 400,final__c=false);          
         list<CatereaseFinanceStaging__c> lstCFS = new list<CatereaseFinanceStaging__c>();
         Map<Id, CatereaseFinanceStaging__c> oldMap ;           
         
         LNE_CatereaseFinanceStaging_T.execute(lstCFS, oldMap);                                                                   
                                                              
  
                                                                            
                                                              
            insert evt;    
             
            cFS= new CatereaseFinanceStaging__c(EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='0',TotalPrice__c=28150,TotalCost__c=-6486);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='40267',TotalPrice__c=19700,TotalCost__c=0);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='40270',TotalPrice__c=0,TotalCost__c=2500);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='40276',TotalPrice__c=0,TotalCost__c=160);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='50341',TotalPrice__c=0,TotalCost__c=1584);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='50342',TotalPrice__c=0,TotalCost__c=1500);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='50343',TotalPrice__c=0,TotalCost__c=1299.2);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='50344',TotalPrice__c=0,TotalCost__c=2988.8);
            lstCFS.add(cFS);
            cFS = new CatereaseFinanceStaging__c( EventStagingID__c= evt.Id,LocationName__c='LN - Atlanta',EvtNum__c='1695',AcctCode__c='50370',TotalPrice__c=0,TotalCost__c=8775);
            lstCFS.add(cFS);
            insert lstCFS;
                             

        
        LNE_CatereaseFinanceStaging_T.execute(lstCFS, oldMap);
 
     }
}