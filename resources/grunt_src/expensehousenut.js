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

function rowHasHouseNutChecked(row) {
	return jq(row).closest('tr').find(createFieldInputSelector( 'HouseNut__c' )).is(':checked');
}

function rowIsX50148X(row) {
	return jq(row).closest('tr').find(createFieldSelector('GLAccount__c')).find(':contains("House Nut")').length > 0;
}

/**
 *  Logic handler (NON DEV) version of the ancillary revenue section under the events page.
**/
function expenseRecordChangedHandler( evt ){
	var nut = false;
	var ledgerString, o, parentCell, parentRow;
	console.log( "housenut - something changed in the rate type" );
	console.log('evt is ');
	console.log(evt);

	if( !isTableReady() || this == window){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);

	if(jq(this).closest("tr").hasClass("nr") || isHouseNutRow === true){
		return;
	}

	var ledgerEntry = {};
	var parentCell = jq(evt.target).closest('td');
	var parentRow = jq(evt.target).closest('tr');
	ledgerEntry.Id = jq(parentRow).attr('id');
	//this.parentElement = jq(parentRow).get(0);

	ledgerEntry.OfferRateType__c = getInputValue( parentRow, 'OfferRateType__c' );
	ledgerEntry.OfferRate__c = sanitizeNumber( getInputValue( parentRow, 'OfferRate__c' ));
	ledgerEntry.OfferRate__c = ledgerEntry.OfferRate__c || 0;
	ledgerEntry.OfferMin__c = sanitizeNumber( getInputValue( parentRow, 'OfferMin__c' ));
	ledgerEntry.OfferMin__c = ledgerEntry.OfferMin__c || 0;
	ledgerEntry.OfferMax__c = sanitizeNumber( getInputValue( parentRow, 'OfferMax__c' ));
	ledgerEntry.OfferMax__c = ledgerEntry.OfferMax__c || 0;
	ledgerEntry.OfferAtSellout__c = sanitizeNumber( getInputValue( parentRow, 'OfferAtSellout__c' ));
	ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferAtSellout__c  || 0;
	ledgerEntry.OfferAtProjection__c = sanitizeNumber( getInputValue( parentRow, 'OfferAtProjection__c' ));
	ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferAtProjection__c  || 0;
	ledgerEntry.SettleAtActual__c = getBooleanInputValue( parentRow, 'SettleAtActual__c' );
	ledgerEntry.SettleAtActual__c  = ledgerEntry.SettleAtActual__c;
	ledgerEntry.InHouseRateType__c = getInputValue( parentRow, 'InHouseRateType__c' );
	ledgerEntry.InHouseRateType__c = ledgerEntry.InHouseRateType__c || 0;
	ledgerEntry.InHouseRate__c = sanitizeNumber( getInputValue( parentRow, 'InHouseRate__c' ));
	ledgerEntry.InHouseRate__c = ledgerEntry.InHouseRate__c || 0;
	ledgerEntry.InHouseMin__c = sanitizeNumber( getInputValue( parentRow, 'InHouseMin__c' ));
	ledgerEntry.InHouseMin__c = ledgerEntry.InHouseMin__c || 0;
	ledgerEntry.InHouseMax__c = sanitizeNumber( getInputValue( parentRow, 'InHouseMax__c' ));
	ledgerEntry.InHouseMax__c = ledgerEntry.InHouseMax__c || 0;
	ledgerEntry.InHouseProjection__c = sanitizeNumber( getInputValue( parentRow, 'InHouseProjection__c' ));
	if (ledgerEntry.InHouseProjection__c.length === 0) {
		console.log('RESET ledgerEntry.InHouseProjection__c');
		ledgerEntry.InHouseProjection__c = 0;
	}
	ledgerEntry.ExpenseAdjustment__c = sanitizeNumber( getInputValue( parentRow, 'ExpenseAdjustment__c' ));
	ledgerEntry.ExpenseAdjustment__c = ledgerEntry.ExpenseAdjustment__c  || null;
	
	//-- the event is always going to be more up to date.
	//var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
	//ledgerEntry[ currentField ] = evt.target.value;
	console.log('ledgerEntry is');
	console.log(ledgerEntry);
	ledgerString = JSON.stringify( ledgerEntry );
	console.log(ledgerString);

	var url = createApexURL( "LNE_EventExpenseCalculationAPI" );
	//console.log( "calling[" + url + "]" );

	if(jq(this).closest("div").hasClass("childDataContainer")) {
		o = 'LedgerEntryBreakout__c';
	} else {
		o = 'LedgerEntry__c';
	}

	var sendData = {};
	sendData[o] = ledgerString;
	console.log('Updating GL Account or Breakout? - o = ' + o);
	console.log('send Data');
	console.log(sendData);

	jq.ajax({
		url: url,
		data: sendData,
		context: this,
		dataType: 'jsonp'
	}).done( function( results ){
		//debugger
		if( results && results.isSuccessful === true ){
			console.log( "fields updated" );
			console.log(results);
			
			if (results && results.data) {

				if (!results.data.OfferAtSellout__c) {
					results.data.OfferAtSellout__c = 0;
				}
				var newOfferAtSellout = formatNumber( results.data.OfferAtSellout__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.OfferAtSellout__c.fieldName ) ).val( newOfferAtSellout ).change();

				if (!results.data.OfferAtProjection__c) {
					results.data.OfferAtProjection__c = 0;
				}
				var newOfferAtProjection = formatNumber( results.data.OfferAtProjection__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.OfferAtProjection__c.fieldName ) ).val( newOfferAtProjection ).change();

				if (!results.data.InHouseProjection__c) {
					results.data.InHouseProjection__c = 0;
				}
				var newInHouseProjection = formatNumber( results.data.InHouseProjection__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.InHouseProjection__c.fieldName ) ).val( newInHouseProjection ).change();
				
				if (!results.data.ExpenseAdjustment__c) {
					results.data.ExpenseAdjustment__c = 0;
				}
				var newExpenseAdjustment = formatNumber( results.data.ExpenseAdjustment__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.ExpenseAdjustment__c.fieldName ) ).val( newExpenseAdjustment ).change();

			}
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
		window.setTimeout(disableNutCalculatedFields('nutcheck',evt.target), 1000);
		window.setTimeout(disableNutCalculatedFields('nutcheck',evt.target), 2000);
		window.setTimeout(disableNutCalculatedFields('nutcheck',evt.target), 4000);

		//console.log( "always jsonp" );
	});
}


