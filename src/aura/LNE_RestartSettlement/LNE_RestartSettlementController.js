({
    doInit: function( component, event, helper ){
        console.log( 'LNE_RestartSettlementController init' );
    },
    handleScriptsLoaded: function( component, event, helper ){
        console.log( 'all components should have loaded' );
    },
    clickNo : function(component, event, helper) {
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();	
	},
    clickYes: function(component, event, helper) {
        console.log( 'LNE_RestartSettlement controller clicked' );
        var action = component.get("c.restartSettlement");
        action.setParams({
            eventId : component.get("v.recordId")
        });
        
        component.set("v.showButtons", false);
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
				var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                	"title": "Settlement Restarted",
                	"message": "The Settlement Restart process has been completed."
                });
                resultsToast.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                var pageName = 'LNE_RestartSettlement';
                var messageType = 'saveComplete';
                var isSuccessful = true;
                var data = {
                    "auraId":component.getGlobalId(), 
                    "src": window.location.href
                };
                var postMessage = new LNE_PostMessage( pageName, messageType, isSuccessful, data );
                postMessage.dispatch( window );
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
    
        $A.enqueueAction(action);
	}
    
    
})