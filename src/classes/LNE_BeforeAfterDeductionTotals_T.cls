/**
 *	Trigger logic to check for changes on any fields that would case a Before/After
 *	deduction calculation to fire off
 *	@author Daniel Nakonieczny
 **/
public with sharing class LNE_BeforeAfterDeductionTotals_T {

    private static final DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();

	/**
     *  Checks if any fields changed that would require a recalculation of deduction totals
     *  @param newList Deduction__c[]
     *  @param oldMap Map<Id,Deduction__c>
     *  @return Deduction__c[] - list of deductions updated.
    **/
    
    public static Deduction__c[] execute( Deduction__c[] newList, Map<Id,Deduction__c> oldMap ){
    	List<Deduction__c> changedDeductions = new List<Deduction__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();
 		ChangedDeduction objChange = null;

 		if (oldMap == null){
            oldMap = new Map<Id, Deduction__c>();
        }

		for (Deduction__c newDeduction : newList ){
			if(oldMap.containsKey(newDeduction.Id)){
                
                Deduction__c oldDeduction = oldMap.get(newDeduction.Id);
                objChange = new ChangedDeduction(oldDeduction, newDeduction);
                
                if(
                    objChange.notEqualsStr('RateType__c', false) ||
                    objChange.notEquals('AmountRate__c') ||
                    objChange.notEquals('Adjustment__c') ||
                    objChange.notEqualsStr('ApplyTicketScale__c', false) ||
                    objChange.notEqualsStr('TicketScaleList__c', false) ||
                    objChange.notEqualsStr('StageType__c', false) ||
                    objChange.notEqualsStr('IncludeInAuditPrice__c', false)
                ) {
                	if (objChange.getNewDeduction().Event__c != null) {
                		listOfRelatedEventIds.add(objChange.getNewDeduction().Event__c);	
                	}
                	changedDeductions.add(objChange.getNewDeduction());
                  }
                
            } else {
                if (newDeduction.Event__c != null) {
                	listOfRelatedEventIds.add(newDeduction.Event__c);	
                }
                changedDeductions.add(newDeduction);
            }
		}

		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return changedDeductions;
    }

    /**
     *  Populates the Event__c lookup (if blank) by parsing the EventIDStageType__c.
     *  This should run only on before insert
     *  @param newList Deduction__c[]
    **/
    public static void populateEventIfBlank(Deduction__c[] newList) {

        for (Deduction__c d : newList) {
            if (d.Event__c == null && !String.isBlank(d.EventIDStageType__c)) {

                String encodedField = EncodingUtil.urlEncode(d.EventIDStageType__c, 'UTF-8');
                String encodedDelimeter = EncodingUtil.urlEncode(DATA_SETTINGS.CombinedKeyDelimiter__c, 'UTF-8');

                List<String> l = encodedField.split(encodedDelimeter);

                if (!l.isEmpty()) {
                    d.Event__c = l[0];

                    if (l.size()>1) {
                        d.StageType__c = l[1];
                    }
                }
            }
        }
    }
    
    /**
     *  Recalculates for deleted Deductions
     *  @param Deductions[] - list of deleted Deductions.
     *  @return Deductions[] - list of Deductions updated.
    **/
    
     public static Deduction__c[] execute( Deduction__c[] deletedList ){
    	List<Deduction__c> ChangedDeductions = new List<Deduction__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();

 		for (Deduction__c deletedDeduction : deletedList){
 		    if (deletedDeduction.Event__c != null) {
            	listOfRelatedEventIds.add(deletedDeduction.Event__c);	
            }
            ChangedDeductions.add(deletedDeduction);
 		}
 		
 		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return ChangedDeductions;
    }
    
    /**
     *  Internal class to represent the changes from the object.
    **/
    class ChangedDeduction extends LNE_SObjectChange {
        
        ChangedDeduction( Deduction__c oldObject, Deduction__c newObject ){
            super( oldObject, newObject );
        }
        
        Deduction__c getNewDeduction(){
            return( (Deduction__c)this.newObject );
        }
    }
}