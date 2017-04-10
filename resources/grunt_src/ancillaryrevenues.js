
/** current window **/
var overlayWindow;

/**
 *  Logic handler (NON DEV) version of the ancillary revenue section under the events page.
 **/
function ancillaryRecordChangedHandler(evt) {
    console.log('ancillaryRecordChangedHandler begins');

    if  (jq(this.parentElement).hasClass("nr")) {
	    return;
	}

    if (jq(this.closest("div")).hasClass("childDataContainer")) {

        var ledgerEntryBreakout = {};
        ledgerEntryBreakout.Id = this.parentElement.getAttribute("id");
        ledgerEntryBreakout.RateType__c = getInputValue(this.parentElement,
            'RateType__c');
        ledgerEntryBreakout.BaseAmount__c = sanitizeNumber(getInputValue(this.parentElement,
            'BaseAmount__c'));
        ledgerEntryBreakout.ApplyTicketScale__c = getInputValue(this.parentElement,
            'ApplyTicketScale__c');
        ledgerEntryBreakout.X3rdPartyPercent__c = sanitizeNumber(getInputValue(
            this.parentElement, 'X3rdPartyPercent__c'));
        ledgerEntryBreakout.ContraPercent__c = sanitizeNumber(getInputValue(
            this.parentElement, 'ContraPercent__c'));
        ledgerEntryBreakout.ContraType__c = getInputValue(this.parentElement,
            'ContraType__c');
        ledgerEntryBreakout.Min__c = sanitizeNumber(getInputValue(this.parentElement,
            'Min__c'));
        ledgerEntryBreakout.ContraAmount__c = sanitizeNumber(getInputValue(this
            .parentElement, 'ContraAmount__c'));
        ledgerEntryBreakout.Max__c = sanitizeNumber(getInputValue(this.parentElement,
            'Max__c'));
        ledgerEntryBreakout.GrossRevenue__c = sanitizeNumber(getInputValue(this.parentElement,
            'GrossRevenue__c'));

        //-- the event is always going to be more up to date.
        //var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
        //ledgerEntry[ currentField ] = evt.target.value;

        var url = createApexURL("LNE_GridBuddyCalculationAPI");
        //console.log( "calling[" + url + "]" );
        console.log(JSON.stringify(ledgerEntryBreakout));
        jq.ajax({
            url: url,
            data: {
                'LedgerEntryBreakout__c': JSON.stringify(
                    ledgerEntryBreakout)
            },
            context: this,
            dataType: 'jsonp'
        }).done(function(results) {
            //debugger
            if (results && results.isSuccessful === true) {
                console.log("LNE_GridBuddyCalculationAPI LedgerEntryBreakout__c success. fields updated");
                var newGrossRevenue = formatNumber(results.data.GrossRevenue__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.GrossRevenue__c.fieldName)).val(
                    newGrossRevenue).change();
                var newGrossPerPaid = formatNumber(results.data.GrossPerPaid__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.GrossPerPaid__c.fieldName)).val(
                    newGrossPerPaid).change();
                var newContraAtForecast = formatNumber(results.data.ContraAtForecast__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.ContraAtForecast__c.fieldName
                )).val(newContraAtForecast).change();
                var newContraPercentAtForecast = formatNumber(
                    floatToPercent(results.data.Contra_At_Forecast__c)
                );
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.ContraPercentAtForecast__c.fieldName
                )).val(newContraPercentAtForecast).change();
                var newNetRevenue = formatNumber(results.data.Net_Revenue__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.NetRevenue__c.fieldName)).val(
                    newNetRevenue).change();
                var newNetPerPaid = formatNumber(results.data.NetPerPaid__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.NetPerPaid__c.fieldName)).val(
                    newNetPerPaid).change();
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

    } else {

        var ledgerEntry = {};
        ledgerEntry.Id = this.parentElement.getAttribute("id");
        ledgerEntry.RateType__c = getInputValue(this.parentElement,
            'RateType__c');
        ledgerEntry.BaseAmount__c = sanitizeNumber(getInputValue(this.parentElement,
            'BaseAmount__c'));
        ledgerEntry.ApplyTicketScale__c = getInputValue(this.parentElement,
            'ApplyTicketScale__c');
        ledgerEntry.X3rdPartyPercent__c = sanitizeNumber(getInputValue(this.parentElement,
            'X3rdPartyPercent__c'));
        ledgerEntry.ContraPercent__c = sanitizeNumber(getInputValue(this.parentElement,
            'ContraPercent__c'));
        ledgerEntry.ContraType__c = getInputValue(this.parentElement,
            'ContraType__c');
        ledgerEntry.Min__c = sanitizeNumber(getInputValue(this.parentElement,
            'Min__c'));
        ledgerEntry.ContraAmount__c = sanitizeNumber(getInputValue(this.parentElement,
            'ContraAmount__c'));
        ledgerEntry.Max__c = sanitizeNumber(getInputValue(this.parentElement,
            'Max__c'));
        ledgerEntry.GrossRevenue__c = sanitizeNumber(getInputValue(this.parentElement,
            'GrossRevenue__c'));

        //-- the event is always going to be more up to date.
        //var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
        //ledgerEntry[ currentField ] = evt.target.value;

        var url = createApexURL("LNE_GridBuddyCalculationAPI");
        //console.log( "calling[" + url + "]" );
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
                console.log("LNE_GridBuddyCalculationAPI LedgerEntry__c success. fields updated");
                var newGrossRevenue = formatNumber(results.data.GrossRevenue__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.GrossRevenue__c.fieldName)).val(
                    newGrossRevenue).change();
                var newGrossPerPaid = formatNumber(results.data.GrossPerPaid__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.GrossPerPaid__c.fieldName)).val(
                    newGrossPerPaid).change();
                var newContraAtForecast = formatNumber(results.data.ContraAtForecast__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.ContraAtForecast__c.fieldName
                )).val(newContraAtForecast).change();
                var newContraPercentAtForecast = formatNumber(
                    floatToPercent(results.data.ContraPercentAtForecast__c)
                );
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.ContraPercentAtForecast__c.fieldName
                )).val(newContraPercentAtForecast).change();
                var newNetRevenue = formatNumber(results.data.NetRevenue__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.NetRevenue__c.fieldName)).val(
                    newNetRevenue).change();
                var newNetPerPaid = formatNumber(results.data.NetPerPaid__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.NetPerPaid__c.fieldName)).val(
                    newNetPerPaid).change();
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
 *  Handler for when the ticketScale has changed (ApplyTicketScale__c)
 **/
