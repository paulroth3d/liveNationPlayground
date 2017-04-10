/**
*   Make sure any rows on initial load do not allow record type change
*/
function makeRecordTypeReadOnly() {
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        if (jq(this).val() == 'ProductionMiscellaneous') {
            jq(this)[0].readOnly = true;
        }
    });
}

/**
*   When adding a new record, default record type and make it read only
*/
function setRecordType() {
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        if (jq(this).val() != 'Production/Miscellaneous') {
            jq(this).val('Production/Miscellaneous').change();
            jq(this)[0].readOnly = true;
        } 
        jq(createFieldSelector('RecordTypeId')).hide();
    });
}

function disableSplitRows() {

    // for each masteradforsplit input, if not blank then disable the entire ro
    jq('tr.dr ' + createFieldInputSelector('MasterAdForSplit__c')).each(function() {
        if (this.value != '') {
            //get row
            jq(this).closest('tr').find('td.ui-selectee').each(function() {
                jq(this).find('.plTxt').click();
                jq(this).find('input, textarea, select').attr('disabled', true);
                jq(this).find('.gbdt').hide();
            });

        }
    });

}


jq(document).ready(function() {
    var initialFocus = true;

    console.log('gbc_ProductionMiscellaneous_js document.ready fired!');

    //-- always call after jq(document).ready for all scripts
    convertGridInfoMap(gridInfoMap);

    //-- mark the grid as not ready, so change events should not be fired
    markTableReady(false);

    disableSplitRows();

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

    //Hide record type
    jq(createFieldSelector('RecordTypeId')).hide();
    jq(createFieldSelector('MasterAdForSplit__c')).hide();

    markTableReady(true);

    gridStateMessagingController();

    jq('.saveBtn').click(function() {
        parent.postMessage('Saving', '*');
    });

    jq('.deleteItem').click(function() {
        parent.postMessage('Saving', '*');
    });

    jq('.createNew').click(function(){
        jq(createFieldSelector('MasterAdForSplit__c')).hide();
    });
    
    jq(window).on('message', function(e) {
        if (e.originalEvent.data == 'refresh') {
            jq('.refreshBtn').click();
        }
     });

    parent.postMessage('Loaded','*');
});


