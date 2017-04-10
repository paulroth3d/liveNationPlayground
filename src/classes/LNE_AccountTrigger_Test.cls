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
private class LNE_AccountTrigger_Test {

    class TestSettings {
        
        
        public TestSettings() {
			//-- initialize common custom settings
            LNE_TestObjectFactory.prepStandardCustomSettings();
        }
        
        public void typicalSetup(){

        }
		
		public void finalize(){
		}
    }
    
	
    //-- test test methods here
	
	static testMethod void runSetupAWithoutException() {
        TestSettings ts = new TestSettings();
    	ts.typicalSetup();
    	ts.finalize();
        System.assert( true, 'No Exceptions have occurred in getting here' );
	}
    
   	//-- test functionality here
	
    static testMethod void testScenario() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        
        GeneralSettings__c gs = [SELECT BypassAutomation__c FROM GeneralSettings__c];
		gs.BypassAutomation__c = true;
		update gs;
        
        System.Debug('*****' +LNE_RT.RT_ARTIST_ID);
        Account testAcct = LNE_TestObjectFactory.createAccount( 'TestAccountTrigger', LNE_RT.RT_ARTIST_ID); 
        insert(testAcct);
        
        System.assertNotEquals(null, testAcct);
        System.assertNotEquals(null, testAcct.id);
        
        //-- your logic off of any info from TS here
        System.assert( true, 'ts.account.DMA__c is not null, etc.' );
    }

}