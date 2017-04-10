global class LNE_FlashTab_CX {
    
    private ApexPages.StandardController std;
    private final Event__c relatedEvent;
    private final SObject parent;
    public Boolean flashProcess {get;set;}

    
    public LNE_FlashTab_CX( ApexPages.StandardController standard ){
        this.std = standard;
        parent = std.getRecord();
        relatedEvent = [SELECT Id, Status__c FROM Event__c
                        WHERE Id = :parent.id];
        if(relatedEvent.Status__c == 'Flash Started' || relatedEvent.Status__c == 'Flash Complete'){
            flashProcess = true;
        }else{
            flashProcess = false;
        }
    }
    
    public void startFlashProcess(){
        
        
          relatedEvent.Status__c = 'Flash Started';

          update relatedEvent;

          flashProcess = true;
  
    }

    @RemoteAction
    global static Boolean copyToFlash(Id eventId) {
        LNE_LedgerEntryUtil.copyToFlash(eventId);
        return true;
    }

}