/**
 * Controller for the mass edit.
 * @author Vinay
 * US199 - Controller class to review and enter manual ticket count data across events via a searchable interface 
 *			so that the routine task is faster to complete for all events within a venue, by artist, or other common criteria.
 * @version - us199 
 **/
global with sharing class LNE_MassManualTicketCounts_C {
	/* -- Constants -- */
	private static final Set<String> eventStatus = LNE_Constants.MASS_MANUAL_TICKET_COUNT_EVENT_STATUS;
	public static final String TOO_MANY_RESULTS = 'Too Many Results found. Please further narrow your search.';
	public static final String ERROR_MANUAL_TICKET_COUNT_NOT_VALID = 'Manual ticket count not valid';
	
	public static final TIME MIDNIGHT = Time.newInstance( 0,0,0,0 );

	/* -- Variables -- */
    public EventDateTime__c eventDateTimeSearch {get; set;} 
    public EventDateTime__c eventDateTimeSelected {get; set;} 
    public String  selectedVenueName {get; set;} 
    public Id eventDateTimeId {get; set;}
    public List<EventDateTimeWrapper> eventDateTimeWrapperList {get; set;} 
    public List<ManualTicketCount__c> manualTicketCountList {get; set;} 
    private Map<Id, List<ManualTicketCount__c>> eventDateTimeIdToManualTicketCountMap {get; set;} 
    public Date eventStartDate {get; set;} 
    public Date eventEndDate {get; set;} 
    public ManualTicketCount__c newManualTicketCount {get; set;} 
    private static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue',  'Account.Artist'});         
    private static Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
    private static Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );

    public LNE_MassManualTicketCounts_C() {
		//instantiate the variables
		eventDateTimeSearch = new EventDateTime__c();
		eventDateTimeWrapperList = new List<EventDateTimeWrapper>();
		eventDateTimeIdToManualTicketCountMap = new Map<Id, List<ManualTicketCount__c>>();


        //default start date to today on initial load
        eventDateTimeSearch.EventDate__c = System.today();
        
	}

	/**
	* @description Run a dynamic search and sets list of EventDateTime meeting the search criteria - US199
	* @return PageReference
	**/
    public PageReference runSearch(){
    	Integer numTicketCounts;
		Id eventDateTimeId;
		Id[] eventDateTimeIds;
		
		EventDateTimeWrapper edtWrapper;
        eventDateTimeWrapperList = new List<EventDateTimeWrapper>(); 
        eventDateTimeIdToManualTicketCountMap = new Map<Id, List<ManualTicketCount__c>>();

    	String queryString = buildQuery();
        System.debug(logginglevel.error,'@@@ queryString - '+ queryString);
        List<EventDateTime__c> eventDateTimeList = Database.Query( queryString );
        System.debug(logginglevel.error,'@@@ eventDateTimeList - '+ eventDateTimeList.size() + ' -- ' + eventDateTimeList);

        if(eventDateTimeList != null && !eventDateTimeList.isEmpty()){
        	if(eventDateTimeList.size() > GeneralSettings__c.getInstance().SearchLimit__c){
        		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, TOO_MANY_RESULTS );
            	ApexPages.addMessage(myMsg);
        	}else{

        		Map<Id, EventDateTimeWrapper> eventDateTimeWrapperMap = new Map<Id, EventDateTimeWrapper>();
        		for(EventDateTime__c eventDateTime : eventDateTimeList){
        			/* check for additional critieria based on related object
					* Earliest of (Event Date Time.On Sale Date <= today - 7) OR (Event Date Time.On Sale Date Times.Sale Date <= today)
					*/
					//-- if the eventDateTime.PublicOnSale__c <= system.today() + 7days;
					if(
						( eventDateTime.PublicOnSale__c <= system.today().addDays(7) ) ||
						( eventDateTime.OnSaleDateTimes__r != null && !eventDateTime.OnSaleDateTimes__r.isEmpty() && eventDateTime.OnSaleDateTimes__r[0].SaleStartDate__c <= system.today())
					){
	        			eventDateTimeWrapperMap.put(eventDateTime.Id, new EventDateTimeWrapper(eventDateTime));
	        			eventDateTimeIdToManualTicketCountMap.put(eventDateTime.Id, eventDateTime.ManualTicketCounts__r);
        			}
        		}

        		//Run aggregate query on TicketScale to get the feed counts
				AggregateResult[] groupedResults = [SELECT EventDateTime__c
															, Sum(ActualSalesToDate__c)feedTicketCount
															, Sum(ActualGrossToDate__c)feedGrossCount
															, Max(LastModifiedDate)lastFeedDate 
															FROM TicketScale__c 
															WHERE EventDateTime__c IN :eventDateTimeWrapperMap.keySet()
															AND ( StageType__c = 'Audit' OR (StageType__c = 'Projection' AND Event__r.UsingTicketFeed__c = true))
															GROUP BY EventDateTime__c
														];
				if(groupedResults != null && !groupedResults.isEmpty()){
					ManualTicketCount__c[] manualTicketCounts;
					
					for(AggregateResult ar : groupedResults){
						
						eventDateTimeId = (ID)ar.get('EventDateTime__c');

						EventDateTime__c eventDateTime = eventDateTimeWrapperMap.get(eventDateTimeId).eventDateTime;
						eventDateTimeWrapperMap.put((Id)ar.get('EventDateTime__c'), 
							new EventDateTimeWrapper(eventDateTime,(Decimal)ar.get('feedTicketCount'),(Decimal)ar.get('feedGrossCount'),(DateTime)ar.get('lastFeedDate')));
					}
				}

				eventDateTimeWrapperList.addAll(eventDateTimeWrapperMap.values());
				
				//-- clear the list of manual ticket counts;
				eventDateTimeSelected = null;
				if( manualTicketCountList != null ){
					manualTicketCountList.clear();
				}

                //set the eventDateTimeId to the first of the list.
                if(eventDateTimeWrapperList != null && !eventDateTimeWrapperList.isEmpty()){
                    eventDateTimeId = eventDateTimeWrapperList[0].eventDateTime.Id; 
                }
			}
        }
         System.debug(logginglevel.error,'@@@ eventDateTimeWrapperList - '+ eventDateTimeWrapperList.size() + ' -- ' + eventDateTimeWrapperList);
        return null;
    }

    /**
	* @description builds the dynamic query string for EventDateTime query - US199
	* @return String
	**/
    public String buildQuery(){
    	String queryString = 'SELECT Id, PublicOnSale__c ';
		
    	/* get the fields can be configured as field set to add to query */
    	for(Schema.FieldSetMember f: SObjectType.EventDateTime__c.FieldSets.LNE_MassTicketCount_EventDTListFields.getFields()){ 
    		queryString += ', ' + f.getFieldPath();
        }

        /* get the field for Ticket Count configured as field set and build inner query */
        queryString += ', (SELECT Id, lastModifiedBy.Name ';
        for(Schema.FieldSetMember f: SObjectType.ManualTicketCount__c.FieldSets.LNE_MassTicketCount_Fields.getFields()){ 
    		queryString += ', ' + f.getFieldPath();
        }
        queryString += ' FROM ManualTicketCounts__r order by TicketSalesDate__c desc limit 5 ) ';

        // Add to query to get On Sales Dates
        queryString += ' , (Select Id, SaleStartDate__c from OnSaleDateTimes__r ORDER BY SaleStartDate__c DESC limit 1) ';

        queryString += ' FROM EventDateTime__c ';

        /* Apply predefined filters */
        queryString += ' WHERE EventStatus__c IN :eventStatus' ;

        /* Apply filter criteria based on search filter */
        if(eventDateTimeSearch.Market__c != null){
        	 queryString += ' AND Market__c = \''+ eventDateTimeSearch.Market__c + '\' '  ;
        }
        system.debug(logginglevel.error,'eventDateTimeSearch.Venue__c - '+ eventDateTimeSearch.Venue__c);
        if(eventDateTimeSearch.Venue__c != null){
        	 queryString += ' AND Venue__c = \''+ eventDateTimeSearch.Venue__c + '\' '  ;
        }

        if(selectedVenueName != null && selectedVenueName != ''){
             queryString += ' AND Venue__r.venueName__c = \''+ selectedVenueName + '\' '  ;
        }

        if(eventDateTimeSearch.Artists__c != null && eventDateTimeSearch.Artists__c != ''){
        	 queryString += ' AND Artists__c like \'%'+ eventDateTimeSearch.Artists__c + '%\' '  ;
        }
        if(eventDateTimeSearch.EventDate__c != null){
        	 Date eventStartDate = eventDateTimeSearch.EventDate__c ;
        	 queryString += ' AND EventDate__c >='+ DateTime.newInstance(eventStartDate.year(),eventStartDate.month(),eventStartDate.day()).format('yyyy-MM-dd')  ;
        }
        if(eventDateTimeSearch.EventEndDate__c != null){
        	 Date eventEndDate = eventDateTimeSearch.EventEndDate__c ;
        	 queryString += ' AND EventDate__c <='+ DateTime.newInstance(eventEndDate.year(),eventEndDate.month(),eventEndDate.day()).format('yyyy-MM-dd')  ;
        }

        queryString += ' ORDER BY Venue__r.venueName__c,EventDate__c ASC';

        System.debug(logginglevel.error,'@@@ queryString - '+ queryString);
        return queryString;
    }

    /**
	* @description Returns the list of ManualTicketCounts associated to eventDateTime Id - US199
	* @param (Id) EventDateTimeID
	* @return PageReference
	**/
    public PageReference getManualTicketCountList(){
    	manualTicketCountList = new List<ManualTicketCount__c>();
    	if(eventDateTimeId != null && eventDateTimeIdToManualTicketCountMap.containsKey(eventDateTimeId)){
    		manualTicketCountList = eventDateTimeIdToManualTicketCountMap.get(eventDateTimeId);
    		
    		manualTicketCountList = sortManualTicketCounts( manualTicketCountList );
    		
            //Set the event Date time selected details
            eventDateTimeSelected = [SELECT Id, Name, EventDate__c, StartTime__c FROM EventDateTime__c WHERE Id =: eventDateTimeId ];
            system.debug(LoggingLevel.ERROR, 'manualTicketCountList - '+ manualTicketCountList);
    	}
        instantiateNewManualTicketCount();
        manualTicketCountList.add(newManualTicketCount);
        System.debug( 'eventDateTimeSelected:' ); System.debug( eventDateTimeSelected );
        system.debug(LoggingLevel.ERROR, 'manualTicketCountList after blank row - ' );
        System.debug( manualTicketCountList);
    	return null;
	}

	/**
	* @description instantiate new 
	* @param (Id) EventDateTimeID
	* @return PageReference
	**/
    public ManualTicketCount__c instantiateNewManualTicketCount(){
    	if(eventDateTimeId != null){
    		newManualTicketCount = new ManualTicketCount__c();
    		newManualTicketCount.EventDateTime__c = eventDateTimeId;  
    	}
    	return newManualTicketCount;
	}
	
	/**
	 *  Determines if a new manual ticket count is valid
	 *  @return boolean
	 **/
	public static Boolean isTicketCountValid( ManualTicketCount__c manualTicketCount ){
		//System.debug( 'isNull:' + (manualTicketCount != null) );
		//System.debug( 'TicketSalesDate__c:' + (manualTicketCount.TicketSalesDate__c != null) );
		//System.debug( 'manualTicketCount.TicketCount__c:' + (manualTicketCount.TicketCount__c != null) );
		//System.debug( 'manualTicketCount.GrossSales__c:' + (manualTicketCount.GrossSales__c != null) );
		
		Boolean isValid = (
			manualTicketCount != null && 
			manualTicketCount.TicketSalesDate__c != null &&
			manualTicketCount.TicketCount__c != null &&
			manualTicketCount.GrossSales__c != null
		);
		System.debug( 'isValid:' + isValid );
		return( isValid );
	}
	
	/**
	 * Whether the manual ticket count has been touched in any way
	 * @return boolean
	 **/
	public static Boolean isTicketCountBlank( ManualTicketCount__c manualTicketCount ){
		//System.debug( 'isNull:' + (manualTicketCount != null) );
		//System.debug( 'TicketSalesDate__c:' + (manualTicketCount.TicketSalesDate__c != null) );
		//System.debug( 'manualTicketCount.TicketCount__c:' + (manualTicketCount.TicketCount__c != null) );
		//System.debug( 'manualTicketCount.GrossSales__c:' + (manualTicketCount.GrossSales__c != null) );
		
		Boolean isBlank = (
			manualTicketCount != null && !(
				( manualTicketCount.TicketSalesDate__c != null ) ||
				( manualTicketCount.TicketCount__c != null ) ||
				( manualTicketCount.GrossSales__c != null )
			)
		);
		System.debug( 'isBlank:' + isBlank );
		return( isBlank );
	}
	
	/**
	 * Creates a list of valid manual ticket counts
	 * @param ManualTicketCount__c[] manualTicketCounts
	 * @return ManualTicketCount__c[] - manual ticket counts filtered to only those that are 'valid'
	 **/
	public static ManualTicketCount__c[] getValidManualTicketCounts( ManualTicketCount__c[] manualTicketCounts ){
		ManualTicketCount__c[] results = new ManualTicketCount__c[]{};
		
		if( manualTicketCounts != null && manualTicketCounts.size() > 0 ){
			for( ManualTicketCount__c mtc : manualTicketCounts ){
				if( isTicketCountValid( mtc )){
					results.add( mtc );
				}
			}
		}
		return( results );
	}


	/**
	* @description save ManualTicketCounts associated to eventDateTime Id - US199
	* @return PageReference
	**/
    public PageReference saveManualTicketCountList(){
    	
    	//-- check if the new ticket count is blank
    	//System.debug( 'is new blank:' + isTicketCountBlank( this.newManualTicketCount ) );
    	//System.debug( 'is new valid:' + isTicketCountValid( this.newManualTicketCount ) );
    	
    	//-- validate all the records
    	for( ManualTicketCount__c mtc: this.manualTicketCountList ){
    		if( !isTicketCountBlank( mtc ) && !isTicketCountValid( mtc )){
    			System.debug( 'mtc is not valid:' ); System.debug( mtc );
    			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_MANUAL_TICKET_COUNT_NOT_VALID );
            	ApexPages.addMessage(myMsg);
	    	}
    	}
    	
    	ManualTicketCount__c[] updateList = getValidManualTicketCounts( this.manualTicketCountList );
    	
    	if( updateList != null && !updateList.isEmpty()){
    		
    		System.debug( 'list to insert:' ); System.debug( updateList );
	    	try{
	    		upsert updateList;
	    		
	    		//-- recalculate formulas WILL NOT WORK in this case.
	    		
	    		//-- update the cache
	    		eventDateTimeIdToManualTicketCountMap.put( eventDateTimeId, updateList );
	    		
	    		if( isTicketCountValid( this.newManualTicketCount ) ){
	    			//-- its in use, so we'll add a new one.
	    			manualTicketCountList.add( instantiateNewManualTicketCount() );
	    		}
	    	}
	    	catch(Exception ex){
	    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() );
            	ApexPages.addMessage(myMsg);
	    	}
    	}
    	return null;
	}

	/** 
	 * Remote action to find the venues that match a similar name.
	 * @param venueSearch
	 * @return String[] list of venue names
	 **/
	@RemoteAction
	global static String[] searchVenues( String venueSearch ){
		String[] results = new String[]{};
		String venueSearch2 = '%' + venueSearch + '%';
		
		for( Account venue: [
			select id, name, venueName__c
			from account
			where venueName__c like :venueSearch2 and RecordTypeId =: RT_ACCOUNT_VENUE_ID
		]){
			results.add( venue.VenueName__c );
		}
		
		return( results );
	}

	/** 
	 * Remote action to find the artist that match a similar name.
	 * @param artistSearch
	 * @return String[] list of artist names
	 **/
	@RemoteAction
	global static String[] searchArtists( String artistSearch ){
		String[] results = new String[]{};
		String artistSearch2 = '%' + artistSearch + '%';
		
		for( Account artist: [
			select id, name
			from account
			where name like :artistSearch2 and RecordTypeId =: RT_ACCOUNT_ARTIST_ID
		]){
			results.add( artist.name );
		}
		
		return( results );
	}
	
	/**
	 * Sorts a list of manual ticket counts
	 * @param manualTicketCounts (ManualTicketCount__c[] )
	 * @return ManualTicketCount__c[] - sorted list
	 **/
	public static ManualTicketCount__c[] sortManualTicketCounts( ManualTicketCount__c[] manualTicketCounts ){
		ManualTicketCount__c[] results = new ManualTicketCount__c[]{};
		
		if( manualTicketCounts != null ){
			SortableManualTicketCountWrapper[] sortableList= new SortableManualTicketCountWrapper[]{};
			for( ManualTicketCount__c mtc : manualTicketCounts ){
				sortableList.add( new SortableManualTicketCountWrapper( mtc ));
			}
			sortableList.sort();
			
			for( Integer i = 0; i < sortableList.size(); i++ ){
				results.add( sortableList[i].manualTicketCount );
			}
		}
		
		return( results );
	}
	
	/**
	 * Sortable list of manual ticket counts
	 **/
	public class SortableManualTicketCountWrapper implements Comparable {
		public ManualTicketCount__c manualTicketCount;
		public Integer epochLifetime;
		
		public SortableManualTicketCountWrapper( ManualTicketCount__c manualTicketCount ){
			this.manualTicketCount = manualTicketCount;
			
			this.epochLifetime = 0;
			if( manualTicketCount.TicketSalesDate__c != null ){
			//	DateTime dt = DateTime.newInstance( manualTicketCount.TicketSalesDate__c, MIDNIGHT );
			//	this.epochLifetime = dt.getTime();
				this.epochLifetime = (manualTicketCount.TicketSalesDate__c.year() * 365) + manualTicketCount.TicketSalesDate__c.dayOfYear();
			}
		}
		
		public Integer compareTo( Object compareTo ){
			SortableManualTicketCountWrapper compareToMTC = (SortableManualTicketCountWrapper)compareTo;
			
			Integer returnVal = Integer.valueOf( this.epochLifetime - compareToMTC.epochLifetime);
			System.debug( 'comparing times[' + this.epochLifetime + '] thatTime[' + compareToMTC.epochLifetime + ']:' + returnVal );
			return( returnVal );
		}
	}

	/**
	* @author Vinay Kanuganti
	* @created 2017-01-27
	* @description Wrapper class to display the Event Date time and coresponding the ticket counts.
	**/
    public class EventDateTimeWrapper{
    	public EventDateTime__c eventDateTime {get; set;} 
    	public Decimal feedTicketCount {get; set;} 
    	public Decimal feedGrossSales {get; set;} 
    	public DateTime lastFeedDate {get; set;} 

    	public EventDateTimeWrapper( EventDateTime__c  cEventDateTime){
    		this.eventDateTime = cEventDateTime;
    		this.feedTicketCount = 0;
    		this.feedGrossSales = 0.0;
    		this.lastFeedDate = null;		
    	}

    	public EventDateTimeWrapper( EventDateTime__c  cEventDateTime, Decimal cFeedTicketCount, Decimal cFeedGrossSales, DateTime cLastFeedDate){
    		this.eventDateTime = cEventDateTime;
    		this.feedTicketCount = cFeedTicketCount;
    		this.feedGrossSales = cFeedGrossSales;
    		this.lastFeedDate = cLastFeedDate;		
    	}
    }

}