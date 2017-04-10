/** 
 *	Trigger logic to handle when the primary agency is changed on account.
 *  Creates a new ArtistAgency record if necessary, otherwise updates Agent__c on existing
 *  ArtistAgency__c 
 *
 *  Assumes that the trigger will be run after update
 *	@author Dominic Aveyard 
 **/
public class LNE_ArtistAgencyAssign_T {
	
	static final String RT_Artist = 'Account.Artist';

    /** 
     *  When an account is updated or created
     *  When assigning the Primary Agency,
     *  an agency relationship record related to the Artist
     *  and Agency needs to be automatically established
     *  if it doesn't exist already and including the Agent selected
     **/
	public static ArtistAgency__c[] execute( Account[] newList, Map<Id,Account> oldMap ){
        ArtistAgency__c[] results = new ArtistAgency__c[]{};

        if ( newList == null ){
            return( results );
        }
        
        //-- find the record types to make sure only artists are dealt with.
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{ RT_Artist }
		);
		Id RT_ARTIST_ID = recordTypeMap.get( RT_Artist );
		
        
        //-- find the list of artists that have changed their primary agency.
        //-- all other accounts that are in the list we ignore
        Account oldAccount = null;
        Account[] validArtists = new Account[]{};
        
        Account blankAccount = new Account();
        
        Id[] agenciesUsed = new Id[]{};
        
        String key = null;
        
        Map<String,ArtistAgency__c> artistAgencyMap= new Map<String,ArtistAgency__c>();
        Boolean isValid = false;
        
		for( Account newAccount : newList ){
		    //System.debug( 'LNE_ArtistAgencyAssign_T.recordType: ' + newAccount.recordTypeId );
			isValid = false;
			oldAccount = null;	    
			
            if(  oldMap != NULL && newAccount != NULL && newAccount.RecordTypeId == RT_ARTIST_ID ){	
				if(oldMap.containsKey( newAccount.Id )){
				    //System.debug( 'LNE_ArtistAgencyAssign_T isUpdate: ' + newAccount );
					oldAccount = oldMap.get( newAccount.Id );
					if( newAccount.PrimaryAgency__c != null &&
					    newAccount.PrimaryAgency__c != oldAccount.PrimaryAgency__c
					){
						//-- primary agency was changed	
						isValid = true;
					}
                }
			} else if ( newAccount != NULL && newAccount.RecordTypeId == RT_ARTIST_ID ) {
                //System.debug( 'LNE_ArtistAgencyAssign_T isInsert: ' + newAccount );
                if( newAccount.PrimaryAgency__c != null ){
                    //-- primary agency was changed
                    isValid = true;
                }
			}
            
            if( isValid ){
                //-- primary agency defined
                validArtists.add( newAccount );
                agenciesUsed.add( newAccount.PrimaryAgency__c );
                
                key = createArtistAgencyKey( newAccount );
                artistAgencyMap.put( key, null );
            }
		}
        
        //-- if there aren't any accounts that fit that criteria, then we stop
        if( validArtists.size() < 1 ){
        	return( results );
        }
        
        //-- find if there are any artistAgencies already exist
        
        for( ArtistAgency__c possibleAgency : [
        	SELECT id, name, Artist__c, Agency__c, Agent__c
        	FROM ArtistAgency__c
        	where Artist__c in :validArtists
        		and Agency__c in :agenciesUsed
        ]){
        	key = '' + possibleAgency.Artist__c + '|'
						+ possibleAgency.Agency__c;
			
			if( artistAgencyMap.containsKey( key ) ){
				artistAgencyMap.put( key, possibleAgency );
			}
        }
        
        //-- valid artists are now only the ones that do not have an artistAgency already defined
        //validArtists = artistAgencyMap.values();
        
        //-- for each of the valid artists
        //--    if there is no valid artist agency for that artist
        //--        then we create a new artist agency
        //--            with the artist, and the agency and the agent.
        //--       and we add that new artistAgency to a bucket to be created
        //--    end
        //-- end
        ArtistAgency__c newArtistAgency = null;
        for( Account validArtist : validArtists ){
        	key = createArtistAgencyKey( validArtist );
        	
        	//-- all artists were added to the map, but not all were defined
        	if( artistAgencyMap.get( key ) != null ){
        		newArtistAgency = artistAgencyMap.get( key );
        		
        		newArtistAgency.Agent__c = validArtist.Agent__c;
        		results.add( newArtistAgency );
        		
        	} else {
        		newArtistAgency = new ArtistAgency__c(
        			Artist__c = validArtist.Id,
        			Agency__c = validArtist.PrimaryAgency__c,
        			Agent__c = validArtist.Agent__c
        		);
        		
        		results.add( newArtistAgency );
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
	
	/** Creates a concatenated key representing an artist/agency **/
	public static String createArtistAgencyKey( Account a ){
		return( '' + a.Id + '|'
			+ a.PrimaryAgency__c
		);
	}
	
	/** Creates a concatenated key representing an artist/agency **/
	public static String createArtistAgencyKey( ArtistAgency__c aa ){
		return( '' + aa.Artist__c + '|'
			+ aa.Agency__c
		);
	}
}