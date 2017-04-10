({
	/**
	 *  initialize event
	 **/
    doInit: function(component, event, helper) {
        //console.log( "doInit");
        
		helper.onetimeSetup(component,helper);
	},
    
    /**
     *  Handler for when all associated scripts have finished loading
     **/
    handleScriptsLoaded: function( component, event, helper ){
        //console.log( 'VisualforceContainer loaded' );
        //debugger;
		//-- proth: i have no idea why it is that LNE_PostMessage is not available here
		console.log( 'LNE_PostMessage:' + (typeof LNE_PostMessage) + ' from handleScriptsLoaded' );
    },
    
    /**
     *  handles when the toggle button is pressed
     **/
    openWindow: function( component,event,helper ){
        console.log('openWindow');
        component.set('v.sideNavWidth','0');
    },
    closeWindow: function( component,event,helper){
        console.log('closeWindow');
        component.set('v.sideNavWidth','100%');
    }
})