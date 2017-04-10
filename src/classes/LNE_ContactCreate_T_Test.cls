/**
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
 * @group unitTests
 */
@isTest
private class LNE_ContactCreate_T_Test {
	
	class TestSettings {
		
		String ROLE_BUSINESS_USER = 'Business User';
		String ROLE_BUSINESS_CONTACT = 'Business Contact';
		String MULTI_SEL_DELIMITER = ';';
		
		//-- instance values
		Account[] accounts;
		Contact[] oldContacts;
		Contact[] contacts;
		Map<Id,Contact> oldMap;
		AccountContactRole[] accountContactRoles;
		
		String[] selectedRoles;
				
		public TestSettings(){
			//-- initialize common custom settings.
			LNE_TestObjectFactory.prepStandardCustomSettings();

			//-- global setup here
			accounts = new Account[]{
				LNE_TestObjectFactory.createAccount( 'Acme1' ),
				LNE_TestObjectFactory.createAccount( 'Acme2' )
			};
			accounts[0].SourceSystemId__c = 'Acct-1010';
			accounts[1].SourceSystemId__c = 'Acct-1011';
			insert accounts;
			
			//-- these contacts will exist before we do anything with the new ones.
			oldContacts = new Contact[]{
				LNE_TestObjectFactory.createContact(
					accounts[0].id, 'OldContact1', 'Test'
				),
				LNE_TestObjectFactory.createContact(
					accounts[1].id, 'OldContact2', 'Test'
				)
			};
			insert oldContacts;
		}
		
		private String createMultiSelect( String[] values ){
			return( String.join( values, MULTI_SEL_DELIMITER ) );
		}
		
		public void typicalSetup(){
			selectedRoles = new String[]{
				ROLE_BUSINESS_CONTACT, ROLE_BUSINESS_USER
			};
			
			//-- specific setup here
			contacts = new Contact[]{
				new LNE_TestObjectFactory(
					LNE_TestObjectFactory.createContact( 
						accounts[0].id, 'My','Contact'
					)
				).addProperties( new Map<String,Object>{
					'Roles__c' => createMultiSelect( selectedRoles ),
					'SourceSystemId__c' => 'Cont-1010'
				}).buildContact()
			};
			
			oldMap = null;
		}
		
		public void updateSetup(){
		    typicalSetup();
		    insert contacts;
		    
		    oldMap = new Map<Id,Contact>( contacts.deepClone(true,true,true) );
		    
		    contacts[0].accountId =accounts[1].Id;
		}
		
		public void finalize(){
		}
	}
	
	//-- test test methods here
	static testMethod void runSetupAWithoutException() {
		try {
			TestSettings ts = new TestSettings();
			ts.typicalSetup();
			ts.finalize();
		} catch( Exception err ){
			System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
		}
	}
	
	static testMethod void runUpdateSetupWithoutException(){
	    try {
	        TestSettings ts = new TestSettings();
	        ts.updateSetup();
	        ts.finalize();
	    } catch( Exception err ){
	        System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
	    }
	}
	
	//-- test functionality here
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
		*/
		System.debug( 'prior to insert' );
		insert ts.contacts;
		
		Test.startTest();
		System.debug( 'starting the test' );
		
		AccountContactRelation[] results = LNE_ContactCreate_T.updateContactRelationships( ts.contacts, null );
		System.debug( 'results:' ); System.debug( results );
		System.assertNotEquals( results, null, 'updateContactRelations must return back some result' );
		System.assertEquals( 1, results.size(), 'expected a single ACR since a single contact was sent:' + results.size() );
		
		AccountContactRelation myRelation = results[0];
		System.assert( !String.isEmpty( myRelation.roles ), 'Some role should be set' );
		for( String oldRole : ts.selectedRoles ){
			System.assert( myRelation.Roles.contains( oldRole ), 'Role pre-selected[' + oldRole + '] was not found|' + myRelation.Roles + '|' );
		}
		
		Test.stopTest();
	}
	
	static testMethod void testExternalIdWasSet(){
	    TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();
		
		System.debug( 'prior to insert' );
		insert ts.contacts;
		
		Test.startTest();
		System.debug( 'start of test' );
		
		AccountContactRelation[] results = LNE_ContactCreate_T.updateContactRelationships( ts.contacts, null );
		System.debug( 'results:' ); System.debug( results );
		System.assertNotEquals( results, null, 'updateContactRelations must return back some result' );
		System.assertEquals( 1, results.size(), 'expected a single ACR since a single contact was sent:' + results.size() );
		
		AccountContactRelation myRelation = results[0];
		System.assert( !String.isEmpty( myRelation.ExternalId__c ), 'Some External Id must be set[' + myRelation.ExternalId__c  + ']' );
		
		Test.stopTest();
	}
	
	static testMethod void testUpdate(){
	    TestSettings ts = new TestSettings();
		ts.updateSetup();
		ts.finalize();
		
		AccountContactRelation[] oldACRs = [select id, ExternalId__c from AccountContactRelation where ContactId = :ts.contacts[0].Id and AccountId = :ts.accounts[0].Id ];
		System.assert( oldACRs != null, 'there should be at least one ACR returned' );
		System.assert( oldACRs.size() == 1, 'there should be a single ACR returned, since there is only one account set:' + oldACRs.size() );
		
		String oldExternalId = oldACRs[0].ExternalId__c;
		System.debug( 'oldExternalId:' + oldExternalId );
		
		System.debug( 'prior to update' );
		update ts.contacts;
		
		Test.startTest();
		System.debug( 'start of test' );
		
		AccountContactRelation[] results = [ select id, ExternalId__c, Roles from AccountContactRelation where contactId in :ts.contacts and AccountId = :ts.accounts[1].Id ];
		//AccountContactRelation[] results = LNE_ContactCreate_T.updateContactRelationships( ts.contacts, ts.oldMap );
		System.assertNotEquals( results, null, 'updateContactRelations must return back some result' );
		System.assertEquals( 1, results.size(), 'expected a single ACR since a single contact was updated:' + results.size() );
		
		AccountContactRelation myRelation = results[0];
		System.assert( !String.isEmpty( myRelation.ExternalId__c ), 'Some External Id must be set[' + myRelation.ExternalId__c  + ']' );
		System.assert( !myRelation.ExternalId__c.equals( oldExternalId ), 'since we changed the account, the externalId should also change[' + myRelation.ExternalId__c + '] old[' + oldExternalId + ']' );
		
		Test.stopTest();
	}

	static testMethod void testBypassAutomation(){
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

		GeneralSettings__c gs = [SELECT BypassAutomation__c FROM GeneralSettings__c];
		gs.BypassAutomation__c = true;
		update gs;

		/*
		This test is a bit difficult because the system automatically
		generates out the AccountContactRelationships
		and they cannot be generated beforehand - or without the contacts
		already existing.  For now, we will insert them,
		and verify that the roles are accurate.
		*/
		insert ts.contacts;
		
		Test.startTest();
		
		AccountContactRelation[] results = [ select id, ExternalId__c from AccountContactRelation where ContactId = :ts.contacts[0].Id ];
		System.assert( results != null, 'there should still be an account contact relation even if the trigger doesnt fire. not our code.' );
		System.assert( String.isEmpty( results[0].ExternalId__c ), 'ExternalId__c should be blank, because the code to set it, wasnt run' );
		
		Test.stopTest();
	}
}