/**
 *  Class that generates objects for use in UnitTests.
 *  @author Paul Roth <proth@salesforce.com>
 *  
 *  <p>Please note that there are three methods of generating test objects:
 *  * Option A - Common parameters are passed to generate the object:
 *  		ex: LNE_TestObjectFactory.createAccount( 'AccountName' )
 *  * Option B - Parameters are passed as a multi-map and are assigned as needed.
 *  		ex: LNE_TestObjectFactory( new Map<String,Object>{
 *  			'Name': 'AccountName'
 *  		} );
 *  * Object C - Classes specific to building a specific object, so methods are chained.
 *  		ex: new lne_AccountBuilder( 'AccountName' )
 *  			.withAddress( '1000 Illinois St', 'Chicago', 'IL', '60108' )
 *  			.withShipping( '999 Auroa Rd.', 'Aurora', 'IL', '60000' )
 *  			.build();
 *  This class will employ Options A and B. Option C will be held separately.
**/
public with sharing class LNE_TestObjectFactory {
	static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
	    new String[]{ 
	        'Account.CoPromoter', 
	        'Account.Artist', 
	        'Account.Office', 
	        'Account.Venue',
	        'Account.Local',
	        'LedgerEntry__c.Ancillary', 
	        'LedgerEntry__c.TicketRevenue', 
	        'LedgerEntry__c.Expenses' ,
	        'Deal__c.CoPromoter'
	       }
    );

    static Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );
    static Id RT_ACCOUNT_OFFICE_ID = recordTypeMap.get( 'Account.Office' );
    static Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
    static Id RT_ACCOUNT_COPROMOTER_ID = recordTypeMap.get( 'Account.CoPromoter' );
    static Id RT_ACCOUNT_LOCAL_ID = recordTypeMap.get( 'Account.Local' );
    static Id RT_TICKET_REVENUE_ID = recordTypeMap.get( 'LedgerEntry__c.TicketRevenue' );
    static Id RT_LEDGERENTRY_EXPENSES_ID = recordTypeMap.get( 'LedgerEntry__c.Expenses' );
    static Id RT_LEDGERENTRY_ANCILLARY_ID = recordTypeMap.get( 'LedgerEntry__c.Ancillary' );
    static Id RT_DEAL_COPROMOTER_ID = recordTypeMap.get( 'Deal__c.CoPromoter' );
    
	//#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
	//-- Unique Maker Functionality
	/**
	 * Unique identifier used to ensure the uniqueness within a test
	 **/
	private static Integer UUID = 0;
	
	/**
	 * Determines a unique value within a testing session
	 * @return (Integer)
	 **/
	public static Integer getUUID(){ return( ++UUID); }
	
	/**
	 * Creates a unique string (such as a name)
	 * @param str (String)
	 * @return (String)
	 **/
	public static String makeUnique( String str ){
	    return( '' + str + getUUID() );
	}
	
	//#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
	//-- public constants
	
	//-- list of profiles we care about
	public static final String PROFILE_LNE_INTERNAL_USER = 'LNE Internal User';
	public static final String PROFILE_LNE_INTEGRATION = 'LNE Integration';
	public static final String PROFILE_MARKETING_USER = 'Marketing User';
	public static final String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';

	/** List of Profile IDs indexed by DeveloperName. **/
	public static Map<String,Id> PROFILE_IDS;
	
	//-- list of permission sets.
	public static final String PERM_SET_BOOKING = 'Booking';
	public static final String PERM_SET_FLASHING = 'Flashing';
	public static final String PERM_SET_MANAGE_WAVE_ANALYTICS = 'Manage_Wave_Analytics';
	public static final String PERM_SET_MARKETING = 'Marketing';
	public static final String PERM_SET_TOUR_MARKETING = 'Tour_Marketing';
	public static final String PERM_SET_MDM = 'Master_Data_Management';
	public static final String PERM_SET_OPERATIONS = 'Operations';
	public static final String PERM_SET_SETTLEMENT = 'Settlement';
	
	//-- venue hierarchy account types
	
	//-- gl account codes
	public static final String GL_TICKET_REVENUE = '40100';
	public static final String GL_LAWN = '40116';
	public static final String GL_ALCOHOLIC_REVENUE = '40205';
	public static final String GL_AUTO_RENTAL_EXPENSE = '50103';
	public static final String GL_CO_PROMOTE_EXPENSE = '50302';
	public static final String GL_BUILDING_CO_PROMOTE = '50339';
	public static final String GL_PARKING_REVENUE = '40216';
	public static final String GL_PARKING_CONTRA = '40900';
	
	//-- standard data set types
	public static final String STANDARD_DATA_OFFICE = 'office';
	public static final String STANDARD_DATA_VENUE = 'venue';
	
	public static final String STANDARD_DATA_COPRO_1 = 'copro1';
	public static final String STANDARD_DATA_COPRO_2 = 'copro2';
	public static final String STANDARD_DATA_ARTIST = 'artist';
	
	public static final String STANDARD_DATA_EVENT = 'event-';
	
	public static final String STANDARD_DATA_DEAL = 'deal';
	public static final String STANDARD_DATA_TALENT = 'talent';
	
	public static final String STANDARD_DATA_REVGL = 'revGL';
	public static final String STANDARD_DATA_LAWNGL = 'lawnGL';
	public static final String STANDARD_DATA_ANCILLARY = 'ancillary';
	public static final String STANDARD_DATA_EXPENSE = 'expense';
	public static final String STANDARD_DATA_COPROEXPENSE = 'coproexpense';
	public static final String STANDARD_DATA_BUILDINGCOPRO = 'buildingcopro';
	public static final String STANDARD_DATA_PARKING = 'parking';
	public static final String STANDARD_DATA_PARKINGCONTRA = 'parkingContra';
	
	//-- @TODO: use hierarchy level instead
	//public enum HierarchyLevel { GEOGRAPHY, DIVISION, BUSINESS_UNIT, OFFICE }
	
	public static final String ACCT_TYPE_GEOGRAPHY = 'Geography';
	public static final String ACCT_TYPE_DIVISION = 'Division';
	public static final String ACCT_TYPE_BUSINESS_UNIT = 'Business Unit';
	public static final String ACCT_TYPE_OFFICE = 'Office';
	public static final String ACCT_TYPE_STADIUM = 'Stadium';

	public static Map<String,Id> PERMISSION_SET_IDS;

	public static final String PUBLIC_GROUP_LNE_CONCERTS = 'LNE Concerts';

	public static Map<String, Id> PUBLIC_GROUP_IDS;
	
	public static final Map<String,Object> EMPTY_MAP;
	
	//-- standard setup records
	public static Id INTEGRATION_USER_ID;
	
	//-- static initializer
	static {
		EMPTY_MAP = new Map<String,Object>();
		
		String[] PROFILE_NAMES = new String[]{
			PROFILE_SYSTEM_ADMINISTRATOR,
			PROFILE_LNE_INTEGRATION,
			PROFILE_LNE_INTERNAL_USER,
			PROFILE_MARKETING_USER
		};
		
		PROFILE_IDS = new Map<String,Id>();
		for( Profile myProfile : [
			select id, name
			from Profile
			where name in :PROFILE_NAMES
		]){
			PROFILE_IDS.put(myProfile.name,myProfile.id);
		}
		
		String[] PERMISSION_SET_NAMES = new String[]{
			PERM_SET_BOOKING,
			PERM_SET_FLASHING,
			PERM_SET_MANAGE_WAVE_ANALYTICS,
			PERM_SET_MARKETING,
			PERM_SET_TOUR_MARKETING,
			PERM_SET_MDM,
			PERM_SET_OPERATIONS,
			PERM_SET_SETTLEMENT
		};
		
		PERMISSION_SET_IDS = new Map<String,Id>();

		for( PermissionSet permSet : [
			select id, name
			from PermissionSet
			where name in :PERMISSION_SET_NAMES
		]){
			PERMISSION_SET_IDS.put( permSet.name, permSet.id );
		}


		String[] PUBLIC_GROUP_NAMES = new String[]{
			PUBLIC_GROUP_LNE_CONCERTS
		};

		PUBLIC_GROUP_IDS = new Map<String,Id>();

		for( Group g : [
				select id, name
				from Group
				where name in :PUBLIC_GROUP_NAMES
		]){
			PUBLIC_GROUP_IDS.put( g.name, g.id );
		}
	}
	
	//#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
	//-- user creation methods
	/**
	 *  Creates a test user.
	 *  Specialized user creation should extend this method.
	 *  @param String alias
	 *  @param profileId Id
	 *  @return User
	**/
	public static User createUser( String alias, Id profileId ){
		String uniqueAlias = LNE_TestObjectFactory.makeUnique( alias );
		String email = '' + alias + '@lne.unit.test.com';
		return( new User(
			alias = alias,
			email = email,
			emailEncodingKey = 'UTF-8',
			firstName = 'JohnDoe',
			lastName = 'TEST_' + alias,
			localeSIDKey='en_US',
			profileId = profileId,
			languageLocaleKey='en_US',
			timezoneSIDKey='America/Los_Angeles',
			username=email
		));
	}
	
	/**
	 *  Creates a set of permission set assignments.
	 *  @param userId (Id)
	 *  @param permissionSets (Id[]) - set of ids of permissionSets to assign
	 *  @return PermissionSetAssignment[] - list of permissionSetAssignments
	**/
	public static PermissionSetAssignment[] createPermissionSetAssignments( Id userId, Id[] permissionSets ){
		PermissionSetAssignment[] results = new PermissionSetAssignment[]{};
		for( Id permissionSetId : permissionSets ){
			results.add( new PermissionSetAssignment(
				AssigneeId = userId, PermissionSetId = permissionSetId
			));
		}
		return( results );
	}

	/**
	 *  Creates a set of group members.
	 *  @param userId (Id)
	 *  @param groups (Id[]) - set of ids of groups to assign
	 *  @return GroupMember[] - list of GroupMembers
	**/
	public static GroupMember[] createGroupMemberships( Id userId, Id[] groups ){
		GroupMember[] results = new GroupMember[]{};
		for( Id groupId : groups ){
			results.add( new GroupMember(
					GroupId = groupId, UserOrGroupId = userId
			));
		}
		return( results );
	}

	public static User createAdminUser( String alias ){
		Id profileId = PROFILE_IDS.get( PROFILE_SYSTEM_ADMINISTRATOR );
		User adminUser = createUser( alias, profileId );
		insert adminUser;

		return( adminUser );
	}
	
	/**
	 *  Creates a test Promoter/Booker.
	 *  <p>So this can be used within test run-as statements</p>
	 *  <p>Please note: the user has ALREADY been created and does not need to be inserted in this case.</p>
	 *  @param String alias
	 *  @return User that is of type Internal User with the Booker Permission Set.
	**/
	public static User createPromoterUser( String alias ){
		Id profileId = PROFILE_IDS.get( PROFILE_LNE_INTERNAL_USER );
		User bookerUser = createUser( alias, profileId );
		insert bookerUser;
		
		Id[] permissionSetIds = new Id[]{
			PERMISSION_SET_IDS.get( PERM_SET_BOOKING )
		};
		PermissionSetAssignment[] permSets = LNE_TestObjectFactory.createPermissionSetAssignments(
			bookerUser.Id, permissionSetIds
		);
		insert permSets;
		
		return( bookerUser );
	}

	/**
	 *  Creates a test Marketer.
	 *  <p>So this can be used within test run-as statements</p>
	 *  @param String alias
	 *  @return User that is of type Internal User with the Marketing and TourMarketing Permission Sets.
	**/
	public static User createMarketingUser( String alias ){

		Id profileId = PROFILE_IDS.get( PROFILE_MARKETING_USER );
		User marketingUser = createUser( alias, profileId );

		insert marketingUser;

		Id[] permissionSetIds = new Id[]{
			PERMISSION_SET_IDS.get( PERM_SET_MARKETING ),
			PERMISSION_SET_IDS.get( PERM_SET_TOUR_MARKETING )
		};

		PermissionSetAssignment[] permSets = LNE_TestObjectFactory.createPermissionSetAssignments(
				marketingUser.Id, permissionSetIds
		);

		insert permSets;

		Id[] groupIds = new Id[]{
				PUBLIC_GROUP_IDS.get( PUBLIC_GROUP_LNE_CONCERTS )
		};

		GroupMember[] groupMembers = LNE_TestObjectFactory.createGroupMemberships(
			marketingUser.Id, groupIds
		);

		insert groupMembers;

		return( marketingUser );
	}

	
	/**
	 *  Creates an integration user
	 *  <p>This is required for certain custom settings / flows to work correctly.
	 *  Please see the prepStandardCustomSettings method</p>
	 *  @param String alias
	 *  @return User - type Integrations
	 **/
	public static User createIntegrationsUser( String alias ){
		Id profileId = PROFILE_IDS.get( PROFILE_LNE_INTEGRATION );
		User intUser = createUser( alias, profileId );
		insert intUser;
		
		return( intUser );
	}
	
	//#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
	//-- Custom Settings
	
	/**
	 *  Creates an environment id custom setting record
	 *  @param integrationUserId (Id)
	 *  @return EnvironmentIds__c custom setting record.
	 **/
	public static EnvironmentIds__c createEnvironmentIds( Id integrationUserId){
	    EnvironmentIds__c results = new EnvironmentIds__c(
	        IntegrationUser__c = integrationUserId,
	        CoPromoterDealRecordTypeId__c = RT_DEAL_COPROMOTER_ID,
	        LocalAdPlanRecordType__c = RT_ACCOUNT_LOCAL_ID
	    );
	    insert results;
	    
	    /****** The below must occur after setting the EnvironmentIds or a flow error will occur ******/
	    Account a = new Account();
	    a.status__c = 'Active';
	    a.RecordTypeId = RT_ACCOUNT_COPROMOTER_ID;
	    a.Name = 'Live Nation';
	    //a.OwnerId = integrationUserId;
	    insert a;
	    
	    results.LiveNationAccountID__c = a.Id;
	    update results;
	    
	    //-- GL Accounts
	    GLAccount__c[] commonGL_Accounts = new GLAccount__c[]{
	    	//-- LA National Touring Allocation GL CODE
	    	LNE_TestObjectFactory.createGLAccount('LA National Touring Allocation', '50360')
	    	//-- TODO: include all the other major GL Accounts
	    };
	    insert commonGL_Accounts;
	    
	    return( results );
	}
	
	/**
	 *  Creates the General Settings custom setting
	 *  @return GeneralSettings__c
	 **/
	public static GeneralSettings__c createGeneralSettings(){
	    //-- use defaults for now
	    //-- update with any other parameters needed later.
	    GeneralSettings__c results = new GeneralSettings__c(
			GlobalDataAdministrator__c = true,
			Grid_Lost_Focus_Poll_Interval__c = '500' //-- @TODO: this should NOT be a string...
		);
	    return( results );
	}
	
	/**
	 *  Creates the API Settings custom setting
	 *  @return API_Settings__c
	 **/
	public static API_Settings__c createAPISettings(){
	    //-- use defaults for now
	    //-- update with any other parameters needed later.
	    API_Settings__c results = new API_Settings__c(
			LiveNationAPI_Endpoint__c = 'http://api.livenation.com',
			LiveNation_API_Timeout__c = 6000,
			LiveNationAPI_Profiles__c = 'System Administrator'
		);
	    return( results );
	}

	/**
	 *  Creates the Data Generation Settings custom setting
	 *  @return DataGenerationSettings__c
	 **/
	public static DataGenerationSettings__c createDataSettings(){
	    //-- use defaults for now
	    //-- update with any other parameters needed later.
	    DataGenerationSettings__c results = new DataGenerationSettings__c(
			CombinedKeyDelimiter__c = '|',
			MultiPicklistDelimiter__c = ';'
		);
	    return( results );
	}

	/**
	 *  Creates the Rome FieldSet Settings custom setting
	 *  @return API_Settings__c
	 **/
	public static RomeFieldSetSettings__c createRomeFieldSetSettings(){
	    //-- use defaults for now
	    //-- update with any other parameters needed later.
	    RomeFieldSetSettings__c results = new RomeFieldSetSettings__c(
			ArtistOfferPrimaryEarnings__c = 'ArtistOfferPrimaryEarnings', 
			ArtistOfferPrimarySummary__c = 'ArtistOfferPrimarySummary', 
			ArtistOfferPrimaryTopLeft__c = 'ArtistOfferPrimaryTopLeft', 
			ArtistOfferPrimaryTopRight__c = 'ArtistOfferPrimaryTopRight', 
			ArtistOfferSupportTopLeft__c = 'ArtistOfferSupportTopLeft', 
			ArtistOfferSupportTopRight__c = 'ArtistOfferSupportTopRight',
			ArtistSettlementPrimaryOptionsLeft__c = 'ArtistSettlementPrimaryOptionsLeft', 
			ArtistSettlementPrimaryOptionsRight__c = 'ArtistSettlementPrimaryOptionsRight', 
			ArtistSettlementSupportOptions__c = 'ArtistSettlementSupportOptions'
		);
	    return( results );
	}

	/**
	 *  Creates a GeneralSettings (with default values)
	 *  that will use GlobalDataAdministrator as true.
	 *  (bypassing the common event security).
	 *  @Deprecated and should be used only as a stopgap
	 **/
	 /*
	public static GeneralSettings__c enableGlobalDataAdministrator(){
		GeneralSettings__c settings = new GeneralSettings__c(
			GlobalDataAdministrator__c = true
		);
		insert settings;
		return( settings );
	}
	*/
	
	/*
	public static GeneralSettings__c createGeneralSettings( Boolean artistDataReviewer, Boolean bypassAutomation, Boolean CoPromoterDataReviewer, Boolean debugAPI, Boolean globalDataAdministrator, Boolean vendorDataReviewer){
	    //-- use defaults for now
	    //-- update with any other parameters needed later.
	    GeneralSettings__c results = new GeneralSettings__c(
	        ArtistDataReviewer__c = artistDataReviewer,
	        BypassAutomation__c = bypassAutomation,
	        CoPromoterDataReviewer__c = CoPromoterDataReviewer,
	        DebugAPI__c = debugAPI,
	        GlobalDataAdministrator__c = globalDataAdministrator,
	        VendorDataReviewer__c = vendorDataReviewer
	    );
	    return( results );
	}
	*/
	
	/**
	 *  Creates a DMA record.
	 *  @param DMA (String)
	 *  @param city (String)
	 *  @param StateAbbrev (String)
	 *  @param PostalCode (String)
	 *  @return DMA
	 **/
	public static DMA__c createDMA( String DMA, String city, String stateAbbrev, String postalCode ){
	    DMA__c results = new DMA__c(
	        DMA__c = DMA,
	        City__c = city,
	        State__c = stateAbbrev,
	        PostalCode__c = postalCode
	    );
	    return( results );
	}
	
	/**
	 *  Creates a Tour__c record.
	 *  @param name (String)
	 *  @param artistId (Id)
	 *  @return Tour__c
	 **/
	public static Tour__c createTour(String name, Id artistId) {
		Tour__c results = new Tour__c(
    		TourName__c = name,
    		TourHeadliner__c = artistId,
    		BuyingGroup__c = 'Local Offer'
		);
	    
	    return results;
	}	
	
	/**
	 *  Creates a EventTicketAgency__c record.
	 *  @param eventDateTimeId (Id)
	 *  @param agencySystemId (String)
	 *  @return EventTicketAgency__c
	 **/
	public static EventTicketAgency__c createEventTicketAgency(Id eventDateTimeId, String agencySystemId) {
		EventTicketAgency__c results = new EventTicketAgency__c(
    		AgencySystemID__c = agencySystemId,
    		EventDateTime__c = eventDateTimeId
		);
	    
	    return results;
	}	
	
	/**
	 *  Creates a EventDateTime__c record.
	 *  @param name (String)
	 *  @param artistId (Id)
	 *  @return EventDateTime__c
	 **/
	public static EventDateTime__c createEventDateTime(Id eventId, Date startDate, Date endDate, String eventYear) {
		EventDateTime__c results = new EventDateTime__c(
    		Event__c = eventId,
    		EventDate__c = startDate,
    		EventEndDate__c = endDate,
    		EventYear__c = eventYear
		);
	    
	    return results;
	}		
	
	public static TicketScale__c createTicketScale(Id eventId, 
	                                               String priceLevel, 
	                                               Integer capacity, 
	                                               Double price, 
	                                               Integer projectedPaidTickets, 
	                                               String notes, 
	                                               String stageType) {

	    TicketScale__c testScale = new TicketScale__c(
	        Capacity__c = capacity,
	        Event__c = eventId, 
	        PriceLevel__c = priceLevel,
	        Price__c = price == null ? 0 : price,
	        ProjectedPaidTickets__c = projectedPaidTickets,
	        Notes__c = notes,
	        StageType__c = stageType
	    );
	    
	    return testScale;
	}
	
	/**
	 *  Creates a AdPlan__c record.
	 *  @param name (String)
	 *  @param budget (Integer)
	 *  @param eventId (Id)
	 *  @return AdPlan__c
	 **/
	public static AdPlan__c createAdPlan( String name, Integer budget, Id eventId, Id tourId ){
	    AdPlan__c results = new AdPlan__c(
	        AdPlanName__c = name,
	        LNEAdPlanBudget__c = budget,
	        Event__c = eventId,
	        RadioDefaultCommission__c = 1,
	        DigitalDefaultCommission__c = 1,
	        TVDefaultCommission__c = 1,
	        PrintDefaultCommission__c = 1,
	        OutdoorDefaultCommission__c = 1,
	        Tour__c = tourId
	    );
	    
	    return results;
	}	

	/**
	 *  Creates an Advertisement__c record.
	 *  @param adPlanId (Id)
	 *  @param vendorId (Id)
	 *  @param startDate (Date)
	 *  @param endDate (Date)
	 *  @param netCost (Double)
	 *  @return Advertisement__c
	 **/	
	public static Advertisement__c createAdvertisement(Id adPlanId, Id vendorId, Date startDate, Date endDate, Double netCost) {
	    Advertisement__c ad = new Advertisement__c(	            
	        AdPlan__c =  adPlanId,
	        BuyType__c = LNE_Constants.AD_BUY_TYPE_REGULAR,
            StartDate__c = startDate,
            EndDate__c = endDate,
            StartTime__c = '6:00 AM',
            EndTime__c = '10:00 PM',
            Net__c = 100000,
            Format__c = 'Country',
            Vendor__c = vendorId,
            NetCostToAdPlan__c = netCost
	    );
	    
	    return ad;
	}
	
	/**
	 *  Creates a TourCampaign__c record.
	 *  @param tourId (Id)
	 *  @param recordTypeId (Id)
	 *  @return TourCampaign__c
	 **/		
	public static TourCampaign__c createTourCampaign(Id tourId, Id recordTypeId) {
	    TourCampaign__c testRecord = new TourCampaign__c(
			RecordTypeId = recordTypeId,
			Tour__c = tourId   
	    );
	    
	    return testRecord;
	}
	
	/**
	 *  Creates a TourCampaignAdPlan__c record.
	 *  @param tourCampaignId (Id)
	 *  @param adPlanId (Id)
	 *  @param allocatedAmount (Double)
	 *  @return TourCampaignAdPlan__c
	 **/			
	public static TourCampaignAdPlan__c createTourCampaignAdPlan(Id tourCampaignId, Id adPlanId, Double allocatedAmount) {
	    TourCampaignAdPlan__c testRecord = new TourCampaignAdPlan__c(
	        TourCampaign__c = tourCampaignId,
	        AdPlan__c = adPlanId,
	        AllocatedAmount__c = allocatedAmount
	    );
	    
	    return testRecord;	    
	}	
	
	/**
	 * Creates a quicklink record
	 * @param Name (String)
	 * @param Target (String)
	 * @param Type (String)
	 * @param ExternalId (String)
	 * @param Description (String)
	 **/
	public static QuickLink__c createQuickLink( String Name, String ExternalId, String Type, String Target, String Description ){
		if( String.isEmpty( ExternalId )){
			ExternalId = Name;
		}
		QuickLink__c results = new QuickLink__c(
			Name = Name,
			Target__c = Target,
			Type__c = Type,
			ExternalId__c = ExternalId,
			Description__c = Description
		);
		return( results );
	}
	
	/**
	 * Initializes common custom settings to allow tests to proceed.
	 * 
	 * This includes:
	 *  # integration user
	 *  # Environment Ids
	 *  #...
	 * @return Map<String,Object> - information about the objects created.
	 **/
	public static void prepStandardCustomSettings(){
	    //Map<Id,Object>() results = new Map<Id,Object>();
	    
	    //-- @TODO: currently this is a map because it is not expected that these are going to be needed at all.
	    //-- if it is needed on a regular basis, perhaps this should be separated out to another class / internal class for results.
	    if( INTEGRATION_USER_ID == null ){
    	    User intUser = createIntegrationsUser( '_TstInt' );
    	    //results.put( 'IntegrationUser', intUser );
    	    
    	    EnvironmentIds__c envIds = createEnvironmentIds( intUser.id );
    	    //insert envIds;
    	    //results.put( 'environmentIds', envIds.id );
    	    
    	    GeneralSettings__c generalSettings = createGeneralSettings();
    	    insert generalSettings;
    	    
    	    API_Settings__c apiSettings = createAPISettings();
    	    insert apiSettings;

    	    DataGenerationSettings__c dataSettings = createDataSettings();
    	    insert dataSettings;

    	    RomeFieldSetSettings__c fieldSetSettings = createRomeFieldSetSettings();
    	    insert fieldSetSettings;
    	    
    	    INTEGRATION_USER_ID = intUser.id;
	    }
	    
	    return;
	}
	

	
	/**
	 *  Creates the accounts required for an account hierarchy with ParentIds formed.
	 *  <p>Please note, this inserts and updates these records, so they do not need to be applied again.</p>
	 * 
	 *  <p>Please note, to reduce errors, if the office record sent:
	 *  an Account of recordType Office, with type in either: ACCT_TYPE_DIVISION, ACCT_TYPE_BUSINESS_UNIT, ACCT_TYPE_OFFICE
	 *  then the assignToLevel is ignored, and the venue will be assigned to that office with the hierarchy maintained above.</p>
	 * 
	 *  Couple quick examples:
	 *  we do not have a specific venue or office, but we know the venue should be assigned to the Business Level:
	 *  createVenueHierarchy( LNE_TestObjectFactory.ACCT_TYPE_BUSINESS_UNIT, null, null );
	 *  
	 *  we have a specific event that we'd like to use, with uncommon fields assigned, to be used instead.
	 *  createVenueHierarchy( null, myEvent, myVenue );
	 *  
	 *  @param assignToLevel (String[Division|Business Unit|Office]) - Which level to associate the venue to. Default: Division
	 *  @param office (Account) - A user specified office to use, or null - and one is generated by default instead.
	 *  @param venue (Account) - A user specified venue to use, or null - and one is generated by default instead.
	 *  @return VenueHierarchy
	 **/
	public static VenueHierarchy createVenueHierarchy( String assignToLevel, Account office, Account venue ){
		VenueHierarchy results = null;
		
		Account[] accountsToUpdate = new Account[]{};
		
		//-- keep track of the old office and venue types;
		//-- geography does not require parentId, so we assign all to Geography, to create
		//-- and then update back to the original types once the parentIds have been created.
		String oldOfficeType;
		
		//-- do not include a try throw catch, if there is an error, we want to know about it;
		
		Account geoOfficeAcct;
		Account divisionAcct;
		Account businessUnitAcct;
		Account officeAcct;
		
		Boolean createDivision = true;
		Boolean createBusinessUnit = true;
		Boolean createOffice = true;
		
		if( office != null ){
			assignToLevel = office.Type;
		}
		
		//-- type safe the assignToLevel;
		if( assignToLevel == null || ACCT_TYPE_DIVISION.equalsIgnoreCase( assignToLevel ) ){
			assignToLevel = ACCT_TYPE_DIVISION;
		} else if( ACCT_TYPE_BUSINESS_UNIT.equalsIgnoreCase( assignToLevel )){
			assignToLevel = ACCT_TYPE_BUSINESS_UNIT;
		} else if( ACCT_TYPE_OFFICE.equalsIgnoreCase( assignToLevel )){
			assignToLevel = ACCT_TYPE_OFFICE;
		} else {
			//-- fail.
			//-- office apparently WILL happen.
			System.assert( false, 'Unexpected office.type:[' + assignToLevel + ']. Expecting: ' + ACCT_TYPE_DIVISION + ' or ' + ACCT_TYPE_BUSINESS_UNIT + ' or ' + ACCT_TYPE_OFFICE );
		}
		
		//-- @INVARIANT- the account type is one of three levels: ACCT_TYPE_DIVISION, ACCT_TYPE_BUSINESS_UNIT, ACCT_TYPE_OFFICE - not null
		
		//-- create geography
		geoOfficeAcct = new LNE_TestObjectFactory(
			LNE_TestObjectFactory.createAccount( 'North America', RT_ACCOUNT_OFFICE_ID )
		).addBillingAddress( '1000 west illinois st', 'Chicago', '60402', 'Illinois', 'IL', 'United States', 'US' )
		.addProperties( new Map<String,Object>{
			'Type' => ACCT_TYPE_GEOGRAPHY,
			'Phone' => '708-522-5307'
		}).buildAccount();
		accountsToUpdate.add( geoOfficeAcct );
		
		//-- we assign the venue to the business unit only if the office is not provided.
		//-- otherwise we assign to the office provided ( and to a business unit only if the office is a business unit );
		
		if( !ACCT_TYPE_DIVISION.equals( assignToLevel ) || office == null ){
			divisionAcct = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createAccount('US Concerts', RT_ACCOUNT_OFFICE_ID)
			).addBillingAddress( '123 Main St.', 'Chicago', '60654','Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
			    'Type' => ACCT_TYPE_GEOGRAPHY, // will be type 'Division', -- use geography as it does not require parentId;
			    'Phone' => '1231231234',
			    'Status__c' => 'Active',
				'ApplyGlobalTermsTo__c' => 'Amphitheatre',
				'GlobalTerms__c' => 'Global Terms'
			}).buildAccount();
			//-- parent id is going to be the geo office
		} else {
			//-- align to geography to avoid parentIds from being required yet.
			office.Type = ACCT_TYPE_GEOGRAPHY;
			
			//-- default additional required fields 
			if( office.Phone == null ) office.Phone = '123423424';
			if( office.Status__c == null ) office.Status__c = 'Active';
			
			divisionAcct = office;
		}
		accountsToUpdate.add( divisionAcct );
		
		if( !ACCT_TYPE_BUSINESS_UNIT.equals( assignToLevel ) || office == null ){
			
			businessUnitAcct = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createAccount('Theatres and Clubs', RT_ACCOUNT_OFFICE_ID)
			).addBillingAddress( '123 Main St.', 'Chicago', '60654','Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
			    'Type' => ACCT_TYPE_GEOGRAPHY, // will be type 'Business Unit', -- use geography as it does not require parentId;
			    'Phone' => '1231231234',
			    'Status__c' => 'Active',
				'ApplyGlobalTermsTo__c' => 'Amphitheatre',
				'GlobalTerms__c' => 'Global Terms'
			}).buildAccount();
			//-- parent id to the division
		} else {
			//-- align to geography to avoid parentIds from being required yet.
			office.Type = ACCT_TYPE_GEOGRAPHY;
			
			//-- default additional required fields
			if( office.Phone == null ) office.Phone = '1231231234';
			if( office.Status__c == null ) office.Status__c = 'Active';
			
			businessUnitAcct = office;
		}
		accountsToUpdate.add( businessUnitAcct );
		
		if( createOffice ){
			officeAcct = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createAccount('DET', RT_ACCOUNT_OFFICE_ID)
			).addBillingAddress( '123 Main St.', 'Chicago', '60654','Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
			    'Type' => ACCT_TYPE_GEOGRAPHY, // will be type 'Business Unit', -- use geography as it does not require parentId;
			    'Phone' => '1231231234',
			    'Status__c' => 'Active',
				'ApplyGlobalTermsTo__c' => 'Amphitheatre',
				'GlobalTerms__c' => 'Global Terms'
			}).buildAccount();
			//-- parent id to the division
		} else {
			//-- align to geography to avoid parentIds from being required yet.
			office.Type = ACCT_TYPE_GEOGRAPHY;
			
			//-- default additional required fields
			if( office.Phone == null ) office.Phone = '1231231234';
			if( office.Status__c == null ) office.Status__c = 'Active';
			
			officeAcct = office;
		}
		accountsToUpdate.add( officeAcct );
		
		//-- adds the venue into the chain, if specified
		if( venue != null ){
			//-- do nothing.
		} else {
			venue = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createAccount('Chicago', RT_ACCOUNT_VENUE_ID)
			).addBillingAddress( '123 Main St.', 'Chicago', '60654','Illinois', 'IL', 'United States', 'US' )
			.addProperties( new Map<String,Object>{
			    'Type' => ACCT_TYPE_STADIUM,
			    'Status__c' => 'Active',
			    'Market__c' => 'Chicago',
			    'Capacity__c' => 50000,
			    'OwnershipType__c' => 'Owned/Operated'
			}).buildAccount();
		}
		accountsToUpdate.add( venue );
		
		//-- @INVARIANT: we have now created a record for all levels
		System.debug( 'accounts to update' );
		System.debug( accountsToUpdate );
		
		System.debug( 'all current accounts' );
		System.debug( [ SELECT Id, Name from Account ] );
		
		//-- updates all the records.
		upsert accountsToUpdate;
		
		//-- now all the items in the chain have been created, update the parentId hierarchy
		//-- note: properties are assigned by reference, so specifying results makes no difference here.
		
		divisionAcct.Type = ACCT_TYPE_DIVISION;
		divisionAcct.ParentId = geoOfficeAcct.Id;
		
		businessUnitAcct.Type = ACCT_TYPE_BUSINESS_UNIT;
		businessUnitAcct.ParentId = divisionAcct.Id;
		
		officeAcct.Type = ACCT_TYPE_OFFICE;
		officeAcct.ParentId = businessUnitAcct.Id;
		
		if( ACCT_TYPE_BUSINESS_UNIT.equals( assignToLevel )){
			venue.PrimaryOffice__c = businessUnitAcct.Id;
		} else if( ACCT_TYPE_OFFICE.equals( assignToLevel )){
			venue.PrimaryOffice__c = officeAcct.Id;
		} else { // if( ACCT_TYPE_DIVISION.equals( assignToLevel )){
			venue.PrimaryOffice__c = divisionAcct.Id;
		}
		
		System.debug( 'accounts to updates [parentIds set]' );
		System.debug( accountsToUpdate );
		
		update accountsToUpdate;
		
		System.debug( 'after updating account parents' );
		System.debug( [ SELECT Id, Name, ParentId, Parent.Name, Parent.Type FROM account WHERE Id in :accountsToUpdate ] );
		
		results = new VenueHierarchy( geoOfficeAcct, divisionAcct, businessUnitAcct, officeAcct, venue );
		
		return( results );
	}
	//-- convenience functions
	public VenueHierarchy createVenueHierarchy(){
		return( createVenueHierarchy( ACCT_TYPE_DIVISION, null, null ));
	}
	public VenueHierarchy createVenueHierarchy( String assignToLevel, Account venue ){
		return( createVenueHierarchy( assignToLevel, null, venue ));
	}
	public VenueHierarchy createVenueHierarchy( Account office, Account venue ){
		return( createVenueHierarchy( null, office, venue ));
	}


	/**
	 *  Creates the most common set of records needed for nearly all unit tests.
	 *  
	 * 	<p>Invariant - the following will be created at the end of this call
	 *  <ul>
	 *  #Co Promoter 1 (name:Co Pro 1)
	 *  #Co Promoter 2 (name:Co Pro 2)
	 *  #Artist (name: Pennyback)
	 *  #Geography Office (name:North America)
	 *  #Division Office (name:US Concerts)
	 *  #Business Unit (name:Theatres and Clubs)
	 *  #Office (Name:DET)
	 *  #Event (EventName__c: starting with TestEvent - but made unique)
	 *  #Deal (type__c:Primary headliner)
	 *  #TalentOverhead (Description__c:Test)
	 *  #GLAccounts: Ticket Revenue:40100, Lawn40116, Alcoholic Beverage Revenue:40205, Auto Rental Expense:50103, Co-Promote Expense:50302, Building Co-Promote:50339
	 *  </ul>
	 *
	 *  @param eventsToUse (Event__c[]) - list of events to assign to the hierarchy
	 *  @param hierarchyToUse (VenueHierarchy) - Venue Hierarchy to use when building records. Null uses the default.
	 *  @return Map<String, Id> - map of data created to its respective id
	 *  @see createStandardTestObjectsList
	 **/
	public static Map<String, Id> createStandardDataSetList(List<Event__c> eventsToUse, VenueHierarchy hierarchyToUse ){
		return createStandardTestObjectsList( eventsToUse, hierarchyToUse);
	}
	
	/**
	 * Convenience function for sending only a single event for createStandardDataSetList.
	 * @see createStandardDataSetList
	 * @param eventToUse (Event__c)
	 * @param hierarchyToUse (VenueHierarchy) - Venue Hierarchy to use when building records. Null uses the default.
	 * @return Map<String, Id> - map of data created to its respective id
	 **/
	public static Map<String, Id> createStandardDataSet(Event__c eventToUse, VenueHierarchy hierarchyToUse ){
		return createStandardTestObjectsList( new Event__c[]{ eventToUse }, hierarchyToUse);
	}
	
	//-- convenience methods (all are deprecated.)
	public static Map<String, Id> createStandardDataSetList(List<Event__c> eventsToUse ){
		return createStandardTestObjectsList( eventsToUse, null);
	}
	public static Map<String, Id> createStandardDataSet(Event__c eventToUse ){
		return createStandardTestObjectsList( new Event__c[]{ eventToUse }, null);
	}
	public static Map<String, Id> createStandardDataSet(){
		return createStandardTestObjectsList( null, null );
	}
	
	/**
	 * Creates a standard set of data to be used with unit testing, which should* work with all the flows
	 * 
	 * 	<p>Invariant - the following will be created at the end of this call
	 *  <ul>
	 *  #Geography Office (name:North America)
	 *  #Division Office (name:US Concerts)
	 *  #Business Unit (name:Theatres and Clubs)
	 *  STANDARD_DATA_OFFICE : Account (Office from the hierarchy used)
	 *  STANDARD_DATA_VENUE : Account (Venue from the hierarchy used)
	 *  STANDARD_DATA_COPRO_1 : Account (name: Co Pro 1)
	 *  STANDARD_DATA_COPRO_2 : Account (name:Co Pro 2)
	 *  STANDARD_DATA_ARTIST : Account (name: Pennyback)
	 *  STANDARD_DATA_EVENT : Event__c (name is STANDARD_DATA_EVENT + 1, 2, 3, etc. for all events sent)
	 *  STANDARD_DATA_DEAL : (type__c:Primary headliner)
	 *  STANDARD_DATA_TALENT : TalentOverhead__c (Description__c:Test)
	 *  STANDARD_DATA_REVGL : GLAccount__c (GLCode__c:GL_TICKET_REVENUE)
	 *  STANDARD_DATA_LAWNGL : GLAccount__c (GLCode__c:GL_LAWN)
	 *  STANDARD_DATA_ANCILLARY : GLAccount__c : (GLCode__c:GL_ALCOHOLIC_REVENUE)
	 *  STANDARD_DATA_EXPENSE : GLAccount__c (GLCode__c:GL_AUTO_RENTAL_EXPENSE)
	 *  STANDARD_DATA_COPROEXPENSE : GLAccount__c (GLCode__c:GL_CO_PROMOTE_EXPENSE)
	 *  STANDARD_DATA_BUILDINGCOPRO : GLAccount__c (GLCode__c:GL_BUILDING_CO_PROMOTE)
	 *  STANDARD_DATA_PARKING : GLAccount__c (GLCode__c:GL_PARKING_REVENUE)
	 *  STANDARD_DATA_PARKINGCONTRA : GLAccount__c (GLCode__c:GL_PARKING_CONTRA)
	 *  </ul>
	 * 
	 * @param eventsToUse (Event__c[]) - list of events to assign to the hierarchy
	 * @param hierarchyToUse (VenueHierarchy) - Venue Hierarchy to use when building records. Null uses the default.
	 * @return Map<String, Id> - map of data created to its respective id (i.e: results.get( LNE_TestObjectFactory.STANDARD_DATA_VENUE ) - returns the id of the venue used.)
	 **/
	private static Map<String, Id> createStandardTestObjectsList(List<Event__c> eventsToUse, VenueHierarchy hierarchyToUse ){
		Map<String, Id> objectToId = new Map<String, Id>();
		
		//-- clean info sent
		//-- if the first item in the list is null, or no items were sent, then treat it like nothing was sent.
		if( eventsToUse != null ){
			if( eventsToUse.size() < 1 || eventsToUse[0] == null ){
				eventsToUse = null;
			}
		} //-- otherwise eventsToUse is already null.
		
		// Account - CoPromoter
	    Account copro1 = new LNE_TestObjectFactory(
	        LNE_TestObjectFactory.createAccount('Co Pro 1', RT_ACCOUNT_COPROMOTER_ID)
		).buildAccount();
		
		// Account - CoPromoter
		Account copro2 = new LNE_TestObjectFactory(
	        LNE_TestObjectFactory.createAccount('Co Pro 2', RT_ACCOUNT_COPROMOTER_ID)
		).buildAccount();
		
	    // Account - Artist
	    Account artist = new LNE_TestObjectFactory(
	        LNE_TestObjectFactory.createAccount('Pennyback', RT_ACCOUNT_ARTIST_ID)
		).addProperties( new Map<String,Object>{
		    'Genre__c' => 'Other - Music',
		    'Status__c' => 'Active',
		    'Rank__c' => 1
		}).buildAccount();
		
		//-- create the hierarchy of all business offices
		//-- Geography <- Division <- Business Unit <- Office.
		//-- with the venue.PrimaryOffice__c set to either the Division or Business Unit
		
		//-- ensure the hierarchy exists before the venue is created
		VenueHierarchy hierarchy;
		if( hierarchyToUse != null ){
			hierarchy = hierarchyToUse;
		} else {
			hierarchy = createVenueHierarchy( ACCT_TYPE_DIVISION, null,null );
		}
		objectToId.put(STANDARD_DATA_OFFICE, hierarchy.office.Id);
		objectToId.put(STANDARD_DATA_VENUE, hierarchy.venue.Id);
		
		insert new List<Account>{copro1, copro2, artist};
		objectToId.put(STANDARD_DATA_COPRO_1, copro1.Id);
		objectToId.put(STANDARD_DATA_COPRO_2, copro2.Id);
		objectToId.put(STANDARD_DATA_ARTIST, artist.Id);
		
	    // Event
	    Event__c event;
	    if (eventsToUse != null) {
	    	for( Integer i = 0; i < eventsToUse.size(); i++ ){
	    		event = eventsToUse[i];
				event.Office__c = hierarchy.office.Id;
				event.Venue__c = hierarchy.venue.Id;
				
				//-- assign any other required fields
				if( event.Status__c == null ) event.Status__c = 'Draft';
				if( event.TotalSupportActExpenses__c == null ) event.TotalSupportActExpenses__c = 0.0;
	    	}
	    } else {
	    	event = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createEvent()
			).addProperties( new Map<String,Object>{
			    'EventName__c' => makeUnique( 'TestEvent' ),
			    'Status__c' => 'Draft',
			    'TotalSupportActExpenses__c' => 0.0,
			    'Office__c' => hierarchy.office.Id,
			    'Venue__c' => hierarchy.venue.Id
			}).buildEvent();
			eventsToUse = new Event__c[]{ event };
	    }
	    
	    System.debug( 'office prior to update ' );
	    System.debug( eventsToUse );

		upsert eventsToUse;
        Integer eventCount = 0;
        for(Event__c temp : eventsToUse) {
            objectToId.put(STANDARD_DATA_EVENT + eventCount, temp.Id);
            eventCount++;
        }

        // Deal - Primary Headliner
		Deal__c deal = new Deal__c();
		deal.Event__c = event.Id;
		deal.Type__c = 'Primary Headliner';
		deal.Artist__c = artist.Id;
		deal.GuaranteeAmount__c = 1000;
		deal.dealType__c = 'Flat';
		deal.DealCalculation__c = 'Guarantee Only';
		deal.StageType__c = 'Plan';
		
		LNE_FinancialCalculator.runUpdates = true;
		insert deal;
        objectToId.put(STANDARD_DATA_DEAL, deal.Id);
        
		// Talent Overhead
		TalentOverhead__c talent = new TalentOverhead__c();
		talent.Amount__c = 100;
		talent.Description__c = 'Test';
		talent.Deal__c = deal.Id;
		insert talent;
        objectToId.put(STANDARD_DATA_TALENT, talent.Id);
        
		// GLA Accounts
		//-- @TODO: use TEST_AllGLAccounts instead of one offs like these
		//-- @TODO: to refresh, please see /apex/TEST_AllGLAccountsWriter
		GLAccount__c revGL = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Ticket Revenue', GL_TICKET_REVENUE))
		    .addProperties(
	            new Map<String,Object>{
		            'Type__c' => 'Ticket Revenue'
		        }
	        )
		    .buildGLAccount();
		    
	    GLAccount__c lawnGL = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Lawn', GL_LAWN))
	    .addProperties(
	            new Map<String,Object>{
		            'Type__c' => 'Ticket Revenue'
		        }
	        )
	        .buildGLAccount();
	       
	    GLAccount__c ancillary = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Alcoholic Beverage Revenue', GL_ALCOHOLIC_REVENUE)) // Mmmm beer
	        .addProperties(
	            new Map<String,Object>{
		            'Type__c' => 'Ancillary'
		        }
	        )
		    .buildGLAccount();
		    
	    GLAccount__c expense = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Auto Rental Expense', GL_AUTO_RENTAL_EXPENSE ))
	        .addProperties(
	            new Map<String,Object>{
		            'Type__c' => 'Expenses'
		        }
	        )
		    .buildGLAccount();
		    
	    GLAccount__c coproexpense = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Co-Promote Expense', GL_CO_PROMOTE_EXPENSE ))
	        .addProperties(
	            new Map<String,Object>{
		            'Type__c' => 'Other'
		        }
	        )
		    .buildGLAccount();
		    
	    GLAccount__c buildingcopro = new LNE_TestObjectFactory(LNE_TestObjectFactory.createGLAccount('Building Co-Promote', GL_BUILDING_CO_PROMOTE ))
	        .addProperties(
	            new Map<String,Object>{
		            'Type__c' => 'Other'
		        }
	        )
		    .buildGLAccount();
		    
		GLAccount__c parking = new LNE_TestObjectFactory(
			LNE_TestObjectFactory.createGLAccount( 'Parking Revenue', GL_PARKING_REVENUE )
		).addProperties(
			new Map<String,object>{
				'Category__c' => 'Parking Revenue',
				'Type__c' => 'Ancillary',
				'AvailableForForecast__c' => true,
				'ImportRateType__c' => 'Per Cap'
			}
		).buildGLAccount();
		
		GLAccount__c parkingContra = new LNE_TestObjectFactory(
			LNE_TestObjectFactory.createGLAccount( 'Contra Rev - Parking', GL_PARKING_CONTRA )
		).addProperties(
			new Map<String,object>{
				'Category__c' => 'Parking Revenue',
				'Type__c' => 'Contra',
				'RevenueFlag__c' => false
			}
		).buildGLAccount();

	    insert new List<GLAccount__c>{revGL,lawnGL,ancillary,expense,coproexpense, buildingcopro, parking, parkingContra};
	    
	    parking.RelatedContra__c = parkingContra.Id;
	    update parking;
	    
	    objectToId.put(STANDARD_DATA_REVGL, revGL.Id);
	    objectToId.put(STANDARD_DATA_LAWNGL, lawnGL.Id);
	    objectToId.put(STANDARD_DATA_ANCILLARY, ancillary.Id);
	    objectToId.put(STANDARD_DATA_EXPENSE, expense.Id);
	    objectToId.put(STANDARD_DATA_COPROEXPENSE, coproexpense.Id);
	    objectToId.put(STANDARD_DATA_BUILDINGCOPRO, buildingcopro.Id);
	    objectToId.put(STANDARD_DATA_PARKING, parking.Id );
	    objectToId.put(STANDARD_DATA_PARKINGCONTRA, parkingContra.Id );
	    
	    return objectToId;
	}
	
	
	//#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
	//-- SObject creation methods
	
	/**
	 *  Creates an Account
	 *  @param name (String)
	 *  @param Map<String,Object> - 
	 *  @return Account
	 **/
	public static Account createAccount( String name ){
		Account result = new Account(
			Name = name,
			BillingCountryCode = 'US'
		);
		return( result );
	}

	
	/**
	 *  Creates an Account
	 *  @param name (String)
	 *  @param recordTypeId (Id) - id of the recordtype to create
	 *  @return Account
	 **/
	public static Account createAccount( String name, Id recordTypeId ){
		
		//-- deprecated
		//-- please use the createVenueHierarchy method instead.
		/*
        Account a1 = new Account();
        Account a2 = new Account();
        Account a3 = new Account();
        
        // create Hierarchy if Office is created.
        if (recordTypeId != null && recordTypeId == RT_ACCOUNT_OFFICE_ID){
    	    a1.Name = 'North America';
    	    a1.Type = 'Geography';
    	    a1.BillingCountryCode = 'US';
    	    database.insert(a1, false);
    	    
    	    a2.Name = 'test division';
    	    a2.Type = 'Division';
    	    a2.BillingCountryCode = 'US';
    	    a2.ParentId = a1.Id;
    	    database.insert(a2, false);
    	    
    	    a3.Name = 'Los Angeles';
    	    a3.Type = 'Business Unit'; 
    	    a3.BillingCountryCode = 'US';
    	    a3.ParentId = a2.Id;
	        database.insert(a3, false);
        }
        */
        
		Account result = createAccount( name );
		result.RecordTypeId = recordTypeId;
		
		return( result );
	}
	
	/**
	 *  Creates a contact
	 *  @param accountId (id) - id of the account
	 *  @param firstName (String)
	 *  @param lastName (String)
	 *  @param Map<String,Object> -
	**/
	public static Contact createContact( Id accountId, String firstName, String lastName ){
		Contact result = new Contact(
			FirstName = firstName,
			LastName = lastName,
			AccountId = accountId
		);
		return( result );
	}

	/**
	 *  Creates an Event__c
	 *  @return Event__c
	**/
	public static Event__c createEvent(){
		Event__c result = new Event__c();
		return( result );
	}

	/**
	 *  Creates a GLAccount__c
	 *  @param name (String)
	 *  @param code (String)
	 *  @return GLAccount__c
	 **/
	public static GLAccount__c createGLAccount( String name, String code ){
		List<Schema.PicklistEntry> typePicklist = GLAccount__c.Type__c.getDescribe().getPicklistValues();
		List<Schema.PicklistEntry> categoryPicklist = GLAccount__c.Category__c.getDescribe().getPicklistValues();
		GLAccount__c result = new GLAccount__c(
			Name = name,
			GLCode__c = code,
			Type__c = typePicklist[0].getValue(),
			Category__c = categoryPicklist[0].getValue()
		);
		return( result );
	}
	
	//#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
	//-- Builder Methods
	/*
	 *  Very useful for creating complex extensions:
	 *  example:
	 *  Map<String,Object> COMMON_PROPS = new Map<String,Object>{ 'SomeString' => 'someValue', 'SomeNumber' => 4 };
	 *  new LNE_TestObjectFactory(
	 *  	LNE_TestObjectFactory.createAccount( 'Acme' )
	 *  ).addAddress( '123 Easy St.','San Francisco', '12345','CA','USA' )
	 *  .addproperties( COMMON_PROPS ).buildAccount();
	*/
	
	/** Object to be built upon. The only property we should have on the factory **/
	public SObject sobj;
	
	/**
	 *  Initiates the builder wrapper.
	 *  @param sObject - object to build upon.
	 *  @return LNE_TestObjectFactory
	 *  
	 *  Wrapper for working with builders.
	 *  This allows for some extremely complex building processes:
	 *  Ex:
	 *  new LNE_TestObjectFactory(
	 *  	LNE_TestObjectFactory.createAccount( 'Acme' )
	 *  ).addAddress( '123 Easy St.','San Francisco', '12345','CA','USA' ).buildAccount();
	**/
	public LNE_TestObjectFactory( Sobject sobj ){
		this.sobj = sobj;
	}
	
	/**
	 *  Same as constructor, just allow for recycling of the factory.
	 *  @param sobj (SObject)
	 *  @return LNE_TestObjectFactory - to allow for inline editing.
	 **/
	public LNE_TestObjectFactory importObj( SObject sobj ){
	    this.sobj = sobj;
	    return( this );
	}
	
	/**
	 *  Adds an address to a contact.
	 *  <p>Note: Deprecated, please use addBillingAddress / addMailingAddress instead</p>
	 *  @DEPRECATED
	 *  @param contact Contact
	 *  @param Street (String)
	 *  @param City (String)
	 *  @param PostalCode (String)
	 *  @param State (String)
	 *  @param Country (String)
	 *  @return LNE_TestObjectFactory
	 *  
	 *  Ex:
	 *  new LNE_TestObjectFactory(
	 *  	LNE_TestObjectFactory.createAccount( 'Acme' )
	 *  ).addAddress( '123 Easy St.','San Francisco', '12345','CA','USA' ).buildAccount();
	**/
	/*public LNE_TestObjectFactory addAddress( String street, String city, String postalCode, String state, String country ){
		System.debug( '@DEPRECATED addAddress method called. Please use addMailingAddress / addBillingAddress instead.' );
		//@TODO: convert to generics.
		Contact myContact = (Contact)this.sobj;
		
		myContact.MailingStreet = street;
		myContact.MailingCity = city;
		myContact.MailingpostalCode = postalCode;
		myContact.Mailingstate = state;
		myContact.Mailingcountry = country;
		
		return( this );
	}*/
	
	
	
	/**
	 *  Adds an address to a contact.
	 *  @param fieldPrefix (String) - the prefix to the type of address field name: Billing,Shipping,Mailing,etc.
	 *  @param contact Contact
	 *  @param Street (String)
	 *  @param City (String)
	 *  @param PostalCode (String)
	 *  @param State (String)
	 *  @param Country (String)
	 *  @return LNE_TestObjectFactory
	 *  
	 *  Ex:
	 *  new LNE_TestObjectFactory(
	 *  	LNE_TestObjectFactory.createAccount( 'Acme' )
	 *  ).addAddressInfo( 'Shipping', '123 Easy St.','San Francisco', '12345','CA','USA' ).buildAccount();
	 *  System.assert( '123 Easy St.', myAccount.ShippingStreet, 'the field must be calculated and set' );
	**/
	public LNE_TestObjectFactory addAddressInfo( String fieldPrefix, String street, String city, String postalCode, String state, String stateCode, String country, String countryCode ){
		this.sobj.put( fieldPrefix + 'Street', street );
		this.sobj.put( fieldPrefix + 'City', city );
		this.sobj.put( fieldPrefix + 'PostalCode', postalCode );
		this.sobj.put( fieldPrefix + 'Country', country );
		this.sobj.put( fieldPrefix + 'CountryCode', countryCode );
		this.sobj.put( fieldPrefix + 'State', state );
		this.sobj.put( fieldPrefix + 'StateCode', stateCode );
		
		return( this );
	}
	public LNE_TestObjectFactory addMailingAddress( String street, String city, String postalCode, String state, String stateCode, String country, String countryCode ){
		return( addAddressInfo( 'Mailing', street, city, postalCode, state, stateCode, country, countryCode ));
	}
	public LNE_TestObjectFactory addBillingAddress( String street, String city, String postalCode, String state, String stateCode, String country, String countryCode ){
		return( addAddressInfo( 'Billing', street, city, postalCode, state, stateCode, country, countryCode ));
	}
	public LNE_TestObjectFactory addShippingAddress( String street, String city, String postalCode, String state, String stateCode, String country, String countryCode ){
		return( addAddressInfo( 'Shipping', street, city, postalCode, state, stateCode, country, countryCode ));
	}
	
	
	/**
	 *  Adds any additional properites.
	 *  @param map<String,Object> additionalParameters.
	 *  @return LNE_TestObjectFactory
	 *  
	 *  This allows essentially any additional parameters to be set,
	 *  often in bulk.  If additional properties are set together, consider writing
	 *  a new builder for it.
	 *  
	 *  Ex:
	 *  Map<String,Object> COMMON_PROPS = new Map<String,Object>{ 'SomeString' => 'someValue', 'SomeNumber' => 4 };
	 *  new LNE_TestObjectFactory(
	 *  	LNE_TestObjectFactory.createAccount( 'Acme' )
	 *  ).addAddress( '123 Easy St.','San Francisco', '12345','CA','USA' )
	 *  .addproperties( COMMON_PROPS ).buildAccount();
	**/
	public LNE_TestObjectFactory addProperties( map<String,Object> additionalProps ){
		for( String mapKey : additionalProps.keySet() ){
			this.sobj.put( mapKey, additionalProps.get( mapKey ) );
		}
		
		return( this );
	}
	
	//#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
	// shunt for generics.
	//-- support to convert the object type back since generics aren't supported. X(
	//-- only needed if the result must be Account,Contact,etc. and SObject type will not do
	
	/**
	 *  Synonym for referencing sobj property.
	 *  @return SObject
	**/
	public Account buildAccount(){ return( (Account)this.sobj ); }
	public Contact buildContact(){ return( (Contact)this.sobj ); }
	public DMA__c buildDMA(){ return( (DMA__c)this.sobj ); }
	public Event__c buildEvent(){ return( (Event__c)this.sobj ); }
	public GLAccount__c buildGLAccount(){ return( (GLAccount__c)this.sobj ); }
	//public Contact buildAccountContactRelationship(){ return( (AccountContactRelationship)this.sobj ); }
	//public Contact buildOpportunity(){ return( (Opportunity)this.sobj ); }
	//etc.
	

	
	/**
	 * Represents an account hierarchy (Geography -> Division -> Business Unit
	 */
	public class VenueHierarchy {
		/** geography office - like north america **/
		public Account geography;
		
		/** division office - like West-US **/
		public Account division;
		
		/** business unit - like theatre and clubs **/
		public Account businessUnit;
		
		/** office - sub division under business unit - Det/Indy,Cle **/
		public Account office;
		
		/** venue - like - Red Door Amphitheatre **/
		public Account venue;
		
		public VenueHierarchy( Account geography, Account division, Account businessUnit, Account office, Account venue ){
			this.geography = geography;
			this.division = division;
			this.businessUnit = businessUnit;
			this.office = office;
			this.venue = venue;
		}
	}
}