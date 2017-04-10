/** 
 *	Trigger logic to handle when the primary office is changed on a venue account.
 *  Creates a new venueAgency record if necessary, otherwise updates Agent__c on existing
 *  VenueOffice__c 
 *
 *  Assumes that the trigger will be run after update
 *	@author Dominic Aveyard 
 **/
public class LNE_VenueOfficeAssign_T {
	
	static final String RT_Venue = 'Account.Venue';

    /** 
     *  When an account is updated or created
     *  When assigning the Primary Agency,
     *  an agency relationship record related to the venue
     *  and Agency needs to be automatically established
     *  if it doesn't exist already and including the Agent selected
     **/
	public static VenueOffice__c[] execute( Account[] newList, Map<Id,Account> oldMap ){
        VenueOffice__c[] results = new VenueOffice__c[]{};

        if ( newList == null ){
            return( results );
        }
        
        //-- find the record types to make sure only venues are dealt with.
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{ RT_Venue }
		);
		Id RT_Venue_ID = recordTypeMap.get( RT_Venue );
		
        
        //-- find the list of venues that have changed their primary office.
        //-- all other accounts that are in the list we ignore
        Account oldAccount = null;
        Account[] validVenues = new Account[]{};
        
        Account blankAccount = new Account();
        
        Id[] officesUsed = new Id[]{};
        
        String key = null;
        
        Map<String,VenueOffice__c> venueOfficeMap= new Map<String,VenueOffice__c>();
        Boolean isValid = false;
        
		for( Account newAccount : newList ){
		    //System.debug( 'LNE_VenueOfficeAssign_T.recordType: ' + newAccount.recordTypeId );
			isValid = false;
			oldAccount = null;
            
			if(  oldMap != NULL && newAccount != NULL && newAccount.RecordTypeId == RT_Venue_ID ){				
				if( oldMap.containsKey( newAccount.Id )){
				    //System.debug( 'LNE_VenueOfficeAssign_T isUpdate: ' + newAccount );
					oldAccount = oldMap.get( newAccount.Id );
					if( newAccount.PrimaryOffice__c != null &&
					    newAccount.PrimaryOffice__c != oldAccount.PrimaryOffice__c
					){
						//-- primary office was changed	
						isValid = true;
					}
				} 
            } else if (newAccount != NULL && newAccount.RecordTypeId == RT_Venue_ID) {	
                //System.debug( 'LNE_VenueOfficeAssign_T isInsert: ' + newAccount );
                if( newAccount.PrimaryOffice__c != null ){
                    //-- primary agency was changed
                    isValid = true;
                }
			}
				
            if( isValid ){
				//-- primary office defined
				validVenues.add( newAccount );
				officesUsed.add( newAccount.PrimaryOffice__c );
					
				key = createVenueOfficeKey( newAccount );
				venueOfficeMap.put( key, null );
			}
        }
        
        //-- if there aren't any accounts that fit that criteria, then we stop
        if( validVenues.size() < 1 ){
        	return( results );
        }
        
        //-- find if there are any VenueOffices already exist
        
        for( VenueOffice__c possibleOffice : [
        	SELECT id, name, Venue__c, Office__c
        	FROM VenueOffice__c
        	where Venue__c in :validVenues
        		and Office__c in :officesUsed
        ]){
        	key = '' + possibleOffice.Venue__c + '|'
						+ possibleOffice.Office__c;
			
			if( venueOfficeMap.containsKey( key ) ){
				venueOfficeMap.put( key, possibleOffice );
			}
        }
        

        VenueOffice__c newVenueOffice = null;
        for( Account validVenue : validVenues ){
        	key = createVenueOfficeKey( validVenue );
        	
        	//-- all venues were added to the map, but not all were defined
        	if( venueOfficeMap.get( key ) != null ){
        		newVenueOffice = venueOfficeMap.get( key );
        		
        		newVenueOffice.Office__c = validVenue.PrimaryOffice__c;
        		results.add( newVenueOffice );
        		
        	} else {
        		newVenueOffice = new VenueOffice__c(
        			Venue__c = validVenue.Id,
        			Office__c = validVenue.PrimaryOffice__c
                );
        		
        		results.add( newVenueOffice );
        	}
        }
        
        //-- if there are any accountAccountAgencies to be created
        //--  create them
        
        if( results.size() > 0 ){
        	//upsert results;
        	LNE_SystemModeLogic.upsertRecords( results );
        }

        return( results );
	}
	
	/** Creates a concatenated key representing an venue/agency **/
	public static String createVenueOfficeKey( Account a ){
		return( '' + a.Id + '|'
			+ a.PrimaryOffice__c
		);
	}
	
	/** Creates a concatenated key representing an venue/agency **/
	public static String createVenueOfficeKey( VenueOffice__c vo ){
		return( '' + vo.Venue__c + '|'
			+ vo.Office__c
		);
	}
}