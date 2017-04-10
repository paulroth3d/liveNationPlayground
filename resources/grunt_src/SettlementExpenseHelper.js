var parentEvent = {};

function commonInit() {
	convertGridInfoMap(gridInfoMap);
	markTableReady(false);
	showEventTotalLabel();
	hideAndDisableCommonFields();
	formatGLsWithBreakouts();

	var observer = new MutationObserver(function(mutations) {
	      mutations.forEach(function(mutationRecord) {
	          if (mutationRecord.target.childElementCount > 0) {
	          	hideAndDisableCommonFields();
	          }
	      });
	  });

	  var target = document.getElementsByClassName('fixedHeaderContainer');
	  for (var i = 0; i < target.length; i++) {
	    observer.observe(target[i], { childList : true });
	  }

	  window.addEventListener("message", listenForEventResponse, false);
	  window.parent.postMessage({'requestedAction': 'getEventObject'}, '*');
}

function listenForEventResponse(event) {
	if (event.data.requestedAction === 'parentEventData') {
		if (event.data.data) {
			try {
				parentEvent = JSON.parse(event.data.data);
			} catch (e) {
				console.log(e);
			}
		}
	}
}

function collapseHouseNutGrouping() {
	jq('.groupByRow.grp1 .grpValue').each(function(index,element){
		if (jq(element).text().startsWith('Yes')) {
			if (jq(element).closest('tr').hasClass('off') == false) {
				jq(element).closest('tr').click();
			}
		}
	});
}

