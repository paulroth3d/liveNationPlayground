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
        if (jq(this).val() != 'Digital') {
            jq(this).val('Digital').change();
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

    console.log('Digital_US513 fired!!!');

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
		commisionSelector = createFieldSelector('Commission__c');



		// Commision Input validation 
		jq(commisionSelector).find('input[type="text"]').first().attr({type:"number"});

		function updateDigitalCalculations(){
			var applyNet = jq(this).parents('tr').find(applyNetSelector).find('input').	is(':checked')
			var calcGross = convertToNumber(jq(this).parents('tr').find(calcGrossSelector).text());
			var calcNet = convertToNumber(jq(this).parents('tr').find(calcNetSelector).text());
			var commission = convertToNumber( jq(this).parents('tr').find(commisionSelector).find('input').val());
			var effectComm = convertToNumber(jq(this).parents('tr').find(effCommSelector).find('.txt').val());

			//Hide the effective commision column 
			jq(effCommSelector).hide();
			
			if(effectComm == "" || null){
				effectComm = commission/ 100;
				
			}else if(commission/100 != effectComm){
				effectComm = commission /100;
			}

			if (applyNet == false) {
				calcNet =  calcGross * (1 - effectComm)
			} else if (applyNet == true) {
				calcGross = calcNet / (1 - effectComm)
			} 
			

			calcGross = "USD " + calcGross.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
			calcNet = "USD " + calcNet.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
			jq(this).parents('tr').find(calcGrossSelector).text(calcGross);
			jq(this).parents('tr').find(calcNetSelector).text(calcNet);
		}

		//Apply Net Change 
		jq(applyNetSelector).on('change','input',function(){
		    updateDigitalCalculations.call(this);
		})

		jq(commisionSelector).keyup(function(){
			updateDigitalCalculations.call(this);
		})

});


