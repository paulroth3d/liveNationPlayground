@isTest
public class LNE_SettlementVenueRecapTab_CX_Test {

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
    static void testSettlementVenueRecapTab(){
        TestSettings ts = new TestSettings();
        ApexPages.StandardController sc = new ApexPages.StandardController(ts.event);
        LNE_SettlementVenueRecapTab_CX cx = new LNE_SettlementVenueRecapTab_CX(sc);
        cx.startSettlement();

        //TODO: Add Assertions
    }

}