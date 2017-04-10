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
private class LNE_AccountTermsUpdated_T_Test {
	
	class TestSettings {
		
		//-- example combined key delimiter
		String COMBINED_KEY_DELIMITER = '|';
		
		Account geoOffice;
		Account divisionOffice;
		Account[] venues;
		
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
				'GlobalTerms__c' => ORIGINAL_TERMS,
				'ParentId' => geoOffice.Id
			}).buildAccount();
			insert divisionOffice;
		}
		
		/** Refreshes the accounts to include the updated values. **/
		public void refreshVenues(){
			Map<Id, Account> updatedMap = new Map<Id,Account>(
				[
					select id, Name, GlobalTermsUpdated__c, GlobalTerms__c, PreviousGlobalTerms__c
					from Account
					where id in : venues
				]
			);
			
			Account[] updatedAccounts = new Account[]{};
			Account venue = null;
			for( integer i = 0; i < venues.size(); i++ ){
				venue = venues[i];
				System.assert( updatedMap.containsKey( venue.Id ), 'All accounts created should be found again when refreshed' );
				updatedAccounts.add( updatedMap.get( venue.Id ) );
			}
			
			//-- the updatedAccounts should be refreshed and in the same order as the original list.
		}
		
		/** Setup that simply create the Accounts **/
		private void createOwnedOperated(){
			venues = new Account[]{
				new LNE_TestObjectFactory(
					LNE_TestObjectFactory.createAccount( 'TestAccount999', RT_VENUE_ID )
				).addBillingAddress( '200 West Jackson St.', 'Jackson', '62274', 'Illinois', 'IL', 'United States', 'US' )
				.addProperties( new Map<String,Object>{
					'Capacity__c' => 1000,
					'PrimaryOffice__c' => divisionOffice.Id,
					'OwnershipType__c' => 'Owned/Operated',
					'GlobalTerms__c' => ORIGINAL_TERMS,
					'Type' => 'Amphitheatre'
				}).buildAccount()
			};
		}
		
		public void setupOwnedOperated(){
			createOwnedOperated();
			insert venues;
		}
		
		public void setupThirdParty(){
			createOwnedOperated();
			for( Account venue : venues ){
				venue.OwnershipType__c = 'Third Party';
			}
			insert venues;
		}
		
		public void setupGlobalTermsChange(){
			newAccounts = new Account[]{
				divisionOffice
			};
			
			oldAccountsMap = new Map<Id,Account>(
				newAccounts.deepClone( true, true, true )
			);
			
			String updatedTerms = UPDATED_TERMS;
			divisionOffice.GlobalTerms__c = updatedTerms;
			System.assertEquals( updatedTerms, newAccounts[0].GlobalTerms__c, 'newList should retain pointer to divisionOffice' );
		}
		
		/** Finalize step. Should always be called after all setups. **/
		public void finalize(){
		}
	}

	//-- test test methods here
	static testMethod void setupOwnedOperatedNoExceptions() {
		TestSettings ts = new TestSettings();
		ts.setupOwnedOperated();
		ts.setupGlobalTermsChange();
		ts.finalize();
		System.assert( true, 'No Exception has occurred in setting up owned operated' );
	}
	
	static testMethod void setupThirdPartyNoExceptions() {
		TestSettings ts = new TestSettings();
		ts.setupThirdParty();
		ts.setupGlobalTermsChange();
		ts.finalize();
		System.assert( true, 'No Exception has occurred in setting up third party' );
	}
	
	static testMethod void verifyGlobalTermsUpdated(){
		TestSettings ts = new TestSettings();
		ts.setupOwnedOperated();
		ts.setupGlobalTermsChange();
		ts.finalize();
		
		Account[] updatedAccounts = LNE_AccountTermsUpdated_T.execute( ts.newAccounts, ts.oldAccountsMap );
		System.assert( updatedAccounts.size() > 0, 'The terms were updated, so there should be at least something updated' );
		//-- there is disagreement whether both the division and the Account should be included.
		
		//-- refresh with the updated info
		//ts.refreshVenues();
		
		for( Account updatedAccount: updatedAccounts ){
			System.assertEquals( true, updatedAccount.GlobalTermsUpdated__c, 'The global terms should be updated' );
			System.assertEquals( ts.ORIGINAL_TERMS, updatedAccount.PreviousGlobalTerms__c, 'The previous terms should be the original terms' );
			System.assertEquals( ts.UPDATED_TERMS, updatedAccount.GlobalTerms__c, 'The current global terms should be updated' );
		}
	}
	
	//-- @TODO: perform inverse test using ThirdParty - no changes expected
	
	//-- test functionality here
	
	
}