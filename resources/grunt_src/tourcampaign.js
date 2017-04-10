
function disableInputsOnChildren() {
	var dateToday = new Date();
	dateToday.setHours(0,0,0,0);

	jq('#gbMainTable .childDataContainer tr.dr').each(function() {
		var rowDate = new Date(jq(this).find(jq(createFieldSelector( "EventDate__c", gridChildrenInfoMap['TourCampaignAdPlan__c']))).text());
      
      	if (rowDate < dateToday) {
      		jq(this).find(jq(createFieldInputSelector( "AllocatedAmount__c", gridChildrenInfoMap['TourCampaignAdPlan__c']))).attr('disabled', 'disabled');
      	}
    }); 
}

jq(document).ready(function(){
	//-- initialize everything here
	convertGridInfoMap( gridInfoMap );
	
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