/** 
 *	Trigger logic to check for existing ArtistRetroStepUpDetail__c and validates the Start Range
 *	<p>Assumes that the trigger will be run on a before update or before insert</p>
 *	@author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 *	@author Dominic Aveyard <daveyard@salesforce.com>
 **/
public class LNE_RetroStepUpStartRangeValidation_T {
	
	//-- floating point comparison thingie
	public static final Decimal EPSILON = 1;
	
	//-- map of all updated Artist Retro Step Up Detail Records by the Deal they belong to.
	public static Map<Id, List<SortableArtistStepUpRetroDetail>> artistDetailsByDeal = new Map<Id, List<SortableArtistStepUpRetroDetail>>();
	public static Set<id> artistDetailsFoundIds = new Set<Id>();
	
	/**
	*  Validates the Start Range value for a retro once it is saved to not be less than the End Range of other records with a lesser Start Range
	*  @param newList ArtistRetroStepUpDetail__c[]
	*  @param oldMap Map<Id,ArtistRetroStepUpDetail__c>
	*  @return ArtistRetroStepUpDetail__c[] - list of ledger entries updated.
	**/
	public static ArtistRetroStepUpDetail__c[] execute( ArtistRetroStepUpDetail__c[] newList, Map<Id,ArtistRetroStepUpDetail__c> oldMap ){
		ArtistRetroStepUpDetail__c[] results = new ArtistRetroStepUpDetail__c[]{};
	   
		if ( newList == null ){
			return( results );
		}
		
		//-- set of all the deal ids.
		Set<Id> dealsIds = new Set<Id>();
		
		//-- artist details for a given deal.
		ArtistRetroStepUpDetail__c[] dealArtistDetails = null;
		ArtistRetroStepUpDetail__c currentArtistDetail = null;
		//-- list of artist detail records that are sortable
		SortableArtistStepUpRetroDetail[] sortableArtistDetails = new SortableArtistStepUpRetroDetail[]{};
		
		//-- previous endpoint for the given deal.
		Decimal previousStart = 0, previousEnd = 0;
		
		//-- whether the deal is spoiled by a record overlapping with another
		Boolean doesDealStartAtZero = false;
		
		for(ArtistRetroStepUpDetail__c artistDetail : newList){
			if (oldMap != null && oldMap.get(artistDetail.Id) != null && oldMap.get(artistDetail.Id).StartingRange__c == 0 && artistDetail.StartingRange__c != 0) {
				artistDetail.StartingRange__c.addError('The Starting Artist Retro/Step Up detail range should remain at 0.');
			}

			if (artistDetailsByDeal.get(artistDetail.Deal__c) == null) {
				artistDetailsByDeal.put(artistDetail.Deal__c, new SortableArtistStepUpRetroDetail[]{} );
			}

			artistDetailsByDeal.get(artistDetail.Deal__c).add( new SortableArtistStepUpRetroDetail(artistDetail));
			artistDetailsFoundIds.add( artistDetail.Id );
		}
		
		dealsIds = artistDetailsByDeal.keySet();
		
		//-- @INVARIANT - dealIds now are the list of all deals referenced
		//-- @INVARIANT - artistDetailsByDeal - array of ArtistRetroStepUpdetails from new indexed by the deal they belong to.
		//-- @INVARIANT - artistDetailsByDeal - contains an id for every deal we need.
		//-- @INVARIANT - artistDetailsFoundIds includes all artistDetail.ids for the new records - but NOT for all artistDetail records for that deal
		
		Deal__c[] artistDetailDeals = new Deal__c[]{};
		for (Deal__c deal : [
				SELECT Id, RetroStepUpStartAtZero__c,
					(SELECT Id, Deal__c, StartingRange__c,EndingRange__c FROM Artist_Retro_Step_Up_Details__r)
				FROM Deal__c
				WHERE Id IN :dealsIds
		]) {
		    artistDetailDeals.add( deal );
		    
		    for( ArtistRetroStepUpDetail__c artistDetail : deal.Artist_Retro_Step_Up_Details__r ){
		        if( !artistDetailsFoundIds.contains( artistDetail.Id )){
		            artistDetailsByDeal.get(artistDetail.Deal__c).add( new SortableArtistStepUpRetroDetail(artistDetail));
		        }
		    }
		}
		
		//-- @INVARIANT - artistDetailDeals includes the list of all deals referenced.
		//-- @INVARIANT - artistDetailsFoundIds includes all artistDetail.ids for the new records - but NOT for all artistDetail records for that deal
		
		for( Deal__c deal: artistDetailDeals ){
			deal.RetroStepUpStartAtZero__c = false;
			
			System.assert( artistDetailsByDeal.containsKey( deal.id ), 'the deal for all artist details must be found' );
			sortableArtistDetails = artistDetailsByDeal.get( deal.id );
			
			sortableArtistDetails.sort();
			
			System.debug( 'reviewing deal:' + deal.id );
			
			//-- verify whether there are overlapping records.
			System.debug( 'sortedArtistDetails:' + sortableArtistDetails );
			
			previousStart = previousEnd = -1;
			doesDealStartAtZero = false;
			
			for( SortableArtistStepUpRetroDetail sortableArtistDetail : sortableArtistDetails ){
			    currentArtistDetail = sortableArtistDetail.record;
			    
			    if( currentArtistDetail.StartingRange__c < 0 ||
			        currentArtistDetail.EndingRange__c < 0
			    ){
			        System.debug( 'artistDetail[' + currentArtistDetail.Id + '] cannot have a negative range[' + currentArtistDetail.StartingRange__c + ':' + currentArtistDetail.EndingRange__c + ']' );
			        currentArtistDetail.IsRangeInvalid__c = true;
			    }
			    
			    //-- don't use equals, use epsilon comparison
			    if( currentArtistDetail.StartingRange__c > (0 - EPSILON) &&
			        currentArtistDetail.StartingRange__c < (0 + EPSILON)
			    ){
			        System.debug( 'artistDetail[' + currentArtistDetail.Id + '] starts at zero[' + currentArtistDetail.StartingRange__c + ']' );
			        doesDealStartAtZero = true;
			    }
			    
			    if( currentArtistDetail.StartingRange__c <= previousEnd ){
			        System.debug( 'artistDetail[' + currentArtistDetail.Id + '] overlaps previous end[' + currentArtistDetail.EndingRange__c + ':' + previousEnd + ']' );
			        currentArtistDetail.StartingRangeLessOnOther__c = true;
			    }
			    
			    previousStart = currentArtistDetail.StartingRange__c;
			    previousEnd = currentArtistDetail.EndingRange__c;
			}
			
			//-- mark all records whether none of them start at zero.
			System.debug( 'doesDealStartAtZero[' + doesDealStartAtZero + ']' );
		    for( SortableArtistStepUpRetroDetail sortableArtistDetail : sortableArtistDetails ){
			    currentArtistDetail = sortableArtistDetail.record;
		        System.debug( 'checking[' + currentArtistDetail.id + ']:' + doesDealStartAtZero );
			    currentArtistDetail.DoesDealRangeStartAtZero__c = doesDealStartAtZero;
			    //currentArtistDetail.addError('At least one of the Artist Retro/Step Up detail records for this Deal must have a starting range of zero.');
			}
		}
		
		return ( results );
	}
	
	/**
	 *	Sortable inner class to allow sorting ArtistDetail records.
	 **/
	public class SortableArtistStepUpRetroDetail implements Comparable {
		ArtistRetroStepUpDetail__c record;
		
		public SortableArtistStepUpRetroDetail( ArtistRetroStepUpDetail__c record ){
			this.record = record;
		}
		
		public Integer compareTo( Object compareTo ){
			System.assert( compareTo instanceOf SortableArtistStepUpRetroDetail, 'This is an inner class, and should never be compared against anything other than SortableArtistDetail records' );
			SortableArtistStepUpRetroDetail target = (SortableArtistStepUpRetroDetail)compareTo;
			
			return( Integer.valueOf( this.record.StartingRange__c - target.record.StartingRange__c ) );
		}
	}
}