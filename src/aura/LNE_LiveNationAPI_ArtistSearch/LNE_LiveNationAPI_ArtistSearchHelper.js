({
    /** determines the current Artist info **/
    getCurrentRecord : function( component, helper ) {
        //console.log( 'get current record' );
        var recordId = component.get('v.recordId');
        
        var action=component.get("c.getArtistById");
        action.setParams({ recordId: recordId });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if( state === 'SUCCESS' ){
                var artist = response.getReturnValue();
                component.set('v.artist',artist);
                component.set('v.defaultSearch',artist.Name );
                helper.handleInitComplete(component,helper);
            } else {
                helper.handleResponseError( response, 'Something went wrong in getting the current artist', component, helper );
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
     *  Sets the selected artist.
     *  @param selectedArtist (String) - key for the current artist
     **/
    setSelectedArtist: function( liveNationId, component, helper ){
        var recordId = component.get( 'v.recordId' );
        var action=component.get("c.setArtistLiveNationId");
        action.setParams({ recordId: recordId, liveNationData: liveNationId });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if( state === 'SUCCESS' ){
                helper.closeDialog( component, helper );
            } else {
                helper.handleResponseError( response, 'Something went wrong in setting the livenation Id', component, helper );
            }
        });
        $A.enqueueAction(action);
    },
    
    /**
     *  Closes the dialog
     **/
    closeDialog: function( component, helper ){
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
     *  Handles when the initialization completes.
     **/
    handleInitComplete: function( component, helper ){
        component.set('v.initComplete',true);
    },
    
    /** performs the search **/
    doSearch: function( component, helper ){
        component.set('v.hasResults', false );
        component.set('v.noResultsFound', false );
        var searchText = component.find('searchIn').get('v.value');
        var action = component.get( 'c.searchArtists' );
        action.setParams({ query: searchText });
        action.setCallback( this, function(response){
            var state = response.getState();
            if( state === 'SUCCESS' ){
                var options = response.getReturnValue();
                helper.showResults( response.getReturnValue(), component, helper );
            } else {
                helper.handleResponseError( response, 'Something went wrong in getting the API Settings', component, helper );
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
            
            var currentLiveNationId = component.get('v.artist').LNEAPIId__c;
            var matchingArtistFound = false;
            var isSelected = false;
            var opt = { "class": "optionClass", "label": "-- Select --", "value": "" };
            options.push( opt );
            
            for( var i = 0; i < queryOptions.length; i++ ){
                queryOption = queryOptions[i];

                var labelText = queryOption.name + " (" + queryOption.id + " - " + queryOption.urlSlug + ")";
                var valueText = queryOption.name + "|;|" + queryOption.id + "|;|" + queryOption.urlSlug;
                
                //-- does not make any sense why selected cannot be true or false.
                opt = { "class": "optionClass", "label": labelText, "value": valueText, "selected": isSelected };
                
                if( currentLiveNationId == queryOption.id ){
                    opt.selected = 'true';
                    matchingArtistFound = true;
                }
                
                options.push( opt );
            }

            component.find('apiResultSel').set('v.options',options);
        }
    }
})