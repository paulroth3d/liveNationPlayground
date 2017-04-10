var applyNetSelector;
var calcGrossSelector;
var calcNetSelector;
var effCommSelector;
var commisionSelector;
var rateSelector;
var numLocationsSelector;
var recordTypeSelector; 

var advertisementRecord = {};

/**
*   When adding a new record, default record type and make it read only
*/
function setRecordType() {
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        if (jq(this).val() != 'Outdoor') {
            jq(this).val('Outdoor').change();
            jq(this)[0].readOnly = true;
        }
        jq(createFieldSelector('RecordTypeId')).hide();
    });
}

/**
*   Make sure any rows on initial load do not allow record type change
*/
function makeRecordTypeReadOnly() {
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        if (jq(this).val() == 'Outdoor') {
            jq(this)[0].readOnly = true;
        }
    });
}

function setSelectors() {
    applyNetSelector = createFieldSelector('ApplyNet__c'),
    calcGrossSelector = createFieldSelector('CalculatedGross__c'),
    calcNetSelector = createFieldSelector('CalculatedNet__c'),
    effCommSelector = createFieldSelector('EffectiveCommission__c'),
    commisionSelector = createFieldSelector('Commission__c'),
    rateSelector = createFieldSelector('Rate__c'),
    numLocationsSelector = createFieldSelector('NumberofLocations__c'),
    recordTypeSelector = createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName);    
}

function newRow() {
    setSelectors();
    setRecordType();
    makeRecordTypeReadOnly();
        
    jq(applyNetSelector).find('input[type="checkbox"]').first().prop('checked',true);
    jq(createFieldSelector('MasterAdForSplit__c')).hide();
    getCommissionFromServer();
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

function updateOutdoorCalculations(){
    getCommissionFromServer();

    var applyNet = jq(this).parents('tr').find(applyNetSelector).find('input').is(':checked')
    var calcGross = convertToNumber(jq(this).parents('tr').find(calcGrossSelector).text());
    var calcNet = convertToNumber(jq(this).parents('tr').find(calcNetSelector).text());
    var commission = convertToNumber( jq(this).parents('tr').find(commisionSelector).find('input').val()) || 0;
    var effectComm = convertToNumber(jq(this).parents('tr').find(effCommSelector).find('.txt').val()) || 0;
    var numLocations = convertToNumber(jq(this).parents('tr').find(numLocationsSelector).find('.txt').val()) || 0;
    var Rate = convertToNumber(jq(this).parents('tr').find(rateSelector).find('.txt').val()) || 0;

    if(effectComm == "" || null){
        effectComm = commission/ 100;
        
    }else if(jq.isNumeric(commission) && commission != 0 && commission/100 != effectComm){
        effectComm = commission /100;
    }
    if(Rate !=0){
         if (applyNet == false) {
            calcNet =  (Rate * (1- effectComm)) * numLocations; 
            calcGross= Rate * numLocations; 
        } else if (applyNet == true) {
            calcNet = Rate * numLocations;
            calcGross = (Rate/ (1-effectComm)) * numLocations; 
        } 

    }else{
        calcGross = 0;
        calcNet = 0; 
    }

    calcGross = "USD " + calcGross.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    calcNet = "USD " + calcNet.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    jq(this).parents('tr').find(calcGrossSelector).text(calcGross);
    jq(this).parents('tr').find(calcNetSelector).text(calcNet);
}

function getCommissionFromServer() {
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

    }

    markTableReady(true);

    gridStateMessagingController();
    setSelectors();

    //Default Commision on new entry
    jq('.createNew').click(function(){
        newRow();
    });

    var AdPlanId = getUrlParameter('fpv');

    val = jq('.mainTable').find('.dr').first().find(recordTypeSelector).val();
    if (val) {
        val = val ? val.toLowerCase() : adType;
        advertisementRecord.type = val;
    } else {
        advertisementRecord.type = 'Outdoor';
    }

    advertisementRecord.AdPlan__c = AdPlanId;

    getCommissionFromServer();

    //Hide the effective commision column 
    jq(effCommSelector).hide();
    jq(createFieldSelector('MasterAdForSplit__c')).hide();

    //Hide record type
    jq(createFieldSelector('RecordTypeId')).hide();

    // Commision Input validation 
    jq(commisionSelector).find('input[type="text"]').first().attr({type:"number"});

    //Apply Net Change 
    jq('.mainTable').on( 'change', applyNetSelector, function(){
        updateOutdoorCalculations.call(this);
    })
    //Commision change 
    jq('.mainTable').on('keyup',commisionSelector,function(){
        updateOutdoorCalculations.call(this);
    });

    //Rate Update 
    jq('.mainTable').on('keyup',rateSelector,function(){
        updateOutdoorCalculations.call(this);
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

    jq(window).on('message', function(e) {
        if (e.originalEvent.data == 'refresh') {
            jq('.refreshBtn').click();
        }
     });

    parent.postMessage('Loaded','*');

});


