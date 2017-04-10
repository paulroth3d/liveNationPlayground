/**
 *	Controller for the Example JSONP endpoint to perform an API request.
 *	<p>For more information, see page 10 of the GridBuddyCustomizationGuide</p>
 *	@author Paul Roth <proth@salesforce.com>
 *	@param GET callback (String) - name of the JSONP function to call on success.
 *	@param POST callback (String) - name of the JSONP function to call on success.
 *	@param POST LedgerEntry__c (Object) - LedgerEntry object.
 *		Id (Id)
 *		RateType__c (String)
 *		BaseAmount__c (float)
 *	@return (JSONP)
 *		Id (Id)
 *		RateType__c (String)
 *		BaseAmount__c (float)
 *		GrossRevenue__c (float)
**/
public class LNE_GridBuddyCalculationAPI_CX {
	
	/** SUCCESS STATUS **/
	public static final string STATUS_SUCCESS = 'success';
	/** FAILURE STATUS **/
	public static final string STATUS_FAILURE = 'failure';
	
	/** Default name of the function to call for jsonpResults **/
	public static final string DEFAULT_JSONP_CALLBACK='testApiCallback2';
	
	/** parameter - defines the name of the jsonp function to call on results **/
	public static final string PARAM_JSONP_CALLBACK='callback';
	/** parameter - defines the LedgerEntry with the parameters sent **/
	public static final string PARAM_LEDGER_ENTRY='LedgerEntry__c';
	/** parameter - defines the LedgerEntryBreakout with the parameters sent **/
	public static final string PARAM_LEDGER_ENTRY_BREAKOUT ='LedgerEntryBreakout__c';
	
	public static final string API_NAME = 'LNE_TestGridBuddyAPI-test';
	
	/** name of the jsonp callback to execute **/
	public String jsonpCallback {get; private set;}
	
	/** Response String **/
	public String jsonResponse {get; private set;}
	
	/** Custom settings instance **/
	private static final GeneralSettings__c GENERAL_SETTINGS = GeneralSettings__c.getInstance();
	
	public LNE_GridBuddyCalculationAPI_CX(){
		this.jsonpCallback = DEFAULT_JSONP_CALLBACK;
		this.jsonResponse = '';
	}
	
	/**
	 *	Actual endpoint code.
	 *	Get EVERYTHING from the Ledger Entry
	 *	and update Everything back on the same record
	**/
	public void processRequest(){
		ResponseMessage response = new ResponseMessage( API_NAME );
		
		//-- disable try/catch to resolve errors shown to the end user.
		try {
			Map<String,String> params = ApexPages.currentPage().getParameters();
			
			//-- in case its ever needed, debug all params sent
			/* if( false ){
				response.message = '';
				for( string keyName : params.keySet() ){
					response.message += 'KeyName†' + keyName + '†\nvalue‡' + params.get(keyName) + '‡\n\n';
				}
				return;
			}
			*/
			
			//-- allow the script to say the name of the callback
			if( params.containsKey( PARAM_JSONP_CALLBACK )){
				this.jsonpCallback = params.get( PARAM_JSONP_CALLBACK );
				System.debug( 'jsonpCallback:' + this.jsonpCallback );
			}
			
			if(params.get(PARAM_LEDGER_ENTRY) != null){
				string ledgerJSON = params.get( PARAM_LEDGER_ENTRY );
				//System.debug( 'ledgerJSON:' );
				//System.debug( ledgerJSON );
				
				//-- @TODO: review why this doesn't work.
				//http://salesforce.stackexchange.com/questions/7523/what-is-the-correct-json-to-deserialize-a-map-of-sobjects
				LedgerEntry__c ledgerEntry = (LedgerEntry__c)JSON.deserialize( ledgerJSON, LedgerEntry__c.class );
				System.debug( 'ledgerEntry' ); System.debug( ledgerEntry );
				//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
				
				//-- Logic specific for this API
				updateLedgerEntry( ledgerEntry );
				System.debug( 'ledgerEntry2' ); System.debug( ledgerEntry );
				
				//--	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
				
				response.data = ledgerEntry;
			} else if(params.get(PARAM_LEDGER_ENTRY_BREAKOUT) != null) {
				string ledgerBreakoutJSON = params.get( PARAM_LEDGER_ENTRY_BREAKOUT );
				//System.debug( 'ledgerJSON:' );
				//System.debug( ledgerJSON );
				
				//-- @TODO: review why this doesn't work.
				//http://salesforce.stackexchange.com/questions/7523/what-is-the-correct-json-to-deserialize-a-map-of-sobjects
				LedgerEntryBreakout__c ledgerEntryBreakout = (LedgerEntryBreakout__c)JSON.deserialize( ledgerBreakoutJSON, LedgerEntryBreakout__c.class );
				System.debug( 'ledgerEntryBreakout' ); System.debug( ledgerEntryBreakout );
				//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
				
				//-- Logic specific for this APIBreakout
				updateLedgerEntryBreakout( ledgerEntryBreakout );
				System.debug( 'ledgerEntryBreakout2' ); System.debug( ledgerEntryBreakout );
				
				//--	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
				
				response.data = ledgerEntryBreakout;
			}
			
		} catch( Exception err ) {
			response.isSuccessful = false;
			String errorMessage = err.getMessage();
			
			//-- @TODO: cleanup. we shouldn't show dev errors.
			
			if (GENERAL_SETTINGS.DebugAPI__c == true) {
				errorMessage += '\n\n' +err.getStackTraceString();
			}
			
			response.message = errorMessage;
		}
		
		//-- @TODO: review how to make this work.
		//-- the sub objects are always treated as a doubly encoded string.
		//this.jsonResponse = JSON.serialize( response );
		JSONGenerator generator = JSON.createGenerator(true);
		response.toJSON( generator );
		this.jsonResponse = generator.getAsString();
	}
	
