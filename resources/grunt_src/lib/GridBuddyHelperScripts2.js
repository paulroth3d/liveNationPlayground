/**
 *  Common scripts that can be used by all GridbuddyCustomizations
 *  <p>Similar to the GridBuddyHelperScripts v1 file,
 *  except this resolves the misunderstanding for how multiple grid definitions work.</p>
 * 
 *  @author Paul Roth <proth@salesforce.com>
**/

//-- list of all grid info definitions.
//-- pleasenote that gridInfoByField and gridInfoById are now held within each definition.
//-- parent is the top level grid
//-- subgrid1...N are then the definitions within the gridInfoMap for the corresponding number (i.e. gridInfoMap.1 = gridInfos.subgrid1
gridInfos = {};

console.error( "GridBuddyHelperScriptsv2 has not been fleshed out yet");

/**
 *  Function that converts the gridInfoMap to populate the gridInfoByField
 *  and gridInfoById.
 *  @invariant gridInfoByField populated
 *  @invariant gridInfoById populated
**/
function convertGridInfoMapDefinition( obj ){
  var gridInfoByField = {};
  var gridInfoById = {};

  if( obj && obj.metaColumns ){
    var metaColumn;
    for( var i = 0; i < obj.metaColumns.length; i++ ){
      metaColumn = obj.metaColumns[i];
      gridInfoByField[ metaColumn.fieldName ] = metaColumn;
      gridInfoById[ metaColumn.fieldId ] = metaColumn;
    }
  }
  return({ gridInfoByField:gridInfoByField, gridInfoById:gridInfoById });
}

function convertGridInfoMap() {
  var results = {};

  var originalMap = gridInfoMap;
  var gridInfo = null;
  var fieldName2 = null;
  for( var fieldName in gridInfoMap ){
    if( gridInfoMap.hasOwnProperty( fieldName )){
      fieldName2=fieldName;
      if( fieldName == 'p' ){
        fieldName2 = 'parent';
      } else {
        fieldName2 = 'subgrid' + fieldName;
      }
      results[fieldName2] = convertGridInfoMapDefinition( gridInfoMap[ fieldName ] );
    }
  }
  return( results );
}

/**
 *  Determines the metadata for a particular object within the gridInfoMap.
 *  <p>Appears to be a different way of calculating gridInfoMaps</p>
 *  @param objectName(String)
 *  @return (object:{ gridInfoByField, gridInfoById })
**/
function getMetadataMapsForObject(objectName){
	var originalMap = gridInfoMap;
	var objectMetaData;
	var returnObject = {gridInfoByField:{}, gridInfoById:{}};

	for(var k in originalMap){

		objectMetadata = originalMap[k];

		if(objectMetadata.hasOwnProperty('gridName') && objectMetadata.gridName == objectName){
			if( objectMetadata.metaColumns ){
				var metaColumn;
				for( var i = 0; i < objectMetadata.metaColumns.length; i++ ){
					metaColumn= objectMetadata.metaColumns[i];
					returnObject.gridInfoByField[ metaColumn.fieldName ] = metaColumn;
					returnObject.gridInfoById[ metaColumn.fieldId ] = metaColumn;
				}
			}
		}
	}

	return returnObject;
}

/**
 *  Creates a selector for a row given by a specific salesforce id.
 *  @param salesForceId (String) - salesforce record id
 *  @param String - selector - ex: tr#a0qR0000001iEeYIAU
 *  @example: jq( "#gbMainTable").find( createRowSelector( "a0qR0000001iEeYIAU" )).createFieldSelector( gridInfoByField.RecordTypeId.fieldName ))
**/
function createRowSelector( salesForceId ){
	return( "tr#" + salesForceId );
}

/**
 *  Creates a selector for a field in a gridBuddy grid
 *  for a given salesforce field api name.
 *  @param fieldApi (String) - like RateType__c
 *  @param metadataObject (Object)
 *  @return String - i.e td[name=v2]
**/
function createFieldSelector( fieldApi, metadataObject ){

	var source = metadataObject||window;
	if( !source.gridInfoByField ){
		throw( "convertGridInfoMap() has not been called and metadataObject is missing or unexpected format" );
	} else if( !source.gridInfoByField.hasOwnProperty( fieldApi )){
		throw( "Field[" + fieldApi + "] is not defined in the gridInfoByField" );
	}
	
	//-- :input not included as it seems not necessary
	//-- remember to use evt.target.value to get values on selects.
	return( "td[name=" + source.gridInfoByField[fieldApi].fieldId + "]" );
}

