public with sharing class LNE_SelectFinanceAncillaryCOGSEntries_CX {

	private final Id eventId;

	public List<LNE_LedgerCategoryModel> ancillaries {get;private set;}
	public List<LNE_LedgerCategoryModel> cogs {get;private set;}	
	
	public LNE_SelectFinanceAncillaryCOGSEntries_CX(ApexPages.StandardController sc) {
		this.eventId = sc.getId();
		this.ancillaries = getAncillaries();
		this.cogs = getCOGs();
	}

	public List<LNE_LedgerCategoryModel> getAncillaries() {
		return getLedgerCategories('Ancillary');
	}

	public List<LNE_LedgerCategoryModel> getCOGs() {
		return getLedgerCategories('COGS');
	}

	private List<LNE_LedgerCategoryModel> getLedgerCategories(String acctType) {

		String lastCategory = '';
		LNE_LedgerCategoryModel category;
		List<LNE_LedgerCategoryModel> categories = new List<LNE_LedgerCategoryModel>();
		for (LedgerEntry__c entry : [
			select
				FlashApplicable__c,
				GLAccount__r.Category__c,
				GLAccount__r.GLCode__c,
				GLAccount__r.Name,
				GLAccount__r.Type__c
			from LedgerEntry__c
			where Event__c = :this.eventId
			and GLAccount__r.Type__c = :acctType
			order by 
				GLAccount__r.CategorySort__c,
				GLAccount__r.Category__c,
				GLAccount__r.Name
		]) {

			if (category == null || entry.GLAccount__r.Category__c != lastCategory) {
				lastCategory = entry.GLAccount__r.Category__c;
				addCategory(categories, category);
				category = new LNE_LedgerCategoryModel(lastCategory);
			}

			category.entries.add(entry);

		}

		addCategory(categories, category);

		return categories;

	}

	private void addCategory(List<LNE_LedgerCategoryModel> categories, LNE_LedgerCategoryModel category) {
		if (category != null && categories != null) {
			categories.add(category);
		}
	}

	public void updateLedgerEntries() {

		List<LedgerEntry__c> entries = new List<LedgerEntry__c>();
		for (LNE_LedgerCategoryModel lc : this.ancillaries) {
			entries.addAll(lc.entries);
		}
		for (LNE_LedgerCategoryModel lc : this.cogs) {
			entries.addAll(lc.entries);
		}

		if (!entries.isEmpty()) {
			Database.update(entries, false);
		}

	}

}