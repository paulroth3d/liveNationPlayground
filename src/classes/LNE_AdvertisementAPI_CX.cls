/**
 *  Controller for the JSONP endpoint to perform an API request.
 *  <p>For more information, see page 10 of the GridBuddyCustomizationGuide</p>
 *  @author Paul Roth <dnakonieczny@salesforce.com>
 *  @param GET callback (String) - name of the JSONP function to call on success.
 *  @param POST callback (String) - name of the JSONP function to call on success.
 *  @param POST Advertisement__c (Object) - Advertisement object.
 *  @return (JSONP) Advertisement__c (Object) - Advertisement object.
**/
public with sharing class LNE_AdvertisementAPI_CX {

	/** SUCCESS STATUS **/
    public static final string STATUS_SUCCESS = 'success';
    /** FAILURE STATUS **/
    public static final string STATUS_FAILURE = 'failure';
    
    /** Default name of the function to call for jsonpResults **/
    public static final string DEFAULT_JSONP_CALLBACK='testApiCallback2';
    
    /** parameter - defines the name of the jsonp function to call on results **/
    public static final string PARAM_JSONP_CALLBACK='callback';
    /** parameter - defines the LedgerEntry with the parameters sent **/
    public static final string PARAM_ADVERTISEMENT='Advertisement__c';
    public static final string PARAM_AD_TYPE='type';

	/** name of the jsonp callback to execute **/
    public String jsonpCallback {get; private set;}
    
    /** Response String **/
    public String jsonResponse {get; private set;}

    public static final string API_NAME = 'LNE_AdvertisementAPI_CX';

    /** Custom settings instance **/
    private static final GeneralSettings__c GENERAL_SETTINGS = GeneralSettings__c.getInstance();



    public LNE_AdvertisementAPI_CX() {
    	this.jsonpCallback = DEFAULT_JSONP_CALLBACK;
        this.jsonResponse = '';
    }

	public void processRequest(){
		ResponseMessage response = new ResponseMessage( API_NAME );

		//-- disable try/catch to resolve errors shown to the end user.
        try {
            Map<String,String> params = ApexPages.currentPage().getParameters();
            
            //-- in case its ever needed, debug all params sent
            /*
            if( false ){
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

            system.debug(params);
            system.debug(params.keySet());
            system.debug(params.keySet().contains(PARAM_ADVERTISEMENT));
            system.debug(params.get('Advertisement__c'));
            system.debug(params.get(PARAM_ADVERTISEMENT));
            system.debug(params.get(PARAM_AD_TYPE));
            
            if(params.get(PARAM_ADVERTISEMENT) != null && params.get(PARAM_AD_TYPE) != null){
                string advertisementJSON = params.get( PARAM_ADVERTISEMENT );
                string adType = params.get( PARAM_AD_TYPE );
                Advertisement__c advertisement = (Advertisement__c)JSON.deserialize( advertisementJSON, Advertisement__c.class );
                System.debug( 'advertisement' ); System.debug( advertisement );
            
                AdPlan__c adPlan = [SELECT DigitalDefaultCommission__c,
                						   OutdoorDefaultCommission__c,
                						   PrintDefaultCommission__c,
                						   RadioDefaultCommission__c,
                						   TVDefaultCommission__c
                					FROM AdPlan__c WHERE Id = :advertisement.AdPlan__c];

                if (advertisement.Commission__c == null) {
                	if (!String.isBlank(adType)) {
                		if (adType.toLowerCase() == 'digital') {
                			advertisement.EffectiveCommission__c = adPlan.DigitalDefaultCommission__c;
                		}

                		if (adType.toLowerCase() == 'outdoor') {
                			advertisement.EffectiveCommission__c = adPlan.OutdoorDefaultCommission__c;
                		}

                		if (adType.toLowerCase() == 'print') {
                			advertisement.EffectiveCommission__c = adPlan.PrintDefaultCommission__c;
                		}

                		if (adType.toLowerCase() == 'radio') {
                			advertisement.EffectiveCommission__c = adPlan.RadioDefaultCommission__c;
                		}

                		if (adType.toLowerCase() == 'television') {
                			advertisement.EffectiveCommission__c = adPlan.TVDefaultCommission__c;
                		}
                	}
                } else {
                	advertisement.EffectiveCommission__c = advertisement.Commission__c;
                }
            
                response.data = advertisement;

                system.debug('response data: ' +advertisement );
            }
        } catch( Exception err ){
            response.isSuccessful = false;
            String errorMessage = err.getMessage();
            
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

        system.debug(this.jsonResponse);
	}

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
}