function offerRateTypeChanged( parentRow, newRateType ){

	if( !isTableReady() ){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);
	if (isHouseNutRow === true) {
		return;
	}

	try {
		var isFlat = ( newRateType == "Flat" );
		if( isFlat ){
			jq( parentRow ).find( createFieldInputSelector( 'OfferMin__c' ) ).val( '' ).change();
			jq( parentRow ).find( createFieldInputSelector( 'OfferMax__c' ) ).val( '' ).change();
		}
	} catch( err ){
		console.error( 'error occurred when the rateType changed:' + err );
		console.log( err );
	}
}

function markOfferMinMaxReadOnly(parentRow, readOnly) {
	jq( parentRow ).find( createFieldInputSelector( 'OfferMin__c' ) ).attr( "readonly", readOnly );
	jq( parentRow ).find( createFieldInputSelector( 'OfferMax__c' ) ).attr( "readonly", readOnly );
}

function markInHouseMinMaxReadOnly(parentRow, readOnly) {
	jq( parentRow ).find( createFieldInputSelector( 'InHouseMin__c' ) ).attr( "readonly", readOnly );
	jq( parentRow ).find( createFieldInputSelector( 'InHouseMax__c' ) ).attr( "readonly", readOnly );
}
/**
 *  logic that makes the calculation fields readonly and disabled to prevent user input.
 *  <p>Called on document.ready</p>
**/
function inHouseRateTypeChanged( parentRow, newRateType ){

	if( !isTableReady() ){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);
	if (isHouseNutRow === true) {
		return;
	}
	
	var ledgerNutField = jq(parentRow).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
	if (jq(ledgerNutField).prop('checked')) {
		console.log('houseNut checked for ledger bailing');
		return false;
	}

	try {
		var isFlat = ( newRateType == "Flat" );
		if( isFlat ){
			jq( parentRow ).find( createFieldInputSelector( 'InHouseMin__c' ) ).val( '' ).change();
			jq( parentRow ).find( createFieldInputSelector( 'InHouseMax__c' ) ).val( '' ).change();
		}
	} catch( err ){
		console.error( 'error occurred when the rateType changed:' + err );
		console.log( err );
	}
}

