/**
 *  Logic handler (NON DEV) version of the ancillary revenue section under the events page.
**/

var changed = false;

function platinumRecordChangedHandler( evt ){
	console.log( "something changed and fields need to get recalculated" );

	if( !isTableReady() ){
		//-- don't dispatch the event until the table is ready
		return;
	}

	if(jq(this.closest("tr")).hasClass("nr")){
		return;
	}
	console.log(changed);
	if(changed){
		return;
	}

	if (isSettlement() == true) {
		var parentRow = jq(evt.target).closest('tr');
		var actualGrossToDate = sanitizeNumber(jq(parentRow).find(createFieldSelector('ActualGrossToDate__c')).text());
		var liftBeforeFee = sanitizeNumber(getInputValue(parentRow, 'LiftBeforeFee__c'));

		actualGrossToDate = (actualGrossToDate == null) ? 0 : actualGrossToDate;
		liftBeforeFee = (liftBeforeFee == null) ? 0 : liftBeforeFee;

		var newProceeds = parseFloat(actualGrossToDate) + parseFloat(liftBeforeFee);
		var newProceedsText = 'USD ' + formatNumber(newProceeds);

		jq(parentRow).find(createFieldSelector('TotalPlatinumSeatProceeds__c')).text(newProceedsText);

		var tmFeePercent = sanitizeNumber(getInputValue(parentRow, 'TMFeePercent__c'));
		tmFeePercent = (tmFeePercent == null) ? 0 : tmFeePercent/100;

		var newTMFee = newProceeds * parseFloat(tmFeePercent);
		var newTMFeeText = 'USD ' + formatNumber(newTMFee);
		var newLiftBeforeTaxes = parseFloat(liftBeforeFee) - newTMFee;
		var newLiftBeforeTaxesText = 'USD ' + formatNumber(newLiftBeforeTaxes);

		jq(parentRow).find(createFieldSelector('TMFee__c')).text(newTMFeeText);
		jq(parentRow).find(createFieldSelector('LiftBeforeTaxes__c')).text(newLiftBeforeTaxesText);
	} else {
		var platinumProjectedGrossSales = 0;
		var ticketScale = {};
		ticketScale.Id = this.parentElement.getAttribute("id");
		if(this == jq(this.parentElement).find(createFieldSelector("AverageLiftPerTicket__c"))[0]){
			console.log("AverageLiftPerTicket__c on change");
			ticketScale.AverageLiftPerTicket__c = sanitizeNumber(getInputValue(this.parentElement, 'AverageLiftPerTicket__c'));
			ticketScale.LiftBeforeFee__c = null;
			ticketScale.ProjectedPaidTickets__c = null;
			ticketScale.Price__c = null;
			ticketScale.TMFeePercent__c = getInputValue(this.parentElement, 'TMFeePercent__c');
		}else if(this == jq(this.parentElement).find(createFieldSelector("LiftBeforeFee__c"))[0]){
			console.log("LiftBeforeFee__c on change");
			ticketScale.LiftBeforeFee__c = sanitizeNumber(getInputValue(this.parentElement, 'LiftBeforeFee__c'));
			ticketScale.AverageLiftPerTicket__c = null;
			ticketScale.ProjectedPaidTickets__c = null;
			ticketScale.Price__c = null;
			ticketScale.TMFeePercent__c = getInputValue(this.parentElement, 'TMFeePercent__c');
		}else{
			ticketScale.LiftBeforeFee__c = sanitizeNumber(getInputValue(this.parentElement, 'LiftBeforeFee__c'));
			ticketScale.AverageLiftPerTicket__c =  sanitizeNumber(getInputValue(this.parentElement, 'AverageLiftPerTicket__c'));;
			ticketScale.ProjectedPaidTickets__c = null;
			ticketScale.Price__c = null;
			ticketScale.TMFeePercent__c = getInputValue(this.parentElement, 'TMFeePercent__c');
		}

		var url = createApexURL( "LNE_PlatinumLiftCalculatorAPI" );
		//console.log( "calling[" + url + "]" );

		jq.ajax({
			url: url,
			data: {
				'TicketScale__c': JSON.stringify( ticketScale )
			},
			context: this,
			dataType: 'jsonp'
		}).done( function( results ){
			//debugger
			if( results && results.isSuccessful === true ){
				console.log( "fields updated" );
				console.log(results);
				changed = true;
				var newAverageLiftPerTicket = formatNumber( results.data.AverageLiftPerTicket__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.AverageLiftPerTicket__c.fieldName ) ).val( newAverageLiftPerTicket );
				var newLiftBeforeFee = formatNumber( results.data.LiftBeforeFee__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.LiftBeforeFee__c.fieldName ) ).val( newLiftBeforeFee );
				platinumProjectedGrossSales = parseFloat( results.data.ProjectedPaidTickets__c) * parseFloat(results.data.Price__c);
				var newTotalPlatinumSeatProceeds = parseFloat(platinumProjectedGrossSales) + parseFloat(results.data.LiftBeforeFee__c);
				var newTMFee = newTotalPlatinumSeatProceeds * (parseFloat(results.data.TMFeePercent__c)/100);
				var newLiftBeforeTaxes = parseFloat(results.data.LiftBeforeFee__c) - newTMFee;
				this.parentElement.getElementsByTagName("td")[createFieldSelector("TotalPlatinumSeatProceeds__c").replace("td[name=", "").replace("]", "")].innerHTML = 'USD ' + (formatNumber(newTotalPlatinumSeatProceeds));
				this.parentElement.getElementsByTagName("td")[createFieldSelector("TMFee__c").replace("td[name=", "").replace("]", "")].innerHTML = 'USD ' + (formatNumber(newTMFee));
				this.parentElement.getElementsByTagName("td")[createFieldSelector("LiftBeforeTaxes__c").replace("td[name=", "").replace("]", "")].innerHTML = 'USD ' + (formatNumber(newLiftBeforeTaxes));

				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.AverageLiftPerTicket__c.fieldName ) ).change();
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.LiftBeforeFee__c.fieldName ) ).change();
				changed = false;
				console.log(changed);

			} else {
				//-- the service ran into a problem, but not catestrophic.
				console.log( "service error. something likely wasn't set correctly so we tell the user" );
				alert( results.message );
			}
		}).fail( function(){
			//-- this should only happen if the service is not found or the results are not in JSON.
			console.log( "service failure" );
			debugger;
		}).always( function(){
			//console.log( "always jsonp" );
		});
		console.log("end");
	}
}

