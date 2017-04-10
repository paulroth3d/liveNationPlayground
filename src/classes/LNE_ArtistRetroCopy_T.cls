/**
 *  Copys formula fields to non formula fields to use in rollup summaries on the Deal__c object.
 *  @author John Casimiro <jcasimiro@salesforce.com>
 **/
 
public class LNE_ArtistRetroCopy_T {
    public static ArtistRetroStepUpDetail__c[] execute( ArtistRetroStepUpDetail__c[] newList){
    	ArtistRetroStepUpDetail__c[] results = new ArtistRetroStepUpDetail__c[]{};
   
		if ( newList == null ){
			return( results );
		}
		
		for (ArtistRetroStepUpDetail__c ar : newList){
		    ar.BackendPotentialNonFormula__c = ar.BackendPotential__c;
		    ar.ProjectedBackendNonFormula__c = ar.ProjectedBackend__c;
		    ar.SettlementBackendNonFormula__c = ar.SettlementBackend__c;
		    results.add(ar);
		}
	    
	    return results;
    }
}