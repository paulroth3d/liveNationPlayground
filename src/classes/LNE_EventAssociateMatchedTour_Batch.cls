/**
* Auto-associates an Event__c to a Tour__c.  If the Event has never been matched before and has been
* pre-selected via the AutoMatchedTour__c value, the Tour Id will be copied to the real Tour__c lookup.
*
* @author Scott Will
* @group Batchable
*
**/
global with sharing class LNE_EventAssociateMatchedTour_Batch implements Database.Batchable<SObject> {
	
	// Events who have been pre-matched, are not assocaited to a Tour and are explicitly allowed
	final static String query = 
		'select ' +
			'AutoMatchedTour__c, ' +
			'Tour__c ' +
		'from Event__c ' +
		'where AutoMatchedTour__c != null ' +
		'and Tour__c = null ' +
		'and DoNotAutoAssociateWithTour__c = false';

	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<Event__c> events) {
		// only need to copy over the value and update
		for (Event__c event : events) {
			event.Tour__c = event.AutoMatchedTour__c;
			event.AutoMatchedTour__c = null;
		}
		// update whatever can be
		Database.update(events, false);
	}

	global void finish(Database.BatchableContext bc) {
		// nothing to do, required for implements Database.Batchable<SObject>
		return;
	}

}