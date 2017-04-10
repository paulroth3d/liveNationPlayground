@isTest
public with sharing class LNE_PromoterCreateEvent_CX_Test {
    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet();
    }

	class TestSettings {
        DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();

        Event__c testEventNew;
        Event__c testEventExisting;
        Account primaryHeadliner;
        Account office;
        Account venue;
        Map<String,Id> recordTypeMap;

        public TestSettings() {
            LNE_FinancialCalculator.currentlyRunning = true;
            LNE_FinancialCalculator.pushRunningTrigger( 'LNE_EventDateTimeUtil_T_Test' );
            LNE_GeneralSettingsUtil.setLocalBypassSettings(false, true, false);

            recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue', 'Account.Office', 'Account.Artist', 'Event__c.PromotedShow', 'Event__c.Rental', 'Event__c.Hold'});         
            Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
            Id RT_ACCOUNT_OFFICE_ID = recordTypeMap.get( 'Account.Office' );
            Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );
            Id RT_EVENT_PROMOTEDSHOW_ID = recordTypeMap.get( 'Event__c.PromotedShow' );	
			Id RT_Rental_ID = recordTypeMap.get( 'Event__c.Rental' );
			Id RT_Hold_ID = recordTypeMap.get( 'Event__c.Hold' );

            testEventNew = new Event__c();
            testEventExisting = [SELECT Id FROM Event__c LIMIT 1];
            testEventExisting.RecordTypeId = RT_EVENT_PROMOTEDSHOW_ID;
            update testEventExisting;

            primaryHeadliner = [SELECT Id FROM Account WHERE RecordTypeId = :RT_ACCOUNT_ARTIST_ID LIMIT 1];
            office = [SELECT Id FROM Account WHERE RecordTypeId = :RT_ACCOUNT_OFFICE_ID AND ParentId <> NULL LIMIT 1];
            venue = [SELECT Id FROM Account WHERE RecordTypeId = :RT_ACCOUNT_VENUE_ID LIMIT 1];

            EventDateTime__c eventDateTime = new EventDateTime__c(
                Event__c = testEventExisting.Id, 
                EventYear__c = String.valueOf(System.now().year() + 2),
                EventDate__c = System.today().addDays(10),
                StartTime__c = '6:00 PM');

            EventDateTime__c eventDateTime2 = new EventDateTime__c(
                Event__c = testEventExisting.Id, 
                EventYear__c = String.valueOf(System.now().year() + 2),
                EventDate__c = System.today().addDays(11),
                StartTime__c = '8:00 PM');

            insert new List<EventDateTime__c>{eventDateTime,eventDateTime2};

            TicketScale__c ticketScale = new TicketScale__c();
            ticketScale.Type__c = 'Reserved';
            ticketScale.Capacity__c = 1000;
            ticketScale.Price__c = 100.00;
            ticketScale.Kills__c = 0;
            ticketScale.Comps__c = 0;
            ticketScale.ProjectedPaidTickets__c = 950;
            ticketScale.Event__c = testEventExisting.Id;
            ticketScale.LiftBeforeFee__c = 0;
            ticketScale.TMFeePercent__c = 0.0;
            ticketScale.StageType__c = 'Plan';
            ticketScale.EventDateTime__c = eventDateTime.Id;

            TicketScale__c ticketScale2 = new TicketScale__c();
            ticketScale2.Type__c = 'Lawn';
            ticketScale2.Capacity__c = 1000;
            ticketScale2.Price__c = 100.00;
            ticketScale2.Kills__c = 0;
            ticketScale2.Comps__c = 0;
            ticketScale2.ProjectedPaidTickets__c = 950;
            ticketScale2.Event__c = testEventExisting.Id;
            ticketScale2.LiftBeforeFee__c = 0;
            ticketScale2.TMFeePercent__c = 0.0;
            ticketScale2.StageType__c = 'Plan';
            ticketScale2.EventDateTime__c = eventDateTime.Id;

            TicketScale__c ticketScale3 = new TicketScale__c();
            ticketScale3.Type__c = 'Platinum';
            ticketScale3.Capacity__c = 100;
            ticketScale3.Price__c = 100.00;
            ticketScale3.Kills__c = 0;
            ticketScale3.Comps__c = 0;
            ticketScale3.ProjectedPaidTickets__c = 100;
            ticketScale3.Event__c = testEventExisting.Id;
            ticketScale3.LiftBeforeFee__c = 7420.00;
            ticketScale3.TMFeePercent__c = 0.0;
            ticketScale3.StageType__c = 'Plan';
            ticketScale3.EventDateTime__c = eventDateTime.Id;

            insert new List<TicketScale__c>{ticketScale,ticketScale2,ticketScale3};

            String ticketScaleList = ticketScale.Id + DATA_SETTINGS.CombinedKeyDelimiter__c + ticketScale2.Id + DATA_SETTINGS.CombinedKeyDelimiter__c + ticketScale3.Id;

            Deduction__c deduction = new Deduction__c();
            deduction.BeforeAfter__c = 'Before Adjusted';
            deduction.Event__c = testEventExisting.Id;
            deduction.RateType__c = 'Primary Multiplier Tax';
            deduction.AmountRate__c = 10;
            deduction.TicketScaleList__c = ticketScaleList;

            Deduction__c deduction2 = new Deduction__c();
            deduction2.BeforeAfter__c = 'Before Adjusted';
            deduction2.Event__c = testEventExisting.Id;
            deduction2.RateType__c = 'Primary Divider Tax';
            deduction2.AmountRate__c = 10;
            deduction2.TicketScaleList__c = ticketScaleList;

            insert new List<Deduction__c>{deduction,deduction2};
        }
        
        public void typicalSetup(){}
        
        public void finalize(){}
    }

	static LNE_PromoterCreateEvent_CX setupCtrlForNew(Event__c evnt, id eventRecordTypeId) {
		ApexPages.currentPage().getParameters().put(LNE_PromoterCreateEvent_CX.PARAM_RECORD_TYPE, eventRecordTypeId);
        ApexPages.currentPage().getParameters().put('save_new', '1');

        ApexPages.StandardController standardEventCtlr = new ApexPages.StandardController(evnt);    	
    	LNE_PromoterCreateEvent_CX controller = new LNE_PromoterCreateEvent_CX( standardEventCtlr );

		return controller;
	}

    static LNE_PromoterCreateEvent_CX setupCtrlForClone(Event__c evnt, id eventRecordTypeId) {
        ApexPages.currentPage().getParameters().put(LNE_PromoterCreateEvent_CX.PARAM_RECORD_TYPE, eventRecordTypeId);
        ApexPages.currentPage().getParameters().put('clone', '1');
        ApexPages.currentPage().getParameters().put('Id', evnt.Id);

        ApexPages.StandardController standardEventCtlr = new ApexPages.StandardController(evnt);        
        LNE_PromoterCreateEvent_CX controller = new LNE_PromoterCreateEvent_CX( standardEventCtlr );

        return controller;
    }

    static testMethod void testController() {
    	TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		Id RT_EVENT_PROMOTEDSHOW_ID = ts.recordTypeMap.get( 'Event__c.PromotedShow' );	
		Test.startTest();
		
       	LNE_PromoterCreateEvent_CX controller = setupCtrlForNew(ts.testEventNew, RT_EVENT_PROMOTEDSHOW_ID);

        controller.vTargetYear = String.valueOf(System.now().year() + 1);
        controller.vPrimaryHeadlinerArtist = ts.primaryHeadliner.Id;
        controller.vOffice = ts.office.Id;
        controller.vVenue = ts.venue.Id;
        controller.vPromoter = UserInfo.getUserId();

        controller.restart();
        system.assertEquals(RT_EVENT_PROMOTEDSHOW_ID, controller.currentRecordType.Id);

    	Test.stopTest();
    }

    static testMethod void testController_Error() {
    	TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();
       
       	Id RT_EVENT_PROMOTEDSHOW_ID = ts.recordTypeMap.get( 'Event__c.PromotedShow' );
    	Test.startTest();
		
       	LNE_PromoterCreateEvent_CX controller = setupCtrlForNew(ts.testEventNew, RT_EVENT_PROMOTEDSHOW_ID);
        system.assertEquals(RT_EVENT_PROMOTEDSHOW_ID, controller.currentRecordType.Id);
    	
    	controller.confirm();

		Test.stopTest();
    }

    static testMethod void testController_Clone() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
       
        Id RT_EVENT_PROMOTEDSHOW_ID = ts.recordTypeMap.get( 'Event__c.PromotedShow' );  
        Test.startTest();
        
        LNE_PromoterCreateEvent_CX controller = setupCtrlForClone(ts.testEventExisting, RT_EVENT_PROMOTEDSHOW_ID);
        controller.vTargetYear = String.valueOf(System.now().year() + 1);
        controller.vPrimaryHeadlinerArtist = ts.primaryHeadliner.Id;
        controller.vOffice = ts.office.Id;
        controller.vVenue = ts.venue.Id;
        controller.vPromoter = UserInfo.getUserId();
        
        controller.confirm();

        List<Event__c> events = [SELECT Id FROM Event__c];
        system.assertEquals(1, events.size());

        controller.vTargetYear = String.valueOf(System.now().year() + 1);
        controller.vPrimaryHeadlinerArtist = ts.primaryHeadliner.Id;
        controller.clonedEventName = 'Cloned Event 1234';
        controller.vOffice = ts.office.Id;
        controller.vVenue = ts.venue.Id;
        controller.vPromoter = UserInfo.getUserId();
        controller.headlinerArtist.Artist__c = ts.primaryHeadliner.Id;
        controller.eventDateTime.EventYear__c = String.valueOf(System.now().year() + 1);
        controller.confirmClone();

        Test.stopTest();

        events = [SELECT Id FROM Event__c];
        system.assertEquals(2, events.size());
    }
}