/**
 *  Creates a selector for a field input in a gridBuddy grid
 *  for a given salesforce field api name.
 *  @param fieldApi (String) - like RateType__c
 *  @param metadataObject (Object)
 *  @return String - i.e td[name=v2] :input
**/
function createFieldInputSelector( fieldApi , metadataObject){
	return( createFieldSelector( fieldApi, metadataObject ) + " :input" );
}

/**
 *  Finds a given row by a salesForceId
 *  @param salesForceId (String)
 *  @return (el) - jquery results for that row
 *  @example: jq( createFieldSelector( "BaseAmount__c" ), findRowById( "a0qR0000001iEeYIAU" ));
**/
function findRowById( salesForceId){
	//-- does not appear necessary - and may give some options in the future if we leave off gbTable
	//return( jq( "#gbMainTable " + createRowSelector( salesForceId )));
	return( jq( createRowSelector( salesForceId )));
}

/**
 *  Creates a URL for a given apex page.
 *  @param pageName (String)
 *  @return (String)
 *  @example
 *  getAjaxResponderURL( "LNE_GridBuddyCalculationAPI" ); //https://lne--dev0--c.cs2.visual.force.com/apex/LNE_GridBuddyCalculationAPI 
**/
function createApexURL( pageName ){
  var currentLocation = window.location.href;
  var ajaxURL = currentLocation.replace( 'gblite.', 'c.' );
  ajaxURL = ajaxURL.substring(0, ajaxURL.toLowerCase().indexOf('/apex/' )) + '/apex/' + pageName;
  return( ajaxURL );
}

/**
 *  Sanitize numbers.
 *  @param numStr (can include thousands position)
 *  @return cleanedString
**/
function sanitizeNumber( numStr ){
	if( !numStr ){
		return( numStr );
	} else {
		return(numStr.replace( /[^.0-9]/g, '' ));
	}
}

/**
 *  Formats numbers
 *  @param num
 *  @return (string) - i.e 85,814.00
**/
function formatNumber( num ){
	try {
		var result = num.toLocaleString(  "en-US", { style: 'currency', currency: 'USD' }).replace('$', '');
		return( result );
	} catch( err ){
		console.log( 'unable to format number[' + num + ']' );
		return( num );
	}
}

/**
 *  Gets a value from a gridbuddy input
 *  @param row (Element) - jQuery element of the row to select within
 *  @param fieldAPI (String) - api name of the field to ask for
**/
function getInputValue( row, fieldAPI ){
	if( !gridInfoByField.hasOwnProperty( fieldAPI )){
		throw( "gridInfoByField[" + fieldAPI + "] does not exist" );
	}
	var el = jq( row ).find( createFieldInputSelector( fieldAPI ) );
	if( !el || el.length < 1 ){
		//-- @TODO: investigate further - this happens if there is a select that hasn't been used yet... (facepalm)
		return( jq( row ).find( createFieldSelector( fieldAPI ) + " div" ).text() );
	} else {
		return( el.val() );
	}
}

/**
 *  Gets the ID of the current record being used.
 *  <p>In this case its the id of the event</p>
 **/
function getCurrentRecordId() {
    return (window.location.href.match(/[&?]fpv=([^&?]+)[&?]/)[1]);
}

/**
 *  Gets the ID of the current record being used on grids
 *  that use the "fpv" param with a combined ID+stage type.
 *  This function looks for a separate param with just the record ID.
 *  <p>In this case its the id of the event</p>
 **/
function getParentRecordId() {
    return (window.location.href.match(/[&?]parentid=([^&?]+)($|[&?])/)[1]);
}

/**
 *  Converts a % string to a decimal (i.e. "44" to "0.44")
 *  @param percentStr
 *  @return float as a string
 **/
