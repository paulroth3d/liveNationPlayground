function hideFields() {
  jq(createFieldSelector('SoldValidation__c')).hide();

  disableFields();
}

function disableFields() {
  jq("#gbMainTable").find(createFieldInputSelector('ActualGrossToDate__c')).attr('disabled', 'disabled');
}

function updateNetCapacity(evt) {

  if( evt ){
    var parentRow = jq(evt.target).closest('tr');
    updateNetCapacityForRow(parentRow);
  } else {
    jq("#gbMainTable " + createFieldInputSelector( "Capacity__c" ) ).each( function( index, el ){
      console.log( arguments );
      var parentRow = jq(el).closest('tr');
      updateNetCapacityForRow(parentRow);
    });
  }

}

function updateNetCapacityForRow(row) {
  var capacity = sanitizeNumber(getInputValue(row,'Capacity__c'));
  var kills = sanitizeNumber(getInputValue(row,'Kills__c'));
  var holds = sanitizeNumber(getInputValue(row,'Holds__c'));

  capacity = (capacity == null) ? 0 : capacity;
  kills = (kills == null) ? 0 : kills;
  holds = (holds == null) ? 0 : holds;

  var newNetCapacity = capacity - kills - holds;

  jq(row).find(createFieldSelector('NetCapacity__c')).text(newNetCapacity);
}

function updateSold(evt) {
  if( evt ){
    var parentRow = jq(evt.target).closest('tr');
    updateSoldForRow(parentRow);
  } else {
    jq("#gbMainTable " + createFieldInputSelector( "Capacity__c" ) ).each( function( index, el ){
      console.log( arguments );
      var parentRow = jq(el).closest('tr');
      updateSoldForRow(parentRow);
    });
  }
}

function updateSoldForRow(row) {
  var newSold = calculateSoldForRow(row);
  updateGrossForRow(row);

  var sold = sanitizeNumber(getInputValue(row,'ActualSalesToDate__c'));

  if (newSold != sold) {
    jq(row).find(createFieldInputSelector('ActualSalesToDate__c')).val(newSold).change();

    if (newSold >= 0) {
    	jq(row).find(createFieldInputSelector('ActualSalesToDate__c')).removeClass('gbrq');
    }
  }
}

function calculateSoldForRow(row) {
  var capacity = sanitizeNumber(getInputValue(row,'Capacity__c'));
  var kills = sanitizeNumber(getInputValue(row,'Kills__c'));
  var holds = sanitizeNumber(getInputValue(row,'Holds__c'));
  var comps = sanitizeNumber(getInputValue(row,'Comps__c'));
  var unsold = sanitizeNumber(getInputValue(row,'Unsold__c'));

  capacity = (capacity == null) ? 0 : capacity;
  kills = (kills == null) ? 0 : kills;
  holds = (holds == null) ? 0 : holds;
  comps = (comps == null) ? 0 : comps;
  unsold = (unsold == null) ? 0 : unsold;

  var newSold = capacity - kills - holds - comps - unsold;

  return newSold;
}

function updateGross(evt) {
  if( evt ){
    var parentRow = jq(evt.target).closest('tr');
    updateGrossForRow(parentRow);
  } else {
    jq("#gbMainTable " + createFieldInputSelector( "Price__c" ) ).each( function( index, el ){
      console.log( arguments );
      var parentRow = jq(el).closest('tr');
      updateGrossForRow(parentRow);
    });
  }
}

function updateGrossForRow(row) {
  var price = sanitizeNumber(getInputValue(row,'Price__c'));
  var sold = sanitizeNumber(getInputValue(row,'ActualSalesToDate__c'));

  price = (price == null) ? 0 : price;
  sold = (sold == null) ? 0 : sold;

  var newGross = price * sold;
  var gross = sanitizeNumber(getInputValue(row,'ActualGrossToDate__c'));

  if (newGross != gross) {
    jq(row).find(createFieldInputSelector('ActualGrossToDate__c')).val(formatNumber(newGross)).change();
  }
}

function soldValuesAreValid() {
	var valid = true;

	jq("#gbMainTable " + createFieldInputSelector( "ActualSalesToDate__c" ) ).each( function( index, el ){
		jq(el).removeClass('gbrq');
    	var sold = sanitizeNumber(jq(el).val());
    	if (sold < 0) {
			valid = false;
			jq(el).addClass('gbrq');
		}
    });

	return valid;
}

jq(document).ready(function() {

	jq.fn.deprioritize = function( handlerType ){
	  var handlers;
	  var handler;
	  this.each( function(){
	    console.log( 'de-prioritizing[' + handlerType + '] events for:' + this );
	    handlers = jq._data( this, 'events' );
	    if( handlers.hasOwnProperty( handlerType )){
	      console.log( "found handler type" );
	      var h = handlers[handlerType].pop();
	      handlers[handlerType].splice(0,0,h);
	    } else {
	      console.error( "handler type[" + handlerType + "] not found for:" ); console.error( this );
	    }
	  });
	};

  //-- always call after jq(document).ready for all scripts
  convertGridInfoMap(gridInfoMap);
  gridStateMessagingController();

    //"Total Per Show" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Total per Show');

  jq('.createNew').click(function() {
    hideFields();
  });

  jq('#gbMainTable').on('change', createFieldInputSelector('Capacity__c'), updateNetCapacity);
  jq('#gbMainTable').on('change', createFieldInputSelector('Kills__c'), updateNetCapacity);
  jq('#gbMainTable').on('change', createFieldInputSelector('Holds__c'), updateNetCapacity);
  updateNetCapacity(null);

  jq('#gbMainTable').on('change', createFieldInputSelector('Capacity__c'), updateSold);
  jq('#gbMainTable').on('change', createFieldInputSelector('Kills__c'), updateSold);
  jq('#gbMainTable').on('change', createFieldInputSelector('Holds__c'), updateSold);
  jq('#gbMainTable').on('change', createFieldInputSelector('Comps__c'), updateSold);
  jq('#gbMainTable').on('change', createFieldInputSelector('Unsold__c'), updateSold);
  //updateSold(null);

  jq('#gbMainTable').on('change', createFieldInputSelector('Price__c'), updateGross);
  jq('#gbMainTable').on('change', createFieldInputSelector('ActualSalesToDate__c'), updateGross);
  updateGross(null);

  jq('.saveBtn').click(function(event) {
  	if (soldValuesAreValid() == false) {
  		event.stopPropagation();
  		event.stopImmediatePropagation();
  		event.preventDefault();
  		alert('Sold field value cannot be negative.');
  	} else {
  		parent.postMessage('Saving', '*');
  	}
  });

  jq( ".saveBtn" ).deprioritize( "click" );

  jq('.deleteItem').click(function() {
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

  var observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutationRecord) {
          hideFields();
      });    
  });

  var target = document.getElementsByClassName('ui-resizable');
  for (var i = 0; i < target.length; i++) {
    observer.observe(target[i], { attributes : true, attributeFilter : ['style'] });
  }

});