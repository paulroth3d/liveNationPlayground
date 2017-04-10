/**
 *  Controller for the LNE_LocalPlanTab page - shown at the settlement app, plan tab.
 *  @author Vinay Kanuganti
 *  @see US146
 **/
public class LNE_LocalPlanTab_CX {
    private final SObject parent;

    public String adPlanId {get;set;}
    public AdPlan__c adPlanMetrics {get;set;}

    public LNE_LocalPlanTab_CX(ApexPages.StandardController controller) {
        parent = controller.getRecord();
        adPlanId = parent.Id;
        getAdPlan();
    }
    
    public PageReference getAdPlan(){
        adPlanMetrics = [select Id, LNEAdPlanBudget__c, LNESpend__c, TourSpend__c, RemainingLNEBudget__c, NonLNESpend__c, NonLNEBudget__c
                                , RemainingNonLNEBudget__c, RadioSpend__c, RadioSpendPercent__c, DigitalSpend__c
                                , DigitalSpendPercent__c, TelevisionSpend__c, TelevisionSpendPercent__c, PrintSpend__c
                                , PrintSpendPercent__c, OutdoorSpend__c, OutdoorSpendPercent__c, ProductionMiscellaneousSpend__c
                                , ProductionMiscellaneousSpendPercent__c, Tour__c, TourDigitalSpend__c, TourDigitalSpendPercent__c
                                , TourOtherSpend__c, TourOtherSpendPercent__c 
            from AdPlan__c where Id = :adPlanId][0];
        return null;
    }
}