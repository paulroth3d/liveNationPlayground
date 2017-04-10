(function($) {
	$(window).on('message', function(e) {
    	var data = e.originalEvent.data;
		if (data.resize) {
            $('iframe[data-grid-name=' + data.id + ']').height(data.resize);
    	}
    });
})(window.jQuery);