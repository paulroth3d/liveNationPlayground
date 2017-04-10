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
private class LNE_TestRunner_Schedule_Test {

    class TestSettings {
        
        String jobId = null;
        
        public TestSettings() {
			//-- global setup here
            this.jobId = null;
        }
        
        public void enqueueWithDefaultPattern(){
            LNE_TestRunner_Schedule.enqueueTests();
        }
        public void enqueueForSpecificTests(){
            LNE_TestRunner_Schedule.enqueueTests( LNE_TestRunner_Schedule.DEFAULT_TEST_PATTERN );
        }
        
        public void setupScheduler(){
            this.jobId = System.schedule( LNE_TestRunner_Schedule.DEFAULT_JOB_NAME,
                LNE_TestRunner_Schedule.DEFAULT_CRON,
                new LNE_TestRunner_Schedule() );
        }
		
		public void finalize(){
		}
    }
    
	
    //-- test test methods here
	
	static testMethod void enqueueWithDefaultPatternNoException() {
        TestSettings ts = new TestSettings();
    	ts.enqueueWithDefaultPattern();
    	ts.finalize();
    	//-- can't test anything because you cannot enqueue additional tests while running a test.
        System.assert( true, 'No Exceptions have occurred in getting here' );
	}
	
	static testMethod void enqueueWithSpecificPatternNoException() {
        TestSettings ts = new TestSettings();
    	ts.enqueueForSpecificTests();
    	ts.finalize();
    	//-- can't test anything because you cannot enqueue additional tests while running a test.
        System.assert( true, 'No Exceptions have occurred in getting here' );
	}
	
	static testMethod void enqueueSchedulerSchedulesJobs() {
        TestSettings ts = new TestSettings();
    	ts.setupScheduler();
    	ts.finalize();
    	//-- can't test anything because you cannot enqueue additional tests while running a test.
        System.assertNotEquals( null, ts.jobId, 'Scheduling the job must actually schedule the job' );
	}

}