/**
 *  Trigger functionality to assign the external id / SourceSystemId.
 *  (Used mostly to support import and external system logic
 *  where the record must be updated by a loading script.)
 *  @author Paul Roth <proth@salesforce.com>
 *  @see US588 - see data load process for Deal Settlement Ledgers.
 **/
public class LNE_DealSettlementSSID {
	
	private static final String UNIQUE_DELIMITER = '-';
	
	/**
	 *  Updates a DealSettlementLedger record to have a source system id
	 *  once both the Ledger Entry and Deal are assigned.
	 *  @param newDSLs (DealSettlementLedger__c[])
	 *  @param oldDSL_Map (Map<Id,DealSettlementLedger__c>) - map of old assignments.
	 *  @return DealSettlementLedger__c[] - list of deal settlement ledgers that were updated.
	 *  @assumption - works on both insert and on update
	 **/
	public static DealSettlementLedger__c[] execute( DealSettlementLedger__c[] newDSLs, Map<Id,DealSettlementLedger__c> oldDSL_Map ){
		DealSettlementLedger__c[] results = new DealSettlementLedger__c[]{};
		DealSettlementLedger__c[] validDSLs = new DealSettlementLedger__c[]{};
		
		//-- @TODO: investigate whether the map is indeed needed.
		//Map<String,DealSettlementLedger__c> dslsByUniqueKey = new Map<String,DealSettlementLedger__c>();
		
		Map<Id,String> dealSourceSystemIdMap = new Map<Id,String>();
		Map<Id,String> ledgerSourceSystemIdMap = new Map<Id,String>();
		
		String uniqueKey;
		Boolean isValid = false;
		DealSettlementLedger__c oldDSL;
		for( DealSettlementLedger__c newDSL : newDSLs ){
			isValid = false;
			
			//-- only consider proceeding if both fields are filled and there is a change.
			if( oldDSL_Map != null && oldDSL_Map.containsKey( newDSL.Id )){
				oldDSL = oldDSL_Map.get( newDSL.Id );
				
				if(
					newDSL.LedgerEntry__c != null && newDSL.Deal__c != null &&
					( newDSL.LedgerEntry__c != oldDSL.LedgerEntry__c ) ||
					( newDSL.Deal__c != oldDSL.Deal__c )
				){
					//-- System.debug( 'DSL changed: ledgerEntry[' + newDSL.LedgerEntry__c + '] deal[' + newDSL.Deal__c + ']' );
					isValid = true;
				}
			} else if(
				newDSL.LedgerEntry__c != null &&
				newDSL.Deal__c != null
			){
				isValid = true;
			}
			
			if( isValid ){
				//uniqueKey = generateUniqueKey( newDSL.Deal__c, newDSL.LedgerEntry__c );
				//dslsByUniqueKey.put( uniqueKey, newDSL );
				validDSLs.add( newDSL );
				dealSourceSystemIdMap.put( newDSL.Deal__c, null );
				ledgerSourceSystemIdMap.put( newDSL.LedgerEntry__c, null );
			}
		}
		
		System.debug( 'before short circuit' );
		
		//-- short circuit
		if( validDSLs.size() < 1 ){
			return( results );
		}
		
		System.debug( 'after short circuit' );

		//-- @Invariant: we know at least one DealSettlementLedger__c has a deal and a ledger entry and has changed( either new or the assignment changed)
		
		//-- @Invariant - we have a list of all the deal and ledger entry Ids that need further info
		//-- @Invariant - we have a list of all dealsettlementledgers that have both deal and ledger entry
		//-- 	and have either been inserted or the deal or ledger entry assignments have changed
		//-- 	and a list of the deals and ledger entries that further info is required for.
		//--	because there is at least one record, and that record must have a deal and a ledger, there must be at least one deal and one ledger.
		
		Set<Id> affectedDealIds = dealSourceSystemIdMap.keySet();
		for( Deal__c deal : [
			SELECT id, SourceSystemId__c
			FROM Deal__c
			WHERE id IN :affectedDealIds
		]){
			dealSourceSystemIdMap.put( deal.Id, deal.SourceSystemId__c );
		}
		
		Set<id> affectedLedgerIds = ledgerSourceSystemIdMap.keySet();
		for( LedgerEntry__c ledger : [
			SELECT id, SourceSystemId__c
			FROM LedgerEntry__c
			WHERE id IN :affectedLedgerIds
		]){
			ledgerSourceSystemIdMap.put( ledger.Id, ledger.SourceSystemId__c );
		}
		
		//-- @Invariant: we know source system ids for all deals and ledger entries referenced.
		System.debug( 'dealSourceSystemIdMap' ); System.debug( dealSourceSystemidMap );
		System.debug( 'ledgerSourceSystemIdMap' ); System.debug( ledgerSourceSystemIdMap );
		
		String dealSourceSystemId;
		String ledgerSourceSystemId;
		for( DealSettlementLedger__c dslToUpdate : validDSLs ){
			
			//-- no need to check for whether they key exists, because we know it must have both keys to continue
			
			dealSourceSystemId = dealSourceSystemIdMap.get( dslToUpdate.Deal__c );
			ledgerSourceSystemId = ledgerSourceSystemIdMap.get( dslToUpdate.LedgerEntry__c );

			if (String.isNotBlank(dealSourceSystemId) && String.isNotBlank(ledgerSourceSystemId)) {
				uniqueKey = String.valueOf( '' + dealSourceSystemId + UNIQUE_DELIMITER + ledgerSourceSystemId );
				System.debug( 'unique key:' + uniqueKey );
				
				dslToUpdate.SourceSystemId__c = uniqueKey;
			} else {
				dslToUpdate.SourceSystemId__c = null;
			}
		}
		
		//-- we assume we are on trigger.isBefore. So no DML needed.
		//-- If needed after, just add upsert;
		System.debug( 'validDSLs' ); System.debug( validDSLs );
		
		results = validDSLs;
		
		return( results );
	}
}