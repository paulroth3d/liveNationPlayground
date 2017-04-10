
/** current window **/
var overlayWindow;

/**
 *  Gets a boolean value from a gridbuddy input
 *  @param row (Element) - jQuery element of the row to select within
 *  @param fieldAPI (String) - api name of the field to ask for
**/
function getBooleanInputValue( row, fieldAPI ){
	if( !gridInfoByField.hasOwnProperty( fieldAPI )){
		throw( "gridInfoByField[" + fieldAPI + "] does not exist" );
	}
	var el = jq( row ).find( createFieldInputSelector( fieldAPI ) );
	if( !el || el.length < 1 ){
		//-- @TODO: investigate further - this happens if there is a select that hasn't been used yet... (facepalm)
		return( jq( row ).find( createFieldSelector( fieldAPI ) + " div" ).text() );
	} else {
		return( el.is(":checked") );
	}
}

/**
 *  Logic handler (NON DEV) version of the ancillary revenue section under the events page.
**/
function expenseRecordChangedHandler( evt ){
	console.log( "something changed in the rate type" );

	if( !isTableReady() ){
		//-- don't dispatch the event until the table is ready
		return;
	}

	var ledgerEntry = {};
	ledgerEntry.Id = this.parentElement.getAttribute("id");
	ledgerEntry.OfferRateType__c = getInputValue( this.parentElement, 'OfferRateType__c' );
	ledgerEntry.OfferRate__c = sanitizeNumber( getInputValue( this.parentElement, 'OfferRate__c' ));
	ledgerEntry.OfferMin__c = sanitizeNumber( getInputValue( this.parentElement, 'OfferMin__c' ));
	ledgerEntry.OfferMax__c = sanitizeNumber( getInputValue( this.parentElement, 'OfferMax__c' ));
	ledgerEntry.OfferAtSellout__c = sanitizeNumber( getInputValue( this.parentElement, 'OfferAtSellout__c' ));
	ledgerEntry.OfferAtProjection__c = sanitizeNumber( getInputValue( this.parentElement, 'OfferAtProjection__c' ));
	ledgerEntry.SettleAtActual__c = getBooleanInputValue( this.parentElement, 'SettleAtActual__c' );
	ledgerEntry.InHouseRateType__c = getInputValue( this.parentElement, 'InHouseRateType__c' );
	ledgerEntry.InHouseRate__c = sanitizeNumber( getInputValue( this.parentElement, 'InHouseRate__c' ));
	ledgerEntry.InHouseMin__c = sanitizeNumber( getInputValue( this.parentElement, 'InHouseMin__c' ));
	ledgerEntry.InHouseMax__c = sanitizeNumber( getInputValue( this.parentElement, 'InHouseMax__c' ));
	ledgerEntry.InHouseProjection__c = sanitizeNumber( getInputValue( this.parentElement, 'InHouseProjection__c' ));
	ledgerEntry.ExpenseAdjustment__c = sanitizeNumber( getInputValue( this.parentElement, 'ExpenseAdjustment__c' ));
	
	//-- the event is always going to be more up to date.
	//var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
	//ledgerEntry[ currentField ] = evt.target.value;

	var url = createApexURL( "LNE_EventExpenseCalculationAPI" );
	//console.log( "calling[" + url + "]" );

	jq.ajax({
		url: url,
		data: {
			'LedgerEntry__c': JSON.stringify( ledgerEntry )
		},
		context: this,
		dataType: 'jsonp'
	}).done( function( results ){
		//debugger
		if( results && results.isSuccessful === true ){
			console.log( "fields updated" );

			var newOfferAtSellout = formatNumber( results.data.OfferAtSellout__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.OfferAtSellout__c.fieldName ) ).val( newOfferAtSellout ).change();
			var newOfferAtProjection = formatNumber( results.data.OfferAtProjection__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.OfferAtProjection__c.fieldName ) ).val( newOfferAtProjection ).change();
			var newInHouseProjection = formatNumber( results.data.InHouseProjection__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.InHouseProjection__c.fieldName ) ).val( newInHouseProjection ).change();
			var newExpenseAdjustment = formatNumber( results.data.ExpenseAdjustment__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.ExpenseAdjustment__c.fieldName ) ).val( newExpenseAdjustment ).change();

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
}

/**
 *  Handler for when the ticketScale has changed (ApplyTicketScale__c)
**/
/*
function applyTicketScaleChangeHandler( evt ){
	console.log( "applyticketscale changes" );
	var newTicketScale = evt.target.value;
	var parentRow = evt.target.parentElement.parentElement;

	try {

		var eventId = getCurrentRecordId();
		var ledgerEntryId = parentRow.getAttribute("id");

		if( newTicketScale == "Selected Tickets" ){
			console.log( "selected tickets selected" );
			var url = createApexURL( "LNE_AssignTicketScalesToLedgerEntries?eventId=" + eventId + "&ledgerEntryId=" + ledgerEntryId );
			console.log( url );

			overlayWindow = window.open( url, "_blank", "location=no,width=400,height=585" );
		}
	} catch( err ){
		console.error( "error occurred while opening ticket scale popup:" + err );
	}
} 
*/

