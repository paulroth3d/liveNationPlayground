/** 
 *  Trigger logic to add validation to the CoPromoter(Deal__c) records.
 *  @author John Casimiro
 **/
 public class LNE_DealCoPromoter_T {
    
    /**
    *  Prevent delete of Live Nation Co-Promoter Deals for users except system admins
    *  @param newList Deal__c[]
    *  @return Deal__c[] - list of ledger entries updated.
    **/
    public static Deal__c[] checkDeletePermission( Deal__c[] newList){

        for (Deal__c d : newList){
           d.addError('Only Global Data Administrators are permitted to delete Live Nation Co-Promoter records.');
        }
    }
    
}
