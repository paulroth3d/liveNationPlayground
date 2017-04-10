/**
 *  Scheduler that runs all apex jobs given a particular pattern.
 *  
 *  <p>This is not tied to any specific project, and can be used multiple times
 *  with different initialization configurations</p>
 *  
 *  <p>DEVELOPMENT ONLY: runs all unit tests so it can be run on a scheduled basis.</p>
 *  
 *  @author Paul Roth <proth@salesforce.com>
 *  @example:
 *  LNE_TestRunner_Schedule testRunner = new LNE_TestRunner_Schedule();
 *  System.Schedule(
 * 		LNE_TestRunner_Schedule.createJobName( LNE_TestRunner_Schedule.DEFAULT_TEST_PATTERN ),
 * 		LNE_TestRunner_Schedule.DEFAULT_CRON,
 * 		testRunner );
 **/
global class LNE_TestRunner_Schedule implements Schedulable {
    
    //-- default name of the test runner schedulable job
    public static final String DEFAULT_JOB_NAME='TestRunner';
    
    //-- default schedule to run the job
    public static final String DEFAULT_CRON = '0 0 2 * * ?';
    
    //-- default test pattern - used to find test classes
	public static final String DEFAULT_TEST_PATTERN = 'LNE_%_TEST';
	
	//-- the actual test pattern to match against.
	public String testPattern;
	
    /**
     *  Executes all tests
     *  @param testPattern (String) - pattern to search for for tests, if null, then %Test is used.
     *  @example: LNE_Util.enqueueTests( 'LNE%Test');
     **/
	public static ID enqueueTests( String testPattern ){
	    if( String.isEmpty( testPattern )){
	        testPattern = DEFAULT_TEST_PATTERN;
	    }
	    ApexTestQueueItem[] results = new ApexTestQueueItem[]{};
	    Id parentJobId = null;
	    
	    for( ApexClass testClass : [ select id from ApexClass where Name like :testPattern ] ){
	        results.add( new ApexTestQueueItem( ApexClassId = testClass.Id ));
	    }
	    
	    //-- you cannot enqueue tests while running a test. These lines cannot be covered within a unit test
	    if( !Test.isRunningTest() ){
    	    insert results;
    	    
    	    ApexTestQueueItem item = [ select ParentJobId from ApexTestQueueItem where id = :results[0].Id limit 1 ];
    	    parentJobId = item.parentJobId;
	    }
	    
	    return( parentJobId );
	}
	public static ID enqueueTests(){
	    return( enqueueTests(null) );
	}
	
	/**
	 *  Static method that generates the job name given a specific pattern.
	 *  @param pattern
	 *  @return String
	**/
	public static String createJobName( String testPattern ){
		return( DEFAULT_JOB_NAME + ':' + testPattern );
	}
	
	//-- instance methods
	
	/**
	 *  Constructor.
	 *  @param testPattern to run.
	 **/
	public LNE_TestRunner_Schedule( String testPattern ){
	    this.testPattern = testPattern;
	}
	public LNE_TestRunner_Schedule(){
	    this( DEFAULT_TEST_PATTERN );
	}
	
	/**
	 *  Executes the job
	 **/
	global void execute( SchedulableContext ctx ){
	    enqueueTests( this.testPattern );
	}
}