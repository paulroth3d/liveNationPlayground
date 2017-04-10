//-- your info goes here:ticketscaleanubhav
//-- to deploy run: grunt deployGridBuddyResource:ticketscaleanubhav

/**
 *  Handle when the Capacity or comps or kills are changed.
 *  <p>Single function since they are all related</p>
**/
function capacityKillCompsChangedHandler( evt ){
	var parentRow = jq( evt.target.parentElement.parentElement );
	var capacityValue = sanitizeNumber(getInputValue(parentRow,'Capacity__c'));
	var compsValue = sanitizeNumber(getInputValue(parentRow,'Comps__c'));	
	var killsValue = sanitizeNumber(getInputValue(parentRow,'Kills__c'));
	var priceValue = sanitizeNumber(getInputValue(parentRow,'Price__c'));
	var newSellableCapacityValue = formatNumber(capacityValue - compsValue - killsValue);
	var newGrossSales = formatNumber((capacityValue - compsValue - killsValue)  * priceValue);
	jq( parentRow ).find( createFieldSelector( "SellableCapacity__c" )).html(newSellableCapacityValue).change();
	jq( parentRow ).find( createFieldSelector( "GrossSales__c" )).html(newGrossSales).change();
}

/**
 *  Handle when the price has changed.
**/
function priceChangedHandler( evt ){
	var parentRow = jq( evt.target.parentElement.parentElement.parentElement );
	var capacityValue = sanitizeNumber(getInputValue(parentRow,'Capacity__c'));
	var compsValue = sanitizeNumber(getInputValue(parentRow,'Comps__c'));	
	var killsValue = sanitizeNumber(getInputValue(parentRow,'Kills__c'));
	var priceValue = sanitizeNumber(getInputValue(parentRow,'Price__c'));
	var projectedPaidTicketsValue = sanitizeNumber(getInputValue(parentRow,'ProjectedPaidTickets__c'));
	var newGrossSales = formatNumber((capacityValue - compsValue - killsValue)  * priceValue);
	var newProjectedGrossSales =  formatNumber(projectedPaidTicketsValue * priceValue);
	jq( parentRow ).find( createFieldSelector( "GrossSales__c" )).html(newGrossSales).change();
	jq( parentRow ).find( createFieldSelector( "ProjectedGrossSales__c" )).html(newProjectedGrossSales).change();
}

/**
 *  Handle when the Projected Paid Tickets have changed.
**/
function projectedPaidTicketsChangedHandler( evt ){
	var parentRow = jq( evt.target.parentElement.parentElement );
	var priceValue = sanitizeNumber(getInputValue(parentRow,'Price__c'));
	var projectedPaidTicketsValue = sanitizeNumber(getInputValue(parentRow,'ProjectedPaidTickets__c'));
	var newProjectedGrossSales =  formatNumber(projectedPaidTicketsValue * priceValue);
	jq( parentRow ).find( createFieldSelector( "ProjectedGrossSales__c" )).html(newProjectedGrossSales).change();
}


jq( document ).ready( function(){
	console.log("anubhav grid is ready");
	debugger;
	//-- initialize everything here
	convertGridInfoMap( gridInfoMap );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "Capacity__c"), capacityKillCompsChangedHandler );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "Comps__c"), capacityKillCompsChangedHandler );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "Kills__c"), capacityKillCompsChangedHandler );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "Price__c"), priceChangedHandler );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "ProjectedPaidTickets__c"), projectedPaidTicketsChangedHandler );
});