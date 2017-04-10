@isTest
public class LNE_SettlementReportSetupTab_CX_Test {
	
	static final String RT_VENDOR = 'Account.Vendor';
	static final String RT_Rental = 'Event__c.Rental';
    static final String RT_Hold = 'Event__c.Hold';

    class TestSettings {
    	public Event__c event;

    	public TestSettings(){

    		LNE_TestObjectFactory.createStandardDataSet();

	        this.event = Database.query('select ' + String.join(LNE_Util.getFieldsForObject('Event__c'),',') + ' from Event__c limit 1');
	    }
    }

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    @isTest
    static void testSettlementReportSetupTab(){
        TestSettings ts = new TestSettings();
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.event);
        LNE_SettlementReportSetupTab_CX cx = new LNE_SettlementReportSetupTab_CX(sc);
        cx.startSettlement();

        //TODO: Add Assertions
    }

    static testMethod void testScenario() {
        TestSettings ts = new TestSettings();
        Test.startTest();
        
        Event__c testEvent = [select Id from Event__c limit 1];
        Deal__c testDeal = [select Id from Deal__c where Event__c = :testEvent.Id limit 1];

        PageReference pr = Page.LNE_EventOfferSheet;
        pr.getParameters().put('id', testEvent.Id);
        Test.setCurrentPage(pr);

        ApexPages.StandardController sc = new ApexPages.StandardController(testEvent);
        LNE_SettlementReportSetupTab_CX cx = new LNE_SettlementReportSetupTab_CX(sc);

        cx.selectedDealIds = testDeal.Id;
        cx.saveDeals();
        
    }

}