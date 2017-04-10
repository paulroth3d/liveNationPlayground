/** 
 *  Trigger logic to check for existing BonusDetail__c and validates the Start Point
 *  <p>Assumes that the trigger will be run on a before update or before insert</p>
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/
 public class LNE_BonusStartPointValidation_T {
  /**
   *  Validates the Start Point value for a Bonus once it is saved to not be less than the End Point of other records with a lesser Start Point
   *  @param newList BonusDetail__c[]
   *  @param oldMap Map<Id,BonusDetail__c>
   *  @return BonusDetail__c[] - list of ledger entries updated.
  **/
    
    public static BonusDetail__c[] execute( BonusDetail__c[] newList, Map<Id,BonusDetail__c> oldMap ){
        BonusDetail__c[] results = new BonusDetail__c[]{};
        BonusDetail__c[] existingDeals = new BonusDetail__c[]{};
       
        if ( newList == null ){
            return( results );
        }
        
        Set<Id> dealsIds = new Set<Id>();
        
        for(BonusDetail__c d : newList){
            dealsIds.add(d.Deal__c);
        }
        
        if (dealsIds.size() < 1){
             return ( results );
        }
        
        Map<Id, Deal__c> deals = new Map<Id, Deal__c>([SELECT Id, (SELECT Id, StartPoint__c,EndPoint__c FROM BonusDetails__r) FROM Deal__c WHERE Id IN :dealsIds]);

        for(Integer i = 0; i < newList.size(); i++){ 
            newList.get(i).StartPointlessonother__c = false;
            for(Deal__c d : deals.values()){
                for(BonusDetail__c bonus : d.BonusDetails__r){
                    if(	newList.get(i).Deal__c == d.Id && 
                    	newList.get(i).StartPoint__c <= bonus.EndPoint__c && 
                    	newList.get(i).EndPoint__c >= bonus.StartPoint__c && 
                    	newList.get(i).Id != bonus.Id){
                
                    	newList.get(i).StartPointlessonother__c = true;
                        results.add(newList.get(i));
                	}
                         
                }
                 
                List<BonusDetail__c> bonusNew = newList.deepClone();
      			bonusNew.remove(i);
          
                for(BonusDetail__c bonusN : bonusNew){
                    
                    System.debug(newList.get(i).StartPoint__c + ' <= ' + bonusN.EndPoint__c + ' && ' + newList.get(i).EndPoint__c  + ' >= ' +  bonusN.StartPoint__c);
                    if(newList.get(i).Deal__c == d.Id && newList.get(i).StartPoint__c <= bonusN.EndPoint__c && newList.get(i).EndPoint__c >= bonusN.StartPoint__c){
                
                    	newList.get(i).StartPointlessonother__c = true;
                        results.add(newList.get(i));
               		 }
                    
                }
            }
        }
        
        System.debug('Updated Bonus Details: ');
        System.debug(results);
        return ( results );
    }
    
}