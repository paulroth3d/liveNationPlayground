function capacityKillCompsChangedHandler( evt ){

	if (evt && evt.target) {
		capacityKillCompsChangedForRow(jq(evt.target).closest('tr'));
	} else {
		jq( "#gbMainTable" ).find(createFieldInputSelector( "Comps__c" )).each(function(index, element){
			capacityKillCompsChangedForRow(jq(element).closest('tr'));
		});
	}
}

function capacityKillCompsChangedForRow(parentRow) {
	const capacityValue = sanitizeNumber(getInputValue(parentRow,'Capacity__c'));
	const compsValue = sanitizeNumber(getInputValue(parentRow,'Comps__c'));	
	const killsValue = sanitizeNumber(getInputValue(parentRow,'Kills__c'));
	const priceValue = sanitizeNumber(getInputValue(parentRow,'Price__c'));
	//const newSellableCapacityValue = capacityValue - compsValue - killsValue;
	const newGrossSales = formatNumber((capacityValue - compsValue - killsValue)  * priceValue);

	//const currentSellableCapacity = jq( parentRow ).find( createFieldSelector( "SellableCapacity__c" )).html();
	const currentGrossSales = jq( parentRow ).find( createFieldSelector( "GrossSales__c" )).html();
	
	/*
	if(!priceValue || !priceValue.length || !capacityValue || !capacityValue.length) {
		jq( parentRow ).find( createFieldSelector( "SellableCapacity__c" )).html('').change();
	} else if (newSellableCapacityValue != currentSellableCapacity) {
		jq( parentRow ).find( createFieldSelector( "SellableCapacity__c" )).html(newSellableCapacityValue).change();
	}
	*/
	
	setSellableCapacity(parentRow, capacityValue, priceValue, compsValue, killsValue);

	if (newGrossSales != currentGrossSales) {
		jq( parentRow ).find( createFieldSelector( "GrossSales__c" )).html(newGrossSales).change();
	}
}

function setSellableCapacity(parentRow, capacityValue, priceValue, compsValue, killsValue) {
	var sellableCapacity = '';
	
	if(capacityValue && capacityValue.length && priceValue && priceValue.length) {
		if(parseFloat(priceValue) === 0) {
			sellableCapacity = '0';
		} else {
			sellableCapacity = capacityValue - compsValue - killsValue;
		}
	} else {
		sellableCapacity = '';
	}
	
	jq( parentRow ).find(createFieldSelector( "SellableCapacity__c" )).html(sellableCapacity).change();
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
	
	
	setSellableCapacity(parentRow, capacityValue, priceValue, compsValue, killsValue);
	
	/*
	if(priceValue && priceValue.length && parseFloat(priceValue) === 0 && capacityValue && capacityValue.length) {
		jq( parentRow ).find( createFieldSelector( "SellableCapacity__c" )).html(0).change();
	} else {
		capacityKillCompsChangedForRow(parentRow);
	}
	*/
	
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
	var newProjectedGrossSalesNumber =  projectedPaidTicketsValue * priceValue;
	var newProjectedGrossSales =  formatNumber(newProjectedGrossSalesNumber);
	jq( parentRow ).find( createFieldSelector( "ProjectedGrossSales__c" )).html(newProjectedGrossSales).change();

	var actualSalesToDate = sanitizeNumber(getInputValue(parentRow,'ActualSalesToDate__c'));

	if (projectedPaidTicketsValue != null && projectedPaidTicketsValue != undefined && !isNaN(projectedPaidTicketsValue) &&
		actualSalesToDate != null && actualSalesToDate != undefined && !isNaN(actualSalesToDate)) {

		var newForecastSalesToGo = formatNumber(projectedPaidTicketsValue - actualSalesToDate).replace(".00", "");
		var forecastSalesToGoText = jq( parentRow ).find( createFieldSelector( "ForecastSalesToGo__c" )).text();
		var currencyCodeText = "";
		if (forecastSalesToGoText != null && forecastSalesToGoText != undefined) {
			var currencyCode = forecastSalesToGoText.split(" ");
			if (currencyCode.length > 1) {
				currencyCodeText = currencyCode[0];
			}
		}

		jq( parentRow ).find( createFieldSelector( "ForecastSalesToGo__c" )).html(currencyCodeText + " " + newForecastSalesToGo).change();
	} else {
		jq( parentRow ).find( createFieldSelector( "ForecastSalesToGo__c" )).html('').change();
	}

	var actualGrossToDate = sanitizeNumber(getInputValue(parentRow,'ActualGrossToDate__c'));

	if (newProjectedGrossSalesNumber != null && newProjectedGrossSalesNumber != undefined && !isNaN(newProjectedGrossSalesNumber) &&
		actualGrossToDate != null && actualGrossToDate != undefined && !isNaN(actualGrossToDate)) {

		var newForecastGrossToGo = formatNumber(newProjectedGrossSalesNumber - actualGrossToDate);
		var forecastGrossToGoText = jq( parentRow ).find( createFieldSelector( "ForecastGrossToGo__c" )).text();
		var currencyCodeText = "";
		if (forecastGrossToGoText != null && forecastGrossToGoText != undefined) {
			var currencyCode = forecastGrossToGoText.split(" ");
			if (currencyCode.length > 1) {
				currencyCodeText = currencyCode[0];
			}
		}

		jq( parentRow ).find( createFieldSelector( "ForecastGrossToGo__c" )).html(currencyCodeText + " " + newForecastGrossToGo).change();
	} else {
		jq( parentRow ).find( createFieldSelector( "ForecastGrossToGo__c" )).html('').change();
	}
}

