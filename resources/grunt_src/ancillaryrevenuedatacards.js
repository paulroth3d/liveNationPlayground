var GBConditionalFields = (function(window, document, jq) {

    // Data Cards config #1
    // set how many primary fields there are in each object
    // the key is the object Id ( p, 1, 2, 3, 4) and the value is the number of primary fields you want to show on load
    var noOfFieldsToShow = {
        p: 4,
        1: 4
    };

    // Data Cards config #2
    // set how many fields you want to show in a row in a data card
    var elementsInARow = 4;

    // assumptions:
    // 1. required fields (fieldToShow) are set up as secondary fields
    // 2. condition fields (governingField) are primary fields
    // 3. condition field and required field are on the same object

    // Conditionally required fields use case #1
    // Make a field required when we change another field to a specific value. If we don't need this, declare as an empty object.
    var requiredFields = {
        //Opportunity: [
        //    {
        //        governingField: 'StageName',
        //        value: ['Closed Won', 'Closed Lost'],
        //        fieldToShow: ['Reason_Won_Lost__c']
        //    }
        //]
    };

    // Conditionally required fields use case #2
    // Make a field required when we when a validation rule is tripped. If we don't need this, declare as an empty object.
    var validatonRequiredFields = {
        //Opportunity: ['Lost_Reason__c']
    };

    /**
    *  DON'T CHANGE ANYTHING BELOW THIS LINE
    **/

    var secondaryFields = {};
    var numberOfrequiredForCreateFields = {};
    var requiredFieldsToHide = [];

    var cssRules = [
        {ruleName: '#gbMainTable .lastCol .showDataCard .ui-icon', ruleDef: 'background-image: url(images/ui-icons_888888_256x240.png);'},
        {ruleName: '#gbMainTable .dataCard .cardItem', ruleDef: 'width:' + (100 / elementsInARow) + '%;'},
        {ruleName: '#gbMainTable .dataCardCell .gbInfoIcon', ruleDef: 'background:transparent url("images/ic_info.png") no-repeat scroll 0 0; margin-left:4px; position:relative; top:2px; height:13px; width:13px; background-size:13px; display:inline-block; cursor:pointer;'}
    ];

    var mobileCssRules = [
        {ruleName: '#gbMainTable .lastCol .showDataCard',ruleDef: 'padding: 4px !important;zoom: 150%;'},
        {ruleName: '#gbMainTable .dataCard .cardItem',ruleDef: 'padding: 0 !important;'},
        {ruleName: 'body,html',ruleDef: 'width:100% !important; /* reset SFDC body widths */'},
        {ruleName: '#gbMainTable',ruleDef: 'width: 99%; margin-left: 1%;'},
        {ruleName: '#parentHeaderTable',ruleDef: 'margin-left: 1%; margin-top: 10px; margin-bottom: 10px; width: 99%;'},
        {ruleName: '#gbMainTable .cardItem nobr',ruleDef: 'display:inline-block; vertical-align:middle;'},
        {ruleName: '#gbMainTable .cardItem input[type="checkbox"]',ruleDef: 'vertical-align:top;'},
        {ruleName: '#gbMainTable .dataCard .cardItem label',ruleDef: 'width:200px !important; padding-left:3px; padding-bottom: 4px; display:block !important;'},
        {ruleName: '#gbMainTable .dataCard .cardTable',ruleDef: 'margin-bottom: 20px !important;'},
        {ruleName: '#gbMainTable .dataCard .conditionalFieldsHeader',ruleDef: 'height: 17px; margin-bottom: 9px !important'},
        {ruleName: '#gbMainTable .dataCard .conditionalFieldsHeader span',ruleDef: 'left: -124px !important;'}
    ];

    // count editable cols, we need to account for these on the parent when we expand the data card
    var noOfEditableRelCols = 0;
    for (var i = 1; i <= 4; i++) {
        if (gridInfoMap[i] == undefined) {
            break;
        }
        if(gridInfoMap[i].isConcatenatedView == true){
            noOfEditableRelCols++
        }
    }

    function init() {
    	debugger;

        var headerClass = '',
            sectionSelector = '';

        for(var k in gridInfoMap){
            for (var i=noOfFieldsToShow[k]; i < gridInfoMap[k].metaColumns.length; i++) {
                if(secondaryFields[k] == undefined){
                    secondaryFields[k] = [];
                }
                // don't add fields that are required on create. they should show up in the top col
                if(gridInfoMap[k].metaColumns[i].requiredForCreate == false){
                    secondaryFields[k].push(gridInfoMap[k].metaColumns[i].fieldId);
                }else{
                    if(numberOfrequiredForCreateFields[k] == undefined){
                        numberOfrequiredForCreateFields[k] = 1;
                    }else{
                        numberOfrequiredForCreateFields[k] ++;
                    }
                }
            }

            // hide secondary fields
            if(secondaryFields[k] != undefined && secondaryFields[k].length > 0){
                for (var j=0; j<secondaryFields[k].length; j++) {
                    if(k == 'p'){
                        headerClass = '.gradientHeader';
                        sectionSelector = mainTableJqueryId + ' > tbody >';
                    }else{
                        headerClass = '.childHeaderRow';
                        sectionSelector = '.childTable[name="c' + k + '"]';
                    }

                    jq(headerClass + ' td[name="' + secondaryFields[k][j] + '"]').remove(); // remove column headers to avoid them being copied to frozen header
                    jq(sectionSelector + ' .summaryRow td[name="' + secondaryFields[k][j] + '"]').remove(); // remove summary cells
                    jq(sectionSelector + ' .groupByRow td[name="' + secondaryFields[k][j] + '"]').remove(); // remove group by cells
                    cssRules.push({ruleName: sectionSelector + ' tr > td[name="' + secondaryFields[k][j] + '"]',ruleDef: 'display: none;'});
                }
                jq(sectionSelector + ' .dr .lastCol').append('<span class="showDataCard"><span class="ui-icon ui-icon-plusthick"></span></span>');
            }
        }

        jq(mainTableJqueryId).on('click', '.showDataCard', showDataCard);

        setupEvents(secondaryFields);
        addRulesToStyleSheet(cssRules);
        if(isInMobileView){
            addRulesToStyleSheet(mobileCssRules);
        }

        if(Object.keys(requiredFields).length > 0){
            initConditionalFields();
        }

        if(Object.keys(validatonRequiredFields).length > 0){
            initValidationConditionalFields();
        }

    }

    function initConditionalFields(){
        var gridInfo,
            fieldToWatch,
            requiredData;

        for(var k in requiredFields){
            gridInfo = GBGridInfoHelper.getGridInfoByFullObjectName(k);

            if(gridInfo == null){
                continue;
            }

            for (var i = 0; i < requiredFields[k].length; i++) {
                fieldToWatch = requiredFields[k][i].governingField;
                requiredData = requiredFields[k][i];
                watchForRequiredField(gridInfo, fieldToWatch, requiredData);
                requiredFieldsToHide = requiredFieldsToHide.concat(requiredData.fieldToShow);
            }
        }
    }

    // hide ValidationConditionalFields also
    function initValidationConditionalFields(){
        for(var k in validatonRequiredFields){
            requiredFieldsToHide = requiredFieldsToHide.concat(validatonRequiredFields[k]);
        }

        jq('body').on('click', '.saveBtn', removeOriginalValidationRequiredFields);

        // check if we need to parse validation error messages
        if(errorRecs.length > 0){
            handleValidationError();
        }

    }

    // before save, we have to remove the original ValidationRequiredFields from the grid, otherwise they'd trip our required validation
    function removeOriginalValidationRequiredFields(){
        var sectionSelector,
            gridInfo,
            metaCol;

        for(var k in validatonRequiredFields){
            gridInfo = GBGridInfoHelper.getGridInfoByFullObjectName(k);

            if(gridInfo == null){
                continue;
            }

            for(var i = 0; i < validatonRequiredFields[k].length; i++) {
                metaCol = getMetaColByFieldName(gridInfo, validatonRequiredFields[k][i]);
                sectionSelector = (gridInfo.gridId == 'p')?mainTableJqueryId + ' > tbody >':'.childTable[name="' + pGridInfo.objId + '"]';
                jq(sectionSelector + ' .dr td[name="'+metaCol.fieldId+'"]').remove();
            }

        }
    }

    function handleValidationError(){
        var element;

        for(var i = 0; i < errorRecs.length; i++) {
            jq('#'+errorRecs[i]+' > .lastCol .showDataCard').click(); // expand data card
            element = jq('#'+errorRecs[i]);

            // after the data card has been expanded
            setTimeout(function(element){
                var dataCard = element.next('.dataCard'),
                    gridInfo,
                    metaCol,
                    reqField,
                    reqInput;

                // show required header
                dataCard.find('.conditionalFieldsHeader').show();

                // show required field(s)
                for(var k in validatonRequiredFields){
                    gridInfo = GBGridInfoHelper.getGridInfoByFullObjectName(k);

                    for (var i = 0; i < validatonRequiredFields[k].length; i++) {
                        metaCol = getMetaColByFieldName(gridInfo, validatonRequiredFields[k][i]);
                        reqField = dataCard.find('.cardItem[name="'+metaCol.fieldId+'"]').show();
                        reqInput = reqField.find('select, input, textarea');
                        reqInput.after('<span class="gbInfoIcon tooltip"></span>');
                        reqField.find('.gbInfoIcon').tooltipster({content:'Please fill out required field'});

                        // add required styling
                        if(reqInput.val() == ''){
                            reqInput.addClass('gbrq').on('blur, change',function(){
                                var elem = jq(this);
                                if(elem.val() != ''){
                                    elem.removeClass('gbrq'); // remove required styling
                                }
                            });
                        }
                        blinkDataCard(reqField);
                    }
                }

            },0, element);
        }
    }

    // when the value changes to on a watched field, show the conditional fields if appropriate
    function watchForRequiredField(pGridInfo, pFieldToWatch, pRequiredData){
        var sectionSelector = (pGridInfo.gridId == 'p')?mainTableJqueryId + ' > tbody >':'.childTable[name="' + pGridInfo.objId + '"]';
        var metaCol = getMetaColByFieldName(pGridInfo, pFieldToWatch);

        jq('body').on('change',sectionSelector + ' .dr [name="'+metaCol.fieldId+'"]', function(){
            var changedField = jq(this);
            var value = changedField.find('select, input, textarea').val();
            var thisRow = changedField.closest('tr');

            if(pRequiredData.value.indexOf(value) != -1){
                // show required field
                if(!thisRow.hasClass('dataCardExpanded')){
                    thisRow.find('.showDataCard').click(); // expand data card
                }

                // after the data card has been expanded
                setTimeout(function(){
                    var dataCard = thisRow.next('.dataCard'),
                        metaCol,
                        reqField,
                        reqInput;

                    // show required header
                    dataCard.find('.conditionalFieldsHeader').show();

                    // show required field(s)
                    for (var i = 0; i < pRequiredData.fieldToShow.length; i++) {
                        metaCol = getMetaColByFieldName(pGridInfo, pRequiredData.fieldToShow[i]);
                        //reqField = dataCard.find('.cardItem[name="'+metaCol.fieldId+'"]').css('display','table-cell');
                        reqField = dataCard.find('.cardItem[name="'+metaCol.fieldId+'"]').show();
                        reqInput = reqField.find('select, input, textarea');

                        // add required styling
                        if(reqInput.val() == ''){
                            reqInput.addClass('gbrq').on('blur',function(){
                                var elem = jq(this);
                                if(elem.val() != ''){
                                    elem.removeClass('gbrq'); // remove required styling
                                }
                            });
                        }
                        blinkDataCard(reqField);
                    }

                },0);
            }else{
                // hide required field
                setTimeout(function(){
                    var dataCard = thisRow.next('.dataCard'),
                        metaCol,
                        reqField;

                    for (var i = 0; i < pRequiredData.fieldToShow.length; i++) {
                        metaCol = getMetaColByFieldName(pGridInfo, pRequiredData.fieldToShow[i]);
                        reqField = dataCard.find('.cardItem[name="'+metaCol.fieldId+'"]').hide();
                    }

                    // hide required header
                    if(dataCard.find('.hiddenRequiredTable .cardItem:visible').length == 0){
                        dataCard.find('.conditionalFieldsHeader').hide();
                    }

                },0);
            }

        });
    }

    function blinkDataCard(elem){
        elem.addClass('highlight');
        setTimeout(function(){
            elem.removeClass('highlight');
        },300);
    }

    function showDataCard(){
        var button = jq(this).find('.ui-icon'),
            thisRow = button.closest('tr'),
            dataCard = thisRow.next('.dataCard'),
            isInitialized = dataCard.length != 0,
            dataCardHtml,
            newDataCard,
            rowClasses = thisRow[0].className,
            gridInfo = getGridInfo(button),
            isNewRow = thisRow.hasClass('nr'),
            colspan = noOfFieldsToShow[gridInfo.gridId] + 1;

        if(isNewRow && numberOfrequiredForCreateFields[gridInfo.gridId] != undefined){
            // when it's a new row, we have to account for the not configured required fields
            colspan += numberOfrequiredForCreateFields[gridInfo.gridId];
        }

        if(gridInfo.gridId == 'p' && noOfEditableRelCols > 0){
            colspan += noOfEditableRelCols; // account for editable related cols on the parent
        }

        button.toggleClass('expanded');

        if(button.hasClass('expanded')){
            button.addClass('ui-icon-minusthick').removeClass('ui-icon-plusthick');
            thisRow.addClass('dataCardExpanded');
            dataCard.addClass('dataCardExpanded');

            // expand
            if(!isInitialized){
                // init and insert row
                dataCardHtml = getDataCardHtml(thisRow, gridInfo);
                thisRow.after('<tr id="'+thisRow.attr('id')+'" class="' + rowClasses + ' dataCard dataCardExpanded"><td class="firstCol"></td><td class="dataCardCell" colspan="'+ colspan +'">'+dataCardHtml+'</td></tr>')
                newDataCard = jq('#'+thisRow.attr('id')+'.dataCard');
                addAutocompleteToLookupFields(newDataCard, false);
                initTextAreas(newDataCard);
                initPicklists(newDataCard);
                newDataCard.addClass('highlightRow');

                newDataCard.find('input, textarea').css('width', ''); // remove enforced width from draggable resize columns
            }else{
                // already initialized, just show row
                dataCard.show();
            }

            correctColspan(thisRow.closest('tbody'), gridInfo.gridId);

            GBMixpanel.track('Show Data Card', {
                'Source': 'Button'
            });

        }else{
            button.addClass('ui-icon-plusthick').removeClass('ui-icon-minusthick');
            thisRow.removeClass('dataCardExpanded');
            dataCard.removeClass('dataCardExpanded');
            // collapse
            dataCard.hide();
        }
    }

    function getDataCardHtml(row, gridInfo){
        var htmlArr = ['<div class="cardTable">'],
            cell,
            fieldId,
            fieldData,
            isThereRequired = false,
            requiredHiddenHtmlArr = [],
            isRowOpen,
            rowFieldIndex = 0;

        for (var i=0; i<secondaryFields[gridInfo.gridId].length; i++) {
            fieldId = secondaryFields[gridInfo.gridId][i];
            fieldData = gridInfoMap[gridInfo.gridId].getMetaColByFieldId(fieldId);
            cell = row.find('td[name="'+fieldId+'"]');

            if(cell.length == 0){
                continue;
            }

            // if it's a required field, add it to the markup later
            if(requiredFieldsToHide.indexOf(fieldData.fieldName) != -1){
                isThereRequired = true;
                requiredHiddenHtmlArr.push('<div class="cardItem ' + cell[0].className + ' creq" name="'+fieldId+'">');
                requiredHiddenHtmlArr.push('<label>' + fieldData.fieldLabel + '</label>');
                requiredHiddenHtmlArr.push(cell.html());
                requiredHiddenHtmlArr.push('</div>');

            }else{
                if(rowFieldIndex%elementsInARow == 0){
                    htmlArr.push('<div class="cardRow">'); // start cardRow div
                    isRowOpen = true;
                }

                htmlArr.push('<div class="cardItem ' + cell[0].className + '" name="'+fieldId+'">');
                htmlArr.push('<label>' + fieldData.fieldLabel + '</label>');
                htmlArr.push(cell.html());
                htmlArr.push('</div>');

                if(rowFieldIndex%elementsInARow == elementsInARow-1){
                    htmlArr.push('</div>'); // close cardRow div after every 5th card or at the end
                    isRowOpen = false;
                }
                rowFieldIndex++;
            }
        }

        if(isRowOpen == true){
            htmlArr.push('</div>'); // close cardRow div
        }
        htmlArr.push('</div>'); // close cardTable

        // if there's a required hidden field, add it in a separate row at the bottom of the data card
        if(isThereRequired){
            htmlArr.push('<div class="conditionalFieldsHeader"><span>Required Fields</span></div>'); // open row
            htmlArr.push('<div class="cardTable hiddenRequiredTable"><div class="cardRow ">'); // open row
            htmlArr = htmlArr.concat(requiredHiddenHtmlArr);
            htmlArr.push('</div>'); // close cardRow div
            htmlArr.push('</div>'); // close cardTable
        }

        return htmlArr.join('');
    }

    function setupEvents(){

        jq(mainTableJqueryId).on('change', 'input.rtf', function(e) {
            GBRowHelper.updateRecordTypePicklists(jq(this).closest('td'), false);
        });

    }

    function handleNewRow(newRow){
        // find new row
        var childTable = newRow.closest('.childTable'),
            id = '';

        if(childTable.length == 0){
            // it's the parent object
            id = 'p';
        }else{
            id = childTable.attr('name').charAt(1);
        }

        correctColspan(newRow.closest('tbody'), id);

        // append expand button if we need to
        if(secondaryFields[id] != undefined && secondaryFields[id].length > 0){
            newRow.find('.lastCol').append('<span class="showDataCard"><span class="ui-icon ui-icon-plusthick"></span></span>');
        }

    }

    // make sure dataCard colspans are still accurate due to not configured required fields
    function correctColspan(section, gridId){
        var newRows = section.find('>tr.nr');

        if(numberOfrequiredForCreateFields[gridId] != undefined){
            if(newRows.length != 0){
                // if there’s a new row in the section and if there are hidden required columns
                var numberOfCols = newRows.first().find('td:visible').length;
                section.find('>tr.dataCard .dataCardCell').attr('colspan', numberOfCols-1)
            }
        }
    }

    function initTextAreas(dataCard){
        var originalRow = dataCard.prev('.dr');

        // we have to copy the values from the textareas in the dataCard to their hidden counterparts. This is because they're saved in a specific way
        jq(mainTableJqueryId).on('blur', '#'+dataCard.attr('id')+'.dataCard textarea', function(e) {
            originalRow.find('td[name="'+jq(this).closest('.cardItem').attr('name')+'"] textarea').val(jq(this).val());
        });

    }

    function initPicklists(dataCard){
        dataCard.find('.cardItem.pl').each(function(item){
            setupPicklistBehavior(null, jq(this), false);
        });
    }

    return {
        init: init,
        handleNewRow: handleNewRow
    }

})(window, document, jq); // end GBConditionalFields

