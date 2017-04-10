/**
 * Test class for LNE_MassManualTicketCounts_C
 * @author Vinay
 * US199
 * @version - us199 
 **/
@isTest
private class LNE_MassManualTicketCounts_C_Test
{
	
	@testSetup
    static void globalSetup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

	class TestSettings {
        public TestSettings() {
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
			
			LNE_TestObjectFactory.VenueHierarchy acctHierarchy = LNE_TestObjectFactory.createVenueHierarchy(
            	LNE_TestObjectFactory.ACCT_TYPE_DIVISION, null, null
            );
            Account venue = acctHierarchy.venue;
            Account office = acctHierarchy.office;
			
            //-- global setup here
            Event__c[] myEvents = new Event__c[]{
            	//-- first event
            	new LNE_TestObjectFactory(
			        LNE_TestObjectFactory.createEvent()
				).addProperties( new Map<String,Object>{
				    'EventName__c' => 'My Test Event',
				    'Status__c' => 'Draft'
				}).buildEvent(),
				//-- second event
				new LNE_TestObjectFactory(LNE_TestObjectFactory.createEvent()
				).addProperties( new Map<String,Object>{
				    'Status__c' => new List<String>(LNE_Constants.MASS_MANUAL_TICKET_COUNT_EVENT_STATUS)[0],
				    'Venue__c' => venue.id,
				    'Office__c' => office.Id 
				}).buildEvent()
            };
            Event__c event = myEvents[0];
            Event__c event2 = myEvents[1];
            
            Map<String,Id> dataSetIdMap = LNE_TestObjectFactory.createStandardDataSetList( myEvents, accthierarchy );
            
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue',  'Account.Artist'});         
            Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
            Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );
            
			Id artistId = dataSetIdMap.get( LNE_TestObjectFactory.STANDARD_DATA_ARTIST );
            Account artist = [Select Id, Name from Account where Id = :artistId limit 1];

            event.Status__c = new List<String>(LNE_Constants.MASS_MANUAL_TICKET_COUNT_EVENT_STATUS)[0];
            update event;

            venue.Market__c = 'Chicago';
            update venue;

            List<EventDateTime__c> evtDateTimeList = new List<EventDateTime__c>();
            EventDateTime__c evtDateTime1 = new EventDateTime__c(
	            event__c = event.Id, 
	            EventStatus__c = new List<String>(LNE_Constants.MASS_MANUAL_TICKET_COUNT_EVENT_STATUS)[0],
	            EventYear__c = String.valueOf(System.now().year() + 2),
	            Market__c = 'Chicago',
	            Venue__c = venue.Id,
	            Artists__c = artist.Name,
	            EventDate__c = System.today().addDays(2)
            );
            evtDateTimeList.add(evtDateTime1);

            EventDateTime__c evtDateTime2 = new EventDateTime__c(
	            event__c = event2.Id, 
	            EventYear__c = String.valueOf(System.now().year() + 2),
	            Market__c = 'Albany',
                EventDate__c = System.today().addDays(2)
            );
            evtDateTimeList.add(evtDateTime2);

        	insert evtDateTimeList;

        	evtDateTime2.Market__c = 'Albany';
        	update evtDateTime2;

        	//Insert Manual Ticket counts for event date times
        	List<ManualTicketCount__c> manualTicketCountList = new List<ManualTicketCount__c>();
        	for(Integer i = 1; i <= 10; i++){
        		ManualTicketCount__c newManualTicketCount = new ManualTicketCount__c();
        		newManualTicketCount.EventDateTime__c = evtDateTime1.Id;
        		newManualTicketCount.Comps__c = i;
        		newManualTicketCount.Holds__c = i;
        		newManualTicketCount.Kills__c = i;
        		newManualTicketCount.Open__c = i;
        		newManualTicketCount.TicketCount__c = i;
        		newManualTicketCount.TicketSalesDate__c = system.today();

        		manualTicketCountList.add(newManualTicketCount);
        	}
        	insert manualTicketCountList;

        	//Insert EventTicketAgency for event date times
        	List<EventTicketAgency__c> eventTicketAgencyList = new List<EventTicketAgency__c>();
        	
    		EventTicketAgency__c newEventTicketAgency1 = new EventTicketAgency__c();
    		newEventTicketAgency1.EventDateTime__c = evtDateTime1.Id;
    		newEventTicketAgency1.BypassValidation__c = true;
    		eventTicketAgencyList.add(newEventTicketAgency1);

    		EventTicketAgency__c newEventTicketAgency2 = new EventTicketAgency__c();
    		newEventTicketAgency2.EventDateTime__c = evtDateTime2.Id;
    		newEventTicketAgency2.BypassValidation__c = true;
    		eventTicketAgencyList.add(newEventTicketAgency2);

        	insert eventTicketAgencyList;

        	//Insert OnSaleDateTime for event date times
        	List<OnSaleDateTime__c> onSaleDateTimeList = new List<OnSaleDateTime__c>();
        	for(Integer i = 1; i <= 10; i++){
        		OnSaleDateTime__c newOnSaleDateTime1 = new OnSaleDateTime__c();
        		newOnSaleDateTime1.EventDateTime__c = evtDateTime1.Id;
        		newOnSaleDateTime1.SaleStartDate__c = system.today().addDays(-1);
        		newOnSaleDateTime1.EventTicketAgency__c = newEventTicketAgency1.Id;
        		onSaleDateTimeList.add(newOnSaleDateTime1);

        		OnSaleDateTime__c newOnSaleDateTime2 = new OnSaleDateTime__c();
        		newOnSaleDateTime2.EventDateTime__c = evtDateTime2.Id;
        		newOnSaleDateTime2.SaleStartDate__c = system.today().addDays(-1);
        		newOnSaleDateTime2.EventTicketAgency__c = newEventTicketAgency2.Id;
        		onSaleDateTimeList.add(newOnSaleDateTime2);
        	}
        	insert onSaleDateTimeList;

