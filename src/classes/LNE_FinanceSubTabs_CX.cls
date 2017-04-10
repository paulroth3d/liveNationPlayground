/**
 *  Controller to handle updates from the Finance SubTabs
 *  @author John Casimiro <jcasimiro@salesforce.com>
 *  
**/
global class LNE_FinanceSubTabs_CX {
    
    global Event__c event {get;set;}
    public Boolean showCompleteFlashButton {get; set;}
    public Boolean showExportToOracleButton {get; set;}
    public Boolean isFlashUser {get; set;}
    public String lastQueuedToOracle {get;set;}
    private static final String QUEUED_TEXT = 'Queued for Oracle:';
    private static final String LAST_EXPORTED_TEXT = 'Last Export to Oracle:';
    
    public LNE_FinanceSubTabs_CX( ApexPages.StandardController std ){
        this.event = (Event__c)std.getRecord();
        showCompleteFlashButton = false;
        showExportToOracleButton = false;
        lastQueuedToOracle = '';
        
        /* Set isFlashUser flag based on Permission Set */
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>([
            SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() 
            AND PermissionSet.Name = 'Flashing']);
        
        if (psa.size() > 0){
            isFlashUser = true;
        } else {
            isFlashUser = false;
        }
        
        refreshFlags();
    }
    
    public void exportToOracle(){
        event.FlashIntegrationStatus__c = 'Updated';
        event.OracleExportComplete__c = true;
        event.OracleExportCompletedBy__c = LNE_DateTimeUtility.getCurrentTimestampString();
        update event;
        
        refreshFlags();
    }
    
    @RemoteAction
    global static void defaultFees(String evtId){
        System.debug( 'Remoting succeeded: defaulting fees on Controller' );
        LNE_LedgerEntryDefaultFees.defaultFees(evtId);
    }

    public void completeSettlementRecap(){
        event.SettlementRecapComplete__c = true;
        event.SettlementRecapCompletedBy__c = LNE_DateTimeUtility.getCurrentTimestampString();
        update event;
    }
    
    public void completeEventMetrics(){
        event.MetricsComplete__c = true;
        event.MetricsCompletedBy__c = LNE_DateTimeUtility.getCurrentTimestampString();
        update event;
    }
    
    public void completeFlash(){
        event.Status__c = 'Flash Complete';
        event.FlashComplete__c = true;
        event.FlashCompletedBy__c = LNE_DateTimeUtility.getCurrentTimestampString();
        update event;
        
        refreshFlags();
    }
    
    /* Refreshes all the flags */
    public void refreshFlags(){
        Event__c evt = [select ArtistSettlementComplete__c, SettlementRecapComplete__c, EventRecapComplete__c,
            MetricsComplete__c, FlashComplete__c, 
            FlashIntegrationStatus__c, OracleExportComplete__c, BoxOfficeImportComplete__c,
            ArtistSettlementCompletedBy__c, SettlementRecapCompletedBy__c, EventRecapCompletedBy__c,
            MetricsCompletedBy__c, FlashCompletedBy__c,
            OracleExportCompletedBy__c, BoxOfficeImportCompletedBy__c
            from Event__c where id = :event.id];
        this.event = evt;
        
        system.debug(event + ' ' + isFlashUser);
        if (evt.SettlementRecapComplete__c == true && evt.MetricsComplete__c == true 
            && evt.FlashComplete__c == false && isFlashUser == true){ 
            showCompleteFlashButton = true;
        }
        
        if (evt.SettlementRecapComplete__c == true && evt.MetricsComplete__c == true 
            && evt.FlashComplete__c == true && isFlashUser == true){ 
            showExportToOracleButton = true;
        } 
        
        /* Populate Queued/Last Export Date/Time to be displayed */
        if (event.OracleExportCompletedBy__c != null && event.OracleExportComplete__c == true){
            lastQueuedToOracle = event.OracleExportCompletedBy__c.right(23);
            
            if (event.FlashIntegrationStatus__c == 'Oracle Updated') {
                lastQueuedToOracle = LAST_EXPORTED_TEXT + ' ' +  lastQueuedToOracle;
            } else {
                lastQueuedToOracle = QUEUED_TEXT + ' ' +  lastQueuedToOracle;
            }
        }
    }
}