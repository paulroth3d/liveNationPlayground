/**
 * Utility class for deep cloning an Event
 * @Author Paul Roth <proth@salesforce.com>
 * @Author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 * @SEE US36
 **/
public without sharing class LNE_EventCloneUtil {
    
    //-- errors
    /** error thrown if no fields could be found for an sobject **/
    public static final String ERROR_SOBJECT_HAS_NO_FIELDS = 'NO FIELDS FOUND FOR:';
    /** error if parse schema was not called on the clonableObjects **/
    public static final String ERROR_PARSE_SCHEMA_NOT_CALLED = 'ClonableObject: parseSchema not called; not initialized;';
    /** error thrown if we try to query when there are no records **/
    public static final String WARNING_NO_RECORDS_TO_QUERY = 'WARNING: no records to query';
    /** error thrown if there are no records returned **/
    public static final String WARNING_NO_RECORDS_RETURNED = 'WARNING: no records returned';
    /** warning if there was no match found for a parent field, when attempting to translate **/
    public static final String WARNING_PARENT_ID_NOT_FOUND = 'WARNING: no parent id found:';

    private static final DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
    
    //-- statuses
    public static final String JOB_STATUS_ABORTED = 'Aborted';
    public static final String JOB_STATUS_COMPLETED = 'Completed';
    public static final String JOB_STATUS_FAILED = 'Failed';
    
    //-- clonable statuses;
    /** initial state of the clonable **/
    public static final String CLONABLE_STATUS_INITIAL = 'INITIAL';
    /** state once the clonable has records ready **/
    public static final String CLONABLE_STATUS_READY = 'READY';
    /** state once the clonable has finished inserting everything **/
    public static final String CLONABLE_STATUS_COMPLETE = 'COMPLETE';
    
    /** delimiter used in chunking **/
    public static final String DELIMITER = ',';
    /** default id field **/
    public static final String DEFAULT_ID_FIELD = 'Id';

    public static String DATA_DELIMITER {get;set;} 
    public static String ESCAPED_DATA_DELIMITER {get;set;} 
    
    /** unique id **/
    private static Integer UUID_SEED = 1;
    public static String GET_UUID(){
        //-- normally, we would like to get a unique identifier
        //-- but switched to a null UUID to allow updates from the backend.
        //return( '' + DateTime.now().getTime() + '-'+ UUID_SEED++ );
        return( null );
    }
    
    /** standard fields **/
    public static Set<String> STANDARD_FIELDS = getStandardFields();
    public static Set<String> getStandardFields(){
        Set<String> results = new Set<String>();
        results.addAll( new String[]{ 'Id','CreatedDate','CreatedById','LastModifiedDate','LastModifiedById','OwnerId','RecordTypeId' } );
        return( results );
    }
    public static Set<String> STANDARD_IMMUTABLE_FIELDS = new Set<String>{'Id', 'CreatedDate', 'CreatedById', 'LastModifiedDate', 'LastModifiedById', 'IsDeleted'};
    
	public static final String SOBJECT_ADPLAN = 'AdPlan__c';
	public static final String SOBJECT_ADVERTISEMENT = 'Advertisement__c';
	public static final String SOBJECT_ARTISTRETROSTEPUPDETAIL = 'ArtistRetroStepUpDetail__c';
	public static final String SOBJECT_ARTISTSETTLEMENTSUPPLEMENT = 'ArtistSettlementSupplement__c';
	public static final String SOBJECT_BONUSDETAIL = 'BonusDetail__c';
	public static final String SOBJECT_DEAL = 'Deal__c';
	public static final String SOBJECT_DEALSETTLEMENTLEDGER = 'DealSettlementLedger__c';
	public static final String SOBJECT_DEDUCTION = 'Deduction__c';
	public static final String SOBJECT_EVENT = 'Event__c';
	public static final String SOBJECT_EVENTDATETIME = 'EventDateTime__c';
	public static final String SOBJECT_EVENTTICKET = 'EventTicket__c';
	public static final String SOBJECT_EVENTTICKETAGENCY = 'EventTicketAgency__c';
	public static final String SOBJECT_INSERTION = 'Insertion__c';
	public static final String SOBJECT_LEDGERENTRY = 'LedgerEntry__c';
	public static final String SOBJECT_LEDGERENTRYBREAKOUT = 'LedgerEntryBreakout__c';
	public static final String SOBJECT_MANUALTICKETCOUNT = 'ManualTicketCount__c';
	public static final String SOBJECT_MERCHANDISEDEAL = 'MerchandiseDeal__c';
	public static final String SOBJECT_NONLNEBUDGET = 'NonLNEBudget__c';
	public static final String SOBJECT_ONSALEDATETIME = 'OnSaleDateTime__c';
	public static final String SOBJECT_PROMOPROMOSCALE = 'PromoPromoScale__c';
	public static final String SOBJECT_PROMOSCALE = 'PromoScale__c';
	public static final String SOBJECT_PROMOTIONS = 'Promotions__c';
	public static final String SOBJECT_TALENTOVERHEAD = 'TalentOverhead__c';
	public static final String SOBJECT_TICKETSCALE = 'TicketScale__c';
	public static final String SOBJECT_TOURCAMPAIGNADPLAN = 'TourCampaignAdPlan__c';

	public static final List<ClonableDescription> objectsToClone_SecondTier = new List<ClonableDescription>();
	public static final List<ClonableDescription> objectsToClone_ThirdTier = new List<ClonableDescription>();
	public static final List<ClonableDescription> objectsToClone_FourthTier = new List<ClonableDescription>();
	public static final List<ClonableDescription> objectsToClone_FifthTier = new List<ClonableDescription>();

	static final String RT_DEAL_ARTIST = 'Deal__c.Artist';
	static final String RT_DEAL_COPROMOTER = 'Deal__c.CoPromoter';
	static final String RT_DEAL_INTERNALCOPROMOTER = 'Deal__c.InternalCoPromoter';

	static final String RT_LEDGERENTRY_EXPENSES = 'LedgerEntry__c.Expenses';
	static final String RT_LEDGERENTRY_ANCILLARY = 'LedgerEntry__c.Ancillary';
	static final String RT_LEDGERENTRY_COGS = 'LedgerEntry__c.COGS';

	static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
		new String[]{ RT_DEAL_ARTIST, RT_DEAL_COPROMOTER, RT_DEAL_INTERNALCOPROMOTER, RT_LEDGERENTRY_EXPENSES, RT_LEDGERENTRY_ANCILLARY, RT_LEDGERENTRY_COGS }
	);

	static Event__c originalEvent;

	private static Map<String,GLAccount__c> glAccountsMap = LNE_Util.getGLAccounts(new String[] {'50410','50419','50412','50408','50404','50402','50441','50446'});
	private static Set<Id> glAccountIds = new Map<Id, GLAccount__c>(glAccountsMap.values()).keySet();
    
    /**
     * peforms a deep delete of an event
     * @param eventId (Id) - id of the event to obliterate
     * @param (Id) - the id of the job that was kicked off.
     **/
    public static Id execute( Id eventId, EventCloneParams params){
    	
    	Id jobId = null;
    	
    	//-- only allow deep cloning if the user can edit the event.
    	//-- @TODO: verify that with sharing to call without sharing does indeed block.

        if( !LNE_Util.isEventEditable( eventId )){
        	System.debug( 'current user cannot edit the event' );
        	return( jobId );
        }
        
    	deepCloneEvent( eventId, JSON.serialize(params));
    	
    	//-- use Queueable apex class instead to get a more accurate job id.
    	//-- https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
    	
    	jobId = getJobId();
    	System.debug( 'current running job id:' + jobId );
    	return( jobId );
    }
    
    /**
     * Determine the job id of the most recent future event.
     * @return Id
     **/
    public static Id getJobId(){
    	Id result = null;
    	
		Id currentUserId = UserInfo.getUserId();
		
        List<AsyncApexJob> latestJobs = [ SELECT Id, CreatedBy.Name, ApexClass.Name, MethodName, Status
            FROM AsyncApexJob
            WHERE CreatedById = :currentUserId
            AND ApexClass.Name = 'LNE_EventCloneUtil'
            ORDER BY createdDate desc
            limit 1 ];
        
        if (latestJobs.size() > 0) {
            result = latestJobs[0].Id;
        }
    	
    	return( result );
    }
    
    /**
     * Actually does the deep clone
     * @param eventId (Id) - the id of the event to clone.
     * @return Event__c (the NEW event created)
     **/
    @future
    private static void deepCloneEvent( Id eventid, String paramsString){

        //- Too bad we can't send an Apex object to a @future method, so let's reconstruct it here
        EventCloneParams params = (EventCloneParams)JSON.deserialize(paramsString, EventCloneParams.class );
        DATA_DELIMITER = DATA_SETTINGS.CombinedKeyDelimiter__c;
        ESCAPED_DATA_DELIMITER = DATA_SETTINGS.CombinedKeyDelimiter__c;
        if (String.isNotBlank(ESCAPED_DATA_DELIMITER)) {
    		if (ESCAPED_DATA_DELIMITER == '|') {
	            ESCAPED_DATA_DELIMITER = '\\|';
	        }
    	}

        originalEvent = [SELECT StatusStage__c FROM Event__c WHERE Id = :eventid];

        Event__c results = null;
        
        //-- list of related records;
        SObject[] records;
        Map<Id,Sobject> clonedObjects;
        ClonableObject clonable;
        
        //-- translation from oldId to newId
        Map<Id, Id> oldIdsNewIds = new Map<Id,Id>();
        Id oldParentId, newParentId;
        
        Id[] eventIds = new Id[]{ eventId };
        
        ClonableObject cObj;
        ClonableObjectGroup clonableGroup;
        String whereClause;
        
        //-- @TODO: look into whether this can be made static (but not static initialized)
        Map<String,ClonableObject> clonableMap = null;
        ClonableObject[] orderedClonableObjects = new ClonableObject[]{};
        
		//-- collection of all the objects, by their relationships to get to the parent Event (the where clause)
		//-- in the order that they need to be created
		clonableGroup = new ClonableObjectGroup();
		addClonableSchema( orderedClonableObjects, clonableGroup, SOBJECT_EVENT, createWhereClause(SOBJECT_EVENT, 'Id', eventIds ));

		objectsToClone_SecondTier.addAll(new List<ClonableDescription>{
			new ClonableDescription(SOBJECT_DEAL,'Event__c'),
			new ClonableDescription(SOBJECT_EVENTDATETIME,'Event__c')
		});

		objectsToClone_ThirdTier.addAll(new List<ClonableDescription>{
			new ClonableDescription(SOBJECT_TICKETSCALE,'Event__c'),
			new ClonableDescription(SOBJECT_DEDUCTION,'Event__c'),
			new ClonableDescription(SOBJECT_LEDGERENTRY,'Event__c')
		});

		objectsToClone_FourthTier.addAll(new List<ClonableDescription>{
			new ClonableDescription(SOBJECT_LEDGERENTRYBREAKOUT,'LedgerEntry__r.Event__c'),
			new ClonableDescription(SOBJECT_BONUSDETAIL,'Deal__r.Event__c'),
			new ClonableDescription(SOBJECT_DEALSETTLEMENTLEDGER,'Deal__r.Event__c')
		});

		objectsToClone_FifthTier.addAll(new List<ClonableDescription>{
			new ClonableDescription(SOBJECT_EVENTTICKETAGENCY,'EventDateTime__r.Event__c')
		});

		//-- second tiers
		clonableGroup = new ClonableObjectGroup();
		for (ClonableDescription cd : objectsToClone_SecondTier) {
			addClonableSchema( orderedClonableObjects, clonableGroup, cd.sObjectName, createWhereClause(cd.sObjectName, cd.whereClause, eventIds));
		}

		//-- third tiers
		clonableGroup = new ClonableObjectGroup();
		for (ClonableDescription cd : objectsToClone_ThirdTier) {
			addClonableSchema( orderedClonableObjects, clonableGroup, cd.sObjectName, createWhereClause(cd.sObjectName, cd.whereClause, eventIds));
		}

		//-- fourth tiers
		clonableGroup = new ClonableObjectGroup();
		for (ClonableDescription cd : objectsToClone_FourthTier) {
			addClonableSchema( orderedClonableObjects, clonableGroup, cd.sObjectName, createWhereClause(cd.sObjectName, cd.whereClause, eventIds));
		}

		//-- fifth tiers
		clonableGroup = new ClonableObjectGroup();
		for (ClonableDescription cd : objectsToClone_FifthTier) {
			addClonableSchema( orderedClonableObjects, clonableGroup, cd.sObjectName, createWhereClause(cd.sObjectName, cd.whereClause, eventIds));
		}
        
        /*
        @TODO: okay, now all objects have been cloned, we have to go through each of the created objects again
        and simply run the appropriate cObj.updateExternalReferences( records, oldIdsNewIds )
        */
        
        clonableMap = createClonableMap( orderedClonableObjects );

        Savepoint sp = Database.setSavepoint();
        
        //-- @TODO uncomment this try/catch, commented out for testing/development
        //try {
        
            //-- hold off for the financial calculator and disable all triggers for now.
            LNE_FinancialCalculator.currentlyRunning = true;
            LNE_Util.IS_CURRENTLY_CLONING = true;
            
            //-- do the event by hand just to make sure everything is going correctly
            clonable = orderedClonableObjects[0];
            System.debug( 'now attempting to clone:' + clonable.sObjectName );
            System.assert( SOBJECT_EVENT.equals( clonable.sObjectName ), 'the first thing to clone must be the event' );
            clonedObjects = clonable.queryRecords(false);
            records = clonedObjects.values();

            if (records.size() > 0) {
            	RecordProcessor processor = getRecordProcessor(clonable.sObjectName);
            	if (processor != null) {
            		processor.processRecords(params, clonable);
            	}
            }

            System.assert( clonedObjects.containsKey( eventId ), 'if we\'re trying to clone the event, it needs to be in the list' );
            Boolean wasInsertAttempted = clonable.attemptInsert( oldIdsNewIds );
            System.assert( wasInsertAttempted == true, 'there should be only one item in the list, so an update should be attempted' );
            results = (Event__c)(clonedObjects.get( eventId ));
            // System.debug( '-- finished cloning:' + clonable.sObjectName );
            // System.debug( 'oldIdsNewIds' );
            // System.debug( oldIdsNewIds );

            //-- if that works correctly, then do all the other ones. BWA! HAHAHA!
            for( Integer i = 1; i < orderedClonableObjects.size(); i++ ){
                clonable = orderedClonableObjects[i];
                System.debug( 'now attempting to clone:' + clonable.sObjectName );

                Boolean storeOriginals = clonable.sObjectName == SOBJECT_EVENTDATETIME;
                
                clonedObjects = clonable.queryRecords(storeOriginals);
                records = clonedObjects.values();
                clonable.updateExternalReferences( records, oldIdsNewIds );

                RecordProcessor processor = getRecordProcessor(clonable.sObjectName);
                if (processor != null) {
                	processor.processRecords(params, clonable);	
                }
                
                wasInsertAttempted = clonable.attemptInsert( oldIdsNewIds );

                System.debug( '-- finished cloning:' + clonable.sObjectName );
                System.debug( 'wasInsertAttempted:' + wasInsertAttempted );
                System.debug( 'oldIdsNewIds' );
                System.debug( oldIdsNewIds );
            }

            System.debug( 'finished cloning everything, now updating the back references' );

            SObject[] allObjectsUpdate = new SObject[]{};
            for( Integer i = 0; i < orderedClonableObjects.size(); i++ ){
            	clonable = orderedClonableObjects[i];

                clonable.updateExternalReferences( clonable.objectsCreated, oldIdsNewIds );
                allObjectsUpdate.addAll( clonable.objectsCreated );

                RecordProcessor processor = getRecordProcessor(clonable.sObjectName);
                if (processor != null) { 
                	processor.processRecordsAfterInsert(params, clonable, clonableMap.get(SOBJECT_TICKETSCALE));	
                }
            }
            
            update allObjectsUpdate;
            System.debug( 'finished cloning everything, and all back references have completed.' );
            
            createAristDeal(params, results);
            
            runCalculator(results);
            
            finalizeEvent(results);
            
            
        //} catch( Exception err ){
            // System.debug( err );
            // Database.rollback( sp );
        //}
        
        //-- @TODO: remove rollback.
        //-- currently ALWAYS rolling back since it dramatically simplifies development and cleanup.
        
        //Database.rollback( sp );
        
        //-- verify error messages appear in ExtendedStatus.
		//System.assert( false,'TOO MUCH AWESOME. EVERYTHING FINISHED' );
        
        //return( results );
    }

    private static void runCalculator(Event__c event) {
    	LNE_FinancialCalculator.currentlyRunning = false;
        LNE_Util.IS_CURRENTLY_CLONING = false;
        LNE_FinancialCalculator.addEventId(event.Id);
        LNE_FinancialCalculator.checkIfCanRunCalculations();
    }

    private static void finalizeEvent(Event__c event) {
    	LNE_FinancialCalculator.currentlyRunning = true;
        LNE_Util.IS_CURRENTLY_CLONING = true;
        Event__c e = [SELECT CloningInProcess__c FROM Event__c WHERE Id = :event.Id];
    	e.CloningInProcess__c = false;

    	update e;
    }

    private static void createAristDeal(EventCloneParams params, Event__c newEvent) {
    	LNE_Util.IS_CURRENTLY_CLONING = false;
    	if (String.isNotBlank(params.artistId) && newEvent != null) {
    		Id RT_DEAL_ARTIST_ID = recordTypeMap.get( RT_DEAL_ARTIST );
    		Deal__c d = new Deal__c(RecordTypeId = RT_DEAL_ARTIST_ID,
    					 		 	Event__c = newEvent.Id,
    					 		 	Artist__c = params.artistId,
    					 		 	Rank__c = 1,
    					 		 	Type__c = 'Primary Headliner');

    		if (String.isNotBlank(params.ownerId)) {
    			d.OwnerId = params.ownerId;
    		}

    		insert d;
    		
    	}
    	LNE_Util.IS_CURRENTLY_CLONING = true;
    }
    
    /**
     * Generates a where clause for a specific set of ids and potentially
     * more depending on the sObject
     * @param String idField
     * @param Id[] ids
     * @return String - ex: idField in ('123123','1123123')
     **/
    public static String createWhereClause(String sObjectName, String idField, Id[] recordIds ){
        String result = null;
        if( recordIds != null && recordIds.size() > 0 ){
            result = idField + ' in (\'' + String.join( recordIds, '\', \'' ) + '\')';
        }

        if (sObjectName == SOBJECT_DEAL) {
			Id RT_DEAL_COPROMOTER_ID = recordTypeMap.get( RT_DEAL_COPROMOTER );
			Id RT_DEAL_INTERNALCOPROMOTER_ID = recordTypeMap.get( RT_DEAL_INTERNALCOPROMOTER );
			List<Id> recordTypeIds = new List<Id>{RT_DEAL_COPROMOTER_ID, RT_DEAL_INTERNALCOPROMOTER_ID};

        	result += ' AND RecordTypeId IN (\'' + String.join( recordTypeIds, '\', \'' ) + '\') AND Type__c <> \'Internal\'';
        }

        if (sObjectName == SOBJECT_BONUSDETAIL) {
			Id RT_DEAL_COPROMOTER_ID = recordTypeMap.get( RT_DEAL_COPROMOTER );
			Id RT_DEAL_INTERNALCOPROMOTER_ID = recordTypeMap.get( RT_DEAL_INTERNALCOPROMOTER );
			List<Id> recordTypeIds = new List<Id>{RT_DEAL_COPROMOTER_ID, RT_DEAL_INTERNALCOPROMOTER_ID};

        	result += ' AND Deal__r.RecordTypeId IN (\'' + String.join( recordTypeIds, '\', \'' ) + '\') AND Deal__r.Type__c <> \'Internal\'';
        }

        if (sObjectName == SOBJECT_DEALSETTLEMENTLEDGER) {
			Id RT_DEAL_COPROMOTER_ID = recordTypeMap.get( RT_DEAL_COPROMOTER );
			Id RT_DEAL_INTERNALCOPROMOTER_ID = recordTypeMap.get( RT_DEAL_INTERNALCOPROMOTER );
			List<Id> recordTypeIds = new List<Id>{RT_DEAL_COPROMOTER_ID, RT_DEAL_INTERNALCOPROMOTER_ID};

        	result += ' AND Deal__r.RecordTypeId IN (\'' + String.join( recordTypeIds, '\', \'' ) + '\') AND Deal__r.Type__c <> \'Internal\'';
        }

        if (sObjectName == SOBJECT_TICKETSCALE) {
        	String originalEventStageType = originalEvent.StatusStage__c;

        	if (String.isNotBlank(originalEventStageType)) {
        		result += ' AND StageType__c = \'' + originalEventStageType + '\'';
        	}
        }

        if (sObjectName == SOBJECT_DEDUCTION) {
        	String originalEventStageType = originalEvent.StatusStage__c;

        	if (String.isNotBlank(originalEventStageType)) {
        		result += ' AND StageType__c = \'' + originalEventStageType + '\'';
        	}
        }

        if (sObjectName == SOBJECT_LEDGERENTRY) {
        	Id RT_LEDGERENTRY_EXPENSES_ID = recordTypeMap.get( RT_LEDGERENTRY_EXPENSES );
        	Id RT_LEDGERENTRY_ANCILLARY_ID = recordTypeMap.get( RT_LEDGERENTRY_ANCILLARY );
        	Id RT_LEDGERENTRY_COGS_ID = recordTypeMap.get( RT_LEDGERENTRY_COGS );
			List<Id> recordTypeIds = new List<Id>{RT_LEDGERENTRY_EXPENSES_ID, RT_LEDGERENTRY_ANCILLARY_ID, RT_LEDGERENTRY_COGS_ID};
			List<Id> glAccountsToSkip = new List<Id>(glAccountIds);

        	result += ' AND RecordTypeId IN (\'' + String.join( recordTypeIds, '\', \'' ) + '\') AND (NOT GLAccount__c IN (\'' + String.join( glAccountsToSkip, '\', \'' ) + '\'))';
        }

        if (sObjectName == SOBJECT_LEDGERENTRYBREAKOUT) {
        	Id RT_LEDGERENTRY_EXPENSES_ID = recordTypeMap.get( RT_LEDGERENTRY_EXPENSES );
        	Id RT_LEDGERENTRY_ANCILLARY_ID = recordTypeMap.get( RT_LEDGERENTRY_ANCILLARY );
        	Id RT_LEDGERENTRY_COGS_ID = recordTypeMap.get( RT_LEDGERENTRY_COGS );
			List<Id> recordTypeIds = new List<Id>{RT_LEDGERENTRY_EXPENSES_ID, RT_LEDGERENTRY_ANCILLARY_ID, RT_LEDGERENTRY_COGS_ID};
			List<Id> glAccountsToSkip = new List<Id>(glAccountIds);

        	result += ' AND LedgerEntry__r.RecordTypeId IN (\'' + String.join( recordTypeIds, '\', \'' ) + '\') AND (NOT LedgerEntry__r.GLAccount__c IN (\'' + String.join( glAccountsToSkip, '\', \'' ) + '\'))';
        }

        return( result );
    }
    
    /**
     * Represents the relevant info about an object
     **/
    public class ClonableObject {
        /** name of the sobject **/
        public String sObjectName;
        
        /**
         * The where clause to use when querying.
         * NOTE: this is the actual clause, 'WHERE' is added for you only if this is non-null
         **/
        public String whereClause;
        
        //-- fake public fields - used for testing for now. @TODO: set to private when done.
        /** set of immutable fields **/
        public Set<String> immutableFields { public get; private set; }
        /** set of fields that are considered unique external ids - and must be regenerated **/
        public Set<String> uniqueExternalIds { public get; private set; }
        /** map of parent sobject: field that references that object **/
        public Map<String,String> parentObjectFields { public get; private set; }
        /** map of fields by parent object - inverse of parentObjectFields **/
        public Map<String,String> parentFieldObjects { public get; private set; }
        /** query to get all fields from the object - available after parseSchema **/
        public string allQuery { public get; private set; }
        
        /** the list of objects created **/
        public SObject[] objectsCreated { public get; private set; }

        /** the list of original/source objects, conditionally populated **/
        public SObject[] originalObjects { public get; private set; }
        
        /** the group of clonableobjects this should work within **/
        public ClonableObjectGroup clonableGroup { public get; private set; }

        public List<String> fieldsToQuery {get;set;}
        public Map<String,Schema.DescribeFieldResult> fieldMap {get;set;}

        public Map<Id,SObject> originalIdAndClonedObject {get;set;}
        
        /**
         *  current status of the clonable object.
         *  CLONABLE_STATUS_INITIAL -> CLONABLE_STATUS_READY (records are there) -> CLONABLE_STATUS_COMPLETE (inserted)
         **/
        public String status { public get; private set; }
        
        public ClonableObject( String sObjectName, ClonableObjectGroup clonableGroup ){
            this.sObjectName = sObjectName;
            this.whereClause = null;
            this.status = CLONABLE_STATUS_INITIAL;
            
            this.clonableGroup = clonableGroup;
            clonableGroup.addMember( this );
			
            this.uniqueExternalIds = new Set<String>();
            this.parentObjectFields = new Map<String,String>();
            this.parentFieldObjects = new Map<String,String>();
            this.immutableFields = new Set<String>();
            this.allQuery = null;
            this.objectsCreated = new SObject[]{};
            this.originalObjects = new SObject[]{};
            this.fieldsToQuery = new List<String>();
            this.immutableFields.addAll(STANDARD_IMMUTABLE_FIELDS);
            this.fieldMap = new Map<String,Schema.DescribeFieldResult>();
            this.originalIdAndClonedObject = new Map<Id,SObject>();
        }
        
        /**
         * Fills out the clonable object through a describe
         **/
        public void parseSchema(){
            Map<String, Schema.SobjectField> fields = 
                Schema.getGlobalDescribe().get( this.sObjectName ).getDescribe().SObjectType.getDescribe().fields.getMap();
                
            this.allQuery = 'SELECT ' ;
            Boolean isFirstField = true;
                
            Schema.DescribeFieldResult fieldDescribe;
            List<Schema.sObjectType> relatedToList;
            String fieldName, parentName;
            for( Schema.SObjectField field : fields.values() ){
                
                //-- reference: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_fields_describe.htm
                
                //-- NOTE: we don't care whether they are accessible, we want all fields.
                //if( field.getDescribe().isAccessible() ){
                fieldDescribe = field.getDescribe();
                fieldName = fieldDescribe.getName();
                
                if( !this.immutableFields.contains( fieldName ) ){
                    
                    //-- why on earth is the stringBuilder class not available to apex...
                    if( isFirstField ){
                        isFirstField = false;
                    } else {
                        this.allQuery += ', ';
                    }
                    this.allQuery += fieldName;
                    

                    fieldsToQuery.add(fieldName);
                    fieldMap.put(fieldName, fieldDescribe);
                }

                //this.allQuery += String.join(fieldsToQuery, ',');
                
                if( fieldDescribe.isExternalID() && fieldDescribe.isUnique() ){
                    this.uniqueExternalIds.add( fieldName );
                }
                
                if( !LNE_EventCloneUtil.STANDARD_FIELDS.contains( fieldName )){
                    
                    if( !String.isEmpty( fieldDescribe.getRelationshipName() )){
                        System.debug( 'we think this field is a relationship:' + fieldName );
                        relatedToList = fieldDescribe.getReferenceTo();
                        if( relatedToList != null && relatedToList.size() > 0 ){
                            for( Schema.sObjectType relatedToObj: relatedToList){
                                parentName = relatedToObj.getDescribe().getName();
                                this.parentObjectFields.put( parentName, fieldName );
                                this.parentFieldObjects.put( fieldName, parentName );
                            }
                        } else {
                            System.assert( false, 'you should never have a field description name without object to relate to' );
                        }
                    }
                } else {
                    System.debug( '[' + fieldName + '] is a standard field' );
                }
            }
            
            this.allQuery += ' \nFROM ' + this.sObjectName;
        }
        
        public void addParentField( String parentObject, String fieldName ){
            this.parentObjectFields.put( parentObject, fieldName );
            this.parentFieldObjects.put( fieldName, parentObject );
        }
        
        public void addUniqueExternalId( String externalId ){
            this.uniqueExternalIds.add( externalId );
        }
        
        public void addImmutableField( String immutableField ){
            this.immutableFields.add( immutableField );
        }
        public void addImmutableFields( String[] immutableFields ){
            if( immutableFields != null ){
                this.immutableFields.addAll( immutableFields );
            }
        }
        
        /**
         * Retrieves all sObjects to a map based on their id.
         * @see LNE_EventCloneUtil.createWhereClause
         **/
        public Map<Id,SObject> queryRecords(Boolean storeOriginalsInList){
            System.debug( 'within queryRecords' );
            
            Map<Id,SObject> results = new Map<Id,Sobject>();
            
            if( String.isBlank( this.allQuery )){
                throw( new CustomException( ERROR_PARSE_SCHEMA_NOT_CALLED ));
            }
            
            //-- another option to quickly clone is to use trim...
            String query = '' + this.allQuery;
            if( this.whereClause != null ){
                query += '\n WHERE ' + whereClause;
            }
            
            //-- @INVARIANT - the schema has been called at this point, so the query has all the fields
            //-- allowed, relationships to the other objects has been established, and we have a full query
            System.debug( 'query' ); System.debug( query );
            
            SObject[] queryResults = Database.query( query );
            SObject[] clones = new SObject[]{};
            SObject clone;
            if( queryResults != null && queryResults.size() > 0 ){
                for( SObject objectToClone: queryResults ){
                    //-- set all unique identifiers
                    
                    clone = objectToClone.clone( false, true, false, false );
                    if( this.uniqueExternalIds.size() > 0 ){
                        for( String uniqueExternalIdField : this.uniqueExternalIds ){
                            clone.put( uniqueExternalIdField, GET_UUID() );
                        }
                    }
                    
                    results.put( objectToClone.Id, clone );
                    originalIdAndClonedObject.put(objectToClone.Id, clone);

                    if (storeOriginalsInList == true) {
                        originalObjects.add(objectToClone);
                    }
                }
                
                this.objectsCreated = results.values();
                
            } else {
                System.debug( WARNING_NO_RECORDS_RETURNED );
            }
            
            this.status = CLONABLE_STATUS_READY;
            
            //-- @INVARIANT: at this point we know we have records returned,
            //-- and results are packed based on the original id with the cloned record.
            //-- we are returning map of all objects by their original id : new object to replace it.
            
            return( results );
        }
        
        /**
         *  Updates all the parent external ids
         *  @param records (SObject[])
         *  @param oldIdsNewIds (Map<Id,Id>) - map of the old id to the value of the new id.
         **/
        public void updateExternalReferences( SObject[] records, Map<Id,Id> oldIdsNewIds ){
            System.assert( oldIdsNewIds != null, 'If calling to update external references, you need to have a list of recferences to update with' );
            
            //-- do not wrap in a try throw catch, if you're trying to set other objects, we wanna know about it.
            if( records != null && records.size() > 0 ){
                if( this.parentFieldObjects.size() > 0 ){
                    Id oldParentValue;
                    Id newParentValue;
                    
                    System.debug( 'parentFieldObjects' ); System.debug( this.parentFieldObjects.keySet() );
                    
                    for( SObject record : records ){
                        for( String parentFieldName : this.parentFieldObjects.keySet() ){
                            oldParentValue = (Id)(record.get( parentFieldName ));
                            System.debug( 'attempting to update:' + parentFieldName + '=' + oldParentValue );
                            if( oldIdsNewIds.containsKey( oldParentValue )){
                                newParentValue = oldIdsNewIds.get( oldParentValue );
                                record.put( parentFieldName, newParentValue );
                                System.debug( 'updated parent:' + parentFieldName + ' from:' + oldParentValue + ' to ' + newParentValue );
                            } else {
                                System.debug( WARNING_PARENT_ID_NOT_FOUND + ':' + parentFieldName + ':' + oldParentValue );
                            }
                        }
                    }
                }
            }
        }
        
        /**
         * checks and performs an upsert if the clonable's group is ready.
         * @param oldIdsNewIds Map<Id,Id>
         * @return (Boolean) - whether the group is ready and an insert was attempted.
         **/
        public boolean attemptInsert( Map<Id,Id> oldIdsNewIds ){
        	System.assert( this.clonableGroup != null, 'For now, every clonable must belong to a clonable group' );
        	//-- although, the alternative is to just create a new clonable group at this point, add it, and run.
        	
        	return( this.clonableGroup.groupUpdate( oldIdsNewIds ) );
        }
    }
    
    /**
     * Represents a group of ClonableObjects.
     **/
    public class ClonableObjectGroup {
    	
    	/** the list of clonable objects within the group **/
    	public ClonableObject[] members { public get; private set; }
    	
    	public ClonableObjectGroup(){
    		this.members = new ClonableObject[]{};
    	}
    	
    	public void addMember( ClonableObject clonable ){
    		this.members.add( clonable );
    	}
    	
    	/**
    	 * Whether all the members in the group have run
    	 * @return (Boolean)
    	 **/
    	public Boolean isGroupReady(){
    		for( ClonableObject clonable : this.members ){
    			System.debug( 'checking clonableStatus:' + clonable.sObjectName + ':' + clonable.status );
    			if( !CLONABLE_STATUS_READY.equals( clonable.status )){
    				return( false );
    			}
    		}
    		return( true );
    	}
    	
    	/**
    	 * Performs a group insert
    	 * @return Boolean - whether successful (true) or not (false)
         * @param oldIdsNewIds (Map<Id,Id>)
         **/
        public Boolean groupUpdate( Map<Id,Id> oldIdsNewIds ){
    		Boolean isSuccessful = false;
    		
    		if( isGroupReady() ){
    			SObject[] readyList = new SObject[]{};
    			
    			for( ClonableObject clonable : this.members ){
    				readyList.addAll( clonable.objectsCreated );
    			}
    			
    			//try {
    				insert readyList;
    			//} catch( Exception err ){} // we want to know any errors currently.
    			
    			//-- translate all objects as they were created
    			for( SObject clonedObject : readyList ){
	                oldIdsNewIds.put( clonedObject.getCloneSourceId(), clonedObject.Id );
	            }
    			
    			for( ClonableObject clonable2 : this.members ){
    				clonable2.status = CLONABLE_STATUS_COMPLETE;
    			}
    			
    			isSuccessful = true;
    		}
    		return( isSuccessful );
    	}
    }
    
    /**
     * Prepares a clonable object within a map of clonable objects
     * @param orderedClonableObjects ClonableObject[] - ordered list of clonable objects.
     * @param clonableGroup (ClonableObjectGroup) - the group that this clonable object belongs to.
     * @param sObjectName (String)
     * @param whereClause (String) - the clause to use when querying for the record.
     * @return orderedClonableObjects
     **/
    public static ClonableObject[] addClonableSchema( ClonableObject[] orderedClonableObjects, ClonableObjectGroup clonableGroup, String sObjectName, String whereClause ){
        if( orderedClonableObjects == null ){
            orderedClonableObjects = new ClonableObject[]{};
        }
        
        ClonableObject target = new ClonableObject( sObjectName, clonableGroup );
        target.whereClause = whereClause;
        target.parseSchema();
        orderedClonableObjects.add( target );
        
        return( orderedClonableObjects );
    }
    
    /**
     *  Converts an ordered list of clonable objects into a map by sObjectName
     *  @param clonableObjects ClonableObject[]
     *  @return Map<String,ClonableObject> - sObject name : last clonable object with that name
     **/
    public static Map<String,ClonableObject> createClonableMap( ClonableObject[] clonableObjects ){
        Map<String,ClonableObject> results = new Map<String,ClonableObject>();
        
        if( clonableObjects != null && clonableObjects.size() > 0 ){
            for( ClonableObject cObject : clonableObjects ){
                results.put( cObject.sObjectName, cObject );
            }
        }
        
        return( results );
    }
    
    /**
     * Method to create a large list of clonable object schemas
     * (often helpful for testing)
     * @param sObjectNames (string[]) - list of sobjects to create clonable objects for
     * @return Map<String,ClonableObject> - map of the name of the sobject by the clonable object parsed schema object
     **/
    public static Map<String,ClonableObject> createClonableMap( String[] sObjectnames ){
        Map<String,ClonableObject> results = new Map<String,ClonableObject>();
        
        ClonableObject target;
        ClonableObjectGroup clonableGroup = new ClonableObjectGroup();
        
        if( sObjectNames != null && sObjectNames.size() > 0 ){
            for( String sObjectName : sObjectNames ){
                target = new ClonableObject( sObjectName, clonableGroup );
                target.parseSchema();
                results.put( sObjectName, target );
            }
        }
        
        return( results );
    }

    private static RecordProcessor getRecordProcessor(String name) {
    	RecordProcessor processor;

    	if (String.isNotBlank(name)) {
    		Type t = Type.forName('LNE_EventCloneUtil.'+ name.remove('__c') + 'Processor');

    		if (t != null) {
    			processor = (RecordProcessor)t.newInstance();
    		}
    	}

    	return processor;
    }
    
    class CustomException extends Exception {
    }

    public abstract class RecordProcessor {
    	public abstract void processRecords(EventCloneParams params, ClonableObject clonable);
    	public abstract void processRecordsAfterInsert(EventCloneParams params, ClonableObject clonable, ClonableObject clonableTicketScales);

    	protected void setFieldToBlank(sObject so, Schema.DescribeFieldResult fieldDescribe) {
	        if (fieldDescribe.getType() == Schema.DisplayType.Boolean) {
	            so.put(fieldDescribe.getName(), false);
	        } else {
	            so.put(fieldDescribe.getName(), null);
	        }
	    }

	    protected void setEventIdStageType(sObject so) {
	    	if (so.get('StageType__c') != null && so.get('Event__c') != null) {
	    		String stageType = (String)so.get('StageType__c');
	    		String eventId = (String)so.get('Event__c');
	    		String newEventIDStageType = ((String)eventId).substring(0,15) + DATA_DELIMITER + stageType;

	    		so.put('EventIDStageType__c', newEventIDStageType);

	    		if (so.getSObjectType() == Schema.TicketScale__c.SObjectType && so.get('EventDateTime__c') != null) {
	    			String eventDateTimeId = (String)so.get('EventDateTime__c');

					so.put('EventIDStageTypeDateTime__c', newEventIDStageType + DATA_DELIMITER + ((String)eventDateTimeId).substring(0,15));
	    		}
	    	}
	    }

	    protected void updateTicketScaleList(sObject so, Map<Id,SObject> originalAndClonedIds) {
    		if (so.get('TicketScaleList__c') != null) {
    			String ticketScaleList = (String)so.get('TicketScaleList__c');
    			if (String.isNotBlank(ticketScaleList)) {
	                List<String> ids = ticketScaleList.split(ESCAPED_DATA_DELIMITER);
	                if (ids.size() > 0) {
	                	Set<String> newIDs = new Set<String>();

	                    for (String s : ids) {
	                        if (String.isNotBlank(s)) {
	                            String newID;

	                            if (originalAndClonedIds.get(s) != null && originalAndClonedIds.get(s).Id != null) {
	                                newID = originalAndClonedIds.get(s).Id;
	                            } else if (originalAndClonedIds.get(s.substring(0,15)) != null && originalAndClonedIds.get(s.substring(0,15)).Id != null) {
	                                newID = originalAndClonedIds.get(s.substring(0,15)).Id;
	                            }

	                            if (String.isNotBlank(newID)) {
	                                newIDs.add(newID.substring(0,15));
	                            }
	                        }
	                    }

	                    String newTicketScaleList = String.join(new List<String>(newIDs), DATA_DELIMITER);
	                    so.put('TicketScaleList__c', newTicketScaleList);
	                }
	            }
    		}
    	}
    }

    public class EventProcessor extends RecordProcessor {

    	public override void processRecords(EventCloneParams params, ClonableObject clonable) {
    		ObjectFieldDefaults fieldDefaults = params.eventDefaults;

    		if (clonable.objectsCreated != null && clonable.objectsCreated.size() > 0) {
    			sObject event = clonable.objectsCreated[0];

    			if (fieldDefaults != null) {
		            for (String field : fieldDefaults.fieldsToNull) {
		                event.put(field, null);
		            }

		            for (String field : fieldDefaults.fieldsToSetToFalse) {
		                event.put(field, false);
		            }
		        }

		        event.put('EventName__c', params.eventName);
            	event.put('Status__c', params.status);
            	event.put('Promoter__c', params.ownerId);
            	event.put('Office__c', params.officeId);
                event.put('Venue__c', params.venueId);
		        event.put('CloningInProcess__c', true);

                if (String.isNotBlank(params.ownerId)) {
                    event.put('OwnerId', params.ownerId);
                }
    		}
    	}

    	public override void processRecordsAfterInsert(EventCloneParams params, ClonableObject clonable, ClonableObject clonableTicketScales) {}
    }

    public class EventDateTimeProcessor extends RecordProcessor {

    	public override void processRecords(EventCloneParams params, ClonableObject clonable) {
    		calculateEventDates(params, clonable);

            for (sObject so : clonable.objectsCreated) {
                resetFields(so, params, clonable);
            }
    	}

    	public override void processRecordsAfterInsert(EventCloneParams params, ClonableObject clonable, ClonableObject clonableTicketScales) {}

    	private void calculateEventDates(EventCloneParams params, ClonableObject clonable) {
	        List<EventDateTime__c> sortedOriginals = getSortedEventDateTimes(clonable.originalObjects);
	        List<EventDateTime__c> sortedClones = getSortedEventDateTimes(clonable.objectsCreated);

	        if (sortedClones.size() > 0) {
	            EventDateTime__c firstEventDateTime_Cloned = sortedClones[0];
	            EventDateTime__c firstEventDateTime_Original = sortedOriginals.size() > 0 ? sortedOriginals[0] : new EventDateTime__c();

	            if (clonable.objectsCreated != null && firstEventDateTime_Cloned != null) {
	                firstEventDateTime_Cloned.EventDate__c = params.eventDate;
	                firstEventDateTime_Cloned.EventYear__c = params.eventYear;

	                if (clonable.objectsCreated.size() > 1) {
	                    Date selectedEventDate = params.eventDate;
	                    Date originalEventDate = firstEventDateTime_Original.EventDate__c;

	                    if (selectedEventDate != null && originalEventDate != null) {
	                        Integer daysBetween = originalEventDate.daysBetween(selectedEventDate);

	                        for (Integer i = 1; i < sortedClones.size(); i++) {
	                            EventDateTime__c edt = (EventDateTime__c)sortedClones[i];

	                            if (edt.EventDate__c != null) {
	                                edt.EventDate__c = edt.EventDate__c.addDays(daysBetween);
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    }

	    private List<EventDateTime__c> getSortedEventDateTimes(List<sObject> records) {
	        List<EventDateTime__c> toReturn = new List<EventDateTime__c>();

	        if (records != null && records.size() > 0) {
	            List<EventDateTime__c> dateTimes = (List<EventDateTime__c>)records;

	            List<LNE_EventDateTimeUtil_T.EventDateTime> listToSort = new List<LNE_EventDateTimeUtil_T.EventDateTime>();                                        
	                                           
	            for (EventDateTime__c edt : dateTimes) {
	                listToSort.add(new LNE_EventDateTimeUtil_T.EventDateTime(edt));
	            }
	            
	            listToSort.sort();

	            for (LNE_EventDateTimeUtil_T.EventDateTime edt : listToSort) {
	                toReturn.add(edt.edt);
	            }
	        }

	        return toReturn;
	    }

	    private void resetFields(sObject so, EventCloneParams params, ClonableObject co) {
	        ObjectFieldDefaults fieldDefaults = params.childObjectDefaults.get(SOBJECT_EVENTDATETIME);

	        for (String field : co.fieldsToQuery) {
	            if (fieldDefaults.fieldsToLeavePopulated.contains(field) == false && co.fieldMap.get(field).isCreateable()) {
	                setFieldToBlank(so, co.fieldMap.get(field));
	            }
	        }

	        so.put('OwnerId', params.ownerId);
	    }
    }

    public class EventTicketAgencyProcessor extends RecordProcessor {

    	public override void processRecords(EventCloneParams params, ClonableObject clonable) {
    		ObjectFieldDefaults fieldDefaults = params.childObjectDefaults.get(SOBJECT_EVENTTICKETAGENCY);

    		for (sObject so : clonable.objectsCreated) {
    			for (String field : clonable.fieldsToQuery) {
		            if (fieldDefaults.fieldsToLeavePopulated.contains(field) == false && clonable.fieldMap.get(field).isCreateable()) {
		                setFieldToBlank(so, clonable.fieldMap.get(field));
		            }
		        }

		        so.put('BypassValidation__c', true);
    		}
    	}

    	public override void processRecordsAfterInsert(EventCloneParams params, ClonableObject clonable, ClonableObject clonableTicketScales) {}
    }

    public class TicketScaleProcessor extends RecordProcessor {

    	public override void processRecords(EventCloneParams params, ClonableObject clonable) {
    		List<String> fieldsToBlank = new List<String>{'ProjectedPaidTickets__c','AverageLiftPerTicket__c','LiftBeforeFee__c'};

    		for (sObject so : clonable.objectsCreated) {
    			for (String field : fieldsToBlank) {
		            setFieldToBlank(so, clonable.fieldMap.get(field));
		        }

                so.put('ProjectedPaidTickets__c', 0);
		        so.put('StageType__c', 'Plan');
		        so.put('OwnerId', params.ownerId);

		        setEventIdStageType(so);
    		}
    	}

    	public override void processRecordsAfterInsert(EventCloneParams params, ClonableObject clonable, ClonableObject clonableTicketScales) {}
    }

    public class DeductionProcessor extends RecordProcessor {

    	public override void processRecords(EventCloneParams params, ClonableObject clonable) {
    		for (sObject so : clonable.objectsCreated) {
		        so.put('StageType__c', 'Plan');
		        so.put('OwnerId', params.ownerId);

		        setEventIdStageType(so);
    		}
    	}

    	public override void processRecordsAfterInsert(EventCloneParams params, ClonableObject clonable, ClonableObject clonableTicketScales) {
    		for (sObject so : clonable.objectsCreated) {
		        updateTicketScaleList(so, clonableTicketScales.originalIdAndClonedObject);
    		}
    	}
    }

    public class LedgerEntryProcessor extends RecordProcessor {

    	public override void processRecords(EventCloneParams params, ClonableObject clonable) {
    		ObjectFieldDefaults fieldDefaults = params.childObjectDefaults.get(SOBJECT_LEDGERENTRY);

    		for (sObject so : clonable.objectsCreated) {
		        so.put('OwnerId', params.ownerId);

		        if (fieldDefaults != null) {
		            for (String field : fieldDefaults.fieldsToNull) {
		                setFieldToBlank(so, clonable.fieldMap.get(field));
		            }
		        }
    		}
    	}

    	public override void processRecordsAfterInsert(EventCloneParams params, ClonableObject clonable, ClonableObject clonableTicketScales) {
    		for (sObject so : clonable.objectsCreated) {
		        updateTicketScaleList(so, clonableTicketScales.originalIdAndClonedObject);
    		}
    	}
    }

    public class LedgerEntryBreakoutProcessor extends RecordProcessor {

    	public override void processRecords(EventCloneParams params, ClonableObject clonable) {
    		ObjectFieldDefaults fieldDefaults = params.childObjectDefaults.get(SOBJECT_LEDGERENTRYBREAKOUT);

    		for (sObject so : clonable.objectsCreated) {
		        if (fieldDefaults != null) {
		            for (String field : fieldDefaults.fieldsToNull) {
		                setFieldToBlank(so, clonable.fieldMap.get(field));
		            }
		        }
    		}
    	}

    	public override void processRecordsAfterInsert(EventCloneParams params, ClonableObject clonable, ClonableObject clonableTicketScales) {
    		for (sObject so : clonable.objectsCreated) {
		        updateTicketScaleList(so, clonableTicketScales.originalIdAndClonedObject);
    		}
    	}
    }

    public class EventCloneParams {
        public ObjectFieldDefaults eventDefaults;
        public Map<String, ObjectFieldDefaults> childObjectDefaults;

        public String eventName {get;set;}
        public String status {get;set;}
        public String ownerId {get;set;}
        public Date eventDate {get;set;}
        public String eventYear {get;set;}
        public String artistId {get;set;}
        public String officeId {get;set;}
        public String venueId {get;set;}

        private Set<String> eventFieldsToNull = new Set<String>{
            'NumberOfUpgrades__c',
            'ActualDropCount__c',
            'Artists__c',
            'ArtistSettlementCompletedBy__c',
            'BoxOfficeImportCompletedBy__c',
            'BPCIntegrationStatus__c',
            'CatereaseEvent__c',
            'CatereaseId__c',
            'DidtheShowGointoPercentage__c',
            'EventRecapCompletedBy__c',
            'FlashCompletedBy__c',
            'FlashIntegrationStatus__c',
            'GrossLawnCapacity__c',
            'GrossReservedCapacity__c',
            'IntegrationStatus__c',
            'LawnComps__c',
            'LawnKills__c',
            'LawnPaidAttendance__c',
            'MetricsCompletedBy__c',
            'OracleExportCompletedBy__c',
            'OracleProjectId__c',
            'PrevioulsyForecastedLiftBeforeTaxes__c',
            'PreviouslyForecastedProjPaidTickets__c',
            'PublicOnSale__c',
            'ReservedComps__c',
            'ReservedKills__c',
            'ReservedPaidAttendance__c',
            'SettlementAdjustedGross__c',
            'SettlementArtistShare__c',
            'SettlementArtistSuppliedSL__c',
            'SettlementAverageTicketPrice__c',
            'SettlementBackendPercentage__c',
            'SettlementDealCalculation__c',
            'SettlementDealType__c',
            'SettlementDeductions__c',
            'SettlementGross__c',
            'SettlementGrossSales__c',
            'SettlementGuarantee__c',
            'SettlementHouseNut__c',
            'SettlementNetGross__c',
            'SettlementNetPot__c',
            'SettlementNotes__c',
            'SettlementOtherTalentAmount__c',
            'SettlementPaidTickets__c',
            'SettlementPlatinumLift__c',
            'SettlementPromoterEarnings__c',
            'SettlementRecapCompletedBy__c',
            'SettlementSplitPoint__c',
            'SettlementToBeSharedAmount__c',
            'SettlementTotalSupportActExpenses__c',
            'Tour__c'
        };

        private Set<String> eventFieldsToSetToFalse = new Set<String>{
            'HidePreviouslyForecastedLiftBfrTxs__c',
            'HidePreviouslyForecastedProjPdTkt__c',
            'ArtistSettlementComplete__c',
            'BoxOfficeImportComplete__c',
            'EventCancelled__c',
            'EventRecapComplete__c',
            'ExcludefromOracleFinancialUpdates__c',
            'FlashComplete__c',
            'MetricsComplete__c',
            'OracleExportComplete__c',
            'SettlementRecapComplete__c',
            'SettlementStarted__c',
            'UsingTicketFeed__c'
        };

        public EventCloneParams(String n, String o) {
            this.eventName = n;
            this.status = 'Draft';
            this.ownerId = o;

            eventDefaults = new ObjectFieldDefaults('Event__c');

            populateFieldMap();
        }

        private void populateFieldMap() {
            eventDefaults.fieldsToNull = eventFieldsToNull;
            eventDefaults.fieldsToSetToFalse = eventFieldsToSetToFalse;

            childObjectDefaults = new Map<String, ObjectFieldDefaults>();

            ObjectFieldDefaults eventDateTime = new ObjectFieldDefaults('EventDateTime__c');
            childObjectDefaults.put('EventDateTime__c', eventDateTime);
            eventDateTime.fieldsToLeavePopulated.add('Event__c');
            eventDateTime.fieldsToLeavePopulated.add('OwnerId');
            eventDateTime.fieldsToLeavePopulated.add('EventDate__c');
            eventDateTime.fieldsToLeavePopulated.add('EventYear__c');
            eventDateTime.fieldsToLeavePopulated.add('StartTime__c');

            ObjectFieldDefaults eventTicketAgency = new ObjectFieldDefaults('EventTicketAgency__c');
            childObjectDefaults.put('EventTicketAgency__c', eventTicketAgency);
            eventTicketAgency.fieldsToLeavePopulated.add('TicketAgency__c');
            eventTicketAgency.fieldsToLeavePopulated.add('EventDateTime__c');

            Set<String> commonLedgerFieldsToNull = new Set<String>{
	            'ArtistAmount__c',
				'ArtistAmountRate__c',
				'CurrentFlash__c',
				'ExternalId__c',
				'FlashCapacityRange__c',
				'FlashOverridden__c',
				'FlashRateAmount__c',
				'FlashRateType__c',
				'LNTouringAmount__c',
				'LNTouringAmountRate__c',
				'ProjectionAmount__c',
				'PromoterAmount__c',
				'PromoterAmountRate__c',
				'ResponsibleifnotLNE__c',
				'Settlement__c',
				'SettlementNotes__c',
				'SettlementRateType__c',
				'VenueAmount__c',
				'VenueAmountRate__c'
	        };

            ObjectFieldDefaults legerEntry = new ObjectFieldDefaults('LedgerEntry__c');
            childObjectDefaults.put('LedgerEntry__c', legerEntry);
	        legerEntry.fieldsToNull = commonLedgerFieldsToNull.clone();
	        legerEntry.fieldsToNull.add('FinalForecast__c');

	        ObjectFieldDefaults legerEntryBreakout = new ObjectFieldDefaults('LedgerEntryBreakout__c');
            childObjectDefaults.put('LedgerEntryBreakout__c', legerEntryBreakout);
	        legerEntry.fieldsToNull = commonLedgerFieldsToNull.clone();
        }
    }

    public class ObjectFieldDefaults {
        public String sObjectName {get;set;}
        public Set<String> fieldsToNull {get;set;}
        public Set<String> fieldsToSetToFalse {get;set;}
        public Set<String> fieldsToLeavePopulated {get;set;}
        public Map<String, String> stringsToDefault {get;set;}

        public ObjectFieldDefaults(String n) {
            this.sObjectName = n;
            fieldsToNull = new Set<String>();
            fieldsToSetToFalse = new Set<String>();
            fieldsToLeavePopulated = new Set<String>();
            stringsToDefault = new Map<String, String>();
        }
    }

    public class ClonableDescription {
    	String sObjectName;
    	String whereClause;

    	public ClonableDescription(String n, String w) {
    		this.sObjectName = n;
    		this.whereClause = w;
    	}
    }
}