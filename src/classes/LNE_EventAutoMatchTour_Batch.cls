/**
* Iterates over Tour__c records that have pre-defined and active Filters setup to automatically find
* and match Event__c records that have those same exact values.
*
* @author	Scott Will
* @group	Batchable, Schedulable
*
**/
global class LNE_EventAutoMatchTour_Batch implements Database.Batchable<sObject>, Schedulable {
	
	final static String query =
		'select ' +
			'FilterArtist__c, ' +
			'FilterDivision__c, ' +
			'FilterEndDate__c, ' +
			'FilterStartDate__c, ' +
			'FilterVenueType__c ' +
		'from Tour__c ' +
		'where FilterExpirationDate__c >= TODAY ' +
		'and FilterArtist__c != null ' +
		'and FilterStartDate__c != null ' +
		'order by CreatedDate desc ';

	private final DateTime batchLastRan;

	public LNE_EventAutoMatchTour_Batch() {
		// retrieve last ran
		List<AsyncApexJob> jobs = new List<AsyncApexJob>([
			select CreatedDate 
			from AsyncApexJob 
			where ApexClass.Name = 'LNE_EventAutoMatchTour_Batch' 
			order by CreatedDate desc 
			limit 1
		]);
		// either run last 24 hours or since last ran
		this.batchLastRan = jobs.isEmpty()
			? System.now().addDays(-1)
			: jobs[0].CreatedDate;

	}

	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<Tour__c> tours) {

		// SCOPE IS SET TO 1, THIS IS _NOT_ RUNNING IN BULK
		Tour__c tour = tours[0];

		String artist = tour.FilterArtist__c;
		String division = tour.FilterDivision__c;
		String venue = tour.FilterVenueType__c;
		Date beginDate = tour.FilterStartDate__c;
		Date endDate = tour.FilterEndDate__c;
	
		// find any events that match
		List<Event__c> events = new List<Event__c>();

		// find any events that have been modified since the last ran date
		// and that have an exact match to the Tour's filters
		for (Event__c event : (List<Event__c>)Database.query(
			'select AutoMatchedTour__c ' +
			'from Event__c ' +
			'where LastModifiedDate >= :batchLastRan ' +
			'and AutoMatchedTour__c = null ' +
			'and Tour__c = null ' +
			'and DoNotAutoAssociateWithTour__c = false ' +
			'and PrimaryHeadlinerArtist__c = :artist ' +
			'and EventFirstDate__c >= :beginDate ' +
			(endDate == null ? '' : 'and EndLastDate__c <= :endDate ') +
			(String.isBlank(division) ? '' : 'and Division__c = :division ') +
			(String.isBlank(venue) ? '' : 'and Venue__c = :venue ')
		)) {
			// only pre-set for now.  a second, slower, batch will move the value to the real Tour__c
			event.AutoMatchedTour__c = tour.Id;
			events.add(event);
		}

		if (!events.isEmpty()) {
			// update whatever can be updated
			Database.update(events, false);
		}

	}
	
	global void finish(Database.BatchableContext bc) {
		// call next step in process, to associate the events individually to allow financial calc to run
		Database.executeBatch(new LNE_EventAssociateMatchedTour_Batch(), 1);
	}

	global void execute(SchedulableContext sc) {
		// schedule will execute batch @1 scope
		Database.executeBatch(this, 1);
	}
	
}