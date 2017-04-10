convertGridInfoMap();

var orderSelector = createFieldSelector('Rank__c');
var orderInputSelector = createFieldInputSelector('Rank__c');
var typeSelector = createFieldSelector('Type__c');

var GROUP_PRIMARY_HEADLINER = 'Primary Headliner';

var setOrders = function(reorder){

	//get sort direction
	var ascendingOrder = jq('.firstHeader ' + orderSelector + ' .sortasc').length > 0;
	var parentRowCount = 0, oldVal, orderInput;

	var oh = jq('tr.dr.primaryheadliner').not('.nr');
	var nh = jq('tr.nr.primaryheadliner');
	var oc = jq('tr.dr.co-headliner').not('.nr');
	var nc = jq('tr.nr.co-headliner');
	var os = jq('tr.dr.support').not('.nr');
	var ns = jq('tr.nr.support');

	var allRows = [];
	addArrayElements(allRows, oh, !ascendingOrder);
	addArrayElements(allRows, nh, true);
	addArrayElements(allRows, oc, !ascendingOrder);
	addArrayElements(allRows, nc, true);
	addArrayElements(allRows, os, !ascendingOrder);
	addArrayElements(allRows, ns, true);

	jq(allRows).each(function(i, e){
		element = jq(e);
		parentRowCount++;

		orderInput = jq(orderInputSelector, element);

		oldVal = orderInput.val();

		if(!oldVal.trim() || (reorder && oldVal != parentRowCount)){
			orderInput.val(parentRowCount);
			orderInput.change();
		}
	});
}

var addArrayElements = function(ary, elements, newRows){

	if(newRows){
		for(var i=elements.length-1; i>=0; i--){
			ary.push(elements[i]);
		}
	}else{
		jq(elements).each(function(i, e) {
			ary.push(e);
		});
	}


	return ary;
}

function setupRankOrdering(){

	//determine if there are any rows in the table, if none return
	if(jq('#gbMainTable > tbody > tr.dr:not(.nd)').length==0)return;

	//the default selectable nature of gridbuddy grids is interfering with making them sortable, so we're removing it
	jq( "#gbMainTable > tbody" ).selectable( "destroy" );

	var element, cId, className, group, groupCounter = 1, prevGroupClass, groupClass, groupName, groupClasses = [], groupsToDrag = [];

	//pre-process table rows
	jq('#gbMainTable > tbody > tr').each(function(i, e){

		element = jq(e);
		groupClass = 'artist-group-' + groupCounter;

		if(element.is('.groupByRow')){
			groupCounter++;
			groupClass = 'artist-group-' + groupCounter;
			groupCounter++;
			group = jq('.grpValue', element).text();
			groupName = group.substr(0, group.indexOf('(')-1).replace(/ /g,'').toLowerCase();
		}else if(element.is('.dr')){

			cId = element.attr('id');
			className = 'id-'+cId;

			if(!group.startsWith(GROUP_PRIMARY_HEADLINER)){
				var cell = jq('[name=v0]', e);
				cell.append('<div class="handle"></div>');
			}

			element.addClass(groupName);

		}else if(element.is('.cr') || element.is('.gradientHeader')){
			element.addClass(className);
		}

		element.addClass(groupClass);

		if(!groupClasses.includes(groupClass)){
			groupClasses.push(groupClass);
		}

		if((element.is('.dr') || element.is('.cr')) && !groupsToDrag.includes(groupClass) && (group && !group.startsWith(GROUP_PRIMARY_HEADLINER))){
			groupsToDrag.push(groupClass);
		}

	});

	var newTbody;

	for(var i=0; i<groupClasses.length; i++){

		newTbody = jq('<tbody class="' + groupClasses[i] + '-container" />');

		jq('#gbMainTable').append(newTbody);

		newTbody.append(jq('.' + groupClasses[i]));
	}

	jq('#gbMainTable > tbody > tr.dr ' + orderInputSelector).prop('disabled', true);

	setOrders(false);

	//add sortable nature to main table
	for(var i=0; i<groupsToDrag.length; i++){
		jq('#gbMainTable > tbody.' + groupsToDrag[i] + '-container').sortable({
			//handle:'.handle',
			handle:'td[name=v0]',
			//axis:'y',
			revert:300,
			start:function(event, ui){
				jq('#gbMainTable > tbody > tr.cr').hide();
			},
			stop:function(event, ui){
				var item = jq(ui.item);
				var prevItem = jq(item.prev());

				if(!prevItem.is('.gradientHeader')){
					var prevId = prevItem.attr('id');

					var insertionPoint = jq('.gradientHeader.id-'+prevId);

					insertionPoint.after(item);
				}

				var id = item.attr('id');
				var childRows = jq('.id-'+id);
				item.after(childRows);

				jq('#gbMainTable > tbody > tr.dr').each(function(i, e){

					element = jq(e);

					var iconArrow = jq('.icon-arrow', element);

					if(!iconArrow.is('.right')){
						cId = element.attr('id');
						className = 'id-'+cId;
						jq('tr.cr.'+className).show();
					}
				});

				setOrders(true);
			}
		});
	}

	jq('.gridBtnsCell .createNew:first').click(function(){
		var orderInput = jq(orderInputSelector, jq('tr.nr:first'));
		orderInput.val(0);
		orderInput.prop('disabled', true);
	});

	jq('.mainTable').on('change', 'tr.nr ' + typeSelector + ' select', function(e){

		var v = jq(e.target).val();
		var type = v.replace(/ /g,'').toLowerCase();
		var newRow = jq(e.target).closest('tr.nr');
		var cType = newRow.prop('dealType');

		if(cType){
			newRow.removeClass(cType);
		}

		newRow.addClass(type);
		newRow.prop('dealType', type);



		setOrders(true);
	});
}


