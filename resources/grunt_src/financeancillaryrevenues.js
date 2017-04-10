function disableRows() {

    // for each masteradforsplit input, if not blank then disable the entire ro
    jq('tr.dr ' + createFieldSelector('RollUpCount__c')).each(function() {
        var $this = jq(this);
        if ($this.text() !== '0' && $this.text() != '') {
            //get row
            $this.closest('tr').find('td.ui-selectee').each(function() {
                jq(this).find('.plTxt').click();
                jq(this).find('input, textarea, select').attr('disabled', true);
                jq(this).find('.gbdt').hide();
            });

        }
    });

}

jq(document).ready(function() {

    convertGridInfoMap(gridInfoMap);
    disableRows();

});