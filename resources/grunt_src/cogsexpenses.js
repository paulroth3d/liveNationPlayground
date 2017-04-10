

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

        //- if ledgerEntryId is null or less than 15 characters (Salesforce IDs have 15 or 18 characters)
        //- it means that this row hasn't been saved to the database yet
        if (ledgerEntryId != null && ledgerEntryId != undefined && ledgerEntryId.length >= 15) {
            if( newTicketScale == "Selected Tickets" ){
                console.log( "selected tickets selected" );
                var url = createApexURL( "LNE_AssignTicketScalesToLedgerEntries?id=" + eventId + "&ledgerEntryId=" + ledgerEntryId );
                console.log( url );
                
                overlayWindow = window.open( url, "_blank", "location=no,width=400,height=585" );
            }
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
			//console.log( arguments );
			var parentRow = el.parentElement;
			if( parentRow && parentRow.hasAttribute( "id" )){
				var newRateType = getInputValue( parentRow, 'RateType__c' );
				rateTypeChanged( parentRow, newRateType );
			}
		});
	}
}
 
function ledgerEntryChangedHandler( evt ) {
	   

       if  (jq(this.parentElement).hasClass("nr")) {
        return;
    }

    if (jq(this.closest("div")).hasClass("childDataContainer")) {

        console.log('ledgerEntryChangedHandler evt is',evt);
        var ledgerEntryBreakout = {};
        ledgerEntryBreakout.Id = this.parentElement.getAttribute("id");
        
        ledgerEntryBreakout.RateType__c = getInputValue(this.parentElement,
            'RateType__c');
        ledgerEntryBreakout.BaseAmount__c = sanitizeNumber(getInputValue(this.parentElement,
            'BaseAmount__c'));
        ledgerEntryBreakout.ApplyTicketScale__c = getInputValue(this.parentElement,
            'ApplyTicketScale__c');
        ledgerEntryBreakout.Min__c = sanitizeNumber(getInputValue(this.parentElement,
            'Min__c'));
        ledgerEntryBreakout.Max__c = sanitizeNumber(getInputValue(this.parentElement,
            'Max__c'));

        //-- the event is always going to be more up to date.
        //var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
        //ledgerEntry[ currentField ] = evt.target.value;

        var url = createApexURL("LNE_CogsExpensesAPI");

        console.log(JSON.stringify(ledgerEntryBreakout));

        jq.ajax({
            url: url,
            data: {
                'LedgerEntryBreakout__c': JSON.stringify(ledgerEntryBreakout)
            },
            context: this,
            dataType: 'jsonp'
        }).done(function(results) {
            //debugger
            if (results && results.isSuccessful === true) {
                console.log("fields updated. returned result obj is ",results);

                var newCOGSAtForecast__c = results.data.COGSatForecast__c;
                
                if (newCOGSAtForecast__c) {
                    newCOGSAtForecast__c = formatNumber(newCOGSAtForecast__c);
                }

                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.COGSAtForecast__c.fieldName)).val(
                    newCOGSAtForecast__c).change();
            } else {
                //-- the service ran into a problem, but not catestrophic.
                console.log(
                    "non-catestrophic service error. something likely wasn't set correctly so we tell the user"
                );
                alert(results.message);
            }
        }).fail(function() {
            //-- this should only happen if the service is not found or the results are not in JSON.
            console.log("service failure");
            debugger;
        }).always(function() {
            //console.log( "always jsonp" );
        });
    }else{

        console.log('ledgerEntryChangedHandler evt is',evt);
        var ledgerEntry = {};
        ledgerEntry.Id = this.parentElement.getAttribute("id");
        
        ledgerEntry.RateType__c = getInputValue(this.parentElement,
            'RateType__c');
        ledgerEntry.BaseAmount__c = sanitizeNumber(getInputValue(this.parentElement,
            'BaseAmount__c'));
        ledgerEntry.ApplyTicketScale__c = getInputValue(this.parentElement,
            'ApplyTicketScale__c');
        ledgerEntry.Min__c = sanitizeNumber(getInputValue(this.parentElement,
            'Min__c'));
        ledgerEntry.Max__c = sanitizeNumber(getInputValue(this.parentElement,
            'Max__c'));

        //-- the event is always going to be more up to date.
        //var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
        //ledgerEntry[ currentField ] = evt.target.value;

        var url = createApexURL("LNE_CogsExpensesAPI");

        console.log(JSON.stringify(ledgerEntry));

        jq.ajax({
            url: url,
            data: {
                'LedgerEntry__c': JSON.stringify(ledgerEntry)
            },
            context: this,
            dataType: 'jsonp'
        }).done(function(results) {
            //debugger
            if (results && results.isSuccessful === true) {
                console.log("fields updated. returned result obj is ",results);

                var newCOGSAtForecast__c = results.data.COGSAtForecast__c;
                
                if (newCOGSAtForecast__c) {
                	newCOGSAtForecast__c = formatNumber(newCOGSAtForecast__c);
                }

                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.COGSAtForecast__c.fieldName)).val(
                    newCOGSAtForecast__c).change();
            } else {
                //-- the service ran into a problem, but not catestrophic.
                console.log(
                    "non-catestrophic service error. something likely wasn't set correctly so we tell the user"
                );
                alert(results.message);
            }
        }).fail(function() {
            //-- this should only happen if the service is not found or the results are not in JSON.
            console.log("service failure");
            debugger;
        }).always(function() {
            //console.log( "always jsonp" );
        });
    }

}

