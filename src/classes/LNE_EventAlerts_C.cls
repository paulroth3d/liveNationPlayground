/** 
 *	Controller class for the LNE_EventAlerts lightning component
 *	@author Scott Will
 *  @group Controller
 **/
public with sharing class LNE_EventAlerts_C {

	private final static GeneralSettings__c settings = GeneralSettings__c.getInstance();
	
	/**
     *  Returns server specific data
     **/
    @AuraEnabled
    public static Map<String,String> getServerData() {
        return new Map<String,String> {
        	'sessionId' => (UserInfo.getSessionId()),
        	'userId' => (UserInfo.getUserId())
        };
    }

    /**
     *  Returns the current list of event notifications
     *	@param eventId Id - expecting an Event__c.Id
     **/
    @AuraEnabled
    public static List<Notification__c> getNotifications(Id eventId) {

    	Integer maxAge = settings.NotificationAgeLimit__c.intValue();
    	DateTime ageLimit = System.now().addDays(-maxAge);

    	return new List<Notification__c>([
        	select
        		CreatedDate,
        		Description__c,
        		Type__c
        	from Notification__c
        	where Event__c = :eventId
        	and CreatedById = :UserInfo.getUserId()
        	and CreatedDate >= :ageLimit
        	order by CreatedDate desc
        ]);

    }

    /**
     *  Deletes the notifications
     *	@param notificationIdsList Id[] - expecting an array of Notification__c.Id
     **/
    @AuraEnabled
    public static Boolean dismissNotifications(List<Id> notificationIdsList) {

    	Set<Id> notificationIds = new Set<Id>(notificationIdsList);
    	List<Notification__c> notifications = new List<Notification__c>([
    		select Id 
    		from Notification__c 
    		where Id in :notificationIds
    	]);

    	Boolean success = true;

    	if (!notifications.isEmpty()) {
    		
    		Database.delete(notifications, false);

    	}

    	return success;

    }

}