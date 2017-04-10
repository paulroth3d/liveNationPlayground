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
private class LNE_ArtistAgencyAssign_T_Test {
	static final String RT_Artist = 'Account.Artist';
	static final String RT_Agency = 'Account.Agency';
	static final String RT_Office = 'Account.Office';

	class TestSettings {
		
		String ROLE_BUSINESS_USER = 'Business User';
		String ROLE_BUSINESS_CONTACT = 'Business Contact';
		String MULTI_SEL_DELIMITER = ';';
		
		//-- instance values
		Account[] newAccounts;
		Account[] oldAccounts;		  
		String[] selectedRoles;
		Map<Id, Account> oldAccountsMap;
		
		public TestSettings(){
			//-- initialize common custom settings.
			LNE_TestObjectFactory.prepStandardCustomSettings();

			//-- find the record types 
			Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
				new String[]{ RT_Artist, RT_Agency, RT_Office }
			);
			Id RT_Artist_ID = recordTypeMap.get( RT_Artist );
			Id RT_Agency_ID = recordTypeMap.get( RT_Agency );
			Id RT_Office_ID = recordTypeMap.get( RT_Office );
		   
			/**
			 *	Old accounts (i.e. TriggerOld)
			 **/
			oldAccounts = new Account[]{
				LNE_TestObjectFactory.createAccount( 'Redundant Account Venue 1 old set' ),
				LNE_TestObjectFactory.createAccount( 'Old Account Office old set' )
			};

			for( Account oa : oldAccounts ){
				oa.BillingStreet = '123 Easy St.';
				oa.BillingCity = 'San Francisco';
				oa.BillingPostalCode = '12345';
				oa.BillingState = 'California';
				oa.BillingCountry = 'United States';
				oa.Type = 'Geography';
			}
			
			oldAccounts[0].RecordTypeId = RT_Artist_ID; 
			oldAccounts[1].RecordTypeId = RT_Agency_ID;	   
			
			insert oldAccounts;

			// set primary office
			//oldAccounts[0].PrimaryOffice__c = oldAccounts[1].Id;			  
			
			/**
			 *	New Accounts (i.e. TriggerNew)
			 **/
			newAccounts = new Account[]{
				LNE_TestObjectFactory.createAccount( 'First Venue Account new set' ),
				LNE_TestObjectFactory.createAccount( 'Account Office first new set' ),
				LNE_TestObjectFactory.createAccount( 'Venue the 2 new set' ),
				LNE_TestObjectFactory.createAccount( 'Account Office second new set' )
			};

			for( Account na : newAccounts ){
				na.BillingStreet = '123 Easy St.';
				na.BillingCity = 'San Francisco';
				na.BillingPostalCode = '12345';
				na.BillingState = 'California';
				na.BillingCountry = 'United States';
				
				// TODO: Technically only need type of office recordtypes
				na.Type = 'Geography';
			}
			
			newAccounts[0].RecordTypeId = RT_Artist_ID;
			newAccounts[1].RecordTypeId = RT_Agency_ID;	   
			newAccounts[2].RecordTypeId = RT_Artist_ID;
			newAccounts[3].RecordTypeId = RT_Office_ID;	   
			
			insert new List<Account>{newAccounts[1], newAccounts[3]};
			newAccounts[0].PrimaryAgency__c = newAccounts[1].Id;
			newAccounts[2].PrimaryAgency__c = newAccounts[3].Id;

			insert new List<Account>{newAccounts[0], newAccounts[2]};
		}
		
		public void typicalSetup(){
			selectedRoles = new String[]{
				ROLE_BUSINESS_CONTACT, ROLE_BUSINESS_USER
			};
			
			Map<Id, Account> oldAccountsMap = new Map<Id, Account>(oldAccounts);
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
	
	//-- test functionality here
	static testMethod void testEnterTextInUpdate() {
		try {
			TestSettings ts = new TestSettings();
			ts.typicalSetup();

			Test.startTest();
			
			LNE_ArtistAgencyAssign_T testedTrigger = new LNE_ArtistAgencyAssign_T();
			
			/**
			 *	Results should be empty
			 **/
			Account[] emptyNewAccounts;
			ArtistAgency__c[] resultsE = LNE_ArtistAgencyAssign_T.execute(emptyNewAccounts, ts.oldAccountsMap);
			System.assertEquals(0, resultsE.size());

			/**
			 *	Should get some results
			 **/			
			ArtistAgency__c[] results = LNE_ArtistAgencyAssign_T.execute(ts.newAccounts, ts.oldAccountsMap);
			//System.assertNotEquals(0, results.size());
			
			ArtistAgency__c artistAgency = [SELECT Id FROM ArtistAgency__c WHERE Artist__c = :ts.newAccounts[0].Id AND Agency__c = :ts.newAccounts[1].Id];
			System.assertNotEquals(null, artistAgency.Id);
			
			ts.newAccounts[1].PrimaryOffice__c = ts.newAccounts[3].Id;
			upsert ts.newAccounts[1];
			
			/**
			 *	Try another run 
			 **/
			ArtistAgency__c[] results2 = LNE_ArtistAgencyAssign_T.execute(ts.newAccounts, ts.oldAccountsMap);
			System.assertNotEquals(0, results2.size());
			
			Test.stopTest();

			//System.assertEquals(true, testedController.LatestAccountRequest.contains('Update from test script'));

			//-- Get new record from db
			// Account[] savedAccounts = [SELECT LatestAccountRequest__c FROM Account WHERE Id = :ts.accounts[0].Id];

			//-- Check LatestAccountRequest__c
			// System.assertEquals(testedController.formattedLatestAccountRequest, savedAccounts[0].LatestAccountRequest__c);

			ts.finalize();
		} catch( Exception err ){
			System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
		}

	}

	
}