function rateTypeChanged( parentRow, newRateType ){

	if( !isTableReady() ){
		//-- don't dispatch the event until the table is ready
		return;
	}

	try {
		var isFlat = ( newRateType == "Flat" );
		if( isFlat ){
			jq( parentRow ).find( createFieldInputSelector( 'OfferMin__c' ) ).val( '' ).change();
			jq( parentRow ).find( createFieldInputSelector( 'OfferMax__c' ) ).val( '' ).change();
		}
		jq( parentRow ).find( createFieldInputSelector( 'OfferMin__c' ) ).attr( "readonly", isFlat );
		jq( parentRow ).find( createFieldInputSelector( 'OfferMax__c' ) ).attr( "readonly", isFlat );
	} catch( err ){
		console.error( 'error occurred when the rateType changed:' + err );
		console.log( err );
	}
}

/** Change Handler for the rateType. **/
function rateTypeChangeHandler( evt ){
	console.log( 'rateType has changed' );

	//debugger;

	if( evt ){
		var parentRow = evt.target.parentElement.parentElement;
		var newRateType = evt.target.value;

		rateTypeChanged( parentRow, newRateType );

		expenseRecordChangedHandler();
	} else {
		jq("#gbMainTable " + createFieldSelector( "OfferRateType__c" ) ).each( function( index, el ){
			console.log( arguments );
			var parentRow = el.parentElement;
			if( parentRow && parentRow.hasAttribute( "id" )){
				var newRateType = getInputValue( parentRow, 'OfferRateType__c' );
				rateTypeChanged( parentRow, newRateType );
			}
		});
	}
}

/**
 *  logic that hides/shows the min/max on the grid.
 *  <p>Called externally through a global action on the grid</p>
**/
/*
function toggleMinMax(){
	console.log( "MinMaxToggled" );
	jq("#gbMainTable " + createFieldSelector( "Min__c" ) ).toggle();
	jq("#gbMainTable " + createFieldSelector( "Max__c" ) ).toggle();
}
*/

/**
 *  logic that makes the calculation fields readonly and disabled to prevent user input.
 *  <p>Called on document.ready</p>
**/
function disableCalculatedFields(){

	var offerAtSelloutFields = jq("#gbMainTable").find(  createFieldInputSelector("OfferAtSellout__c"));
	var offerAtProjectionFields = jq("#gbMainTable").find(  createFieldInputSelector("OfferAtProjection__c"));
	var inHouseProjectionFields = jq("#gbMainTable").find(  createFieldInputSelector("InHouseProjection__c"));
	var expenseAdjustmentFields = jq("#gbMainTable").find(  createFieldInputSelector("ExpenseAdjustment__c"));

	for(var i = 0; i < offerAtSelloutFields.length; i++){

		offerAtSelloutFields[i].readOnly = true;
		offerAtProjectionFields[i].readOnly = true;
		inHouseProjectionFields[i].readOnly = true;
		expenseAdjustmentFields[i].readOnly= true;
	}
}

jq(document).ready( function(){
	var initialFocus = true;

	//-- always call after jq(document).ready for all scripts
	convertGridInfoMap( gridInfoMap );

	//-- mark the grid as not ready, so change events should not be fired
	markTableReady( false );

	//-- default by turning the minMax off
	//toggleMinMax();

	//-- makes the calculation fields readonly and disabled
	disableCalculatedFields();

	//-- hide Category by default
	//jq("#gbMainTable " + createFieldSelector( "Category__c" ) ).hide();

	if ( readOnlyGrid === false ) {
		//-- change handler for the RateType__c cell (not input) but that can be through createFieldInputSelector
		var changeSelectors =  createFieldSelector("OfferRateType__c") + ', '+ createFieldSelector("OfferRate__c") + ', ' + createFieldSelector("OfferMin__c") + ', ' + createFieldSelector("OfferMax__c") + ', ' + createFieldSelector("SettleAtActual__c") + ', ' + createFieldSelector("InHouseRateType__c") + ', ' + createFieldSelector("InHouseRate__c") + ', ' + createFieldSelector("InHouseMin__c") + ', ' + createFieldSelector("InHouseMax__c");
		jq("#gbMainTable").on( 'change', changeSelectors, expenseRecordChangedHandler );

		jq("#gbMainTable").on( 'change', createFieldSelector("OfferRateType__c"), rateTypeChangeHandler );
		rateTypeChangeHandler( null );

		//jq("#gbMainTable").on( 'change', createFieldSelector( "ApplyTicketScale__c" ), applyTicketScaleChangeHandler );
		/*
		jq("#gbMainTable").on( 'focus', createFieldSelector( "ApplyTicketScale__c" ), function( evt ) {
			if ( !overlayWindow && initialFocus ) {
				initialFocus = false;

				//applyTicketScaleChangeHandler.apply( this, arguments );
			} else {
				if ( overlayWindow && !overlayWindow.closed ) {
					overlayWindow.close();
				}

				initialFocus = true;
				overlayWindow = null;
				
				expenseRecordChangedHandler.apply( this, arguments );
			}
		});
		*/
	}

	markTableReady(true);
});
