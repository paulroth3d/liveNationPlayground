@isTest
private class LNE_OfficeVenuePromoterPicker_CC_Test {

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet();
        LNE_GeneralSettingsUtil.setLocalBypassSettings(false, true, false);
    }

	class TestSettings {
        Event__c event;
        Account office;
        Account venue;
        Map<String,Id> recordTypeMap;
        
        public TestSettings() {
            LNE_FinancialCalculator.currentlyRunning = true;
            LNE_FinancialCalculator.pushRunningTrigger( 'LNE_EventDateTimeUtil_T_Test' );

            recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue', 'Account.Office', 'Account.Artist', 'Event__c.PromotedShow', 'Event__c.Rental', 'Event__c.Hold'});         
            Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
            Id RT_ACCOUNT_OFFICE_ID = recordTypeMap.get( 'Account.Office' );
            Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );
            Id RT_EVENT_PROMOTEDSHOW_ID = recordTypeMap.get( 'Event__c.PromotedShow' ); 
            Id RT_Rental_ID = recordTypeMap.get( 'Event__c.Rental' );
            Id RT_Hold_ID = recordTypeMap.get( 'Event__c.Hold' );

            event = [SELECT Id FROM Event__c LIMIT 1];

            office = [SELECT Name FROM Account WHERE RecordTypeId = :RT_ACCOUNT_OFFICE_ID AND ParentId <> NULL LIMIT 1];
            venue = [SELECT Id FROM Account WHERE RecordTypeId = :RT_ACCOUNT_VENUE_ID LIMIT 1];
        }
        
        public void typicalSetup(){
        	PermissionSet testPS = [SELECT Id FROM PermissionSet WHERE Name = 'Booking' LIMIT 1];
            List<PermissionSetAssignment> pseList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId() AND PermissionSetId=:testPS.Id];

            if (pseList.size() == 0) {
                PermissionSetAssignment pse = new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId=testPS.Id);
                insert pse;
            }
        	

        	Group g = new Group(Name=office.Name + ' Booking');
        	insert g;

        	GroupMember gm = new GroupMember();
        	gm.GroupId = g.Id;
        	gm.UserOrGroupId = UserInfo.getUserId();
        	insert gm;
        }
        
        public void finalize(){
        }
    }

    static LNE_PromoterCreateEvent_CX setupCtrlForNew(Event__c evnt, id eventRecordTypeId) {
        ApexPages.currentPage().getParameters().put(LNE_PromoterCreateEvent_CX.PARAM_RECORD_TYPE, eventRecordTypeId);
        ApexPages.currentPage().getParameters().put('save_new', '1');

        ApexPages.StandardController standardEventCtlr = new ApexPages.StandardController(evnt);        
        LNE_PromoterCreateEvent_CX controller = new LNE_PromoterCreateEvent_CX( standardEventCtlr );

        return controller;
    }

    @isTest static void testGroups() {
    	TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();

        Id RT_EVENT_PROMOTEDSHOW_ID = ts.recordTypeMap.get( 'Event__c.PromotedShow' );  
        LNE_PromoterCreateEvent_CX parentController = setupCtrlForNew(ts.event, RT_EVENT_PROMOTEDSHOW_ID);

        Test.startTest();

        LNE_OfficeVenuePromoterPicker_CC controller = new LNE_OfficeVenuePromoterPicker_CC();
        controller.originalEventVenueId = parentController.originalEventVenueId;

        List<User> users = LNE_OfficeVenuePromoterPicker_CC.getPromoters(ts.office.Name);
        system.assert(users.size() > 0);
    }
}