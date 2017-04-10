
jq(document).ready(function() {
    var initialFocus = true;

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
        jq('.gridBtnsCell').on( 'click', 'input.createNew', setRecordType('Television'));
    }

    markTableReady(true);

    gridStateMessagingController();

    setupInsertionWidget('television');


    jq('.mainTable').on( 'change', applyNetSelector, function(){
        updateDefaultCalculations.call(this);
    })

    //Buy Type Update
    jq('.mainTable').on('change',buyTypeSelector,function(){
        updateDefaultCalculations.call(this);
    });

    //Rate Update
    jq('.mainTable').on('keyup',rateSelector,function(){
        updateDefaultCalculations.call(this);
    });
});


