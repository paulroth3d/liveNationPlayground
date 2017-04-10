
/** current window **/
var overlayWindow;

/**
 *  Logic handler (NON DEV) version of the ancillary revenue section under the events page.
**/
function ancillaryRecordChangedHandler( evt ){

	if(jq(this.closest("tr")).hasClass("nr")){
	return;
	}

	if(jq(this.closest("div")).hasClass("childDataContainer")){

	var ledgerEntryBreakout = {};
	ledgerEntryBreakout.Id = this.parentElement.getAttribute("id");
	ledgerEntryBreakout.RateType__c = getInputValue( this.parentElement, 'RateType__c' );
	ledgerEntryBreakout.BaseAmount__c = sanitizeNumber( getInputValue( this.parentElement, 'BaseAmount__c' ));
	ledgerEntryBreakout.ApplyTicketScale__c = getInputValue( this.parentElement, 'ApplyTicketScale__c' );
	ledgerEntryBreakout.X3rdPartyPercent__c = percentToFloat( getInputValue( this.parentElement, 'X3rdPartyPercent__c' ) );
	ledgerEntryBreakout.ContraPercent__c = percentToFloat( getInputValue( this.parentElement, 'ContraPercent__c' ) );
	ledgerEntryBreakout.ContraType__c = getInputValue( this.parentElement, 'ContraType__c' );
	ledgerEntryBreakout.Min__c = sanitizeNumber( getInputValue( this.parentElement, 'Min__c' ));
	ledgerEntryBreakout.ContraAmount__c = sanitizeNumber( getInputValue( this.parentElement, 'ContraAmount__c' ));
	ledgerEntryBreakout.Max__c = sanitizeNumber( getInputValue( this.parentElement, 'Max__c' ));
	
	
	
	//-- the event is always going to be more up to date.
	//var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
	//ledgerEntry[ currentField ] = evt.target.value;
	
	var url = createApexURL( "LNE_GridBuddyCalculationAPI" );
	//console.log( "calling[" + url + "]" );
	console.log(JSON.stringify(ledgerEntryBreakout));
	jq.ajax({
		url: url,
		data: {
			'LedgerEntryBreakout__c': JSON.stringify( ledgerEntryBreakout )
		},
		context: this,
		dataType: 'jsonp'
	}).done( function( results ){
		//debugger
		if( results && results.isSuccessful === true ){
			console.log( "fields updated" );
			var newGrossRevenue = formatNumber( results.data.GrossRevenue__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.GrossRevenue__c.fieldName ) ).val( newGrossRevenue ).change();
			var newGrossPerPaid = formatNumber( results.data.GrossPerPaid__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.GrossPerPaid__c.fieldName ) ).val( newGrossPerPaid ).change();
			var newContraAtForecast = formatNumber( results.data.ContraAtForecast__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.ContraAtForecast__c.fieldName ) ).val( newContraAtForecast ).change();
			var newContraPercentAtForecast = formatNumber( floatToPercent( results.data.Contra_At_Forecast__c ) );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.ContraPercentAtForecast__c.fieldName ) ).val( newContraPercentAtForecast ).change();
			var newNetRevenue = formatNumber( results.data.Net_Revenue__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.NetRevenue__c.fieldName ) ).val( newNetRevenue ).change();
			var newNetPerPaid = formatNumber( results.data.NetPerPaid__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.NetPerPaid__c.fieldName ) ).val( newNetPerPaid ).change();
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

	}else{
	
	var ledgerEntry = {};
	ledgerEntry.Id = this.parentElement.getAttribute("id");
	ledgerEntry.RateType__c = getInputValue( this.parentElement, 'RateType__c' );
	ledgerEntry.BaseAmount__c = sanitizeNumber( getInputValue( this.parentElement, 'BaseAmount__c' ));
	ledgerEntry.ApplyTicketScale__c = getInputValue( this.parentElement, 'ApplyTicketScale__c' );
	ledgerEntry.X3rdPartyPercent__c = percentToFloat( getInputValue( this.parentElement, 'X3rdPartyPercent__c' ) );
	ledgerEntry.ContraPercent__c = percentToFloat( getInputValue( this.parentElement, 'ContraPercent__c' ) );
	ledgerEntry.ContraType__c = getInputValue( this.parentElement, 'ContraType__c' );
	ledgerEntry.Min__c = sanitizeNumber( getInputValue( this.parentElement, 'Min__c' ));
	ledgerEntry.ContraAmount__c = sanitizeNumber( getInputValue( this.parentElement, 'ContraAmount__c' ));
	ledgerEntry.Max__c = sanitizeNumber( getInputValue( this.parentElement, 'Max__c' ));
	
	
	
	//-- the event is always going to be more up to date.
	//var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
	//ledgerEntry[ currentField ] = evt.target.value;
	
	var url = createApexURL( "LNE_GridBuddyCalculationAPI" );
	//console.log( "calling[" + url + "]" );
	console.log(JSON.stringify(ledgerEntry));
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
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.GrossRevenue__c.fieldName ) ).val( newGrossRevenue ).change();
			var newGrossPerPaid = formatNumber( results.data.GrossPerPaid__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.GrossPerPaid__c.fieldName ) ).val( newGrossPerPaid ).change();
			var newContraAtForecast = formatNumber( results.data.ContraAtForecast__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.ContraAtForecast__c.fieldName ) ).val( newContraAtForecast ).change();
			var newContraPercentAtForecast = formatNumber( floatToPercent( results.data.ContraPercentAtForecast__c ) );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.ContraPercentAtForecast__c.fieldName ) ).val( newContraPercentAtForecast ).change();
			var newNetRevenue = formatNumber( results.data.NetRevenue__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.NetRevenue__c.fieldName ) ).val( newNetRevenue ).change();
			var newNetPerPaid = formatNumber( results.data.NetPerPaid__c );
			jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.NetPerPaid__c.fieldName ) ).val( newNetPerPaid ).change();
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
			
			overlayWindow = window.open( url, "_blank", "location=no,width=400,height=585" );
		}
	} catch( err ){
		console.error( "error occurred while opening ticket scale popup:" + err );
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

/** Change Handler for the rateType. **/
function rateTypeChangeHandler( evt ){
	console.log( 'rateType has changed' );
	
	//debugger;
	
	if( evt ){
		var parentRow = evt.target.parentElement.parentElement;
		var newRateType = evt.target.value;
		
		rateTypeChanged( parentRow, newRateType );
		if(!jq(this.closest("tr")).hasClass("nr")){
			ancillaryRecordChangedHandler();
		}
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
	jq('li.reorderColsItem').trigger('click');
	jq('#reorderCols').hide();
	jq('#gbOverlay').hide();
	var listItems = jq('#rocContent').find('li.udcField');
	jq.each(listItems, function() {
		var thisListItem = jq(this);
		if (thisListItem.attr('name') == 'LedgerEntry__c:Min__c' || thisListItem.attr('name') == 'LedgerEntry__c:Max__c' || thisListItem.attr('name') == 'LedgerEntryBreakout__c:Min__c:LedgerEntry__c' || thisListItem.attr('name') == 'LedgerEntryBreakout__c:Max__c:LedgerEntry__c') {
			if (thisListItem.find('input[type="checkbox"]').is(':checked')) {
				thisListItem.find('input[type="checkbox"]').attr('checked', false);
			} else {
				thisListItem.find('input[type="checkbox"]').attr('checked', true);
			}
		}
	});
	jq('input.gbBtn.rocSaveBtn').trigger('click');

}

function disableCalculatedFields(){
	var grossRevenueFields = jq("#gbMainTable").find(  createFieldInputSelector("GrossRevenue__c"));
	var grossPerPaid = jq("#gbMainTable").find(  createFieldInputSelector("GrossPerPaid__c"));
	var contraAtForecastFields = jq("#gbMainTable").find(  createFieldInputSelector("ContraAtForecast__c"));
	var contraPercentAtForecastFields = jq("#gbMainTable").find(  createFieldInputSelector("ContraPercentAtForecast__c"));
	var netRevenueFields = jq("#gbMainTable").find(  createFieldInputSelector("NetRevenue__c"));
	var netPerPaidFields = jq("#gbMainTable").find(  createFieldInputSelector("NetPerPaid__c"));

	for(var i = 0; i < grossRevenueFields.length; i++){

		grossRevenueFields[i].readOnly = true;
		grossPerPaid[i].readOnly = true;
		contraAtForecastFields[i].readOnly = true;
		contraPercentAtForecastFields[i].readOnly= true;
		netRevenueFields[i].readOnly = true;
		netPerPaidFields[i].readOnly = true;

	}
}



function calculateContraPercentAtForecast(){
	var groupByRows = jq("#gbMainTable").find(".groupByRow");
	for(var i = 0; i < groupByRows.length; i++){
		
		var GrossRevenue = groupByRows[i].getElementsByTagName("td")[createFieldSelector("GrossRevenue__c").replace("td[name=", "").replace("]", "")].innerHTML.replace("<div>SUM</div>USD ", "").replace(",", "");
		var ContraAtForecast = groupByRows[i].getElementsByTagName("td")[createFieldSelector("ContraAtForecast__c").replace("td[name=", "").replace("]", "")].innerHTML.replace("<div>SUM</div>USD ", "").replace(",", "");
		var ContraPercentAtForecast = parseInt(ContraAtForecast) / parseInt(GrossRevenue);
		groupByRows[i].getElementsByTagName("td")[createFieldSelector("ContraPercentAtForecast__c").replace("td[name=", "").replace("]", "")].innerHTML = "<div>SUM</div>" + ContraPercentAtForecast + "%";

	}


}

function firstBreakoutCreation(){
	
	var childDataContainer = jq(this.closest("tr")).find(".childDataContainer");
	var tr = jq(childDataContainer).find(".none");
	var newRows = jq(childDataContainer).find(".pldisplayed");
	if(tr.length == 1 && newRows.length == 1){
		console.log("first breakout");
		var newId = parseInt(jq(newRows[0]).attr("id"))-1;
		var newName = "r" + (parseInt(jq(newRows[0]).attr("name").replace("r", ""))-1).toString();
		var newTr = document.createElement("tr");
		newTr.id = newId;
		newTr.innerHTML = jq.extend(true, {}, newRows[0]).innerHTML;
		jq(jq(childDataContainer).find(".ui-selectable tr:nth-child(1)")).after(newTr);
		var generatedRow = jq(childDataContainer).find("#"+ newId);
		jq(generatedRow).attr("name", newName);
		jq(generatedRow).attr("class", "dr nr pldisplayed" );
		var parentTrs = jq("#gbMainTable").find("tr[name="+ jq(jq(this.closest("tr"))[0]).attr("name") +"]");
		var GLlevel;
		for(var i = 0; i < parentTr.length; i++){
			if(!jq(parentTr[i].closest("div")).hasClass("childDataContainer")){
				GLlevel = parentTr[i];
			}
		}

		var newDescription =  getInputValue( GLlevel, 'Description__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.Description__c.fieldName ) ).val( newDescription ).change();
		var newRateType =  getInputValue( GLlevel, 'RateType__c' );
		jq( generatedRow ).find( createFieldSelector( gridInfoByField.RateType__c.fieldName ) ).click(); 
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.RateType__c.fieldName ) ).val( newRateType ).change();
		var newBaseAmount = getInputValue( GLlevel, 'BaseAmount__c' )
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.BaseAmount__c.fieldName ) ).val( newBaseAmount ).change();
		var newApplyTicketScale = getInputValue( GLlevel, 'ApplyTicketScale__c' );
		jq( generatedRow ).find( createFieldSelector( gridInfoByField.ApplyTicketScale__c.fieldName ) ).click(); 
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.ApplyTicketScale__c.fieldName ) ).click().val( newApplyTicketScale ).change();
		var new3rdPartyPercent = getInputValue( GLlevel, 'X3rdPartyPercent__c' ) ;
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.X3rdPartyPercent__c.fieldName ) ).val( new3rdPartyPercent ).change();
		var newContraPercent = getInputValue( GLlevel, 'ContraPercent__c' ) ;
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.ContraPercent__c.fieldName ) ).val( newContraPercent ).change();
		var newContraType = getInputValue( GLlevel, 'ContraType__c' );
		jq( generatedRow ).find( createFieldSelector( gridInfoByField.ContraType__c.fieldName ) ).click(); 
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.ContraType__c.fieldName ) ).val( newContraType ).change();
		var newMin = getInputValue( GLlevel, 'Min__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.Min__c.fieldName ) ).val( newMin ).change();
		var newContraAmount = getInputValue( GLlevel, 'ContraAmount__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.ContraAmount__c.fieldName ) ).val( newContraAmount ).change();	
		var newGrossRevenue = getInputValue( GLlevel, 'GrossRevenue__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.GrossRevenue__c.fieldName ) ).val( newGrossRevenue ).change();
		var newGrossPerPaid = getInputValue( GLlevel, 'GrossPerPaid__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.GrossPerPaid__c.fieldName ) ).val( newGrossPerPaid ).change();
		var newContraAtForecast = getInputValue( GLlevel, 'ContraAtForecast__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.ContraAtForecast__c.fieldName ) ).val( newContraAtForecast ).change();
		var newContraPercentAtForecast = getInputValue( GLlevel, 'ContraPercentAtForecast__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.ContraPercentAtForecast__c.fieldName ) ).val( newContraPercentAtForecast ).change();
		var newMax = getInputValue( GLlevel, 'Max__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.Max__c.fieldName ) ).val( newMax ).change();
		var newnetRevenue = getInputValue( GLlevel, 'NetRevenue__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.NetRevenue__c.fieldName ) ).val( newnetRevenue ).change();
		var newNetPerPaid = getInputValue( GLlevel, 'NetPerPaid__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.NetPerPaid__c.fieldName ) ).val( newNetPerPaid ).change();




	}
}


function formatGLsWithBreakouts(){

var rows = jq("#gbMainTable").find(".dr");
	for(var i = 0; i < rows.length; i++){
		var div = rows[i].closest("div");
		if(!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCount__c")).text()) > 0){
			
			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
		    jq(childrenRow).css("display", "table-row");
		    jq(jq(childrenRow).find("h3.toggleData")[0]).attr("class", "toggleData expanded");
			jq(jq(childrenRow).find("h3.toggleData")[1]).attr("class", "toggleData expanded fixed none");
		    jq(childrenRow).find(".childData").attr("class", "childData expanded");
		    jq(childrenRow).find(".childData").css("display", "block");

		    inputs = jq(rows[i]).find("input");
		    for(var j = 0; j < inputs.length; j ++){

		    	inputs[j].readOnly = true;
		    	inputs[j].disabled = true;
		    	jq(inputs[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
		    }


		}else if (!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCount__c")).text()) == 0){

			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
			jq(jq(childrenRow).find(".childHeaderRow")).attr('style', 'display: table-row!important');


		}

	}


}



/**
 *  Whether a Popup is currently open. Used exclusively for the focus events.
**/
isPopupOpen=false;

jq(document).ready( function(){
		
	debugger;
	
	


	//-- always call after jq(document).ready for all scripts
	convertGridInfoMap( gridInfoMap );

	disableCalculatedFields();

	calculateContraPercentAtForecast()

	formatGLsWithBreakouts();
	
	jq('#gbMainTable').change(function(){})
	//-- hide Category by default
	jq("#gbMainTable " + createFieldSelector( "Category__c" ) ).hide();
	
	if( readOnlyGrid === false ){
		//-- change handler for the RateType__c cell (not input) but that can be through createFieldInputSelector
		var changeSelectors =  createFieldSelector("BaseAmount__c") + ', '+ createFieldSelector("ApplyTicketScale__c") + ', ' + createFieldSelector("ContraPercent__c") +', ' + createFieldSelector("X3rdPartyPercent__c") +', ' + createFieldSelector("Min__c") +', ' + createFieldSelector("Max__c") +', ' + createFieldSelector("ContraAmount__c") +', ' + createFieldSelector("ContraType__c");
		jq("#gbMainTable").on( 'change', changeSelectors, ancillaryRecordChangedHandler );
		

		jq("#gbMainTable").on( 'click', '.createNew', firstBreakoutCreation);

		jq("#gbMainTable").on( 'change', createFieldSelector("RateType__c"), rateTypeChangeHandler );
		rateTypeChangeHandler( null );
		
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

				ancillaryRecordChangedHandler.apply( this, arguments );
			}
		});
	}
});