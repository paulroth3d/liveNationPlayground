/**
 *  Logic handler (NON DEV) version of the ancillary revenue section under the events page.
**/
function ancillaryRecordChangedHandler( evt ){
	console.log( "something changed in the rate type" );

	var ledgerEntry = {};
	ledgerEntry.Id = this.parentElement.getAttribute("id");
	ledgerEntry.RateType__c = getInputValue( this.parentElement, 'RateType__c' );
	ledgerEntry.BaseAmount__c = sanitizeNumber( getInputValue( this.parentElement, 'BaseAmount__c' ));
	ledgerEntry.ApplyTicketScale__c = getInputValue( this.parentElement, 'ApplyTicketScale__c' );
	ledgerEntry.X3rdPartyPercent__c = getInputValue( this.parentElement, 'X3rdPartyPercent__c' );
	ledgerEntry.ContraPercent__c = getInputValue( this.parentElement, 'ContraPercent__c' );
	ledgerEntry.ContraType__c = getInputValue( this.parentElement, 'ContraType__c' );
	ledgerEntry.Min__c = sanitizeNumber( getInputValue( this.parentElement, 'Min__c' ));
	ledgerEntry.ContraAmount__c = sanitizeNumber( getInputValue( this.parentElement, 'ContraAmount__c' ));
	ledgerEntry.Max__c = sanitizeNumber( getInputValue( this.parentElement, 'Max__c' ));

	//-- the event is always going to be more up to date.
	//var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
	//ledgerEntry[ currentField ] = evt.target.value;
	
	var url = createApexURL( "LNE_GridBuddyCalculationAPI" );
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
			var newGrossRevenue = formatNumber( results.data.GrossRevenue__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.GrossRevenue__c.fieldName ) ).val( newGrossRevenue );
			var newGrossPerPaid = formatNumber( results.data.GrossPerPaid__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.GrossPerPaid__c.fieldName ) ).val( newGrossPerPaid );
			var newContraAtForecast = formatNumber( results.data.ContraAtForecast__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.ContraAtForecast__c.fieldName ) ).val( newContraAtForecast );
			var newContraPercentAtForecast = formatNumber( results.data.ContraPercentAtForecast__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.ContraPercentAtForecast__c.fieldName ) ).val( newContraPercentAtForecast );
			var newNetRevenue = formatNumber( results.data.NetRevenue__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.NetRevenue__c.fieldName ) ).val( newNetRevenue );
			var newNetPerPaid = formatNumber( results.data.NetPerPaid__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.NetPerPaid__c.fieldName ) ).val( newNetPerPaid );
		} else {
			//-- the service ran into a problem, but not catestrophic.
			console.log( "non-catestrophic service error. something likely wasn't set correctly so we tell the user" );
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

			popupWindow = window.open( url, "_blank", "location=no,width=400,height=585" );
		}
	} catch( err ){
		console.error( "error occurred while opening ticket scale popup:" + err );
	}
}

/** Change Handler for the rateType. **/
function rateTypeChangeHandler( evt ){
	console.log( 'rateType has changed' );
	
	debugger;
	
	if( evt ){
		var parentRow = evt.target.parentElement.parentElement;
		var newRateType = evt.target.value;
		
		rateTypeChanged( parentRow, newRateType );
		
		ancillaryRecordChangedHandler();
	} else {
		jq("#gbMainTable " + createFieldSelector( "RateType__c" ) ).each( function( index, el ){
			console.log( arguments );
			var parentRow = el.parentElement;
			if( parentRow && parentRow.hasAttribute( "id" )){
				var newRateType = getInputValue( parentRow, 'RateType__c' );
				rateTypeChanged( parentRow, newRateType );
			}
		});
	}
}

/** Change Handler for the rateType. **/
function rateTypeChangeHandler( evt ){
	console.log( 'rateType has changed' );
	
	debugger;
	
	if( evt ){
		var parentRow = evt.target.parentElement.parentElement;
		var newRateType = evt.target.value;
		
		rateTypeChanged( parentRow, newRateType );
		
		ancillaryRecordChangedHandler();
	} else {
		jq("#gbMainTable " + createFieldSelector( "RateType__c" ) ).each( function( index, el ){
			console.log( arguments );
			var parentRow = el.parentElement;
			if( parentRow && parentRow.hasAttribute( "id" )){
				var newRateType = getInputValue( parentRow, 'RateType__c' );
				rateTypeChanged( parentRow, newRateType );
			}
		});
	}
}

function rateTypeChanged( parentRow, newRateType ){
	try {
		var isFlat = ( newRateType == "Flat" );
		if( isFlat ){
			jq( parentRow ).find( createFieldInputSelector( 'Min__c' ) ).val( '' );
			jq( parentRow ).find( createFieldInputSelector( 'Max__c' ) ).val( '' );
		}
		jq( parentRow ).find( createFieldInputSelector( 'Min__c' ) ).attr( "readonly", isFlat );
		jq( parentRow ).find( createFieldInputSelector( 'Max__c' ) ).attr( "readonly", isFlat );
	} catch( err ){
		console.error( 'error occurred when the rateType changed:' + err );
		console.log( err );
	}
}


/**
 *  logic that hides/shows the min/max on the grid.
 *  <p>Called externally through a global action on the grid</p>
**/
function toggleMinMax(){
	console.log( "MinMaxToggled" );
	jq("#gbMainTable " + createFieldSelector( "Min__c" ) ).toggle()
	jq("#gbMainTable " + createFieldSelector( "Max__c" ) ).toggle();
}


function getCurrentRecordId(){
	return( window.location.href.match( /[&?]fpv=([^&?]+)[&?]/ )[1] );
}

/**
 *  Whether a Popup is currently open. Used exclusively for the focus events.
**/

jq(document).ready( function(){

	//-- always call after jq(document).ready for all scripts
	convertGridInfoMap( gridInfoMap );
	
	//-- default by turning the minMax off
	toggleMinMax();
	
	//-- hide Category by default
	jq("#gbMainTable " + createFieldSelector( "Category__c" ) ).hide();
	
	if( readOnlyGrid === false ){
		//-- change handler for the RateType__c cell (not input) but that can be through createFieldInputSelector
		var changeSelectors =  createFieldSelector("BaseAmount__c") + ', '+ createFieldSelector("ApplyTicketScale__c") + ', ' + createFieldSelector("ContraPercent__c") +', ' + createFieldSelector("X3rdPartyPercent__c") +', ' + createFieldSelector("Min__c") +', ' + createFieldSelector("Max__c") +', ' + createFieldSelector("ContraAmount__c") +', ' + createFieldSelector("ContraType__c");
		jq("#gbMainTable").on( 'change', changeSelectors, ancillaryRecordChangedHandler );
		
		jq("#gbMainTable").on( 'change', createFieldSelector("RateType__c"), rateTypeChangeHandler );
		//-- grid isn't ready...
		rateTypeChangeHandler( null );
		
		jq("#gbMainTable").on( 'change', createFieldSelector( "ApplyTicketScale__c" ), applyTicketScaleChangeHandler );
		jq("#gbMainTable").on( 'focus', createFieldSelector( "ApplyTicketScale__c" ), function( evt ){
			if( !popupWindow ){
				console.log('!!!--- opening popup window ---!!!');
				ancillaryRecordChangedHandler.apply( this, arguments )
			} else {
				if ( overlayWindow.closed ) {
					console.log('!!!--- reset popup window since window is closed ---!!!');
					popupWindow = null;
				}

				applyTicketScaleChangeHandler.apply( this, arguments );
			}
		});

	}
});
