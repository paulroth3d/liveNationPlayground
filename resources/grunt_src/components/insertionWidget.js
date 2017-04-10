convertGridInfoMap();

var BUY_TYPE_PKG_DATES = 'Pkg. Deal (select dates)';
var BUY_TYPE_PKG_RANGE = 'Pkg. Deal (date range)';
var BUY_TYPE_REGULAR = 'Regular Buy';
var MASTER_INSERTION = 'MASTER';


//get startdate selector
var startDateSelector = createFieldInputSelector('StartDate__c');

//get enddate selector
var endDateSelector = createFieldInputSelector('EndDate__c');

//get buytype selector
var buyTypeSelector = createFieldSelector('BuyType__c');

//get numberOfSpots selector
var numberOfSpotsSelector = createFieldInputSelector('NumberofSpots__c');

//get spottype selector
var spotTypeSelector;
try{spotTypeSelector = createFieldSelector('SpotType__c');}catch(e){}



var applyNetSelector = createFieldSelector('ApplyNet__c'),
    calcGrossSelector = createFieldSelector('CalculatedGross__c'),
    calcNetSelector = createFieldSelector('CalculatedNet__c'),
    rateSelector = createFieldSelector('Rate__c'),
    effCommSelector = createFieldSelector('EffectiveCommission__c'),
    commisionSelector = createFieldSelector('Commission__c'),
    numSpotSelector = createFieldSelector('NumberofSpots__c'),
    recordTypeSelector = createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName);


/**
 *   Make sure any rows on initial load do not allow record type change
 */
function makeRecordTypeReadOnly() {
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        jq(this)[0].readOnly = true;
    });
}

/**
 *   When adding a new record, default record type and make it read only
 */
