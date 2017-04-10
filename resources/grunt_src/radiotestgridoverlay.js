//-- your info goes here:radiotestpopup
//-- to deploy run: grunt deployGridBuddyResource:radiotestpopup

//-- makes gridInfoByField and gridInfoById available
convertGridInfoMap();

function handleResultDispatch( event ){
	console.log( 'postMessage dispatch caught' );
	console.log( arguments );
	debugger;
	
	var postMessage = LNE_PostMessage.parse( event );
	
	//-- is this the event we are looking for?
	//-- the source and the messageType are the same
	//-- as the page that dispatched it?
	
	if( postMessage.matchesPageMessage( 'testGridOverlay','complete' )){
		var advertisementId = postMessage.data.advertisementId;
		var numSpots = postMessage.data.numSpots;
		
		//-- find the id of Num
		var columnIdOfNumberOfSpots = createFieldSelector( gridInfoByField.NumberofSpots__c.fieldName );
		
		jq("#gbMainTable")
			.find( "tr#" + postMessage.data.advertisementId )
			.find( columnIdOfNumberOfSpots )
			.text( postMessage.data.numSpots )
			.css( "color", "#F00" );
		
		//-- close the inline popup
		//-- otherwise (if a popup) the LNE_TestGridOverlay self destructs instead. (using window.self.close())
		try {
			jQuery( ".closeX" ).click();
		} catch( err ){}
	}
}

//-- all postMessages are dispatched as window level events
//-- of type 'message'
//-- for more info, please see: https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage
window.addEventListener( "message", handleResultDispatch, false );

//-- this is absolutely not necessary and only included to provide a debug hook if needed.
jq(document).ready(function(){
	console.log( 'radiotestgridoverlay document is ready' );	
	debugger;
});