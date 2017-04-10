/** 
 *  Trigger logic to copy Primary Headliner values to any Co-Headliner records ( parent Deal__c ).
 *  Copies Deal Type, Deal Application Type, Backend %, and Deal Calculation
 *  @author Dominic Aveyard
 **/
 public class LNE_CopyPrimaryHeadlinerToCoHeadliners_T {
    
    static final String RT_Artist = 'Deal__c.Artist';
    
    /**
    *  Updates coheadliners with values from primary headliner when primary changes.
    *  @param newList Deal__c[]
    *  @param oldMap Map<Id,Deal__c>
    *  @return Deal__c[] - list of ledger entries updated.
    **/
    public static Deal__c[] execute( Deal__c[] newList, Map<Id,Deal__c> oldMap ){
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{ RT_Artist }
		);
		Id RT_ARTIST_ID = recordTypeMap.get( RT_Artist );
		
		Boolean changed = false;
        Id[] actionDealEventIds = new List<Id>();
        List<Deal__c> coheadliners = new List<Deal__c>();
        Map<String, Deal__c> eventPrimaryHeadlinersMap = new Map<String, Deal__c>();
        Map<Id, Deal__c> eventPrimaryHeadlinersMap2 = new Map<Id, Deal__c>();
        
        List<Deal__c> updatedCoHeadliners = new List<Deal__c>();
		
		//-- @TODO: pr 2/24 check for fields changing first, look into other opportunities for improvements.
		
		if( oldMap == null ){
			oldMap = new Map<Id,Deal__c>();
		}
		
		ChangedDeal cDeal;
		Deal__c oldDeal;
		for ( Deal__c nd : newList ) {
			
			if( oldMap.containsKey( nd.Id )){
	        	oldDeal = oldMap.get( nd.Id );
				cDeal = new ChangedDeal( oldDeal, nd );

			    //-- only continue if something has changed
			    
			    if(
			    	!(  cDeal.notEquals( 'RecordTypeId' ) ||
			    		cDeal.notEquals( 'BackendPercent__c') ||
			    		cDeal.notEqualsStr( 'Type__c', false ) ||
			    		cDeal.notEqualsStr( 'DealType__c', false ) ||
			    		cDeal.notEqualsStr( 'DealApplicationType__c', false ) ||
			    		cDeal.notEqualsStr( 'DealCalculation__c', false )
			    	 )
			    ){
			    	//-- neither the record type or the type field changed.
			    	continue;
			    }
			}
			
			if (
				nd.RecordTypeId == RT_ARTIST_ID &&
				(nd.Type__c == 'Primary Headliner' || nd.Type__c == 'Co-Headliner')
			){
                actionDealEventIds.add(nd.Event__c);
            }
        }
        
        if( actionDealEventIds == null || actionDealEventIds.size() < 1 ){
        	//-- no point in continuing
        	return(updatedCoHeadliners);
        }

        List<Deal__c> allDealList = new List<Deal__c>();
        if (actionDealEventIds.size() > 0){
            allDealList = [
                SELECT Event__c,
                       OtherTalentDescription__c,
                       DealApplicationType__c,
                       DealCalculation__c,
                       DealType__c,
                       BackendPercent__c,
                       Type__c,
                       StageType__c
                FROM Deal__c 
                WHERE Event__c IN :actionDealEventIds
                AND Type__c IN ('Primary Headliner', 'Co-Headliner')
            ];
        }
        
        for (Deal__c adl : allDealList ) {
            if (adl.Type__c == 'Primary Headliner') {
                eventPrimaryHeadlinersMap.put(adl.Event__c+adl.StageType__c, adl);
            }  
            if (adl.Type__c == 'Co-Headliner') {
                coheadliners.add(adl);
            }
        }

        for ( Deal__c ch : coheadliners ) {   
            Deal__c p = eventPrimaryHeadlinersMap.get(ch.Event__c+ch.StageType__c);

            if (p != null) {
                //-- copy: Deal Type, Deal Application Type, Backend %, and Deal Calculation
                changed = false;
                
                if (ch.DealType__c != p.DealType__c) {
                    ch.DealType__c = p.DealType__c;
                    changed = true;
                }
                if (ch.DealApplicationType__c != p.DealApplicationType__c) {
                    ch.DealApplicationType__c = p.DealApplicationType__c;
                    changed = true;
                }
                if (ch.BackendPercent__c != p.BackendPercent__c) {
                    ch.BackendPercent__c = p.BackendPercent__c;
                    changed = true;
                }
                if (ch.DealCalculation__c != p.DealCalculation__c) {
                    ch.DealCalculation__c = p.DealCalculation__c;
                    changed = true;
                }
                
                if (changed) {
                    updatedCoHeadliners.add(ch);
                }
            }
        }
        
        //   update all the coheadliners
        update (updatedCoHeadliners);

        return updatedCoHeadliners;
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