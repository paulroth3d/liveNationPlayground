({
    /** initialization **/
    doInit: function(component, event, helper) {
        helper.generateRequestId(component);
        helper.getPicklists(component);
    },

    getRecords: function(component, event, helper) {
        helper.getRecords(component);
    }
    
})