//-- your info goes here:US220_TourSpecificOverhead
//-- to deploy run: grunt deployGridBuddyResource:US220_TourSpecificOverhead

jq(document).ready(function() {
    var initialFocus = true;

    console.log('gbc_flashgrid_js document.ready fired');
    
    //-- always call after jq(document).ready for all scripts
    convertGridInfoMap(gridInfoMap);

    //-- mark the grid as not ready, so change events should not be fired
    markTableReady(false);

    markTableReady(true);

	gridStateMessagingController();

	//Cannot use createFieldSelector because it's a child grid 
	//This needs to be updated if any of the field order changes in the future 
	var tourRepSelector = "td[name=v0]"
	var teSelector = "td[name=v1]"
	var perDiemsSelector = "td[name=v2]"
	var endOfTourDinnerSelector = "td[name=v3]"
	var miscExpenseSelector = "td[name=v4]"
	var totalTSOSelector = "td[name=v5]"

	function sumTSOFields(){
	 var tourRepVal =   parseInt(jq(this).parents('tr').find(tourRepSelector).eq(1).find('input').val()) || 0;
	 var teVal = parseInt(jq(this).parents('tr').find(teSelector).eq(1).find('input').val()) || 0;
	 var perDiemsVal =  parseInt(jq(this).parents('tr').find(perDiemsSelector).eq(1).find('input').val()) || 0;
	 var endOfTourDinnerVal = parseInt(jq(this).parents('tr').find(endOfTourDinnerSelector).eq(1).find('input').val()) || 0;
	 var miscExpenserVal =  parseInt(jq(this).parents('tr').find(miscExpenseSelector).eq(1).find('input').val()) || 0;
	 
	 var totalTSOVal =  tourRepVal + teVal + perDiemsVal + endOfTourDinnerVal + miscExpenserVal;

	 jq(this).parents('tr').find(totalTSOSelector).eq(1).text("USD " +totalTSOVal)

	}

	jq('.n').keyup(function(){
		sumTSOFields.call(this);
	})


});