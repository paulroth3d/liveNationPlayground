/**
 * This assigns the list of offices that a user is associated with (used in Event__c and sub object security)\
 * 
 * @author Daniel Nakonieczny (dnakonieczny@salesforce.com);
 * 
 **/
global class LNE_UserOfficeAccessBatch implements Database.Batchable<sObject>, Database.Stateful {

	String officeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Office').getRecordTypeId();
	String query = 'SELECT Name FROM Group WHERE Id IN :groupIDs';

	Map<Id, Set<String>> userIdToOfficeCodeMap = new Map<Id, Set<String>>();
	Map<String, String> officeNameToOfficeIDMap = new Map<String, String>();
	Map<String, String> groupToOfficeMap = new Map<String, String>();
	Set<Id> groupIDs = new Set<Id>();

	global LNE_UserOfficeAccessBatch() {
		List<Account> primaryOffices = [SELECT Name, OfficeID__c FROM Account WHERE RecordTypeId = :officeRecordTypeId AND OfficeID__c <> NULL];
		List<Group> groups = [SELECT Name FROM Group];
		Set<String> officeNames = new Set<String>();

		for (Account a : primaryOffices) {
			for (Group g : groups) {
				if (!String.isBlank(g.Name) && g.Name.startsWith(a.Name)) {
					officeNames.add(a.Name);
					groupToOfficeMap.put(g.Name, a.Name);
					groupIDs.add(g.Id);
				}
			}

			officeNameToOfficeIDMap.put(a.Name, a.OfficeID__c);
		}
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
  	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Group> groups = (List<Group>)scope;

		for (Group g : groups) {
			String officeName = groupToOfficeMap.get(g.Name);

			if (!String.isBlank(officeName)) {
				Set<Id> userIDs = LNE_GroupMembershipUtil.getDirectAndIndirectUsersForGroupId(g.Id, null);
				String officeID = officeNameToOfficeIDMap.get(officeName);

				if (!String.isBlank(officeID)) {
					for (Id userId : userIDs) {
						if (userIdToOfficeCodeMap.get(userId) == null) {
							userIdToOfficeCodeMap.put(userId, new Set<String>());
						}

						userIdToOfficeCodeMap.get(userId).add(officeID);
					}
				}
			}
		}
	}

	global void finish(Database.BatchableContext BC){
		List<User> toUpdate = [SELECT OfficeAccess__c FROM User WHERE IsActive = true];

		for (User u : toUpdate) {
			u.OfficeAccess__c = null;
			if (userIdToOfficeCodeMap.get(u.Id) != null) {
				List<String> codes = new List<String>(userIdToOfficeCodeMap.get(u.Id));
				u.OfficeAccess__c = String.join(codes, ',');
			}
		}

		update toUpdate;
	}
}