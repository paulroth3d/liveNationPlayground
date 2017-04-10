/**
 *  Trigger logic for US220 - create the tour ledger entry once an event is linked to a tour.
 *  @assumption - will only be fired on updates
 *  @author Sebastian Gutierrez
 *  @version - initial 1/11/2017
 **/
public class LNE_CheckLinkedToTour_T {
	
	//-- record types
    private static String RT_EXPENSES = 'LedgerEntry__c.Expenses';
    
    /** LA National Touring Allocation GL CODE that must be assigned to the ledger entry. **/
    public static final String GL_CODE='50360';
    
    public static final String ERROR_GL_CODE_NOT_FOUND = 'Expected GL Account was not found:';
	
	/**
	 * execution method
	 **/
    public static Event__c[] execute( Event__c[] newList, Map<Id,Event__c> oldMap ){
    	
    	Event__c[] results = new Event__c[]{};
    	
    	//-- assume update
        if( oldMap == null ){
        	return( results );
        }
    	
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        	new String[]{ RT_EXPENSES}
        );
        Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
        //-- invariant : rt_expenses_id is the id of the expenses record type for the Ledger Entry object.
        
        //-- gl accounts
        GLAccount__c tourGLAccount;
        try {
	        Map<String,GLAccount__c> glAccounts = LNE_Util.getGLAccounts( new String[]{ GL_CODE } );
        	tourGLAccount = glAccounts.get( GL_Code );
        } catch( Exception err ){
        	throw( new CustomException( ERROR_GL_CODE_NOT_FOUND + GL_CODE ));
        }
        
        //-- all the events that have changed their tour.
        Event__c[] validEvents = new Event__c[]{}; //-- same thing as new List<Event__c>();
        
        Event__c oldEvent;
        //-- only find the Events that have changed tour values.
        for( Event__c newEvent : newList ){
        	if( oldMap.containsKey( newEvent.Id )){
        		//-- not necessary to use the SObjectChange class, because we are only doing a single field.
        		oldEvent = oldMap.get( newEvent.Id );
        		if( newEvent.Tour__c != oldEvent.Tour__c && newEvent.Tour__c != null ){
        			//System.debug( 'The tour has changed on an event and the tour has been defined' );
        			validEvents.add( newEvent );
        		}
        	}
        	//-- else should never occur.
        }
        
        //-- @INVARIANT: valid events contain the list of all events thave changed.
        //System.debug( 'validEvents:' + validEvents );
        
        //-- short circuit the trigger if it doesn't need to go further.
        if( validEvents.size() < 1 ){
        	return( results );
        }
		
		//-- list of all the gl touring ledger entries that are created.
        List<LedgerEntry__c> tourLedgerEntries = new List<LedgerEntry__c>();
        Map<Id, Event__c> validEventMap = new Map<Id,Event__c>( validEvents );
        
        //-- find any of those events that have a ledger entry of the GL_CODE and do not process those events further.
        for( LedgerEntry__c tourLedgerEntry: [
        	select id, GLCode__c,Event__c
        	from LedgerEntry__c
        	where Event__c in :validEvents and GLCode__c = :GL_CODE
        ]){
        	validEventMap.remove( tourLedgerEntry.Event__c );
        }
        
        validEvents = validEventMap.values();
        
        //-- @invariant - valid events now only are events that changed to a tour that do not have a ledger entry of the gl code.
        //System.debug( 'validEvents2:' + validEvents );
        
        for( Event__c validEvent : validEvents ){
        	tourLedgerEntries.add(new LedgerEntry__c(
                GLAccount__c = tourGLAccount.Id,
                    BaseAmount__c = 0,
                    OfferRateType__c = 'Flat', 
                    SettleAtActual__c = false,
                    OfferRate__c = 0.0,
                    InHouseRateType__c = 'Flat',
                    RecordTypeId = RT_EXPENSES_ID,
                    Event__c = validEvent.Id
                ));
        }
        
        System.debug( 'ledger entries created for those events:' ); System.debug( tourLedgerEntries );
        insert tourLedgerEntries;
        
        results = validEvents;
        System.debug( 'validEvents' ); System.debug( validEvents );
        
        return( results );
    }
    
    /** custom exception **/
    class CustomException extends Exception {}

}