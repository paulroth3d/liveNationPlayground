/**
 * Trigger logic that checks if the Flash Process started and creates the necesary Ledger Entry placeholders
 * @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/
public class LNE_CheckFlashStarted_T {
    
    private static String DIVISION_TC = 'Theaters & Clubs';
    private static String DIVISION_CANADA = 'Canada Concerts';
    private static String DIVISON_US = 'US Concerts';
    
    private static String TYPE_ANCILLARY = 'Ancillary';
    private static String TYPE_COGS = 'COGS';
    private static String TYPE_TICKETREVENUE = 'Ticket Revenue';
    private static String TYPE_EXPENSES = 'Expenses';
    private static String TYPE_CONTRA = 'Contra';
    private static String TYPE_DIVISION = 'Division';
    private static String TYPE_COPROMOTE_EXPENSE = 'Co Promote Expense';
    private static String TYPE_COPROMOTE_REVENUE = 'Co Promote Revenue';
    private static String TYPE_OTHER = 'Other';
    private static String TYPE_TALENT_FEES = 'Talent Fees';
    
    private static String EVENT_FLASH_STARTED = 'Flash Started';

    public static Event__c[] execute( Event__c[] newList, Map<Id,Event__c> oldMap ){
        
        if ( newList == null || newList.size() == 0){    //short circuit evaulation of empty input
        	//return empty list for empty input
            return( new list<Event__c>() );
        }
       
        Event__c[] newEvents = null;
        
        GLAccount__c[] listOfGlAccount = new GLAccount__c[]{};
        LedgerEntry__c[] ledgerEntryPlaceHolder = new LedgerEntry__c[]{};

        if( oldMap == null ){ //handle insert trigger where oldMap == null
        	oldMap = new Map<Id,Event__c>();
        }
        
        Event__c[] validEvents = new Event__c[]{};
        Event__c oldEvent = null;
        for( Event__c newEvent : newList ){
        	if ( newEvent.Status__c.equalsIgnoreCase( EVENT_FLASH_STARTED ) ) {
	        	if( oldMap.containsKey( newEvent.Id )){
	        		//-- it is an update
	        		oldEvent = oldMap.get( newEvent.Id );
	        		if( !newEvent.Status__c.equals( oldEvent.Status__c )){    //filter only events that have changed
	        			validEvents.add( newEvent );
	        		}
	        	} else {
	        		//-- it is an insert
	    			validEvents.add( newEvent );
	        	}
        	}
        }
        
        //-- short circuit if there are not events that have changed or inserted.
        if( validEvents.isEmpty() ){
        	return( validEvents );
        }
        
        newEvents = [
        	Select Id, Status__c, RecordTypeId, Office__r.Division__c, 
        		(Select Id, RecordTypeId, GLAccount__c From LedgerEntries__r) 
        	From Event__c 
        	WHERE Id IN :validEvents
        ];

        //-- @TODO: iterate over only the GL accounts that we care about within the event.
        //-- ...
        
        
        listOfGlAccount = [
        	Select Id, Type__c, ApplyToBuySellEvent__c, ApplyToGospelBrunchEvent__c, ApplyToHOBEvent__c, 
        		ApplyToNAMusicEvent__c, ApplyToPromotedEvent__c, ApplyToRentalEvent__c
        	FROM GLAccount__c 
        	WHERE (ApplyToBuySellEvent__c = true OR ApplyToGospelBrunchEvent__c = true OR ApplyToPromotedEvent__c = true OR ApplyToRentalEvent__c = true) 
        	AND (ApplyToHOBEvent__c = true OR ApplyToNAMusicEvent__c = true)
        ];
        
        Map<Id,GLAccount__c> buySellEventGLs = new Map<Id,GLAccount__c>();
        Map<Id,GLAccount__c> rentalEventGLs = new Map<Id,GLAccount__c>();
        Map<Id,GLAccount__c> promotedEventGLs = new Map<Id,GLAccount__c>();
        Map<Id,GLAccount__c> gospelBrunchEventGLs = new Map<Id,GLAccount__c>();
        Map<Id,GLAccount__c> hobEventGLs = new Map<Id,GLAccount__c>();
        Map<Id,GLAccount__c> naEventGLs = new Map<Id,GLAccount__c>();
        
        //sort GL Accounts into list based on attributes
        for( GLAccount__c glAcct : listOfGlAccount){          
        	if( glAcct.ApplyToBuySellEvent__c ){
        		buySellEventGLs.put( glAcct.Id, glAcct );
        	}
        	if( glAcct.ApplyToRentalEvent__c ){
        		rentalEventGLs.put( glAcct.Id, glAcct );
        	}
        	if( glAcct.ApplyToPromotedEvent__c ){
        		promotedEventGLs.put( glAcct.Id, glAcct );
        	}
        	if( glAcct.ApplyToGospelBrunchEvent__c ){
        		gospelBrunchEventGLs.put( glAcct.Id, glAcct );
        	}
        	if( glAcct.ApplyToHOBEvent__c){
        	    hobEventGLs.put( glAcct.Id, glAcct );
        	}
        	if( glAcct.ApplyToNAMusicEvent__c){
        	    naEventGLs.put( glAcct.Id, glAcct );
        	}
        }
        
        Set<Id> buySellEventGLIds = buySellEventGLs.keySet();
        Set<Id> rentalEventGLIds = rentalEventGLs.keySet();
        Set<Id> promotedEventGLIds = promotedEventGLs.keySet();
        Set<Id> gospelBrunchEventGLIds = gospelBrunchEventGLs.keySet();
        Set<Id> hobEventGLIds = hobEventGLs.keySet();
        Set<Id> naEventGLIds = naEventGLs.keySet();
        
        Map<Id, GLAccount__c[]> applicableGLPerEvent = new Map<Id, GLAccount__c[]>();
        for( Event__c evt : newEvents){
        	if(evt.RecordTypeId == LNE_RT.RT_BUYSELL_ID){
        		setupBuySell(evt, listOfGlAccount, applicableGLPerEvent, buySellEventGLIds, hobEventGLIds, naEventGLIds);
        	} else if(evt.RecordTypeId == LNE_RT.RT_RENTAL_ID){
        	    setupRental(evt, listOfGlAccount, applicableGLPerEvent, rentalEventGLIds, hobEventGLIds, naEventGLIds);
        	} else if(evt.RecordTypeId == LNE_RT.RT_PROMOTEDSHOW_ID || evt.RecordTypeId == LNE_RT.RT_FESTIVAL_ID){
        	    setupPromotedShowFestival(evt, listOfGlAccount, applicableGLPerEvent, promotedEventGLIds, hobEventGLIds, naEventGLIds);
        	} else if(evt.RecordTypeId == LNE_RT.RT_GOSPELBRUNCH_ID){
        		setupGospelBrunch(evt, listOfGlAccount, applicableGLPerEvent, gospelBrunchEventGLIds, hobEventGLIds, naEventGLIds);
        	}
        }
        
        Map<Id, Set<Id>> usedGLPerEvent = new Map<Id, Set<Id>>();
        for(Event__c evt : newEvents){
            for(LedgerEntry__c le : evt.LedgerEntries__r){
                if(usedGLPerEvent.get(evt.Id) == null){
                    usedGLPerEvent.put(evt.Id, new Set<Id>());
                }
                usedGLPerEvent.get(evt.Id).add(le.GLAccount__c);
            }
        }
        
        for(Id evtId : applicableGLPerEvent.keySet()){
           for(GLAccount__c gl : applicableGLPerEvent.get(evtId)){
               if(usedGLPerEvent.get(evtId) == null || !usedGLPerEvent.get(evtId).contains(gl.Id) ){
					ledgerEntryPlaceholder.add( setupLEPlaceHolder(gl, GLMapToLERTId.get(gl.Type__c), evtId));
                   	
                }               
            }
        }
    	
    	//all or nothing insert
    	System.debug(ledgerEntryPlaceholder);
        insert ledgerEntryPlaceholder;
        return (newList);
    }
    
    private static LedgerEntry__c setupLEPlaceHolder(GLAccount__c gl, id RTId, Id evtId) {
    	LedgerEntry__c result = 
    		new LedgerEntry__c(
	            GLAccount__c = gl.Id,
	            BaseAmount__c = 0,
	            RateType__c = 'Flat', 
	            RecordTypeId = RTId,
	            Event__c = evtId
	      	);
    	return result;
    }
    
    private static void setupBuySell(Event__c evt, list<GLAccount__c> listOfGlAccount, 
    	Map<Id, GLAccount__c[]> applicableGLPerEvent, set<id> buySellEventGLIds, set<id> hobEventGLIds,
    	set<Id> naEventGLIds) {
    		
        if(evt.Office__r.Division__c == DIVISION_TC){
		    for(GLAccount__c gl : listOfGlAccount){
		        if(buySellEventGLIds.contains(gl.Id) && hobEventGLIds.contains(gl.Id)){
		            if(applicableGLPerEvent.get(evt.Id) == null){
		                applicableGLPerEvent.put(evt.Id, new GLAccount__c[]{});
		            }
		            applicableGLPerEvent.get(evt.Id).add(gl);
		        }
		    }
	     } else if(evt.Office__r.Division__c == DIVISON_US || evt.Office__r.Division__C == DIVISION_CANADA){
	     	for(GLAccount__c gl : listOfGlAccount){
		        if(buySellEventGLIds.contains(gl.Id) && naEventGLIds.contains(gl.Id)){
		            if(applicableGLPerEvent.get(evt.Id) == null){
		                applicableGLPerEvent.put(evt.Id, new GLAccount__c[]{});
		            }
		            applicableGLPerEvent.get(evt.Id).add(gl);
		        }
		    }
		 }
    }
    
    private static void setupRental(Event__c evt, list<GLAccount__c> listOfGlAccount, 
    	Map<Id, GLAccount__c[]> applicableGLPerEvent, set<id> rentalEventGLIds, set<id> hobEventGLIds,
    	set<Id> naEventGLIds) {
    		
	    if(evt.Office__r.Division__c == DIVISION_TC){
		    for(GLAccount__c gl : listOfGlAccount){
		        if(rentalEventGLIds.contains(gl.Id) && hobEventGLIds.contains(gl.Id)){
		            if(applicableGLPerEvent.get(evt.Id) == null){
		                applicableGLPerEvent.put(evt.Id, new GLAccount__c[]{});
		            }
		            applicableGLPerEvent.get(evt.Id).add(gl);
		        }
		    }
	     } else if(evt.Office__r.Division__c == DIVISON_US || evt.Office__r.Division__C == DIVISION_CANADA){
	           for(GLAccount__c gl : listOfGlAccount){
		        if(rentalEventGLIds.contains(gl.Id) && naEventGLIds.contains(gl.Id)){
		            if(applicableGLPerEvent.get(evt.Id) == null){
		                applicableGLPerEvent.put(evt.Id, new GLAccount__c[]{});
		            }
		            applicableGLPerEvent.get(evt.Id).add(gl);
		        }
		    }
		}
    }
    
    private static void setupPromotedShowFestival(Event__c evt, list<GLAccount__c> listOfGlAccount, 
    	Map<Id, GLAccount__c[]> applicableGLPerEvent, set<id> promotedEventGLIds, set<id> hobEventGLIds,
    	set<Id> naEventGLIds) {
    		
    	if(evt.Office__r.Division__c == DIVISION_TC){
        	for(GLAccount__c gl : listOfGlAccount){
        		if(promotedEventGLIds.contains(gl.Id) && hobEventGLIds.contains(gl.Id)){
        			if(applicableGLPerEvent.get(evt.Id) == null){
						applicableGLPerEvent.put(evt.Id, new GLAccount__c[]{});
    				}
					applicableGLPerEvent.get(evt.Id).add(gl);
				}
       		}
		} else if(evt.Office__r.Division__c == DIVISON_US || evt.Office__r.Division__C == DIVISION_CANADA){
			for(GLAccount__c gl : listOfGlAccount){
				if(promotedEventGLIds.contains(gl.Id) && naEventGLIds.contains(gl.Id)){
					if(applicableGLPerEvent.get(evt.Id) == null){
 						applicableGLPerEvent.put(evt.Id, new GLAccount__c[]{});
					}
					applicableGLPerEvent.get(evt.Id).add(gl);
				}
			}
		}
    }
    
    
    
    private static void setupGospelBrunch(Event__c evt, list<GLAccount__c> listOfGlAccount, 
    	Map<Id, GLAccount__c[]> applicableGLPerEvent, set<id> gospelBrunchEventGLIds, set<id> hobEventGLIds,
    	set<Id> naEventGLIds) {
    		
        if(evt.Office__r.Division__c == DIVISION_TC){
		    for(GLAccount__c gl : listOfGlAccount){
		        if(gospelBrunchEventGLIds.contains(gl.Id) && hobEventGLIds.contains(gl.Id)){
		            if(applicableGLPerEvent.get(evt.Id) == null){
		                applicableGLPerEvent.put(evt.Id, new GLAccount__c[]{});
		            }
		            applicableGLPerEvent.get(evt.Id).add(gl);
		        }
		    }
	     } else if(evt.Office__r.Division__c == DIVISON_US || evt.Office__r.Division__C == DIVISION_CANADA){
	           for(GLAccount__c gl : listOfGlAccount){
		        if(gospelBrunchEventGLIds.contains(gl.Id) && naEventGLIds.contains(gl.Id)){
		            if(applicableGLPerEvent.get(evt.Id) == null){
		                applicableGLPerEvent.put(evt.Id, new GLAccount__c[]{});
		            }
		            applicableGLPerEvent.get(evt.Id).add(gl);
		        }
		    }
		 }
    }
    
    
    private static Map<String, ID> pGLMapToLERTId = null;
	public static Map<String, ID> GLMapToLERTId {
		get {
			if ( pGLMapToLERTId == null) {
				pGLMapToLERTId = new Map<String, ID>();
		        pGLMapToLERTId.put(TYPE_ANCILLARY, LNE_RT.RT_ANCILLARY_ID);
		        pGLMapToLERTId.put(TYPE_COGS, LNE_RT.RT_COGS_ID);
		        pGLMapToLERTId.put(TYPE_TICKETREVENUE, LNE_RT.RT_TICKETREVENUE_ID);
		        pGLMapToLERTId.put(TYPE_EXPENSES, LNE_RT.RT_EXPENSES_ID);
		        pGLMapToLERTId.put(TYPE_COPROMOTE_EXPENSE, LNE_RT.RT_COPROMOTE_EXPENSE_ID);
                pGLMapToLERTId.put(TYPE_COPROMOTE_REVENUE, LNE_RT.RT_COPROMOTE_REVENUE_ID);
                pGLMapToLERTId.put(TYPE_OTHER , LNE_RT.RT_OTHER_ID);
                pGLMapToLERTId.put(TYPE_TALENT_FEES , LNE_RT.RT_TALENT_FEES_ID);
                pGLMapToLERTId.put(TYPE_CONTRA, LNE_RT.RT_CONTRA_ID);
			}
			return pGLMapToLERTId;
		}
	}
    
}