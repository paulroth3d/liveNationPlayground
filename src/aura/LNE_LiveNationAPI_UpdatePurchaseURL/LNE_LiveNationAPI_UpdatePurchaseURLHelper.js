({	
	/** Checks if the current user has edit access to the record **/
	validateAccess : function( component, helper ) {
		var recordId = component.get('v.recordId');
		
		var action = component.get("c.checkIfUserCanEditCurrentRecord");
		action.setParams({ recordId: recordId });
        
		action.setCallback(this,function(response){
			var state = response.getState();
            
			if( state === 'SUCCESS' ){
				var canEdit = response.getReturnValue();
				if (canEdit == true) {
					component.set("v.hasAccess", true);
                    helper.doSearch(component, helper);
				} else {
					component.set("v.showNoAccessMessage", true);
				}
			} else {
				helper.handleResponseError( response, 'Something went wrong in getting the current ad plan', component, helper );
			}
		});
		$A.enqueueAction(action);
	},
	
	/**
	 *	Sets the selected event.
	 **/
	setSelectedEvent: function( liveNationId, component, helper ){
		var recordId = component.get( 'v.recordId' );
		var action = component.get("c.setEventLiveNationId");
        
        console.log('wat', { recordId: recordId, liveNationData: liveNationId });
        
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
		var searchText = component.get('v.recordId');//component.find('searchIn').get('v.value');
		//var apiSettings = component.get( 'v.apiSettings' );
		console.log( 'doing the search:' + searchText );
		
		var action = component.get( 'c.searchEvents' );
		action.setParams({ adPlanId: searchText });
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
			var isSelected = false;
			var opt = { "class": "optionClass", "label": "-- Select --", "value": "" };
			options.push( opt );
			
			for( var i = 0; i < queryOptions.length; i++ ){
				queryOption = queryOptions[i];

				var labelText = queryOption.name;
				var valueText = queryOption.purchaseURL;
				
				//-- does not make any sense why selected cannot be true or false.
				opt = { "class": "optionClass", "label": labelText, "value": valueText, "selected": isSelected };
				
				options.push( opt );
			}
			
			component.find('apiResultSel').set('v.options',options);
		}
	}
})