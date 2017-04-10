public with sharing class LNE_PromoterCreateEvent_CX {

    public ApexPages.StandardController controller;
    public Event__c parentEvent {get;set;}
    public String pageTitle {get;set;}

    public Boolean showVFType {get; set;}
    public Boolean showFlow {get; set;}
    public Boolean showCloningPanel {get;set;}

    public Boolean validated {get; set;}
    public Boolean showError {get; set;}
    public String errorMessage {get; set;}
    public Boolean errorTypeArtist {get; set;}
    public Boolean errorTypeDate {get; set;}
    public Boolean errorTypeSubtype {get; set;}
    public Boolean errorTypeComponentIncomplete {get; set;}

    public Deal__c headlinerArtist {get; set;}
    public Event__c eventRecord {get;set;}
    public EventDateTime__c eventDateTime {get; set;}
    
    public static final String PARAM_RECORD_TYPE = 'RecordType';
    public static final String PARAM_CLONE = 'clone';
    public static final String PARAM_SAVE_NEW = 'save_new';
    private static final String PAGE_TITLE_NEW = 'Create Event';
    private static final String PAGE_TITLE_CLONE = 'Clone Event';
    public RecordType currentRecordType {get; set;}

    //-- getting vars from component
    public String componentOffice {get; set;}
    public String componentOfficeName {get; set;}
    public String componentVenue {get; set;}
    public String componentVenueName {get; set;}
    public String componentPromoter {get; set;}
    public String componentPromoterName {get; set;}

    //-- flow params
    public String vRecordTypeId {get; set;}
    public String vRecordTypeName {get; set;}
    public String vSubtype {get; set;}
    public String vPrimaryHeadlinerArtist {get; set;}
    public String vPrimaryHeadlinerArtistName {get; set;}
    public Date vEventDate {get; set;}
    public String vTargetYear {get; set;}
    public String vOffice {get; set;}
    public String vVenue {get; set;}
    public String vVenueName {get; set;}
    public String vPromoter {get; set;}
    public Boolean vAppetizeEvent {get; set;}
    public Boolean vOver5Hours {get; set;}
    public Boolean vTemporaryStageToBeUsed {get; set;}

    //-- just to show user what they picked in component, not passed to flow
    public String vOfficeName {get; set;}
    public String vPromoterName {get; set;}

    public Boolean isCloning {get;set;}
    public Boolean isCreatingNew {get;set;}
    public String originalEventVenueId {get;set;}
    public String clonedEventName {get;set;}

    public LNE_PromoterCreateEvent_CX thisController {get {
        return this;
    }}

    public LNE_PromoterCreateEvent_CX(ApexPages.StandardController controller) {
        this.controller = controller;
        getParentRecord();
        initVars();
        processUrlParams();
        getRecordType();
        setPageTitle();
        getOriginalEventValues();
        
        try {
            eventRecord = new Event__c(recordTypeId = currentRecordType.Id);
            
            vAppetizeEvent = false;
            vOver5Hours = false;
            vTemporaryStageToBeUsed = false;
        } catch( Exception err ){
            System.debug( 'Unable to determine the recordType' );
        }
    }

    private void initVars() {
        headlinerArtist = new Deal__c();
        eventDateTime = new EventDateTime__c();
        showFlow = false;
        validated = false;
        showError = false;
        showVFType = false;
        errorTypeArtist = false;
        errorTypeDate = false;
        errorTypeSubtype = false;  
        errorTypeComponentIncomplete = false;
        isCloning = false;
        isCreatingNew = false;
        showCloningPanel = false;
    }

    private void processUrlParams() {
        if (ApexPages.currentPage().getParameters().containsKey(PARAM_CLONE)) {
            isCloning = ApexPages.currentPage().getParameters().get(PARAM_CLONE) == '1';
        }

        if (ApexPages.currentPage().getParameters().containsKey(PARAM_SAVE_NEW)) {
            isCreatingNew = ApexPages.currentPage().getParameters().get(PARAM_SAVE_NEW) == '1';
        }
    }

    private void getRecordType() {
        List<RecordType> rtList;

        if (isCreatingNew) {
            if (ApexPages.currentPage().getParameters().containsKey(PARAM_RECORD_TYPE)) {
                String passedRecordTypeId = ApexPages.currentPage().getParameters().get( PARAM_RECORD_TYPE );
                rtList = [SELECT Name FROM RecordType WHERE Id = :String.escapeSingleQuotes(passedRecordTypeId)];

                if (rtList.size() > 0) {
                    currentRecordType = rtList[0];
                }
            }
        } else if (isCloning) {
            currentRecordType = new RecordType(Id = parentEvent.RecordTypeId,
                                               Name = parentEvent.RecordType.Name,
                                               DeveloperName = parentEvent.RecordType.DeveloperName);
        }
    }

    private void getParentRecord() {
        if (ApexPages.currentPage().getParameters().containsKey('Id')) {
            parentEvent = [SELECT RecordTypeId,
                                  RecordType.Name,
                                  RecordType.DeveloperName,
                                  Venue__c,
                                  ShowCount__c
                           FROM Event__c
                           WHERE Id = :controller.getRecord().Id];
        }
    }

    public void setPageTitle() {
        if (isCreatingNew) {
            pageTitle =  PAGE_TITLE_NEW;
        } else if (isCloning) {
            pageTitle =  PAGE_TITLE_CLONE;
        }
    }

    private void getOriginalEventValues() {
        if (isCloning && parentEvent != null) {
            originalEventVenueId = parentEvent.Venue__c;
        }
    }
    
    public void confirm() {
        if (isCreatingNew) {
            confirmNewEvent();
        } else if (isCloning) {
            confirmClonedEventName();
        }
    }

    public void confirmNewEvent() {
        validated = true;
        vRecordTypeId = currentRecordType.Id;
        vRecordTypeName = currentRecordType.Name;
        vSubtype = eventRecord.Subtype__c;

        getPrimaryHeadlinerArtistName();
        
        vEventDate = eventDateTime.EventDate__c; 
        vTargetYear = eventDateTime.EventYear__c;
        vOffice = componentOffice;
        vOfficeName = componentOfficeName;
        vVenue = componentVenue;
        vVenueName = componentVenueName;
        vPromoter = componentPromoter;
        vPromoterName = componentPromoterName;
        
        validateForm();

        if (showError == false) {
            showFlow = true;
            showCloningPanel = false;
            showError = false;
        }
    }

    public void confirmClonedEventName() {
        validated = true;

        vRecordTypeId = currentRecordType.Id;
        vRecordTypeName = currentRecordType.Name;
        vSubtype = eventRecord.Subtype__c;

        getPrimaryHeadlinerArtistName();

        vEventDate = eventDateTime.EventDate__c; 
        vTargetYear = eventDateTime.EventYear__c;
        vOffice = componentOffice;
        vOfficeName = componentOfficeName;
        vVenue = componentVenue;
        vVenueName = componentVenueName;
        vPromoter = componentPromoter;
        vPromoterName = componentPromoterName;

        String dateToUse = '';

        if (eventDateTime.EventDate__c != null) {
            dateToUse = String.valueOf(eventDateTime.EventDate__c);//eventDateTime.EventDate__c.format();
        } else {
            dateToUse = eventDateTime.EventYear__c;
        }

        clonedEventName = vPrimaryHeadlinerArtistName + ' at ' + vVenueName + ' - ' + dateToUse;

        validateForm();

        if (showError == false) {
            showFlow = false;
            showCloningPanel = true;
            showError = false;
        }
    }

    public PageReference confirmClone() {
        LNE_EventCloneUtil.EventCloneParams ep = new LNE_EventCloneUtil.EventCloneParams(clonedEventName, vPromoter);
        ep.eventDate = eventDateTime.EventDate__c;
        ep.eventYear = eventDateTime.EventYear__c;
        ep.artistId = headlinerArtist.Artist__c;
        ep.officeId = vOffice;
        ep.venueId = vVenue;

        Id jobId = LNE_EventCloneUtil.execute(parentEvent.Id, ep);
        return getFinalpage(jobId);
    }

    private void validateForm() {
        Boolean errorTypeArtist1 = false;

        if (vEventDate == null && String.isBlank(vTargetYear)) {
            showError = true;
            errorTypeDate = true;
        } else {
            errorTypeDate = false;
        }

        if (vPrimaryHeadlinerArtist == null && vRecordTypeName != 'Rental' && vRecordTypeName != 'Hold') {
            showError = true;
            errorTypeArtist = true;
            errorTypeArtist1 = true;
        }  else {
            errorTypeArtist = false;
            errorTypeArtist1 = false;
        }

        if (vPrimaryHeadlinerArtist == null && vRecordTypeName == 'Hold' && 
            vSubtype != 'Rental/Special Events/Venue Holds') 
        {
            showError = true;
            errorTypeArtist = true;
        } else {
            if (!errorTypeArtist1) {
                errorTypeArtist = false;
            }
        }

        if (vRecordTypeName == 'Hold' && vSubType == null) {
            showError = true;
            errorTypeSubtype = true;
        } else {
            errorTypeSubtype = false;
        }
        
        if (vOffice == null || vOffice == '' || vVenue == null || vVenue == '' || vPromoter == null || vPromoter == '') {
            showError = true;
            errorTypeComponentIncomplete = true;
        } else {
            errorTypeComponentIncomplete = false;
        }

        if (errorTypeDate == false && errorTypeArtist == false && errorTypeSubtype == false && errorTypeComponentIncomplete == false) {
            showError = false;
        }
    }

    private void getPrimaryHeadlinerArtistName() {
        vPrimaryHeadlinerArtist = headlinerArtist.Artist__c;
        List<Account> headliner = [SELECT Name FROM Account WHERE Id = :vPrimaryHeadlinerArtist];
        if (!headliner.isEmpty()) {
            vPrimaryHeadlinerArtistName = headliner[0].Name;
        } else {
            vPrimaryHeadlinerArtistName = '';
        }
    }
    
    public PageReference restart(){
        PageReference result = Page.LNE_PromoterCreateEvent;
        result.setRedirect(true);
        //-- @TODO: use vRecordTypeId instead.
        if (currentRecordType != null) {
            result.getParameters().put( PARAM_RECORD_TYPE, currentRecordType.Id);

            if (isCreatingNew) {
                result.getParameters().put( PARAM_SAVE_NEW, '1');
            } else if (isCloning) {
                result.getParameters().put( PARAM_CLONE, '1');
                result.getParameters().put( 'Id', parentEvent.Id);
            }
        }
        return( result );
    }
    
    public PageReference getflowFinished() {
        //-- put in the stub
        return Page.LNE_PromoterCreateEventResults;
    }

    public PageReference getFinalpage(Id jobId) {
        PageReference result = Page.LNE_PromoterCreateEventResults;
        result.setRedirect(true);
        result.getParameters().put( 'jobId', jobId);

        return result;
    }

}