function disableInputsForAudit() {
	jq('#gbMainTable tr').each(function() {
      if (jq(this).attr('id')) {
          jq(this).find('input').attr('disabled', 'disabled').removeClass('gbrq');
          jq(this).find('select').attr('disabled', 'disabled').removeClass('gbrq');
          jq(createFieldSelector( "Type__c" )).click();
          jq(createFieldInputSelector( "Type__c" )).attr('disabled', 'disabled');
          jq('.selectAllChk').attr('disabled', 'disabled');

          jq(this).find(createFieldInputSelector( "ProjectedPaidTickets__c")).attr('disabled', false);
          jq(this).find(createFieldInputSelector( "ShowOnOffer__c")).attr('disabled', false);
          jq(this).find(createFieldInputSelector( "Notes__c")).attr('disabled', false);
      }
    });
}

function hideNonAuditFields() {
	jq('#gbMainTable tr').find(createFieldSelector( "Unsold__c")).hide();
	jq('#gbMainTable tr').find(createFieldSelector( "Holds__c")).hide();
	jq('#gbMainTable tr').find(createFieldSelector( "ActualSalesToDate__c")).hide();
	jq('#gbMainTable tr').find(createFieldSelector( "ActualGrossToDate__c")).hide();
	jq('#gbMainTable tr').find(createFieldSelector( "ForecastSalesToGo__c")).hide();
	jq('#gbMainTable tr').find(createFieldSelector( "ForecastGrossToGo__c")).hide();
}

function hideSaveButtons() {
	jq('.createNew,.editBtn').remove();
	jq('input.selectAllChk').remove();
	jq('input.dl').remove();
	jq('.deleteItem').remove();
}

function isAudit() {
	var gridType = window.location.href.match(/[&?]gridType=([^&?]+)($|[&?])/)[1];
	if (gridType != null && gridType != undefined && gridType == 'Audit') {
		return true;
	}

	return false;
}

jq( document ).ready( function(){
	//-- initialize everything here
	convertGridInfoMap( gridInfoMap );

	//"Total Per Show" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Total per Show');

	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "Capacity__c"), capacityKillCompsChangedHandler );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "Comps__c"), capacityKillCompsChangedHandler );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "Kills__c"), capacityKillCompsChangedHandler );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "Price__c"), priceChangedHandler );
	jq( "#gbMainTable" ).on( "change", createFieldInputSelector( "ProjectedPaidTickets__c"), projectedPaidTicketsChangedHandler );
	capacityKillCompsChangedHandler();
	
	jq('.saveBtn, .deleteItem').click(function() {
		parent.postMessage('Saving', '*');
	});

	gridStateMessagingController('nutter');

	parent.postMessage('Loaded','*');

	if (readOnlyGrid === true) {
		hideSaveButtons();
	}

	jq('.createNew').click(function() {
	    hideNonAuditFields();
	  });


	if (isAudit() == true) {
		hideSaveButtons();
		disableInputsForAudit();
	} else {
		hideNonAuditFields();
	}
	
});