function applyTicketScaleChangeHandler(evt) {
    console.log("applyticketscaleChangeHandler begins");
    var newTicketScale = evt.target.value;
    var ledgerEntryId = jq(this).closest("tr").attr("id");
    
    //- if ledgerEntryId is null or less than 15 characters (Salesforce IDs have 15 or 18 characters)
    //- it means that this row hasn't been saved to the database yet
    if (ledgerEntryId != null && ledgerEntryId != undefined && ledgerEntryId.length >= 15) {
        try {
            var eventId = getCurrentRecordId();
            if (newTicketScale == "Selected Tickets") {
                var url = createApexURL("LNE_AssignTicketScalesToLedgerEntries?id=" + eventId + "&ledgerEntryId=" + ledgerEntryId);
                overlayWindow = window.open(url, "_blank", "location=no,width=400,height=585");
            }
        } catch (err) {
            console.error("error occurred while opening ticket scale popup:" + err);
        }
    }
}


function rateTypeChanged(parentRow, newRateType) {
    try {
        const isFlat = (newRateType == "Flat");
        const rowMin = jq(parentRow).find(createFieldInputSelector('Min__c')).val();
        const rowMax = jq(parentRow).find(createFieldInputSelector('Max__c')).val();

        if (isFlat === true) {
            if (rowMin != '' && parseFloat(rowMin) !== 0) {
                jq(parentRow).find(createFieldInputSelector('Min__c')).val('').change();
            }

            if (rowMax != '' && parseFloat(rowMax) !== 0) {
                jq(parentRow).find(createFieldInputSelector('Max__c')).val('').change();
            }
        }

        jq(parentRow).find(createFieldInputSelector('Min__c')).attr("readonly",
            isFlat);
        jq(parentRow).find(createFieldInputSelector('Max__c')).attr("readonly",
            isFlat);
    } catch (err) {
        console.error('error occurred when the rateType changed:' + err);
        console.log(err);
    }
}

