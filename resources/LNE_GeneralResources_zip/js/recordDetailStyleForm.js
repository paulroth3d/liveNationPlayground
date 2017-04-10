
window.lneRecordDetailStyleForm = {};
var recdet = lneRecordDetailStyleForm;

recdet.settings = {
    edit: false
};

recdet.init = function() {
    console.log('lneFinanceSummary init ');
    var gridId;
    var id;
    var raw;
    var split = [];
    var inSplit = [];
    var settings = recdet.settings;

    function setCancelButtonVisibility() {
        $cancelButton = $('#recdet-main-container').find('[data-control="cancel-edit"]').first();
        if (recdet.edit) {
            $cancelButton.removeClass('hide');
        } else {
            $cancelButton.addClass('hide');
        }
    }

    function turnOffEdit() {
    	recdet.edit = false;
        $('#recdet-main-container').removeClass('forceInlineEdit');
        $('#recdet-main-container .edit-footer').first().addClass('hide').removeClass('active');
        $('#recdet-main-container').removeClass('riseTransitionEnabled');
        $('#recdet-main-container').removeClass('risen');
        setCancelButtonVisibility();
        $('[data-control="input"]').each(function() {
            $(this).addClass('hide');
        });
        $('[data-control="read-only"]').each(function() {
            $(this).removeClass('hide');
        }); 
        $('[data-control="edit"]').each(function() {
            $(this).removeClass('hide');
        });  
    }
    
    function enableEdit(){
    	recdet.edit = true;
    	
		$('#recdet-main-container').addClass('forceInlineEdit');
		$('#recdet-main-container .edit-footer').first().removeClass('hide').addClass('active');
		$('#recdet-main-container').addClass('riseTransitionEnabled');
		$('#recdet-main-container').addClass('risen');
		setCancelButtonVisibility();
		$('[data-control="input"]').each(function() {
			$(this).removeClass('hide');
		});
		$('[data-control="read-only"]').each(function() {
			$(this).addClass('hide');
		});
		$('[data-control="edit"]').each(function() {
			$(this).addClass('hide');
		});
    }

    setCancelButtonVisibility();

    /**
    *   Event handlers
    */
    $('.main-container').on('click', '[data-control="edit"]', function(event) {
    	//-- always turn on edit?
    	//-- the pencils will never be there if you are currently in edit mode.
    	enableEdit();
    });
    
    $('div.rome-lds.main-container').on('dblclick', function(){
		if( !recdet.edit ){
    		enableEdit();
    	}
    });

    $('#recdet-main-container').on('click', '[data-control="cancel-edit"]', function(event) {
        
        turnOffEdit();
    });
};

                
recdet.handleSuccessfulSave = function() {
    var auraId, data, isSuccessful, messageType, pageName, postMessage, u;
    var changedDom = false;
    
        console.log('lne.handleSuccessfulSave init');
        console.log('lne.handleSuccessfulSave broadcastSaveComplete fires');
        pageName = 'Expenses';
        isSuccessful = true;

        //-- some custom message type. Again, only saveComplete is special/recognized for now.
        messageType = 'saveComplete';

        //-- send the data payload as an object with stuff to return.
        //-- always include src as some unique identifier for the page
        u = new URLSearchParams(window.location.search);
        auraId = u.get('auraId') || null;
        
        data = {
            src: window.location.href
        };
    
        console.log('pageName ' + pageName);
        console.log('isSuccessful ' + isSuccessful);
        console.log('messageType ' + messageType);
        console.log('auraId ' + auraId);
        console.log('data.src ' + data.src);

        postMessage = new LNE_PostMessage( pageName, messageType, isSuccessful, data );

        //-- works if in a grid overlay
        postMessage.dispatch( parent );
};

console.log('window.lneRecordDetailStyleForm');
console.log(window.lneRecordDetailStyleForm);