/**
 *  logic that makes the calculation fields readonly and disabled to prevent user input.
 *  <p>Called on document.ready</p>
 **/
function disableCalculatedFields() {
	console.log('disableCalculatedFields');
	
	var COGSAtForecastFields = jq("#gbMainTable").find(createFieldInputSelector(
        "COGSAtForecast__c"));

	for (var i = 0; i < COGSAtForecastFields.length; i++) {
        COGSAtForecastFields[i].readOnly = true;
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


/**
*	Formats the cogs expenses with breakouts
*	Called on document.ready
**/

function formatGLsWithBreakouts() {

	console.log("format GL with breakouts");
    var rows = jq("#gbMainTable").find(".dr");
    for (var i = 0; i < rows.length; i++) {
        var div = rows[i].closest("div");
        if (!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass(
                "nd") && parseInt(jq(rows[i]).find(createFieldSelector(
                "RollUpCount__c")).text()) > 0) {

            var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[
                i]).attr("name") + "].cr")[0];
            jq(childrenRow).css("display", "table-row");
            console.log(jq(childrenRow).find("h3.toggleData"));
            jq(jq(childrenRow).find("h3.toggleData")[0]).attr("class",
                "toggleData expanded");
            jq(jq(childrenRow).find("h3.toggleData")[1]).attr("class",
                "toggleData expanded fixed none");
            jq(childrenRow).find(".childData").attr("class",
                "childData expanded");
            jq(childrenRow).find(".childData").css("display", "block");

           jq(rows[i]).find(createFieldSelector( gridInfoByField.RateType__c.fieldName)).click();
            jq(rows[i]).find(createFieldSelector( gridInfoByField.ApplyTicketScale__c.fieldName)).click();
            inputs = jq(rows[i]).find("input");
            for (var j = 0; j < inputs.length; j++) {

                inputs[j].readOnly = true;
                inputs[j].disabled = true;
                jq(inputs[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
            }
            selects = jq(rows[i]).find("select");
            for (var j = 0; j < selects.length; j++) {

                selects[j].disabled = true;
                jq(selects[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
            }
        }else if (!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCount__c")).text()) == 0){

			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
			jq(jq(childrenRow).find(".childHeaderRow")).attr('style', 'display: table-row!important');


		}

    }


}

/**
 *  logic that creates two breakout levels and copies the info from the GL parent, once the first breakout ledger entry is created.
 *  <p>Called on click of new buttons</p>
 **/
function firstBreakoutCreation(event){

    if (!event || !event.target) {
        return;
    }
    
    var childDataContainer = jq(event.target).closest("tr").find(".childDataContainer");
    var tr = jq(childDataContainer).find(".nd");
    var newRows = jq(childDataContainer).find(".nr");
    
    if(tr.length == 1 && newRows.length == 1){
        console.log("first breakout");

        jq(childDataContainer).parent().parent().find(".createNew").click();
        //somehow the "click()" above generates two new rows (so we now have three)
        //so we need to delete the third one
        jq(childDataContainer).find(".firstCol").find(".minus").first().click();

        var generatedRow = jq(childDataContainer).find(".nr").first()[0];
        const nameToFind = jq(jq(event.target).closest("tr")[0]).attr("name");
        var parentTrs = jq("#gbMainTable").find(`tr[name=${nameToFind}]`);
        var GLlevel;
        for(var i = 0; i < parentTrs.length; i++){
            if(!jq(parentTrs[i].closest("div")).hasClass("childDataContainer") && jq(parentTrs[i]).hasClass("dr")){
                GLlevel = parentTrs[i];
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
        var newMin = getInputValue( GLlevel, 'Min__c' );
        jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.Min__c.fieldName ) ).val( newMin ).change();
        var newCOGSAtForecast = getInputValue( GLlevel, 'COGSAtForecast__c' );
        jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.COGSAtForecast__c.fieldName ) ).val( newCOGSAtForecast ).change();   
        var newMax = getInputValue( GLlevel, 'Max__c' );
        jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.Max__c.fieldName ) ).val( newMax ).change();
    }

    //find only new rows that haven't been saved to the database yet
    childDataContainer = jq(childDataContainer).find('.nr');

    var rateTypeFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( gridInfoByField.RateType__c.fieldName ));
    var ticketScaleFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( gridInfoByField.ApplyTicketScale__c.fieldName ));

    var fieldsToClick = rateTypeFieldsToClickAndShow.toArray().concat(ticketScaleFieldsToClickAndShow.toArray());

    for (var i = 0; i < fieldsToClick.length; i++) {
        jq(fieldsToClick[i]).click();
    }
    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.RateType__c.fieldName )).attr("class","");
    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.BaseAmount__c.fieldName )).attr("class","");
    var rateTypeFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.RateType__c.fieldName ));
    var baseAmountFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.BaseAmount__c.fieldName ));
    var minFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.Min__c.fieldName ));
    var maxFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.Max__c.fieldName ));
    var ticketScaleFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.ApplyTicketScale__c.fieldName ));
    var COGSAtForecastFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.COGSAtForecast__c.fieldName ));
    var notesField = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.Notes__c.fieldName )); 

    var fieldsToDisable = minFields.toArray().concat(maxFields.toArray(),
                                                      ticketScaleFields.toArray(),
                                                      COGSAtForecastFields.toArray(),
                                                      rateTypeFields.toArray(),
                                                      baseAmountFields.toArray(),
                                                      notesField.toArray());

    for (var i = 0; i < fieldsToDisable.length; i++) {
        jq(fieldsToDisable[i]).attr("disabled", "disabled");
    }
}

