/**
*  Class that provides functionality for LNE_SelectAncillaryCOGSEntries.page
*
*  @author Brandon Robins <brobins@salesforce.com>
*
**/
public class LNE_SelectAncillaryCOGSEntries {
	static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';
	static final String RT_COGS = 'LedgerEntry__c.COGS';
	static final String RT_PROMOTEDSHOW = 'Event__c.PromotedShow';
    static final String RT_RENTAL = 'Event__c.Rental';
	static final String PARAM_EVENT_ID = 'event_id';

	public String eventId {get;set;}
	public String previousSelectedEntriesJson {get;set;}
	public String revenueExpenseEntriesJson {get;set;}
	public String selectedEntriesJson {get;set;}
	public String saveSelectedRevenuesExpensesSuccess {get;set;}
	
	private List<Id> previousSelectedGLAccountIds {get;set;}
	
	Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
		new String[]{ RT_Ancillary, RT_COGS, RT_PROMOTEDSHOW, RT_RENTAL  }
	);
	
	Id RT_Ancillary_ID = recordTypeMap.get(RT_Ancillary);
	Id RT_COGS_ID = recordTypeMap.get(RT_COGS);
    Id RT_PROMOTEDSHOW_ID = recordTypeMap.get( RT_PROMOTEDSHOW );
    Id RT_RENTAL_ID = recordTypeMap.get( RT_RENTAL );
	
	public LNE_SelectAncillaryCOGSEntries() {
		eventId = ApexPages.currentPage().getParameters().get( PARAM_EVENT_ID );
		previousSelectedGLAccountIds = new List<Id>();
		getGLAccountListGroupedByCategory();
	}
	
	private void addLedgerEntries(List<Id> glAccountIds, String glAccountRecordType) {
		List<LedgerEntry__c> ledgerEntries = new List<LedgerEntry__c>();
		
		if (glAccountRecordType == 'Ancillary') {
			for (Id accountId : glAccountIds) {
				ledgerEntries.add(new LedgerEntry__c(
					GLAccount__c = accountId,
					Event__c = eventId,
					RecordTypeId = RT_Ancillary_ID
				));
			}
		} else if (glAccountRecordType == 'COGS') {
			for (Id accountId : glAccountIds) {
				ledgerEntries.add(new LedgerEntry__c(
					GLAccount__c = accountId,
					Event__c = eventId,
					RecordTypeId = RT_COGS_ID
				));
			}
		}

		insert ledgerEntries;
	}
	
	private void getGLAccountListGroupedByCategory() {
		List<GLAccount__c> expenseEntries = new List<GLAccount__c>();
		List<GLAccountWrapper> ancillaryWrapperList = new List<GLAccountWrapper>();
		List<GLAccountWrapper> cogsWrapperList = new List<GLAccountWrapper>();
		
		List<GLAccount__c> ancillariesList = new List<GLAccount__c>();
		//ancillariesList = [SELECT Name, Category__c, CategorySort__c, GLCode__c, Type__c FROM GLAccount__c WHERE Type__c = 'Ancillary' AND AvailableForForecast__c = true];
		
		// US751 - build dynamic soql for ancillaries and check for rental vs promoted based on event recordtype.
		String additionalFilter = '';
		if(eventId != null){
			List<Event__c> eventList = [Select Id, RecordTypeId, RentalBuildOption__c from Event__c where Id = :eventId];
			if(eventList != null && !eventList.isEmpty()){
				Event__c event = eventList[0];
				if(event.RecordTypeId == RT_PROMOTEDSHOW_ID){
					additionalFilter = ' AND ApplyToPromotedEvent__c = true ';
				}else if(event.RecordTypeId == RT_RENTAL_ID){
					if(event.RentalBuildOption__c == 'Build Using Rental Accounts' ){
						additionalFilter = ' AND ApplyToRentalEvent__c = true ';
					}else if(event.RentalBuildOption__c == 'Build as a Promoted Show'){
						additionalFilter = ' AND ApplyToPromotedEvent__c = true ';
					}
				}
			}
		}
		String ancillariesSOQL = 'SELECT Name, Category__c, CategorySort__c, GLCode__c, Type__c FROM GLAccount__c'
									+ ' WHERE Type__c = \'Ancillary\' AND AvailableForForecast__c = true '
									+ additionalFilter;
		ancillariesList = Database.Query(ancillariesSOQL);

		for (GLAccount__c account : ancillariesList) {
			ancillaryWrapperList.add(new GLAccountWrapper(account));
		}
		
		ancillaryWrapperList.sort();
		
		for (GLAccountWrapper glAccountWrapper : ancillaryWrapperList) {
			expenseEntries.add(glAccountWrapper.glAccount);
		}
		
		List<GLAccount__c> cogsList = new List<GLAccount__c>();
		//cogsList = [SELECT Name, Category__c, CategorySort__c, GLCode__c, Type__c FROM GLAccount__c WHERE Type__c = 'COGS' AND AvailableForForecast__c = true];
		String cogsSOQL = 'SELECT Name, Category__c, CategorySort__c, GLCode__c, Type__c FROM GLAccount__c'
									+ ' WHERE Type__c = \'COGS\' AND AvailableForForecast__c = true '
									+ additionalFilter;
		cogsList = Database.Query(cogsSOQL);

		for (GLAccount__c account : cogsList) {
			cogsWrapperList.add(new GLAccountWrapper(account));
		}
		
		cogsWrapperList.sort();
		
		for (GLAccountWrapper glAccountWrapper : cogsWrapperList) {
			expenseEntries.add(glAccountWrapper.glAccount);
		}
		
		revenueExpenseEntriesJson = System.JSON.serialize(expenseEntries);
	}
	
	private void removeLedgerEntries(List<Id> glAccountIds) {
		List<LedgerEntry__c> ledgerEntries = [SELECT Id FROM LedgerEntry__c WHERE GLAccount__c IN :glAccountIds AND Event__c = :eventId];
		
		delete ledgerEntries;
	}
	
	public void addOrRemoveRevenueExpenseEntries() {
		List<Id> ancillaryGLAccountsToAdd = new List<Id>();
		List<Id> cogGLAccountsToAdd = new List<Id>();
		List<Id> glAccountsToRemove = new List<Id>();
		List<Id> selectedAncillaryGLAccounts = new List<Id>();
		List<Id> selectedCogGLAccounts = new List<Id>();
		List<Id> selectedGLAccountsList = new List<Id>();
		
		List<Object> selectedGLAccounts = (List<Object>) System.JSON.deserializeUntyped(selectedEntriesJson);
		getRelatedRevenuesExpenses();
		
		// Sort GL Accounts into type
		for (Object selectedGLAccountObj : selectedGLAccounts) {
			Map<String, Object> glAccountElem = (Map<String, Object>) selectedGLAccountObj;
			
			if (glAccountElem.get('type') == 'Ancillary') {
				selectedAncillaryGLAccounts.add((String) glAccountElem.get('id'));
			} else if (glAccountElem.get('type') == 'COGS') {
				selectedCogGLAccounts.add((String) glAccountElem.get('id'));
			}
		}
		
		for (Id elem : selectedAncillaryGLAccounts) {
			selectedGLAccountsList.add(elem);
		}
		
		for (Id elem : selectedCogGLAccounts) {
			selectedGLAccountsList.add(elem);
		}
		
		for (Integer i = 0; i < previousSelectedGLAccountIds.size(); i++) {
			Boolean isMissing = true;
			
			for (Id selElem : selectedGLAccountsList) {
				if (selElem == previousSelectedGLAccountIds[i]) {
					isMissing = false;
					break;
				}
			}
			
			if (isMissing) {
				glAccountsToRemove.add(previousSelectedGLAccountIds[i]);
			}
		}
		
		// Check if Ancillary GL Accounts were previously added
		for (Id elem : selectedAncillaryGLAccounts) {
			Boolean isAlreadyPresent = false;
			
			for (Id prevSelElem : previousSelectedGLAccountIds) {
				if (prevSelElem == elem) {
					isAlreadyPresent = true;
					break;
				}
			}
			
			if (!isAlreadyPresent) {
				ancillaryGLAccountsToAdd.add(elem);
			}
		}
		
		// Check if COGS GL Accounts were previously added
		for (Id elem : selectedCogGLAccounts) {
			Boolean isAlreadyPresent = false;
			
			for (Id prevSelElem : previousSelectedGLAccountIds) {
				if (prevSelElem == elem) {
					isAlreadyPresent = true;
					break;
				}
			}
			
			if (!isAlreadyPresent) {
				cogGLAccountsToAdd.add(elem);
			}
		}
		
		try {
			if (ancillaryGLAccountsToAdd.size() > 0) {
				addLedgerEntries(ancillaryGLAccountsToAdd, 'Ancillary');
			}
			
			if (cogGLAccountsToAdd.size() > 0) {
				addLedgerEntries(cogGLAccountsToAdd, 'COGS');
			}
			
			removeLedgerEntries(glAccountsToRemove);
			
			saveSelectedRevenuesExpensesSuccess = 'true';
		} catch (DmlException e) {
			System.debug(e);
			
			saveSelectedRevenuesExpensesSuccess = 'false';
		}
	}
	
	public void getRelatedRevenuesExpenses() {
		previousSelectedGLAccountIds = new List<Id>();
		
		List<LedgerEntry__c> expenses = [SELECT GLAccount__c FROM LedgerEntry__c WHERE RecordTypeId IN (:RT_Ancillary_ID, :RT_COGS_ID) AND Event__c = :eventId];
		
		if (expenses.size() > 0) {
			previousSelectedEntriesJson = System.JSON.serialize(expenses);
			
			for (LedgerEntry__c entry : expenses) {
				previousSelectedGLAccountIds.add(entry.GLAccount__c);
			}
		} else {
			previousSelectedEntriesJson = '[]';
		}
	}
}