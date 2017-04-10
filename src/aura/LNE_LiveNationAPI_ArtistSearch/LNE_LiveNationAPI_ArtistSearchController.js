({
	/** initialization **/
    doInit : function(component, event, helper) {
		console.log( 'doInit' );
        helper.validateAccess( component,helper );
	},
    
    /** handler for when the search button is pressed **/
    handleSearch: function(component,event,helper){
        helper.doSearch(component,helper);
    },
    
    /** handler for when the scripts have finished loading. If Any **/
    handleScriptsLoaded: function( component, event, helper ){
        console.log( 'artist search scripts loaded correctly' );
    },
    
    /** handles when a user clicks on one of the artist selections **/
    handleArtistSelected: function( component, event, helper ){
        var selectedLiveNationId = component.find('apiResultSel').get('v.value');
        if( selectedLiveNationId ){
        	helper.setSelectedArtist( selectedLiveNationId, component, helper );
        }
    },
    
    showSpinner: function( component, event, helper ){
        component.set("v.showSpinner", true);
    },
    hideSpinner: function( component, event, helper ){
        component.set("v.showSpinner", false);
    }
})