(function() {
  'use strict';

    jq(document).ready(updateGridBuddies);
    
    function updateGridBuddies() {
        updateGridBuddyStyle();
        updateGridBuddyEvents();
    }
    
    function updateGridBuddyEvents() {
        
    }
    
    function updateGridBuddyStyle() {
        hideSum();
        //hideCurrencyISOCodes();
    }
    
    function hideSum() {
        jq('.ui-selectee div:contains("SUM")').hide(); //US783 - Hide "SUM"
    }
    
    function hideCurrencyISOCodes() {
        var $codes = jq('nobr span');
        
        if($codes && $codes.length) {
            var isoCode = jq.trim(jq($codes[0]).text());
            
            if(isoCode && isoCode.length) {
                $codes.hide();
                var $toHide = jq('.ui-selectee:contains("' + isoCode + '")');
                $toHide.html($toHide.html().replace(isoCode, ''));
            }
        }
    }
    
})();
