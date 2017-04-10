 

/** current window **/
var overlayWindow;

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
			
			overlayWindow = window.open( url, "_blank", "location=no,width=400,height=585" );
		}
	} catch( err ){
		console.error( "error occurred while opening ticket scale popup:" + err );
	}
}

function rateTypeChanged( parentRow, newRateType ){
	
	if( !isTableReady() ){
		//-- don't dispatch the event until the table is ready
		return;
	}
	
	try {
		var isFlat = ( newRateType == "Flat" );
		if( isFlat ){
			jq( parentRow ).find( createFieldInputSelector( 'Min__c' ) ).val( '' ).change();
			jq( parentRow ).find( createFieldInputSelector( 'Max__c' ) ).val( '' ).change();
		}
		jq( parentRow ).find( createFieldInputSelector( 'Min__c' ) ).attr( "readonly", isFlat );
		jq( parentRow ).find( createFieldInputSelector( 'Max__c' ) ).attr( "readonly", isFlat );
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

/**
 *  logic that hides/shows the min/max on the grid.
 *  <p>Called externally through a global action on the grid</p>
**/
function toggleMinMax(){
	console.log( "MinMaxToggled" );
	jq("#gbMainTable " + createFieldSelector( "Min__c" ) ).toggle();
	jq("#gbMainTable " + createFieldSelector( "Max__c" ) ).toggle();
}

/**
 *  Whether a Popup is currently open. Used exclusively for the focus events.
**/
isPopupOpen=false;

jq(document).ready( function(){
		
	//debugger;
	
	//-- always call after jq(document).ready for all scripts
	convertGridInfoMap( gridInfoMap );
	
	//-- mark the grid as not ready, so change events should not be fired
	markTableReady( false );
	
	//-- default by turning the minMax off
	toggleMinMax();
	
	//-- hide Category by default
	jq("#gbMainTable " + createFieldSelector( "Category__c" ) ).hide();
	
	if( readOnlyGrid === false ){
		//-- change handler for the RateType__c cell (not input) but that can be through createFieldInputSelector
		var changeSelectors =  createFieldSelector("BaseAmount__c") + ', '+ createFieldSelector("ApplyTicketScale__c") +', ' + createFieldSelector("Min__c") +', ' + createFieldSelector("Max__c");
		
		jq("#gbMainTable").on( 'change', createFieldSelector("RateType__c"), rateTypeChangeHandler );
		
		jq("#gbMainTable").on( 'change', createFieldSelector( "ApplyTicketScale__c" ), applyTicketScaleChangeHandler );
		jq("#gbMainTable").on( 'focus', createFieldSelector( "ApplyTicketScale__c" ), function( evt ) {
			if ( !overlayWindow ) {
				console.log('!!!--- OPENING WINDOW ---!!!');
				applyTicketScaleChangeHandler.apply( this, arguments );
			} else {
				if ( overlayWindow.closed ) {
					console.log('!!!--- RESET OVERLAYWINDOW SINCE WINDOW IS CLOSED ---!!!');
					overlayWindow = null;
				}
			}
		});
	}
	
	markTableReady(true);
	rateTypeChangeHandler( null );
});