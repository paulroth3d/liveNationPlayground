/**
 * Controller class for the LNE_TourRoutingMarketing Event__c subtab
 *
 * @author	Scott Will
 * @group	Controller
**/
global without sharing class LNE_TourRoutingMarketing_C {

	final static Id ACCOUNT_ARTIST_RECTYPE_ID;
	final static Id ACCOUNT_OFFICE_RECTYPE_ID;
	final static Id ACCOUNT_VENUE_RECTYPE_ID;

	static {

		String acctArtist = 'Account.Artist';
		String acctOffice = 'Account.Office';
		String acctVenue = 'Account.Venue';
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new List<String> { acctArtist, acctOffice, acctVenue }
		);

		ACCOUNT_ARTIST_RECTYPE_ID = recordTypeMap.get(acctArtist);
		ACCOUNT_OFFICE_RECTYPE_ID = recordTypeMap.get(acctOffice);
		ACCOUNT_VENUE_RECTYPE_ID = recordTypeMap.get(acctVenue);

	}

	final Tour__c tour;
	
	public LNE_TourRoutingMarketing_C(ApexPages.StandardController sc) {
		this.tour = (Tour__c)sc.getRecord();
	}

	/**
	 * Returns array of Division type Office Accounts
	 *
	 * @return 	String[] - Array of 'Id|Name' options
	**/
	public List<SelectOption> getDivisions() {

		List<SelectOption> divisions = new List<SelectOption> {
			new SelectOption('', '--None--')
		};

		for (Account acct : [
			select Name
			from Account
			where RecordTypeId = :ACCOUNT_OFFICE_RECTYPE_ID
			and Type = 'Division'
			order by Name
		]) {
			divisions.add(new SelectOption(acct.Name, acct.Name));
		}

		return divisions;

	}

	/**
	 * Returns array of distinct Venue types
	 *
	 * @return 	String[] - Array of Venue Names
	**/
	public List<SelectOption> getVenueTypes() {

		List<SelectOption> venues = new List<SelectOption> {
			new SelectOption('', '--None--')
		};

		for (AggregateResult agg : [
			select Type
			from Account
			where RecordTypeId = :ACCOUNT_VENUE_RECTYPE_ID
			and Type != null
			group by Type
			order by Type
		]) {
			String text = String.valueOf(agg.get('Type'));
			venues.add(new SelectOption(text, text));
		}

		return venues;

	}

	/**
	 * Returns a list of AdPlans currently associated with the Tour Id
	 *
	 * @param  tourId Id - the Id of the Tour
	 * @return AdPlan__c[]
	 */
	@RemoteAction
	global static List<AdPlan__c> getAdPlans(Id tourId) {

		return new List<AdPlan__c>([
			select
				AdPlanName__c,
				Artists__c,
				Event__c,
				Event__r.Office__r.Division__c,
				Event__r.Venue__r.Type,
				EventDate__c
			from AdPlan__c
			where Tour__c = :tourId
			order by AdPlanName__c
		]);

	}

	/**
	 * Returns a list of Artists whose Name matches the term 
	 *
	 * @param  term String - the string to match
	 * @return String[] - array of matched Artist names
	 */
	@RemoteAction
	global static List<String> searchArtists(String term) {

		List<String> artists = new List<String>();

		if (String.isNotBlank(term)) {

			String fuzzedTerm = term + '%';

			for (Account acct : [
				select Name
				from Account
				where Name like :fuzzedTerm
				and RecordTypeId = :ACCOUNT_ARTIST_RECTYPE_ID
				order by Name
			]) {
				artists.add(acct.Name);
			}

		}

		return artists;

	}

	/**
	 * find any AdPlan that match the SearchTerm values
	 * and are not associated with the supplied Tour Id
	 *
	 * @param	terms SearchTerms - The search terms
	 * @param	tourId Id - Ignores AdPlans already associated to the Id
	 * @return 	AdPlan__c[]
	**/
	@RemoteAction
	global static List<AdPlan__c> searchAdPlans(SearchTerms terms, Id tourId) {

		List<AdPlan__c> adplans = new List<AdPlan__c>();

		// dont do anything unless there are actual terms to search upon
		if (terms.hasSearchValues()) {

			// adplanName overrides all, does a SOSL
			adplans.addAll(String.isNotBlank(terms.adplanName)
				? searchAdPlansSOSL(terms.adplanName, tourId)
				: searchAdPlansSOQL(terms, tourId)
			);

		}

		return adplans;

	}

	/**
	 * Associates an AdPlan with a Tour.  Or disassociates the AdPlan by passing a null tourId.
	 *
	 * @param	adplanIds Id[] - The Ids of the AdPlan__c records to update
	 * @param	tourId Id - The Id of the tour to associate to the AdPlan__c
	 * @return 	Boolean - the success of the DML statement
	**/
	@RemoteAction
	global static Map<Id,String> associateAdPlansToTour(List<Id> adplanIds, Id tourId) {

		Map<Id,String> results = new Map<Id,String>();

		if (!adplanIds.isEmpty()) {

			List<AdPlan__c> adplans = new List<AdPlan__c>();
			for (Id adplanId : new Set<Id>(adplanIds)) {
				adplans.add(new AdPlan__c(
					Id = adplanId,
					Tour__c = tourId
				));
			}

			// because of the way Database.SaveResult only returns an Id for getId()
			// if there was no error, we get to do this ugliness.
			// the two lists will always equal in size
			List<Database.SaveResult> saveResults = Database.update(adplans, false);
			for (Integer i = 0; i < saveResults.size(); i++) {
				Database.SaveResult sr = saveResults[i];
				String result = sr.isSuccess() ? '' : (sr.getErrors()[0].getMessage());
				Id adplanId = adplans[i].Id;
				results.put(adplanId, result);
			}

		}

		return results;

	}

	/**
	 * find all AdPlans that contain the searchTerm value
	 * and are not associated with the supplied Tour Id
	 *
	 * @param	searchTerm String - The term to search
	 * @param	tourId Id - Ignores AdPlans already associated to the Id
	 * @return 	AdPlan__c[]
	**/
	private static List<AdPlan__c> searchAdPlansSOSL(String searchTerm, Id tourId) {

		List<AdPlan__c> adplans = new List<AdPlan__c>();

		if (String.isNotBlank(searchTerm)) {
		
			List<List<SObject>> adplansList = [
				find :searchTerm
				in all fields 
				returning 
					AdPlan__c (
						AdPlanName__c,
						Artists__c,
						Event__c,
						Event__r.Office__r.Division__c,
						Event__r.Venue__r.Type,
						EventDate__c,
						Name,
						Tour__c,
						Tour__r.TourName__c
						where Tour__c != :tourId
						order by AdPlanName__c
					)
			];
			
			if (!adplansList.isEmpty()) {
				adplans.addAll((List<AdPlan__c>)adplansList[0]);
			}

		}

		return adplans;

	}

	/**
	 * find any AdPlan that match the SearchTerm values
	 * and are not associated with the supplied Tour Id
	 *
	 * @param	terms SearchTerms - The search terms
	 * @param	tourId Id - Ignores AdPlans already associated to the Id
	 * @return 	AdPlan__c[]
	**/
	private static List<AdPlan__c> searchAdPlansSOQL(SearchTerms terms, Id tourId) {

		List<AdPlan__c> adplans = new List<AdPlan__c>();

		if (terms != null && terms.hasSearchValues()) {

			String soql = 
				'select ' +
					'AdPlanName__c, ' +
					'Artists__c, ' +
					'Event__c, ' +
					'Event__r.Office__r.Division__c, ' +
					'Event__r.Venue__r.Type, ' +
					'EventDate__c,' +
					'Name, ' +
					'Tour__c, ' +
					'Tour__r.TourName__c ' +
				'from AdPlan__c ' +
				'where Tour__c != :tourId ';

			// adplanId overrides others
			if (String.isNotBlank(terms.adplanId)) {

				String fuzzedAdplanId = '%' + terms.adplanId;
				adplans.addAll((List<AdPlan__c>)Database.query(
					soql + 
					'and Name like :fuzzedAdplanId'
				));

			}
			else {

				Boolean standalone = terms.standalone;
				Date eventBegin = terms.eventBegin;
				Date eventEnd = terms.eventEnd;
				String artist = String.isBlank(terms.artist) ? '' : terms.artist + '%';
				String division = terms.division;
				String venueType = terms.venueType;

				adplans.AddAll((List<AdPlan__c>)Database.query(
					soql +
					(standalone ? 'and Event__c = null ' : '') +
					(eventBegin == null ? '' : 'and EventDate__c >= :eventBegin ') +
					(eventEnd == null ? '' : 'and EventDate__c <= :eventEnd ') +
					(String.isBlank(artist) ? '' : 'and PrimaryHeadlinerArtist__c like :artist ') +
					(String.isNotBlank(division) && !standalone ? 'and Event__r.Office__r.Division__c = :division ' : '') +
					(String.isNotBlank(venueType) && !standalone ? 'and Event__r.Venue__r.Type = :venueType ' : '') +
					'order by AdPlanName__c'
				));

			}

		}

		return adplans;

	}

	/**
	 * Wrapper for search terms
	**/
	global class SearchTerms {

		public Boolean standalone {get;set;}
		public Date eventBegin {get;set;}
		public Date eventEnd {get;set;}
		public String adplanId {get;set;}
		public String adplanName {get;set;}
		public String artist {get;set;}
		public String division {get;set;}
		public String venueType {get;set;}

		public SearchTerms() {
			this.standalone = false;
			this.eventBegin = null;
			this.eventEnd = null;
			this.adplanId = '';
			this.adplanName = '';
			this.artist = '';
			this.division = '';
			this.venueType = '';
		}

		/**
		 * Returns TRUE if any search term has a non-default value
		 *
		 * @return 	Boolean
		**/
		public Boolean hasSearchValues() {

			return this.standalone
				|| this.eventBegin != null
				|| this.eventEnd != null
				|| String.isNotBlank(this.adplanId)
				|| String.isNotBlank(this.adplanName)
				|| String.isNotBlank(this.artist)
				|| String.isNotBlank(this.division)
				|| String.isNotBlank(this.venueType);

		}

	}

}