jq(document).ready(function() {GBConditionalFields.init()});








/**
**  OVERRIDES
**/

// override getMetaCol function to accommodate data cards
function getMetaCol(pJqueryElem, pGridInfo) {
    var cellName = pJqueryElem.parents('td').attr('name');
    if(cellName == undefined){
        cellName = pJqueryElem.closest('.cardItem').attr('name');
    }
    var metaCol = getMetaColByCellName(cellName, pGridInfo);
    return metaCol;
}

// override updateModifiedDataMap function to accommodate data cards
function updateModifiedDataMap(pJqueryElem, pGridInfo) {
    // the value of this element changed
    // get the element's row id and put it in the modified map
    var dataRow = pJqueryElem.parents('tr'),
        rowId = dataRow.attr('id'),
        isNewData = dataRow.hasClass('nr'),
        dataMap = (isNewData ? newData : modData),
        rowData = dataMap[rowId],
        metaCol = getMetaCol(pJqueryElem, pGridInfo),
        cellId = metaCol.fieldId,
        inputVal;

    // only proceed if rowData is empty or has exaclty one property: 'cl'. This happens when cloning a record
    if (rowData == null || (Object.keys(rowData).length == 1 && rowData.cl)) {
        dataMap[rowId] = dataMap[rowId] ? dataMap[rowId] : new Object();
        rowData = dataMap[rowId];
        // set the object name
        rowData['nm'] = pGridInfo.fullyQualifiedObjectName;

        if (isNewData) {
            newDataSize++;

            if (pGridInfo.objId != 'p') {
                // this is a child row, get the parent row's id
                var childContainerRow = dataRow.parents('tr.cr'),
                // looking for parent row which is a row adjacent to the child container row
                    prevRow = childContainerRow.prev(),
                    parentRowId;

                if (childContainerRow.length == 1) {
                    var ctr = 0;

                    // FIXME use the row name to find the parent
                    while (prevRow.hasClass('cr')) {
                        prevRow = prevRow.prev();
                        ctr++;

                        // safety exit
                        if (ctr > 4) {
                            break;
                        }
                    }

                    if (prevRow.hasClass('dr')) {
                        parentRowId = prevRow.attr('id');
                        if (GBUnrelated.isChildUnrelated(pGridInfo)) {
                            parentRowId = GBUnrelated.getParentIdentifierForChildData(pGridInfo,
                                parentRowId,
                                prevRow);
                        }
                        rowData['pId'] = parentRowId;
                    }
                }else{
                    parentRowId = dataRow.closest('#relatedColumnWidget').attr('data-parent-id');
                    rowData['pId'] = parentRowId;
                }
            }
        } else {
            modDataSize++;
        }
    }

    if (pGridInfo.objId == 'p' && GBUnrelated.fieldIsCrossRefForeignKey(metaCol.fieldName)) {
        // the field updated is for the parent object, and it is a cross ref FK field
        GBUnrelated.updateUnrelatedChildData(dataRow, metaCol.fieldName);
    }

    if (pJqueryElem.is(':checkbox')) {
        // make sure boolean is in string format for json object
        inputVal = (pJqueryElem.is(':checked') == true)+"";

    } else {
        // scrub value
        inputVal = scrubFieldValue(pJqueryElem, pGridInfo, isNewData);

        // if it's a lookup for whoId add the whoId object name to the map
        if (metaCol.isWhoIdField()) {
            var whoIdObjectName = pJqueryElem.parents('div.ui-widget').find('select.wId').val();
            rowData['whoId'] = whoIdObjectName;
        } else if (metaCol.isWhoOrWhatIdField()) {
            var whatIdObjectName = pJqueryElem.parents('div.ui-widget').find('select.wId').val();
            rowData['whatId'] = whatIdObjectName;
        }
    }

    if (inputVal == null) {
        inputVal = '';
    }

    // for new records only, if there's an empty value it means the user entered a value to begin with and then removed it
    // instead of setting the value on the sobject to empty, remove it from the map so the default value gets applied on create
    // ISSUE WITH RECORD TYPE - can't be empty on create, can't remove on edit
    if (isNewData==true && inputVal == '' && metaCol.defaultedOnCreate==true) {
        delete rowData[cellId];
    } else {
        rowData[cellId] = inputVal;
    }
}

