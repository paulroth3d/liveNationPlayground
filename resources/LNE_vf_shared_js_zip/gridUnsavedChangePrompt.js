//-- LNE_vf_shared_js

window.lneSharedJs = {};
var lne = window.lneSharedJs;

lne.alerted = {};
lne.gridList = [];
lne.settings = {};
lne.targets = {};
lne.gridIframeNameAttr = 'data-grid-name';

lne.sharedInit = function() {
    window.addEventListener("message", lne.receiveMessage, false);
    lne.handleFocusLoss();
};

lne.receiveMessage = function(event) {
        var frame, humanGridName, g, save, win;
        humanGridName = event.data.gridName;

        //-- the event.data.gridName is intended for display to user so it can
        //-- contain spaces and uppercase. Of course the naming convention for grid iframes 
        //-- in the markup is all lower case no spaces. 
        if (event.data.gridName) {
            g = (event.data.gridName).toLowerCase();
            g = g.replace(/ /g,'');
            win = lne.targets[g];
        } else {
            win = 'unknown';
        }
        
        if (event.data.requestedAction === 'report') {
            frame = $(document.activeElement).attr(lne.gridIframeNameAttr);

            //-- typical show prompt to save changes 
            if (event.data.changes === 'true' && lne.alerted[g] === 0 && g !== frame && !frame && win !== 'unknown') {
                save = window.confirm('You have unsaved changes in the ' + humanGridName + ' grid. Would you like to save now?');
                lne.alerted[g] = 1;
            } else {
                //-- So we don't get save prompt twice in a row or on returning focus to grid with unsaved changes
                //-- but it will be reset so as to be useful again this work period
                lne.alerted[g] = 0;
            }

            if (win) {
                if (save) {
                    win.postMessage({'action': 'save'}, '*');
                    console.log('sending save request to win ');
                } 
            } else if (!win && save) {
                console.log('win for save message not set!');
            }
        } else if (event.data.requestedAction === 'reportForVisibility') {
            //-- we let the toggle list handle news of changes in its own way
            if (g.indexOf('-') > -1) {
                g = g.replace(/-/g,'');
            }
            lneAdPlanLocal.completeVisibilityToggle(g, event.data.changes, event.data.hasRows);
        } else if (event.data.requestedAction === 'savedNotification') {
            console.log('VF Shared js - savedNotification message received, calling handleSuccessfulSave');
            lne.handleSuccessfulSave();
        } 
};

/**
*   Helper builds list of grids
**/
lne.getGridsOnPage = function() {
    var sel = 'iframe[' + lne.gridIframeNameAttr + ']';
    lne.gridList = []; 

    $(sel).each(function() {
        console.log('BUILDING LNE GRID LIST');
        console.log($(this));
        console.log('found grid ' + $(this).attr(lne.gridIframeNameAttr));
        lne.gridList.push($(this).attr(lne.gridIframeNameAttr)); 
    });

    if (lne.gridList) {
	    console.log('lne.gridList ', lne.gridList);
	    return true;
    } else {
        console.log('no grids on page');
        return false;
    }
};

/**
*   Handle cases where grid iframe looses focus
**/
lne.handleFocusLoss = function(namedGrid) {
    var changedDom = false;
    var focused;
    var i = 0;
    var id = '';

    var checkFocus = function() {
        if(document.activeElement != focused) {
            //console.log('changed focus - ', document.activeElement);
            checkGridStatus();
        }

        focused = document.activeElement;
    };

    var checkGridStatus = function(namedGrid) {                        
        /**
        *   Usually origin would be a recommended value. However we are not sending
        *   passwords or other sensitive information and will be screening messages
        *   to be from at least force.com
        **/
        var origin = window.location.href;
        
        if (!namedGrid) {
            checkAllGrids();
        } else {
            if (lne.targets[namedGrid]) {
                console.log('send reportForVisibility to ' + namedGrid);
                lne.targets[namedGrid].postMessage({'action': 'reportForVisibility'}, '*');
            }
        }
    };

    var checkAllGrids = function() {
        /**
        *   Usually origin would be a recommended value. However we are not sending
        *   passwords or other sensitive information and will be screening messages
        *   to be from at least force.com
        **/
        var origin = window.location.href;
        console.log('check all grids sending report msg from vf js');
        
        for (i = 0; i < lne.gridList.length; i++) {
            if (lne.targets[lne.gridList[i]]) {
                lne.targets[lne.gridList[i]].postMessage({'action': 'report'}, '*');
            }
        }
    };

    if (lne.gridList.length === 0) {
        if (!lne.getGridsOnPage()) {
            return false;
        }
    }

    //-- for more information, please see: https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver
    //-- creates the observer that will fire the function when the dom is updated.
    var MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;

    var observer = new MutationObserver( function( mutations, observer ){
        mutations.forEach(function(mutation) {
            changedDom = true;
            //-- no longer need to check focus a new tab was selected
            checkGridStatus();
        });
    });

    //-- configuration for the observer
    var mutationConfig = { attributes: true, childList: true, characterData: true, subtree: true };

    //-- observer.observe( htmlElement, mutationConfig )
    //-- this monitors for any mutations on #gbMainTable on cells inc children
    observer.observe( document.querySelector('body'), mutationConfig );

    //-- keep track of what grids have caused a prompt to be shown
    for (i = 0; i < lne.gridList.length; i++) {
        lne.alerted[lne.gridList[i]] = 0;
    }

    //-- build list of iframes to target specific grids 1 at a time
    for (i = 0; i < lne.gridList.length; i++) {
        sel = 'iframe[' + lne.gridIframeNameAttr + '="'+ lne.gridList[i] + '"]';
        lne.targets[lne.gridList[i]] = $(sel).get(0).contentWindow;
    }

    if (lne.targets) {
        console.log(' lne.targets is ', lne.targets);
    }
    
    if (!$) {
        console.log('no jq!');    
    }
    
    if (!namedGrid) {
        //-- Perform init
        console.log('Init handle focus loss');
        window.setInterval(checkFocus, 400);
    } else {
        //-- Just want the status of 1 specific grid
        console.log('handleFocusLoss - namedGrid ' + namedGrid);
        checkGridStatus(namedGrid);
    }
};

/**
*   Handle notifying the lightning container a grid was saved
**/
lne.handleSuccessfulSave = function() {
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
