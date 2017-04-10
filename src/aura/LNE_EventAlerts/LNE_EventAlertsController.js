({
	/**
	 *  Initialization event
	 **/
    doInit : function(component, event, helper) {
        //debugger;
        helper.getNotifications(component);
	},
    
    /**
     *  Handler once all the scripts have loaded
     **/
    setupJS: function(component, event, helper) {
        component.set('v.jsLoaded', true);
        helper.getServerData(component);
    },
    
    /**
     *  Handles if the user clicks the close button
     **/
    handleClose: function(component, event, helper) {
        component.set('v.hideAlerts', true);
    },

    handleDestroy : function(component, event, helper) {
        jQuery.cometd.disconnect();
    },
    
    /**
     * Requests to open the list of messages
     **/
    toggleMessages: function(component, event, helper) {
        component.set('v.showList', !component.get('v.showList'));
    },

    dismissAll: function(component, event, helper) {
        helper.dismissAll(component);
    }

})