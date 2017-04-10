/**
 * Controller class for the LNE_TourRoutingBooking Event__c subtab
 *
 * @author	Scott Will
 * @group	Controller
**/
global without sharing class LNE_TourRoutingBooking_CX {

	final static Time MIDNIGHT = (Time.newInstance(0, 0, 0, 0));
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
	
	public LNE_TourRoutingBooking_CX(ApexPages.StandardController sc) {

		tour = (Tour__c)sc.getRecord();

		if (tour.FilterExpirationDate__c != null
		 && tour.FilterExpirationDate__c < System.today()
		) {
			// if filter has expired then wipe out the values
			// in memory so the front-end thinks there isnt one
			tour.FilterArtist__c = '';
			tour.FilterDivision__c = '';
			tour.FilterEndDate__c = null;
			tour.FilterExpirationDate__c = null;
			tour.FilterStartDate__c = null;
			tour.FilterVenueType__c = '';
		}

	}

	/**
	 * Returns today's date formatted as yyyy-mm-dd
	 *
	 * @return 	String - today's date formatted as yyyy-mm-dd
	**/
	public String getTodayFormatted() {
		return formatDate(System.today());
	}

	/**
	 * Returns the Tour's Filter Start Date formatted as yyyy-mm-dd
	 *
	 * @return 	String - Filter Start Date formatted as yyyy-mm-dd
	**/
	public String getStartFormatted() {
		return formatDate(tour.FilterStartDate__c == null ? System.today() : tour.FilterStartDate__c);
	}

	/**
	 * Returns the Tour's Filter End Date formatted as yyyy-mm-dd
	 *
	 * @return 	String - Filter End Date formatted as yyyy-mm-dd
	**/
	public String getEndFormatted() {
		return formatDate(tour.FilterEndDate__c);
	}

	private static String formatDate(Date d) {
		return d == null ? '' : DateTime.newInstance(d, MIDNIGHT).format('yyyy-MM-dd');
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
	 * Returns a list of Events currently associated with the Tour Id
	 *
	 * @param  tourId Id - the Id of the Tour
	 * @return Event__c[]
	 */
	@RemoteAction
	global static List<Event__c> getEvents(Id tourId) {

		List<Event__c> events = new List<Event__c>();

		if (tourId != null) {
			events.addAll(new List<Event__c>([
				select
					EventTitle__c,
					PrimaryHeadlinerArtist__c,
					ShowCount__c,
					Status__c,
					Venue__r.Name
				from Event__c
				where Tour__c = :tourId
				order by EventTitle__c
			]));
		}

		return events;

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
	 * finds any Event that match the the tours Headliner or CoHeadliner
	 * and are not associated with the supplied Tour Id
	 *
	 * @param	tourId Id - Ignores Events already associated to the Id
	 * @return 	Event__c[]
	**/
	@RemoteAction
	global static List<Event__c> presearchEvents(Id tourId) {

		List<Event__c> events = new List<Event__c>();

		if (tourId != null) {

			List<Tour__c> tours = new List<Tour__c>([
				select
					TourCoHeadliner__r.Name,
					TourHeadliner__r.Name
				from Tour__c
				where Id = :tourId
			]);

			if (!tours.isEmpty()) {

				Tour__c tour = tours[0];

				Set<String> artists = new Set<String>();
			 	if (String.isNotBlank(tour.TourCoHeadliner__r.Name)) {
			 		artists.add(tour.TourCoHeadliner__r.Name);
			 	}
			 	if (String.isNotBlank(tour.TourHeadliner__r.Name)) {
			 		artists.add(tour.TourHeadliner__r.Name);
			 	}

				if (!artists.isEmpty()) {

					Set<Id> seenEvents = new Set<Id>();
					for (Deal__c deal : [
						select
							Event__c,
							Event__r.EventTitle__c,
							Event__r.PrimaryHeadlinerArtist__c,
							Event__r.ShowCount__c,
							Event__r.Status__c,
							Event__r.Venue__r.Name
						from Deal__c
						where Event__r.Tour__c != :tour.Id
						and Artist__r.Name in :artists
						and Event__r.EventLastDate__c >= :System.today()
						and Type__c in ('Primary Headliner', 'Co-Headliner')
						order by 
							Event__r.EventTitle__c,
							CreatedDate desc
					]) {
						// add parent event
						if (seenEvents.add(deal.Event__c)) {
							events.add(deal.Event__r);
						}
					}

				}

			}

		}

		return events;

	}

	/**
	 * find any Event that match the SearchTerm values
	 * and are not associated with the supplied Tour Id
	 *
	 * @param	terms SearchTerms - The search terms
	 * @param	tourId Id - Ignores Events already associated to the Id
	 * @return 	Event__c[]
	**/
	@RemoteAction
	global static List<Event__c> searchEvents(SearchTerms terms, Id tourId) {

		List<Event__c> events = new List<Event__c>();

		// dont do anything unless there are actual terms to search upon
		if (terms.hasSearchValues()) {

			// eventTitle overrides all, does a SOSL
			events.addAll(String.isNotBlank(terms.eventTitle)
				? searchEventsSOSL(terms.eventTitle, tourId)
				: searchEventsSOQL(terms, tourId)
			);

		}

		return events;

	}

	/**
	 * Associates an Event with a Tour.  Or disassociates the Event by passing a null tourId.
	 *
	 * @param	eventIds Id[] - The Ids of the Event__c records to update
	 * @param	tourId Id - The Id of the tour to associate to the Event__c
	 * @return 	Boolean - the success of the DML statement
	**/
	@RemoteAction
	global static Map<Id,String> associateEventsToTour(List<Id> eventIds, Id tourId) {

		Map<Id,String> results = new Map<Id,String>();

		if (!eventIds.isEmpty()) {

			List<Event__c> events = new List<Event__c>();
			for (Id eventId : new Set<Id>(eventIds)) {
				events.add(new Event__c(
					Id = eventId,
					Tour__c = tourId
				));
			}

			// because of the way Database.SaveResult only returns an Id for getId()
			// if there was no error, we get to do this ugliness.
			// the two lists will always equal in size
			List<Database.SaveResult> saveResults = Database.update(events, false);
			for (Integer i = 0; i < saveResults.size(); i++) {
				Database.SaveResult sr = saveResults[i];
				String result = sr.isSuccess() ? '' : (sr.getErrors()[0].getMessage());
				Id eventId = events[i].Id;
				results.put(eventId, result);
			}

		}

		return results;

	}

	/**
	 * Updates a Tour with new Filter paramters.
	 *
	 * @param	tourId Id - The Id of the tour to associate to the Event__c
	 * @param 	filters SearchFilters - The search filters
	 * @return 	Boolean - the success of the DML statement
	**/
	@RemoteAction
	global static Boolean updateTourFilters(Id tourId, SearchFilters filters) {

		Boolean result = false;

		if (tourId != null) {

			Tour__c tour = new Tour__c(
				Id = tourId,
				FilterArtist__c = filters.artist,
				FilterDivision__c = filters.division,
				FilterEndDate__c = filters.endDate,
				FilterExpirationDate__c = filters.expirationDate,
				FilterStartDate__c = filters.startDate,
				FilterVenueType__c = filters.venue
			);
			Database.SaveResult sr = Database.update(tour, false);

			result = sr.isSuccess();

		}

		return result;

	}

	/**
	 * find all Events that contain the searchTerm value
	 * and are not associated with the supplied Tour Id
	 *
	 * @param	searchTerm String - The term to search
	 * @param	tourId Id - Ignores Events already associated to the Id
	 * @return 	Event__c[]
	**/
	private static List<Event__c> searchEventsSOSL(String searchTerm, Id tourId) {

		List<Event__c> events = new List<Event__c>();

		if (String.isNotBlank(searchTerm)) {
		
			List<List<SObject>> eventsList = [
				find :searchTerm
				in all fields 
				returning 
					Event__c (
						EventTitle__c,
						PrimaryHeadlinerArtist__c,
						ShowCount__c,
						Status__c,
						Venue__r.Name
						where Tour__c != :tourId
						order by EventTitle__c
					)
			];
			
			if (!eventsList.isEmpty()) {
				events.addAll((List<Event__c>)eventsList[0]);
			}

		}

		return events;

	}

	/**
	 * find any Event that match the SearchTerm values
	 * and are not associated with the supplied Tour Id
	 *
	 * @param	terms SearchTerms - The search terms
	 * @param	tourId Id - Ignores Events already associated to the Id
	 * @return 	Event__c[]
	**/
	private static List<Event__c> searchEventsSOQL(SearchTerms terms, Id tourId) {

		List<Event__c> events = new List<Event__c>();

		if (terms != null && terms.hasSearchValues()) {

			String soql = 
				'select ' +
					'Event__c, ' +
					'Event__r.EventTitle__c, ' +
					'Event__r.PrimaryHeadlinerArtist__c, ' +
					'Event__r.ShowCount__c, ' +
					'Event__r.Status__c, ' +
					'Event__r.Venue__r.Name ' +
				'from Deal__c ' +
				'where Event__r.Tour__c != :tourId ' +
				'and Type__c in (\'Primary Headliner\', \'Co-Headliner\') ';

			// adplanId overrides others
			if (String.isNotBlank(terms.eventId)) {

				String fuzzedEventId = '%' + terms.eventId;
				List<Deal__c> deals = new List<Deal__c>((List<Deal__c>)Database.query(
					soql + 
					'and Event__r.Name like :fuzzedEventId ' +
					'order by CreatedDate desc ' +
					'limit 1'
				));

				if (!deals.isEmpty()) {
					events.add(deals[0].Event__r);
				}

			}
			else {

				Date eventBegin = terms.eventBegin;
				Date eventEnd = terms.eventEnd;
				String artist = String.isBlank(terms.artist) ? '' : terms.artist + '%';
				String division = terms.division;
				String venueType = terms.venueType;

				Set<Id> seenEvents = new Set<Id>();
				for (Deal__c deal : (List<Deal__c>)Database.query(
					soql +
					(eventBegin == null ? '' : 'and Event__r.EventLastDate__c >= :eventBegin ') +
					(eventEnd == null ? '' : 'and Event__r.EventFirstDate__c <= :eventEnd ') +
					(String.isBlank(artist) ? '' : 'and Artist__r.Name like :artist ') +
					(String.isBlank(division) ? '' : 'and Event__r.Office__r.Division__c = :division ') +
					(String.isBlank(venueType) ? '' : 'and Event__r.Venue__r.Type = :venueType ') +
					'order by Event__r.EventTitle__c, CreatedDate desc'
				)) {

					if (seenEvents.add(deal.Event__c)) {
						events.add(deal.Event__r);
					}

				}

			}

		}

		return events;

	}

	/**
	 * Wrapper for search filters
	**/
	global class SearchFilters {

		public Date endDate {get;set;}
		public Date expirationDate {get;set;}
		public Date startDate {get;set;}
		public String artist {get;set;}
		public String division {get;set;}
		public String venue {get;set;}

	}

	/**
	 * Wrapper for search terms
	**/
	global class SearchTerms {

		public Date eventBegin {get;set;}
		public Date eventEnd {get;set;}
		public String eventId {get;set;}
		public String eventTitle {get;set;}
		public String artist {get;set;}
		public String division {get;set;}
		public String venueType {get;set;}

		public SearchTerms() {
			this.eventBegin = null;
			this.eventEnd = null;
			this.eventId = '';
			this.eventTitle = '';
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

			return this.eventBegin != null &&
				(this.eventEnd != null
				|| String.isNotBlank(this.eventId)
				|| String.isNotBlank(this.eventTitle)
				|| String.isNotBlank(this.artist)
				|| String.isNotBlank(this.division)
				|| String.isNotBlank(this.venueType));

		}

	}

}