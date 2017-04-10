@isTest
public class LNE_RestartSettlement_CX_Test {

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

    @isTest
    public static void testLNE_RestartSettlement_CX(){
    	LNE_TestObjectFactory.createStandardDataSet();

	    Event__c event = Database.query('select ' + String.join(LNE_Util.getFieldsForObject('Event__c'),',') + ' from Event__c limit 1');

	    LNE_RestartSettlement_CX.restartSettlement(event.id);

	    //TODO: add assertions to test business logic as needed
    }

}