({
    getPageSrc : function(pageName, recordId, urlArguments, auraId){
        var pageSrc='';
        
        //-- calculate the target page src/address.
        if( pageName ){
            pageSrc='/apex/'+pageName+"?auraId=" + auraId;
            if( recordId ){
                pageSrc+='&Id='+recordId;
            }
            if( urlArguments ){
                pageSrc+='&'+urlArguments;
            }
        }
        
        return( pageSrc );
    },
    
    /**
     *  Setup that should only run once.
     **/
    onetimeSetup: function( component, helper){
        //-- only setup an event listener once for this component.
        console.log( 'onetimeSetup attempted' );
        
        var didRun=false;
        
        if( component.get('v.setupComplete') === false ){
            console.log( 'init and code all loaded' );
            
            //-- this will only run once
            helper.setupPostMessageListeners(component, helper);
            
            component.set('v.setupComplete',true);
            didRun=true;
        }
        
        console.log( 'onetimeSetup completed' );
        return( didRun );
    },
    
    /**
     * Sets up the listners for visualforce notifications.
     **/
    setupPostMessageListeners: function(component, helper){
        
        this.postOffice = new LNE_MessagePostOffice(this);
        
        //-- handle the save complete
        this.postOffice.addTypeHandler( 'saveComplete', function( myPostMessage ){
            //-- now notify visualforce pages.
            var iFrameTarget=component.find( "targetFrame").getElement();
            
            console.log( "YAY, vf event in lightning" );
            
            $A.get('e.force:refreshView').fire();
            
            //-- tell the other pages
            myPostMessage.dispatch( iFrameTarget.contentWindow );
        });

        //-- handle opening a new tab
        this.postOffice.addTypeHandler( 'openTab', function( myPostMessage ){

            if( myPostMessage.data.auraId &&
                myPostMessage.data.auraId !== component.getGlobalId()
            ){
                console.log( 'auraId sent and does not match. not sending aura message' );
            } else {

                window.open(myPostMessage.data.src, '_blank');

            }
        });
        
        //-- handle any unknown types of events
        this.postOffice.addTypeHandler( null, function( myPostMessage ){
            //-- now notify visualforce pages.
            var iFrameTarget=component.find( "targetFrame").getElement();
            
            console.log( "YAY, vf event in lightning" );
            
            if( typeof myPostMessage.data.auraMessageType !== 'undefined' &&
               myPostMessage.data.auraMessageType
            ){
               
                if( myPostMessage.data.auraId &&
                    myPostMessage.data.auraId !== component.getGlobalId()
                ){
                    console.log( 'auraId sent and does not match. not sending aura message' );
                } else {
                    var auraMessageData = {} || myPostMessage.data.auraMessageData;
                    //console.log( 'Aura message:' + myPostMessage.data.auraMessageType );
                    //console.log( 'Aura data:' ); console.log( myPostMessage.data.auraMessageData );
                    
                    //debugger;
                    var appEvent = $A.get( myPostMessage.data.auraMessageType );
                    appEvent.setParams(myPostMessage.data.auraMessageData);
                    appEvent.fire();
                }
            }
            
            //-- tell the other pages.
            myPostMessage.dispatch( iFrameTarget.contentWindow );
        });
        
        this.postOffice.listenForPostEvents(window);
    }
})