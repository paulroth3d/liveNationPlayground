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
 */
@isTest
private class LNE_AccountDMA_Autoassign_T_Test {
	
	class TestSettings {
		
		//-- example combined key delimiter
		String COMBINED_KEY_DELIMITER = '|';
		
		Account geoOffice;
		Account divisionOffice;
		
		//-- instance values
		Account[] newAccounts;
		Map<Id,Account> oldAccountsMap;
		DataGenerationSettings__c dataSettings;
		DMA__c[] dmaList;
		
		String RT_VENUE_NAME = 'Account.Venue';
		String RT_OFFICE_NAME = 'Account.Office';
		ID RT_VENUE_ID;
		ID RT_OFFICE_ID;
		
		LNE_TestObjectFactory factory;
		
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
				'GlobalTerms__c' => 'Global Terms',
				'ParentId' => geoOffice.Id
			}).buildAccount();
			insert divisionOffice;
		}
		
		/** Refreshes the accounts to include the updated values. **/
		public void refreshAccounts(){
			Map<Id, Account> updatedMap = new Map<Id,Account>(
				[
					select id, Name, DMA__c
					from Account
					where id in : newAccounts
				]
			);
			
			Account[] updatedAccounts = new Account[]{};
			Account newAccount = null;
			for( integer i = 0; i < newAccounts.size(); i++ ){
				newAccount = newAccounts[i];
				System.assert( updatedMap.containsKey( newAccount.Id ), 'All accounts created should be found again when refreshed' );
				updatedAccounts.add( updatedMap.get( newAccount.Id ) );
			}
			
			//-- the updatedAccounts should be refreshed and in the same order as the original list.
		}
		
		/** Setup that simply create the Accounts **/
		public void setupSingleVenueByZip(){
			newAccounts = new Account[]{
				new LNE_TestObjectFactory(
					LNE_TestObjectFactory.createAccount( 'TestAccount999', RT_VENUE_ID )
				).addBillingAddress( '200 West Jackson St.', 'Jackson', '62274', 'Illinois', 'IL', 'United States', 'US' )
				.addProperties( new Map<String,Object>{
					'Capacity__c' => 1000,
					'PrimaryOffice__c' => divisionOffice.Id,
					'OwnershipType__c' => 'Owned/Operated',
					'Type' => 'Amphitheatre'
				}).buildAccount()
			};
			
			oldAccountsMap = null;
		}
		
		public void setupSingleVenue(){
			newAccounts = new Account[]{
				new LNE_TestObjectFactory(
					LNE_TestObjectFactory.createAccount( 'TestAccount999', RT_VENUE_ID )
				).addBillingAddress( '200 West Jackson St.', 'Jackson', '62274', 'Illinois', 'IL', 'United States', 'US' )
				.addProperties( new Map<String,Object>{
					'Capacity__c' => 1000,
					'PrimaryOffice__c' => divisionOffice.Id,
					'OwnershipType__c' => 'Owned/Operated',
					'Type' => 'Amphitheatre'
				}).buildAccount()
			};
			
			oldAccountsMap = null;
		}
		
		/** Setup that creates and the has an update to the Account **/
		public void setupSingleVenueUpdate(){
			setupSingleVenue();
			insert newAccounts;
			
			LNE_TestObjectFactory factory = new LNE_TestObjectFactory(null);
			oldAccountsMap = new Map<Id,Account>( newAccounts.deepClone( true, true, true ) );
			factory.importObj( newAccounts[0] )
				.addBillingAddress( '111 West Illinois.', 'COOK', '60402', 'Illinois', 'IL', 'United States', 'US' );
		}
		
		/** Setup that doesn't change anything for the Accounts **/
		public void setupSingleVenueWithoutChanges(){
			setupSingleVenue();
			insert newAccounts;
			oldAccountsMap = new Map<Id,Account>( newAccounts );
		}
		
		/** Setup that where the DMA is not found **/
		public void setupNoMatchingDMA(){
			setupSingleVenue();
			insert newAccounts;
			
			oldAccountsMap = new Map<Id,Account>( newAccounts.deepClone( true, true, true ) );
			
			factory.importObj( newAccounts[0] )
				.addBillingAddress( '1 Easy St', 'Easy', '99999', 'louisiana', 'LA', 'United States', 'US' );
		}
		
		/** Finalize step. Should always be called after all setups. **/
		public void finalize(){
		}
	}

	//-- test test methods here
	static testMethod void runSimpleAccountsWithoutException() {
		TestSettings ts = new TestSettings();
		ts.setupSingleVenue();
		ts.finalize();
		System.assert( true, 'No exceptions were thrown' );
	}
	
	static testMethod void runUpdateSimpleAccountsWithoutException() {
		TestSettings ts = new TestSettings();
		ts.setupSingleVenueUpdate();
		ts.finalize();
		System.assert( true, 'No exceptions were thrown' );
	}
	
	static testMethod void runSimpleAccountsNoChangeNoException() {
		TestSettings ts = new TestSettings();
		ts.setupSingleVenueWithoutChanges();
		ts.finalize();
		System.assert( true, 'No exceptions were thrown' );
	}
	
	//-- test functionality here
	static testMethod void verifyInsertMatchingByZip(){
		TestSettings ts = new TestSettings();
		ts.setupSingleVenueByZip();
		ts.finalize();
		
		Account[] results = LNE_AccountDMA_Autoassign_T.execute( ts.newAccounts, ts.oldAccountsMap );
		
		System.assertNotEquals( null, results, 'AutoAssign must have some results when a valid Zip code is provided' );
		System.assertEquals( 1, results.size(), 'Since one account was created, there should be one account auto assigned' );
		
		Account updatedAccount = results[0];
		System.assertEquals( ts.dmaList[1].DMA__c, updatedAccount.DMA__c, '62274 should map to PADUCAH-CAPE/Jackson' );
	}
	
	
	static testMethod void verifyInsertMatchByCityState(){
		TestSettings ts = new TestSettings();
		ts.setupSingleVenue();
		ts.finalize();
		
		Account[] results = LNE_AccountDMA_Autoassign_T.execute( ts.newAccounts, ts.oldAccountsMap );
		
		System.assertNotEquals( null, results, 'AutoAssign must have some results when a valid Zip code is provided' );
		System.assertEquals( 1, results.size(), 'Since one account was created, there should be one account auto assigned' );
		
		Account updatedAccount = results[0];
		System.assertEquals( ts.dmaList[1].DMA__c, updatedAccount.DMA__c, 'JACKSON-IL should map to PADUCAH-CAPE/Jackson' );
	}
	
	
	static testMethod void verifySimpleAccountUpdateSetsDMA(){
		TestSettings ts = new TestSettings();
		ts.setupSingleVenueUpdate();
		ts.finalize();
		
		Account[] results = LNE_AccountDMA_Autoassign_T.execute( ts.newAccounts, ts.oldAccountsMap );
		
		System.assertNotEquals( null, results, 'AutoAssign must have some results when a valid Zip code is provided' );
		System.assertEquals( 1, results.size(), 'Since one account was created, there should be one account auto assigned' );
		
		Account updatedAccount = results[0];
		System.assertEquals( ts.dmaList[0].DMA__c, updatedAccount.DMA__c, '60402 should match to Chicago' );
	}
	
	//-- test that the DMA is cleared if no known Postal Code or City/State is found.
	//-- not part of the AC, so removing from the tests.
	/*
	static testMethod void verifyUnknownClearsDMA(){
		TestSettings ts = new TestSettings();
		ts.setupNoMatchingDMA();
		ts.finalize();
		
		Account[] results = LNE_AccountDMA_Autoassign_T.execute( ts.newAccounts, ts.oldAccountsMap );
		
		System.assertNotEquals( null, results, 'AutoAssign must have some results when a valid Zip code is provided' );
		System.assertEquals( 1, results.size(), 'Since one account was created, there should be one account auto assigned' );
		
		Account updatedAccount = results[0];
		System.assertEquals( null, updatedAccount.DMA__c, 'unknown DMA should be cleared' );
	}
	*/
}