({
    doInit: function( component, event, helper ){
        console.log( 'init' );
    },
    handleScriptsLoaded: function( component, event, helper ){
        console.log( 'all components should have loaded' );
    },
	clickNo : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
    clickYes: function(component, event, helper) {
        var action = component.get("c.deleteHoldEvent");
        action.setParams({
            eventId : component.get("v.recordId")
        });
        
        component.set("v.showSpinner", true);
        component.set("v.showButtons", false);
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
				var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                	"title": "Event Deleted",
                	"message": "The Event record has been deleted."
                });
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
                
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    "scope": "Event__c"
                });
                homeEvent.fire();
            } else if (a.getState() === "ERROR") {
                var errorString = "";
                
                a.getError().forEach(function(element){
                    element.pageErrors.forEach(function(pageError){
                        errorString += pageError.message + "\n";
                    });
                });
                
                $A.log("Errors", a.getError());

                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                	"title": "Cannot Delete Event",
                	"message": errorString
                });
                resultsToast.fire();
				$A.get("e.force:closeQuickAction").fire();
            }
        });
    
        $A.enqueueAction(action);
	}
})