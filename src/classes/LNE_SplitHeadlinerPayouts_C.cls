/**
 * Controller for the Splt Headliner Payouts.
 * @author Vinay
 * US648 - Controller class to  specify split percentages for artist deals among headliners 
 *			so that the artists can share in the upside potential of the event and artist 
 *			walkout amounts are calculated according to the proportions specified.
 *
 * @version - US648 
 **/
public with sharing class LNE_SplitHeadlinerPayouts_C {

	/* -- Constants -- */
	public static final String PARAM_EVENT_ID = 'eventId';
	public static final String PARAM_STAGETYPE = 'stageType';
	public static final String ARTIST_RECORDTYPE_NAME = 'Artist';
	public static final String PRIMARY_HEADLINER_TYPE = 'Primary Headliner';
	public static final String CO_HEADLINER_TYPE = 'Co-Headliner';
	public static final List<String> headlinerTypes = new List<String>{PRIMARY_HEADLINER_TYPE,CO_HEADLINER_TYPE};

	/* -- Variables -- */
	/** Id of the Event **/
    public String eventId {get; set;} 
    /** StageType of Deal **/
    public String stageType {get; set;} 
    /** Event object **/
    public Event__c currentEvent {get; set;}
    /** Primary headliner related to event in context **/
    public Deal__c primaryHeadliner {get; set;} 
    /** List of all headliners related to event in context **/
    public List<Deal__c> headlinerList {get; set;} 
    /** variable for save status **/
    public Boolean saveSuccess {get; set;} 
    

	public LNE_SplitHeadlinerPayouts_C() {
		eventId = ApexPages.currentPage().getParameters().get( PARAM_EVENT_ID );
		stageType = ApexPages.currentPage().getParameters().get( PARAM_STAGETYPE );
		system.debug('@@@ page eventId -- '+ eventId + ' - stageType - '+ stageType);

		saveSuccess = false;
	}

	/**
	* init method set list of headliners based on the event Id in context.
	* @param - None
	* @return - void
	**/
    public void init(){
    	system.debug('@@@ init eventId -- '+ eventId);
    	if(eventId != null && eventId != ''){
    		//query for event details and related headliners (deal recordtype of artist) related to the event in context.
    		List<Event__c> eventList = [SELECT Id, Name, EventName__c, 
    											(SELECT Id, BackendPercent__c, Artist__c, Artist__r.Name, SplitPercentage__c
	    												  , SplitBackendPercent__c, Type__c, StageType__c FROM Deals__r 
	    												WHERE recordtype.Name = :ARTIST_RECORDTYPE_NAME AND Type__c IN :headlinerTypes
	    												AND StageType__c = :stageType 
														ORDER BY Type__c)
												FROM Event__c WHERE Id =: eventId
												];
			
			system.debug('@@@ eventList -- '+ eventList);
    		if(eventList != null && !eventList.isEmpty()){
    			currentEvent = eventList[0];
    			if(currentEvent.Deals__r != null && !currentEvent.Deals__r.isEmpty() && currentEvent.Deals__r.size() > 1){
    				//when initially launched check if all split are null, if so set split  
					headlinerList = currentEvent.Deals__r;
					for(Deal__c headliner : headlinerList){
						if(PRIMARY_HEADLINER_TYPE.equalsIgnoreCase(headliner.Type__c)){
							primaryHeadliner = headliner;
							//check if split percentage is null, if so set the primary to 100%
							if(headliner.SplitPercentage__c == NULL){
								 headliner.SplitPercentage__c = 100;
							}
						}else{
							//check if split percentage is null, if so set the co-headliner to 0%
							if(headliner.SplitPercentage__c == NULL){
								 headliner.SplitPercentage__c = 0;
							}
						}
					}
				}else{
	    			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ' Atleast one Primary and one Co-Headliner should exist.' );
	            	ApexPages.addMessage(myMsg);
	    		}
    		}
    	}
	}

	/**
	* resets the splits reverting the changes user entered
	* @param - None
	* @return - PageReference
	**/
	public PageReference cancel(){
		init();
		return null;
	}

	/**
	* Saves all split changes, adds page message for any errors.
	* @param - None
	* @return - PageReference
	**/
	public PageReference save(){
		if(headlinerList != null && !headlinerList.isEmpty()){
			Integer split = 0;
			for(Deal__c headliner : headlinerList){
				if(headliner.SplitPercentage__c < 0 ){
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The Split % must be positive' );
            		ApexPages.addMessage(myMsg);
            		return null;
				}
				split += Integer.valueOf((headliner.SplitPercentage__c == null || headliner.SplitPercentage__c == 0) ? 0 : headliner.SplitPercentage__c);
			}

			if(split == 100){
				update headlinerList;
				saveSuccess = true;
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Save Successfull' );
            	ApexPages.addMessage(myMsg);
			}else {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The Split % must total to 100%' );
            	ApexPages.addMessage(myMsg);
			}
		}
		return null;
	}
}