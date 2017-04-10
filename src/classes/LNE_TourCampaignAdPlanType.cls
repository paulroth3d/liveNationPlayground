/**
 *  Trigger logic to update the tour campaign type on tour campaign ad plans
 *  @author Paul Roth <proth@salesforce.com
 *  @see US689 / US146
 **/
public class LNE_TourCampaignAdPlanType {
	
	public static final String RT_TOUR_CAMPAIGN_DIGITAL = 'Digital';
	public static final String RT_TOUR_CAMPAIGN_MISC = 'Misc';
	public static final String RT_TOUR_CAMPAIGN_PROD = 'Production';

	/**
	 *  Updates the tour campaign type on tour campaign ad plans.
	 *  <p>Please note that the HasNonLNETourBudget is also assigned in LNE_TourLogic_T and LNE_AdPlanLogic_T</p>
	 *  <p>This is exclusively for the purpose of when the tour campaign is finally assigned (or removed)</p>
	 *  @assumption - only run on update.
	 *  @param TourCampaign__c[] newList
	 *  @param Map<Id,TourCampaign__c> oldMap
	 *  @return TourCampaignAdPlan__c[] - list of tour campaign ad plans that were updated.
	 **/
	public static TourCampaignAdPlan__c[] execute( TourCampaign__c[] newList, Map<Id,TourCampaign__c> oldMap ){
		TourCampaignAdPlan__c[] results = new TourCampaignAdPlan__c[]{};
		
		Id[] validTourCampaigns = new Id[]{};
		TourCampaign__c oldTourCampaign;
		for( TourCampaign__c newCampaign : newList ){
			if( oldMap.containsKey( newCampaign.Id )){
				oldTourCampaign = oldMap.get( newCampaign.Id );
				
				//-- continue only if the TourCampaign__c.RecordTypeId was updated.
				if( 
					newCampaign.RecordTypeId != oldTourCampaign.RecordTypeId
				){
					validTourCampaigns.add( newCampaign.Id );
				}
			}
		}
		
		if( validTourCampaigns.size() < 1 ){
			return( results );
		}
		
		//-- @INVARIANT: validTourCampaigns are a list of all the tour campaigns that have changed recordTypes.
		//System.debug( validTourCampaigns );
		
		String tourCampaignRT;
		for( TourCampaignAdPlan__c tcAdPlan : [
			select id, name, TourCampaign__r.recordType.Name
			FROM TourCampaignAdPlan__c
			WHERE TourCampaign__c in :validTourCampaigns
		]){
			tcAdPlan.TourCampaignType__c = null;
			if( tcAdPlan.TourCampaign__r != null && tcAdPlan.TourCampaign__r.RecordType != null ){
				tcAdPlan.TourCampaignType__c = tcAdPlan.TourCampaign__r.RecordType.Name;
			}
			results.add( tcAdPlan );
		}
		
		if( results.size() > 0 ){
			update results;
		}
		
		return( results );
	}

}