/**
 *	Trigger logic to check for changes on any fields that would case a Before/After
 *	Ticket Scale calculations to fire off
 *	@author John Casimiro
 **/
public with sharing class LNE_TicketScaleMetrics_T {

    private static final DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();

	/**
     *  Checks if any fields changed that would require a recalculation of TicketScale totals
     *  @param newList TicketScale__c[]
     *  @param oldMap Map<Id,TicketScale__c>
     *  @return TicketScale__c[] - list of TicketScales updated.
    **/
    
    public static TicketScale__c[] execute( TicketScale__c[] newList, Map<Id,TicketScale__c> oldMap ){
    	List<TicketScale__c> ChangedTicketScales = new List<TicketScale__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();
 		ChangedTicketScale objChange = null;

 		if (oldMap == null){
            oldMap = new Map<Id, TicketScale__c>();
        }
        
        Boolean recalculateEventIdStage;
		for (TicketScale__c newTicketScale : newList ){
			recalculateEventIdStage = false;
			
			if(oldMap.containsKey(newTicketScale.Id)){
                
                TicketScale__c oldTicketScale = oldMap.get(newTicketScale.Id);
                objChange = new ChangedTicketScale(oldTicketScale, newTicketScale);
                
                if(
                    objChange.notEquals('Capacity__c') ||
                    objChange.notEquals('Comps__c') ||
                    objChange.notEquals('Kills__c') ||
                    objChange.notEquals('Price__c') ||
                    objChange.notEquals('ProjectedPaidTickets__c') ||
                    objChange.notEquals('AverageLiftPerTicket__c') ||
                    objChange.notEquals('ActualSalesToDate__c') ||
                    objChange.notEquals('ActualGrossToDate__c') ||
                    objChange.notEquals('TMFee__c') ||
                    objChange.notEquals('LiftBeforeFee__c') ||
                    objChange.notEqualsStr('StageType__c', false) 
                ) {
                	if (objChange.getNewTicketScale().Event__c != null) {
                		listOfRelatedEventIds.add(objChange.getNewTicketScale().Event__c);	
                	}
                	ChangedTicketScales.add(objChange.getNewTicketScale());
                }
                
                if(
                	objChange.notEquals( 'StageType__c' ) ||
                	objChange.notEquals( 'Event__c' ) ||
                	objChange.notEquals( 'EventDateTime__c' )
                ){
                	recalculateEventIdStage = true;
                }
                
            } else {
                if (newTicketScale.Event__c != null) {
                	listOfRelatedEventIds.add(newTicketScale.Event__c);	
                }
                recalculateEventIdStage = true;
                ChangedTicketScales.add(newTicketScale);
            }
            
            if (newTicketScale.StageType__c != null && recalculateEventIdStage ) {
                newTicketScale.EventIDStageType__c = ((String)newTicketScale.Event__c).substring(0,15) + DATA_SETTINGS.CombinedKeyDelimiter__c + newTicketScale.StageType__c;
                if (newTicketScale.EventDateTime__c != null) {
                    newTicketScale.EventIDStageTypeDateTime__c = newTicketScale.EventIDStageType__c + DATA_SETTINGS.CombinedKeyDelimiter__c + ((String)newTicketScale.EventDateTime__c).substring(0,15);
                }
            }
		}

		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return ChangedTicketScales;
    }
    
    /**
     *  Recalculates for deleted TicketScales
     *  @param TicketScale__c[] - list of deleted TicketScales.
     *  @return TicketScale__c[] - list of TicketScales updated.
    **/
    
    public static TicketScale__c[] execute( TicketScale__c[] deletedList ){
    	List<TicketScale__c> ChangedTicketScales = new List<TicketScale__c>();
    	Set<Id> listOfRelatedEventIds = new Set<Id>();
 		ChangedTicketScale objChange = null;

 		for (TicketScale__c deletedTicketScale : deletedList){
 		    if (deletedTicketScale.Event__c != null) {
            	listOfRelatedEventIds.add(deletedTicketScale.Event__c);	
            }
            ChangedTicketScales.add(deletedTicketScale);
 		}
 		
 		LNE_FinancialCalculator.addEventIdSet(listOfRelatedEventIds);

		return ChangedTicketScales;
    }

    /**
     *  Populates the Event__c lookup (if blank) by parsing the EventIDStageType__c.
     *  This should run only on before insert
     *  @param newList TicketScale__c[]
    **/
    public static void populateEventIfBlank(TicketScale__c[] newList) {
        for (TicketScale__c ts : newList) {
            if (ts.Event__c == null) {
                List<String> splitEventIDStageType = splitString(ts.EventIDStageType__c);
                List<String> splitEventIDStageTypeDateTime = splitString(ts.EventIDStageTypeDateTime__c);

                populateFields(ts, splitEventIDStageType);
                populateFields(ts, splitEventIDStageTypeDateTime);
            }
        }
    }

    private static List<String> splitString(String s) {
        List<String> result = new List<String>();

        if (String.isNotBlank(s)) {
            String encodedDelimeter = EncodingUtil.urlEncode(DATA_SETTINGS.CombinedKeyDelimiter__c, 'UTF-8');
            String encodedString = EncodingUtil.urlEncode(s, 'UTF-8');
            result = encodedString.split(encodedDelimeter);
        }
        
        return result;
    }

    private static void populateFields(TicketScale__c ts, List<String> values) {
        if (!values.isEmpty()) {
            ts.Event__c = values[0];

            if (values.size()>1) {
                ts.StageType__c = values[1];
            }

            if (values.size()>2) {
                ts.EventDateTime__c = values[2];
            }
        }
    }

    /**
     *  Internal class to represent the changes from the object.
    **/
    class ChangedTicketScale extends LNE_SObjectChange {
        
        ChangedTicketScale( TicketScale__c oldObject, TicketScale__c newObject ){
            super( oldObject, newObject );
        }
        
        TicketScale__c getNewTicketScale(){
            return( (TicketScale__c)this.newObject );
        }
    }
}