/** Change Handler for the rateType. **/
function rateTypeChangeHandler(evt) {
    console.log('rateType has changed');

    //debugger;

    if (evt) {
        var parentRow = evt.target.parentElement.parentElement;
        var newRateType = evt.target.value;

        rateTypeChanged(parentRow, newRateType);

        if(!jq(this.closest("tr")).hasClass("nr")){
            ancillaryRecordChangedHandler();
        }
    } else {
        console.log('evt null');
        jq("#gbMainTable " + createFieldSelector("RateType__c")).each(function(
            index, el) {
            console.log(arguments);
            var parentRow = el.closest('tr');
            if (parentRow && parentRow.hasAttribute("id")) {
                var newRateType = getInputValue(parentRow,
                    'RateType__c');
                rateTypeChanged(parentRow, newRateType);
            }
        });
    }
}

/**
 *  logic that hides/shows the min/max on the grid.
 *  <p>Called externally through a global action on the grid</p>
 **/
function toggleMinMax() {
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
 *  logic that makes the calculation fields readonly and disabled to prevent user input.
 *  <p>Called on document.ready</p>
 **/
function disableCalculatedFields() {
    var grossRevenueFields = jq("#gbMainTable").find(createFieldInputSelector(
        "GrossRevenue__c"));
    var grossPerPaid = jq("#gbMainTable").find(createFieldInputSelector(
        "GrossPerPaid__c"));
    var contraAtForecastFields = jq("#gbMainTable").find(
        createFieldInputSelector("ContraAtForecast__c"));
    var contraPercentAtForecastFields = jq("#gbMainTable").find(
        createFieldInputSelector("ContraPercentAtForecast__c"));
    var netRevenueFields = jq("#gbMainTable").find(createFieldInputSelector(
        "NetRevenue__c"));
    var netPerPaidFields = jq("#gbMainTable").find(createFieldInputSelector(
        "NetPerPaid__c"));

    for (var i = 0; i < grossRevenueFields.length; i++) {
        grossRevenueFields[i].readOnly = true;
        grossPerPaid[i].readOnly = true;
        contraAtForecastFields[i].readOnly = true;
        contraPercentAtForecastFields[i].readOnly = true;
        netRevenueFields[i].readOnly = true;
        netPerPaidFields[i].readOnly = true;
        grossRevenueFields[i].disabled = true;
        grossPerPaid[i].disabled = true;
        contraAtForecastFields[i].disabled = true;
        contraPercentAtForecastFields[i].disabled = true;
        netRevenueFields[i].disabled = true;
        netPerPaidFields[i].disabled = true;
    }
}

/**
 *  logic that makes the calculation for Contra % At Forecast at Summary Level
 *  <p>Called on document.ready</p>
 **/

function calculateContraPercentAtForecast() {
    var groupByRows = jq("#gbMainTable").find(".groupByRow");
    for (var i = 0; i < groupByRows.length; i++) {
        var GrossRevenue = parseFloat(groupByRows[i].getElementsByTagName("td")[
            createFieldSelector("GrossRevenue__c").replace("td[name=",
                "").replace("]", "")].innerHTML.replace(
            "<div>SUM</div>USD ", "").replace(",", ""));
        var ContraAtForecast = parseFloat(groupByRows[i].getElementsByTagName(
            "td")[createFieldSelector("ContraAtForecast__c").replace(
            "td[name=", "").replace("]", "")].innerHTML.replace(
            "<div>SUM</div>USD ", "").replace(",", ""));
        if (GrossRevenue > 0) {
            var ContraPercentAtForecast = ContraAtForecast / GrossRevenue;
            groupByRows[i].getElementsByTagName("td")[createFieldSelector(
                "ContraPercentAtForecast__c").replace("td[name=", "").replace(
                "]", "")].innerHTML = (ContraPercentAtForecast * 100).toFixed(
                2) + "%";

        }

    }
}

/**
 *  logic that formats the GL levels when there are breakouts, it expands the breakouts and makes the GL read only on load
 *  <p>Called on document.ready</p>
 **/

function formatGLsWithBreakouts() {

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

             var contraPercentAtForecast = parseFloat(jq(rows[i]).find(createFieldInputSelector( gridInfoByField.ContraPercentAtForecast__c.fieldName)).val()).toFixed(2);
              jq(rows[i]).find(createFieldInputSelector( gridInfoByField.ContraPercentAtForecast__c.fieldName)).val(contraPercentAtForecast);
            jq(rows[i]).find(createFieldSelector( gridInfoByField.RateType__c.fieldName)).click();
            jq(rows[i]).find(createFieldSelector( gridInfoByField.ApplyTicketScale__c.fieldName)).click();
            jq(rows[i]).find(createFieldSelector( gridInfoByField.ContraType__c.fieldName)).click();
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
	var tr = jq(childDataContainer).find(".none");
	var newRows = jq(childDataContainer).find(".pldisplayed");
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
        console.log(GLlevel);
        console.log(getInputValue(GLlevel, 'Description__c'));
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
		jq(jq(generatedRow).find("select")).attr("class", "");
	}

	//find only new rows that haven't been saved to the database yet
	childDataContainer = jq(childDataContainer).find('.nr');

	var rateTypeFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( gridInfoByField.RateType__c.fieldName ));
	var ticketScaleFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( gridInfoByField.ApplyTicketScale__c.fieldName ));
	var contraTypeFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( gridInfoByField.ContraType__c.fieldName ));

	var fieldsToClick = rateTypeFieldsToClickAndShow.toArray().concat(ticketScaleFieldsToClickAndShow.toArray(),
																	  contraTypeFieldsToClickAndShow.toArray());

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
    var contraTypeFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.ContraType__c.fieldName ));
    var contraAmountFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.ContraAmount__c.fieldName ));
    var contraPercentFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.ContraPercent__c.fieldName ));
    var thirdPartyPercentFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.X3rdPartyPercent__c.fieldName ));
    var grossRevenueFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.GrossRevenue__c.fieldName ));
    var grossPerPaidFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.GrossPerPaid__c.fieldName ));
    var contraAtForecastFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.ContraAtForecast__c.fieldName ));
    var contraPercentAtForecastFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.ContraPercentAtForecast__c.fieldName ));
    var netRevenueFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.NetRevenue__c.fieldName ));
    var netPerPaidFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.NetPerPaid__c.fieldName ));
    var notesFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.Notes__c.fieldName )); 

    var fieldsToDisable = minFields.toArray().concat(maxFields.toArray(),
													  ticketScaleFields.toArray(),
													  contraTypeFields.toArray(),
													  contraAmountFields.toArray(),
													  contraPercentFields.toArray(),
													  thirdPartyPercentFields.toArray(),
													  grossRevenueFields.toArray(),
													  grossPerPaidFields.toArray(),
													  contraAtForecastFields.toArray(),
													  contraPercentAtForecastFields.toArray(),
													  netRevenueFields.toArray(),
													  netPerPaidFields.toArray(),
                                                      rateTypeFields.toArray(),
                                                      baseAmountFields.toArray(),
                                                      notesFields.toArray());

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
*
*	document.ready kicks off
*
**/