/** Change Handler for the offer rate type. **/
function offerRateTypeChangeHandler( evt ){
	console.log( 'offer rateType has changed' );

	if( !isTableReady() || this == window){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);
	if (isHouseNutRow === true) {
		return;
	}

	//debugger;

	if( evt ){
		var parentRow = evt.target.parentElement.parentElement;
		var newRateType = evt.target.value;

		var ledgerNutField = jq(parentRow).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
		if (jq(ledgerNutField).prop('checked')) {
			console.log('houseNut checked for ledger bailing');
			return false;
		}

		offerRateTypeChanged( parentRow, newRateType );
		if(!jq(this.closest("tr")).hasClass("nr")){
			markOfferMinMaxReadOnly(parentRow, newRateType == "Flat");
			expenseRecordChangedHandler(evt);
		}
	} else {
		jq("#gbMainTable " + createFieldSelector( "OfferRateType__c" ) ).each( function( index, el ){

			var parentRow = el.parentElement;
			var ledgerNutField = jq(parentRow).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
			if (jq(ledgerNutField).prop('checked')) {
				console.log('houseNut checked for ledger bailing');
				return false;
			}

			if( parentRow && parentRow.hasAttribute( "id" )){
				var newRateType = getInputValue( parentRow, 'OfferRateType__c' );
				markOfferMinMaxReadOnly(parentRow, newRateType == "Flat");
			}
		});
	}
}

/** Change Handler for the in house rate type. **/
function inHouseRateTypeChangeHandler( evt ){
	console.log( 'in house rateType has changed' );

	if( !isTableReady() || this == window){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);
	if (isHouseNutRow === true) {
		return;
	}

	//debugger;

	if( evt ){
		var parentRow = evt.target.parentElement.parentElement;
		var newRateType = evt.target.value;
		var ledgerNutField = jq(parentRow).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
		inHouseRateTypeChanged( parentRow, newRateType );
		if(!jq(this.closest("tr")).hasClass("nr")){
			markInHouseMinMaxReadOnly(parentRow, newRateType == "Flat");
			expenseRecordChangedHandler(evt);
		}
	} else {
		jq("#gbMainTable " + createFieldSelector( "InHouseRateType__c" ) ).each( function( index, el ){
			var parentRow = el.parentElement;

			if( parentRow && parentRow.hasAttribute( "id" )){
				var newRateType = getInputValue( parentRow, 'InHouseRateType__c' );
				markInHouseMinMaxReadOnly(parentRow, newRateType == "Flat");
			}
		});
	}
}

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


