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
private class LNE_Util_Test {
	
	class TestSettings {
		
		//-- instance values
		String expectedProfileName;
		Id expectedProfileId;
		
		String expectedPermissionSetName;
		Id expectedPermissionSetId;
		
		String RT_VENUE_NAME;
		String RT_OFFICE_NAME;
		
		Id RT_VENUE_ID;
		Id RT_OFFICE_ID;
		
		String GL_ACCOUNT_CODE = '50360';
		GLAccount__c[] glAccounts;
		
		Event__c currentEvent;
		
		public TestSettings(){
			//-- determine a profile name and ID
			expectedProfileName = 'LNE Internal User';
			Profile expectedProfile = [
				select id, name
				from Profile
				where name = :expectedProfileName
			];
			System.assert( expectedProfile != null, 'expectedProfile[' + expectedProfileName + '] is expected to be found in the org' );
			expectedProfileId = expectedProfile.Id;
			
			//-- determine the permission set name and id
			expectedPermissionSetName = 'Booking';
			
			PermissionSet expectedPermissionSet = [
				select id, name
				from PermissionSet
				where name = :expectedPermissionSetName
			];
			System.assert( expectedPermissionSet != null, 'PermissionSet[' + expectedPermissionSetName + '] must be found' );
			expectedPermissionSetId = expectedPermissionSet.Id;
			
			//-- determine the recordTypes
			RT_VENUE_NAME = 'Account.Venue';
			RT_OFFICE_NAME = 'Account.Office';
			
			RT_VENUE_ID = null;
			RT_OFFICE_ID = null;
			
			for( RecordType rt : [
				select Id, DeveloperName, SObjectType
				from RecordType
				where SObjectType = 'Account'
				and DeveloperName in ('Venue','Office')
			]){
				if( ('Venue').equals( rt.DeveloperName ) ){
					RT_VENUE_ID = rt.Id;
				} else if( ('Office').equals( rt.DeveloperName )){
					RT_OFFICE_ID = rt.Id;
				}
			}
			
			System.assertNotEquals( RT_VENUE_ID, null, 'Venue RecordType must be found' );
			System.assertNotEquals( RT_OFFICE_ID, null, 'Office RecordType must be found' );
		}
		
		public void initialSetup(){
			//-- nothing needed for now
		}
		
		public void setupGLAccounts(){
		    glAccounts = new GLAccount__c[]{
		    	//-- LA National Touring Allocation GL CODE
		    	LNE_TestObjectFactory.createGLAccount('LA National Touring Allocation', GL_ACCOUNT_CODE)
		    	//-- TODO: include all the other major GL Accounts
		    };
		    insert glAccounts;
		}
		
		public void setupEventForAccess(){
			
			//-- should this be added always? / @TestSetup?
			LNE_TestObjectFactory.prepStandardCustomSettings();
			
	        Event__c e = new Event__c();
	        this.currentEvent = e;
	        LNE_TestObjectFactory.createStandardDataSet( this.currentEvent );
		}
		
		public void finalize(){
			//-- nothing needed for now
		}
	}
	
	//-- test test methods here
    static testMethod void runSetupAWithoutException() {
        try {
        	TestSettings ts = new TestSettings();
        	ts.initialSetup();
        	ts.finalize();
        } catch( Exception err ){
        	System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
        }
    }
    
    //-- test functionality here
    
    /** Tests that ProfileIds are found **/
    static testMethod void testProfilesFound(){
    	TestSettings ts = new TestSettings();
    	ts.initialSetup();
    	ts.finalize();
    	
    	Map<String,Id> profileMap= LNE_Util.getProfileIds(
    		new String[]{ ts.expectedProfileName }
    	);
    	System.assertNotEquals( profileMap, null, 'Some profile set map must be returned' );
    	System.assert( profileMap.containsKey( ts.expectedProfileName ), 'Profile['+ ts.expectedProfileName+ '] is expected to be found in the org' );
    	
    	Id resultingProfileId = profileMap.get( ts.expectedProfileName );
    	System.assertEquals( ts.expectedProfileId, resultingProfileId, 'Profile should match the profile queried for' );
    }
    
    /** Tests that PermissionSets are found correctly. **/
    static testMethod void testPermissionSetsFound(){
    	TestSettings ts = new TestSettings();
    	ts.initialSetup();
    	ts.finalize();
    	
    	Map<String,Id> permissionSetMap = LNE_Util.getPermissionSetIds(
    		new String[]{ ts.expectedPermissionSetName }
    	);
    	System.assertNotEquals( permissionSetMap, null, 'Some permission set map must be returned' );
    	System.assert( permissionSetMap.containsKey( ts.expectedPermissionSetName ), 'PermissionSet[' + ts.expectedPermissionSetName + '] should be found in the results, but was not' );
    	
    	Id resultingPermSetId = permissionSetMap.get( ts.expectedPermissionSetName );
    	System.assertEquals( ts.expectedPermissionSetId, resultingPermSetId, 'Permission set found earlier is expected to match the permission set id returned' );
    }
    
    /** Tests that RecordTypes are found **/
    static testMethod void testRecordTypesFound(){
    	TestSettings ts = new TestSettings();
    	ts.initialSetup();
    	ts.finalize();
    	
    	Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
    		new String[]{ ts.RT_VENUE_NAME, ts.RT_OFFICE_NAME }
    	);
    	
    	System.assertNotEquals( recordTypeMap, null, 'getRecordTypes must return some result' );
    	
    	System.assert( recordTypeMap.containsKey( ts.RT_VENUE_NAME),  '[' + ts.RT_VENUE_NAME + '] must be found in the results' );
    	System.assert( recordTypeMap.containsKey( ts.RT_OFFICE_NAME ), '[' + ts.RT_OFFICE_NAME + '] must be found in the results' );
    	
    	Id RESULT_VENUE  = recordTypeMap.get( ts.RT_VENUE_NAME );
    	Id RESULT_OFFICE = recordTypeMap.get( ts.RT_OFFICE_NAME );
    	
    	System.assertEquals( ts.RT_VENUE_ID,  RESULT_VENUE, 'Venue recordTypeId must match' );
    	System.assertEquals( ts.RT_OFFICE_ID, RESULT_OFFICE, 'Office recordTypeId must match' );
    }
    
	/** Tests that the GL Accounts can be retrieved **/
    static testMethod void testGLAccountsFound(){
    	TestSettings ts = new TestSettings();
    	ts.setupGLAccounts();
    	ts.finalize();
    	
    	Test.startTest();
    	System.debug( 'start of the test' );
    	
    	Map<String,GLAccount__c> foundGLAccounts = LNE_Util.getGLAccounts( new String[]{ ts.GL_ACCOUNT_CODE });
    	
    	System.assert( foundGLAccounts.size() > 0, 'GL Accounts created above should be found' );
    	System.assert( foundGLAccounts.containsKey( ts.GL_ACCOUNT_CODE ), 'GL Account added above should be found' );
    	
    	Test.stopTest();
    }
    
    /** Tests whether the current user can edit an event. **/
    static testMethod void testCanEditEvent(){
    	TestSettings ts = new TestSettings();
    	ts.setupEventForAccess();
    	ts.finalize();
    	
    	Test.startTest();
    	
    	Boolean canEditEvent = LNE_Util.isEventEditable( ts.currentEvent.Id );
    	System.assert( canEditEvent, 'The current user should be able to edit the event' );
    	//-- @TODO: negative case - if the user is an XYZ, they should not be able to edit the event.
    	
    	Test.stopTest();
    }
}