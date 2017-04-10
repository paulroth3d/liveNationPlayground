({
	/** determines the current Venue info **/
	getCurrentRecord : function( component, helper ) {
		//console.log( 'get current record' );
		var recordId = component.get('v.recordId');
		
		var action=component.get("c.getVenueById");
		action.setParams({ recordId: recordId });
		
		action.setCallback(this,function(response){
			//console.log( 'current record response found' );
			var state = response.getState();
			if( state === 'SUCCESS' ){
				var venue = response.getReturnValue();
				component.set('v.venue',venue);
				component.set('v.defaultSearch',venue.VenueName__c );
				helper.handleInitComplete(component,helper);
			} else {
				helper.handleResponseError( response, 'Something went wrong in getting the current venue', component, helper );
			}
		});
		$A.enqueueAction(action);
	},
	
	/** Checks if the current user has edit access to the record **/
	validateAccess : function( component, helper ) {
		var recordId = component.get('v.recordId');
		
		var action=component.get("c.checkIfUserCanEditCurrentRecord");
		action.setParams({ recordId: recordId });
		
		action.setCallback(this,function(response){
			var state = response.getState();
			if( state === 'SUCCESS' ){
				var canEdit = response.getReturnValue();
				if (canEdit == true) {
					helper.getCurrentRecord(component, helper);
					component.set("v.hasAccess", true);
				} else {
					component.set("v.showNoAccessMessage", true);
				}
			} else {
				helper.handleResponseError( response, 'Something went wrong in getting the current artist', component, helper );
			}
		});
		$A.enqueueAction(action);
	},
	
	/**
	 *	Sets the selected venue.
	 *	@param selectedVenue (String) - key for the current venue
	 **/
	setSelectedVenue: function( liveNationId, component, helper ){
		var recordId = component.get( 'v.recordId' );
		//console.log( 'selected venue[' + recordId + ':' + liveNationId + ']' );
		
		var action=component.get("c.setVenueLiveNationId");
		action.setParams({ recordId: recordId, liveNationData: liveNationId });
		
		action.setCallback(this,function(response){
			//console.log( 'set selected venue response found' );
			var state = response.getState();
			if( state === 'SUCCESS' ){
				//console.log( 'venue livenation id was set' );
				helper.closeDialog( component, helper );
			} else {
				helper.handleResponseError( response, 'something went wrong in setting the livenation Id', component, helper );
			}
		});
		$A.enqueueAction(action);
	},
	
	/**
	 *	Closes the dialog
	 **/
	closeDialog: function( component, helper ){
		//console.log( 'closing the dialog' );
		$A.get('e.force:refreshView').fire();
		$A.get("e.force:closeQuickAction").fire();
	},
	
	/**
	 * Handles errors within Controller calls
	 * @param response
	 **/
	handleResponseError: function( response, message, component, helper ){
		console.error( 'ERROR: ' + message );
		debugger;
		var errors = response.getError();
		console.error( state );
		console.error( errors );
		if( errors ){
			if( errors[0] && errors[0].message ){
				console.error( 'ERROR:' + errors[0].message );
			}
		}
	},
	
	/**
	 *	Handles when the initialization completes.
	 **/
	handleInitComplete: function( component, helper ){
		//console.log( 'initializationComplete' );
		component.set('v.initComplete',true);
	},
	
	
	/** performs the search **/
	doSearch: function( component, helper ){
		component.set('v.hasResults', false );
		component.set('v.noResultsFound', false );
		var searchText = component.find('searchIn').get('v.value');
		//var apiSettings = component.get( 'v.apiSettings' );
		console.log( 'doing the search:' + searchText );
		
		var action = component.get( 'c.searchVenues' );
		action.setParams({ venueQuery: searchText });
		action.setCallback( this, function(response){
			console.log( 'options found' );
			var state = response.getState();
			if( state === 'SUCCESS' ){
				var options = response.getReturnValue();
				helper.showResults( response.getReturnValue(), component, helper );
			} else {
				helper.handleResponseError( response, 'something went wrong in getting the API Settings', component, helper );
			}
		});
		$A.enqueueAction(action);
	},
	
	/**
	 * Pushes a set of results to the selection
	 * @param queryOptions (SelectOption2[])
	 **/
	showResults: function( queryOptions, component, helper ){
		var options = [];
		if( queryOptions && queryOptions.length < 1 ){
			component.set('v.hasResults', false );
			component.set('v.noResultsFound', true );
		} else {
			component.set('v.hasResults', true );
			component.set('v.noResultsFound', false );
			
			var options = [];
			var optionLabel = null;
			var queryOption = null;
			
			var currentLiveNationId = '';
			var venue = component.get( 'v.venue' );
			var currentLiveNationId = venue.LNEAPIId__c;
			var matchingVenueFound = false;
			var isSelected = false;
			var opt = { "class": "optionClass", "label": "-- Select --", "value": "" };
			options.push( opt );
			
			for( var i = 0; i < queryOptions.length; i++ ){
				queryOption = queryOptions[i];

				var labelText = queryOption.name + " (" + queryOption.id + " - " + queryOption.city + ")";
				var valueText = queryOption.name + "|;|" + queryOption.id + "|;|" + queryOption.urlSlug + "|;|" + queryOption.hostVenueId + "|;|" + queryOption.latitude + "|;|" + queryOption.longitude;
				
				//-- does not make any sense why selected cannot be true or false.
				opt = { "class": "optionClass", "label": labelText, "value": valueText, "selected": isSelected };
				
				if( currentLiveNationId == queryOption.id ){
					opt.selected = 'true';
					matchingVenueFound = true;
				}
				
				options.push( opt );
			}
			
			component.find('apiResultSel').set('v.options',options);
		}
	}
})