function setupHighlightForMouseoverAction() {
    // highlight a data record (highlighting was removed
    // from the mass update widget because of an issue in IE9)
    var rowSelector = mainTableJqueryId+' tr.dr:not(.nd)';

    jq('div.gbPage').on('mouseover', rowSelector, function() {
        jq('tr[id="' + jq(this).attr('id') + '"]').addClass('highlightRow');
    });

    jq('div.gbPage').on('mouseleave', rowSelector, function() {
        jq('tr[id="' + jq(this).attr('id') + '"]').removeClass('highlightRow');
    });
}

// remember fields and data the user changed
function registerValueChange(e, jQueryElem, isMassUpdate, excludePicklistValidation, excludeUnrelatedUpdates, skipFlatView) {
    var gridInfo = getGridInfo(jQueryElem),
        metaCol = getMetaCol(jQueryElem, gridInfo),
        isNewRow = jQueryElem.parents('tr.dr:first').hasClass('nr'),
        isUnrelatedRow = jQueryElem.closest('tr').hasClass('ur'),
        dependentInfo = dependentPickListInfo[metaCol.fieldName],
        isFlatViewUpdate = (jq('#relatedColumnWidget:visible').length > 0) && !skipFlatView;

    // make parameters default
    excludeUnrelatedUpdates = excludeUnrelatedUpdates || false;

    updateModifiedDataMap(jQueryElem, gridInfo);
    validateField(jQueryElem, gridInfo, isNewRow);

    if (isNewRow==false) {
        var dataCell = jQueryElem.parents('td:first');

        if(dataCell.hasClass('dataCardCell')){
            dataCell = jQueryElem.closest('.cardItem');
        }

        if (dataCell.hasClass('mod')==false) {
            dataCell.addClass('mod');
        }
    }

    //on mass update don't override the values that were selected in the mass update widget
    if(dependentInfo && (!isMassUpdate || (isMassUpdate && jQueryElem.val() == ""))){
        updateDependentPickLists(jQueryElem, dependentInfo, metaCol, gridInfo);
    }

    // validate after the dependent field logic in case any of the dependent fields are required
    validateRemainingRequiredRowFields(jQueryElem, gridInfo, isNewRow, excludePicklistValidation);

    // if child record is unrelated, update all duplicates
    if (isUnrelatedRow && !excludeUnrelatedUpdates) {
        GBRowHelper.updateRecords(e, jQueryElem, gridInfo, metaCol, true);
    }

    // if the flat view related records widget is open, update between the widget and the related section
    if(isFlatViewUpdate){
        GBRowHelper.updateRecords(e, jQueryElem, gridInfo, metaCol, false);
    }

    // update the summary value if this field has one
    if (metaCol.summaryType && metaCol.summaryType != '') {
        GBSummary.updateSummaryValue(jQueryElem);
    }

    // update chart
    if (GBHelpers.isChartValid()) {
        GBCharts.gridChart.updateChart(modData, newData);
    }

    // update the color code
    GBColorCode.updateColor(jQueryElem, metaCol, gridInfo);

}