	/**
	 *	THE LOGIC SPECIFIC FOR THIS API, all the stuff above is more or less boilerplate.
	**/
	private void updateLedgerEntry( LedgerEntry__c ledgerEntry ){
		
		System.debug( 'updateLedgerEntry' ); System.debug( ledgerEntry );
		LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntry);
		System.debug( 'updateLedgerEntry' ); System.debug( ledgerEntry );
	}
	
	

	private void updateLedgerEntryBreakout( LedgerEntryBreakout__c ledgerEntryBreakout ){
		
		System.debug( 'updateLedgerEntryBreakout' ); System.debug( ledgerEntryBreakout );
		LNE_LEBreakoutCalculationLogic.calculateFieldsOnGrid(ledgerEntryBreakout);
		System.debug( 'updateLedgerEntryBreakout' ); System.debug( ledgerEntryBreakout );
	}
	
	//-- @TODO: separate out to a separate class.
	
	/** internal class representing a response **/
	class ResponseMessage {
		boolean isSuccessful;
		String message;
		Object data;
		String api;
		
		ResponseMessage( String apiName ){
			this.api = apiName;
			this.isSuccessful = true;
		}
		
		void toJSON( JSONGenerator generator ){
			generator.writeStartObject();
			generator.writeBooleanField( 'isSuccessful', this.isSuccessful );
			generator.writeStringField( 'api', this.api );
			
			//-- this seems absolutely silly, but otherwise will get the following error
			//00:47:40.0 (11217688)|FATAL_ERROR|System.NullPointerException: null argument for JSONGenerator.writeStringField()
			if( this.message != null ){
				generator.writeStringField( 'message', this.message );
			} else {
				generator.writeNullField( 'message' );
			}
			
			if( this.data != null ){
				generator.writeObjectField( 'data', this.data );
			} else {
				generator.writeNullField( 'data' );
			}
			generator.writeEndObject();
		}
	}
	
	//-- can be removed
	/**
	 *	Internal test object just to capture the request info.
	 *	<p>Seems as though using an actual LedgerEntry__c object might also work.</p>
	**/
	/*
	//-- alternative method
	class LedgerEntry {
		Id myId;
		String RateType;
		decimal BaseAmount;
		decimal GrossRevenue;
		
		void toJSON( JSONGenerator generator ){
			generator.writeObject( this );
		}
	}
	*/
}