/**
 *  Class to manage various bypasses within logic (financial calculators, process builder flows,etc).
 *  @author Paul Roth <proth@salesforce.com>
 **/
public without sharing class LNE_GeneralSettingsUtil {
	
	/** error if we could not find a user override **/
	public static final String ERROR_NO_USER_OVERRIDE_FOUND = 'ERROR: No user override found';
	/** error if we could not remove any user override found **/
	public static final String ERROR_COULD_NOT_REMOVE_USER_OVERRIDE = 'ERROR: Could not remove the user override:';
	
	/**
	 *  Specifies which permissions the current user should be able to bypass
	 *  @param bypassProcessBuilder (Boolean)
	 *  @param bypassAutomation (Boolean) - bypass all triggers and process builder functionality (including financial calculator)
	 *  @param bypassFinancialCalculator (Boolean) - bypass the financial calculator
	 *  @return Boolean - success (true) or failure (false)
	 **/
	public static Boolean setLocalBypassSettings( Boolean bypassAutomation, Boolean bypassProcessBuilder, Boolean bypassFinancialCalculator ){
		return setSettings(bypassAutomation, bypassProcessBuilder, bypassFinancialCalculator, false);
	}
	
	public static Boolean setLocalBypassSettings( Boolean bypassAutomation, Boolean bypassProcessBuilder, Boolean bypassFinancialCalculator, Boolean forceFlagFlowsToRun){
		return setSettings(bypassAutomation, bypassProcessBuilder, bypassFinancialCalculator, forceFlagFlowsToRun);
	}
	
	private static Boolean setSettings(Boolean bypassAutomation, Boolean bypassProcessBuilder, Boolean bypassFinancialCalculator, Boolean forceFlagFlowsToRun) {
		GeneralSettings__c updatedRecord = GeneralSettings__c.getInstance();
		Id currentUserId = UserInfo.getuserId();
		
		//-- @TODO: investigate whether we want to actually make the assumption that you should not already have one in your name.
		//-- or whether this should be cached.
		
		if( updatedRecord.SetupOwnerId != currentUserId ){
			updatedRecord = updatedRecord.clone( false, false, false, false );
		}

		updatedRecord.BypassAutomation__c = bypassAutomation;
		updatedRecord.BypassPBFlow__c = bypassProcessBuilder;
		updatedRecord.BypassAutomationFinancialCalculator__c = bypassFinancialCalculator;
		updatedRecord.ForceFlagLogic__c = forceFlagFlowsToRun; 
		
		updatedRecord.SetupOwnerId = UserInfo.getUserId();
		
		//try {
			upsert updatedRecord;
		//} catch( Exception err ){
		//	System.debug( 'exception occurred while trying to set local bypass settings' );
		//}

		return( true );
	}
	
	/**
	 *  Attempts to remove the current user's general setting override.
	 *  @return Boolean - whether successful (true) or not (false)
	 **/
	public static Boolean removeCurrentUserOverride(){
		GeneralSettings__c recordToDelete = GeneralSettings__c.getInstance();
		Id currentUserId = UserInfo.getuserId();
		
		//-- @TODO: investigate whether we want to actually make the assumption that you should not already have one in your name.
		//-- or whether this should be cached.
		
		if( recordToDelete.SetupOwnerId != currentUserId ){
			System.debug( ERROR_NO_USER_OVERRIDE_FOUND );
			return( false );
		}
		
		//try {

		//-- If you try to delete a setting without an Id
		//-- e.g. if it was deleted before, you'll get an error
		if (recordToDelete.Id != null) {
			delete recordToDelete;
		}
		//} catch( Exception err ){
		//	System.debug( ERROR_COULD_NOT_REMOVE_USER_OVERRIDE + err.getMessage() );
		//  return( false );
		//}

		return( true );
	}
	
	//-- @TODO: investigate whether we want to make a more broad one, for a specific user id
	//-- but it would need to be restricted perhaps by the current user's profile / general settings.
}