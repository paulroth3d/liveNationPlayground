/**
 *	Trigger logic to check for changes on any fields that would cause the
 *	financial calculator to fire off
 *	@author Daniel Nakonieczny
 **/
public with sharing class LNE_BonusMetrics_T {
	/**
     *  Checks if any fields changed that would require a recalculation of event totals
     *  @param newList BonusDetail__c[]
     *  @param oldMap Map<Id,BonusDetail__c>
     *  @return BonusDetail__c[] - list of bonuses updated.
    **/
    
    public static BonusDetail__c[] execute( BonusDetail__c[] newList, Map<Id,BonusDetail__c> oldMap ){
    	List<BonusDetail__c> changedBonuses = new List<BonusDetail__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();
        ChangedBonusDetail objChange = null;

 		if (oldMap == null){
            oldMap = new Map<Id, BonusDetail__c>();
        }

        for (BonusDetail__c newRecord : newList ){
            if(oldMap.containsKey(newRecord.Id)){
                
                BonusDetail__c oldRecord = oldMap.get(newRecord.Id);
                objChange = new ChangedBonusDetail(oldRecord, newRecord);
                
                if(
                    objChange.notEquals('StartPoint__c') ||
                    objChange.notEquals('EndPoint__c') ||
                    objChange.notEquals('Increment__c') ||
                    objChange.notEquals('BonusAmount__c') ||
                    objChange.notEqualsStr('Type__c', false) ||
                    objChange.notEqualsStr('BonusBase__c', false) 
                ) {
                    if (objChange.getNewObject().ParentEventId__c != null) {
                        listOfRelatedEventIds.add(objChange.getNewObject().ParentEventId__c);  
                    }
                    changedBonuses.add(objChange.getNewObject());
                  }
                
            } else {
                if (newRecord.ParentEventId__c != null) {
                    listOfRelatedEventIds.add(newRecord.ParentEventId__c); 
                }
                changedBonuses.add(newRecord);
            }

            populateBonusMessage(newRecord);
        }

		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return changedBonuses;
    }
    
    /**
     *  Recalculates for deleted Bonuses
     *  @param Bonuses[] - list of deleted Bonuses.
     *  @return Bonuses[] - list of Bonuses updated.
    **/
    
     public static BonusDetail__c[] executeDelete( BonusDetail__c[] deletedList ){
    	List<BonusDetail__c> changedBonuses = new List<BonusDetail__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();

 		for (BonusDetail__c deletedBonus : deletedList){
 		    if (!String.isBlank(deletedBonus.ParentEventId__c)) {
            	listOfRelatedEventIds.add(deletedBonus.ParentEventId__c);	
            }
            changedBonuses.add(deletedBonus);
 		}
 		
 		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return changedBonuses;
    }

    private static void populateBonusMessage(BonusDetail__c bonus) {
        String message = '';

        if (bonus.Type__c != null) {
            if (bonus.Type__c == 'Step Up') {
                message += 'Artist to receive a bonus of ';
                if (bonus.BonusAmount__c != null) {
                    message += bonus.CurrencyIsoCode + ' ' + bonus.BonusAmount__c.format();
                }
                message += ' starting at ';
                if (bonus.StartPoint__c != null) {
                    message += bonus.StartPoint__c.format() + ' ';
                }
                if (bonus.BonusBase__c != null) {
                    message += bonus.BonusBase__c.toLowerCase();
                }
                message += ', plus ';
                if (bonus.BonusAmount__c != null) {
                    message += bonus.CurrencyIsoCode + ' ' + bonus.BonusAmount__c.format();
                }
                message += ' per ';
                if (bonus.Increment__c != null) {
                    message += bonus.Increment__c.format() + ' ';
                }
                if (bonus.BonusBase__c != null) {
                    message += bonus.BonusBase__c.toLowerCase();
                }
                message += ' increment up to ';
                if (bonus.EndPoint__c == null) {
                    message += 'sellout ';
                } else {
                    message += bonus.EndPoint__c.format() + ' ';
                }
                if (bonus.BonusBase__c != null) {
                    message += bonus.BonusBase__c.toLowerCase();
                }
                message += '.';
            }

            if (bonus.Type__c == 'Retro') {
                message += 'If total ';
                if (bonus.BonusBase__c != null) {
                    message += bonus.BonusBase__c.toLowerCase();
                }
                message += ' is between ';
                if (bonus.StartPoint__c != null) {
                    message += bonus.StartPoint__c.format();
                }
                message += ' and ';
                if (bonus.EndPoint__c == null) {
                    message += 'sellout';
                } else {
                    message += bonus.EndPoint__c.format();
                }
                message += ', Artist to receive a bonus of ';
                if (bonus.BonusAmount__c != null) {
                    message += bonus.CurrencyIsoCode + ' ' + bonus.BonusAmount__c.format();
                }
                message += ' per ';
                if (bonus.Increment__c != null) {
                    message += bonus.Increment__c.format() + ' ';
                }
                if (bonus.BonusBase__c != null) {
                    message += bonus.BonusBase__c.toLowerCase();
                }
                message += ' increment retroactive to the first ';
                if (bonus.BonusBase__c != null) {
                    if (bonus.BonusBase__c == 'Drop Count'){
                        message += 'attendee.';
                    } else {
                        message += 'paid ticket.';
                    }
                }
            }
        }

        bonus.ArtistBonusExplanation__c = message;
    }

    /**
     *  Internal class to represent the changes from the object.
    **/
    class ChangedBonusDetail extends LNE_SObjectChange {
        
        ChangedBonusDetail( BonusDetail__c oldObject, BonusDetail__c newObject ){
            super( oldObject, newObject );
        }
        
        BonusDetail__c getNewObject(){
            return( (BonusDetail__c)this.newObject );
        }
    }
}