/**
 *  logic that makes the calculation for Average Lift Per Ticket if Projected Paid Ticket has changed
 *  <p>Called on document.ready</p>
 **/

function calculateAverageLiftPerTicket() {
    var rows = jq("#gbMainTable").find(".dr");
    for (var i = 0; i < rows.length; i++) {
    	if(!jq(rows[i]).hasClass('pnd')){
        	var projectedPaidTickets = parseFloat(rows[i].getElementsByTagName("td")[
           		createFieldSelector("ProjectedPaidTickets__c").replace("td[name=",
            	"").replace("]", "")].innerHTML.replace(
           		"<div>SUM</div>USD ", "").replace(",", ""));
        	var liftBeforeFee =  sanitizeNumber(getInputValue(rows[i], 'LiftBeforeFee__c'));
     		var averageLiftPerTicket = sanitizeNumber(getInputValue(rows[i], 'AverageLiftPerTicket__c'));
     		console.log(projectedPaidTickets);
     		console.log(liftBeforeFee);
     		console.log(averageLiftPerTicket);
     		console.log( (liftBeforeFee / projectedPaidTickets).toFixed(2));
        	if (averageLiftPerTicket != (liftBeforeFee / projectedPaidTickets).toFixed(2) && averageLiftPerTicket != "") {
       		 		changed = true;
       		 		jq( rows[i] ).find( createFieldInputSelector( gridInfoByField.AverageLiftPerTicket__c.fieldName ) ).val( (liftBeforeFee / projectedPaidTickets).toFixed(2) ).change();
        			changed = false;

        	}
    	}
    }
}

function hideFieldsOnSettlementGrid() {
	jq(createFieldSelector('ProjectedPaidTickets__c')).hide();
	jq(createFieldSelector('ProjectedGrossSales__c')).hide();
	jq(createFieldSelector('AverageLiftPerTicket__c')).hide();
	jq(createFieldSelector('ShowPlatinumOnOffer__c')).hide();
}

function hideFieldsOnNonSettlement() {
	jq(createFieldSelector('ActualSalesToDate__c')).hide();
	jq(createFieldSelector('ActualGrossToDate__c')).hide();
}

function isSettlement() {
	var gridType = window.location.href.match(/[&?]gridType=([^&?]+)($|[&?])/)[1];
	if (gridType != null && gridType != undefined && gridType == 'Settlement') {
		return true;
	}

	return false;
}

jq(document).ready( function(){
	console.log('platinum lift ready');

	var initialFocus = true;

	//-- always call after jq(document).ready for all scripts
	convertGridInfoMap( gridInfoMap );

	//-- mark the grid as not ready, so change events should not be fired
	markTableReady( false );

	 //"Total Per Show" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Total per Show');

	calculateAverageLiftPerTicket();

	if ( readOnlyGrid === false ) {
		//-- change handler for the RateType__c cell (not input) but that can be through createFieldInputSelector
		console.log(gridInfoByField);
		var changeSelectors =  createFieldSelector("AverageLiftPerTicket__c") + ', '+ createFieldSelector("LiftBeforeFee__c") + ', ' + createFieldSelector("TMFeePercent__c");
		jq("#gbMainTable").on( 'change', changeSelectors, platinumRecordChangedHandler);
	} else {
		jq('.createNew,.editBtn').remove();
		jq('input.selectAllChk').remove();
		jq('input.dl').remove();
		jq('.deleteItem').remove();
	}

	jq('.saveBtn').mousedown(function(){
		calculateAverageLiftPerTicket();
	});

	if (isSettlement() == true) {
		hideFieldsOnSettlementGrid();
	} else {
		hideFieldsOnNonSettlement();
	}

	jq('.saveBtn').click(function() {
		parent.postMessage('SavingPL', '*');
	});

	parent.postMessage('Loaded','*');
	
	markTableReady(true);
	gridStateMessagingController();
	
});