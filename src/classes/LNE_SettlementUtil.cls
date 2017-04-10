public with sharing class LNE_SettlementUtil {

	private static final DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
	private static final String STAGE_TYPE_PLAN = 'Plan';
	private static final String STAGE_TYPE_PROJECTION = 'Projection';
	private static final String STAGE_TYPE_SETTLEMENT = 'Settlement';

	public static final List<String> ledgerFieldsToErase = new List<String>{ 'PromoterAmount__c',
																			 'PromoterRateType__c',
																			 'PromoterAmountRate__c',
																			 'PromoterMin__c',
																			 'PromoterMax__c',
																			 'ArtistAmount__c',
																			 'ArtistRateType__c',
																			 'ArtistAmountRate__c',
																			 'ArtistMin__c',
																			 'ArtistMax__c',
																			 'VenueAmount__c',
																			 'VenueRateType__c',
																			 'VenueAmountRate__c',
																			 'VenueMin__c',
																			 'VenueMax__c',
																			 'LNTouringAmount__c',
																			 'LNTouringRateType__c',
																			 'LNTouringAmountRate__c',
																			 'LNTouringMin__c',
																			 'LNTouringMax__c',
																			 'SettlementNotes__c'
																		   };

	public static void startSettlementProcess(Id eventId) {
		LNE_FinancialCalculator.currentlyRunning = true;

		List<sObject> toInsert = new List<sObject>();
		Event__c event = [SELECT SettlementStarted__c, BookingHouseNut__c FROM Event__c WHERE Id = :eventId];

		event.SettlementStarted__c = true;
		event.SettlementHouseNut__c = event.BookingHouseNut__c;

		update event;

		Set<String> deductionFieldNames = getFieldNamesForObject(Deduction__c.sObjectType.getDescribe());

		String queryFieldNames = String.join(new List<String>(deductionFieldNames), ',');
		String deductionQuery = 'SELECT ';
		deductionQuery += queryFieldNames;
		deductionQuery += ' FROM Deduction__c';
		deductionQuery += ' WHERE Event__c = :eventId';
		deductionQuery += ' AND StageType__c = :STAGE_TYPE_PROJECTION';

		List<Deduction__c> deductions = Database.query(deductionQuery);
	    
	    for (Deduction__c d : deductions) {
	        Deduction__c newDeduction = d.clone(false, true, false, false);
	        newDeduction.StageType__c = STAGE_TYPE_SETTLEMENT;
	        newDeduction.EventIDStageType__c = ((String)d.Event__c).substring(0,15) + DATA_SETTINGS.CombinedKeyDelimiter__c + newDeduction.StageType__c;
	        newDeduction.TicketScaleList__c = null;
	        toInsert.add(newDeduction);
	    }

	    Id artistRTID = Schema.SObjectType.Deal__c.getRecordTypeInfosByName().get('Artist').getRecordTypeId();
		Set<String> dealFieldNames = getFieldNamesForObject(Deal__c.sObjectType.getDescribe());
		Set<String> bonusDetailFieldNames = getFieldNamesForObject(BonusDetail__c.sObjectType.getDescribe());
		Set<String> artistRetroStepUpDetailFieldNames = getFieldNamesForObject(ArtistRetroStepUpDetail__c.sObjectType.getDescribe());
		Set<String> talentOverheadFieldNames = getFieldNamesForObject(TalentOverhead__c.sObjectType.getDescribe());

		String dealQueryFieldNames = String.join(new List<String>(dealFieldNames), ',');
		String bonusDetailQueryFieldNames = String.join(new List<String>(bonusDetailFieldNames), ',');
		String artistRetroStepUpDetailQueryFieldNames = String.join(new List<String>(artistRetroStepUpDetailFieldNames), ',');
		String talentOverheadQueryFieldNames = String.join(new List<String>(talentOverheadFieldNames), ',');
		String dealQuery = 'SELECT ';
		dealQuery += dealQueryFieldNames;
		dealQuery += ', (SELECT ';
		dealQuery += bonusDetailQueryFieldNames;
		dealQuery += ' FROM BonusDetails__r)';
		dealQuery += ', (SELECT ';
		dealQuery += artistRetroStepUpDetailQueryFieldNames;
		dealQuery += ' FROM Artist_Retro_Step_Up_Details__r)';
		dealQuery += ', (SELECT ';
		dealQuery += talentOverheadQueryFieldNames;
		dealQuery += ' FROM Talent_Overhead__r)';
		dealQuery += ' FROM Deal__c';
		dealQuery += ' WHERE Event__c = :eventId';
		dealQuery += ' AND RecordTypeId = :artistRTID';
		dealQuery += ' AND StageType__c = :STAGE_TYPE_PLAN';


		List<Deal__c> deals = Database.query(dealQuery);
		List<DealWrapper> clonedDeals = new List<DealWrapper>();
	    
	    for (Deal__c d : deals) {
	    	DealWrapper dw = new DealWrapper(d);
	        Deal__c newDeal = d.clone(false, true, false, false);
	        newDeal.StageType__c = STAGE_TYPE_SETTLEMENT;
	        toInsert.add(newDeal);
	        dw.clonedDeal = newDeal;
	        clonedDeals.add(dw);
	    }

	    insert toInsert;

	    List<sObject> childRecordsToInsert = new List<sObject>();

	    for (DealWrapper dw : clonedDeals) {
	    	for (BonusDetail__c r : dw.originalDeal.BonusDetails__r) {
	    		BonusDetail__c newR = r.clone(false, true, false, false);
	    		newR.Deal__c = dw.clonedDeal.Id;
	    		childRecordsToInsert.add(newR);
	    	}

	    	for (ArtistRetroStepUpDetail__c r : dw.originalDeal.Artist_Retro_Step_Up_Details__r) {
	    		ArtistRetroStepUpDetail__c newR = r.clone(false, true, false, false);
	    		newR.Deal__c = dw.clonedDeal.Id;
	    		childRecordsToInsert.add(newR);
	    	}

	    	for (TalentOverhead__c r : dw.originalDeal.Talent_Overhead__r) {
	    		TalentOverhead__c newR = r.clone(false, true, false, false);
	    		newR.Deal__c = dw.clonedDeal.Id;
	    		childRecordsToInsert.add(newR);
	    	}
	    }

	    insert childRecordsToInsert;

	    LNE_FinancialCalculator.currentlyRunning = false;
	    LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(eventId);
        LNE_FinancialCalculator.checkIfCanRunCalculations();
	}

	public static void restartSettlement(Id eventId) {
		LNE_FinancialCalculator.currentlyRunning = true;

		List<sObject> toDelete = new List<sObject>();
		toDelete.addAll(((List<sObject>)[SELECT Id FROM TicketScale__c WHERE Event__c = :eventId AND StageType__c = :STAGE_TYPE_SETTLEMENT]));
		toDelete.addAll(((List<sObject>)[SELECT Id FROM Deduction__c WHERE Event__c = :eventId AND StageType__c = :STAGE_TYPE_SETTLEMENT]));
		toDelete.addAll(((List<sObject>)[SELECT Id FROM Deal__c WHERE Event__c = :eventId AND StageType__c = :STAGE_TYPE_SETTLEMENT]));

		delete toDelete;

        Set<Id> allLedgerEntryIds = new Set<Id>();
		List<sObject> allLedgers = new List<SObject>();
		for( LedgerEntry__c foundLedgerEntry : [SELECT Id FROM LedgerEntry__c WHERE Event__c = :eventId] ){
		    allLedgers.add( foundLedgerEntry );
		    allLedgerEntryIds.add( foundLedgerEntry.Id );
		}
		for( LedgerEntryBreakout__c foundLEBreakout : [SELECT Id FROM LedgerEntryBreakout__c WHERE LedgerEntry__c IN :allLedgerEntryIds ] ){
		    allLedgers.add( foundLEBreakout );
		}
		
		for (sObject so : allLedgers) {
			for (String fieldName : ledgerFieldsToErase) {
				so.put(fieldName, null);
			}
		}

		for (sObject so : allLedgers) {
			for (String fieldName : ledgerFieldsToErase) {
				so.put(fieldName, null);
			}
		}

		update allLedgers;

		startSettlementProcess(eventId);
	}

	private static Set<String> getFieldNamesForObject(Schema.DescribeSObjectResult objectDescribe) {
		Map<String, Schema.SObjectField> objectFields = objectDescribe.fields.getMap();
		Set<String> fieldNames = new Set<String>();

		for(Schema.sObjectField field : objectFields.values()){
			Schema.DescribeFieldResult dfr = field.getDescribe();
			if (dfr.isCreateable()) {
				fieldNames.add(dfr.getName());
			}
		}

		return fieldNames;
	}

	public class DealWrapper {
		public Deal__c originalDeal {get;set;}
		public Deal__c clonedDeal {get;set;}

		public DealWrapper(Deal__c d) {
			originalDeal = d;
		}
	}
}