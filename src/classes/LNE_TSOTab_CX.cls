public class LNE_TSOTab_CX {
	
    private final SObject parent;
    public Tour__c tourTotals {get;set;}
    public String tourId {get;set;}

    public LNE_TSOTab_CX(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        tourId = parent.Id;
        init();
    }
    
     public void init() {
        getTourTotals();
      
    }
     
    public PageReference getTourTotals(){
        tourTotals = [select TotalTourRep__c, TotalMiscExpense__c, TotalEndOfTourDinner__c, TotalTE__C, TotalTSO__c, TotalPerDiems__c  from Tour__c where Id = :tourId][0]; 
        System.debug('getTourTotals');
        System.debug(tourTotals);
        return null;
    }
}