function formatGLsWithBreakouts(){

	const houseNutFieldId = gridInfoByField.HouseNut__c.fieldId;

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
			jq(rows[i]).find(createFieldSelector( gridInfoByField.OfferRateType__c.fieldName)).click();
            jq(rows[i]).find(createFieldSelector( gridInfoByField.InHouseRateType__c.fieldName)).click();

		    inputs = jq(rows[i]).find("input");
		    for(var j = 0; j < inputs.length; j ++){
		    	const columnId = jq(jq(inputs[j]).closest("td")[0]).attr("name");

		    	if (columnId != houseNutFieldId) {
		    		inputs[j].readOnly = true;
		    		inputs[j].disabled = true;
		    		jq(inputs[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
		    	}
		    }
		    selects = jq(rows[i]).find("select");
            for (var j = 0; j < selects.length; j++) {

                selects[j].disabled = true;
                jq(selects[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
            }

		} else if (!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCount__c")).text()) == 0){

			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
			jq(jq(childrenRow).find(".childHeaderRow")).attr('style', 'display: table-row!important');
		}
	}
}

function firstBreakoutCreation(event) {

	if (!event || !event.target) {
        return;
    }
	
	var childDataContainer = jq(event.target).closest("tr").find(".childDataContainer");
	var tr = jq(childDataContainer).find(".none");
	var newRows = jq(childDataContainer).find(".pldisplayed");

	var generatedRow = jq(childDataContainer).find(".nr").first()[0];
	const nameToFind = jq(jq(event.target).closest("tr")[0]).attr("name");
    var parentTrs = jq("#gbMainTable").find(`tr[name=${nameToFind}]`);
	var GLlevel;
	for(var i = 0; i < parentTrs.length; i++){
		if(!jq(parentTrs[i].closest("div")).hasClass("childDataContainer") && jq(parentTrs[i]).hasClass("dr")){
			GLlevel = parentTrs[i];
		}
	}

	var newSettleAtActual = jq(GLlevel).find(createFieldInputSelector('SettleAtActual__c')).is(':checked');

	if(tr.length == 1 && newRows.length == 1){
		console.log("first breakout");

		jq(childDataContainer).parent().parent().find(".createNew").click();
		//somehow the "click()" above generates two new rows (so we now have three)
		//so we need to delete the third one
		jq(childDataContainer).find(".firstCol").find(".minus").first().click();

		var newDescription =  getInputValue( GLlevel, 'Description__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.Description__c.fieldName ) ).val( newDescription ).change();
		var newRateType =  getInputValue( GLlevel, 'OfferRateType__c' );
		jq( generatedRow ).find( createFieldSelector( gridInfoByField.OfferRateType__c.fieldName ) ).click(); 
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferRateType__c.fieldName ) ).val( newRateType ).change();
		var newOfferRate = getInputValue( GLlevel, 'OfferRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferRate__c.fieldName ) ).val( newOfferRate ).change();
		var newOfferAtSellout = getInputValue( GLlevel, 'OfferAtSellout__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferAtSellout__c.fieldName ) ).click().val( newOfferAtSellout ).change();
		var newOfferAtProjection = getInputValue( GLlevel, 'OfferAtProjection__c' ) ;
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferAtProjection__c.fieldName ) ).val( newOfferAtProjection ).change();
		var newInHouseRateType = getInputValue( GLlevel, 'InHouseRateType__c' );
		jq( generatedRow ).find( createFieldSelector( gridInfoByField.InHouseRateType__c.fieldName ) ).click(); 
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseRateType__c.fieldName ) ).val( newInHouseRateType ).change();
		var newMin = getInputValue( GLlevel, 'OfferMin__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferMin__c.fieldName ) ).val( newMin ).change();
		var newInHouseRate = getInputValue( GLlevel, 'InHouseRate__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseRate__c.fieldName ) ).val( newInHouseRate ).change();	
		var newInHouseMin = getInputValue( GLlevel, 'InHouseMin__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseMin__c.fieldName ) ).val( newInHouseMin ).change();
		var newInHouseMax = getInputValue( GLlevel, 'InHouseMax__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseMax__c.fieldName ) ).val( newInHouseMax ).change();
		var newInHouseProjection = getInputValue( GLlevel, 'InHouseProjection__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseProjection__c.fieldName ) ).val( newInHouseProjection ).change();
		var newExpenseAdjustment = getInputValue( GLlevel, 'ExpenseAdjustment__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.ExpenseAdjustment__c.fieldName ) ).val( newExpenseAdjustment ).change();
		var newMax = getInputValue( GLlevel, 'OfferMax__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferMax__c.fieldName ) ).val( newMax ).change();

	}
	//find only new rows that haven't been saved to the database yet
	childDataContainer = jq(childDataContainer).find('.nr');

	jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.SettleAtActual__c.fieldName ) ).prop( "checked", newSettleAtActual ).change();

	var offerRateTypeFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( gridInfoByField.OfferRateType__c.fieldName ));
	var inHouseRateTypeFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( gridInfoByField.InHouseRateType__c.fieldName ));

	var fieldsToClick = offerRateTypeFieldsToClickAndShow.toArray().concat(inHouseRateTypeFieldsToClickAndShow.toArray());

    for (var i = 0; i < fieldsToClick.length; i++) {
    	jq(fieldsToClick[i]).click();
    }

    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferRateType__c.fieldName )).attr("class","");
    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferRate__c.fieldName )).attr("class","");
    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseRateType__c.fieldName )).attr("class","");
    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseRate__c.fieldName )).attr("class","");
    var offerRateTypeFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferRateType__c.fieldName ));
    var offerRateFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferRate__c.fieldName ));
    var offerAtSelloutFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferAtSellout__c.fieldName ));
    var offerAtProjectionFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferAtProjection__c.fieldName ));
    var settleAtActualFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.SettleAtActual__c.fieldName ));
    var inHouseRateTypeFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseRateType__c.fieldName ));
    var offerMinFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferMin__c.fieldName ));
    var inHouseRateFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseRate__c.fieldName ));
    var inHouseMinFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseMin__c.fieldName ));
    var inHouseMaxFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseMax__c.fieldName ));
    var inHouseProjectionFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseProjection__c.fieldName ));
    var expenseAdjustmentFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.ExpenseAdjustment__c.fieldName ));
    var offerMaxFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferMax__c.fieldName ));
    var notesFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.Notes__c.fieldName ));


    var fieldsToDisable = offerRateTypeFields.toArray().concat(offerRateFields.toArray(),
													  offerAtSelloutFields.toArray(),
													  offerAtProjectionFields.toArray(),
													  settleAtActualFields.toArray(),
													  inHouseRateTypeFields.toArray(),
													  offerMinFields.toArray(),
													  inHouseRateFields.toArray(),
													  inHouseMinFields.toArray(),
													  inHouseMaxFields.toArray(),
													  inHouseProjectionFields.toArray(),
													  offerMaxFields.toArray(),
													  notesFields.toArray(),
													  expenseAdjustmentFields.toArray());

    for (var i = 0; i < fieldsToDisable.length; i++) {
        jq(fieldsToDisable[i]).attr("disabled", "disabled");
    }

		
}

