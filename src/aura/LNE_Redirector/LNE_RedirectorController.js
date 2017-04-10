({
	doInit : function(component, event, helper) {
		var url=window.location.href;
        console.log( 'url' );console.log( url );
        var params=helper.urlParams( url );
        if( !params.hasOwnProperty( 'redirectType') &&
            !params.hasOwnProperty( 'redirectTarget' )
        ){
            console.log( 'not a redirect' );
            return;
        }
        
        var redirectType = params.redirectType;
        var redirectTarget = params.redirectTarget;
        
		helper.navigate( redirectType, redirectTarget );
	}
})