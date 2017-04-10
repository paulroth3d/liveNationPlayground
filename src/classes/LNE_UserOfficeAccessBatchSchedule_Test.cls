@isTest
public class LNE_UserOfficeAccessBatchSchedule_Test {
	@isTest static void testSchedulable() {
		LNE_UserOfficeAccessBatchSchedule s = new LNE_UserOfficeAccessBatchSchedule();
		system.assertEquals('0 0 2 ? * 1,2,3,4,5,6,7', LNE_UserOfficeAccessBatchSchedule.DEFAULT_SCHEDULE);
		system.assertEquals('Office User Access Batch', LNE_UserOfficeAccessBatchSchedule.JOB_NAME);
		s.execute(null);
	}
}