/**
 * Adds the given css rules to the gb-jq style sheet.
 * @param pNewRules an array of objects, example:
 * 		  [{ruleName: 'table.mainTable > tbody > tr > td[name="v3"]',
 *			ruleDef: 'min-width: 750px;'},
 * 		   {ruleName: 'table.mainTable > tbody > tr > td[name="v3"] input',
 *			ruleDef: 'width: 740px;'},
 * 		   {ruleName: 'table.childTable[name="c2"] tr td[name="v4"] textarea',
 * 			ruleDef: 'width: 590px;'},
 * 		   ...]
 */
function addRulesToStyleSheet(pNewRules) {
    var gbStyleSheet,
        ruleName,
        ruleDef;

    for (var y=0; y < document.styleSheets.length; y++) {
        if (document.styleSheets[y].href && document.styleSheets[y].href.indexOf('gb-jq') > 0) {
            gbStyleSheet = document.styleSheets[y];
            break;
        }
    }

    if(!gbStyleSheet){
        return;
    }

    // loop through the new rules and add them to the style sheet
    for (var k=0; k < pNewRules.length; k++) {
        ruleName = pNewRules[k].ruleName;
        ruleDef = pNewRules[k].ruleDef;

        if (gbStyleSheet.addRule) {
            // IE
            gbStyleSheet.addRule(ruleName, ruleDef, 0);
        } else {
            // others
            gbStyleSheet.insertRule(ruleName+' { '+ruleDef+' }', 0);
        }
    }
}

