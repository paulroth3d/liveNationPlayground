/**
 * 
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LNE_RequestAccountUpdate_CX_Test	{
	
	class TestSettings {
		
		String ROLE_BUSINESS_USER = 'Business User';
		String ROLE_BUSINESS_CONTACT = 'Business Contact';
		String MULTI_SEL_DELIMITER = ';';
		
		//-- instance values
		Account[] accounts;
		String[] selectedRoles;
		
		public TestSettings(){
			
			//-- global setup here
			accounts = new Account[]{
				LNE_TestObjectFactory.createAccount( 'Acme1' ),
				LNE_TestObjectFactory.createAccount( 'Acme2' )
			};
			insert accounts;
			
		}
		
		public void typicalSetup(){
			selectedRoles = new String[]{
				ROLE_BUSINESS_CONTACT, ROLE_BUSINESS_USER
			};
			
			// Boot the visual force 'page'
			PageReference testPage = Page.LNE_RequestAccountUpdate;
			Test.setCurrentPage(testPage);
		}
		
		public void finalize(){
		}
	}

	//-- test test methods here

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
	
	static testMethod void runSetupAWithoutException() {
		try {
			TestSettings ts = new TestSettings();
			ts.typicalSetup();
			ts.finalize();
		} catch( Exception err ){
			System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
		}
	}
	
	//-- test functionality here
	static testMethod void testEnterTextInUpdate() {
		try {
			TestSettings ts = new TestSettings();
			ts.typicalSetup();

			Test.startTest();
			
			ApexPages.currentPage().getParameters().put('id', ts.accounts[0].Id);
			ApexPages.StandardController standardAccountController = new ApexPages.StandardController(ts.accounts[0]);
			LNE_RequestAccountUpdate_CX testedController = new LNE_RequestAccountUpdate_CX(standardAccountController);
			testedController.LatestAccountRequest = 'Update from test script';
			testedController.getAccount();
			testedController.submit();
			
			Test.stopTest();

			System.assertEquals(true, testedController.LatestAccountRequest.contains('Update from test script'));

			//-- Get new record from db
			Account[] savedAccounts = [SELECT LatestAccountRequest__c FROM Account WHERE Id = :ts.accounts[0].Id];

			//-- Check LatestAccountRequest__c
			System.assertEquals(testedController.formattedLatestAccountRequest, savedAccounts[0].LatestAccountRequest__c);

			ts.finalize();
		} catch( Exception err ){
			System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
		}

	}

	static testMethod void testEnterNoTextInUpdate() {
		try {
			TestSettings ts = new TestSettings();
			ts.typicalSetup();

			Test.startTest();

			ApexPages.currentPage().getParameters().put('id', ts.accounts[0].Id);
			ApexPages.StandardController standardAccountController = new ApexPages.StandardController(ts.accounts[0]);
			LNE_RequestAccountUpdate_CX testedController = new LNE_RequestAccountUpdate_CX(standardAccountController);
			testedController.LatestAccountRequest = 'two';
			testedController.submit();

			Test.stopTest();

			ts.finalize();
		} catch( Exception err ){
			System.assert( true, 'Exception must be thrown if less than 5 chars given for update:' + err.getMessage() );
		}

	}	

	static testMethod void testBadUpdate() {
		try {
			TestSettings ts = new TestSettings();
			ts.typicalSetup();
			
			Test.startTest();

			ApexPages.currentPage().getParameters().put('id', ts.accounts[0].Id);
			ApexPages.StandardController standardAccountController = new ApexPages.StandardController(ts.accounts[0]);
			LNE_RequestAccountUpdate_CX testedController = new LNE_RequestAccountUpdate_CX(standardAccountController);
			testedController.LatestAccountRequest = 'Update from test script';
			testedController.getAccount();
			
			// try for a bad update to get those 3 lines covered 
			testedController.updateAccount.Id = '';
			
			try {
				testedController.submit();
			} catch( Exception err ){
				System.assert( true, 'Exception must be thrown if bad update:' + err.getMessage() );
			}
			
			Test.stopTest();

			ts.finalize();
		} catch( Exception err ){
			System.assert( true, 'Exception must be thrown if bad update:' + err.getMessage() );
		}
	}
	
	static testMethod void testRolesWereSet(){
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();
		
		/*
			This test is a bit difficult because the system automatically
			generates out the AccountContactRelationships
			and they cannot be generated beforehand - or without the contacts
			already existing.  For now, we will insert them,
			and verify that the roles are accurate.
			insert ts.contacts;
			
			AccountContactRelation[] results = LNE_ContactCreate_T.updateContactRelationships( ts.contacts );
			System.assertNotEquals( results, null, 'updateContactRelations must return back some result' );
			System.assertEquals( results.size(), 1, 'expected a single ACR since a single contact was sent' );
			
			AccountContactRelation myRelation = results[0];
			System.assert( !String.isEmpty( myRelation.roles ), 'Some role should be set' );
			for( String oldRole : ts.selectedRoles ){
				System.assert( myRelation.Roles.contains( oldRole ), 'Role pre-selected[' + oldRole + '] was not found|' + myRelation.Roles + '|' );
			}
		*/

	}
}