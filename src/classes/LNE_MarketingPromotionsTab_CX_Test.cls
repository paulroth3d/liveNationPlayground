/**
 * Created by JK on 1/7/17.
 */
@isTest
public with sharing class LNE_MarketingPromotionsTab_CX_Test {
    
    static final String RT_VENDOR = 'Account.Vendor';
    static final String RT_Rental = 'Event__c.Rental';
    static final String RT_Hold = 'Event__c.Hold';

    class TestSettings {

        public Adplan__c adPlan;
        List<TicketScale__c> ticketScales = new List<TicketScale__c>();
        List<TicketScale__c> planTicketScales = new List<TicketScale__c>();
        List<TicketScale__c> projectionTicketScales = new List<TicketScale__c>();
        List<String> eventPlanStatuses = new List<String>(LNE_Constants.TICKET_SCALE_PLAN_EVENT_STATUSES);
        List<PromoScale__c> promoScales = new List<PromoScale__c>();

        public TestSettings(String eventStatus) {

            //create an event
            //need record types to create an event
            Map<String,Id> eventRecordTypeMap = LNE_Util.getRecordTypes(
                    new String[]{ RT_Rental, RT_Hold}
            );

            //get event record types
            Id RT_Rental_ID = eventRecordTypeMap.get( RT_Rental );
            Id RT_Hold_ID = eventRecordTypeMap.get( RT_Hold );

            //create vendor
            Map<String,Id> accountRecordTypeMap = LNE_Util.getRecordTypes(
                    new String[]{RT_VENDOR}
            );

            ID RT_VENDOR_ID = accountRecordTypeMap.get(RT_VENDOR);

            Account vendor = LNE_TestObjectFactory.createAccount('Test Vendor');
            vendor.RecordTypeId = RT_VENDOR_ID;
            vendor.Format__c = 'Country';
            vendor.Market__c = 'San Francisco';

            insert vendor;

            //insert event
            Event__c event = new Event__c(
                Venue__c = vendor.Id,
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Status__c = eventStatus,
                RecordTypeId = RT_Rental_ID
            );

            //insert event;
            LNE_TestObjectFactory.createStandardDataSet( event );

            //create ticket scales for the event
            TicketScale__c ticketScale;
            String priceLevel;
            Boolean isPlan;
            String stageType;

            for(Integer i=0; i<10; i++){

                //plan or projection
                isPlan = Math.round(Math.random()*1)==1;

                if(isPlan){
                    stageType = LNE_Constants.TICKET_SCALE_STAGE_TYPE_PLAN;
                }else{
                    stageType = LNE_Constants.TICKET_SCALE_STAGE_TYPE_PROJECTION;
                }

                priceLevel = 'TEST_' + Math.round(Math.random()*1000);

                ticketScale = new TicketScale__c(
                    Capacity__c = 100000,
                    Event__c = event.Id,
                    PriceLevel__c = priceLevel,
                    Price__c = 100,
                    ProjectedPaidTickets__c = 80000,
                    Notes__c = 'Notes for ' + priceLevel,
                    StageType__c = stageType
                );

                ticketScales.add(ticketScale);

                if(isPlan){
                    planTicketScales.add(ticketScale);
                }else{
                    projectionTicketScales.add(ticketScale);
                }
            }

            insert ticketScales;

            //create an adplan
            //insert adplan
            adPlan = new AdPlan__c(
                AdPlanName__c = 'Test Ad Plan',
                LNEAdPlanBudget__c = 1000000,
                Event__c = event.Id
            );

            insert adPlan;

            //create promo scales for adplan
            PromoScale__c promoScale;

            for(Integer i=0; i<4; i++){
                promoScale = new PromoScale__c(
                    Description__c = ticketScales[i].Notes__c,
                    Name = ticketScales[i].PriceLevel__c,
                    Price__c = ticketScales[i].Price__c,
                    TicketScale__c = ticketScales[i].Id,
                    AdPlan__c = adPlan.Id
                );

                promoScales.add(promoScale);
            }

            insert promoScales;

        }

        public void typicalSetup() {

        }


        public void finalize() {
        }
    }

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    private static void testConstructorBase(String eventStatus){
        TestSettings ts = new TestSettings(eventStatus);
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.adPlan);
        LNE_MarketingPromotionsTab_CX cx = new LNE_MarketingPromotionsTab_CX(sc);

        System.assertNotEquals(null, cx.adPlan, 'The controller does not have an AdPlan__c record.');
        System.assertEquals(ts.adPlan.Id, cx.adPlan.Id, 'The controller contains an incorrect AdPlan__c record.');
        System.assertEquals(ts.promoScales.size(), cx.promoScales.size(), 'The controller contains an incorrect number of promotion scales.');

        if(eventStatus==LNE_Constants.EVENT_STATUS_DRAFT){
            System.assertEquals(ts.planTicketScales.size(), cx.ticketScales.size(), 'The controller contains an incorrect number of ticket scales.');
        }else{
            System.assertEquals(ts.projectionTicketScales.size(), cx.ticketScales.size(), 'The controller contains an incorrect number of ticket scales.');
        }
    }

    @isTest
    static void testConstructorPlanPhase(){
        testConstructorBase(LNE_Constants.EVENT_STATUS_DRAFT);
    }

    @isTest
    static void testConstructorProjectionPhase(){
        testConstructorBase(LNE_Constants.EVENT_STATUS_CONFIRMED);
    }

    @isTest
    static void testSavePromoScale(){
        TestSettings ts = new TestSettings(LNE_Constants.EVENT_STATUS_CONFIRMED);
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.adPlan);
        LNE_MarketingPromotionsTab_CX cx = new LNE_MarketingPromotionsTab_CX(sc);

        PromoScale__c promoScale = cx.promoScales[0];

        promoScale.Name = 'Changed Name';
        promoScale.Description__c = 'Changed Description';

        LNE_MarketingPromotionsTab_CX.savePromoScale(promoScale);

        PromoScale__c savedPromoScale = [Select Name, Description__c from PromoScale__c where Id = :promoScale.Id];

        System.assertEquals(promoScale.Name, savedPromoScale.Name);
        System.assertEquals(promoScale.Description__c, savedPromoScale.Description__c);

    }

}