function changedDealType(){

	console.log( "deal type has changed" );

	var dealType = getInputValue(this.parentElement, 'DealType__c');
	var backendField = jq(this.parentElement).find(createFieldInputSelector('BackendPercent__c'));
	jq(this.parentElement).find(createFieldSelector('DealCalculation__c')).click();
	var dealCalculationField = jq(this.parentElement).find(createFieldInputSelector('DealCalculation__c'))

	console.log(backendField);

	if( dealType == 'Flat' || dealType == 'Retro Gross Deal' || dealType == 'Step Up Gross Deal' || dealType == 'Step Up Net Deal'){
		backendField.val('');
		backendField.attr('disabled', true);
		backendField.attr('class', '');
	}
	if( dealType == 'Alternative Promoter Profit Deal' || dealType == 'Gross Split Point' || dealType == 'Percentage Of Gross' || dealType == 'Precentage of Net' || dealType == 'Promoter Profit'){
		if(backendField.val() == ''){
			backendField.attr('class', 'gbrq');
		}
		backendField.attr('disabled', false);
	}

	if(dealType == 'Gross Split Point' || dealType == 'Percentage of Gross' || dealType == 'Retro Gross Deal' || dealType == 'Step Up Gross Deal' ){
		dealCalculationField.val('Inclusive of Sound & Lights & Support & Other Talent Amount');
		dealCalculationField.attr('class', '');
	}



}

function changedTypeOnly(){

	console.log( "type has changed" );


	console.log(this.closest('tr'));
	jq(this.closest('tr')).find(createFieldSelector('Type__c')).click();
	var type = jq(this.closest('tr')).find(createFieldInputSelector('Type__c')).val();
	console.log(type);
	var backendField = jq(this.closest('tr')).find(createFieldInputSelector('BackendPercent__c'));
	console.log(backendField);
	jq(this.closest('tr')).find(createFieldSelector('DealCalculation__c')).click();
	var dealCalculationField = jq(this.closest('tr')).find(createFieldInputSelector('DealCalculation__c'));
	jq(this.closest('tr')).find(createFieldSelector('DealType__c')).click();
	var dealTypeField = jq(this.closest('tr')).find(createFieldInputSelector('DealType__c'));


	if( type == 'Support'){
		backendField.val('');
		backendField.attr('disabled', true);
		backendField.attr('class', '');
		dealTypeField.val('');
		dealTypeField.attr('disabled', true);
		dealTypeField.attr('class', '');
		dealCalculationField.val('');
		dealCalculationField.attr('disabled', true);
		dealCalculationField.attr('class', '');
	}
}


