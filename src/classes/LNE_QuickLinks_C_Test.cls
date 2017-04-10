@isTest
public class LNE_QuickLinks_C_Test {

	@TestSetup
	static void setup() {

		// create some custom permissions
		system.debug([select DeveloperName from CustomPermission]);

		//create a quick link
		QuickLink__c ql0 = LNE_TestObjectFactory.createQuickLink('String Name', 'String ExternalId', 'URL', 'String Target', 'String Description');
		QuickLink__c ql1 = LNE_TestObjectFactory.createQuickLink('String Name1', 'String ExternalId2', 'URL', 'String Target4', 'String Description5');
		ql1.Permission__c = 'RomeAdmin';
		insert new List<QuickLink__c> { ql0, ql1 };

	}

	static testMethod void test_QuickLinks() {

		List<QuickLink__c> links = LNE_QuickLinks_C.getMyLinks();

	}

}