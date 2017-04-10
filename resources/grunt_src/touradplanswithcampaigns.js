
function tourBudgetPercentChangedHandler( evt ){
	var parentRow = jq( evt.target.parentElement.parentElement );
	var tourBudgetPercent = sanitizeNumber(getInputValue(parentRow,'TourBudgetPercent__c'));
	var lneAdPlanBudget = sanitizeNumber(jq(parentRow).find( createFieldSelector( "LNEAdPlanBudget__c" )).text());
	var oldBudget = jq( parentRow ).find( createFieldInputSelector( "TourBudget__c" )).val();
	var newBudget;

	if (tourBudgetPercent != null && tourBudgetPercent != undefined &&
			lneAdPlanBudget != null && lneAdPlanBudget != undefined) {

		tourBudgetPercent = tourBudgetPercent/100;

		newBudget = (lneAdPlanBudget * tourBudgetPercent).toFixed(2);
		
		jq( parentRow ).find( createFieldInputSelector( "TourBudget__c" )).val(newBudget);
	} else {
		newBudget = '';
		jq( parentRow ).find( createFieldInputSelector( "TourBudget__c" )).val(newBudget);
	}

	if (oldBudget != newBudget) {
		jq( parentRow ).find( createFieldInputSelector( "TourBudget__c" )).change();
	}
}

function tourBudgetChangedHandler( evt ){
	var parentRow = jq( evt.target.parentElement.parentElement.parentElement );
	var tourBudget = sanitizeNumber(getInputValue(parentRow,'TourBudget__c'));
	var lneAdPlanBudget = sanitizeNumber(jq(parentRow).find( createFieldSelector( "LNEAdPlanBudget__c" )).text());
	var oldBudgetPercent = jq( parentRow ).find( createFieldInputSelector( "TourBudgetPercent__c" )).val();
	var newBudgetPercent;

	if (tourBudget != null && tourBudget != undefined &&
			lneAdPlanBudget != null && lneAdPlanBudget != undefined) {

		newBudgetPercent = ((tourBudget / lneAdPlanBudget) * 100).toFixed(2);
		
		jq( parentRow ).find( createFieldInputSelector( "TourBudgetPercent__c" )).val(newBudgetPercent);
	} else {
		newBudgetPercent = '';
		jq( parentRow ).find( createFieldInputSelector( "TourBudgetPercent__c" )).val(newBudgetPercent);
	}

	if (oldBudgetPercent != newBudgetPercent) {
		jq( parentRow ).find( createFieldInputSelector( "TourBudgetPercent__c" )).change();
	}
}

function disableInputsOnChildren() {
	var dateToday = new Date();
	dateToday.setHours(0,0,0,0);

	jq('#gbMainTable .childDataContainer tr.dr').each(function() {
		var parentRecord = jq(this).closest('tr.cr').prev();
		var parentDate = jq(parentRecord).find(jq(createFieldSelector( "EventDate__c"))).text();

		var eventDate = new Date(parentDate);
      
      	if (eventDate < dateToday) {
      		jq(this).find(jq(createFieldInputSelector( "AllocatedAmount__c", gridChildrenInfoMap['TourCampaignAdPlan__c']))).attr('disabled', 'disabled');
      	}
    });
}

jq(document).ready(function(){
	//-- initialize everything here
	convertGridInfoMap( gridInfoMap );

	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "TourBudgetPercent__c"), tourBudgetPercentChangedHandler );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "TourBudget__c"), tourBudgetChangedHandler );
	
	jq('.saveBtn').click(function() {
		parent.postMessage('Saving', '*');
	});

	jq('.deleteItem').click(function() {
		parent.postMessage('Saving', '*');
	});	

	gridStateMessagingController();

	parent.postMessage('Loaded','*');

	disableInputsOnChildren();
});