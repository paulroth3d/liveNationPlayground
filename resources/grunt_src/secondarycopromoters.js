/**
 *  Defaults the PrimarySecondaryCoPromoter__c field to Primary
 **/
function setPrimarySecondaryCoPromoter(){
	jq('#gbMainTable').find(createFieldInputSelector('PrimarySecondaryCoPromoter__c')).each(function() {
        jq(this).val('Secondary').change();
        jq(this).prop("disabled", true); 
    
	});
}

jq(document).ready(function() {
	var initialFocus = true;

	//-- always call after jq(document).ready for all scripts
	convertGridInfoMap(gridInfoMap);

	//-- mark the grid as not ready, so change events should not be fired
	markTableReady(false);

	makeLiveNationRowReadOnly();

    //"Event Total" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');

	jq('#gbMainTable ' + createFieldSelector('RecordTypeId')).hide();
	jq('#gbMainTable ' + createFieldSelector('PrimarySecondaryCoPromoter__c')).hide();
	jq('#gbMainTable tr.firstHeader td.nc').hide();
	jq('#gbMainTable ' + createFieldSelector('Rank__c')).closest('td').hide();

	jq('input.createNew').click(function(){ // if a new row is added we need ...
		setlisteners(); //update listeners
		setPrimarySecondaryCoPromoter(); // set default Primary/Secondary Co-Promoter
		jq("#gbMainTable > tbody > tr > td > span.minus").on("click", recalculateLNRow); // listen for row removals and recalculate

		//set record type to co-promoter
		var newRowEl=jq('#gbMainTable tbody > tr.dr')[0];
		var recordTypeInput=jq(newRowEl).find(createFieldInputSelector('RecordTypeId'));
		recordTypeInput.val('Co-Promoter').change();
		recordTypeInput.closest('td').hide();
		jq(newRowEl).find(createFieldInputSelector('PrimarySecondaryCoPromoter__c')).closest('td').hide();
		jq('#gbMainTable tbody > tr.firstHeader td.nc').hide(); // hide Rank header
		jq(newRowEl).find(createFieldInputSelector('Rank__c')).closest('td').hide();
		setPrimarySecondaryCoPromoter();
	});

	jq('input.saveBtn').click(function(){ // extra validation on totals
		if (parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).val()) < 0 ||
			parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventLoss__c' )).val()) < 0 ||
			parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentProfit__c' )).val()) < 0 ||
			parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentLoss__c' )).val()) < 0 ||
			parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'AncillaryRevenue__c' )).val()) < 0){

			alert('The total of non Live Nation rows cannot be greater than 100. Please make sure there are no negative numbers in the Live Nation row.');
			return false;
		}
	});
	
	setlisteners();
	markTableReady(true);
	gridStateMessagingController();

    var fieldInfoSecondary = {
        fields : {
            BonusBase__c: {
                type: 'drop',
                order: 1,
                prepop: 'true'
            },
            Type__c: {
                type: 'drop',
                order: 2,
                prepop: 'true'
            },
            BonusAmount__c: {
                type: 'text',
                order: 3,
                prepop: 'false'
            },
            rangeStart: {
                type: 'text',
                order: 4,
                prepop: 'calc'
            },
            rangeEnd: {
                type: 'text',
                order: 5,
                prepop: 'false'
            },
            Increment__c: {
                type: 'text',
                order: 6,
                prepop: 'true'
            }      
        },
        uniqueness: 'copromoter',
        tableNewRowLabel: 'Create new Bonus Detail',
        tableOrder: 1,
        humanGridName: 'Bonus Detail',
        shortGridName: 'secondary'
    };

    var copromoterBonusSecondary = new lneBonusHelp(fieldInfoSecondary);
});
