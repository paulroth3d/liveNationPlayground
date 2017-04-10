@IsTest(SeeAllData=false)
private class LNE_SObjectFieldDefaulter_Test {

	static testMethod void test_SObjectFieldDefaulter() {

		Deal__c d = new Deal__c();
		LNE_SObjectFieldDefaulter.defaultDecimalFields(d);

		System.assertEquals(1, d.SplitBackendPercent__c);

	}

}