jq(document).ready(function() {
    var initialFocus = true;

    console.log('gbc_ancillaryrevenues_js document.ready fired');
    
    //-- always call after jq(document).ready for all scripts
    convertGridInfoMap(gridInfoMap);

    //-- mark the grid as not ready, so change events should not be fired
    markTableReady(false);

    //-- makes the calculation fields readonly and disabled
    disableCalculatedFields();

    //-- makes the calculation for Contra % at Forecast at Summary Level
    calculateContraPercentAtForecast();

    //-- formats the GL levels when there are breakouts
    formatGLsWithBreakouts();

    //"Event Total" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');

    hideFields();

    //-- logic to create the two breakout ledger entries on new button
    jq("#gbMainTable").on( 'click', '.createNew', function(event){
        firstBreakoutCreation(event);
        hideFields();
    });

    if (readOnlyGrid === false) {
        //-- change handler for the RateType__c cell (not input) but that can be through createFieldInputSelector
        var changeSelectors = createFieldSelector("BaseAmount__c") +
            ', ' + createFieldSelector("ApplyTicketScale__c") + ', ' +
            createFieldSelector("ContraPercent__c") + ', ' +
            createFieldSelector("X3rdPartyPercent__c") + ', ' +
            createFieldSelector("Min__c") + ', ' + createFieldSelector(
                "Max__c") + ', ' + createFieldSelector(
                "ContraAmount__c") + ', ' + createFieldSelector(
                "ContraType__c");
        jq("#gbMainTable").on('change', changeSelectors,
            ancillaryRecordChangedHandler);

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

                ancillaryRecordChangedHandler.apply(this,
                    arguments);
            }
        });
    }

    markTableReady(true);

	gridStateMessagingController();
});