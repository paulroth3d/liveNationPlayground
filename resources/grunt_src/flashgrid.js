jq(document).ready(function() {
    var initialFocus = true;
    var hasScrolled = false;

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
    //"Event Total" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');

jq(document).ready(function() {
    var initialFocus = true;
    var hasScrolled = false;

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

    //-- for more information, please see: https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver

    //-- creates the observer that will fire the function when the dom is updated.
    //-- in this case when we scroll, there are new elements added to the fixedHeaderContainer
    //-- so we just run from that
    //-- if we wanted to be smarter, we can look through the mutations arguments to see if
    //-- any mutation records (i.e. mutations[0].addedNodes is greater than 0)
    var observer = new MutationObserver( function( mutations, observer ){
      console.log( "mutations occurred" ); console.log( mutations ); console.log( this );
      jq( "#gbMainTable > tbody > tr > td.fixedHeaderContainer tr td[name='v5']" ).hide();
      jq( "#gbMainTable > tbody > tr > td.fixedHeaderContainer tr td[name='v6']" ).hide();
    });

    //-- configuration for the observer
    var mutationConfig = { attributes: true, childList: true };

    //-- observer.observe( htmlElement, mutationConfig )
    //-- this monitors for any mutations on #gbMainTable ... fixedHeaderContainer
    //-- note we are using direct descendants to avoid listening on child grids.
    observer.observe( jq( "#gbMainTable > tbody > tr > td.fixedHeaderContainer")[0], mutationConfig );

});

    function copySettlementToCurrentFlash(){
    	console.log( 'settlement copy to current flash' );
        var settlementSelector = jq(createFieldSelector('Settlement__c'));
        var flashSelector = jq(createFieldSelector('CurrentFlash__c'));

        var settlementSelectorLen = settlementSelector.length;

        var isChecked; 
        
        var settlementMatch;
        var settlementVal, settlementStr, settlementNum;

        for(var i=1; i <settlementSelectorLen; i++ ){
        	settlementVal = '';
        	
            if(settlementSelector[i]){
                settlementVal = settlementSelector.eq(i).html();
                try {
                	settlementMatch = settlementVal.match( /[\d,.]+/i );
                	settlementStr = settlementMatch[0];
                	settlementStr = settlementStr.replace( /[^\d.]/gi, "" );
                	settlementNum = parseFloat( settlementStr );
                	settlementVal = "" + settlementNum;
                	//console.log(settlementVal);
                } catch ( err ){
                	//console.error( 'unable to convert settlementVal:' + settlementVal );
                }
            }
            
            //Check if particular row is checked 
            if( jq(flashSelector).eq(i).parent().hasClass("groupByRow") ){
                 isChecked = jq(flashSelector).eq(i).parent().find('.titleCol').find('input[type="checkbox"]').is(":checked")
            }else{
                 isChecked = jq(flashSelector).eq(i).parent().hasClass("selected")
            }
            
            //Copy and apply changes over
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

});

    function copySettlementToCurrentFlash(){
    	console.log( 'copy settlement values to flash' );
        var settlementSelector = jq(createFieldSelector('Settlement__c'));
        var flashSelector = jq(createFieldSelector('CurrentFlash__c'));

        var settlementSelectorLen = settlementSelector.length;

        var isChecked; 

        var settlementMatch;
        var settlementVal, settlementStr, settlementNum;

        for(var i=1; i <settlementSelectorLen; i++ ){
            settlementVal = '';
        	
            if(settlementSelector[i]){
                settlementVal = settlementSelector.eq(i).html();
                try {
                	settlementMatch = settlementVal.match( /[\d,.]+/i );
                	settlementStr = settlementMatch[0];
                	settlementStr = settlementStr.replace( /[^\d.]/gi, "" );
                	settlementNum = parseFloat( settlementStr );
                	settlementVal = "" + settlementNum;
                	//console.log(settlementVal);
                } catch ( err ){
                	//console.error( 'unable to convert settlementVal:' + settlementVal );
                }
            }
            
            //Check if particular row is checked 
            if( jq(flashSelector).eq(i).parent().hasClass("groupByRow") ){
                 isChecked = jq(flashSelector).eq(i).parent().find('.titleCol').find('input[type="checkbox"]').is(":checked")
            }else{
                 isChecked = jq(flashSelector).eq(i).parent().hasClass("selected")
            }
            
            //Copy and apply changes over
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