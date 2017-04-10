public with sharing class LNE_LedgerCategoryModel {

	public String category {get;set;}
	public List<LedgerEntry__c> entries {get;set;}

	public LNE_LedgerCategoryModel(String category) {
		this.category = category;
		this.entries = new List<LedgerEntry__c>();
	}

}