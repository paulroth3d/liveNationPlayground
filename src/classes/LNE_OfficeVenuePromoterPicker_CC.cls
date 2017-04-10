global without sharing class LNE_OfficeVenuePromoterPicker_CC {
	static final String RT_Office = 'Account.Office';
	static final String RT_Venue = 'Account.Venue';
	static final String SELECT_AN_OFFICE = '-- Please select an office --';
	static final String NO_OFFICES_AVAILABLE = '-- No offices available --';

	public String originalEventVenueId {get;set {
		this.originalEventVenueId = value;
		isOriginalEventVenueAccessible();
	}}

	public List<SelectOption> offices {get;set;}
	public String selectedOfficeId {get;set;}
	public Boolean isVenueAccessible {get;set;}
	public String venueMapJSON {get;set;}

	private String defaultOffice;
	private Set<Id> allOfficeIds;
	private List<VenueOffice__c> allVenues;
	private Set<Id> allAccessibleVenueIds;

	global LNE_OfficeVenuePromoterPicker_CC() {
	    getOffices();
	    findDefaultOffice();
	    getAllVenues();
	}

	private void getOffices() {
		Set<String> trimmedGroupNames = new Set<String>();
		offices = new List<SelectOption>();
		List<Account> accounts = new List<Account>();
		List<Group> userGroups = getUserGroups();

        //-- only want office accounts
		Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{ RT_Office }
		);
		Id RT_Office_ID = recordTypeMap.get( RT_Office );

		//-- loop through each group and extract name minus booking
		for ( Group ug : userGroups ) {
			if (String.isNotBlank(ug.Name)) {
				String strippedGroupName = ug.Name.remove('Booking').trim();
				trimmedGroupNames.add(strippedGroupName);
			}
		}

		if (trimmedGroupNames.size() > 0) {
			accounts = [SELECT Id, Name FROM Account WHERE Account.RecordTypeId = :RT_Office_ID AND Name IN :trimmedGroupNames];
		}

		accounts.sort();
		populateOfficeListOptions(accounts);
	}

	private List<Group> getUserGroups() {
		Id userId = UserInfo.getUserId();
		Set<Id> users = new Set<Id>();
		users.add(userId);

		Map<Id,Set<id>> foundGroupIdsMap;
		Set<id> foundGroupIds;
		List<Group> foundGroups;

		foundGroupIdsMap = LNE_GroupMembershipUtil.getDirectAndIndirectGroupsForUserIdMult(userId);
		foundGroupIds = foundGroupIdsMap.get(userId);

		foundGroups = [SELECT Id, Name FROM Group WHERE Id IN :foundGroupIds AND Name LIKE '%Booking'];

		return foundGroups;
	}

	private void findDefaultOffice() {
		String userProfileName = getCurrentUserProfileName();
		String userRoleName = getCurrentUserRoleName();

		Set<String> possibleNames = new Set<String>{userProfileName,userRoleName,trimProfileName(userProfileName),trimProfileName(userRoleName)};

		for (String s : possibleNames) {
			if (String.isNotBlank(s)) {
				defaultOffice = findMatchingAccountId(s);
			}

			if (defaultOffice != null) {
				break;
			}
 		}

		if (String.isNotBlank(defaultOffice)) {
			selectedOfficeId = defaultOffice;
		}
	}

	private void getAllVenues() {
		allVenues = [SELECT Venue__c, Venue__r.Id, Venue__r.Name, Office__c FROM VenueOffice__c WHERE Office__c IN :allOfficeIds ORDER BY Venue__r.Name ASC];
		allAccessibleVenueIds = new Set<Id>();
		Map<Id, List<ListOption>> venueMap = new Map<Id, List<ListOption>>();
		for (VenueOffice__c vo : allVenues) {
			allAccessibleVenueIds.add(vo.Venue__c);

			if (venueMap.get(vo.Office__c) == null) {
				venueMap.put(vo.Office__c, new List<ListOption>());
			}

			venueMap.get(vo.Office__c).add(new ListOption(vo.Venue__c, vo.Venue__r.Name));
		}

		venueMapJSON = JSON.serialize(venueMap);
	}

	private Boolean isOriginalEventVenueAccessible() {
		if (String.isNotBlank(originalEventVenueId)) {
			isVenueAccessible = allAccessibleVenueIds.contains(originalEventVenueId);
			return allAccessibleVenueIds.contains(originalEventVenueId);
		}

		return false;
	}

	private void populateOfficeListOptions(List<Account> accounts) {
		offices = new List<SelectOption>();
		allOfficeIds = new Set<Id>();

		if (accounts == null || accounts.size() == 0) {
			offices.add(new SelectOption('', NO_OFFICES_AVAILABLE));
		} else {
			offices.add(new SelectOption('', SELECT_AN_OFFICE));

			for (Account a : accounts) {
				offices.add(new SelectOption(a.Id, a.Name));
				allOfficeIds.add(a.Id);
			}
		}
	}

	private String getCurrentUserProfileName() {
		return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name.trim();
	}

	private String getCurrentUserRoleName() {
		User u = [SELECT UserRoleId, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
		if (u.UserRoleId != null && u.UserRole.Name != null) {
			return u.UserRole.Name.trim();
		}
		return null;
	}

	private String trimProfileName(String profileName) {
		if (String.isNotBlank(profileName)) {
			String[] wordsToRemove = new String[]{'Promoter','Marketer','Operations'};

			for (String s : wordsToRemove) {
				profileName = profileName.remove(s);
			}

			return profileName.trim();
		}
		
		return null;
	}

	private String findMatchingAccountId(String nameToFind) {
		String toReturn;

		if (String.isNotBlank(nameToFind)) {
			for (SelectOption office : offices) {
				if (office.getLabel().trim() == nameToFind) {
					toReturn = office.getValue();
				}
			}	
		}

		return toReturn;
	}

	@RemoteAction
	global static List<User> getPromoters(String selectedGroupName) {
		//-- Worker vars for getting groups that align to selected office
		String extendedGroupName;
		Id searchGroupId;
		List<Group> resultGroups;
		Set<Id> userIdResults = new Set<Id>();

		//-- Result
		List<User> promoters;

		/*
		Available promoter logic - the list of promoter options:
		Query for all members (direct and indirect) of Public Group where Name (Label) = <selected Office name> + " Booking"
		filter to only members that have the "Booking" Permission Set
		For example:
		if the defaulted Office is Los Angeles (from above)
		then find all members that have the permission set 'Booking'
		Find every group that those users belong to (both by role and by the roles contained in the hierarchy)
		and narrow to only those groups that have the name 'Los Angeles Booking'
		Only show the users that are within that set
		*/

		//-- query for all members of public group passed in
		extendedGroupName = selectedGroupName + ' Booking';
		resultGroups = [SELECT Id FROM Group WHERE Name = :extendedGroupName LIMIT 1];
		
		if (resultGroups != null && !resultGroups.isEmpty()) {
			searchGroupId = resultGroups[0].Id;
		}

		if (searchGroupId != null) {
			userIdResults = LNE_GroupMembershipUtil.getDirectAndIndirectUsersForGroupId(searchGroupId, new Set<String>{'Booking'});
		}
		
        promoters = [SELECT Name FROM User WHERE Id IN :userIdResults ORDER BY Name ASC];
        
		return promoters;
	}

	//- We need this class to serialize <select> options into JSON. Serializing
	//- the standard class SelectOption results in an error.
	public class ListOption {
		public String optionValue {get;set;}
		public String optionLabel {get;set;}

		public ListOption(String v, String l) {
			this.optionValue = v;
			this.optionLabel = l;
		}
	}
}