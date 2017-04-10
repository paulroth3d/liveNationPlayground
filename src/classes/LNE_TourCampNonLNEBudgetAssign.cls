/**
 *  Trigger logic to update the TourCampaign_AdPlan record
 *  when the Non-LNE Budget is assigned (or removed)
 *  from the tour campaign.
 *  @author Paul Roth <proth@salesforce.com
 *  @see US689 / US146
 **/
public class LNE_TourCampNonLNEBudgetAssign {

    /**
     *  updates all the TourCampaignAdPlans - when the Non-LNE budget
     *  has been assigned.
     *  <p>Please note that the HasNonLNETourBudget is also assigned in LNE_TourLogic_T and LNE_AdPlanLogic_T</p>
     *  <p>This is exclusively for the purpose of when the tour campaign is finally assigned (or removed)</p>
     *  @assumption - only run on update.
     *  @param TourCampaign__c[] newList
     *  @param Map<Id,TourCampaign__c> oldMap
     *  @return TourCampaignAdPlan__c[] - list of tour campaign ad plans that were updated.
     **/
    public static TourCampaignAdPlan__c[] execute( TourCampaign__c[] newList, Map<Id,TourCampaign__c> oldMap ){
        TourCampaignAdPlan__c[] results = new TourCampaignAdPlan__c[]{};
        
        TourCampaign__c[] validTourCampaigns = new TourCampaign__c[]{};
        TourCampaign__c oldTourCampaign;
        for( TourCampaign__c newCampaign : newList ){
            if( oldMap.containsKey( newCampaign.Id )){
                oldTourCampaign = oldMap.get( newCampaign.Id );
                
                //-- continue only if the NonLNETourBudget__c was assigned.
                if(newCampaign.NonLNETourBudget__c != oldTourCampaign.NonLNETourBudget__c){
                    validTourCampaigns.add( newCampaign );
                }
            }
        }
        
        if( validTourCampaigns.size() < 1 ){
            return( results );
        }
        
        for( TourCampaign__c updatedCampaign : [
            select id, NonLNETourBudget__c, NonLNETourBudget__r.Type__r.Name, ( select id, name from Tour_Campaign_Ad_Plan__r )
            from TourCampaign__c
            where id in :validTourCampaigns
        ]){
            for( TourCampaignAdPlan__c tcAdPlan : updatedCampaign.Tour_Campaign_Ad_Plan__r ){
                tcAdPlan.HasNonLNETourBudget__c = ( updatedCampaign.NonLNETourBudget__c != null );
                if( updatedCampaign.NonLNETourBudget__c != null ){
                    tcAdPlan.Sponsor__c = ( updatedCampaign.NonLNETourBudget__r.Type__r.Name );
                } else {
                    tcAdPlan.Sponsor__c = null;
                }
                results.add( tcAdPlan );
            }
        }
        
        if( results.size() > 0 ){
            update results;
        }
        
        return( results );
    }

}