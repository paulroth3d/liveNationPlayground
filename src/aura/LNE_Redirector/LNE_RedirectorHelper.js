({
    urlParams: function( url ){
        var results = {};
        if( !url ){
            return( results );
        }
        if( url.indexOf( "?" ) < 0 ){
            return( results );
        }
        var queryStr = url.substr( url.indexOf( "?" )+1 );
        queryStr = queryStr.replace( /&/gi, '?' ).replace( /\?amp;/gi, '&' );
        var paramList = queryStr.split( '?' );
    
        var paramName;
        var paramValue;
        var questionIndex;
        var param;
        for( var i = 0; i < paramList.length; i++ ){
            param = paramList[i];
            questionIndex = param.indexOf( '=' );
            if( questionIndex > -1 ){
                paramName = param.substr(0,questionIndex);
                paramValue = decodeURIComponent( param.substr( questionIndex+1 ) );
                results[paramName]=paramValue;
            }
        }
        return( results );
    },
    
    navigate: function( redirectType, redirectTarget ){
        var evt;
        if( redirectType == 'visualforce' ){
            evt = $A.get( 'e.force:navigateToURL' );
            evt.setParams({ 'url': '/apex/' + redirectTarget });
        } else if( redirectType == 'record' ){
            evt = $A.get( 'e.force:navigateToSObject' );
            evt.setParams({ 'recordId': redirectTarget });
        } else {
            evt = $A.get( 'e.force:navigateToURL' );
            evt.setParams({ 'url': redirectTarget });
        }
        evt.fire();
    }
})