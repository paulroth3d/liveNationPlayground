/**
 *  Class that provides functionality for LNE_CampaignTab.page
 *
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 *
 **/
public class LNE_CampaignTab_CX {
	public String gridToShow {get;set;}
	public String matrixReportId {get;set;}
	public String tourId {get;set;}
	public Tour__c tour {get;set;} 

	public LNE_CampaignTab_CX(ApexPages.StandardController controller) {
		gridToShow = 'tour_campaign';
		getMatrixReportId();
		tourId = controller.getRecord().Id;
		refreshTour();
    }

    public void showTourCampaigns() {
    	gridToShow = 'tour_campaign';
    }

    public void showTourAdPlans() {
    	gridToShow = 'tour_ad_plan';
    }

    private void getMatrixReportId() {
    	List<Report> reportList = [SELECT Id FROM Report WHERE DeveloperName = 'TourCampaignswithAdPlans'];

    	if (!reportList.isEmpty()){
    		matrixReportId = reportList[0].Id;
    	}
    }

    public void refreshTour() {
        this.tour = [SELECT Name, LNEMarketingBudget__c, LNESpend__c, RemainingLNEBudget__c, NonLNEBudget__c, NonLNESpend__c, RemainingNonLNEBudget__c, DigitalSpendPercent__c,
                MiscSpendPercent__c, ProductionSpendPercent__c, DigitalSpend__c, MiscSpend__c, ProductionSpend__c FROM Tour__c WHERE Id = :tourId];
    }

}