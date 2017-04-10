@isTest
public class LNE_EventStandardController_CX_Test {

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }

	@isTest
	public static void testLNE_ExpenseTabPage(){
		LNE_TestObjectFactory.createStandardDataSet();
		Event__c event = Database.query('select ' + String.join(LNE_Util.getFieldsForObject('Event__c'),',') + ' from Event__c limit 1');

		ApexPages.StandardController sc = new ApexPages.StandardController(event);
		LNE_EventStandardController_CX controller = new LNE_EventStandardController_CX(sc);
		
		PageReference pageRef = Page.LNE_ExpenseTab;

        Test.setCurrentPage(pageRef);
        
        controller.reloadRecord();

        controller.customSave();

        //TODO: assert business logic as needed
	}

	@isTest
	public static void testLNE_FinanceEventMetricsPage(){
		LNE_TestObjectFactory.createStandardDataSet();
		Event__c event = Database.query('select ' + String.join(LNE_Util.getFieldsForObject('Event__c'),',') + ' from Event__c limit 1');

		ApexPages.StandardController sc = new ApexPages.StandardController(event);
		LNE_EventStandardController_CX controller = new LNE_EventStandardController_CX(sc);
		
		PageReference pageRef = Page.LNE_FinanceEventMetrics;

        Test.setCurrentPage(pageRef);
        
        controller.reloadRecord();

        controller.customSave();

        //TODO: assert business logic as needed
		
	}

	@isTest
	public static void testLNE_FinanceSummaryPage(){
		LNE_TestObjectFactory.createStandardDataSet();
		Event__c event = Database.query('select ' + String.join(LNE_Util.getFieldsForObject('Event__c'),',') + ' from Event__c limit 1');

		ApexPages.StandardController sc = new ApexPages.StandardController(event);
		LNE_EventStandardController_CX controller = new LNE_EventStandardController_CX(sc);
		
		PageReference pageRef = Page.LNE_FinanceSummary;

        Test.setCurrentPage(pageRef);
        
        controller.reloadRecord();

        controller.customSave();

        //TODO: assert business logic as needed
		
	}
}