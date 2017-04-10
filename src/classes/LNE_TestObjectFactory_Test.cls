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
private class LNE_TestObjectFactory_Test {
	
	class TestSettings {
		
		//-- instance values
		String RT_OFFICE_NAME = 'Account.Office';
		String RT_VENUE_NAME = 'Account.Venue';
		Id RT_OFFICE_ID = null;
		ID RT_VENUE_ID = null;
		
		String PROFILE_NAME = LNE_TestObjectFactory.PROFILE_LNE_INTERNAL_USER;
		Id PROFILE_ID = null;
		
		String PERMISSION_SET_NAME = LNE_TestObjectFactory.PERM_SET_BOOKING;
		Id PERM_SET_BOOKING_ID = null;
		
		User testUser;
		
		Map<String,Account> offices;
		Account testAccount;
		Contact testContact;
		DMA__c testDMA;
		
		public TestSettings(){
		    this(true);
		}
		public TestSettings( Boolean shouldPrepCustomSettings){
			//-- global setup here
			if( shouldPrepCustomSettings == true ){
			    LNE_TestObjectFactory.prepStandardCustomSettings();
			}
			
			//-- important rule to allow duplicates within the unit tests.
			Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
			
			Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			    new String[]{ RT_VENUE_NAME, RT_OFFICE_NAME }
		    );
		    RT_OFFICE_ID = recordTypeMap.get( RT_OFFICE_NAME );
		    RT_VENUE_ID = recordTypeMap.get( RT_VENUE_NAME );
			
			Map<String,Id> profileMap = LNE_Util.getProfileIds(
			    new String[]{ PROFILE_NAME }
			);
			PROFILE_ID = profileMap.get( PROFILE_NAME );
			System.assertNotEquals( PROFILE_ID, null, 'Profile:' + PROFILE_NAME + ', must be found' );
			
			offices = new Map<String,Account>();
		}
		
		public void setupUser(){
			testUser = LNE_TestObjectFactory.createUser( LNE_TestObjectFactory.makeUnique('lnejdoe'), PROFILE_ID );
    	    insert testUser;
		}
		
		public void setupTestUser(){
		    testUser = LNE_TestObjectFactory.createPromoterUser(
		    	LNE_TestObjectFactory.makeUnique( 'lnejdoe' )
		    );
		}
		
		public void setupAccount(){
			testAccount = new LNE_TestObjectFactory(
				LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' ))
			).addBillingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
			.addShippingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
			.buildAccount();
			insert testAccount;
		}
		
		public void setupContact(){
			setupAccount();
			
			testContact = new LNE_TestObjectFactory(
				LNE_TestObjectFactory.createContact( testAccount.id, 'John', LNE_TestObjectFactory.makeUnique( 'Doe' ))
			).addMailingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
			//-- this line should be removed as it is deprecated
			.buildContact();
			insert testContact;
		}
		
		public void setupDMA(){
		    testDMA = LNE_TestObjectFactory.createDMA( 'Chicago', 'Chicago', 'IL', '60402' );
		    insert testDMA;
		}
		
		
		public void setupGeographyOffice(){
		    Account geoOffice = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testGeography' ), RT_OFFICE_ID )
			).addBillingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
			    'Phone' => '708-522-5307',
			    'Type' => 'Geography'
			}).buildAccount();
			insert geoOffice;
			
			offices.put( 'Geography', geoOffice );
		}
		
		public void setupDivisionOffice(){
		    setupGeographyOffice();
		    Account geoOffice = offices.get( 'Geography' );
		    
		    Account divison = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testDivision' ), RT_OFFICE_ID )
			).addBillingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
			    'Phone' => '708-522-5307',
			    'Type' => 'Division',
			    'ApplyGlobalTermsTo__c' => 'Amphitheatre',
			    'GlobalTerms__c' => 'Global Terms',
			    'ParentId' => geoOffice.Id
			}).buildAccount();
			insert divison;
			
			offices.put( 'Division', divison );
		}
		
		public void setupVenueAccount(){
		    setupDivisionOffice();
		    Account divisionAcct = offices.get( 'Division' );
		    
		    testAccount = new LNE_TestObjectFactory(
				LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testVenue' ), RT_VENUE_ID )
			).addBillingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
			    'Capacity__c' => 1000,
			    'PrimaryOffice__c' => divisionAcct.Id,
			    'OwnershipType__c' => 'Owned/Operated',
			    'Type' => 'Amphitheatre'
			}).buildAccount();
