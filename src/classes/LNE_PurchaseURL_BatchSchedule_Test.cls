@isTest
private class LNE_PurchaseURL_BatchSchedule_Test {

	private static testMethod void testScheduling() {
        String jobId = System.schedule( 
            LNE_PurchaseURL_BatchSchedule.JOB_NAME,
            LNE_PurchaseURL_BatchSchedule.DEFAULT_SCHEDULE,
            new LNE_PurchaseURL_BatchSchedule() );
        
        System.assertNotEquals(null, jobId);
	}

}