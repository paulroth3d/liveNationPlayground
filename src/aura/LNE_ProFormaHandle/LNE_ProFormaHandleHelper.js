({
    /**
     *  Setup that should only run once.
     **/
    onetimeSetup: function( component, helper){
        //-- only setup an event listener once for this component.
        var didRun=false;
        if( component.get('v.setupComplete') === false ){
            
            //-- this will only run once
            
            
            component.set('v.setupComplete',true);
            didRun=true;
        }
        return( didRun );
    }
})