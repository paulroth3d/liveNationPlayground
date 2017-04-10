/**
 *  Controller for the LNE_LiveNationAPI_VenueSearch lightning component.
 *  @author Paul Roth (proth@salesforce.com)
 **/
public with sharing class LNE_API_VenueSearch_C {
    
    /** Constant - to avoid people playing with Accounts **/
    public static final String RT_Venue = 'Venue';
    
    /** Constant - ok status **/
    public static final Integer STATUS_CODE_OK = 200;
	
    /** constructor **/
    public LNE_API_VenueSearch_C(){
    }
    
    /**
     * Finds a particular venue by record Id
     * @param recordId (Id)
     * @return Account
     **/
    @AuraEnabled
    public static Account getVenueById( Id recordId ){
        //-- @TODO: investigate whether a private class can be used to return both this and the settings in a single call.
        
        //-- we don't want to catch anything, because the query should work
        //-- and the front end should know if there was an error found.
        return( [ SELECT id, Name, VenueName__c, SourceSystemId__c, LNEAPIId__c, LNEAPIName__c, LNEUrlSlug__c
                FROM Account
            	WHERE RecordType.Name = :RT_Venue and id = :recordId ][0] );
    }
    
    /**
     *  Sets the livenation id for the particular venue
     *  @param recordId (Id)
     *  @param livenationId (String)
     *  @return Boolean - whether succeeded (true) or not (false)
     **/
    @AuraEnabled
    public static Boolean setVenueLiveNationId( Id recordId, String liveNationData ){
    	if (!String.isBlank(liveNationData)) {
    		List<String> values = liveNationData.split('\\|;\\|');
    		String livenationName = values[0];
            String livenationID = values[1];
            String livenationUrlSlug = values[2];
            String livenationHostId = values[3];
            String billingLatitudeStr = values[4];
            String billingLongitudeStr = values[5];
            
            Account accountUpdate = new Account(Id=recordId,
            									LNEAPIId__c=livenationID,
            									LNEAPIName__c=livenationName,
            									LNEUrlSlug__c=livenationUrlSlug,
            									LNEAPITicketMasterId__c=livenationHostId
            									);
            
            try {
            	accountUpdate.BillingLatitude = Double.valueOf( billingLatitudeStr );
            } catch ( Exception err ){
            	System.debug( 'BillingLatitude: unable to parse:' + billingLatitudeStr );
            }
            
            try {
            	accountUpdate.BillingLongitude = Double.valueOf( billingLongitudeStr );
            } catch ( Exception err ){
            	System.debug( 'BillingLongitude: unable to parse:' + billingLongitudeStr );
            }
            
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
    public static List<VenueResult> searchVenues( String venueQuery ){
        /*
        Why is this done in apex vs doing it within front end/jQuery
		http://salesforce.stackexchange.com/questions/55306/how-to-call-a-salesforce-rest-url-from-lightning-component
		Ultimately, that would violate the security policy of the document.
		As there is no way to alter the Meta tags (required to fix the problem)
		this now has to be done within apex.
        */
        
        List<VenueResult> results = new List<VenueResult>();
        
        System.debug( 'venueQuery[' + venueQuery + ']' );
        
        API_Settings__c apiSettings = API_Settings__c.getInstance();
        String targetURL = apiSettings.LiveNationAPI_Endpoint__c + '/venues?q=' + venueQuery;
        
        System.debug( 'targetURL:' + targetURL );
        
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
            resp.setBody('{"meta":{"status":200,"message":"OK"},"pagination":{"total":1,"offset":0,"count":1},"data":[{"id":"ven_33251","name":"FEDEX Field - Lot D Green","lat":"38.912575","lng":"-76.86225","homepage":null,"address":{"street":"Lot D Green - 1600 FEDEX Way","street2":null,"city":"Hyattsville","state":"Maryland","postal_code":"20785","country":"United States"},"phone":null,"ticketmaster_ids":["172619"],"box_office":{"phone":"800-745-3000"},"vdp_img_url":null,"time_zone":"US/Eastern","time_zone_abbr":"EST","url_slug":"fedex-field-lot-d-green","owned_by_ln":false,"websites":[],"terrapass":false}]}');
            
        }
        
        if( resp.getStatusCode() == STATUS_CODE_OK ){
            System.debug( 'venues found' );
            System.debug( resp );
            LNE_API_VenueSearchResp apiResponse = LNE_API_VenueSearchResp.parse( resp.getBody() );
            //System.debug( apiResponse );
            
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
    private static List<VenueResult> createResponseOptions( LNE_API_VenueSearchResp response ){
        List<VenueResult> results = new List<VenueResult>();

        String label;
        String value;
        
        String livenationName;
        String city;
        String livenationID;
        String ticketMasterId;
        String livenationUrlSlug;
        String latitude;
        String longitude;
        
        if( response.data != null && response.data.size() > 0 ){
            for( LNE_API_VenueSearchResp.Data venueSearchResult : response.data ){
            	city = venueSearchResult.address.city;
                livenationName = venueSearchResult.name;
                livenationID = venueSearchResult.id;
                ticketMasterId = '';
                if( venueSearchResult.ticketmaster_ids != null && venueSearchResult.ticketmaster_ids.size() > 0 ){
                    List<Integer> sortedTicketmasterIds = sortStringsAsNumbers(venueSearchResult.ticketmaster_ids);
                    if( sortedTicketmasterIds != null && sortedTicketmasterIds.size() > 0 ){
                        ticketMasterId = String.valueOf(sortedTicketmasterIds[ sortedTicketmasterIds.size() -1 ]);
                    }
                }
                livenationUrlSlug = venueSearchResult.url_slug;
                latitude = venueSearchResult.lat;
                longitude = venueSearchResult.lng;
                results.add(new VenueResult(livenationName, city, livenationID, livenationUrlSlug, ticketMasterId, latitude, longitude));
            }
        } else {
            System.debug( 'no results found' );
        }
        
        System.debug( 'resultOptions:' );
        System.debug( results );
        
        return( results );
    }

    private static List<Integer> sortStringsAsNumbers(List<String> stringList) {
        List<Integer> sortedList = new List<Integer>();
        for (String s : stringList) {
            try {
                sortedList.add(Integer.valueOf(s));
            } catch (Exception e) {
                system.debug('Could not parse string as integer: ' + s);
            }
        }
        sortedList.sort();

        return sortedList;
    }

    public class VenueResult {
    	@AuraEnabled
    	public String name {get;set;}
    	@AuraEnabled
    	public String city {get;set;}
    	@AuraEnabled
    	public String id {get;set;}
    	@AuraEnabled
    	public String urlSlug {get;set;}
    	@AuraEnabled
    	public String hostVenueId {get;set;}
    	@AuraEnabled
    	public String latitude {get;set;}
    	@AuraEnabled
    	public String longitude {get;set;}

    	public VenueResult(String venueName, String city, String apiId, String urlSlug, String hostVenueId, String latitude, String longitude) {
    		this.name = venueName;
    		this.city = city;
    		this.id = apiId;
    		this.urlSlug = urlSlug;
    		this.hostVenueId = hostVenueId;
    		this.latitude = latitude;
    		this.longitude = longitude;
    	}
    }
}