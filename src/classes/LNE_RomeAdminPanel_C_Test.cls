@isTest
public class LNE_RomeAdminPanel_C_Test {

	static testMethod void test_RomeAdminPanel() {

		PageReference pr = Page.LNE_RomeAdminPanel;
		Test.setCurrentPageReference(pr);

		Test.startTest();

		LNE_RomeAdminPanel_C con = new LNE_RomeAdminPanel_C();

		LNE_RomeAdminPanel_C.startJob(LNE_RomeAdminPanel_C.JOB_USER_OFFICE_BATCH);
		LNE_RomeAdminPanel_C.startJob(LNE_RomeAdminPanel_C.JOB_RUN_ALL_TESTS);
		LNE_RomeAdminPanel_C.startJob('foo');

		LNE_RomeAdminPanel_C.JobRunner[] runners = LNE_RomeAdminPanel_C.getJobRunners();
		LNE_RomeAdminPanel_C.TestRunResult[] res = LNE_RomeAdminPanel_C.getTestRunResults();

		Test.stopTest();

		List<AsyncApexJob> apexJobs = [
			select ApexClass.Name, Status, LastProcessedOffset, TotalJobItems, NumberOfErrors, CreatedBy.Name, CreatedDate
			from AsyncApexJob limit 1
		];

		if (!apexJobs.isEmpty()) {
			LNE_RomeAdminPanel_C.BatchJob batchJob = new LNE_RomeAdminPanel_C.BatchJob(apexJobs[0]);
		}

	}



}