/**
 *  Script handler for the dev version of the ancillary revenues.
 *  @author Dominic Aveyard (daveyard@salesforce.com)
**/
jq(document).ready(function(){
	var scaleColIndex;

	console.log('dom custom js');

	for (var gridInfoKey in gridInfoMap) {
		var gridInfoObj = gridInfoMap[gridInfoKey];

		for (var i=0; i < gridInfoObj.metaColumns.length; i++) {
			thisCol = gridInfoObj.metaColumns[i];

			if (thisCol.fieldName == 'ApplyTicketScale__c') {
				console.log('ApplyTicketScale__c found ', thisCol);
				scaleColIndex = thisCol.colIndex;
			}
		}
	}

	var sel = 'td:nth-child(' + (scaleColIndex + 2) + ')';

	jq('#gbMainTable').on('click', sel, function() {
		console.log('td changed');
/*
		console.log('jq(this) is ',jq(this));
		console.log('jq(this).attr(name) is ',jq(this).attr('name'));
		var inputs = jq(this).find('input');
		console.log('searched for inputs found ', inputs);
*/

		console.log ('this should only happen on ticket scale');

		window.open('/apex/LNE_AssignTicketScalesToLedgerEntries');
	});

	function receiveMessage(event) {
	  // Do we trust the sender of this message?
	  /*
	  if (event.origin !== "http://example.com:8080")
	    return;
*/

	  // event.source is window.opener
	  // event.data is "hello there!"

	  // Assuming you've verified the origin of the received message (which
	  // you must do in any case), a convenient idiom for replying to a
	  // message is to call postMessage on event.source and provide
	  // event.origin as the targetOrigin.
	  event.source.postMessage("hi there yourself!  the secret response " +
	                           "is: rheeeeet!",
	                           event.origin);
	}

	window.addEventListener("message", receiveMessage, false);

});