//            testAccount.BillingCountryCode = 'US';
			insert testAccount;
		}
		
		public void finalize(){
			
		}
	}
    /*
    //-- test functionality here
    
    //-- UUID functionality
    static testmethod void testUUID(){
    	TestSettings ts = new TestSettings();
    	ts.finalize();
    	
    	Integer int1 = LNE_TestObjectFactory.getUUID();
    	Integer int2 = LNE_TestObjectFactory.getUUID();
    	
    	System.assertNotEquals( int1, int2, 'the point of getUUID is that they are unique. they arent.' );
    }
    
    static testMethod void testMakeUnique(){
    	TestSettings ts = new TestSettings();
    	ts.finalize();
    	
    	String seed = 'TestAccount';
    	String str1 = LNE_TestObjectFactory.makeUnique(seed);
    	String str2 = LNE_TestObjectFactory.makeUnique(seed);
    	
    	System.assertNotEquals( str1, str2, 'the point of makeUnique is that they are unique. they arent.' );
    }
    
    static testMethod void createUserWithoutException(){
    	try {
        	TestSettings ts = new TestSettings();
            ts.setupUser();
    	    ts.finalize();
    	} catch( Exception err ){
    	    System.assert( false, 'An exception shouldnt be thrown:' + err.getMessage() );
    	}
    }
    
    static testMethod void testRunAsUser(){
        TestSettings ts;
        try {
        	ts = new TestSettings(false);
            ts.setupTestUser();
    	    ts.finalize();
    	} catch( Exception err ){
    	    System.assert( false, 'An exception shouldnt be thrown:' + err.getMessage() );
    	}
    	
    	System.runAs( ts.testUser ){
    		//-- @TODO - test inserting as the user, but at this point it isn't really well defined.
    		System.debug( 'currently running as:' + ts.testUser.Name );
    	}
    }
    
    //-- test the builder
    
    //-- just to prove a point
    static testMethod void testBuilderWithAddressMultiple(){
    	TestSettings ts = new TestSettings();
		ts.finalize();
    	
		//-- can be created in so many ways.
		Account[] testAccounts = new Account[]{
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' ))
    	};
    	
    	String billingStreetAddress = '1000 west illinois st';
    	
    	LNE_TestObjectFactory factory = new LNE_TestObjectFactory( null );
    	for( Account testAccount: testAccounts ){
    		factory.importObj( testAccount ).addBillingAddress( billingStreetAddress, 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' );
    	}
    	
    	//-- just as an example, but all of them have their properties set all inline.
    	System.assertEquals( billingStreetAddress, testAccounts[0].billingStreet, 'Street address is expected to be set through addBillingAddress' );
		
		insert testAccounts;
		System.assert( true, 'No exceptions were found when creating the account' );
    }
    
    static testMethod void testBuilderWithProps(){
    	TestSettings ts = new TestSettings();
    	ts.finalize();
    	
    	String billingStreetAddress = '1000 west illinois st';
    	Map<String,Object> allProps = new Map<String,Object>{
    		'BillingStreet' => billingStreetAddress,
    		'BillingCity' => 'Chicago',
    		'BillingPostalCode' => '60402',
    		'BillingState' => 'Illinois',
    		'BillingStateCode' => 'IL',
    		'BillingCountry' => 'United States',
    		'BillingCountryCode' => 'US'
    		//-- any additional props here
    	};
    	
    	Account[] testAccounts = new Account[]{
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' )),
    		LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testAccount' ))
    	};
    	
    	
    	LNE_TestObjectFactory factory = new LNE_TestObjectFactory( null );
    	for( Account testAccount: testAccounts ){
    		factory.importObj( testAccount ).addProperties( allProps );
    		System.assertEquals( billingStreetAddress, testAccount.BillingStreet, 'Street address from props are not the same' );
    	}
		
		insert testAccounts;
		System.assert( true, 'No exceptions were found when creating the account' );
    }
    
    //-- test building objects
    //-- note that the final assert is true, because it would only get there if no unexpected exceptions were thrown beforehand.
    
    static testMethod void testBuildAccount(){
    	TestSettings ts = new TestSettings();
    	ts.setupAccount();
		ts.finalize();
   		System.assert( true, 'No exceptions were found when creating the account' );
    }
    
    static testMethod void testBuildVenueAccount(){
        TestSettings ts = new TestSettings();
        ts.setupVenueAccount();
        ts.finalize();
   		System.assert( true, 'No exceptions were found when creating the venue' );
    }
    
    //-- create contacts
    static testMethod void testCreatingContacts(){
    	TestSettings ts = new TestSettings();
    	ts.setupContact();
    	ts.finalize();
    	System.assert( true, 'No Exceptions were found creating the contact' );
    }
    
    static testMethod void testCreateDMA(){
        TestSettings ts = new TestSettings();
        ts.setupDMA();
        ts.finalize();
        System.assert( true, 'No Exceptions were found creating the DMA' );
    }
    static testMethod void testCreateVenue(){
    	TestSettings ts = new TestSettings();
        ts.setupVenueAccount();
        ts.finalize();
        System.assert( true, 'No Exceptions were found creating the Venue' );
    }
    
    static testMethod void testCreateAdmin(){
    	TestSettings ts = new TestSettings();
        User u = LNE_TestObjectFactory.createAdminUser('admin');
        ts.finalize();
        System.assert( true, 'No Exceptions were found creating the Admin User' );
    }
    
    static testMethod void testCreateMarketingUser(){
    	//TestSettings ts = new TestSettings();
        User u = LNE_TestObjectFactory.createMarketingUser('market');
       // ts.finalize();
        System.assert( true, 'No Exceptions were found creating the Marketing User' );
    }
    
    static testMethod void testCreateGroupMemberships(){
        TestSettings ts = new TestSettings();
        User u = LNE_TestObjectFactory.createAdminUser('admin');
        Group g = new Group();
        g.Name = 'test group';
        insert g;
        GroupMember[] gms = LNE_TestObjectFactory.createGroupMemberships(u.Id, new List<Id>{g.Id});
        ts.finalize();
        System.assert( true, 'No Exceptions were found creating the Venue' );
        
    }
    */
    static testMethod void testCreateStandardDataSet(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet();
        System.assert( true, 'No Exceptions were found creating the Standard Data Set' );
    }
    
    static testMethod void testCreateStandardDataSet2(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
        Event__c e = new LNE_TestObjectFactory(
	        LNE_TestObjectFactory.createEvent()
		).addProperties( new Map<String,Object>{
		    'Status__c' => 'Draft',
		    'TotalSupportActExpenses__c' => 0.0
		}).buildEvent();
        LNE_TestObjectFactory.createStandardDataSet(e);
        System.assert( true, 'No Exceptions were found creating the Standard Data Set' );
    }
    
    static testMethod void testCreateStandardDataSet3(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
        Event__c e = new LNE_TestObjectFactory(
	        LNE_TestObjectFactory.createEvent()
		).addProperties( new Map<String,Object>{
		    'Status__c' => 'Draft',
		    'TotalSupportActExpenses__c' => 0.0
		}).buildEvent();
		LNE_TestObjectFactory.VenueHierarchy h = LNE_TestObjectFactory.createVenueHierarchy( LNE_TestObjectFactory.ACCT_TYPE_BUSINESS_UNIT, null, null );
        LNE_TestObjectFactory.createStandardDataSet(e, h );
        System.assert( true, 'No Exceptions were found creating the Standard Data Set' );
    }
    
    static testMethod void testCreateQuickLinks(){
        LNE_TestObjectFactory.createQuickLink('test link', '', '', '', 'test');
        System.assert( true, 'No Exceptions were found creating the Quick Link' );
    }
    
}