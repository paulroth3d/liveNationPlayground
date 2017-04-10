this.postOffice = new LNE_MessagePostOffice(this);

var eventMethod = window.addEventListener ? 'addEventListener' : 'attachEvent';
var eventer = window[eventMethod];
var messageEvent = eventMethod == 'attachEvent' ? 'onmessage' : 'message';

function sendMessage(){
	var pageName = 'SettlementExpenseGrid';
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

function makeX50148XRowsReadonly() {
	setTimeout(function() {
		var $row = jq('tr.dr td[name=v0]:contains("House Nut")').parent();
		var $inputs = $row.find('input, textarea');	
		
		$inputs.attr('disabled', true);
		$row.next('.cr').find('.createNew').hide();	
	}, 2000);
}

jq(document).ready( function(){
	commonInit();

	if ( readOnlyGrid === false ) {

		createCommonChangeSelectors();

		jq("#gbMainTable").on( 'click', '.createNew', function(evt){
			manageCalculationFields();
			hideAndDisableCommonFields();
			firstBreakoutCreation(evt);
		});
		
		jq("#gbMainTable").on('click', 'select', function(){

			if(jq(this).val != "--None--"){
				jq(this).attr("class","");
			}
		});
	}

	markTableReady(true);
	gridStateMessagingController('nutter');
	makeX50148XRowsReadonly();
});