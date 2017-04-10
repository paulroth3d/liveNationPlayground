//-- your info goes here:ancillaryrevenuesnewrecordv1b
//-- to deploy run: grunt deployGridBuddyResource:ancillaryrevenuesnewrecordv1b

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
					
					var newRowHtml='<tr id="' + results.data.Id + '" class="dr" name="r0"><td class="chk ui-selectee"><input type="checkbox" class="dl"><div class="actionsBtn icon-ellipses ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" title="Actions" role="button" tabindex="0"><span class="ui-button-text">&nbsp;</span></div></td><td name="v0" class="ui-selectee"></td><td name="v1" class="ui-selectee"><input type="text" value="" maxlength="100" class="txt" style="background-image: url(&quot;data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABHklEQVQ4EaVTO26DQBD1ohQWaS2lg9JybZ+AK7hNwx2oIoVf4UPQ0Lj1FdKktevIpel8AKNUkDcWMxpgSaIEaTVv3sx7uztiTdu2s/98DywOw3Dued4Who/M2aIx5lZV1aEsy0+qiwHELyi+Ytl0PQ69SxAxkWIA4RMRTdNsKE59juMcuZd6xIAFeZ6fGCdJ8kY4y7KAuTRNGd7jyEBXsdOPE3a0QGPsniOnnYMO67LgSQN9T41F2QGrQRRFCwyzoIF2qyBuKKbcOgPXdVeY9rMWgNsjf9ccYesJhk3f5dYT1HX9gR0LLQR30TnjkUEcx2uIuS4RnI+aj6sJR0AM8AaumPaM/rRehyWhXqbFAA9kh3/8/NvHxAYGAsZ/il8IalkCLBfNVAAAAABJRU5ErkJggg==&quot;); background-repeat: no-repeat; background-attachment: scroll; background-size: 16px 18px; background-position: 98% 50%;"></td><td name="v2" class="pl ui-selectee"><div class="plTxt" tabindex="0"></div></td><td name="v3" class="ui-selectee"><nobr><span>USD </span><input type="text" value="" size="18" class="txt n"></nobr></td><td name="v4" class="ui-selectee"><nobr><span>USD </span><input type="text" value="" size="18" class="txt n"></nobr></td><td name="v5" class="ui-selectee"><nobr><span>USD </span><input type="text" value="" size="18" class="txt n"></nobr></td><td name="v6" class="pl ui-selectee"><div class="plTxt" tabindex="0"></div></td><td name="v7" class="pl ui-selectee"><div class="plTxt" tabindex="0"></div></td><td name="v8" class="ui-selectee"><nobr><span>USD </span><input type="text" value="" size="18" class="txt n"></nobr></td><td name="v9" class="ui-selectee"><input type="text" value="" size="18" class="txt n"></td><td name="v10" class="ui-selectee"><input type="text" value="" size="18" class="txt n"></td><td name="v11" class="ui-selectee"><nobr><span>USD </span><input type="text" value="" size="18" class="txt n" readonly="" disabled=""></nobr></td><td name="v12" class="ui-selectee"><nobr><span>USD </span><input type="text" value="" size="18" class="txt n" readonly="" disabled=""></nobr></td><td name="v13" class="ui-selectee"><nobr><span>USD </span><input type="text" value="" size="18" class="txt n" readonly="" disabled=""></nobr></td><td name="v14" class="ui-selectee"><input type="text" value="" size="18" class="txt n" readonly="" disabled=""></td><td name="v15" class="ui-selectee"><nobr><span>USD </span><input type="text" value="" size="18" class="txt n" readonly="" disabled=""></nobr></td><td name="v16" class="ui-selectee"><nobr><span>USD </span><input type="text" value="" size="18" class="txt n" readonly="" disabled=""></nobr></td><td name="v17" class="ui-selectee"><input type="text" value="" maxlength="255" class="txt"></td><td class="lastCol ui-selectee"></td></tr>';
					
					//-- gridbuddy still creates a new row.
					//jq(this.newRow).replaceWith(newRowHtml);
					jq(this.newRow).before(newRowHtml);
					jq(this.newRow).find(".minus").click();
					
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