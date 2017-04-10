({
	/**
	 * loads in all the quicklinks
	 **/
    loadQuickLinks : function( component, helper ) {
		var action=component.get("c.getMyLinks");
        action.setStorable();
        //action.setParams({ userId: something });
        
        action.setCallback(this,function(response){
            console.log( 'quicklinks returned' );
            var state = response.getState();
            if( state === 'SUCCESS' ){
                var quickLinkList = response.getReturnValue();
                component.set('v.quickLinks',quickLinkList);
                helper.handleInitComplete(component,helper);
            } else {
                helper.handleResponseError( response, 'something went wrong in getting the current venue', component, helper );
            }
        });
        $A.enqueueAction(action);
	},
    
    /**
     * Called when the component completes initialization
     **/
    handleInitComplete : function( component, helper ){
    	component.set( 'v.setupComplete', true );
	},
    
    /** generates the target URL **/
    generateTargetURL : function( qlType, qlTarget ) {
        var result = qlTarget;
        if( qlType == 'Record' ){
            result = '/one/one.app#/sObject/' + qlTarget + '/view';
        } else if( qlType == 'Visualforce' ){
            result = '/one/one.app#/n/' + qlTarget;
        }
        return( result );
	}
})