GBColorCode.updateColor = function(element, metaCol, gridInfo){
    var colorCodeValue,
        isColored = false,
        value,
        cell = element.closest('.cardItem'),
        objectDotFieldName = '',
        fullyQualifiedObjectNameParts = gridInfo.fullyQualifiedObjectName.split(':'),
        valueProps;

    if(cell.length == 0){
        cell = element.closest('td');
    }

    if(fullyQualifiedObjectNameParts.length == 1){
        objectDotFieldName = gridInfo.fullyQualifiedObjectName + ':' + metaCol.fieldName; // if it's a parent object
    }else{
        objectDotFieldName = fullyQualifiedObjectNameParts[0] + ':' + metaCol.fieldName + ':' + fullyQualifiedObjectNameParts[1]; // if it's a related object
    }

    // find the applicable rules based on the objectDotFieldName
    // parent field example: "Account:Industry"
    // related field example: "Opportunity:Amount:AccountId"
    // unrelated field example: "Opportunity:Amount:unrelated"
    // junction parent field example: "Asset:Quantity:unrelated-AssetId-Case"
    var applicableRules = colorCodingRulesJson.filter(function(obj) {
        if (obj.governingField == objectDotFieldName) {
            // related object or parent
            return true;
        }else if(obj.governingField.split(':').length == 3 && // governing field is syntactically correct
            obj.governingField.split(':')[2].indexOf('unrelated') != -1 && // last token (relation) of governingField contains "unrelated"
            objectDotFieldName.split(':')[0].indexOf(obj.governingField.split(':')[0]) != -1 && // first token (object) of objectDotFieldName containts the first token of governingField. If it's truly unrelated, they'll be the same. If it's junction parent, one will just contain part of the other
            obj.governingField.split(':')[1] == objectDotFieldName.split(':')[1]){ // second token (field) of governingField and objectDotFieldName are the same
            // unrelated object: last element of governing field should be 'unrelated' and the first and second element of the objectDotFieldnames should match
            return true;
        }
    });

    for (var i = 0; i < applicableRules.length; i++) {
        // convert color code value from string to something that we can compare
        colorCodeValue = this.convertValue(applicableRules[i].value, metaCol.colDataType, applicableRules[i].value);

        // update color coding on change
        //value = (cell.hasClass('pl') && !cell.hasClass('plOn')) ? cell.find('.plTxt').text() : cell.find('input, select').val();
        valueProps = this.getCleanValue(cell, metaCol.colDataType);
        value = valueProps['cleanValue'];

        if (!value && metaCol.isNumeric()) {
            // reset/don't highlight this field, it's numeric but the value is blank
            // blank numeric values should not be treated like 0 values
            isColored = false;

        } else {
            // convert value from string to something that we can compare
            value = this.convertValue(value, metaCol.colDataType, applicableRules[i].value);

            isColored = this.evaluateValueForColorCode(applicableRules[i].operator, value, colorCodeValue, metaCol.colDataType);
        }

        this.applyColor(cell, applicableRules[i], isColored);
    }
};