function changedType(){

	console.log( "type has changed" );

	var type = getInputValue(this.parentElement, 'Type__c');
	var backendField = jq(this.parentElement).find(createFieldInputSelector('BackendPercent__c'));
	jq(this.parentElement).find(createFieldSelector('DealCalculation__c')).click();
	var dealCalculationField = jq(this.parentElement).find(createFieldInputSelector('DealCalculation__c'));
	jq(this.parentElement).find(createFieldSelector('DealType__c')).click();
	var dealTypeField = jq(this.parentElement).find(createFieldInputSelector('DealType__c'));


	if( type == 'Support'){
		backendField.val('');
		backendField.attr('disabled', true);
		backendField.attr('class', '');
		dealTypeField.val('');
		dealTypeField.attr('disabled', true);
		dealTypeField.attr('class', '');
		dealCalculationField.val('');
		dealCalculationField.attr('disabled', true);
		dealCalculationField.attr('class', '');
	}else{

		if(dealTypeField.attr('disabled')){
		
			
			backendField.attr('disabled', false);
			dealTypeField.attr('disabled', false);
			dealTypeField.change();
		}

		if(dealCalculationField.attr('disabled')){

			dealCalculationField.attr('disabled', false);
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

        if (!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd")){
        	var childrenRows = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") + "].cr");
        	for (var j = 0; j < childrenRows.length; j++){
        		if ((j == 0 && parseInt(jq(rows[i]).find(createFieldSelector("RollUpArtistRetroCount__c")).text()) > 0) ||
        			(j == 1 && parseInt(jq(rows[i]).find(createFieldSelector("RollUpBonusDetailsCount__c")).text()) > 0) ||
        			(j == 2 && parseInt(jq(rows[i]).find(createFieldSelector("RollUpTalentOverheadCount__c")).text()) > 0)){
					var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") + "].cr")[j];
		            jq(childrenRow).css("display", "table-row");
		            jq(jq(childrenRow).find("h3.toggleData")[0]).attr("class","toggleData expanded");
		            jq(jq(childrenRow).find("h3.toggleData")[1]).attr("class","toggleData expanded fixed none");
		            jq(childrenRow).find(".childData").attr("class","childData expanded");
		            jq(childrenRow).find(".childData").css("display", "block");
	        	}
			}
		}
    }
}