function hideFields() {
    jq("#gbMainTable " + createFieldSelector("Category__c")).hide();
    jq("#gbMainTable " + createFieldSelector("RollUpCount__c")).hide();
    jq("#gbMainTable " + createFieldSelector("SelectedTicketScale__c")).hide();
}

/**
 *  Whether a Popup is currently open. Used exclusively for the focus events.
**/
isPopupOpen=false;

jq(document).ready( function(){
    var initialFocus = true;

	//debugger;
		
	//-- always call after jq(document).ready for all scripts
	convertGridInfoMap( gridInfoMap );
	
	//-- mark the grid as not ready, so change events should not be fired
	markTableReady( false );
	
	//-- makes the calculation fields readonly and disabled
    disableCalculatedFields();

    //-- formats the cogs expenses with breakouts
    formatGLsWithBreakouts();

    //"Event Total" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');

    hideFields();

    //-- logic that creates two breakout levels and copies the info from the GL parent, once the first breakout ledger entry is created.
    jq("#gbMainTable").on( 'click', '.createNew', function(event){
        firstBreakoutCreation(event);
        hideFields();
    });
	
	if( readOnlyGrid === false ){
		// change handler to calculate COGS At Forecast
		var changeSelectors = createFieldSelector("BaseAmount__c") +
            ', ' + createFieldSelector("ApplyTicketScale__c") + ', ' +
            createFieldSelector("Min__c") + ', ' + createFieldSelector(
                "Max__c");
        jq("#gbMainTable").on('change', changeSelectors,
            ledgerEntryChangedHandler);

        jq("#gbMainTable").on('change', createFieldSelector(
            "RateType__c"), rateTypeChangeHandler);
        rateTypeChangeHandler(null);

        jq("#gbMainTable").on('change', createFieldSelector(
                "ApplyTicketScale__c"),
            applyTicketScaleChangeHandler);
        jq("#gbMainTable").on('focus', createFieldSelector(
            "ApplyTicketScale__c"), function(evt) {
            if (!overlayWindow && initialFocus) {
                initialFocus = false;

                applyTicketScaleChangeHandler.apply(this,
                    arguments);
            } else {
                if (overlayWindow && !overlayWindow.closed) {
                    overlayWindow.close();
                }

                initialFocus = true;
                overlayWindow = null;

                ledgerEntryChangedHandler.apply(this,
                    arguments);
            }
        });
	}
	
	markTableReady(true);

	gridStateMessagingController();

});
