/**
*   Make sure any rows on initial load do not allow record type change
*/
function makeRecordTypeReadOnly() {
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        if (jq(this).val() == 'Digital') {
            jq(this)[0].readOnly = true;
        }
    });
}

function newRow() {
    console.log('newRow in digital.js fires');
    setRecordType();
}

/**
*   When adding a new record, default record type and make it read only
*/
function setRecordType() {
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        if (jq(this).val() != 'Digital') {
            jq(this).val('Digital').change().hide();
            jq(this)[0].readOnly = true;
        }
        jq(createFieldSelector('RecordTypeId')).hide();
    });
}

function setApplyNet() {
    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.ApplyNet__c.fieldName)).each(function() {
        // check
        if (!jq(this).prop('checked') && jq(this).closest('tr').hasClass('nr')) {            
            jq(this).prop('checked', true).change();
        } 
    });
}

function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

//Convert to whole number
function convertToNumber(s){
    return Number(s.replace(/[^0-9\.]+/g,""));
}

function getCommissionFromServer() {
    var recordTypeSelector = createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName);
    var advertisementRecord = {};
    var AdPlanId = getUrlParameter('fpv');

    val = jq('.mainTable').find('.dr').first().find(recordTypeSelector).val();
    if (val) {
        val = val ? val.toLowerCase() : adType;
        advertisementRecord.type = val;
    } else {
        advertisementRecord.type = 'Digital';
    }

    advertisementRecord.AdPlan__c = AdPlanId;

    var url = createApexURL("LNE_AdvertisementAPI"); 

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
        jq('.gridBtnsCell').on( 'click', 'input.createNew', newRow);
    }

    //Hide record type
    jq(createFieldSelector('RecordTypeId')).hide();
    getCommissionFromServer();

    markTableReady(true);

    gridStateMessagingController();
     
    var applyNetSelector = createFieldSelector('ApplyNet__c'),
        calcGrossSelector = createFieldSelector('Gross__c'),
        calcNetSelector = createFieldSelector('Net__c'),
        effCommSelector = createFieldSelector('EffectiveCommission__c'),
        commisionSelector = createFieldSelector('Commission__c')
        

    //Hide the effective commision column 
     jq(effCommSelector).hide();

     //Hide record type
    jq(createFieldSelector('RecordTypeId')).hide()
    jq(createFieldSelector('MasterAdForSplit__c')).hide();
    

    //Default Commision on new entry
    jq('.createNew').click(function(){
        jq(applyNetSelector, newRow).find('input[type="checkbox"]').first().prop('checked',true);
        jq(createFieldSelector('MasterAdForSplit__c')).hide();
        getCommissionFromServer();
    })
        

    // Commision Input validation 
    jq(commisionSelector).find('input[type="text"]').first().attr({type:"number"});

    function updateDigitalCalculations(_input){
        getCommissionFromServer();

        var applyNet = jq(this).parents('tr').find(applyNetSelector).find('input').is(':checked')
        var calcGross = convertToNumber(jq(this).parents('tr').find(calcGrossSelector).find('.txt').val()) || 0;
        var calcNet = convertToNumber(jq(this).parents('tr').find(calcNetSelector).find('.txt').val()) || 0;
        var commission = convertToNumber( jq(this).parents('tr').find(commisionSelector).find('input').val()) || 0;
        var effectComm = convertToNumber(jq(this).parents('tr').find(effCommSelector).find('.txt').val()) || 0;

        //Hide the effective commision column 
        jq(effCommSelector).hide();

        if(effectComm == "" || null){
            effectComm = commission/ 100;
            
        }else if(jq.isNumeric(commission) && commission != 0 && commission/100 != effectComm){
            effectComm = commission /100;
        }

        if (applyNet == false) {
            calcNet =  calcGross * (1 - effectComm)
        } else if (applyNet == true) {
            calcGross = calcNet / (1 - effectComm)
        } 
        

        calcGross = calcGross.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
        calcNet =  calcNet.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
        
        if(_input){
            if(_input =='Gross'){
                jq(this).parents('tr').find(calcNetSelector).find('.txt').val(calcNet);
            }else if(_input == 'Net'){
                jq(this).parents('tr').find(calcGrossSelector).find('.txt').val(calcGross);
            }
        }else{
            jq(this).parents('tr').find(calcGrossSelector).find('.txt').val(calcGross);
            jq(this).parents('tr').find(calcNetSelector).find('.txt').val(calcNet);
        }
    }

    //Apply Net Change 
    jq('.mainTable').on( 'change', applyNetSelector, function(){
        updateDigitalCalculations.call(this);
    })

     //Update on commision 
    jq('.mainTable').on('keyup',commisionSelector,function(){
        updateDigitalCalculations.call(this);
    });

    jq('.mainTable').on('keyup',calcNetSelector,function(){
        updateDigitalCalculations.call(this,'Net');
    });

    jq('.mainTable').on('keyup',calcGrossSelector,function(){
        updateDigitalCalculations.call(this,'Gross');
    });

    jq('.saveBtn').click(function() {
        jq('body').focus();
        jq(applyNetSelector).find('input').change();
        jq(calcGrossSelector).find('.txt').change()
        jq(calcNetSelector).find('.txt').change(); 
        parent.postMessage('Saving', '*');
    });

    jq('.deleteItem').click(function() {
        parent.postMessage('Saving', '*');
    });

    jq(window).on('message', function(e) {
        if (e.originalEvent.data == 'refresh') {
            jq('.refreshBtn').click();
        }
     });

    parent.postMessage('Loaded','*');
});


