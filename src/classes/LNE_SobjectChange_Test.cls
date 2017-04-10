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
private class LNE_SobjectChange_Test {
	
	class TestSettings {
		
		//-- instance values
		
		Account newAccount;
		Account oldAccount;
		
		AccountChangeObj objectChange;
		
		public TestSettings(){
			//-- initialize common custom settings.
			LNE_TestObjectFactory.prepStandardCustomSettings();
		}
		
		public void setupObjectsTheSame(){
			//-- specific setup here
			this.oldAccount = new Account(
				name = 'account',
				NumberOfEmployees = 100
			);
			this.newAccount = new Account(
				name = 'account',
				NumberOfEmployees = 100
			);
		}
		
		public void setupObjectsDifferently(){
			this.oldAccount = new Account(
				name = 'account',
				NumberOfEmployees = 100
			);
			this.newAccount = new Account(
				name = 'ACCOUNT',
				NumberOfEmployees = 200
			);
		}
		
		public void setupWasNull(){
			this.oldAccount = new Account(
			);
			this.newAccount = new Account(
				name = 'account',
				NumberOfEmployees = 200
			);
		}
		
		public void setupIsNull(){
			this.oldAccount = new Account(
				name = 'account',
				NumberOfEmployees = 100
			);
			this.newAccount = new Account(
			);
		}
		
		public void finalize(){
			this.objectChange = new AccountChangeObj( this.oldAccount, this.newAccount );
		}
	}
	
	class AccountChangeObj extends LNE_SObjectChange {
		AccountChangeObj( Account oldAccount, Account newAccount ){
			super( oldAccount, newAccount );
		}
		Account getOldAccount(){
			return( (Account)this.oldObject );
		}
		Account getNewAccount(){
			return( (Account)this.newObject );
		}
	}

	//-- test test methods here
	static testMethod void runSetupWithoutExceptions() {
		TestSettings ts = new TestSettings();
		//-- separate out if needed...
		ts.setupObjectsTheSame();
		ts.setupObjectsDifferently();
		ts.setupWasNull();
		ts.setupIsNull();
		ts.finalize();
		System.assert( true, 'No Exceptions have occurred in getting here' );
	}
		
	static testMethod void testStandardFieldNotEquals(){
		TestSettings ts = new TestSettings();
		ts.setupObjectsDifferently();
		ts.finalize();
		
		System.assertEquals( true, ts.objectChange.notEquals( 'NumberOfEmployees' ), 'NumberOfEmployees should be different if setup differently' );
		
		ts = new TestSettings();
		ts.setupObjectsTheSame();
		ts.finalize();
		
		System.assertEquals( false, ts.objectChange.notEquals( 'NumberOfEmployees' ), 'NumberOfEmployees should not be different if setup the same' );
		
		ts = new TestSettings();
		ts.setupWasNull();
		ts.finalize();
		
		System.assertEquals( true, ts.objectChange.notEquals( 'NumberOfEmployees' ), 'NumberOfEmployees should be different if it is now defined' );
		
		ts = new TestSettings();
		ts.setupIsNull();
		ts.finalize();
		
		System.assertEquals( true, ts.objectChange.notEquals( 'NumberOfEmployees' ), 'NumberOfEmployees should be different if cleared' );
	}
		
	static testMethod void testStandardFieldEquals(){
		TestSettings ts = new TestSettings();
		ts.setupObjectsDifferently();
		ts.finalize();
		
		System.assertEquals( false, ts.objectChange.equals( 'NumberOfEmployees' ), 'NumberOfEmployees should not be the same if setup differently' );
		
		ts = new TestSettings();
		ts.setupObjectsTheSame();
		ts.finalize();
		
		System.assertEquals( true, ts.objectChange.equals( 'NumberOfEmployees' ), 'NumberOfEmployees should be the same if setup the same' );
		
		ts = new TestSettings();
		ts.setupWasNull();
		ts.finalize();
		
		System.assertEquals( false, ts.objectChange.equals( 'NumberOfEmployees' ), 'NumberOfEmployees should not be the same if it is now defined' );
		
		ts = new TestSettings();
		ts.setupIsNull();
		ts.finalize();
		
		System.assertEquals( false, ts.objectChange.equals( 'NumberOfEmployees' ), 'NumberOfEmployees should not be the same if cleared' );
	}
		
	static testMethod void testStringFieldEquals(){
		TestSettings ts = new TestSettings();
		ts.setupObjectsDifferently();
		ts.finalize();
		
		System.assertEquals( false, ts.objectChange.equalsStr( 'Name', false ), 'Name should not be the same if setup differently and case sensitive' );
		System.assertEquals( true, ts.objectChange.equalsStr( 'Name', true ), 'Name should be the same if setup differently and not case sensitive' );
		
		ts = new TestSettings();
		ts.setupObjectsTheSame();
		ts.finalize();
		
		System.assertEquals( true, ts.objectChange.equalsStr( 'Name', false ), 'Name should be the same if setup the same and case sensitive' );
		
		ts = new TestSettings();
		ts.setupWasNull();
		ts.finalize();
		
		System.assertEquals( false, ts.objectChange.equalsStr( 'Name', false ), 'Name should not be the same if it is now defined' );
		
		ts = new TestSettings();
		ts.setupIsNull();
		ts.finalize();
		
		System.assertEquals( false, ts.objectChange.equalsStr( 'Name', false ), 'Name should not be the same if cleared' );
	}
		
	static testMethod void testStringFieldNotEquals(){
		TestSettings ts = new TestSettings();
		ts.setupObjectsDifferently();
		ts.finalize();
		
		System.assertEquals( true, ts.objectChange.notEqualsStr( 'Name', false ), 'Name should be different if setup differently and case sensitive' );
		System.assertEquals( false, ts.objectChange.notEqualsStr( 'Name', true ), 'Name should NOT be different if setup differently and not case sensitive' );
		
		ts = new TestSettings();
		ts.setupObjectsTheSame();
		ts.finalize();
		
		System.assertEquals( false, ts.objectChange.notEqualsStr( 'Name', false ), 'Name should NOT be different if setup different and case sensitive' );
		
		ts = new TestSettings();
		ts.setupWasNull();
		ts.finalize();
		
		System.assertEquals( true, ts.objectChange.notEqualsStr( 'Name', false ), 'Name should be different if it is now defined' );
		
		ts = new TestSettings();
		ts.setupIsNull();
		ts.finalize();
		
		System.assertEquals( true, ts.objectChange.notEqualsStr( 'Name', false ), 'Name should be different if cleared' );
	}
	
	//-- test functionality here
	
	
}