function percentToFloat(percentStr) {
    var newVal = parseFloat(percentStr, 10);
    if (!isNaN(newVal)) {
        return ((newVal / 100.0).toFixed(4));
    } else {
        //-- could not parse percentStr
        return (percentStr);
    }
}

/**
 *  Converts a Decimal string to a percentage
 *  @see percentToFloat
 *  @param floatStr
 *  @return percent as String
 **/
function floatToPercent(floatAmt) {
    if (!isNaN(floatAmt)) {
        return (floatAmt * 100.0);
    } else {
        //-- could not parse percentStr
        return (floatAmt);
    }
}

/**
 *  Marks whether the table is ready (true) or not (false)
 *  @param isReady - whether the table is ready and change events can dispatch
 **/
function markTableReady(isReady) {
    jq("#gbMainTable").attr("isReady", isReady);
}

/**
 *  Determines whether the table is ready
 *  @return boolean - whether the table was marked ready (true) or not (false)
 **/
function isTableReady() {
    var isReady = jq("#gbMainTable").attr("isReady");
    return (isReady === "true");
}

function gridStateMessagingController() {
  gridStateMessagingController();
  gridSpecificNotifySavedSuccessful();
}

function gridSpecificNotifySavedSuccessful() {
  console.log('gridSpecificNotifySavedSuccessful Fires');

}

/**
*   Handle when user has unsaved changes and this grid looses focus
*   Receive messages from parent VF containing page
**/
function gridSpecificHandleFocusLoss() {
    console.log('gridSpecificHandleFocusLoss Fires');
    var gridName = window.gridNameForUDF || null;

    if (gridName.indexOf('-') > -1) {
    	gridName = gridName.replace(/-/g,'');
    }

    window.addEventListener("message", receiveMessage, false);

    function receiveMessage(event) {
        var msg = {
            'changes': 'false',
            'gridName': gridName,
            'requestedAction': event.data.action,
            'hasRows': 'false'
        };

        if (!gridName) {
            return false;
        }

        var origin = event.origin || event.originalEvent.origin; // For Chrome, the origin property is in the event.originalEvent object.
        if (origin.indexOf('visual.force.com') === -1) {
            return false;
        } else {
            var $changedCells = jq('#gbMainTable').find('td.mod');
            var $newRows = jq('#gbMainTable').find('tr.nr');

            if ($changedCells.length > 0 || $newRows.length > 0) {
                msg.changes = 'true';
            } else {
                msg.changes = 'false';
            }

            var $noDataCol = jq('#gbMainTable').find('td.noDataCol');
            var $cell1 = jq('#gbMainTable').find('td[name="v0"]');
            if ($cell1.length == 0 || $noDataCol.length > 0) {
                msg.hasRows = 'false';
            } else {
                msg.hasRows = 'true';
            }

            if (event.data.action === 'report' || event.data.action === 'reportForVisibility') {
                event.source.postMessage(msg, event.origin);
            } else if (event.data.action === 'save') {
                //-- check again to be sure
                if ($changedCells.length > 0 || $newRows.length > 0) {
                	if (jq('body').find('input[type="submit"].saveBtn:not(.none)')) {
                    	jq('body').find('input[type="submit"].saveBtn:not(.none)').click();
                	} else {
                		console.log('Cannot find save button');
                	}
                }
            }
        }
    }
}

/**
* Sets up resizing events
**/
(function() {

    var u = new URLSearchParams(window.location.search);
    var nom = (u.get('gname') || '').replace(/[^a-z]/gi, '').toLowerCase();

    function resizeNow() {
      // to check for new elements created by the new button.
      // timeout isnt best approach but not much else to go off of
      setTimeout(function() {
        jq('.createNew, .deleteItem, .minus, .icon-arrow, .rfIcon').on('click', resizeNow);
      }, 100);

      var height = jq('.gbAppPage').outerHeight() + (jq(this).hasClass('rfIcon') ? 150 : 40);
      // post message to parent
      parent.postMessage({
        resize: height,
        id: nom
      }, '*');
    }

    // to force it to run after other ready scripts
    setTimeout(resizeNow, 100);

})();

