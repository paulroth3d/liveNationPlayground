/**
 * Created by JK on 1/12/17.
 */
@isTest
public with sharing class LNE_PromoScale_T_Test {

    static final String RT_VENDOR = 'Account.Vendor';
    static final String RT_Rental = 'Event__c.Rental';
    static final String RT_Hold = 'Event__c.Hold';

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    class TestSettings {
    	
        public Adplan__c adPlan;
        Account vendor;
        List<TicketScale__c> ticketScales = new List<TicketScale__c>();
        List<TicketScale__c> planTicketScales = new List<TicketScale__c>();
        List<TicketScale__c> projectionTicketScales = new List<TicketScale__c>();
        List<String> eventPlanStatuses = new List<String>(LNE_Constants.TICKET_SCALE_PLAN_EVENT_STATUSES);
        List<PromoScale__c> promoScales = new List<PromoScale__c>();
        List<PromoPromoScale__c> promoPromoScales = new List<PromoPromoScale__c>();

        public TestSettings() {
        	
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );

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
			
			//-- @TODO: a vendor SHOULDN'T really be used as an office for an event. Is this actually what we want here?
            vendor = LNE_TestObjectFactory.createAccount('Test Vendor');
            vendor.RecordTypeId = RT_VENDOR_ID;
            vendor.Format__c = 'Country';
            vendor.Market__c = 'San Francisco';
            
            LNE_TestObjectFactory.VenueHierarchy acctHierarchy = LNE_TestObjectFactory.createVenueHierarchy(
            	LNE_TestObjectFactory.ACCT_TYPE_DIVISION, null, vendor
            );

            //insert event
            Event__c event = new Event__c(
                Venue__c = vendor.Id,
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Status__c = LNE_Constants.EVENT_STATUS_CONFIRMED,
                RecordTypeId = RT_Rental_ID
            );

            LNE_TestObjectFactory.createStandardDataSet( event, acctHierarchy );

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

            //create promotion
            Date promoStartDate = Date.today();
            Promotions__c promotion = new Promotions__c(
                Vendor__c = vendor.Id,
                StartDate__c = promoStartDate,
                EndDate__c = promoStartDate.addDays(1),
                PromoValue__c = 1000,
                AdPlan__c = adPlan.Id,
                Market__c = 'San Francisco'
            );

            insert promotion;

            //create promoPromoScales
            PromoPromoScale__c promoPromoScale;

            for(Integer i=0; i<promoScales.size(); i++){
                promoScale = promoScales[i];
                promoPromoScale = new PromoPromoScale__c(
                    Promo_Scale__c = promoScale.Id,
                    Promotions__c = promotion.Id,
                    NumberofTickets__c = 1 + Math.round(Math.random()*1000)
                );

                promoPromoScales.add(promoPromoScale);

            }

            insert promoPromoScales;

        }

        public void typicalSetup() {

        }


        public void finalize() {
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
        }
    }

    @isTest
    public static void testCalculateTotalTicketValues(){

        TestSettings ts = new TestSettings();
        ts.typicalSetup();

        for(PromoScale__c ps : ts.promoScales){
            ps.Price__c = Math.round(1 + (Math.random() * 1000));
        }

        update ts.promoScales;

        List<PromoPromoScale__c> promoPromoScales = [Select Price__c, NumberOfTickets__c, TicketValue__c from PromoPromoScale__c];

        System.assert(promoPromoScales.size()>0, 'Unable to locate PromoPromoScale__c records.');

        Decimal expectedTicketValue = 0;

        for(PromoPromoScale__c pps: promoPromoScales){
            expectedTicketValue = pps.Price__c * pps.NumberOfTickets__c;
            System.assert(expectedTicketValue>0, 'expectedTicketValue should be greater than 0.');
            System.assertEquals(expectedTicketValue, pps.TicketValue__c, 'Unexpected value found for PromoPromoScale__c.TicketValue__c');
        }



    }

}