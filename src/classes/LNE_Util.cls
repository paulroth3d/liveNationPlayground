/**
 *  Set of very high level utility methods that deal with Profiles,
 *  PermissionSets, RecordTypes, SObjects (not Accounts or specific subclasses)
 *  etc.
 *  
 *  <p>This class should be as sparse as possible and only should be used
 *  if logic applies across large functionality.</p>
 * 
 *  <p>Please note, if considering modifying sharing access on this class:
 *  the majority of this class does not depend on sharing
 *  but the 'isEventEditable' method down below - does.</p>
 *  
 *  @author Paul Roth <proth@salesforce.com>
**/
public with sharing class LNE_Util {
	
	/**
	 * Static variable to disable all triggers - to allow disabling for the current user only.
	 * 
	 * At present the only valid case is that triggers should be disabled
	 * while cloning. Other use cases to be vetted, but it must be careful
	 * that this is not abused (turning it off and on within the middle of triggers
	 * as this would lead us to likely invalid states quite quickly.
	 * 
	 * The alternatives are to set the disable flags on the custom setting side
	 * but this applies to multiple users (not just this one)
	 * and should be used for those other cases for now.
	 * 
	 **/
	public static boolean IS_CURRENTLY_CLONING = false;
	
	/** sample test value for an eventName **/
	public static final String DEFAULT_EVENT_NAME_CHECK = 'EVENTNAMECHECK';
	
	//-- notice this is a regex
	public static final String PATH_DELIMITER = '.';
	public static final String PATH_DELIMITER_REGEX = '[.]';
	
	private static final Map<String, Id> RECORD_TYPES_BY_NAME = getRecordTypesByName();
	private static Map<String, GLAccount__c> GL_ACCOUNTS_BY_ID = null;
	
	private static final String ERROR_RETRIEVING_GL_ACCOUNTS = 'ERROR occurred while retrieivng all GL Accounts';
	
	private static Map<String, Id> getRecordTypesByName(){
	    Map<String,Id> results = new Map<String,Id>();
		string downloadedPath = null;
		
		for( RecordType rt : [select id, DeveloperName, SObjectType from RecordType]){
			downloadedPath = rt.SObjectType + PATH_DELIMITER + rt.DeveloperName;
			results.put( downloadedPath, rt.Id );
		}
		
		return( results );
	}
	
	public static Map<String,Id> getRecordTypes( String[] recordTypePaths ){
		Map<String,Id> results = new Map<String,Id>();
		
		for( String recordTypePath : recordTypePaths ){
			if( RECORD_TYPES_BY_NAME.containsKey( recordTypePath )){
				results.put( recordTypePath, RECORD_TYPES_BY_NAME.get(recordTypePath) );
			}
		}
		
		return( results );
	}
	
	/**
	 *  Creates a map of Profile Names by Profile Ids.
	 *  @pram profileNames String[] - list of profile names to be returned.
	 *  @return Map<String,Id>
	**/
	public static Map<String,Id> getProfileIds( String[] profileNames ){
		Map<String,Id> results = new Map<String,Id>();
		
		for( Profile p : [ select id, name
			from Profile
			where name in :profileNames
		]){
			results.put( p.name, p.id );
		}
		return( results );
	}
	
	/**
	 *  Creates a map of Permission set names by ids.
	 *  @param permSetNames String[] - list of permission set names to be returned
	 *  @return Map<String,id>
	**/
	public static Map<String,Id> getPermissionSetIds( String[] permissionSetNames ){
		Map<String,Id> results = new Map<String,Id>();
		
		for( PermissionSet p : [ select id, name
			from PermissionSet
			where name in :permissionSetNames
		]){
			results.put( p.name, p.id );
		}
		return( results );
	}
	
	/**
	 *  Retrieves all GL Accounts.
	 *  called on first demand of getGLAccounts, or any other time after all GL Accounts have been loaded.
	 *  @INVARIANT - GL_ACCOUNTS_BY_ID is fill with the GL Accounts by the GL Account Id (ex: 60001)
	 **/
	public static Map<String,GLAccount__c> refreshGLAccountCache(){
		try {
			GL_ACCOUNTS_BY_ID = new Map<String,GLAccount__c>();
			for( GLAccount__c glAccount : [
				select ActiveFlag__c, ApplyToBuySellEvent__c, 
				ApplyToGospelBrunchEvent__c, ApplyToHOBEvent__c, ApplyToNAMusicEvent__c, 
				ApplyToPromotedEvent__c, ApplyToRentalEvent__c, AvailableForForecast__c, 
				Category__c, CategorySort__c, CurrencyIsoCode, DeactivationDate__c, 
				FinancialCategorySAPBPC__c, GLCode__c, Id, ImportRateType__c, Name, 
				RelatedContra__c, RevenueFlag__c, SourceSystemId__c, Type__c
				from GLAccount__c
			]){
				GL_ACCOUNTS_BY_ID.put( glAccount.GLCode__c, glAccount );
			}
		} catch( Exception err ){
			System.debug( ERROR_RETRIEVING_GL_ACCOUNTS + ':' + err.getMessage() );
			throw( err );
		}
		
		return( GL_ACCOUNTS_BY_ID );
	}
	
	/**
	 *  Defines a list of GLAccounts by gl account id
	 *  @param String[] - list of gl accounts ids
	 *  @return Map<String,GLAccount__c> - list of gl accounts by the gl account number
	 **/
	public static Map<String,GLAccount__c> getGLAccounts( String[] glAccountNumbers ){
		Map<String,GLAccount__c> results = new Map<String,GLAccount__c>();
		
		if( GL_ACCOUNTS_BY_ID == null ){
			GL_ACCOUNTS_BY_ID = refreshGLAccountCache();
		}
		
		for( String glAccountId : glAccountNumbers ){
			if( GL_ACCOUNTS_BY_ID.containsKey( glAccountId )){
				results.put( glAccountId, GL_ACCOUNTS_BY_ID.get( glAccountId ));
			}
		}
		
		return( results );
	}

	/**
	 *  Gets all field names for sobject by name
	 *  @param String - object name
	 *  @return List<String> - list of field names
	 **/
	public static List<String> getFieldsForObject(String objectName) {
		Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		return new List<String>(globalDescribe.get(objectName).getDescribe().fields.getMap().keySet());
	}
	
	/**
	 *  Verifies that a given event is editable by the current person.
	 *  @param eventId (Id)
	 *  @return (Boolean) - whether the current person can edit an event - true - or it is not currently editable (false)
	 **/
	public static Boolean isEventEditable( Id eventId ){
	    
	    Boolean canEdit = false;
	    
	    //-- disable all triggers and other logic for the current user as best as possible.
        LNE_FinancialCalculator.currentlyRunning = true;
        LNE_Util.IS_CURRENTLY_CLONING = true;
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            Event__c eventToCheck = [ select Id, EventName__c from Event__c where id = :eventId limit 1 ];
            
            eventToCheck.EventName__c = DEFAULT_EVENT_NAME_CHECK;
            
            update eventToCheck;
            
            canEdit = true;
            
        } catch( Exception err ){
            System.debug( 'user does not have access to edit event:' + eventId );
            
            //-- implied from above but makes it clear.
            canEdit = false;
        } finally {
            Database.rollback( sp );
        }
        
        return( canEdit );
	}
	
	/**
	 *  Creates a map of RecordTypes by RecordType Developer names
	 *  @param recordTypePaths (String[]) - list of SObject.DeveloperNames (Object . DeveloperName)
	 *  @return Map<String,Id> - collection of recordTypes 
	 *  @example
	 *  	String recordTypes = new String[]{
	 *  		'Account.Venue','Account.Office'
	 *  	};
	 *  	Map<String,Id> recordTypes = LNE_Util.getRecordTypes( recordTypes );
	 *  	Id RT_VENUE_ID = recordTypes.get( 'Account.Venue' );
	 *  	Id RT_OFFICE_ID = recordTypes.get( 'Account.Office' );
	**/
	/*public static Map<String,Id> getRecordTypes( String[] recordTypePaths ){
		Map<String,Id> results = new Map<String,Id>();
		
		Set<String> sObjects = new Set<String>();
		Set<String> developerNames = new Set<String>();
		String[] pathSplits = null;
		
		Set<String> retrievedPaths = new Set<String>();
		
		for( String recordTypePath : recordTypePaths ){
			pathSplits = recordTypePath.split( PATH_DELIMITER_REGEX );
			sObjects.add( pathSplits[0] );
			developerNames.add( pathSplits[1] );
			
			results.put( recordTypePath, null );
		}
		
		String downloadedPath = null;
		for( RecordType rt : [
			select id, DeveloperName, SObjectType
			from RecordType
			where SObjectType in :sObjects
			and developerName in :developerNames
		]){
			downloadedPath = rt.SObjectType + PATH_DELIMITER + rt.DeveloperName;
			
		    if( results.containsKey( downloadedPath )){
				results.put( downloadedPath, rt.Id );
			}
		}
		
		return( results );
	}*/
}