this.postOffice = new LNE_MessagePostOffice(this);

var eventMethod = window.addEventListener ? 'addEventListener' : 'attachEvent';
var eventer = window[eventMethod];
var messageEvent = eventMethod == 'attachEvent' ? 'onmessage' : 'message';

function sendMessage(){
	var pageName = 'SettlementExpenseHouseNutGrid';
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

	jq('#gbMainTable').on('click', 'td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input', function(e) {
		console.log('house nut clicked');
		var $row = jq(e.target).closest('tr');
		var badRow=$row;
		var runCount = 0;

		setTimeout( function(){
			if (runCount < 32) {
				var badInputs = jq( badRow ).find( '.gbrq' );
				jq( badRow ).find( '.gbrq' ).removeClass( 'gbrq' );
				runCount++;
			}
		}, 25);

	});

	createCommonChangeSelectors();

	jq("#gbMainTable").on( 'click', '.createNew', function(evt){
		hideAndDisableCommonFields();
		firstBreakoutCreation(evt);
	});
	
	jq("#gbMainTable").on('click', '.pl.ui-selectee', function(e) {
		var kids, nut, parent;
		parent = jq(e.target).closest('td');
		parent = jq(parent).closest('tr');	

		kids = (parent).find(createFieldSelector("RollUpCountSettlement__c")).text();
		kids = parseInt(kids) ? parseInt(kids) : 0;
		if (kids) {
	       jq( parent ).find( "select" ).prop( "disabled", true );
	       jq( parent ).find( "input" ).attr( "readonly", true ).attr( "disabled", true );
	       jq( parent ).find( "select" ).removeClass('gbrq');
	       jq( parent ).find( "input" ).removeClass('gbrq');
	        nut = jq( parent ).find(createFieldSelector("HouseNut__c"));
	        nut = nut.find('input');
	        nut.attr( "readonly", false ).attr( "disabled", false );   
		}
	});

	jq( `#gbMainTable > tbody > tr > ${createFieldSelector("RollUpCountSettlement__c")}` ).each( function( elIndex, el ){
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
	       	if (jq(toggle).closest('h3').hasClass('collapsed')) {
	       		toggle.each( function() {
		       		el.click();
		       	});
	       	}
		} 
	});

	markTableReady(true);

	gridStateMessagingController('nutter');
	makeX50148XRowsReadonly();
});