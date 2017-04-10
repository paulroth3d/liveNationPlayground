/** 
 *  Trigger logic to summarize the Total Guarantees & Overhead field of all Support Deals in Total Support Act Expenses field on the related Event
 *  <p>Assumes that the trigger will be run on a after insert or after update.</p>
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/
public class LNE_SupportDealsSummary_T {
  /**
   *  Summarize the Total Guarantees & Overhead fields on all Support Deals in Total Support Act Expenses field on the related Event
   *  @param newList Deal__c[]
   *  @param oldMap Map<Id,Deal__c>
   *  @return Deal__c[] - list of deals updated.
  **/
	
	public static Deal__c[] execute( Deal__c[] newList, Map<Id,Deal__c> oldMap ){

		Deal__c[] results = new Deal__c[]{};
		Deal__c[] existingDeals = new Deal__c[]{};
		ChangedDeal objChange = null;

		if ( newList == null && oldMap == null){
			return( results );
		}

		if (oldMap == null){
            oldMap = new Map<Id, Deal__c>();
        }
		
		Set<Id> eventIds = new Set<Id>();

		//Check for inserts or updates.
		if(newList != null && !newList.isEmpty()){
			for(Deal__c newDeal : newList){
				if(newDeal.StageType__c == 'Plan' || newDeal.StageType__c == 'Settlement'){
	            	if(oldMap.containsKey(newDeal.Id)){
		                Deal__c oldDeal = oldMap.get(newDeal.Id);
		                objChange = new ChangedDeal(oldDeal, newDeal);

		                if(
		                    objChange.notEquals('TotalGuaranteesandOverhead__c') ||
		                    objChange.notEquals('GuaranteeAmount__c') ||
		                    objChange.notEquals('ArtistSuppliedSL__c') ||
		                    objChange.notEquals('OtherTalentAmount__c') ||
		                    objChange.notEquals('RollUpTalentOverheadAmount__c')
		                ){
		                	
		            		eventIds.add(newDeal.Event__c);
		                }
	                }else if(oldMap == null || oldMap.isEmpty()){
	                	eventIds.add(newDeal.Event__c);
	                }
				}
			}
		}else if(newList == null && oldMap != null){
			//recalculate for deletes
			for(Deal__c oldDeal : oldMap.values()){
				if(oldDeal.StageType__c == 'Plan' || oldDeal.StageType__c == 'Settlement'){
					eventIds.add(oldDeal.Event__c);
				}
			}
		}
		
		//-- short circuit
		if( eventIds.size() < 1 ){
			//-- no point in continuing
			return( results );
		}
		
		Map<Id, Event__c> events = new Map<Id, Event__c>();
		if (eventIds.size() > 0) {
			events = new Map<Id, Event__c>([SELECT Id, EventName__c, TotalSupportActExpenses__c, SettlementTotalSupportActExpenses__c, Status__c
													, ProjectedDropCount__c, ProjectedPaidTickets__c, TotalGuaranteesOverhead__c
													, (SELECT Type__c,Event__c, TotalGuaranteesandOverhead__c,StageType__c 
														FROM Deals__r WHERE (StageType__c = 'Plan' or StageType__c = 'Settlement')) 
														FROM Event__c WHERE Id IN :eventIds]);
		}
		
		for(Event__c event : events.values()){
			event.TotalSupportActExpenses__c = 0.0;
			event.SettlementTotalSupportActExpenses__c = 0.0;
			event.TotalGuaranteesOverhead__c = 0.0;


			for(Deal__c deal : event.Deals__r){
				Decimal TotalGuaranteesandOverhead = deal.TotalGuaranteesandOverhead__c == null ? 0.0 : deal.TotalGuaranteesandOverhead__c;
				
				if(deal.Type__c == 'Support'){
					if (deal.StageType__c == 'Settlement') {
						event.SettlementTotalSupportActExpenses__c += TotalGuaranteesandOverhead;
					} else {
						event.TotalSupportActExpenses__c += TotalGuaranteesandOverhead;
					}
				}

				if(deal.StageType__c == 'Plan'){
					event.TotalGuaranteesOverhead__c += TotalGuaranteesandOverhead;
				}
				
				if(deal.Type__c == 'Primary Headliner' && deal.StageType__c == 'Plan'){
					event.PrimaryGuaranteesOverhead__c = deal.TotalGuaranteesAndOverhead__c;
				}
			}
		}      		
	   
		update events.values();
		
		return ( results );
	}

	/**
     *  Internal class to represent the changes from the object.
    **/
    class ChangedDeal extends LNE_SObjectChange {
        
        ChangedDeal( Deal__c oldObject, Deal__c newObject ){
            super( oldObject, newObject );
        }
        
        Deal__c getNewDeal(){
            return( (Deal__c)this.newObject );
        }
    }
}