        	//Insert TicketScale for event date times
        	List<TicketScale__c> ticketScaleList = new List<TicketScale__c>();
        	for(Integer i = 1; i <= 10; i++){
        		TicketScale__c newTicketScale1 = new TicketScale__c();
        		newTicketScale1.EventDateTime__c = evtDateTime1.Id;
        		newTicketScale1.ActualSalesToDate__c = 1;
        		newTicketScale1.ActualGrossToDate__c = 2;
        		newTicketScale1.Price__c = 1;
        		newTicketScale1.ProjectedPaidTickets__c = 10;
        		newTicketScale1.Type__c = 'Platinum';
        		newTicketScale1.Event__c = event.Id;
        		newTicketScale1.StageType__c = 'Audit';
        		ticketScaleList.add(newTicketScale1);

        	}
        	insert ticketScaleList;

		}

        //-- whatever your setups, and you can make it as varied as you'd like.
        public void typicalSetup(Integer searchLimit){
            //Set search limit in general settings
            GeneralSettings__c results = new GeneralSettings__c(SearchLimit__c = searchLimit);
            insert results;
        }

        public void finalize(){
            //-- always should be called.
            
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
		} 
	}

    //-- test setups here to find out if errors have nothing to do with the test.
    static testMethod void runSetupAWithoutException() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(10);
        ts.finalize();
        System.assert( true, 'No Exceptions have occurred in getting here' );
    }

    //-- test functionality here
    static testMethod void testSearch() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(10);
        ts.finalize();
        
        test.startTest();
        	LNE_MassManualTicketCounts_C massManualTicketCountsController = new LNE_MassManualTicketCounts_C();
        	massManualTicketCountsController.runSearch();

        test.stopTest();

        System.assertNotEquals( NULL, massManualTicketCountsController.eventDateTimeWrapperList, 'The EventDateTime Wrapper should not be null' );
        System.assertEquals( 2, massManualTicketCountsController.eventDateTimeWrapperList.size(), '2 records should be returned by search' );
        System.assertEquals( 20, massManualTicketCountsController.eventDateTimeWrapperList[0].feedGrossSales, 'The aggregrate of ActualGrossToDate__c from related TicketScale should be 20' );
        System.assertEquals( 10, massManualTicketCountsController.eventDateTimeWrapperList[0].feedTicketCount, 'The aggregrate of ActualSalesToDate__c from related TicketScale should be 10' );    
    }

    static testMethod void testSelectiveSearch() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(10);
        ts.finalize();

        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue',  'Account.Artist'});         
        Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
        Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );

        test.startTest();
        	LNE_MassManualTicketCounts_C massManualTicketCountsController = new LNE_MassManualTicketCounts_C();
        	massManualTicketCountsController.eventDateTimeSearch.Market__c = 'Chicago';
        	//massManualTicketCountsController.eventDateTimeSearch.Venue__c = venue.Id;
        	massManualTicketCountsController.eventDateTimeSearch.Artists__c = 'Pennyback';
        	massManualTicketCountsController.eventDateTimeSearch.EventDate__c = system.today();
        	massManualTicketCountsController.eventDateTimeSearch.EventEndDate__c = system.today().addMonths(1);


        	massManualTicketCountsController.runSearch();

        	system.debug(LoggingLevel.ERROR, '@@@ massManualTicketCountsController.eventDateTimeWrapperList - ' + massManualTicketCountsController.eventDateTimeWrapperList);
        	Id eventDateTimeId = massManualTicketCountsController.eventDateTimeWrapperList[0].eventDateTime.Id;
            massManualTicketCountsController.eventDateTimeId = eventDateTimeId;
        	massManualTicketCountsController.getManualTicketCountList();
        	massManualTicketCountsController.saveManualTicketCountList();
            massManualTicketCountsController.instantiateNewManualTicketCount();
            LNE_MassManualTicketCounts_C.searchArtists('Pennyback');
            LNE_MassManualTicketCounts_C.searchVenues('Chicago');

        test.stopTest();

        System.assertNotEquals( NULL, massManualTicketCountsController.eventDateTimeWrapperList, 'The EventDateTime Wrapper should not be null' );
        System.assertEquals( 1, massManualTicketCountsController.eventDateTimeWrapperList.size(), '1 record should be returned by search' );
        System.assertEquals( 20, massManualTicketCountsController.eventDateTimeWrapperList[0].feedGrossSales, 'The aggregrate of ActualGrossToDate__c from related TicketScale should be 20'  );
        System.assertEquals( 10, massManualTicketCountsController.eventDateTimeWrapperList[0].feedTicketCount, 'The aggregrate of ActualSalesToDate__c from related TicketScale should be 10' );   
    }

    static testMethod void testSearchLimit() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup(10);
        ts.finalize();
        
        test.startTest();
        	LNE_MassManualTicketCounts_C massManualTicketCountsController = new LNE_MassManualTicketCounts_C();
        	massManualTicketCountsController.runSearch();
        test.stopTest();

       	//Assert limit exception message
       	List<ApexPages.Message> msgList = ApexPages.getMessages();
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
		    System.assertEquals(LNE_MassManualTicketCounts_C.TOO_MANY_RESULTS, msg.getSummary(), 'The page should return too many search results exception.');
		    break;
		}
    }
}