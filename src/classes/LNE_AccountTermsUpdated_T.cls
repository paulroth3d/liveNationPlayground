/**
 *	
 *	Trigger impelementation logic for when the global terms are updated on the division / VenueType level.
 *	<p>Assumes BeforeTrigger to update the PreviousGlobalTerms</p>
 * 
 *	@author Paul Roth <proth@salesforce.com>
 *	@group TermLogic
 **/
public without sharing class LNE_AccountTermsUpdated_T {
	
	//-- Listof RecordType DeveloperNames
	public static final String RT_OFFICE_NAME = 'Account.Office';
	public static final String RT_VENUE_NAME = 'Account.Venue';
	
	public static final String ACCOUNT_TYPE_DIVISION = 'Division';

    public static final String OWNERSHIP_TYPE_OWNED_OPERATED = 'Owned/Operated';
	
	/**
	 *	Updates the global terms on all child venues that share this same division / venue type.
	 *	<p>Assumes that this will only be sent on trigger.updated
	 *		(because otherwise there would be no children)</p>
	 *	@param newList (Account[])
	 *	@param oldMap (Map<Id,Account>)
	 *	@return Account[] - list of accounts that were updated.
	 **/
	public static Account[] execute( Account[] newList, Map<Id,Account> oldMap ){
		
		Account[] results = new Account[]{};
		
		//-- @TODO: siphon to a common utility class
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{ RT_OFFICE_NAME, RT_VENUE_NAME}
		);
		Id RT_OFFICE_ID = recordTypeMap.get( RT_OFFICE_NAME );
		Id RT_VENUE_ID = recordTypeMap.get( RT_VENUE_NAME );
		
		String MULTI_PICKLIST_DELIMITER =DataGenerationSettings__c.getInstance().MultiPicklistDelimiter__c;
		String COMBINED_KEY_DELIMITER = DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;
		
		//-- UPDATE the old GlobalTerms if they were updated.
		Account[] validDivisions = new Account[]{};
		
		//-- update the previousGlobalTerms on the division level (regardless of ApplyGlobalTermsTo status
		Account oldAccount = null;
		for( Account newAccount : newList ){
			if( oldMap.containsKey( newAccount.Id )){
				oldAccount = oldMap.get( newAccount.Id );
				
				if( newAccount.RecordTypeId == RT_OFFICE_ID &&
				    ACCOUNT_TYPE_DIVISION.equals( newAccount.Type ) &&
					!(newAccount.GlobalTerms__c == oldAccount.GlobalTerms__c ||
					newAccount.GlobalTerms__c.equals( oldAccount.GlobalTerms__c ))
				){
					newAccount.PreviousGlobalTerms__c = oldAccount.GlobalTerms__c;
					validDivisions.add( newAccount );
				}
			}
		}
		
		//-- if no accounts are valid, then return
		if( validDivisions.size() < 1 ){
			return( results );
		}
		
		//-- verify whether some divisions were caught
		//System.debug( 'validAccountCount:' ); System.debug( validDivisions.size() );
		
		//-- the division and the venue type combination is the specific combination.
		//-- there is the risk that there would be too many records
		//-- if all venues were retrieved that may or may not apply the the venue 'type'
		//-- so we leverage the combination instead to ensure that we do not hit that limit.
		Map<String,Account> divisionMap = new Map<String,Account>();
		String[] venueTypes = null;
		//String venueType = null;
		String divisionTypeCombination = null;
		for( Account validDivision : validDivisions ){
			if( validDivision.ApplyGlobalTermsTo__c != null ){
				venueTypes = validDivision.ApplyGlobalTermsTo__c.split( MULTI_PICKLIST_DELIMITER );
				for( String venueType : venueTypes ){
					divisionTypeCombination = validDivision.Name + COMBINED_KEY_DELIMITER + venueType;
					divisionMap.put( divisionTypeCombination, validDivision );
				}
			}
		}
		
		//-- determine the list of all valid combinations to use in the query.
		Set<String> allDivisionTypeCombinations = divisionMap.keySet();
		Account divisionAccount = null;
		Account[] affectedVenues = new Account[]{};
		
		//-- update all venues that meet that criteria.
		for( Account affectedVenue : [
			select id, GlobalTerms__c, PreviousGlobalTerms__c, OfficeDivisionType__c
			from Account
			where OfficeDivisionType__c in :allDivisionTypeCombinations
			and OwnershipType__c = :OWNERSHIP_TYPE_OWNED_OPERATED
			and RecordTypeId = :RT_VENUE_ID
		]){
			if( divisionMap.containsKey( affectedVenue.OfficeDivisionType__c )){
				divisionAccount = divisionMap.get( affectedVenue.OfficeDivisionType__c );
				
				affectedVenue.GlobalTermsUpdated__c = true;
				affectedVenue.PreviousGlobalTerms__c = affectedVenue.GlobalTerms__c;
				affectedVenue.GlobalTerms__c = divisionAccount.GlobalTerms__c;
				
				affectedVenues.add( affectedVenue );
			} //-- must be true since it was within the query criteria and checking would count negatively towards test coverage.
		}
		
		//-- verify affected Venues.
		//System.debug( 'allDivisionTypeCombinations' ); System.debug( allDivisionTypeCombinations );
		//System.debug( 'affectedVenues:' ); System.debug( affectedVenues );
		
		//-- update any affected venues.
		if( affectedVenues.size() > 0 ){
			Database.update( affectedVenues, false );
		}
		results.addAll( affectedVenues );
		
		return( results );
	}
}