function formatGLsWithBreakouts(){
	var rows = jq("#gbMainTable").find(".dr");
	for(var i = 0; i < rows.length; i++){
		var div = rows[i].closest("div");
		if(!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCountSettlement__c")).text()) > 0){
			
			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
		    jq(childrenRow).css("display", "table-row");
		    jq(jq(childrenRow).find("h3.toggleData")[0]).attr("class", "toggleData expanded");
			jq(jq(childrenRow).find("h3.toggleData")[1]).attr("class", "toggleData expanded fixed none");
		    jq(childrenRow).find(".childData").attr("class", "childData expanded");
		    jq(childrenRow).find(".childData").css("display", "block");

		    jq(rows[i]).find(createFieldSelector("SettlementRateType__c")).click();

		    inputs = jq(rows[i]).find("input,textarea");
		    for(var j = 0; j < inputs.length; j ++){

		    	inputs[j].readOnly = true;
		    	inputs[j].disabled = true;
		    	jq(inputs[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
		    }
		    
		    selects = jq(rows[i]).find("select");
            for (var j = 0; j < selects.length; j++) {

                selects[j].disabled = true;
                jq(selects[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
            }
		} else if (!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCountSettlement__c")).text()) == 0){
			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
			jq(jq(childrenRow).find(".childHeaderRow")).attr('style', 'display: table-row!important');
		}
	}

	collapseHouseNutGrouping();
}

function firstBreakoutCreation(evt){

	if (!evt || !evt.target) {
		return;
	}

	var childDataContainer = jq(evt.target).closest("tr").find(".childDataContainer");
	var tr = jq(childDataContainer).find(".none");
	var newRows = jq(childDataContainer).find(".nr");

	jq(newRows).find(createFieldInputSelector( "SettlementOnly__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])).each(function(index, element){
		jq(element).attr('checked','checked').change();
	});

	if(tr.length == 1 && newRows.length == 1){

		jq(childDataContainer).parent().parent().find(".createNew").click();
		//somehow the "click()" above generates two new rows (so we now have three)
		//so we need to delete the third one
		jq(childDataContainer).find(".firstCol").find(".minus").first().click();

		var generatedRow = jq(childDataContainer).find(".nr").first()[0];
		const nameToFind = jq(jq(evt.target).closest("tr")[0]).attr("name");
		var parentTrs = jq("#gbMainTable").find(`tr[name=${nameToFind}]`);
		var GLlevel;
		for(var i = 0; i < parentTrs.length; i++){
			if(!jq(parentTrs[i].closest("div")).hasClass("childDataContainer") && jq(parentTrs[i]).hasClass("dr")){
				GLlevel = parentTrs[i];
			}
		}

		var newDescription =  getInputValue( GLlevel, 'Description__c' );
		jq( generatedRow ).find( createFieldInputSelector( 'Description__c' ) ).val( newDescription ).change();

		var newSettlementRateType =  getInputValue( GLlevel, 'SettlementRateType__c' );
		jq( generatedRow ).find( createFieldSelector( 'SettlementRateType__c' ) ).click(); 
		jq( generatedRow ).find( createFieldInputSelector( 'SettlementRateType__c' ) ).val( newSettlementRateType ).change();

		var newPromoterAmountRate = getInputValue( GLlevel, 'PromoterAmountRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'PromoterAmountRate__c' ) ).val( newPromoterAmountRate ).change();

		var newPromoterAmount = getInputValue( GLlevel, 'PromoterAmount__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'PromoterAmount__c' ) ).val( newPromoterAmount ).change();

		var newArtistAmountRate = getInputValue( GLlevel, 'ArtistAmountRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'ArtistAmountRate__c' ) ).val( newArtistAmountRate ).change();

		var newArtistAmount = getInputValue( GLlevel, 'ArtistAmount__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'ArtistAmount__c' ) ).val( newArtistAmount ).change();
		
		var newVenueAmountRate = getInputValue( GLlevel, 'VenueAmountRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'VenueAmountRate__c' ) ).val( newVenueAmountRate ).change();

		var newVenueAmount = getInputValue( GLlevel, 'VenueAmount__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'VenueAmount__c' ) ).val( newVenueAmount ).change();

		var newLNTouringAmountRate = getInputValue( GLlevel, 'LNTouringAmountRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'LNTouringAmountRate__c' ) ).val( newLNTouringAmountRate ).change();

		var newLNTouringAmount = getInputValue( GLlevel, 'LNTouringAmount__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'LNTouringAmount__c' ) ).val( newLNTouringAmount ).change();

		var newSettlementNotes = getInputValue( GLlevel, 'SettlementNotes__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'SettlementNotes__c' ) ).val( newSettlementNotes ).change();
	}

	//find only new rows that haven't been saved to the database yet
	childDataContainer = jq(childDataContainer).find('.nr');

	var settlementRateTypeFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( 'SettlementRateType__c' ));

	var fieldsToClick = settlementRateTypeFieldsToClickAndShow.toArray();

    for (var i = 0; i < fieldsToClick.length; i++) {
    	jq(fieldsToClick[i]).click();
    }
}

function manageCalculationFields() {
	const fieldSelectors = `${createFieldSelector("SettlementRateType__c")},
						  	${createFieldSelector("PromoterAmountRate__c")},
						  	${createFieldSelector("ArtistAmountRate__c")},
						  	${createFieldSelector("VenueAmountRate__c")},
						  	${createFieldSelector("LNTouringAmountRate__c")}`;

	const showOrHide = viewCalculations() == true ? 'show' : 'hide';
	
	jq("#gbMainTable").find(fieldSelectors).each(function(index, el){
		if (jq(el).closest('tr').closest('table').attr('class') == 'mainTable') {
			jq(el)[showOrHide]();
		}
	});

	const breakoutFieldSelectors = `${createFieldSelector( "SettlementRateType__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  	${createFieldSelector( "PromoterAmountRate__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  	${createFieldSelector( "ArtistAmountRate__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  	${createFieldSelector( "VenueAmountRate__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  	${createFieldSelector( "LNTouringAmountRate__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])}`;

	jq("#gbMainTable table.childTable").find(breakoutFieldSelectors)[showOrHide]();

	const disabled = viewCalculations();

	const fieldAmountSelectors = `${createFieldInputSelector("PromoterAmount__c")},
						  		  ${createFieldInputSelector("ArtistAmount__c")},
						  		  ${createFieldInputSelector("VenueAmount__c")},
						  		  ${createFieldInputSelector("LNTouringAmount__c")}`;

	jq("#gbMainTable").find(fieldAmountSelectors).each(function(index, el){
		if (jq(el).closest('tr').closest('table').attr('class') == 'mainTable') {
			jq(el).attr('disabled', disabled);
		}
	});

	const breakoutAmountFieldSelectors = `${createFieldInputSelector( "PromoterAmount__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  		  ${createFieldInputSelector( "ArtistAmount__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  		  ${createFieldInputSelector( "VenueAmount__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  		  ${createFieldInputSelector( "LNTouringAmount__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])}`;

	jq("#gbMainTable table.childTable").find(breakoutAmountFieldSelectors).attr('disabled', disabled);
}

function viewCalculations() {
	var p = window.location.href.match(/[&?]showHideCalculations=([^&?]+)($|[&?])/)[1];
	if (p != null && p != undefined && p.indexOf('View') >= 0) {
		return false;
	}

	return true;
}

function calculateTotal(evt) {
	if (evt.target) {
		calculateTotalForRow(jq(evt.target).closest('tr'));
	} else {
		jq("#gbMainTable " + createFieldInputSelector( "PromoterAmount__c" ) ).each( function( index, el ){
	      var parentRow = jq(el).closest('tr');
	      calculateTotalForRow(parentRow);
	    });
	}
}

function calculateTotalForRow(row) {
	var promoter = getFloat(row, 'PromoterAmount__c');
	var artist = getFloat(row, 'ArtistAmount__c');
	var venue = getFloat(row, 'VenueAmount__c' );
	var touring = getFloat(row, 'LNTouringAmount__c' );

	var newTotal = promoter + artist + venue + touring;

	jq(row).find(createFieldInputSelector('Settlement__c')).val(formatNumber(newTotal)).change();
	calculateVarianceForRow(row);
}

function calculateVariance(evt) {
	if (evt.target) {
		calculateTotalForRow(jq(evt.target).closest('tr'));
	} else {
		jq("#gbMainTable " + createFieldInputSelector( "PromoterAmount__c" ) ).each( function( index, el ){
	      var parentRow = jq(el).closest('tr');
	      calculateTotalForRow(parentRow);
	    });
	}
}

function calculateVarianceForRow(row) {
	var offer = getFloat(row, 'OfferAtSellout__c');
	var total = getFloat(row, 'Settlement__c') ;

	var newVariance = offer - total;

	jq(row).find(createFieldSelector('SettlementExpenseVariance__c')).text(`USD ${formatNumber(newVariance)}`);
}

function runCalculations(evt) {
	if (evt.target) {
		runCalculationsForRow(jq(evt.target).closest('tr'), jq(evt.target).closest('td'));
	}
}

function runCalculationsForRow(row, changedField) {
	const changedFieldRateTypeName = gridInfoById[jq(changedField).attr('name')].fieldName;
	const fieldValueName = changedFieldRateTypeName.replace('Rate','');
	const settlementRateType = getInputValue(row, 'SettlementRateType__c');
	
	var amountRate = getFloat(row, changedFieldRateTypeName);
	var newAmount;
	var multiplier;

	if (!isBlank(settlementRateType)) {
		switch(settlementRateType) {
			case 'Flat':
				multiplier = 1;
				break;
			case 'Per Drop Count':
				multiplier = getNumber(parentEvent._props.ActualDropCount__c);
				break;
			case 'Per Paid Ticket':
				multiplier = getNumber(parentEvent._props.SettlementPaidTickets__c);
				break;
			case '% of Net Gross':
				amountRate /= 100;
				multiplier = getNumber(parentEvent._props.SettlementNetGross__c);
				break;
			case '% of Gross':
				amountRate /= 100;
				multiplier = getNumber(parentEvent._props.SettlementGross__c);
				break;
			case '% of Adjusted Gross':
				amountRate /= 100;
				multiplier = getNumber(parentEvent._props.SettlementAdjustedGross__c);
				break;
			default:
				break;
		}
	}

	if (!isBlank(multiplier)) {
		newAmount = amountRate * multiplier;
	}

	jq(row).find(createFieldInputSelector(fieldValueName)).val(formatNumber(newAmount)).change();
}

function settlementRateTypeChanged(evt) {
	if (evt.target) {
		const parentRow = jq(evt.target).closest('tr');
		runCalculationsForRow(parentRow, jq(parentRow).find(createFieldSelector("PromoterAmountRate__c")));
		runCalculationsForRow(parentRow, jq(parentRow).find(createFieldSelector("ArtistAmountRate__c")));
		runCalculationsForRow(parentRow, jq(parentRow).find(createFieldSelector("VenueAmountRate__c")));
		runCalculationsForRow(parentRow, jq(parentRow).find(createFieldSelector("LNTouringAmountRate__c")));
	}
}

function showEventTotalLabel() {
	var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');
}

function getFloat(row, field) {
	var result = parseFloat(sanitizeNumber(getInputValue(row, field)));
	if (!result) {
		result = parseFloat(sanitizeNumber(getText(row, field)));
	}

	if (!result || isNaN(result)) {
		return 0.0;
	}

	return result;
}

function getNumber(v) {
	return isBlank(v) ? 0.0 : v;
}

function getText(row, field) {
	return jq(row).find(createFieldSelector(field)).text();
}

function isBlank(v) {
	return v == null || v == undefined || v == "";
}

function createCommonChangeSelectors() {
	var changeSelectors = `${createFieldSelector("PromoterAmount__c")},
						   ${createFieldSelector("ArtistAmount__c")},
						   ${createFieldSelector("VenueAmount__c")},
						   ${createFieldSelector("LNTouringAmount__c")}`;
						   
	jq("#gbMainTable").on( 'change', changeSelectors, calculateTotal );

	var calculationChangeSelectors = `${createFieldSelector("PromoterAmountRate__c")},
						   			  ${createFieldSelector("ArtistAmountRate__c")},
						   			  ${createFieldSelector("VenueAmountRate__c")},
						   			  ${createFieldSelector("LNTouringAmountRate__c")}`;
						   
	jq("#gbMainTable").on( 'change', calculationChangeSelectors, runCalculations );
	jq("#gbMainTable").on( 'change', createFieldSelector("SettlementRateType__c"), settlementRateTypeChanged );
}

function hideAndDisableCommonFields() {
	hideCommonFields();
	manageCalculationFields();
	disableCommonFields();
}

function disableCommonFields() {
	jq(createFieldInputSelector('Settlement__c')).attr("disabled", "disabled");
}

function hideCommonFields() {
	jq(createFieldSelector('RollUpCountSettlement__c')).hide();
	jq(createFieldSelector( "SettlementRateType__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])).hide();
}