/**
 *  Copys formula fields to non formula fields to use in rollup summaries on the Deal__c object.
 *  @author John Casimiro <jcasimiro@salesforce.com>
 **/
 
public class LNE_DSLFieldCopy_T {
    public static DealSettlementLedger__c[] execute( DealSettlementLedger__c[] newList){
    	DealSettlementLedger__c[] results = new DealSettlementLedger__c[]{};
   
		if ( newList == null ){
			return( results );
		}
		
		for (DealSettlementLedger__c dsl : newList){
		    dsl.CurrentAmountAtProjectionNF__c = dsl.CurrentAmountatProjection__c;
		    dsl.CurrentAmountAtSelloutNF__c = dsl.CurrentAmountAtSellout__c;
		    dsl.ExpenseAdjustmentAtProjectionNF__c = dsl.ExpenseAdjustmentatProjection__c;
		    dsl.ExpenseAdjustmentAtSelloutNF__c = dsl.ExpenseAdjustmentAtSellout__c;
		    dsl.TypeNF__c = dsl.Type__c;
		    dsl.PrimaryCoProShareAtProjectionNF__c = dsl.PrimaryCoProShareAtProjection__c;
		    dsl.PrimaryCoProShareAtSelloutNF__c = dsl.PrimaryCoProShareAtSellout__c;
		    dsl.DealTypeNF__c = dsl.DealType__c;
		    dsl.EventVenueOwnershipTypeNF__c = dsl.EventVenueOwnershipType__c;
		    dsl.PrimarySecondaryCoPromoterNF__c = dsl.PrimarySecondaryCoPromoter__c;
		    results.add(dsl);
		}
	    
	    return results;
    }
    
    /**
     *  Make dirty child objects of the Deal so rollup summary fields are updated.
     *    DealSettlementLedger__c - when every Deal is updated, update related DSLs
     *    ArtistRetroStepUpDetail__c - when Deal__c.DealType__c OR Deal__c.DealApplicationType__c are changed.
     *  @author John Casimiro <jcasimiro@salesforce.com>
     **/
    public static void recalculateDealChildren(Deal__c[] newList, Map<Id, Deal__c> oldMap){
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Deal__c.CoPromoter'});         
        Id RT_COPROMOTER = recordTypeMap.get( 'Deal__c.CoPromoter' );  //recordtypeid for ancillary ledger entry      
    	
        set<id> dslDealIds = new set<id>();
        set<id> arsudDealIds = new set<id>();
        
        ChangedDeal cDeal;
        
        if (newList != null){
        	Deal__c oldDeal;
    		for(Deal__c d : newList){
    			if( oldMap != null && oldMap.containsKey( d.Id )){
    				cDeal = new ChangedDeal( oldMap.get( d.Id ), d );
    			} else {
    				cDeal = null;
    			}
    			
    		    if (
    		    	(cDeal == null || cDeal.notEquals( 'RecordTypeId' ) || cDeal.notEqualsStr( 'Type__c', true )) &&
    		    	d.recordtypeid == RT_COPROMOTER && !('Internal').equals( d.Type__c )
    		    ){
    		        dslDealIds.add(d.id);
    		    } else if ( cDeal == null || cDeal.notEquals( 'DealType__c' ) || cDeal.notEquals( 'DealApplicationType__c' ) ){
    		        arsudDealIds.add(d.id);
    		    }
    		}
    		
    		if (dslDealIds.size() > 0){
        		List<DealSettlementLedger__c> dsls = [select Id from DealSettlementLedger__c where Deal__c in :dslDealIds];
        		
        		if (dsls.size() > 0)
        		    update dsls;
    		}
    		
    		if(arsudDealIds.size() > 0){
    		    ArtistRetroStepUpDetail__c[] arsuds = [select Id from ArtistRetroStepUpDetail__c where Deal__c in :arsudDealIds];
    		    
    		    if (arsuds.size() > 0)
    		        update arsuds;
    		}
        }
	    
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