public class LNE_BlockDeletingTourLE_T {

    /**
    *  Prevent delete of Tour Ledger Entry if Associated Event is Linked to a Tour
    *  Also prevents the delete of a Ledger Entry if it has OfferRate__c or InHouseRate__c
    *  populated and the related Event__r.SettlementStarted__c = true
    *  @param newList LedgerEntry__c[]
    *  @return LedgerEntry__c[] - list of ledger entries updated.
    **/
    public static LedgerEntry__c[] execute( LedgerEntry__c[] newList){
        
        List<Id> associatedEventIds = new List<Id>();
        for (LedgerEntry__c le : newList){
            associatedEventIds.add(le.Event__c);
        }
        
        Map<Id,Event__c> associatedEvents = new Map<Id,Event__c>([SELECT Tour__c, SettlementStarted__c FROM Event__c WHERE Id =: associatedEventIds ]);
        
        for (LedgerEntry__c le : newList){
            if(le.GLCode__c == '50360' && associatedEvents.get(le.Event__c).Tour__c != null){
                le.addError('The Tour Ledger Entry - 50360 cannot be deleted as long as the Event is associated to a Tour');
            }

            if (associatedEvents.get(le.Event__c) != null &&
                    ((le.OfferRate__c != null && le.OfferRate__c != 0) ||
                    (le.InHouseRate__c != null && le.InHouseRate__c != 0))) {

                if (associatedEvents.get(le.Event__c).SettlementStarted__c != null &&
                    associatedEvents.get(le.Event__c).SettlementStarted__c == true) {
                    le.addError('Cannot delete this Ledger Entry because the Settlement process has started on the Event');
                }
            }

            //US 691 - Prevent deletion if Ledger Entry is AdPlan Managed
            if(le.AdPlanManaged__c == TRUE){
                le.addError('Ad Plan Ledger Entries cannot be Deleted');
            }
        }
        
        return ( newList );
    }
}