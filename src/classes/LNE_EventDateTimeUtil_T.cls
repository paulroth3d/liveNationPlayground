/**
 *  Utility class for LNE_EventDateTime.trigger.
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 **/
public with sharing class LNE_EventDateTimeUtil_T {

	private static final DataGenerationSettings__c DATA_SETTINGS = DataGenerationSettings__c.getInstance();
	private static final String NO_VENUE_OFFICE_ACCESS = 'You cannot create child records of the event because you do not have authorized access to the venue office/division';

	/**
	 *  Determines if the related Event is using Multi Scale, and if so, clones the Ticket Scales for the
	 *  first (earliest date, earliest time) EventDateTime__c and associates them with the EventDateTime__c
	 *  being inserted
	 **/
	public static void checkForMultiScale(EventDateTime__c[] newEventDateTimes) {
		Set<Id> eventIds = new Set<Id>();

		for (EventDateTime__c edt : newEventDateTimes) {
			if (edt.IsEventMultiScale__c == true && edt.Event__c != null) {
				eventIds.add(edt.Event__c);
			}
		}

		if (eventIds.size() == 0) {
			return;
		}

		List<Event__c> events = [SELECT Id, (SELECT EventDate__c, StartTime__c FROM EventDateTimes__r WHERE NOT Id IN :newEventDateTimes) FROM Event__c WHERE Id IN :eventIds];

		Map<Id,Id> oldToNewEventDateTimeMap = new Map<Id,Id>();
		Map<Id,Id> eventIdToEarliestDateTimeMap = new Map<Id,Id>();

		for (Event__c e : events) {
			List<EventDateTime> dateTimes = new List<EventDateTime>();
			for (EventDateTime__c edt : e.EventDateTimes__r) {
				dateTimes.add(new EventDateTime(edt));
			}

			dateTimes.sort();

			if (dateTimes.size() > 0) {
				eventIdToEarliestDateTimeMap.put(e.Id, dateTimes[0].edt.Id);
			}
		}

		if (eventIdToEarliestDateTimeMap.values().size() > 0) {
			Set<String> ticketScaleFieldNames = getFieldNamesForObject(TicketScale__c.sObjectType.getDescribe());
			List<Id> eventDateTimeIds = eventIdToEarliestDateTimeMap.values();

			String queryFieldNames = String.join(new List<String>(ticketScaleFieldNames), ',');
			String ticketScaleQuery = 'SELECT ';
			ticketScaleQuery += queryFieldNames;
			ticketScaleQuery += ' FROM TicketScale__c';
			ticketScaleQuery += ' WHERE EventDateTime__c IN :eventDateTimeIds';

			List<TicketScale__c> toClone = Database.query(ticketScaleQuery);

			Map<Id, List<TicketScale__c>> earliestEventDateTimeToTicketScalesMap = new Map<Id, List<TicketScale__c>>();

			for (TicketScale__c ts : toClone) {
				if (earliestEventDateTimeToTicketScalesMap.get(ts.EventDateTime__c) == null) {
					earliestEventDateTimeToTicketScalesMap.put(ts.EventDateTime__c, new List<TicketScale__c>());
				}

				earliestEventDateTimeToTicketScalesMap.get(ts.EventDateTime__c).add(ts);
			}

			List<TicketScale__c> toInsert = new List<TicketScale__c>();

			Map<Id, TicketScale> tsMap = new Map<Id, TicketScale>();

			for (EventDateTime__c edt : newEventDateTimes) {
				Id earliestExistingEventDateTime = eventIdToEarliestDateTimeMap.get(edt.Event__c);

				List<TicketScale__c> scalesToClone = earliestEventDateTimeToTicketScalesMap.get(earliestExistingEventDateTime);

				if (scalesToClone != null) {
					for (TicketScale__c ts : scalesToClone) {
						tsMap.put(ts.Id, new TicketScale(ts));
					}

					for (TicketScale__c ts : scalesToClone) {
						TicketScale__c newTicketScale = ts.clone(false, true, false, false);
						newTicketScale.EventDateTime__c = edt.Id;
						populateGridBuddyFilterFields(newTicketScale);
						
						toInsert.add(newTicketScale);
						tsMap.get(ts.Id).clonedScales.add(newTicketScale);
					}
				}
			}

			if (toInsert.size() > 0) {
				LNE_GeneralSettingsUtil.setLocalBypassSettings(false, true, false);
				LNE_FinancialCalculator.currentlyRunning = true;

				insert toInsert;

				List<sObject> objectsToUpdate = getRelatedLedgersAndDeductions(eventIds);
		
				for (sObject so : objectsToUpdate) {
					addAdditionalIds(so, tsMap);
				}
				
				update objectsToUpdate;

				LNE_FinancialCalculator.currentlyRunning = false;
				LNE_GeneralSettingsUtil.removeCurrentUserOverride();
			}
		}
	}
	
	/**
	 *  Checks if the current user has access to any of the offices (through VenueOffice__c)
	 *  for the current venue on the EventDateTime__c
	 **/
	public static void checkVenueAccess(EventDateTime__c[] newEventDateTimes) {
		GeneralSettings__c settings = GeneralSettings__c.getInstance();
		
		if (settings.GlobalDataAdministrator__c == false && settings.BypassAutomation__c == false && settings.BypassPBFlow__c == false) {
			String officeAccess = [SELECT OfficeAccess__c FROM User WHERE Id = :UserInfo.getUserId()].OfficeAccess__c;
			
			if (String.isNotBlank(officeAccess)) {
				List<String> userOffices = officeAccess.split(',');
				Set<Id> eventIds = new Set<Id>();
		
				for (EventDateTime__c edt : newEventDateTimes) {
					if (edt.Event__c != null) {
						eventIds.add(edt.Event__c);
					}
				}
				
				if (eventIds.size() > 0) {
					List<Event__c> events = [SELECT Venue__c FROM Event__c WHERE Id IN :eventIds];
					Map<Id, Event__c> eventMap = new Map<Id, Event__c>(events);
					
					Set<Id> venueIds = new Set<Id>();
					
					for (Event__c e : events) {
						if (e.Venue__c != null) {
							venueIds.add(e.Venue__c);
						}
					}
					
					if (venueIds.size() > 0) {
						List<VenueOffice__c> venueOffices = [SELECT Venue__c, Office__r.OfficeID__c FROM VenueOffice__c WHERE Venue__c IN :venueIds];
						
						Map<Id, Set<String>> venueToOfficeIds = new Map<Id, Set<String>>();
						
						for (VenueOffice__c vo : venueOffices) {
							if (venueToOfficeIds.get(vo.Venue__c) == null) { venueToOfficeIds.put(vo.Venue__c, new Set<String>()); }
							
							venueToOfficeIds.get(vo.Venue__c).add(vo.Office__r.OfficeID__c);
						}
						
						for (EventDateTime__c edt : newEventDateTimes) {
							if (eventMap.get(edt.Event__c) != null) {
								Id venueId = eventMap.get(edt.Event__c).Venue__c;
								Set<String> venueOfficeIDs = venueToOfficeIds.get(venueId);
								
								if (venueOfficeIDs != null) {
									venueOfficeIDs.retainAll(userOffices);
									
									if (venueOfficeIDs.size() == 0) {
										edt.addError(NO_VENUE_OFFICE_ACCESS);
									}
								}
							}
						}
					}
				}
			} else {
				newEventDateTimes[0].addError(NO_VENUE_OFFICE_ACCESS);
			}
		}
	}

	/**
	 *  Deletes any child TicketScale__c records when a EventDateTime__c is deleted.
	 **/
	public static void deleteTicketScales(Map<Id,EventDateTime__c> deletedRecords) {
		if (deletedRecords != null && deletedRecords.keySet().size() > 0) {
			Set<Id> deletedIds = deletedRecords.keySet();

			List<TicketScale__c> scalesToDelete = [SELECT Id FROM TicketScale__c WHERE EventDateTime__c IN :deletedIds];

			if (scalesToDelete.size() > 0) {
				delete scalesToDelete;
			}
		}
	}

	public static void populateGridBuddyFilterFields(sObject so) {
		String eventId = (String)so.get('Event__c');
		String stageType = (String)so.get('StageType__c');
		String eventDateTime = so.get('EventDateTime__c') == null ? '' : (String)so.get('EventDateTime__c');

		so.put('EventIDStageType__c', eventId.substring(0,15) + DATA_SETTINGS.CombinedKeyDelimiter__c + stageType);

		if (so.getSObjectType() == Schema.TicketScale__c.SObjectType && eventDateTime.length() >= 15) {
			String EventIDStageTypeDateTime = (String)so.get('EventIDStageType__c') + DATA_SETTINGS.CombinedKeyDelimiter__c + eventDateTime.substring(0,15);

			so.put('EventIDStageTypeDateTime__c', EventIDStageTypeDateTime);
		}
	}

	public static Set<Id> getSelectedTicketScales(sObject so) {
    	String encodedDelimeter = EncodingUtil.urlEncode(DATA_SETTINGS.CombinedKeyDelimiter__c, 'UTF-8');
        String encodedString = EncodingUtil.urlEncode((String)so.get('TicketScaleList__c'), 'UTF-8');
		String[] idList = encodedString.split(encodedDelimeter);
		Set<String> stringSet = new Set<String>(idList);
		stringSet.removeAll(new String[]{'',null});
		
		//- This seems to be the easiest way to convert Set<String> to Set<Id> as they don't seem to be compatible
		Set<Id> idSet = (Set<Id>)JSON.deserialize(JSON.serialize(stringSet), Set<Id>.class);
		
		return idSet;
    }

    public static void addAdditionalIds(sObject so, Map<Id, LNE_EventDateTimeUtil_T.TicketScale> tsMap) {
    	if (so.get('TicketScaleList__c') != null) {
    		Set<Id> idSet = LNE_EventDateTimeUtil_T.getSelectedTicketScales(so);
    		Set<Id> newTicketScaleIdList = new Set<Id>();
    		
    		for (Id ticketScaleId : idSet) {
    			newTicketScaleIdList.add(ticketScaleId);
    			if (tsMap.containsKey(ticketScaleId)) {
    				newTicketScaleIdList.addAll(tsMap.get(ticketScaleId).getClonedIds());
    			}
    		}
    		
    		joinAndPopulateSelectedTicketScales(so, newTicketScaleIdList);
    	}
    }

    public static void removeDeletedIds(sObject so, Set<Id> idsToRemove) {
    	if (so.get('TicketScaleList__c') != null) {
    		Set<Id> idSet = LNE_EventDateTimeUtil_T.getSelectedTicketScales(so);
    		idSet.removeAll(idsToRemove);
    		joinAndPopulateSelectedTicketScales(so, idSet);
    	}
    }

    public static void joinAndPopulateSelectedTicketScales(sObject so, Set<Id> newTicketScaleIdList) {
    	List<String> toJoin = new List<String>();
    	for (Id s : newTicketScaleIdList) {
    		if (s != null) {
    			toJoin.add(((String)s).substring(0,15));
    		}
    	}
    	String newTicketScaleList = String.join(toJoin, DATA_SETTINGS.CombinedKeyDelimiter__c);
    	so.put('TicketScaleList__c', newTicketScaleList);
    }

    private static List<sObject> getRelatedLedgersAndDeductions(Set<Id> eventIds) {
    	List<sObject> objectsToReturn = new List<sObject>();
    	objectsToReturn.addAll((List<sObject>)[SELECT TicketScaleList__c FROM LedgerEntry__c WHERE Event__c IN :eventIds]);
    	objectsToReturn.addAll((List<sObject>)[SELECT TicketScaleList__c FROM LedgerEntryBreakout__c WHERE LedgerEntry__c IN :objectsToReturn]);
    	objectsToReturn.addAll((List<sObject>)[SELECT TicketScaleList__c FROM Deduction__c WHERE Event__c IN :eventIds]);
    	
    	return objectsToReturn;
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

	public class EventDateTime implements Comparable {
    	public EventDateTime__c edt;
    	public DateTime dt;
    	
    	public EventDateTime(EventDateTime__c e) {
    		this.edt = e;
    		this.dt = getDateTime(e);
    	}
    	
    	public Integer compareTo(Object compareTo) {
    		if (compareTo instanceof EventDateTime) {
    			EventDateTime compareToEdt = (EventDateTime)compareTo;
    			
    			if (compareToEdt.edt.EventDate__c == null || this.edt.EventDate__c == null) {
    				return 0;
    			}
    			
    			return this.dt > compareToEdt.dt ? 1 : -1;
    		}
    		
    		return 0;
    	}
    	
    	private DateTime getDateTime(EventDateTime__c e) {
    		DateTime dt;
    		
    		if (e != null && e.EventDate__c != null) {
    			String dts = e.EventDate__c.format();
				if (String.isBlank(e.StartTime__c)) {
					dts += ' 12:00 AM';
				} else {
					dts += ' ' + e.StartTime__c;
				}
				dt = DateTime.parse(dts);
    		} else {
    			dt = System.now();
    		}
    		
			return dt;
    	}
    }

    public class TicketScale {
    	public TicketScale__c ts;
    	public List<TicketScale__c> clonedScales;
    	public Set<Id> clonedScaleIds;
    	
    	public TicketScale(TicketScale__c t) {
    		this.ts = t;
    		clonedScales = new List<TicketScale__c>();
    	}
    	
    	 public Set<Id> getClonedIds() {
    	 	if (clonedScaleIds == null) {
    	 		if (clonedScales != null) {
    	 			clonedScaleIds = new Map<Id,TicketScale__c>(clonedScales).keySet();
    	 		}
    	 	}
    	 	
    	 	return clonedScaleIds;
    	 }
    }
}