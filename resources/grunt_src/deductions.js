function defaultType() {
	try {
    	jq("#gbMainTable " + createFieldSelector("Type__c") + " div").click();
    } catch (e) {
    	console.log(e);
    }
    try {
		jq("#gbMainTable " + createFieldInputSelector("Type__c")).val('Deduction');
	} catch (e) {
    	console.log(e);
    }
	try {
		jq("#gbMainTable " + createFieldInputSelector("Type__c")).change();
	} catch (e) {
    	console.log(e);
    }
	try {
		jq("#gbMainTable " + createFieldSelector("Type__c")).hide();
	} catch (e) {
    	console.log(e);
    }
}

jq(document).ready( function(){
	convertGridInfoMap( gridInfoMap );
	
	jq("#gbMainTable " + createFieldSelector("Type__c")).hide();

	jq('.createNew').click(function() {
		defaultType();
	});
});