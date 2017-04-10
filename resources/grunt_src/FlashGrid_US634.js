jq(document).ready(function() {
    var initialFocus = true;

    console.log('gbc_flashgrid_js document.ready fired');
    
    //-- always call after jq(document).ready for all scripts
    convertGridInfoMap(gridInfoMap);

    //-- mark the grid as not ready, so change events should not be fired
    markTableReady(false);

    //-- hide Category by default
    jq("#gbMainTable " + createFieldSelector("Category__c")).hide();
    jq("#gbMainTable " + createFieldSelector("HighLevelType__c")).hide();

    markTableReady(true);

	gridStateMessagingController();

	//var settlementSelector = createFieldSelector('Settlement__c');

});

	function copySettlementToCurrentFlash(){
		var settlementSelector = jq(createFieldSelector('Settlement__c'));
		var flashSelector = jq(createFieldSelector('CurrentFlash__c'));

		var settlementSelectorLen = settlementSelector.length;

		var isChecked; 

		for(var i=1; i <settlementSelectorLen; i++ ){
		    if(settlementSelector[i]){
		        var settlementVal = settlementSelector.eq(i).html();
		        console.log(settlementVal);
		    }
		    
		  if( jq(flashSelector).eq(i).parent().hasClass("groupByRow") ){
			 isChecked = jq(flashSelector).eq(i).parent().find('.titleCol').find('input[type="checkbox"]').is(":checked")
		  }else{
		     isChecked = jq(flashSelector).eq(i).parent().hasClass("selected")
		  }


		    
		    if(flashSelector[i] && settlementVal != "&nbsp;" && isChecked){

		    	if(flashSelector.eq(i).find('input').length >0){
		    		 flashSelector.eq(i).find('input').val(settlementVal).change(); 
		    	}else{
		    		flashSelector.eq(i).html(settlementVal)
		        	flashSelector.eq(i).change();
		    	}
		        
		    }
		   
		}

	};