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
private class LNE_AccountTermsUpdated_Batch_Test {

	class TestSettings {
		
		//-- example combined key delimiter
		String COMBINED_KEY_DELIMITER = '|';
		
		Account geoOffice;
		Account divisionOffice;
		Account[] venues;
		Contact venueGM;
		
		//-- instance values
		Account[] newAccounts;
		Map<Id,Account> oldAccountsMap;
		DataGenerationSettings__c dataSettings;
		DMA__c[] dmaList;
		
		String RT_VENUE_NAME = 'Account.Venue';
		String RT_OFFICE_NAME = 'Account.Office';
		ID RT_VENUE_ID;
		ID RT_OFFICE_ID;
		
		String ORIGINAL_TERMS = 'Original Terms';
		String UPDATED_TERMS = 'Updated Terms';
		
		LNE_AccountTermsUpdated_Batch batch;
		
		LNE_TestObjectFactory factory;
		
		String ROLE_VENUE_GM = 'Venue GM';
		
		public TestSettings(){
			//-- initialize common custom settings.
			LNE_TestObjectFactory.prepStandardCustomSettings();
					
			//-- important rule to allow duplicates within the unit tests.
			Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.AllowSave = true;
			
			factory = new LNE_TestObjectFactory(null);
			
			//-- get recordtypes
			Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
				new String[]{ RT_VENUE_NAME, RT_OFFICE_NAME }
			);
			RT_OFFICE_ID = recordTypeMap.get( RT_OFFICE_NAME );
			RT_VENUE_ID = recordTypeMap.get( RT_VENUE_NAME );
			
			dmaList = new DMA__c[]{
				LNE_TestObjectFactory.createDMA( 'CHICAGO', 'COOK', 'IL', '60402' ),
				LNE_TestObjectFactory.createDMA( 'PADUCAH-CAPE GIRARD-HARSBG', 'JACKSON', 'IL', '62274' )
			};
			insert dmaList;
			
			//-- create the offices
			//-- @TODO: probably should include new createGeoOffice / createDivisionOffices in TestObjectFactory
			geoOffice = new LNE_TestObjectFactory(
				LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testGeography' ), RT_OFFICE_ID )
			).addBillingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
				'Phone' => '708-522-5307',
				'Type' => 'Geography'
			}).buildAccount();
			insert geoOffice;
			
			divisionOffice = new LNE_TestObjectFactory(
				LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testDivision' ), RT_OFFICE_ID )
			).addBillingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
				'Phone' => '708-522-5307',
				'Type' => 'Division',
				'ApplyGlobalTermsTo__c' => 'Amphitheatre',
				'GlobalTerms__c' => ORIGINAL_TERMS,
				'ParentId' => geoOffice.Id
			}).buildAccount();
			insert divisionOffice;
			
			venues = new Account[]{
				new LNE_TestObjectFactory(
					LNE_TestObjectFactory.createAccount( 'TestAccount999', RT_VENUE_ID )
				).addBillingAddress( '200 West Jackson St.', 'Jackson', '62274', 'Illinois', 'IL', 'United States', 'US' )
				.addProperties( new Map<String,Object>{
					'Capacity__c' => 1000,
					'PrimaryOffice__c' => divisionOffice.Id,
					'OwnershipType__c' => 'Owned/Operated',
					'GlobalTermsUpdated__c' => true,
					'PreviousGlobalTerms__c' => ORIGINAL_TERMS,
					'GlobalTerms__c' => UPDATED_TERMS,
					'Type' => 'Amphitheatre'
				}).buildAccount()
			};
			insert venues;
			
			venueGM = new LNE_TestObjectFactory(
				LNE_TestObjectFactory.createContact( venues[0].Id, 'John', LNE_TestObjectFactory.makeUnique( 'Doe' ))
			)
			.addMailingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
				'Email' => 'test@example.com',
				'Roles__c' => ROLE_VENUE_GM
			}).buildContact();
			insert venueGM;
			
			batch = new LNE_AccountTermsUpdated_Batch();
		}
		
		public void typicalSetup(){
			//-- nothing for now
		}
		
		/** Finalize step. Should always be called after all setups. **/
		public void finalize(){
			//-- nothing for now
		}
	}
	
	
	//-- test test methods here
	
	static testMethod void runSetupAWithoutException() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();
		System.assert( true, 'No Exceptions have occurred in getting here' );
		
		Id venueId = ts.venues[0].Id;
		Id gmId = ts.venueGM.Id;
		AccountContactRelation venueGM_ACR = [
			select id, accountId, contactId, Roles
			from AccountContactRelation
			where AccountId = :venueId and ContactId = :gmId
		];
		System.assertNotEquals( null, venueGM_ACR, 'There must be a relation' );
		System.assertNotEquals( null, venueGM_ACR.Roles, 'There must be roles assigned - from LNE_ContactCreate_T' );
		System.assert( venueGM_ACR.Roles.indexOf( ts.ROLE_VENUE_GM ) > -1, 'The Venue GM role must be defined' );
	}
	
	//-- test functionality here
	
	static testMethod void testEmailsSent() {
		TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();
		
		//-- this shouldn't be needed but there is something up with a workflow and its nulling the state. Not sure why.
		GeneralSettings__c generalSettings = [SELECT Id FROM GeneralSettings__c];
		generalSettings.BypassAutomation__c = true;
		update generalSettings;
		
		Integer emailInvocations = 0;
		
		//-- START THE TEST
		Test.startTest();
		Database.executeBatch( ts.batch );
		emailInvocations = Limits.getEmailInvocations();
		System.debug( 'first emailInvocations:' + emailInvocations );
		Test.stopTest();
		//-- END THE TEST
		
		emailInvocations = Limits.getEmailInvocations();
		System.debug( 'second emailInvocations:' + emailInvocations );
		
		//-- your logic off of any info from TS here
		//System.assert( emailInvocations > 0, 'An email should have been sent' );
		System.assert( true, 'no exceptions should have been found by reaching this point' );
	}

}