jq(document).ready( function(){
	var initialFocus = true;

	//-- always call after jq(document).ready for all scripts
	convertGridInfoMap( gridInfoMap );

	//-- mark the grid as not ready, so change events should not be fired
	markTableReady( false );

	//-- formats the GL levels when there are breakouts
    formatGLsWithBreakouts();

    //-- hide counts by default
    jq("#gbMainTable " + createFieldSelector("RollUpArtistRetroCount__c")).hide();
    jq("#gbMainTable " + createFieldSelector("RollUpBonusDetailsCount__c")).hide();
    jq("#gbMainTable " + createFieldSelector("RollUpTalentOverheadCount__c")).hide();

	if ( readOnlyGrid === false ) {
		jq("#gbMainTable").on( 'change', 'input', changedTypeOnly);
		jq("#gbMainTable").on( 'change', createFieldSelector("DealType__c"), changedDealType);
		jq("#gbMainTable").on('change', createFieldSelector("Type__c"), changedType);
		jq("#gbMainTable").on( 'change', createFieldInputSelector("BackendPercent__c"), function(){
			if(jq(this).val() != ""){
				jq(this).attr("class", "");
			}
			if(jq(this).attr('disabled') != true && jq(this).val() == ""){
				jq(this).attr("class", "gbrq");
			}
		});
		var dealFields = jq("#gbMainTable").find(createFieldSelector("DealType__c"));
		for(var i = 0; i < dealFields.length ; i++){
			var dealType = getInputValue(dealFields[i].parentElement, "DealType__c");
			var backendField = jq(dealFields[i].parentElement).find(createFieldInputSelector('BackendPercent__c'));
			console.log(dealFields[i]);
			console.log(dealType);
			console.log(backendField);
			if( dealType == 'Flat' || dealType == 'Retro Gross Deal' || dealType == 'Step Up Gross Deal' || dealType == 'Step Up Net Deal'){
				backendField.val('');
				backendField.attr('disabled', true);
				backendField.attr('class', '');
			}
			if( dealType == 'Alternative Promoter Profit Deal' || dealType == 'Gross Split Point' || dealType == 'Percentage Of Gross' || dealType == 'Precentage of Net' || dealType == 'Promoter Profit'){
				if(backendField.val() == ''){
					backendField.attr('class', 'gbrq');
				}
			}
			var type = getInputValue(dealFields[i].parentElement, 'Type__c');
			backendField.attr('disabled', false);
			jq(dealFields[i].parentElement).find(createFieldSelector('DealCalculation__c')).click();
			var dealCalculationField = jq(dealFields[i].parentElement).find(createFieldInputSelector('DealCalculation__c'));
			jq(dealFields[i].parentElement).find(createFieldSelector('DealType__c')).click();
			var dealTypeField = jq(dealFields[i].parentElement).find(createFieldInputSelector('DealType__c'));


			if( type == 'Support'){
				backendField.val('');
				backendField.attr('disabled', true);
				backendField.attr('class', '');
				dealTypeField.val('');
				dealTypeField.attr('disabled', true);
				dealTypeField.attr('class', '');
				dealCalculationField.val('');
				dealCalculationField.attr('disabled', true);
				dealCalculationField.attr('class', '');
			}
			
		}
	
		
	}

	setupRankOrdering();
	markTableReady(true);
	gridStateMessagingController();
	
	// Disabled the Co-Headliner Fields 
	var rankSelector = createFieldSelector('Rank__c');
	var typeSelector = createFieldSelector('Type__c');
	var artistSelector = createFieldSelector('Artist__c');
	var guranteedAmountSelector = createFieldSelector('GuaranteeAmount__c');
	var artistSuppliedSelector = createFieldSelector('ArtistSuppliedSL__c');
	var otherTalentAmountSelector = createFieldSelector('OtherTalentAmount__c');
	var otherTalentDescriptionSelector = createFieldSelector('OtherTalentDescription__c');
	var dealTypeSelector = createFieldSelector('DealType__c');
	var dealApplicationType = createFieldSelector('DealApplicationType__c');
	var backendPercentSelector = createFieldSelector('BackendPercent__c');
	var dealCalculationSelector = createFieldSelector('DealCalculation__c');

	jq('.groupByRow').each(function(i,l){
	  var isCoHeadliner = jq(l).find('.titleCol').find('.grpValue').text().indexOf("Co-Headliner") != -1 

	  if(isCoHeadliner){
	    jq(l).parent().next().find('.co-headliner').find(typeSelector).removeClass('pl')
	    jq(l).parent().next().find('.co-headliner').find(artistSelector).find('input').attr('disabled','true')
	    jq(l).parent().next().find('.co-headliner').find(guranteedAmountSelector).find('input').attr('disabled','true')
	    jq(l).parent().next().find('.co-headliner').find(artistSuppliedSelector).find('input').attr('disabled','true')
	    jq(l).parent().next().find('.co-headliner').find(otherTalentAmountSelector).find('input').attr('disabled','true')
	    jq(l).parent().next().find('.co-headliner').find(otherTalentDescriptionSelector).find('input').attr('disabled','true')
	    jq(l).parent().next().find('.co-headliner').find(dealTypeSelector).find('select').attr('disabled','true')
	    jq(l).parent().next().find('.co-headliner').find(backendPercentSelector).find('input').attr('disabled','true')
	    jq(l).parent().next().find('.co-headliner').find(dealCalculationSelector).find('select').attr('disabled','true')

	  }
})

	

});