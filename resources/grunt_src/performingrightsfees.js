this.postOffice = new LNE_MessagePostOffice(this);

var eventMethod = window.addEventListener ? 'addEventListener' : 'attachEvent';
var eventer = window[eventMethod];
var messageEvent = eventMethod == 'attachEvent' ? 'onmessage' : 'message';

function sendMessage(){

	var pageName = 'PerformanceRightFeesGrid';
    var isSuccessful = true;

	//-- some custom message type. Again, only saveComplete is special/recognized for now.
	var messageType = 'defaultFees';

	//-- send the data payload as an object with stuff to return.
	//-- always include src as some unique identifier for the page
	var data = {
		src: window.location.href
	};

	var postMessage = new LNE_PostMessage( pageName, messageType, isSuccessful, data );

	//-- works if in a grid overlay
	postMessage.dispatch( parent );

}


this.postOffice.addTypeHandler( 'defaultFees_completed', function( myPostMessage ){
  	
  	console.log('Default Fees Completed');
 		jq('.refreshBtn').click();
 });

postOffice.listenForPostEvents(window);

function defaultFees(){
	console.log('default fees action fired');
	sendMessage();

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

            jq(rows[i]).find(createFieldSelector( gridInfoByField.FlashRateType__c.fieldName)).click();
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
        }

    }


}

function ledgerRecordChangedHandler(evt) {
    console.log('ledgerRecordChangedHandler begins');

    if  (jq(this.parentElement).hasClass("nr")) {
	    return;
	}

    if (jq(this.closest("div")).hasClass("childDataContainer")) {

        var ledgerEntryBreakout = {};
        ledgerEntryBreakout.Id = this.parentElement.getAttribute("id");
        ledgerEntryBreakout.FlashRateType__c = getInputValue(this.parentElement,
            'FlashRateType__c');
        ledgerEntryBreakout.FlashRateAmount__c = sanitizeNumber(getInputValue(this.parentElement,
            'FlashRateAmount__c'));

        //-- the event is always going to be more up to date.
        //var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
        //ledgerEntry[ currentField ] = evt.target.value;

        var url = createApexURL("LNE_PerformingRightsFeesAPI");
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
                console.log("LNE_PerformingRightsFeesAPI LedgerEntryBreakout__c success. fields updated");
                var currentFlash = formatNumber(results.data.CurrentFlash__c);
                console.log(jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.CurrentFlash__c.fieldName)));
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.CurrentFlash__c.fieldName)).val(
                    currentFlash).change();
               
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
        ledgerEntry.FlashRateType__c = getInputValue(this.parentElement,
            'FlashRateType__c');
        ledgerEntry.FlashRateAmount__c = sanitizeNumber(getInputValue(this.parentElement,
            'FlashRateAmount__c'));
    

        //-- the event is always going to be more up to date.
        //var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
        //ledgerEntry[ currentField ] = evt.target.value;

        var url = createApexURL("LNE_PerformingRightsFeesAPI");
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
               console.log("LNE_PerformingRightsFeesAPI LedgerEntryBreakout__c success. fields updated");
                var currentFlash = formatNumber(results.data.CurrentFlash__c);
                jq(this.parentElement).find(createFieldInputSelector(
                    gridInfoByField.CurrentFlash__c.fieldName)).val(
                    currentFlash).change();
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
    var currentFlashFields = jq("#gbMainTable").find(createFieldInputSelector(
        "CurrentFlash__c"));
    var overridenFields = jq("#gbMainTable").find(createFieldInputSelector(
        "FlashOverridden__c"));
    var capacityRangeFields = jq("#gbMainTable").find(createFieldInputSelector(
         "FlashCapacityRange__c"));

    console.log(capacityRangeFields);
    for (var i = 0; i < currentFlashFields.length; i++) {
        currentFlashFields[i].readOnly = true;
        currentFlashFields[i].disabled = true;
        overridenFields[i].readOnly = true;
        overridenFields[i].disabled = true;
        capacityRangeFields[i].readOnly = true;
        capacityRangeFields[i].disabled = true;
    }
}


jq(document).ready(function() {
    var initialFocus = true;
    //-- always call after jq(document).ready for all scripts
    convertGridInfoMap(gridInfoMap);

    //-- mark the grid as not ready, so change events should not be fired
    markTableReady(false);

    console.log(gridInfoMap);

    disableCalculatedFields();

    formatGLsWithBreakouts();

    jq("#gbMainTable " + createFieldSelector("RollUpCount__c")).hide();

	gridStateMessagingController();

	if (readOnlyGrid === false) {
        //-- change handler for the RateType__c cell (not input) but that can be through createFieldInputSelector
        var changeSelectors = createFieldSelector("FlashRateAmount__c") +
            ', ' + createFieldSelector("FlashRateType__c") + ', ' + createFieldSelector("GLAccount__c");
        jq("#gbMainTable").on('change', changeSelectors,
            ledgerRecordChangedHandler);
        jq("#gbMainTable").on('change', changeSelectors,
            function(){
            	console.log(jq(this));
            	var overridenFields = jq(this.parentElement).find(createFieldInputSelector(
        			"FlashOverridden__c"));
            	for (var i = 0; i < overridenFields.length; i++) {
        			overridenFields[i].checked = true;
        			jq(overridenFields[i]).change();
    			}
            });
        jq("#gbMainTable").on('change', changeSelectors ,
            function(){
            	console.log(jq(this.parentElement));
            	var capacityRangeFields = jq(this.parentElement).find(createFieldInputSelector(
        			"FlashCapacityRange__c"));
            	for (var i = 0; i < capacityRangeFields.length; i++) {
        			capacityRangeFields[i].value = '';
        			jq(capacityRangeFields[i]).change();
    			}
            });

    }
    markTableReady(true);

});
