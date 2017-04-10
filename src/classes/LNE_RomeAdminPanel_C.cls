/**
 *  Controller for the Rome Administration Panel.
 *  <p>Page to work with batches and other administrative functions.</p>
 *  @author Paul Roth <proth@salesforce.com>
 **/
global with sharing class LNE_RomeAdminPanel_C {
	
	public static final String STATUS_HOLDING = 'Holding';
	public static final String STATUS_QUEUED = 'Queued';
	public static final String STATUS_PREPARING = 'Preparing';
	public static final String STATUS_PROCESSING = 'Processing';
	public static final String STATUS_ABORTED = 'Aborted';
	public static final String STATUS_COMPLETED = 'Completed';
	public static final String STATUS_FAILED = 'Failed';
	
	public static final String JOB_SHORT_BATCH = 'Ba';
	@TestVisible
	public static final String JOB_USER_OFFICE_BATCH = 'LNE_UserOfficeAccessBatch';
	public static final String JOB_USER_OFFICE_BATCH_DESCR = 'Refreshes the Offices assigned to all users';
	@TestVisible
	public static final String JOB_RUN_ALL_TESTS = 'LNE_TestRunner_Schedule';
	public static final String JOB_RUN_ALL_TESTS_DESCR = 'Runs all LNE Tests';
	
	public static final String ERROR_JOB_ALREADY_RUNNING = 'Job is already running';
	public static final String ERROR_UNKNOWN_JOB = 'Unknown Job:';
	public static final String ERROR_UNKNOWN = 'Unknown Error';
	
	/** Current list of running jobs. **/
	public ScheduledJob[] currentScheduledJobs { get; private set; }
	
	public BatchJob[] currentBatchJobs { get; private set; }
	
	public LNE_RomeAdminPanel_C(){
		//-- we dont' care about the standard controller, we just need extensions for JS Remoting.
		this.currentScheduledJobs = refreshCurrentScheduledJobs();
		this.currentBatchJobs = refreshCurrentBatchJobs();
	}
	
	/**
	 *  Determines the current running batches.
	 *  @return BatchJob[]
	 **/
	@RemoteAction
	global static BatchJob[] refreshCurrentBatchJobs(){
		BatchJob[] results = new BatchJob[]{};
		for( AsyncApexJob ajob: [
			select id, ApexClass.Name, Status, LastProcessedOffset, TotalJobItems, NumberOfErrors, CreatedBy.Name, CreatedDate
			from AsyncApexJob
			where status not in (:STATUS_COMPLETED, :STATUS_ABORTED, :STATUS_FAILED, :STATUS_QUEUED )
		]){
			results.add( new BatchJob( ajob ));
		}
		return( results );
	}
	
	/**
	 *  Determines the current list of currently scheduled jobs.
	 *  @return ScheduledJob[]
	 **/
	@RemoteAction
	global static ScheduledJob[] refreshCurrentScheduledJobs(){
		ScheduledJob[] results = new ScheduledJob[]{};
		for( CronTrigger cTrigger : [
			select id, CronJobDetail.Name, CreatedBy.Name, CreatedDate, PreviousFireTime, NextFireTime
			from CronTrigger
		]){
			results.add( new ScheduledJob( cTrigger ));
		}
		return( results );
	}
	
	/**
	 *  Determines if a batch is currently running.
	 *  @param className
	 *  @return Boolean - whether a job is currently running for that name (true) or not (false)
	 **/
	public static Boolean isJobRunning( String className ){
		//-- always refresh for now
		for( BatchJob batch: refreshCurrentBatchJobs() ){
			if( batch.jobName.equals( className )){
				return( true );
			}
		}
		return( false );
	}
	
	/**
	 *  Starts a job by the job name
	 *  @param jobName (String)
	 *  @returns (Boolean)
	 **/
	@RemoteAction
	global static String startJob( String className ){
		if( isJobRunning( className )){
			return( ERROR_JOB_ALREADY_RUNNING );
		} else {
			if( JOB_RUN_ALL_TESTS.equals( className )){
				LNE_TestRunner_Schedule.enqueueTests( LNE_TestRunner_Schedule.DEFAULT_TEST_PATTERN );
				//return( 'RUNNING BATCH FOR:' + className );
			} else if( JOB_USER_OFFICE_BATCH.equals( className )){
				LNE_UserOfficeAccessBatch b = new LNE_UserOfficeAccessBatch();
				Database.executeBatch(b, 1);
				//return( 'RUNNING BATCH FOR:' + className );
			} else {
				return( ERROR_UNKNOWN_JOB + className );
			}
			return( null );
		}
		
		//-- job worked just fine.
		return( null );
	}
	
	/**
	 * Determines the list of class runners.
	 * @return ClassRunner[]
	 **/
	@RemoteAction
	global static JobRunner[] getJobRunners(){
		JobRunner[] results = new JobRunner[]{
			new JobRunner( JOB_SHORT_BATCH, JOB_USER_OFFICE_BATCH, JOB_USER_OFFICE_BATCH_DESCR ),
			new JobRunner( JOB_SHORT_BATCH, JOB_RUN_ALL_TESTS, JOB_RUN_ALL_TESTS_DESCR )
		};
		return(results);
	}
	
	/**
	 * Determines the current list of tests run.
	 * @return TestRunResult[]
	 **/
	@RemoteAction
	global static TestRunResult[] getTestRunResults(){
		TestRunResult[] results = new TestRunResult[]{};
		for( ApexTestRunResult r : [
			select Id, AsyncApexJobId, AsyncApexJob.JobType, Status, ClassesCompleted, ClassesEnqueued, MethodsCompleted, MethodsEnqueued, IsAllTests, MethodsFailed, CreatedBy.Name, CreatedDate
			from ApexTestRunResult
			order by createdDate desc
			limit 10
		]){
			results.add( new TestRunResult( r ));
		}
		return( results );
	}
	
	/**
	 * Class that represents a job that can be started
	 **/
	global class JobRunner {
		public String shortName;
		public String className;
		public String descr;
		public JobRunner( String shortName, String className, String descr ){
			this.shortName = shortName;
			this.className = className;
			this.descr = descr;
		}
	}
	
	/**
	 * Class that represents a running batch job
	 **/
	global class BatchJob {
		public id jobId;
		public String jobName;
		public String status;
		public String progress;
		public String createdByName;
		public String createdDate;
		
		public BatchJob( AsyncApexJob job ){
			this.jobId = job.id;
			this.jobName = job.ApexClass.Name;
			this.status = job.Status;
			this.progress = makeProgressStr( job.LastProcessedOffset, job.TotalJobItems, job.NumberOfErrors );
			this.createdByName = job.createdBy.Name;
			this.createdDate = job.createdDate.format();
		}
		
		private String makeProgressStr( Integer processedOffset, Integer totalJobItems, Integer jobErrors ){
			String results = '(';
			results += (processedOffset==null?0:processedOffset);
			results += '/';
			results += (totalJobItems==null?0:totalJobItems);
			results += ')';
			if( jobErrors > 0 ){
				results += '[' + jobErrors + ' errors]';
			}
			return( results );
		}
	}
	
	/**
	 *  Class that represents a suite run of unit tests.
	 **/
	global class TestRunResult {
		public id jobId;
		public String jobName;
		public String status;
		public String progress;
		public String createdByName;
		public String createdDate;
		
		public TestRunResult( ApexTestRunResult result ){
			this.jobId = result.AsyncApexJobId;
			this.jobName = result.AsyncApexJob.JobType;
			this.status = result.Status;
			this.progress = 'classes(' + result.ClassesEnqueued + '/' + result.ClassesEnqueued + ')';
			this.progress += ', methods(' + result.MethodsCompleted + '/' + result.MethodsEnqueued + ')';
			if( result.isAllTests ){
				this.progress += ':AllTests';
			}
			this.createdByName = result.CreatedBy.Name;
			this.createdDate = result.CreatedDate.format();
		}
	}
	
	/**
	 * Class that represents scheduled jobs
	 **/
	global class ScheduledJob {
		public id jobId;
		public String jobName;
		public String createdByName;
		public String createdDate;
		public String lastRunDate;
		public String nextRunDate;
		
		public ScheduledJob( CronTrigger cron ){
			this.jobId = cron.Id;
			this.jobName = cron.CronJobDetail.Name;
			this.createdByName = cron.CreatedBy.Name;
			this.createdDate = cron.createdDate.format();
			this.lastRunDate = cron.PreviousFireTime != null ? cron.PreviousFireTime.format() : '';
			this.nextRunDate = null;
			if( cron != null && cron.NextFireTime != null ){
				this.nextRunDate = cron.NextFireTime.format();
			}
		}
	}
}