function valuesIsNotBlankOrZero( val ){
	return( !( val == '' || parseFloat( val ) == 0 ) );
}

function disableNutCalculatedFields(mode, target){
	console.log('disableNutCalculatedFields mode ' + mode);
	var parent, rows;
	var ledgerNutField, ledgerNutFieldCell;
	var offerRateTypeField;
	var offerRateField;
	var offerMinField;
	var offerMaxField;
	var offerAtSelloutField;
	var offerAtProjectionField;
	var inHouseProjectionField;
	var expenseAdjustmentField;

	console.log('mode is ' + mode);

	if (mode === 'all') {
		rows = jq("#gbMainTable").find('tr.dr');
	} else if (mode === 'nutcheck') {
		parent = jq(target).closest('td');
		parent = jq(parent).closest('tr');		
		console.log('parent cr is');
		console.log(parent);
		rows = jq(parent);
	} else {
		parent = jq(target).closest('td');
		console.log('parent is');
		console.log(parent);
		parent = jq(parent).closest('tr.cr');		
		console.log('parent cr is');
		console.log(parent);
		rows = jq(parent).find('tr.dr.nr.pldisplayed');
		console.log('rows set to ');
		console.log(rows);
	}


	for (var r = 0; r < rows.length; r++) {
		ledgerNutField = jq(rows[r]).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
		ledgerNutFieldCell = jq(ledgerNutField).parent();
		console.log('ledgerNutFieldCell is');
		console.log(jq(ledgerNutFieldCell));
		console.log('about to disable, does nut have mod class?');
		console.log(jq(ledgerNutFieldCell).hasClass('mod'));

		const isX50148X = rowIsX50148X(rows[r]);

		if (jq(ledgerNutFieldCell).hasClass('mod') && !jq(ledgerNutField).prop('checked')) {
			console.log('disableNutCalculatedFields bailing');
			disableNutCalculatedFieldsBeforeSave(ledgerNutField);
			return false;
		} else {
			console.log('if nut checked disable fields');
			if ((jq(ledgerNutField).prop('checked') || jq(rows[r]).find('span.chkd').length > 0) && isX50148X == false) {

				offerRateTypeField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferRateType__c"].fieldId + '"] select');
				offerRateTypeField.prop('disabled','disabled').removeClass('gbrq');;

				offerRateField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferRate__c"].fieldId + '"] input');
				console.log('offerRateField is ');
				console.log(offerRateField);
				if ( valuesIsNotBlankOrZero( offerRateField.val() ) ) {
					offerRateField.val('').change();
				}
				offerRateField.prop('readonly','readonly').removeClass('gbrq');
				
				offerMinField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferMin__c"].fieldId + '"] input');
				if ( valuesIsNotBlankOrZero( offerMinField.val() ) ) {
					offerMinField.val('').change();
				}
				offerMinField.prop('readonly','readonly').removeClass('gbrq');
				
				offerMaxField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferMax__c"].fieldId + '"] input');
				if ( valuesIsNotBlankOrZero( offerMaxField.val() ) ) {
					offerMaxField.val('').change();
				}
				offerMaxField.prop('readonly','readonly').removeClass('gbrq');
				
				offerAtSelloutField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferAtSellout__c"].fieldId + '"] input');
				if ( valuesIsNotBlankOrZero( offerAtSelloutField.val() ) ) {
					offerAtSelloutField.val('').change();
				}
				offerAtSelloutField.prop('readonly','readonly').removeClass('gbrq');		
				
				offerAtProjectionField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferAtProjection__c"].fieldId + '"] input');
				if ( valuesIsNotBlankOrZero( offerAtProjectionField.val() ) ) {
					offerAtProjectionField.val('').change();
				}
				offerAtProjectionField.prop('readonly','readonly').removeClass('gbrq');	

				settleAtActualField = jq(rows[r]).find('td[name="' + gridInfoByField["SettleAtActual__c"].fieldId + '"] input');
				settleAtActualField.prop('checked', false);
				settleAtActualField.prop('disabled','disabled').removeClass('gbrq');	
			} else {
				console.log('disableNutCalculatedFields mode ' + mode  + ' exit with no action');
			}
		}
	}
}

