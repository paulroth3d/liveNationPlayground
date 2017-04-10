/** 
 *  Trigger logic to rollup the Contra at Forecast for all Ancillary Ledger Entries that have the same GL Account.Related Contra
 *  <p>Assumes that the trigger will be run on an after update, after insert or after delete</p>
 *  @author Anubhav Gupta <agupta2733@altimetrik.com>
 **/
public class LNE_RollupContraForecast_T {    

  /**
   *  Create/ Update a Child shadow Ledger Entry Breakout Record when Ancillary Ledger Entry is created/ updated
   *  @param newLedgerEntries List<LedgerEntry__c>
   *  @param oldLedgerEntries List<LedgerEntry__c>  
   *  @return void
  **/
    
    public static void execute( List<LedgerEntry__c> newLedgerEntries, Map<Id,LedgerEntry__c> oldLedgerEntries){
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'LedgerEntry__c.Ancillary', 'LedgerEntry__c.Contra'});         
        Id RT_LEDGER_ENTRY_ANCILLARY = recordTypeMap.get( 'LedgerEntry__c.Ancillary' );  //recordtypeid for ancillary ledger entry        
        Id RT_LEDGER_ENTRY_CONTRA = recordTypeMap.get( 'LedgerEntry__c.Contra' );    //recordtypeid for contra ledger entry 
        String COMBINED_KEY_DELIMITER  = DataGenerationSettings__c.getOrgDefaults().CombinedKeyDelimiter__c;    
        List<LedgerEntry__c> validLedgerEntries = new List<LedgerEntry__c>();       
        Map<Id, Id> ledgerContraGLMap = new Map<Id, Id>();
        Map<Id, List<LedgerEntry__c>> contraGLLedgerMap = new Map<Id, List<LedgerEntry__c>>();
        Set<Id> eventIdSet = new Set<Id>();
        List<LedgerEntry__c> contraLedgerEntries = new List<LedgerEntry__c>();
        Map<String, LedgerEntry__c> lEntryToUpsert = new Map<String, LedgerEntry__c>();
        List<LedgerEntryBreakout__c> lEBreakoutToUpsert = new List<LedgerEntryBreakout__c>();
        
        List<LedgerEntry__c> validLedgerEntriesDelete = new List<LedgerEntry__c>();
        Set<String> externalIdLEBreakout = new Set<String>();
        List<LedgerEntryBreakout__c> lEBreakoutToDelete = new List<LedgerEntryBreakout__c>();
        Set<Id> ledgerEntryRollup = new Set<Id>();
        List<LedgerEntry__c> ledgerEntryRollupCheck = new List<LedgerEntry__c>();
        List<LedgerEntry__c> ledgerEntryToDelete = new List<LedgerEntry__c>();
        
        
        List<LedgerEntry__c> newLedgerEntriesInsert = [Select Id, recordtypeId, Event__c, GLAccount__c, GLAccount__r.RelatedContra__c,ContraAtForecast__c, GLAccountRelatedContra__c
                                                      ,RollUpCount__c, ExternalId__c, RateType__c, BaseAmount__c from LedgerEntry__c where id in :newLedgerEntries];
                                                      

        //List<LedgerEntry__c> newLedgerEntriesInsert = newLedgerEntries;                                       
        //filtering the ledger entries based on Contra at Forecast
        if(oldLedgerEntries != null && !oldLedgerEntries.isEmpty()){
            for(LedgerEntry__c nLedger : newLedgerEntriesInsert){
                LedgerEntry__c nLedgerold = oldLedgerEntries.get(nLedger.Id);
                if((nLedger.recordtypeId == RT_LEDGER_ENTRY_ANCILLARY) && (String.isNotBlank(nLedger.GLAccountRelatedContra__c))
                    &&(nLedger.ContraAtForecast__c != nLedgerOld.ContraAtForecast__c)){
                    
                    if((nLedger.ContraAtForecast__c != 0) && (nLedger.ContraAtForecast__c != null)){
                        validLedgerEntries.add(nLedger);        
                        System.debug('-- Valid for Rollup');
                    }
                    
                    else if((nLedger.ContraAtForecast__c == 0) || (nLedger.ContraAtForecast__c == null)){
                        validLedgerEntriesDelete.add(nLedger);    
                        System.debug('-- Valid for Delete');                
                    }
                    else{
                        System.debug('--Ledger Entry does not satisfy criteria');
                    }
                }
            }
        }
        else {
            for(LedgerEntry__c nLedger : newLedgerEntriesInsert){
                if((nLedger.recordtypeId == RT_LEDGER_ENTRY_ANCILLARY) && (String.isNotBlank(nLedger.GLAccountRelatedContra__c))){
                    
                    if((nLedger.ContraAtForecast__c != 0) && (nLedger.ContraAtForecast__c != null)){
                        validLedgerEntries.add(nLedger);        
                        System.debug('-- Valid for Rollup');
                    }

                    else{
                        System.debug('--Ledger Entry does not satisfy criteria');
                    }
                }
            }               
        }

        if(!validLedgerEntries.isEmpty()){
            for(LedgerEntry__c nLedger : validLedgerEntries){     
                if(!ledgerContraGLMap.containsKey(nLedger.Id)){
                    ledgerContraGLMap.put(nLedger.Id, nLedger.GLAccountRelatedContra__c);
                } 
                eventIdSet.add(nLedger.Event__c);   
            }
            System.debug('--ledgerContraGLMap ' + ledgerContraGLMap);
            System.debug('--ledgerContraGLMap.keyset() ' + ledgerContraGLMap.keyset());
            System.debug('--eventIdSet ' + eventIdSet);
            contraLedgerEntries = [Select Id, recordtypeId, Event__c, GLAccount__c,ContraAtForecast__c,ExternalId__c
                                  , RateType__c, BaseAmount__c from LedgerEntry__c where GLAccount__c in :ledgerContraGLMap.values()
                                  and recordtypeid = :RT_LEDGER_ENTRY_CONTRA and event__c in :eventIdSet];
            System.debug('--contraLedgerEntries '+ contraLedgerEntries);
            for(LedgerEntry__c nLedger : contraLedgerEntries){
                if(!contraGLLedgerMap.containsKey(nLedger.GLAccount__c)){
                    contraGLLedgerMap.put(nLedger.GLAccount__c, new List<LedgerEntry__c>{nLedger});
                }
                else {
                    if(!contraGLLedgerMap.get(nLedger.GLAccount__c).isEmpty()){
                        contraGLLedgerMap.get(nLedger.GLAccount__c).add(nLedger);   
                    }
                    else {
                        contraGLLedgerMap.put(nLedger.GLAccount__c, new List<LedgerEntry__c>{nLedger}); 
                    }   
                }   
            }
            System.debug('--contraGLLedgerMap ' + contraGLLedgerMap);
            System.debug('--contraGLLedgerMap.keyset() ' + contraGLLedgerMap.keyset());         
              
            for(LedgerEntry__c nLedger : validLedgerEntries){
                if(!contraGLLedgerMap.containsKey(ledgerContraGLMap.get(nLedger.Id))){
                    System.debug('-- Create a Contra Ledger Entry');
                    LedgerEntry__c lEntry = new LedgerEntry__c();
                    lEntry.recordTypeId = RT_LEDGER_ENTRY_CONTRA;
                    lEntry.event__c = nLedger.event__c;
                    lEntry.GLAccount__c = ledgerContraGLMap.get(nLedger.Id);
                    lEntry.ExternalId__c = String.valueOf(nLedger.Event__c) + COMBINED_KEY_DELIMITER +String.valueOf(ledgerContraGLMap.get(nLedger.Id));
                    //lEntry.ExternalId__c = String.valueOf(nLedger.Event__c) + String.valueOf(ledgerContraGLMap.get(nLedger.Id));
                    System.debug('--lEntry.ExternalId__c '+lEntry.ExternalId__c);
                    lEntry.RateType__c = 'Flat';
                    lEntry.BaseAmount__c = nLedger.BaseAmount__c;
                    lEntry.ContraAtForecast__c = nLedger.ContraAtForecast__c;
                    if(lEntryToUpsert.isEmpty()){
                        lEntryToUpsert.put(lEntry.ExternalId__c, lEntry);
                    }
                    else if(!lEntryToUpsert.containsKey(lEntry.ExternalId__c)){
                        lEntryToUpsert.put(lEntry.ExternalId__c, lEntry);       
                    }
                    System.debug('-- lEntryToUpsert '+lEntryToUpsert);
                }
            }    
            if(!lEntryToUpsert.isEmpty()){
                List<Database.UpsertResult> srList = Database.upsert(lEntryToUpsert.values(),ledgerEntry__c.Fields.externalid__c, false);    
                String errMessage;
                for(Database.UpsertResult sr:srList){
                    if(!sr.isSuccess()){
                        errMessage = sr.getErrors()[0].getMessage();
                    }
                    System.debug('--errMessage '+ errMessage);
                    System.debug('-- After Upsert');
                    }
            }  
            
            contraLedgerEntries = [Select Id, recordtypeId, Event__c, GLAccount__c,ContraAtForecast__c,ExternalId__c
                                  , RateType__c, BaseAmount__c from LedgerEntry__c where GLAccount__c in :ledgerContraGLMap.values()
                                  and recordtypeid = :RT_LEDGER_ENTRY_CONTRA and event__c in :eventIdSet];
            System.debug('--contraLedgerEntries '+ contraLedgerEntries);                                  
            contraGLLedgerMap.clear();
            for(LedgerEntry__c nLedger : contraLedgerEntries){
                if(!contraGLLedgerMap.containsKey(nLedger.GLAccount__c)){
                    contraGLLedgerMap.put(nLedger.GLAccount__c, new List<LedgerEntry__c>{nLedger});
                }
                else {
                    if(!contraGLLedgerMap.get(nLedger.GLAccount__c).isEmpty()){
                        contraGLLedgerMap.get(nLedger.GLAccount__c).add(nLedger);   
                    }
                    else {
                        contraGLLedgerMap.put(nLedger.GLAccount__c, new List<LedgerEntry__c>{nLedger}); 
                    }   
                }               
            }  
            
            System.debug('--contraGLLedgerMap ' + contraGLLedgerMap);
            System.debug('--contraGLLedgerMap.keyset() ' + contraGLLedgerMap.keyset());             

            for(LedgerEntry__c nLedger : validLedgerEntries){
                LedgerEntryBreakout__c lEBreakout = new LedgerEntryBreakout__c();     
                lEBreakout.ExternalId__c = String.valueOf(nLedger.Event__c) + COMBINED_KEY_DELIMITER  + String.valueOf(nLedger.GLAccount__c);  
                //lEBreakout.ExternalId__c = String.valueOf(nLedger.Event__c) + String.valueOf(nLedger.GLAccount__c); 
                List<LedgerEntry__c> ledgerEntryContra = contraGLLedgerMap.get(ledgerContraGLMap.get(nLedger.Id)); 
                if(ledgerEntryContra!= null){
                    for(LedgerEntry__c lEntryContra : ledgerEntryContra){
                        if(lEntryContra.event__c == nLedger.event__c){
                            lEBreakout.LedgerEntry__c =  lEntryContra.Id;
                        }   
                    }
                }
                lEBreakout.RateType__c = 'Flat';
                lEBreakout.BaseAmount__c = nLedger.BaseAmount__c;                
                lEBreakout.ContraAtForecast__c =  nLedger.ContraAtForecast__c; 
                lEBreakoutToUpsert.add(lEBreakout);
            }  
            if(!lEBreakoutToUpsert.isEmpty()){
                list<Database.UpsertResult> srList = Database.upsert(lEBreakoutToUpsert, ledgerEntryBreakout__c.Fields.externalid__c,false);    
                String errMessage;
                for(Database.UpsertResult sr:srList){
                    if(!sr.isSuccess()){
                        errMessage = sr.getErrors()[0].getMessage();
                    }
                    System.debug('--errMessage '+ errMessage);
                    System.debug('-- After Ledger Entry Breakout Upsert');
                    }           
                    
            }                 
        }

        if(!validLedgerEntriesDelete.isEmpty()){
            for(LedgerEntry__c nLedger : validLedgerEntriesDelete){
                String extId = String.valueOf(nLedger.Event__c)  + COMBINED_KEY_DELIMITER  + String.valueOf(nLedger.GLAccount__c);
                //String extId = String.valueOf(nLedger.Event__c) + String.valueOf(nLedger.GLAccount__c);
                System.debug('--extId '+extId);
                externalIdLEBreakout.add(extId);
            }
            System.debug('--externalIdLEBreakout '+externalIdLEBreakout);
            lEBreakoutToDelete = [Select Id, ledgerEntry__c, externalId__c from ledgerEntrybreakout__c where externalId__c in :externalIdLEBreakout];
            System.debug('--lEBreakoutToDelete '+lEBreakoutToDelete);
            if(!lEBreakoutToDelete.isEmpty()){
                Database.delete(lEBreakoutToDelete, false); 
                for(ledgerEntrybreakout__c lEBreakout : lEBreakoutToDelete){
                    ledgerEntryRollup.add(lEBreakout.ledgerEntry__c);
                }
                System.debug('--ledgerEntryRollup '+ledgerEntryRollup);
                ledgerEntryRollupCheck = [Select id, RollUpCount__c from ledgerEntry__c where id in :ledgerEntryRollup];
                for(LedgerEntry__c nLedger : ledgerEntryRollupCheck){
                    if(nLedger.RollUpCount__c == 0){
                        ledgerEntryToDelete.add(nLedger);
                    }
                }
                System.debug('--ledgerEntryToDelete '+ledgerEntryToDelete);
                if(!ledgerEntryToDelete.isEmpty()){
                    Database.delete(ledgerEntryToDelete, false);    
                }
            }
        }   

    }
    
    
  /**
   *  Delete the Child Shadow Ledger Entry Breakout record when the Ancillary Ledger Entry is deleted
   *  @param oldLedgerEntries List<LedgerEntry__c>
   *  @return void
  **/   
    public static void executeDelete( List<LedgerEntry__c> oldLedgerEntries){
        
        String COMBINED_KEY_DELIMITER  = DataGenerationSettings__c.getOrgDefaults().CombinedKeyDelimiter__c;
        Set<String> externalIdLEBreakout = new Set<String>();
        List<LedgerEntryBreakout__c> lEBreakoutToDelete = new List<LedgerEntryBreakout__c>();
        Set<Id> ledgerEntryRollup = new Set<Id>();
        List<LedgerEntry__c> ledgerEntryRollupCheck = new List<LedgerEntry__c>();
        List<LedgerEntry__c> ledgerEntryToDelete = new List<LedgerEntry__c>();  
        
         if(!oldLedgerEntries.isEmpty()){
            for(LedgerEntry__c nLedger : oldLedgerEntries){
                String extId = String.valueOf(nLedger.Event__c)  + COMBINED_KEY_DELIMITER  + String.valueOf(nLedger.GLAccount__c);
                //String extId = String.valueOf(nLedger.Event__c) + String.valueOf(nLedger.GLAccount__c);
                System.debug('--extId '+extId);
                externalIdLEBreakout.add(extId);
            }
            System.debug('--externalIdLEBreakout '+externalIdLEBreakout);
            lEBreakoutToDelete = [Select Id, ledgerEntry__c, externalId__c from ledgerEntrybreakout__c where externalId__c in :externalIdLEBreakout];
            System.debug('--lEBreakoutToDelete '+lEBreakoutToDelete);
            if(!lEBreakoutToDelete.isEmpty()){
                Database.delete(lEBreakoutToDelete, false); 
                for(ledgerEntrybreakout__c lEBreakout : lEBreakoutToDelete){
                    ledgerEntryRollup.add(lEBreakout.ledgerEntry__c);
                }
                System.debug('--ledgerEntryRollup '+ledgerEntryRollup);
                ledgerEntryRollupCheck = [Select id, RollUpCount__c from ledgerEntry__c where id in :ledgerEntryRollup];
                for(LedgerEntry__c nLedger : ledgerEntryRollupCheck){
                    if(nLedger.RollUpCount__c == 0){
                        ledgerEntryToDelete.add(nLedger);
                    }
                }
                System.debug('--ledgerEntryToDelete '+ledgerEntryToDelete);
                if(!ledgerEntryToDelete.isEmpty()){
                    Database.delete(ledgerEntryToDelete, false);    
                }
            }
        }       
    }
  
    
}