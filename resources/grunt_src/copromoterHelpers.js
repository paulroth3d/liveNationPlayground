/**
 *  Common copromoter scripts for primary and secondary grids.
 *  @author John Casimiro <jcasimiro@salesforce.com>
**/

/**
 *  Finds the Live Nation row and disables all inputs in that row.
 *  <p>Called on document.ready</p>
 **/
function makeLiveNationRowReadOnly() {
	console.log('makeLiveNationRowReadOnly enter');
	var rows = jq("#gbMainTable").find(".dr");
	var foundLNRow = false;
	for (var i = 0; i < rows.length; i++) {
		jq(rows[i]).find('input').each(function() {
			if (this.value == 'Live Nation') {
				// color tds
				jq(this).closest('tr').find('td').each(function() {
					jq(this).css('background-color', '#ccc');
				});
				// disable inputs
				jq(this).closest('tr').find('input').each(function() {
					jq(this).prop('disabled', true);
				});
				// click to show dropdowns
				jq(this).closest('tr').find('td .plTxt').each(function() {
					jq(this).click();
				});
				// disable dropdowns 
				jq(this).closest('tr').find('select').each(function() {
					jq(this).prop('disabled', true);
				});
				// mark the Live Nation Row for future exclusion.
				jq(this).closest('tr').addClass('LNRow');
				foundLNRow = true;
			}
		});
		if (foundLNRow == true)
			break;
	}
	// hide bonus details and deal settlement ledgers for the LNE row
	jq("#gbMainTable tr.LNRow").find("span.icon-arrow").first().hide();
	jq("#gbMainTable tr.LNRow").find("input.dl").first().hide();
	jq("#gbMainTable tr.LNRow").find("div.actionsBtn").first().hide();
	jq("#gbMainTable tr.LNRow").next().hide();
	jq("#gbMainTable tr.LNRow").next().next().hide();
}

/**
 *  Event handler for the Event Profit column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function eventProfitChangedHandler( evt ){
	console.log('event event profit handler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).each(function(){
		if (jq.isNumeric(parseInt(jq( this ).val()))){
			console.log('value' + jq( this ).val());
	    	total += parseInt(jq( this ).val());
		}
	});
	console.log('total = ' + total);

	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
		jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).val(remainder);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).change();

}

/**
 *  Event handler for the Event Loss column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function eventLossChangedHandler( evt ){
	console.log('event event loss handler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'EventLoss__c' )).each(function(){
	    if (jq.isNumeric(parseInt(jq( this ).val()))){
	    	total += parseInt(jq( this ).val());
		}
	});
	
	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventLoss__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventLoss__c' )).change();

}

/**
 *  Event handler for the Expense Adjustment Profit column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function expenseAdjustmentProfitChangedHandler( evt ){
	console.log('expenseAdjustmentProfitChangedHandler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentProfit__c' )).each(function(){
	    if (jq.isNumeric(parseInt(jq( this ).val()))){
	    	total += parseInt(jq( this ).val());
		}
	});
	
	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentProfit__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentProfit__c' )).change();

}

/**
 *  Event handler for the Expense Adjustment Loss column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function expenseAdjustmentLossChangedHandler( evt ){
	console.log('expenseAdjustmentLossChangedHandler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentLoss__c' )).each(function(){
	    if (jq.isNumeric(parseInt(jq( this ).val()))){
	    	total += parseInt(jq( this ).val());
		}
	});
	
	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentLoss__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentLoss__c' )).change();

}

/**
 *  Event handler for the Ancillary Revenue column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function ancillaryRevenueChangedHandler( evt ){
	console.log('ancillaryRevenueChangedHandler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'AncillaryRevenue__c' )).each(function(){
	    if (jq.isNumeric(parseInt(jq( this ).val()))){
	    	total += parseInt(jq( this ).val());
		}
	});
	
	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'AncillaryRevenue__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'AncillaryRevenue__c' )).change();

}

/**
 *  Sets listeners on the columns.
 **/
function setlisteners(){
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "EventProfit__c" ),eventProfitChangedHandler );
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "EventLoss__c"),eventLossChangedHandler );
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "ExpenseAdjustmentProfit__c" ),expenseAdjustmentProfitChangedHandler );
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "ExpenseAdjustmentLoss__c" ),expenseAdjustmentLossChangedHandler );
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "AncillaryRevenue__c" ),ancillaryRevenueChangedHandler );
}

/**
 *  Calls a recalculation of the columns.
 **/
function recalculateLNRow(){
	eventProfitChangedHandler();
	eventLossChangedHandler();
	expenseAdjustmentProfitChangedHandler();
	expenseAdjustmentLossChangedHandler();
	ancillaryRevenueChangedHandler();
}