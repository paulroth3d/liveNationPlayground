//-- your info goes here:promotionsgrid
//-- to deploy run: grunt deployGridBuddyResource:promotionsgrid
Number.prototype.formatMoney = function(c, d, t){
    var n = this,
        c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))),
        j = (j = i.length) > 3 ? j % 3 : 0;
    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
};

var parseNumber = function(v){
    if(!v)return 0;
    return Number(v.replace(/[,\/#!$%\^&\*;:{}=\-_`~()]/g,""));
}

window.onerror = function( errMsg, url, lineNumber ){
    console.log( 'uncaught javascript exception found' );
    console.log(errMsg);
    return( false );
}

var promoTotalTicketValueSelector, promoPromoScaleMetadata, ppsPromoScaleInputSelector, ppsPromoScaleSelector, ppsNameSelector, ppsPriceInputSelector, ppsPriceSelector, ppsNumTicketsSelector, ppsTicketValueInputSelector, newRecords = 0;
var updateQueue = {}, updateStack = [];
var adPlan, ticketScales, promoScales, ticketScaleMap = {};
var newIdTracker = 0;

var updatePScale = function(promoScale){

    clearTimeout(updateQueue[promoScale.Id]);

    updateQueue[promoScale.Id] = setTimeout(function(){

        delete updateQueue[promoScale.Id];

        if(promoScale.Id<0){
            delete promoScale.Id;
        }else{
            delete promoScale.attributes;
        }
        updateStack.push(promoScale);

        //console.log('sending save request for promo scale');
        //console.log(promoScale);

        var request = new LNE_PostMessage( 'Grid','promoScaleUpdate',true,{promoScale:promoScale});
        request.dispatch(parent);

    }, 2000);
};

var renderPScaleTable = function(){

    var tBody = jq('#pScaleTable tbody');

    jq(tBody).empty();

    var selectedTicketScales = [];

    //build a list of ticket scales which have already been selected
    jq(promoScales).each(function(i, promoScale){
        if(promoScale.TicketScale__c){
            selectedTicketScales.push(promoScale.TicketScale__c);
        }
    });


    jq(promoScales).each(function(i, promoScale){

        //do not render promo scales that were created for ticket scales that are not visible
        if(promoScale.TicketScale__c && !ticketScaleMap.hasOwnProperty(promoScale.TicketScale__c))return;

        var row = jq('<tr></tr>');
        var cell, input;
        
        //ticket scale column
        cell = jq('<td></td>');
        input = jq('<select class="ticketScale"></select>');
        
        var ticketScaleSelected = false;
        var selectOption = jq('<option>-- Select Ticket Scale --</option>');
        var option, selectedTicketScale;

        jq(input).append(selectOption);

        jq(ticketScales).each(function(i, ticketScale){

            //do not allow selected ticket scales to be selected again for new promo scales
            if(selectedTicketScales.includes(ticketScale.Id) && ticketScale.Id != promoScale.TicketScale__c)return;

            option = jq('<option value="' + ticketScale.Id + '">' + ticketScale.PriceLevel__c + '</option>');

            if(ticketScale.Id == promoScale.TicketScale__c){
                jq(option).attr('selected', true);
                selectedTicketScale = ticketScale;
            }

            jq(input).append(option);
        });

        var otherOption = jq('<option value="Other">Other</option>');

        jq(input).append(otherOption);

        if(promoScale.Name == "Other"){
            //this is a promo scale that has the "other" ticket scale
            jq(otherOption).attr('selected', true);
        }else if(!selectedTicketScale){
            jq(selectOption).attr('selected', true);
        }

        jq(cell).append(input);

        jq(row).append(cell);
        
        //description column
        cell = jq('<td></td>');
        input = jq('<input class="description" type="text"/>');
        jq(input).val(promoScale.Description__c || (selectedTicketScale ? selectedTicketScale.Notes__c : ''));
        jq(input).attr('disabled', jq(selectOption).attr('selected'));
        jq(cell).append(input);
        jq(row).append(cell);

        //price column
        cell = jq('<td></td>');
        input = jq('<input class="price" type="number"/>');
        jq(input).val(promoScale.Price__c || (selectedTicketScale ? selectedTicketScale.Price__c : ''));
        jq(input).attr('disabled', !jq(otherOption).attr('selected'));
        jq(cell).append(input);
        jq(row).append(cell);

        jq(tBody).append(row);

        jq(row).prop('model', promoScale);

    });

    //1 is empty, so...
    if(promoScales.length>1)renderPromoPromoScales();

};

var renderPromoPromoScales = function(){
    //list promo scales under each record in promotions grid
    jq('.mainTable .dr:not(.pnd)').each(function(i, e){
        renderPromoPromoScalesForRow(e);
    });
}

var renderPromoPromoScalesForRow = function(e){
    var childRow = jq(e).next('.cr');
    var childDataContainer = jq('.childDataContainer', childRow);

    //ticket scale, description, price, # of Tickets, Ticket Value
    var promoPromoScaleTable = jq('.promoPromoScaleTable', childDataContainer), promoPromoScaleRow, promoPromoScaleCell;

    if(promoPromoScaleTable.length==0){
        promoPromoScaleTable = jq('<table border="0" cellpadding="0" cellspacing="0" class="promoPromoScaleTable"><thead><tr><th>Ticket Scale</th><th>Description</th><th>Price</th> <th># of Tickets</th><th>Ticket Value</th></tr></thead><tbody></tbody></table>');
        childDataContainer.append(promoPromoScaleTable);
    }

    jq('tbody',promoPromoScaleTable).empty();

    //get list of promoPromoScale rows
    var oRows = jq('.childTable .dr', childRow);

    //index promoPromoScaleRows by promoScale id
    var oRowMap = {}, keyElement, key;

    jq(oRows).each(function(i, e){

        if(jq(e).is('.nr')){
            //new row
            keyElement = jq(ppsPromoScaleInputSelector, e);
        }else{
            //persisted row
            keyElement = jq(ppsPromoScaleSelector + ' .gbRf', e);
        }

        key = jq(keyElement).attr('name');
        oRowMap[key] = e;
    });

    var oRow, description, price, numTickets, ticketValue, calculatedTicketValue;

    jq(promoScales).each(function(i, promoScale){

        //don't render the empty/new promoScale
        if(!promoScale.Name)return;

        oRow = oRowMap[promoScale.Id];

        description = promoScale.Description__c;
        price = promoScale.Price__c;

        if(oRow){
            numTickets = parseNumber(jq(ppsNumTicketsSelector, oRow).val());
            ticketValue = parseNumber(jq(ppsTicketValueInputSelector, oRow).val());
            calculatedTicketValue = numTickets * price;
        }else{
            numTickets = 0;
            ticketValue = 0;
            calculatedTicketValue = 0;
        }

        promoPromoScaleRow = jq('<tr>'
            + '<td>' + promoScale.Name + '</td>'
            + '<td class="description"><input type="text" value="' + (description||'') + '" disabled/></td>'
            + '<td class="price"><input type="number" value="' + (price||0) + '" disabled/></td>'
            + '<td class="numTickets"><input type="number" value="' + (numTickets) + '"/></td>'
            + '<td class="ticketValue">USD <input type="number" value="' + (calculatedTicketValue) + '" disabled/></td>'
            + '</tr>');

        jq('tbody', promoPromoScaleTable).append(promoPromoScaleRow);

        promoPromoScaleRow.prop('promoScale', promoScale);

        if(oRow)promoPromoScaleRow.prop('oRow', oRow);

        if(calculatedTicketValue!=ticketValue && oRow){
            jq(ppsTicketValueInputSelector, oRow).change();
        }
    });
}

var ticketScaleChange = function(e){

    var value = jq(e.target).val();
    var label = jq('option:selected', e.target).text().trim();
    var row = jq(e.target).closest('tr');
    var model = jq(row).prop('model');
    var id = model.Id;

    if(id<0)promoScales.push({AdPlan__c:adPlan.Id, Id:getNewId()});

    if(value!="Other"){
        model.TicketScale__c = value;
        model.Description__c = ticketScaleMap[value].Notes__c||ticketScaleMap[value].PriceLevel__c;
        model.Price__c = ticketScaleMap[value].Price__c;
    }

    model.Name = label;

    renderPScaleTable();

    updatePScale(model);

};

var descriptionChange = function(e){
    var value = jq(e.target).val();
    var row = jq(e.target).closest('tr');
    var model = jq(row).prop('model');
    model.Description__c = value;
    renderPromoPromoScales(true);
    updatePScale(model);
};


var priceChange = function(e){
    var value = jq(e.target).val();
    var row = jq(e.target).closest('tr');
    var model = jq(row).prop('model');
    model.Price__c = value;
    renderPromoPromoScales();
    updatePScale(model);
};

var calculateTicketValue = function(row){
    var tv = (jq('.price input', row).val()||0) * (jq('.numTickets input', row).val()||0);
    var formatted = tv.formatMoney(2, '.', '');
    var oRow = jq(row).prop('oRow');
    jq('.ticketValue input', row).val(formatted);
    jq(ppsTicketValueInputSelector, oRow).val(formatted);
    jq(ppsTicketValueInputSelector, oRow).change();


    //loop through all rows and total ticket values
    var promoTotal = 0, gridTotal = 0;

    jq('tbody tr', jq(row).closest('.promoPromoScaleTable')).each(function(i, e){
        promoTotal += Number(jq('.ticketValue input', e).val());
    });

    //get parent
    var parentRow = jq(row).closest('.cr').prev('.dr')
    jq(promoTotalTicketValueSelector, parentRow).text('USD ' + promoTotal.formatMoney());


    jq('#gbMainTable .dr:not(.nd)').each(function(i, e){
        gridTotal+= parseNumber(jq(promoTotalTicketValueSelector,e).text().substr(4));
    });


    jq(promoTotalTicketValueSelector, jq('#gbMainTable .summaryRow')).html('<div>SUM</div>USD ' + gridTotal.formatMoney());

};

this.postOffice = new LNE_MessagePostOffice(this);

var getNewId = function(){
    return --newIdTracker;
}

this.postOffice.addTypeHandler( "initPromotionsGrid", function(postMessage){
    //console.log('initPromotionsGrid!!!');

    //console.log('adPlan = ');
    //console.log( postMessage.data.adPlan);
    adPlan = postMessage.data.adPlan;


    //console.log('ticketScales = ');
    //console.log( postMessage.data.ticketScales);
    ticketScales = postMessage.data.ticketScales;

    //console.log('promoScales = ');
    //console.log( postMessage.data.promoScales);
    promoScales = postMessage.data.promoScales;

    promoScales.push({AdPlan__c:adPlan.Id, Id:getNewId()});

    jq(ticketScales).each(function(i, ticketScale){
        ticketScaleMap[ticketScale.Id] = ticketScale;
    });

    renderPScaleTable();
});


this.postOffice.addTypeHandler( "savePromoScaleResponse", function(postMessage){
    //console.log('savePromoScaleResponse');
    //console.log(postMessage);
    var promoScale = updateStack.pop();
    if(!promoScale.Id){
        promoScale.Id = postMessage.data.promoScale.Id;
    }

});

this.postOffice.listenForPostEvents(window);



jq(document).ready(function(e){

    //create table for pscales
    var pScaleTable = jq('<h2 class="gridTitle pScaleHeader">Promotion Scales<a class="toggle">show</a></h2><table border="0" cellpadding="0" cellspacing="0" id="pScaleTable"><thead><tr><th>Ticket Scale</th><th>Description</th><th>Price</th></tr></thead><tbody></tbody></table>');
    jq(document.body).prepend(pScaleTable);

    var newPScaleRow = jq('<tr><td></td><td></td><td></td></tr>');

    var request = new LNE_PostMessage( 'Grid','promoGridReady',true,{});
    request.dispatch(parent);

    jq('#pScaleTable tbody').on('change', '.ticketScale', ticketScaleChange);
    jq('#pScaleTable tbody').on('keyup', '.description', descriptionChange);
    jq('#pScaleTable tbody').on('keyup', '.price', priceChange);

    jq('.gridBtns').on('click', '.createNew', function(e){
        renderPromoPromoScalesForRow(jq('.mainTable > tbody > tr.dr.nr ')[0]);
    });

    jq('.mainTable, .gridBtns').on('click', '.createNew', function(e){
        newRecords++;
    });

    jq('.gridTitle .toggle').click(function(e){
        var state = jq(e.target).text();
        if(state == 'show'){
            jq('#pScaleTable').show();
            jq(e.target).text('hide');
        }else{
            jq('#pScaleTable').hide();
            jq(e.target).text('show');
        }
    });

    jq('#gbMainTable').on('keyup', '.promoPromoScaleTable input', function(e){
        //get row for target input
        var row = jq(e.target).closest('tr');

        //get gb row for this row
        var oRow = row.prop('oRow');
        var promoScale = jq(row).prop('promoScale');

        //if no gb row
        if(!oRow){
            //create new row in gb child grid
            var container = jq(e.target).closest('.branch');
            jq('.createNew:first', container).click();

            //set property oRow on this row to newly created gb row
            oRow = jq('#' + (-1*newRecords), container);
            row.prop('oRow', oRow);

            //set promoScale value on oRow by setting name value on promoScale lookup input
            var promoScaleInput = jq(ppsPromoScaleInputSelector, oRow);
            promoScaleInput.attr('name', promoScale.Id);
            promoScaleInput.val(promoScale.Name);

            //invoke change event on promoScale lookup field in gb row
            promoScaleInput.change();

            //add values for name and price too
            var nameInput = jq(ppsNameSelector, oRow);
            nameInput.val(promoScale.Description__c);
            nameInput.change();

            var priceInput = jq(ppsPriceInputSelector, oRow);
            priceInput.val(promoScale.Price__c);
            priceInput.change();
        }

        //set value for corresponding field in gb row
        var className = jq(e.target).closest('td').prop('className');
        var targetFieldSelector;
        var targetInput;

        switch(className){
            case 'description': targetFieldSelector = ppsNameSelector; break;
            case 'price': targetFieldSelector = ppsPriceInputSelector; calculateTicketValue(row);break;
            case 'numTickets': targetFieldSelector = ppsNumTicketsSelector; calculateTicketValue(row);break;
        }

        targetInput = jq(targetFieldSelector, oRow);
        targetInput.val(jq(e.target).val());

        //invoke change event on corresponging input in gb row
        targetInput.change();

    });

    convertGridInfoMap();
    promoTotalTicketValueSelector = createFieldSelector('TotalTicketValue__c');

    promoPromoScaleMetadata = getMetadataMapsForObject('Promo-Promo Scale');

    ppsPromoScaleInputSelector = createFieldInputSelector('Promo_Scale__c', promoPromoScaleMetadata);
    ppsPromoScaleSelector = createFieldSelector('Promo_Scale__c', promoPromoScaleMetadata);
    ppsNameSelector = createFieldInputSelector('Name', promoPromoScaleMetadata);
    ppsPriceInputSelector = createFieldInputSelector('Price__c', promoPromoScaleMetadata);
    ppsPriceSelector = createFieldSelector('Price__c', promoPromoScaleMetadata);
    ppsNumTicketsSelector = createFieldInputSelector('NumberofTickets__c', promoPromoScaleMetadata);
    ppsTicketValueInputSelector = createFieldInputSelector('TicketValue__c', promoPromoScaleMetadata);



});