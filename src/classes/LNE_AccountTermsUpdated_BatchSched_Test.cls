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
private class LNE_AccountTermsUpdated_BatchSched_Test {
	
	class TestSettings {
		
		//-- instance values
		
		LNE_AccountTermsUpdated_BatchSchedule scheduler;
		
		public TestSettings(){		  
			//-- initialize common custom settings.
			LNE_TestObjectFactory.prepStandardCustomSettings();
					
			//-- global setup here
			scheduler = new LNE_AccountTermsUpdated_BatchSchedule();
			System.Schedule( LNE_AccountTermsUpdated_BatchSchedule.JOB_NAME + '_t', LNE_AccountTermsUpdated_BatchSchedule.DEFAULT_SCHEDULE, scheduler );
		}
		
		public void setupA(){
			//-- specific setup here
		}
		
		public void finalize(){
			
		}
	}

	//-- test test methods here
	static testMethod void schedulesWithoutException() {
		TestSettings ts = new TestSettings();
		ts.setupA();
		ts.finalize();
		System.assert( true, 'No Exceptions have occurred in getting here' );
	}
	
	//-- test functionality here
	
	
}