function disableNutCalculatedFieldsBeforeSave(target){
	console.log('disableNutCalculatedFieldsBeforeSave');
	var parent, rows;
	var ledgerNutField;
	var offerRateTypeField;
	var offerRateField;
	var offerMinField;
	var offerMaxField;
	var offerAtSelloutField;
	var offerAtProjectionField;
	var inHouseProjectionField;
	var expenseAdjustmentField;

	parent = jq(target).closest('td');
	parent = jq(parent).closest('tr');		

	offerRateTypeField = jq(parent).find('td[name="' + gridInfoByField["OfferRateType__c"].fieldId + '"] select').first();
	offerRateTypeField.attr('class','');

	offerRateField = jq(parent).find('td[name="' + gridInfoByField["OfferRate__c"].fieldId + '"] input').first();
	offerRateField.attr('class','text');
}

function hideFields() {
	jq(createFieldSelector('Category__c')).hide();
	jq(createFieldSelector('RollUpCount__c')).hide();
}

function makeX50148XRowsReadonly() {
	setTimeout(disableX50148XRows, 1100);
}

function disableX50148XRows() {
	var $row = jq('tr.dr td[name=v0]:contains("House Nut")').parent();
	$row.find(createFieldSelector('OfferRateType__c')).click();
	$row.find(createFieldSelector('InHouseRateType__c')).click();
	var $inputs = $row.find('input, textarea, select');	
	$inputs.attr('disabled', true);
	$row.find('.gbrq').removeClass('gbrq');
	$row.next('.cr').find('.createNew').hide();	
}

