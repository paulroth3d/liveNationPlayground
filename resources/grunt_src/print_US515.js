

jq(document).ready(function() {
    var initialFocus = true;
    console.log('gbc_Print_js document.ready fired!');

    //-- always call after jq(document).ready for all scripts
    convertGridInfoMap(gridInfoMap);

    //-- mark the grid as not ready, so change events should not be fired
    markTableReady(false);

    if ( readOnlyGrid === false ) {
        /**
        *   Setup
        */
        makeRecordTypeReadOnly();

        /**
        *   Event handlers
        */
        jq('.gridBtnsCell').on( 'click', 'input.createNew', setRecordType);
    }

    markTableReady(true);

    gridStateMessagingController();

    setupInsertionWidget('print');
    //Apply Net Change
    jq('.mainTable').on( 'change', applyNetSelector, function(){
        updateDefaultCalculations.call(this);
    })

    //Rate Update
    jq('.mainTable').on('keyup',rateSelector,function(){
        updateDefaultCalculations.call(this);
    });
     //Update on commision 
     jq('.mainTable').on('keyup',commisionSelector,function(){
         updateDefaultCalculations.call(this);
    });
});


