/**
 *  Handler for when the ticketScale has changed (ApplyTicketScale__c)
 **/
function applyTicketScaleChangeHandler(evt) {
  var newTicketScale = evt.target.value;
  var parentRow = evt.target.parentElement.parentElement;

  try {
    var eventId = getParentRecordId();
    var ledgerEntryId = parentRow.getAttribute('id');

    if (newTicketScale == 'Selected Tickets') {
      var stageType = '';
      if (isSettlement() == true) {
        stageType = 'Settlement';
      }
      var url = createApexURL('LNE_AssignTicketScalesToLedgerEntries?id=' + eventId + '&ledgerEntryId=' + ledgerEntryId + '&stageType=' + stageType);

      console.log('newTicketScale == selected tickets. create apex url for LNE_AssignTicketScalesToLedgerEntries ' + url);
      console.log('open popup url ',url);

      overlayWindow = window.open(url, '_blank', 'location=no,width=400,height=585');
      jq(createFieldInputSelector('SYS_RandomGeneratedText__c')).val(Math.floor(Math.random() * 900000000000000)).change();
    }
  } catch (err) {
    console.error('error occurred while opening ticket scale popup:' + err);
  }
}

function usingTicketFeeds(){
    var url=window.location.href;
    var results = url.match( /[?&]UsingTicketFeeds=([^\n&]+)($|[&])/);
    if( results &&
        results[1] === "true"
    ){
        return( true );
    } else {
        return( false );
    }
}

function hideFields() {
  jq(createFieldSelector('SelectedTicketScale__c')).hide();
  jq(createFieldSelector('IncludeInAuditPriceBlank__c')).hide();
  jq(createFieldSelector('SYS_RandomGeneratedText__c')).hide();

  if (isSettlement() == true) {
    hideFieldsOnSettlementGrid();
  } else {
    hideFieldsOnNonSettlement();
  }
}

function hideFieldsOnSettlementGrid() {
  jq(createFieldSelector('DeductionAtSellout__c')).hide();
  jq(createFieldSelector('DeductionAtProjection__c')).hide();
  jq(createFieldInputSelector('DeductionatSettlement__c')).attr('disabled', 'disabled');
}

function hideFieldsOnNonSettlement() {
  jq(createFieldSelector('TotalBaseAmount__c')).hide();
  jq(createFieldSelector('AppliedTicketsCount__c')).hide();
  jq(createFieldSelector('Adjustment__c')).hide();
  jq(createFieldSelector('DeductionatSettlement__c')).hide();
}

function isSettlement() {
  var gridType = window.location.href.match(/[&?]gridType=([^&?]+)($|[&?])/)[1];
  if (gridType != null && gridType != undefined && gridType == 'Settlement') {
    return true;
  }

  return false;
}

jq(document).ready(function() {
  
  var beforeAfterColName = '';
  var descriptionColName = '';
  var initialFocus = true;
  var typeColName = '';
  var overlayWindow;

  //-- always call after jq(document).ready for all scripts
  convertGridInfoMap(gridInfoMap);
  gridStateMessagingController();

  //"Event Total" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');

  var includeAuditSelector = createFieldSelector('IncludeInAuditPrice__c');
  
  var showAuditField = usingTicketFeeds() == true || (isSettlement() == true);
  
  if(showAuditField == false){
    jq(includeAuditSelector).remove();
  }

  jq('.firstHeader td').each(function() {
    if (jq(this).text().indexOf('Before/After') > -1) {
      beforeAfterColName = jq(this).attr('name');

      jq('td[name=' + beforeAfterColName + ']').hide();
    } else if (jq(this).text().indexOf('Description') === 0) {
      descriptionColName = jq(this).attr('name');
    } else if (jq(this).text().indexOf('Type') === 0) {
      typeColName = jq(this).attr('name');
    }
  });

  jq('.createNew').click(function() {
    const showAudit = showAuditField;

    if(showAudit === false){
      jq(includeAuditSelector).remove();
    }

    jq('td[name=' + beforeAfterColName + '] .plTxt').click();
    jq('td[name=' + beforeAfterColName + '] select').val('Before Adjusted').change();
    jq('td[name=' + beforeAfterColName + '] select').attr('disabled', 'disabled');
    jq('td[name=' + beforeAfterColName + ']').hide();

    jq('#gbMainTable tr').each(function() {
      if (jq(this).attr('id')) {
        if (jq(this).attr('id').indexOf('-') === 0) {
          jq(this).find('input').attr('disabled', 'disabled').removeClass('gbrq');
          jq(this).find('select').attr('disabled', 'disabled').removeClass('gbrq');
          jq(this).find('[name=\'' + typeColName + '\'] select').attr('disabled', false);
          jq(this).find('[name=\'' + descriptionColName + '\'] input').attr('disabled', false);

          if (showAudit === true) {
            jq(this).find(createFieldInputSelector('IncludeInAuditPrice__c')).attr('disabled', false).addClass('gbrq');
          }
        }
      }
    });

    hideFields();
  });

  jq('#gbMainTable').on('change', createFieldSelector('ApplyTicketScale__c'), applyTicketScaleChangeHandler);

  jq('#gbMainTable').on('focus', createFieldSelector('ApplyTicketScale__c'), function(evt) {
    if (!overlayWindow && initialFocus) {
      initialFocus = false;

      applyTicketScaleChangeHandler.apply(this, arguments);
    } else {
      if (overlayWindow && !overlayWindow.closed) {
        overlayWindow.close();
      }

      initialFocus = true;
      overlayWindow = null;
    }
  });

  jq('.saveBtn, .deleteItem').click(function() {
    parent.postMessage('Saving', '*');
  });

  parent.postMessage('Loaded','*');

  if (readOnlyGrid === true) {
    jq('.createNew,.editBtn').remove();
    jq('input.selectAllChk').remove();
    jq('input.dl').remove();
    jq('.deleteItem').remove();
  }

  hideFields();

});