jq(document).ready( function(){
	var initialFocus = true;

	//-- always call after jq(document).ready for all scripts
	console.log('gridInfoMap');
	console.log(gridInfoMap.gridInfo);
	convertGridInfoMap( gridInfoMap );

	//-- mark the grid as not ready, so change events should not be fired
	markTableReady( false );

	//The Offer Rate Type, Offer Rate / $, Offer Min, Offer Max, Offer At Sellout, Offer At Projection are nulled out 
	//and not editable or calculated
	hideFields();
	disableNutCalculatedFields('all');
	disableCalculatedFields();
	window.setTimeout(disableNutCalculatedFields('all'), 2000);

	jq('#gbMainTable').on('click', 'td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input', function(e) {
		console.log('house nut clicked');
		var $row = jq(e.target).closest('tr');
		var badRow=$row;
		var runCount = 0;

		setTimeout( function(){
			if (runCount < 32) {
				var badInputs = jq( badRow ).find( '.gbrq' );
				jq( badRow ).find( '.gbrq' ).removeClass( 'gbrq' );
				offerRateTypeField = jq(badRow).find('td[name="' + gridInfoByField["OfferRateType__c"].fieldId + '"] select').first();
				offerRateTypeField.prop('disabled','disabled');
				runCount++;
			}
		}, 25);

	});

	jq('#gbMainTable').on('click', '[title="Create new Expense Breakout"]', function(e) {
		disableNutCalculatedFields('single',e.target);
	});

	//-- change handler for the RateType__c cell (not input) but that can be through createFieldInputSelector
	var changeSelectors =  createFieldSelector("OfferRateType__c") + ', '+ createFieldSelector("OfferRate__c") + ', ' + createFieldSelector("OfferMin__c") + ', ' + createFieldSelector("OfferMax__c") + ', ' + createFieldSelector("SettleAtActual__c") + ', ' + createFieldSelector("InHouseRateType__c") + ', ' + createFieldSelector("InHouseRate__c") + ', ' + createFieldSelector("InHouseMin__c") + ', ' + createFieldSelector("InHouseMax__c");
	jq("#gbMainTable").on( 'change', changeSelectors, expenseRecordChangedHandler );

	jq("#gbMainTable").on( 'click', '.createNew', function(event){
        firstBreakoutCreation(event);
        hideFields();
    });
	
	jq("#gbMainTable").on('click', '.pl.ui-selectee', function(e) {
		var kids, nut, parent;
		parent = jq(e.target).closest('td');
		parent = jq(parent).closest('tr');	

		kids = (parent).find('td[name="v18"]').text();
		kids = parseInt(kids) ? parseInt(kids) : 0;
		if (kids) {
	       jq( parent ).find( "select" ).prop( "disabled", true );
	       jq( parent ).find( "input" ).attr( "readonly", true ).attr( "disabled", true );
	       jq( parent ).find( "select" ).removeClass('gbrq');
	       jq( parent ).find( "input" ).removeClass('gbrq');
	        nut = jq( parent ).find(createFieldSelector("HouseNut__c"));
	        nut = nut.find('input');
	        nut.attr( "readonly", false ).attr( "disabled", false );   
		} else {
			disableNutCalculatedFields('nutcheck',e.target);
		}
	});

	jq("#gbMainTable").on( 'change', createFieldSelector("OfferRateType__c"), offerRateTypeChangeHandler );
	offerRateTypeChangeHandler( null );
	jq("#gbMainTable").on( 'change', createFieldSelector("InHouseRateType__c"), inHouseRateTypeChangeHandler );
	inHouseRateTypeChangeHandler( null );

	jq( "#gbMainTable > tbody > tr > td[name='v18']" ).each( function( elIndex, el ){
		var con, nextRow, nut, toggle;
		var childCount = -1;
		try { childCount = parseInt( el.innerText ); } catch( err ){}
		if ( childCount > 0 ) {
	       	var parentRow = jq( el ).closest( "tr" );
	       	jq( parentRow ).find( "select" ).attr( "disabled", true );
	       	jq( parentRow ).find( "input" ).attr( "readonly", true ).attr( "disabled", true );
	       	jq( parentRow ).find( "select" ).removeClass('gbrq');
	       	jq( parentRow ).find( "input" ).removeClass('gbrq'); 
	        nut = jq( parentRow ).find(createFieldSelector("HouseNut__c"));
	        nut = nut.find('input');
	        nut.attr( "readonly", false ).attr( "disabled", false );   
	       	jq( parentRow ).find('.icon-arrow').first().click();
	       	nextRow = jq(parentRow).next('tr');
	       	toggle = jq( nextRow ).find('.toggleData').first();
	       	toggle = toggle.find('.icon-arrow').first();
	       	toggle.each( function( elIndex, el ) {
	       		el.click();
	       	});

		} 
	});

	//"Event Total" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');

	formatGLsWithBreakouts();

	markTableReady(true);

	gridStateMessagingController('nutter');
	disableX50148XRows();
	makeX50148XRowsReadonly();
});