function insertNewRow(pDataTable, originalRow) {
    var htmlArr = [],
        gridInfo = getGridInfoByName(pDataTable.attr('name')),
        metaCols = gridInfo.metaColumns,
        firstDataRow = getFirstDataRow(pDataTable),
        firstRowId = (firstDataRow==null || firstDataRow.length==0 ? '' : firstDataRow.attr('id')) || '',
        isParentTable = pDataTable.hasClass('mainTable')==true,
        headerRow = (isParentTable ? pDataTable.find('tr.gradientHeader') : pDataTable.find('tr.childHeaderRow')),
        newCellValue = '',
        metaCol,
        newRow,
        cellClass,
        cellClasses,
        cellProps,
        requiredCols = [], // could contain hidden, required columns and/or required for create columns
        firstDataRowExists = (firstRowId.length == 0 || isNaN(firstRowId)==true);

    // make sure the data table is displayed
    showGridTable(pDataTable);

    if (firstDataRowExists) {
        // this is the first new record for this table
        // add the new required field columns to the header and adjust the columns for the rest of the rows

        if (firstDataRow.hasClass('nd')) {
            // no data found row
            firstDataRow.addClass('none');
        }

        var colHtml = '',
            newColsAdded = 0;

        // show required columns in new rows only if it's not a clone. if it's a clone, we'll take care of it on the back-end
        if (!originalRow) {
            for (var i=0, len=gridInfo.metaColumns.length; i < len; i++) {
                metaCol = gridInfo.metaColumns[i];
                if (metaCol.requiredForCreate == true || metaCol.showHiddenColumnOnCreate(gridInfo)) {
                    // insert the new columns before the last column
                    headerRow.find('td.lastCol').before('<td class="nc">'+metaCol.fieldLabelForDisplay()+'</td>');

                    // add new column to the summary row if applicable
                    headerRow.first().next('.summaryRow').find('td.lastCol').before('<td class="nc"></td>');

                    if (isParentTable) {
                        // add new column to each group by header row
                        jq('.groupByRow').find('td.lastCol').before('<td class="nc"></td>');
                    }

                    newColsAdded++;
                }
            }
        }

        // if there's no select (checkbox) column, add an empty column for the minus button for new records
        // TODO this check may no longer be necessary, since the checkbox column should always be displayed now, confirm
        if (headerRow.find('input.selectAllChk').length == 0) {
            headerRow.find('td:first').before('<td class="minusCol nc">&nbsp;</td>');
            pDataTable.children('tbody').children('tr.dr').children('td:first-child').before('<td class="nc">&nbsp;</td>');
            newColsAdded++;
        }

        // readjust all the data rows in this table
        if (newColsAdded > 0) {
            // set the new colspan on the last column based on how many required columns are added for the new row
            pDataTable.children('tbody').children('tr.dr:not(.nr)').find('td.lastCol').attr('colspan', newColsAdded+1).addClass('bl');

            // readjust the data rows in child tables
            if (isParentTable) {
                var allChildObjectSections = jq('td.crDataContainer');
                if (allChildObjectSections.length > 0) {
                    var origColspan = allChildObjectSections.first().attr('colspan') * 1;
                    allChildObjectSections.attr('colspan', origColspan + newColsAdded);
                }
            }
        }
    }

    // use the current new row id
    htmlArr.push('<tr id="'+currentNewRowId+'" name="r'+currentNewRowId+'" class="dr nr">');

    // decrement the row id
    currentNewRowId--;

    // first column is for the delete icon
    htmlArr.push('<td class="chk firstCol"><span class="minus">&nbsp;</span></td>');

    for (var c=0, len=metaCols.length; c < len; c++) {
        metaCol = metaCols[c];
        if (!metaCol.isHidden && !metaCol.requiredForCreate) {
            _buildRowDataCells(metaCol);
        } else if (metaCol.showHiddenColumnOnCreate(gridInfo) || (metaCol.requiredForCreate && !originalRow)) {
            // only require the metaCol if it's not a clone
            requiredCols.push(metaCol);
        }
    }

    // insert an empty cell before the required columns if this is a new parent row and a concatenated view child is on the grid
    htmlArr.push(GBRowHelper.getFlatViewColDataHtml(gridInfo, null));

    for (var d=0, len=requiredCols.length; d<len; d++) {
        metaCol = requiredCols[d];
        _buildRowDataCells(metaCol);
    }

    function _buildRowDataCells(metaCol) {
        cellProps = getCellProperties(metaCol, newCellValue, null, gridInfo, false);
        cellClasses = getCellClassForContent(metaCol, newCellValue, cellProps.readOnly);
        cellClass = (cellClasses.length > 0 ? 'class="'+cellClasses+'"' : '');
        htmlArr.push('<td name="'+metaCol.fieldId+'" '+cellClass+'>'+cellProps.cellHtml+'</td>');
    }

    htmlArr.push(
        GBRowHelper.getLastColHtml(gridInfo, true)
        + '</tr>'
    );

    // insert row
    if(originalRow){
        if(originalRow.next('.cr').length > 0){
            // user is cloning a parent row on a multi-object grid
            // if the record has one or more child record section as adjecent following siblings,
            // find the last child section tr and insert the cloned record after it
            newRow = jq(htmlArr.join('')).insertAfter(originalRow.nextUntil(':not(.cr)').last());
        }else{
            // user is cloning a child row or any record on a single object grid
            newRow = jq(htmlArr.join('')).insertAfter(originalRow);
        }

    }else{
        // user is creating a new record
        newRow = jq(htmlArr.join('')).insertBefore(firstDataRow);
    }

    // set all the element events
    setEventsForNewRow(newRow);

    // if this is a parent row show the new child object sections
    if (isParentTable) {
        GBActions.addNewRelatedObjects(newRow);
    }

    /* TODO when mass updates are supported for new records
     // display the extra required columns for this object
     toggleRequiredFieldsForCreatesInMassUpdatesWidget(gridInfo, true);
     */

    if (firstDataRowExists) {
        // init summary row if applicable when creating the first new row, but only after we added the first data row
        GBSummary.initSummaryRow();
    }

    // reinitialize draggable resize columns on the new row if they've been already initialized
    GBDraggableResizeColumns.reinitOnNewRow();

    GBConditionalFields.handleNewRow(newRow);

    return newRow; // clone uses the returned newRow object
}