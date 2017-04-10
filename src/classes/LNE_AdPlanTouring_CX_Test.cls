@isTest
public class LNE_AdPlanTouring_CX_Test {
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
            
            LNE_FinancialCalculator.currentlyRunning = true;
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

	            ticketScale = LNE_TestObjectFactory.createTicketScale(
	                event.Id, priceLevel, 100000, 100, 80000, 'Notes for ' + priceLevel, stageType);

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
	    public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			
        }
	}

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    @isTest
    static void testGetAdPlan(){
        TestSettings ts = new TestSettings(LNE_Constants.EVENT_STATUS_CONFIRMED);
        
        Test.startTest();
	        ApexPages.StandardController sc = new ApexPages.StandardController(ts.adPlan);
	        LNE_AdPlanTouring_CX cx = new LNE_AdPlanTouring_CX(sc);
	        cx.getAdPlan();
	        ts.finalize();
        Test.stopTest();
        
        system.assertNotEquals(NULL, cx.adPlanMetrics, 'Controller query should return an Ad Plan');
    }

}