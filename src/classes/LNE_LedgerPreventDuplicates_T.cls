/** 
 *  Trigger logic to check for existing LedgerEntry__c with the same UniqueEventLedgerKey__c
 *  <p>Assumes that the trigger will be run on a before update or before insert</p>
 *  @author Dominic Aveyard <daveyard@salesforce.com>
 **/
public class LNE_LedgerPreventDuplicates_T {
  
    
  /**
   *  Look for any existing LedgerEntry__c records
   *  @param newList LedgerEntry__c[]
   *  @param oldMap Map<Id,LedgerEntry__c>
   *  @return LedgerEntry__c[] - list of ledger entries updated.
   *  @assumption - we are only calling this from inserts
  **/
    
    public static LedgerEntry__c[] execute( LedgerEntry__c[] newList, Map<Id,LedgerEntry__c> oldMap ){
        
        LedgerEntry__c[] results = new LedgerEntry__c[]{};
        String RT_Ancillary = 'LedgerEntry__c.Ancillary';

        if ( newList == null || newList.size() == 0){    //short circuit evaulation of empty input
            //return empty list for empty input
            return( results );
        }

        //-- find the record types we need.
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
            new String[]{ RT_Ancillary }
        );
        Id RT_Ancillary_ID = recordTypeMap.get( RT_Ancillary );
        
        Set<String> proposedLedgerKeys = new Set<String> {};
        for ( LedgerEntry__c newEntry : newList ){
            if (newEntry.RecordTypeId == RT_Ancillary_ID) {
                proposedLedgerKeys.add(newEntry.UniqueEventLedgerKey__c);
            }
        }
        
        //-- Check database for existing records that have the same UniqueEventLedgerKey__c and RecordType = RT_Ancillary
        List<LedgerEntry__c> existingEntries = [
            SELECT Id, UniqueEventLedgerKey__c, RecordTypeId 
            FROM LedgerEntry__c 
            WHERE UniqueEventLedgerKey__c IN :proposedLedgerKeys
            and RecordTypeId = :RT_Ancillary_ID
        ];
        
        //-- add to the set of existing UniqueEventLedgerKey__c for easy comparison
        Set<String> existingLedgerKeys = new Set<String> {};
        for ( LedgerEntry__c exist : existingEntries ) {
            if (!existingLedgerKeys.contains(exist.UniqueEventLedgerKey__c)) {
                existingLedgerKeys.add(exist.UniqueEventLedgerKey__c);
            }
        }
        
        //-- Go through each new entry and add an error to the object if a LedgerEntry__c record already has same UniqueEventLedgerKey__c
        for ( LedgerEntry__c newEntry : newList ) {
            if (existingLedgerKeys.contains(newEntry.UniqueEventLedgerKey__c)) {
                newEntry.addError('Duplicate Ledger Entry is not allowed'); 
                //add ledger entry updated to result
                results.add(newEntry); 
            }
        }
        
        return ( results );
    }
    
}