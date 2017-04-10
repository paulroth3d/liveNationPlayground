//-- your info goes here:ancillaryrevenuesnewrecordv1
//-- to deploy run: grunt deployGridBuddyResource:ancillaryrevenuesnewrecordv1

//-- list of underscore style templates
TEMPLATES = {
	ledgerEntryBreakoutURL : "LNE_TestCreateObjectPlaceholder?type=breakout&ledgerEntryId=<%= ledgerEntryId %>"
};

//-- convert them all to underscore style templates
_.each( Object.getOwnPropertyNames( TEMPLATES ), function( templateName ){
	TEMPLATES[templateName] = _.template( TEMPLATES[ templateName ] );	
});

/**
 *  Makes a gridBuddyRow disabled (or not)
 *  @param row (html entity for the tr row)
 *  @param isDisabled (Boolean) - whether the row should be disabled (true) or enabled (false)
**/
function makeRowDisabled( row, isDisabled ){
	
	jq( row ).find( "input" ).each( function( index, val ){
		jq( val ).attr( "readonly", isDisabled ).removeClass("gbrq");
	});
	
	jq( row ).find( "select" ).each( function( index, val ){
		jq( val ).attr( "disabled", isDisabled ).removeClass("gbrq");
	});
}

function handleCreateNewClicked( evt ){
	debugger;
	
	var el = evt.target;
	
	try {
	
		//-- console.log( 'please note, that this event is dispatched AFTER the row has been created. which is ultimately what we want anyway' );
		
		//-- verify that we only call if we are creating for Ledger Entries.
		if( jq(el).is("[title*='Ledger Entry']")){
			console.log( 'user clicked new on ledger entry' );
			
			var newRows = jq(el).parents(".branch").find( ".childDataContainer tr.nr" );
			if( !newRows ){
				console.error( "unable to find any rows" );
				debugger;
				return;
			}
			
			var newRow = jq(el).parents(".branch").find(".childDataContainer tr.nr")[0];
			makeRowDisabled( true );
			
			var ledgerEntryId = jq(el).parents("tr").prev().attr("id");
			if( !ledgerEntryId ){
				console.error( "unable to find the ledgerEntryId" );
				debugger;
				return;
			}
			
			var context = {
				url:createApexURL(TEMPLATES.ledgerEntryBreakoutURL({ ledgerEntryId: ledgerEntryId })),
				newRow:newRow,
				ledgerEntryId:ledgerEntryId
			};
			
			jq.ajax({
				url: context.url,
				context: context,
				dataType: 'jsonp'
			}).done( function( results ){
				if( results && results.isSuccessful === true ){
					console.log( "successfully worked through creating a placeholder for the ledger entry" );
					jq( this.newRow ).attr( "id", results.data.Id ).removeClass("nr");
					//-- have tried a number of ways - removing nr, remove plselected, removing the delete checkbox, updating the last entry the ui-selected, nothing works. 
					makeRowDisabled( this.newRow, false );
					debugger;
				} else {
					console.error( "Ledger Entry API call threw a known exception:" + results.message );
					debugger;
				}
			}).fail( function( req, string, msg ){
				console.error( "error when making the Ledger Entry api call" );
				console.error( arguments );
				debugger;
			});
		}
	} catch( err ){
		console.error( "no exceptions are expected" );
		console.error( err );
	}
}

jq(document).ready(function(){
	console.log('page starts up');
	debugger;
	
	jq("#gbMainTable").on( 'click', 'span.createNew', handleCreateNewClicked );
});