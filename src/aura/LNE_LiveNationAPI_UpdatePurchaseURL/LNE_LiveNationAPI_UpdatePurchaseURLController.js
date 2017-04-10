({
	/** initialization **/
    doInit : function(component, event, helper) {
		console.log( 'doInit' );
        helper.validateAccess( component,helper );
	},
    
    /** handler for when the scripts have finished loading. If Any **/
    handleScriptsLoaded: function( component, event, helper ){
        console.log( 'venueSearch scripts loaded correctly' );
    },
    
    /** handles when a user clicks on one of the event selections **/
    handleEventSelected: function( component, event, helper ){
        console.log( 'event was selected' );
        var selectedLiveNationId = component.find('apiResultSel').get('v.value');
        if( selectedLiveNationId ){
        	helper.setSelectedEvent( selectedLiveNationId, component, helper );
        }
    },
    
    showSpinner: function( component, event, helper ){
        component.set("v.showSpinner", true);
    },
    hideSpinner: function( component, event, helper ){
        component.set("v.showSpinner", false);
    }
})