/**
 *  Controller for the results page at the end of creating an event.
 *  @author Paul Roth <proth@salesforce.com>
 **/
public class LNE_PromoterCreateEventResults_CC {
    
    /** event id of the newest created event **/
    public String newEventId { get; private set; }
    public String jobId { get; private set; }
    public AsyncApexJob cloneJob {get;set;}
    public String cloneJobCompletedDate {get;set;}
    public Boolean isCloning {get;set;}
    public Boolean jobCompleted {get;set;}
    
    /** current Event **/
    public Event__c newEvent { get; set; }
    
    public static final String ERROR_OCCURRED = 'An error occurred. Please contact your system administrator.';

    private String PARAM_JOB_ID = 'jobId';
    
    public LNE_PromoterCreateEventResults_CC(){
        //-- @INVARIANT- assume that that a person will ONLY come to this page once an event has been created
        //-- @INVARIANT- so the newest event created for THIS USER is the one that was JSUT CREATED.
        
        this.newEventId = '';
        this.isCloning = false;
        this.jobCompleted = false;

        if (ApexPages.currentPage().getParameters().containsKey(PARAM_JOB_ID)) {
            this.jobId = ApexPages.currentPage().getParameters().get(PARAM_JOB_ID);
        }

        //-- if jobId is not blank it means we're coming from the clone page
        if (String.isNotBlank(jobId)) {
            this.isCloning = true;
        } else {
            this.getEvent();
        }
    }
    
    /**
     *  Determines the page to navigate the user to.
     *  <p>Called on the VF Page.action</p>
     *  @return PageRefrerence
     **/
    public PageReference gotoEventPage(){
        //-- @INVARIANT - the event will already be retrieved by this point.
        
        if( this.newEvent != null ){
            return getEventPage();
        } else {
            if (isCloning == false) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_OCCURRED );
                ApexPages.addMessage(myMsg);
            } else {
                getCloneJob();
            }
            
            return( null );
        }
    }

    public PageReference getEventPage() {
        return( new ApexPages.StandardController( this.newEvent ).view() );
    }

    public PageReference getCloneJob() {
        cloneJob = [SELECT Status, ExtendedStatus, CompletedDate
                    FROM AsyncApexJob
                    WHERE Id = :jobId];

        if (cloneJob != null && cloneJob.CompletedDate != null) {
            cloneJobCompletedDate = cloneJob.CompletedDate.format();
        }

        if (cloneJob.Status == 'Completed' || cloneJob.Status == 'Failed') {
            jobCompleted = true;

            if (cloneJob.Status == 'Completed' ) {
                getEvent();
                return gotoEventPage();
            }
        } else {
            jobCompleted = false;
        }

        return null;
    }
    
    /**
     * Determines the event created.
     * <p>Assumes that the user will only navigate to this page once the event has been created.</p>
     * @return Event__c (Event__c) - the event created
     **/
    public Event__c getEvent(){
        Id currentUserId = UserInfo.getUserId();
        
        this.newEvent = null;
        this.newEventId = null;
        
        try {
            this.newEvent = [ select id, name, createdDate, createdBy.name, createdById
                from Event__c
                where createdById = :currentUserId
                order by createdDate desc
                limit 1
            ];
            this.newEventId = this.newEvent.Id;
        } catch ( Exception err ){
            System.debug( ERROR_OCCURRED );
            System.debug( err );
        }
        
        return( this.newEvent );
    }
}