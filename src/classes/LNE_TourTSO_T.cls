/**
 * Logic to apply tour specific expenses.
 * @see US220
 * @author Paul Roth <proth@salesforce.com>
 **/
public with sharing class LNE_TourTSO_T {
	
	/** the national touring allocation gl code **/
	public static final String TOUR_GL_CODE = '50360';
	
	private static ID TOUR_GL_CODE_ID;
	
	//-- lazy instantiation
	//-- if additional items are needed
	private static ID getTourGLCodeId(){
		if( TOUR_GL_CODE_ID == null ){
			refreshGLCodes();
		}
		return( TOUR_GL_CODE_ID );
	}
	
	/**
	 * Lazy instantiation of all gl codes
	 * to support test creation, etc.
	 * @INVARIANT: at the end of this method, all GL Code IDs must be populated.
	 **/
	private static void refreshGLCodes(){
		Map<String,GLAccount__c> glCodes = LNE_Util.getGLAccounts(
			new String[]{ TOUR_GL_CODE }
		);
		System.assert( glCodes.containsKey( TOUR_GL_CODE ), 'Tour Gl Code:' + TOUR_GL_CODE + ' must be found, but was not' );
		TOUR_GL_CODE_ID = glCodes.get( TOUR_GL_CODE ).Id;
	}
	
	/**
	 *  Updates the Tour Specific Overhead (TSO) for any tour
	 *  that has an event change association.
	 *  @param newList <Event__c[])
	 *  @param oldMap Map<Id,Event__c>
	 *  @return Tour__c[] - list of tours that were updated
	 **/
	public static Tour__c[] executeEventChanges( Event__c[] newList, Map<Id,Event__c> oldMap ){
		Tour__c[] results = null;
		
		//-- handle delete
		if( newList == null && oldMap != null ){
			newList = oldMap.values();
			oldMap = null;
		}
		
		Event__c oldEvent;
		set<Id> tourIds = new Set<Id>();
		for( Event__c newEvent : newList ){
			oldEvent = null;
			if( oldMap != null && oldMap.containsKey( newEvent.Id )){
				oldEvent = oldMap.get( newEvent.Id );
				if( oldEvent.Tour__c == newEvent.Tour__c ){
					//-- no change
					continue;
				}
			}
			
			if( newEvent.Tour__c != null ){
				tourIds.add( newEvent.Tour__c );
			}
			if( oldEvent != null && oldEvent.Tour__c != null ){
				tourIds.add( oldEvent.Tour__c );
			}
		}
		
		if( tourIds.size() > 0 ){
			results = updateTourTSO( tourIds );
		}
		
		return( results );
	}
	
	/**
	 *  Updates the Tour Specific Overhead (TSO) for any tour
	 *  that has a change on the TSO Ledger Entry.
	 *  @param newList <LedgerEntry__c[])
	 *  @param oldMap Map<Id,LedgerEntry__c>
	 *  @return Tour__c[] - list of tours that were updated
	 **/
	public static Tour__c[] executeLedgerChanges( LedgerEntry__c[] newList, Map<Id,LedgerEntry__c> oldMap ){
		Tour__c[] results = null;
		
		Boolean isDelete = false;
		
		Id tourGlAccountId = getTourGLCodeId();
		
		set<id> changedEventIds = new Set<Id>();
		
		if( newList == null ){
		    isDelete = true;
		    newList = oldMap.values();
		}
		
		LedgerEntry__c oldLedger;
		for( LedgerEntry__c newLedger : newList ){
			oldLedger = null;
			
			//-- bypass if not the tour gl code
			if( newLedger.GLAccount__c != TOUR_GL_CODE_ID ){
				continue;
			}
			
			//-- add only if there were changes.
			if( !isDelete && oldMap != null && oldMap.containsKey( newLedger.Id )){
				oldLedger = oldMap.get( newLedger.Id );
				
				//-- continue if nothing changed
				//-- @TODO: review with mike if the ledger entry would ever change to a different event.
				if(
					!(
						newLedger.TourRep__c != oldLedger.TourRep__c ||
						newLedger.TE__c != oldLedger.TE__c ||
						newLedger.PerDiems__c != oldLedger.PerDiems__c ||
						newLedger.EndofTourDinner__c != oldLedger.EndofTourDinner__c ||
						newLedger.MiscExpense__c != oldLedger.MiscExpense__c
					)
				){
					//-- no change
					continue;
				}
			}
			
			//-- require that the event id must be set, and at least something was defined.
			if(
				newLedger.Event__c != null
				//&& ( newLedger.TourRep__c != null || newLedger.TE__c != null || newLedger.PerDiems__c != null || newLedger.EndofTourDinner__c != null || newLedger.MiscExpense__c != null )
			){
				changedEventIds.add( newLedger.Event__c );
			}
		}
		
		if( changedEventIds == null || changedEventIds.size() < 1 ){
			//-- short circuit as nothing has changed
			return( results );
		}
		
		//-- @INVARIANT: at this point we have a set of all ledger entries
		//-- that are of type tour ledger entry
		//-- that have changed and have something that we can actually calculate.
		
		set<Id> tourIds = new Set<Id>();
		for( Event__c updatedEvent : [
			SELECT Id, Tour__c
			FROM Event__c
			WHERE Id in :changedEventIds
		]){
			tourIds.add( updatedEvent.Tour__c );
		}
		
		if( tourIds.size() > 0 ){
			results = updateTourTSO( tourIds );
		}
		
		return( results );
	}
		
	/**
	 * Performs the update of the TSO on the tours based on a set of ids.
	 * @param tourIds Id[] - set of ids of tours to recalculate.
	 * @return Tour__c[] - tours that were changed
	 **/
	private static Tour__c[] updateTourTSO( Set<Id> tourIds ){
		Tour__c[] results = new Tour__c[]{};
		
		//-- collection of tours by their id
		Map<Id,Tour__c> toursById;
		//-- collection of ledger entries by the tour id
		Map<Id,LedgerEntry__c[]> ledgerEntriesByTourId = new Map<id,LedgerEntry__c[]>();
		//-- collection of events by tour id;
		//Map<Id,Event__c> eventsByTourId;
		
		Decimal totalTourRep = 0;
        Decimal totalTE = 0;
        Decimal totalPerDiems = 0;
        Decimal totalEndofTourDinner = 0;
        Decimal totalMiscExpense = 0;
		
		if( tourIds != null && tourIds.size() > 0 ){
			for( LedgerEntry__c le : [
				SELECT Id, TourRep__c, TE__c, PerDiems__c, EndofTourDinner__c, MiscExpense__c, Event__r.Tour__c
				FROM LedgerEntry__c
				WHERE Event__r.Tour__c in :tourIds
			]){
				if( !ledgerEntriesByTourId.containsKey( le.Event__r.Tour__c ) ){
					ledgerEntriesByTourId.put( le.Event__r.Tour__c, new LedgerEntry__c[]{} );
				}
				ledgerEntriesByTourId.get( le.Event__r.Tour__c ).add( le );
			}
			
			//-- get the current tour info
			//LedgerEntry__c tourLE;
			LedgerEntry__c[] tourLEs;
			for( Tour__c tourToUpdate : [
				SELECT Id, TotalEndofTourDinner__c, TotalMiscExpense__c,
					TotalPerDiems__c, TotalTE__c, TotalTourRep__c
				FROM Tour__c
				where ID in :tourIds
			]){
				tourToUpdate.TotalTourRep__c = 0;
				tourToUpdate.TotalTE__c = 0;
				tourToUpdate.TotalPerDiems__c = 0;
				tourToUpdate.TotalEndofTourDinner__c = 0;
				tourToUpdate.TotalMiscExpense__c = 0;
				
				//-- can occur if there are no Tour Specific ledger entires yet for the tour
				//-- such as if the only event on the tour has been removed, etc.
				if( ledgerEntriesByTourId.containsKey( tourToUpdate.Id ) ){
					tourLEs = ledgerEntriesByTourId.get( tourToUpdate.Id );
					for( LedgerEntry__c tourLE : tourLEs ){
						if( tourLE.TourRep__c != null ){
							tourToUpdate.TotalTourRep__c += tourLE.TourRep__c;
						}
						if( tourLE.TE__c != null ){
							tourToUpdate.TotalTE__c += tourLE.TE__c;
						}
						if( tourLE.PerDiems__c != null ){
							tourToUpdate.TotalPerDiems__c += tourLE.PerDiems__c;
						}
						if( tourLE.EndofTourDinner__c != null ){
							tourToUpdate.TotalEndofTourDinner__c += tourLE.EndofTourDinner__c;
						}
						if( tourLE.MiscExpense__c != null ){
							tourToUpdate.TotalMiscExpense__c += tourLE.MiscExpense__c;
						}
					}
				}
				
				results.add( tourToUpdate );
			}
			
			if( results != null && results.size() > 0 ){
				update results;
			}
		}
		
		return( results );
	}
}