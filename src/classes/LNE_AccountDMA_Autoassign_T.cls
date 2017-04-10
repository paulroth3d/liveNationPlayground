/** 
 *	Trigger logic to automatically assign the DMA.
 *  <p>Assumes that the trigger will be run on a before update</p>
 *  <p>Also assumes that the cities and the states are also in uppercase</p>
 *	@author Paul Roth <proth@salesforce.com>
 *  @group DMALogic
 **/
public class LNE_AccountDMA_Autoassign_T {
	
	public static final String RT_VENUE = 'Account.Venue';
	
	/**
	 *  Performs the auto assignment.
	 *  @param newList Account[]
	 *  @param oldMap Map<Id,Account>
	 *  @return Account[] - list of accounts updated.
	**/
	public static Account[] execute( Account[] newList, Map<Id,Account> oldMap ){
		Account[] results = new Account[]{};
		
		if( newList == null || newList.size() < 1 ){
			return( results );
		}
		
		Account oldAccount = null;
		Account newAccount = null;
		
		String COMBINED_KEY_DELIMITER = DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;
		
		//-- determine the record types.
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{ RT_VENUE }
		);
		Id RT_VENUE_ID = recordTypeMap.get( RT_VENUE );
		
		//-- determine the list of accounts that have changed
		String[] usedPostalCodes = new String[]{};
		String[] usedCityStates = new String[]{};
		
		ChangedAccount[] changedAccounts = new ChangedAccount[]{};
		ChangedAccount objChange = null;
		
		Map<String,String> postalCodeMap = null;
		Map<String,String> cityStateMap = null;
		
		if( oldMap == null ){
		    oldMap = new Map<Id,Account>();
		}
		
		Boolean isValid = false;
		Account BLANK_ACCOUNT = new Account();
		String billingCityKey = null;
		
		//System.debug( 'LNE_AccountDMA_Autoassign_T' );
		
		//-- loop through all accounts to only those that qualify
		for( Account newAccount1 : newList ){
		    isValid = false;
			oldAccount = null;
            
            if( RT_VENUE_ID == newAccount1.RecordTypeId ){
                //System.debug( 'is an venue' );
                if( oldMap.containsKey( newAccount1.Id )){
                    //System.debug( 'old venue' );
    				oldAccount = oldMap.get( newAccount1.Id );
    				objChange = new ChangedAccount( oldAccount, newAccount1 );
    				
    				//-- if the record type is correct and the fields have changed.
    				//-- assumes the billing address is required
    				if(
    					objChange.notEqualsStr( 'BillingPostalCode',false ) ||
    					objChange.notEqualsStr( 'BillingStateCode',false ) ||
    					objChange.notEqualsStr( 'BillingCity',false )
    				){
    					isValid = true;
    				} else {
    					System.debug( 'is valid venue but no postal change' );
    				}
    				
    			} else {
                    //System.debug( 'new venue' );
    			    oldAccount = BLANK_ACCOUNT;
    			    objChange = new ChangedAccount( oldAccount, newAccount1 );
    			    
    			    isValid = true;
    			}
    			
                if( isValid ){
                    //System.debug( 'postal code changed' );
    				
    				//-- clear the DMA
    				newAccount1.DMA__c = null;
    				
    				//-- determine the keys
    				objChange.postalKey = newAccount1.BillingPostalCode;
    				
    				if( newAccount1.BillingCity == null ){
    				    billingCityKey = '';
    				} else {
    				    billingCityKey = newAccount1.BillingCity.toUpperCase();
    				}
    				
    				objChange.cityStateKey = billingCityKey +
    					COMBINED_KEY_DELIMITER +
    					newAccount1.BillingStateCode;
    				
    				//-- determine which postalcodes / cityStates were used
    				usedPostalCodes.add( objChange.postalKey );
    				
    				//-- add to the list of things that changed
    				changedAccounts.add( objChange );
    			}
            }
		}
		
		//System.debug( 'changedAccounts:' + changedAccounts.size() );
		
		//-- short circuit if nothing is there.
		if( changedAccounts.size() < 1 ){
		    return( results );
		}
		system.debug('+++ changedAccounts' + changedAccounts);
		//-- Update the DMA for all postal codes
		postalCodeMap = new Map<String,String>();
		system.debug('+++ usedPostalCodes = ' + usedPostalCodes);
		//-- find the DMAs by Zip Code (should catch the majority of the records
		for( DMA__c matchingDMA : [
			select Id, DMA__c, PostalCode__c, City__c, State__c, CityStateConcatenatedKey__c
			from DMA__c
			where PostalCode__c in :usedPostalCodes
			order by createdDate desc
		]){
			postalCodeMap.put( matchingDMA.PostalCode__c, matchingDMA.DMA__c );
		}
		
		//System.debug( 'postalCodeMap:' ); System.debug( 'postalCodeMap' );
		
		for( ChangedAccount changedAcc : changedAccounts ){
			newAccount = changedAcc.getNewAccount();
			//System.debug( 'checking postal code DMA[' + changedAcc.postalKey + ']' );
			
			if( changedAcc.postalKey != null && postalCodeMap.containsKey( changedAcc.postalKey ) ){
				newAccount.DMA__c = postalCodeMap.get( changedAcc.postalKey );
				results.add( newAccount );
			} else {
				//-- find by city
				usedCityStates.add( objChange.cityStateKey );
			}
		}
		
		//-- separate out find by city because it is much more expensive and there can be 100s of results...
		//-- NOTE: CITY/STATE IS ASSUMED UPPER CASE IN DMAs
		if( usedCityStates.size() > 0 ){
		    //System.debug( 'usedCityStates:' ); System.debug( usedCityStates );
		
			cityStateMap = new Map<String,String>();
			system.debug('+++ usedCityStates = ' + usedCityStates);
			for( DMA__c matchingDMA : [
				select Id, DMA__c, PostalCode__c, City__c, State__c, CityStateConcatenatedKey__c
				from DMA__c
				where CityStateConcatenatedKey__c in :usedCityStates
				order by createdDate desc
			]){
				cityStateMap.put( matchingDMA.CityStateConcatenatedKey__c, matchingDMA.DMA__c );
			}
			
			//System.debug( 'cityStateMap' ); System.debug( cityStateMap );
			
			for( ChangedAccount changedAcc : changedAccounts ){
				newAccount = changedAcc.getNewAccount();
				//System.debug( 'assigning DMA[' + changedAcc.postalKey + '][' + changedAcc.cityStateKey + ']' );
				
				if( changedAcc.cityStateKey != null && cityStateMap.containsKey( changedAcc.cityStateKey ) ){
					newAccount.DMA__c = cityStateMap.get( changedAcc.cityStateKey );
					results.add( newAccount );
				}
			}
		}
		
		return( results );
	}
	
	/**
	 *  Internal class to represent the changes from the object.
	**/
	class ChangedAccount extends LNE_SObjectChange {
		
		public String postalKey;
		public String cityStateKey;
		
		ChangedAccount( Account oldObject, Account newObject ){
		    super( oldObject, newObject );
		}
		
		Account getNewAccount(){
			return( (Account)this.newObject );
		}
		
		Account getOldAccount(){
			return( (Account)this.oldObject );
		}
	}
}