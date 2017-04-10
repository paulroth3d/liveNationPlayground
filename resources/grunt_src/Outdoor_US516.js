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
    setRecordType();
    setApplyNet();
}

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

//Convert to whole number
function convertToNumber(s){
    return Number(s.replace(/[^0-9\.]+/g,""));
}

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
        jq('.gridBtnsCell').on( 'click', 'input.createNew', newRow);
    }

    markTableReady(true);

    gridStateMessagingController();



    jq('.createNew').click(function(){
        jq('.mainTable').find('.dr').first().find(applyNetSelector).find('input').attr("checked",true);
    })


    var applyNetSelector = createFieldSelector('ApplyNet__c'),
        calcGrossSelector = createFieldSelector('CalculatedGross__c'),
        calcNetSelector = createFieldSelector('CalculatedNet__c'),
        effCommSelector = createFieldSelector('EffectiveCommission__c'),
        commisionSelector = createFieldSelector('Commission__c'),
        rateSelector = createFieldSelector('Rate__c'),
        numLocationsSelector = createFieldSelector('NumberofLocations__c');

    //Hide the effective commision column 
    jq(effCommSelector).hide();

        // Commision Input validation 
        jq(commisionSelector).find('input[type="text"]').first().attr({type:"number"});

        function updateOutdoorCalculations(){
            var applyNet = jq(this).parents('tr').find(applyNetSelector).find('input'). is(':checked')
            var calcGross = convertToNumber(jq(this).parents('tr').find(calcGrossSelector).text());
            var calcNet = convertToNumber(jq(this).parents('tr').find(calcNetSelector).text());
            var commission = convertToNumber( jq(this).parents('tr').find(commisionSelector).find('input').val());
            var effectComm = convertToNumber(jq(this).parents('tr').find(effCommSelector).find('.txt').val());
            var numLocations = convertToNumber(jq(this).parents('tr').find(numLocationsSelector).find('.txt').val());
            var Rate = convertToNumber(jq(this).parents('tr').find(rateSelector).find('.txt').val());
        
            
            if(effectComm == "" || null){
                effectComm = commission/ 100;
                
            }else if(jq.isNumeric(commission) && commission/100 != effectComm){
                effectComm = commission /100;
            }

            if (applyNet == false) {
                calcNet =  (Rate * (1- effectComm)) * numLocations;	
                calcGross= Rate * numLocations; 
            } else if (applyNet == true) {
                calcNet = Rate * numLocations;
                calcGross = (Rate/ (1-effectComm)) * numLocations; 
            } 
            

            calcGross = "USD " + calcGross.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
            calcNet = "USD " + calcNet.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
            jq(this).parents('tr').find(calcGrossSelector).text(calcGross);
            jq(this).parents('tr').find(calcNetSelector).text(calcNet);
        }

        //Apply Net Change 
        jq(applyNetSelector).on('change','input',function(){
            updateOutdoorCalculations.call(this);
        })
        //Commision change 
        jq(commisionSelector).keyup(function(){
            updateOutdoorCalculations.call(this);
        })

        //Rate Update 
	    jq('.mainTable').on('keyup',rateSelector,function(){
	        updateOutdoorCalculations.call(this);
	    });

});


