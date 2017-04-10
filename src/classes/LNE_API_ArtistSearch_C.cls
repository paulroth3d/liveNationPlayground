/**
 *  Controller for the LNE_LiveNationAPI_ArtistSearch lightning component.
 *  @author Daniel Nakonieczny (dnakonieczny@salesforce.com)
 **/
public with sharing class LNE_API_ArtistSearch_C {

    /** Constant - to avoid people playing with Accounts **/
    public static final String RT_Artist = 'Artist';
    
    /** Constant - ok status **/
    public static final Integer STATUS_CODE_OK = 200;
	
    /** constructor **/
    public LNE_API_ArtistSearch_C(){
    }
    
    /**
     * Finds a particular artist by record Id
     * @param recordId (Id)
     * @return Account
     **/
    @AuraEnabled
    public static Account getArtistById( Id recordId ){
        //-- @TODO: investigate whether a private class can be used to return both this and the settings in a single call.
        
        //-- we don't want to catch anything, because the query should work
        //-- and the front end should know if there was an error found.
        return( [SELECT Id, Name, LNEAPIId__c, LNEAPIName__c, LNEUrlSlug__c
                 FROM Account
            	 WHERE RecordType.Name = :RT_Artist AND Id = :recordId ][0] );
    }
    
    /**
     *  Sets the livenation id for the particular artist
     *  @param recordId (Id)
     *  @param livenationId (String)
     *  @return Boolean - whether succeeded (true) or not (false)
     **/
    @AuraEnabled
    public static Boolean setArtistLiveNationId( Id recordId, String liveNationData ){
    	if (!String.isBlank(liveNationData)) {
    		List<String> values = liveNationData.split('\\|;\\|');
    		String livenationName = values[0];
            String livenationID = values[1];
            String livenationUrlSlug = values[2];

            Account accountUpdate = new Account(Id=recordId,
            									LNEAPIId__c=livenationID,
            									LNEAPIName__c=livenationName,
            									LNEUrlSlug__c=livenationUrlSlug);
            update accountUpdate;

            return( true );
    	}

    	return( false );
    }
    
    /**
     *  Finds the current API Settings custom setting
     **/
    @AuraEnabled
    public static API_Settings__c getAPI_Settings(){
        return API_Settings__c.getInstance();
    }
    
    /**
     *  Performs the rest call to the LiveNation API.
     *  @param searchQuery
     *  @return SelectOption[]
     **/
    @AuraEnabled
    public static List<ArtistResult> searchArtists( String query ){
        /*
        Why is this done in apex vs doing it within front end/jQuery
		http://salesforce.stackexchange.com/questions/55306/how-to-call-a-salesforce-rest-url-from-lightning-component
		Ultimately, that would violate the security policy of the document.
		As there is no way to alter the Meta tags (required to fix the problem)
		this now has to be done within apex.
        */
        
        List<ArtistResult> results = new List<ArtistResult>();
        API_Settings__c apiSettings = API_Settings__c.getInstance();
        String targetURL = apiSettings.LiveNationAPI_Endpoint__c + '/artists?q=' + query;
        
        HttpRequest req = new HttpRequest();
        HttpResponse resp = null;
        
        req.setMethod('GET');
        req.setEndpoint( targetURL );
        req.setTimeout( Integer.valueOf( apiSettings.LiveNation_API_Timeout__c ) );
        
        if(!Test.isRunningTest()){
            try {
                resp = (new Http()).send( req );
            } catch( Exception exp ){
                System.debug( 'exception caught:' );
                System.debug( exp );
                throw exp;
            }
        } else {
            resp = new HttpResponse();
            resp.setStatusCode(STATUS_CODE_OK);
            //TODO: un-hardcode this response
            resp.setBody('{"meta":{"status":200,"message":"OK"},"pagination":{"total":1371,"offset":0,"count":20},"data":[{"id":"art_51068","name":"P!NK","images":[],"ticketmaster_ids":["718655"],"bio":null,"url_slug":"p-nk","megaticket":false,"event_group":false},{"id":"art_136367","name":"Floyd Pink","images":[],"ticketmaster_ids":["2261919"],"bio":null,"url_slug":"floyd-pink","megaticket":false,"event_group":false}]}');
        }
        
        if( resp.getStatusCode() == STATUS_CODE_OK ){
            System.debug( 'venues found' );
            System.debug( resp );
            LNE_API_ArtistSearchResp apiResponse = LNE_API_ArtistSearchResp.parse( resp.getBody() );
            
            results = createResponseOptions( apiResponse );
            
        } else {
            System.debug( 'Status not ok:' + resp.getStatusCode() );
            System.debug( resp );
        }
        
        return( results );
    }

    /**
     * Checks if the current user can edit this Account record.
     * Normally we would use a SOQL query on Account:
     * SELECT UserRecordAccess.HasEditAccess FROM Account
     * But that won't tell us if any validation rules would stop the current user from
     * editing this record.
     * @param recordId (Id)
     * @return Boolean
     **/
    @AuraEnabled
    public static Boolean checkIfUserCanEditCurrentRecord(Id recordId) {
    	Boolean success = false;
    	Savepoint sp = Database.setSavepoint();

    	try {
    		Account a = new Account(Id=recordId,LNEAPIName__c='test23423423test234234242test23423423test234234242');
    		Database.SaveResult sr = Database.update(a);
    		success = true;
    	} catch (DMLException e) {
    		success = false;
    	}

    	Database.rollback(sp);

    	return success;
    }
    
    /**
     *  Creates a set of options from an LNE_API_VenueSearchResp(onse)
     *  @param response (LNE_API_VenueSearchResp)
     *  @returns SelectOption2[]
     **/
    private static List<ArtistResult> createResponseOptions( LNE_API_ArtistSearchResp response ){
        List<ArtistResult> results = new List<ArtistResult>();

        String label;
        String value;
        
        if( response.data != null && response.data.size() > 0 ){
            for( LNE_API_ArtistSearchResp.Data venueSearchResult : response.data ){
                String livenationName = venueSearchResult.name;
                String livenationID = venueSearchResult.id;
                String livenationUrlSlug = venueSearchResult.url_slug;
                results.add(new ArtistResult(livenationName, livenationID, livenationUrlSlug));
            }
        } else {
            System.debug( 'no results found' );
        }
        
        System.debug( 'resultOptions:' );
        System.debug( results );
        
        return( results );
    }

    public class ArtistResult {
    	@AuraEnabled
    	public String name {get;set;}
    	@AuraEnabled
    	public String id {get;set;}
    	@AuraEnabled
    	public String urlSlug {get;set;}

    	public ArtistResult(String n, String id, String u) {
    		this.name = n;
    		this.id = id;
    		this.urlSlug = u;
    	}
    }
}