function setRecordType(recType) {
    var sel;
    sel = createFieldInputSelector( gridInfoByField.RecordTypeId.fieldName );

    jq('#gbMainTable').find(createFieldInputSelector(gridInfoByField.RecordTypeId.fieldName)).each(function() {
        if (jq(this).val() != recType) {
            jq(this).val(recType).change();
            jq(this)[0].readOnly = true;
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
    if(s){
        return Number(s.replace(/[^0-9\.]+/g,""));
    }else
    {
        return;
    }

}

function getBuyType(element){
    return jq(buyTypeSelector+ ' .plTxt', element).text() || jq(buyTypeSelector + ' :input', element).val();
}

function updateAdInsertionCount(element, count){
    var adTotalInput = jq(numberOfSpotsSelector, element);
    adTotalInput.val(count);
    adTotalInput.change();
}

var renderInsertionWidget = function(element, buyTypeChange){

    var toggleMasterCount = jq('.insertionMasterCount', insertionContainer).length > 0;

    //determine type here
    var buyType = getBuyType(element);

    //start date string
    var startDateString = jq(startDateSelector, element).val();

    //end date string
    var endDateString = jq(endDateSelector, element).val();

    var childRow = jq(element).next('.cr');
    var childContainer = jq('.childDataContainer', childRow);
    var insertionContainer = jq('.insertionContainer', childContainer);

    if(insertionContainer.length==0){
        insertionContainer = jq('<div class="insertionContainer"></div>');
        jq(childContainer).append(insertionContainer);
    }

    jq(insertionContainer).empty();

    if(!startDateString.trim() || !endDateString.trim()){
        return;
    }

    //index existing inserts by date and id
    var insertionsByDate={},
        dateSelector,
        iDateInput,
        iDate,
        insertionDate,
        insertionStartDate,
        insertionEndDate,
        runOnSelector = createFieldInputSelector('RunOnThisDate__c', insertionMetadata),
        dateSelector = createFieldInputSelector('Date__c', insertionMetadata);

    jq('.childTable tbody tr[id]',childContainer).each(function(i, e){

        iDateInput = jq(dateSelector, e);
        iDate = iDateInput.val();

        if(!iDate.trim()){
            insertionsByDate[MASTER_INSERTION] = e;
        }else{
            insertionsByDate[iDate] = e;

            insertionDate = moment(iDate, "MM-DD-YYYY")

            if(!insertionStartDate || insertionStartDate.isAfter(insertionDate)){
                insertionStartDate = insertionDate;
            }

            if(!insertionEndDate || insertionDate.isAfter(insertionEndDate)){
                insertionEndDate = insertionDate;
            }
        }

    });

    var startDate = moment(startDateString, "MM-DD-YYYY"),
        countSelector = createFieldInputSelector('NumberofSpots__c', insertionMetadata),
        countInput,
        count = 0;

    //add the number of spots container and input for package buys
    if(buyType != BUY_TYPE_REGULAR){

        oInsRow = insertionsByDate[MASTER_INSERTION];

        if (oInsRow) {
            countInput = jq(countSelector, oInsRow)
            count = countInput.val();
        }

        var numLabel = (adType == 'print' ? 'ads' : 'spots');

        var masterContainer = jq('<div class="insertionMasterCount"># of ' + numLabel + ' :  <input type="number" class="spotInput" value="' + count + '"/></div>');
        jq(insertionContainer).append(masterContainer);

        if (oInsRow) {
            jq(masterContainer).prop('oRow', oInsRow);
        }
    }

    if(buyType!=BUY_TYPE_PKG_RANGE){

        var endDate = moment(endDateString, "MM-DD-YYYY"),
            calendarStartDate = moment(startDate).startOf('week'),
            calendarEndDate = moment(endDate).endOf('week');

        if(insertionStartDate && insertionStartDate.isBefore(calendarStartDate)){
            calendarStartDate = insertionStartDate.startOf('week');
        }

        if(insertionEndDate && insertionEndDate.isAfter(calendarEndDate)){
            calendarEndDate = insertionEndDate.endOf('week');
        }

        var numDays = calendarEndDate.diff(calendarStartDate, 'days');

        var table = jq('<table border="0" cellpadding="0" cellspacing="0" class="insertionInputContainer"><thead><tr><th>S</th><th>M</th><th>T</th><th>W</th><th>T</th><th>F</th><th>S</th></tr></thead><tbody></tbody></table>');
        jq(insertionContainer).append(table);

        var row, cell, oInsRow, input, inputsToTrigger = [], outsideRange, createNewInsertion = false;

        for(var i=0; i<=numDays; i++) {

            outsideRange = calendarStartDate.isBefore(startDate) || calendarStartDate.isAfter(endDate);

            if (i % 7 == 0) {
                row = jq('<tr></tr>');
                jq('tbody', table).append(row);
            }

            count = 0;
            oInsRow = insertionsByDate[calendarStartDate.format('MM/DD/YYYY')];
            cell = jq('<td></td>');

            row.append(cell);
            cell.html(calendarStartDate.format('M/D'));
            cell.prop('fullDate', calendarStartDate.format('MM/DD/YYYY'));

            if (oInsRow) {
                countSelector = createFieldInputSelector('NumberofSpots__c', insertionMetadata);
                countInput = jq(countSelector, oInsRow)
                count = countInput.val() || 0;
                cell.prop('oRow', oInsRow);
            }

            if (buyType == BUY_TYPE_PKG_DATES) {
                input = jq('<input type="checkbox"/>');

                var checked = oInsRow ? jq(runOnSelector, oInsRow).is(':checked') : false;

                //automatically check box if this is a new ad, the date is between the defined date range, and the user has not unchecked any boxes from this row
                createNewInsertion = (!outsideRange && buyTypeChange);

                input.attr('checked', checked);
                if(oInsRow){
                    countInput.val(0);
                    countInput.change();
                }

            } else {
                input = jq('<input type="number" class="spotInput" value="' + count + '"/>');
            }

            cell.append(input);

            if((createNewInsertion && !oInsRow)){
                input.trigger('click');
            }

            if (outsideRange) {
                jq(cell).addClass('outsideRange');
                jq(input).attr('readonly', true);
                jq(input).attr('disabled', true);
            }

            calendarStartDate.add(1, 'days');
        }
    }

    toggleMasterCount = (toggleMasterCount != jq('.insertionMasterCount', insertionContainer).length > 0);

    if(buyTypeChange && toggleMasterCount)updateAdInsertionCount(element, 0);

}

var insertionMetadata, newRecords = 0;



function updateDefaultCalculations(){
    var applyNet = jq(this).parents('tr').find(applyNetSelector).find('input').  is(':checked')
    var calcGross = convertToNumber(jq(this).parents('tr').find(calcGrossSelector).text());
    var calcNet = convertToNumber(jq(this).parents('tr').find(calcNetSelector).text());
    var buyType = getBuyType(jq(this).parents('tr'));
    var commission = convertToNumber( jq(this).parents('tr').find(commisionSelector).find('input').val()) || 0;
    var Rate = convertToNumber(jq(this).parents('tr').find(rateSelector).find('input').val()) || 0;
    var effectComm = convertToNumber(jq(this).parents('tr').find(effCommSelector).find('.txt').val()) || 0;
    var numSpots = parseInt(jq(this).parents('tr').find(numSpotSelector).find('input').val(), 10) || 0;

    //Hide the effective commision column
    jq(effCommSelector).hide();

    //Apply change events
    // jq(this).parents('tr').find(applyNetSelector).find('input').change();
    // jq(this).parents('tr').find(rateSelector).find('.txt').change();

    if(effectComm == "" || null){
        effectComm = commission/ 100;

    }else if(jq.isNumeric(commission) && commission != 0 && commission/100 != effectComm){
        effectComm = commission /100;
    }

    if(Rate !=0){
        if (buyType == 'Regular Buy') {
            if (applyNet == false) {
                calcGross = Rate * numSpots
                calcNet = (Rate  * (1 - effectComm)) * numSpots;
            } else if (applyNet == true) {
                calcGross = (Rate / (1 - effectComm)) * numSpots;
                calcNet = Rate * numSpots;
            }
        } else {
            if (applyNet == false) {
                calcGross = Rate;
                calcNet = (Rate * (1 - effectComm))
            } else if (applyNet == true) {
                calcGross = Rate / (1 - effectComm);
                calcNet = Rate;
            }
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

var insertionMasterChange = function(e){

    var masterContainer = jq(e.target).closest('.insertionMasterCount');

    //get count from master input
    var masterCount = jq(e.target).val();

    //get master insertion row from gridbuddy child grid
    var oRow = jq(masterContainer).prop('oRow');

    //if there is none
    if(!oRow){
        var container = jq(e.target).closest('.branch');

        //create a new row for the master insertion
        jq('.createNew:first', container).click();

        //assign the master insertion containers row to be the first record in the gridbuddy child grid (the new row that was just added)
        oRow = jq('.childTable .dr', container)[0];

        var runOnSelector = createFieldInputSelector('RunOnThisDate__c', insertionMetadata);

        jq(runOnSelector, oRow).prop('checked', false);

        jq(masterContainer).prop('oRow', oRow);
    }

    //set the count in the parent row
    updateAdInsertionCount(jq(oRow).closest('.cr').prev('.dr'), masterCount);

    //set the count for the master insertion NumberofSpots__c
    var countFieldSelector = createFieldInputSelector('NumberofSpots__c', insertionMetadata);
    var countField = jq(countFieldSelector, oRow);

    countField.val(masterCount);
    countField.change();

};

var insertionChange = function(e){

    var oRow = jq(e.target).closest('td').prop('oRow');
    var countFieldSelector = createFieldInputSelector('NumberofSpots__c', insertionMetadata);
    var countField;
    var runOnSelector = createFieldInputSelector('RunOnThisDate__c', insertionMetadata);
    var runOnField;
    var newCount = 0;

    if(!jq(e.target).is(':checkbox')){
        newCount = jq(e.target).val();
    }

    if(oRow){
        //editing an existing insertion
        countField = jq(countFieldSelector, oRow);
        runOnField = jq(runOnSelector, oRow);

    }else{

        //creating a new insertion for a date that did not previously have one
        var container = jq(e.target).closest('.branch');
        var fullDate = jq(e.target).closest('td').prop('fullDate');

        jq('.createNew:first', container).click();

        oRow = jq('#' + (-1*newRecords), container);
        jq(e.target).closest('td').prop('oRow', oRow);

        var dateFieldSelector = createFieldInputSelector('Date__c', insertionMetadata);
        if(oRow){
            var dateField = jq(dateFieldSelector, oRow);

            //FIXME: race condition because jquery datepicker takes a moment to render when a new record is added.
            setTimeout(function(){

                dateField.datepicker("setDate", fullDate);
                dateField.val(fullDate);
                dateField.change();

            }, 200);

            countField = jq(countFieldSelector, oRow);
            runOnField = jq(runOnSelector, oRow);
        }

    }

    var parentRow = jq(oRow).closest('.cr').prev('.dr');
    var buyType = getBuyType(parentRow);

    if(buyType==BUY_TYPE_PKG_DATES){
        runOnField.prop('checked', jq(e.target).is(':checked'));
        runOnField.change();
    }else{
        countField.val(newCount);
    }

    countField.change();

    //update total count on parent row
    if(buyType==BUY_TYPE_REGULAR) {
        //update total count in parent row
        var totalCount = 0;
        var allRows = jq(':input', jq(e.target).closest('tbody'));

        //total all insertion count
        jq(allRows).each(function (i, e) {
            totalCount += Number(jq(e).val());
        });

        //set value on parent
        updateAdInsertionCount(jq(oRow).closest('.cr').prev('.dr'), totalCount);
    }

    //Update calculations when spot changes
    updateDefaultCalculations.call(jq(this).closest('.cr').prev().find('td').first());
};

var adType;

var setupInsertionWidget = function(_adType){

    adType = _adType;

    jq('.saveBtn').click(function() {
        jq('body').focus();
        jq(applyNetSelector).find('input').change();

    });
    //Hide Effective Commmision
    jq(effCommSelector).hide();
    //Hide RecordTypes
    jq(createFieldSelector('RecordTypeId')).hide();

    var advertisementRecord = {};
    var AdPlanId = getUrlParameter('fpv');

    val = jq('.mainTable').find('.dr').first().find(recordTypeSelector).val();
    val = val ? val.toLowerCase() : adType;
    advertisementRecord.type = val;
    advertisementRecord.AdPlan__c = AdPlanId;

    if(adType == 'print' || 'television' || 'print') {
        jq('.gridBtnsCell').on( 'click', 'input.createNew', function(){
            setRecordType(adType);
            var newRow = jq('.mainTable tr.dr.nr:first');

            var buyTypeSelect = jq(buyTypeSelector, newRow).find('select');
            buyTypeSelect.val('Regular Buy');
            buyTypeSelect.change();

            if(spotTypeSelector){
                var spotTypeSelect = jq(spotTypeSelector, newRow).find('select');
                spotTypeSelect.val('30 secs');
                spotTypeSelect.change();
            }

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

            if(adType == 'print'){
                jq(applyNetSelector, newRow).find('input[type="checkbox"]').first().prop('checked',true);
            }

            jq('.mainTable').on('keyup',rateSelector,function(){
                updateDefaultCalculations.call(this);
            });
        });
    }


    var packageType;

    jq('.mainTable, .gridBtns').on('click', '.icon-arrow', function(e){
        var el = jq(this).parents().closest('tr');
        renderInsertionWidget(el);
    });

    //buytype change
    jq('.mainTable').on('change', 'select', function() {
        var el = jq(this).parents().closest('tr');
        renderInsertionWidget(el, true);
    });

    jq('.mainTable, .gridBtns').on('click', '.createNew', function(e){
        newRecords++;
        jq('tr.dr ' + numberOfSpotsSelector).prop('disabled', true);
    });

    insertionMetadata = getMetadataMapsForObject('Insertion');

    //get startdate selector
    var startDateSelector = createFieldInputSelector('StartDate__c');
    //get enddate selector
    var endDateSelector = createFieldInputSelector('EndDate__c');

    jq('.mainTable > tbody').on('change', ' > .dr > ' + startDateSelector + ',' + ' > .dr > ' + endDateSelector , function(e){

        renderInsertionWidget(jq(e.target).closest('.dr'), true);

    });

    jq('.mainTable > tbody').on('keyup', '.insertionMasterCount input', insertionMasterChange);
    jq('.mainTable > tbody').on('keyup', '.insertionInputContainer input', insertionChange);
    jq('.mainTable > tbody').on('click', '.insertionInputContainer input:checkbox', insertionChange);


    jq('tr.dr ' + numberOfSpotsSelector).prop('disabled', true);

}