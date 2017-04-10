/**
*   Make sure any rows on initial load do not allow record type change
*/
function makeRecordTypeReadOnly() {
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        if (jq(this).val() == 'Print') {
            jq(this)[0].readOnly = true;
        }
    });
}

/**
*   When adding a new record, default record type and make it read only
*/
function setRecordType() {
    console.log('print setRecordType fires');
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        if (jq(this).val() != 'Print') {
            jq(this).val('Print').change();
            jq(this)[0].readOnly = true;
        } 
        jq(createFieldSelector('RecordTypeId')).hide();
    });
}

function getCommissionFromServer() {
    var advertisementRecord = {};
    var AdPlanId = getUrlParameter('fpv');

    val = jq('.mainTable').find('.dr').first().find(recordTypeSelector).val();
    val = val ? val.toLowerCase() : adType;
    advertisementRecord.type = val;
    advertisementRecord.AdPlan__c = AdPlanId;

    var url = createApexURL("LNE_AdvertisementAPI");

    //Set Default Commision
    jq.ajax({
        url: url,
        data: {
            'Advertisement__c': JSON.stringify(advertisementRecord),
            'type': advertisementRecord.type
        },
        context: this,
        dataType: 'jsonp'
    }).done(function(results) {
        //debugger
        if (results && results.isSuccessful === true) {
            console.log("fields updated. returned result obj is ",results);
            var defaultComm = results.data.EffectiveCommission__c/ 100;
            jq('.mainTable').find('.dr').first().find(createFieldSelector('EffectiveCommission__c')).find('input').attr('value', defaultComm).hide();
        } else {
            //-- the service ran into a problem, but not catestrophic.
            console.log(
                "ajax not successful"
            );
            alert(results.message);
        }
    }).fail(function(){
        console.log("Service failure")
    })

    jq('.mainTable').on('keyup',rateSelector,function(){
        updateDefaultCalculations.call(this);
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
    console.log('gbc_Print_js document.ready fired!');

    //-- always call after jq(document).ready for all scripts
    convertGridInfoMap(gridInfoMap);

    //-- mark the grid as not ready, so change events should not be fired
    markTableReady(false);

    disableSplitRows();

    getCommissionFromServer();

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

    //setTimeout(setupInsertionWidget('print'), 3000);
    setupInsertionWidget('print');
    //Apply Net Change
    jq('.mainTable').on( 'change', applyNetSelector, function(){
        getCommissionFromServer();
        updateDefaultCalculations.call(this);
    })

    //Rate Update
    jq('.mainTable').on('keyup',rateSelector,function(){
        getCommissionFromServer();
        updateDefaultCalculations.call(this);
    });
    //Update on commision 
    jq('.mainTable').on('keyup',commisionSelector,function(){
        getCommissionFromServer();
        updateDefaultCalculations.call(this);
    });

    jq('.saveBtn').click(function() {
        jq('body').focus();
        jq(applyNetSelector).find('input').change();
        jq(rateSelector).find('input').change();
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


