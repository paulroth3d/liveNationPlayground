({

    /**
    * Generic wrapper to make server calls easier to read in the code
    **/
    callServer: function(component, serverAction, params, successCallback, failureCallback) {

        var action = component.get(serverAction);
        action.setParams(params);
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === 'SUCCESS' && successCallback) {
            successCallback(response.getReturnValue());
          }
          else if (state === 'FAILURE') {
            failureCallback = failureCallback || defaultFailure;
            failureCallback(response.getError());
          }
        });
        $A.enqueueAction(action);

        function defaultFailure(error) {
          console.log(error);
        }

    },

    /**
     *  Determines the number of events currently outstanding
     **/
    getNotifications: function(component) {

        var helper = this,
            params = {
                eventId: component.get('v.recordId')
            };

        this.callServer(component, 'c.getNotifications', params, function(response) {

            var numNotifications = 0,
                latestMessage = '';

            if(response) {
                component.set('v.notifications', response);
                numNotifications = response.length;
                if (numNotifications == 1) {
                    var item = response[0];
                    latestMessage = helper.formatMessage(item);
                }
                else if (numNotifications > 1) {
                    latestMessage = '(' + numNotifications + ' messages)';
                }
            }
            else {
                component.set('v.notifications', []);
            }

            component.set('v.numAlerts', numNotifications);
            component.set('v.latestMessage', latestMessage);

        });

    },
    
    /**
     * Determines the session id
     **/
    getServerData: function(component) {

        var helper = this;
        
        this.callServer(component, 'c.getServerData', {}, function(response) {
            component.set('v.sessionId', response.sessionId);
            component.set('v.userId', response.userId);
            helper.initializeCometd(component);
        });
    },
    
    hideAlerts: function(component, shouldHideAlerts) {
        component.set('v.hideAlerts', shouldHideAlerts);
    },
    
    /**
     * initializes cometd - private method - held behind cometdLatch
     **/
    initializeCometd: function(component) {

        var helper = this;
            
        jQuery.cometd.init({
            url: window.location.protocol + '//' + window.location.hostname + '/cometd/38.0/',
            requestHeaders: { 
                Authorization: 'OAuth ' + component.get('v.sessionId') 
            }
        });
        
        jQuery.cometd.subscribe('/topic/EventAlerts', function(message) {

            var item = message.data.sobject,
                eventId = component.get('v.recordId'),
                userId = component.get('v.userId');
            
            if (item.Status__c === 'Open'
             && item.Event__c === eventId
             && item.CreatedById === userId
            ) {

                var latestMessage = helper.formatMessage(item),
                    notifications = [item].concat(component.get('v.notifications'));
                
                if (component.get('v.useToast')) {
                    var toastEvent = $A.get('e.force:showToast');
                    toastEvent.setParams({ 
                        title: 'New Message',
                        message: JSON.stringify(latestMessage)
                    });
                    toastEvent.fire();
                }

                component.set('v.latestMessage', latestMessage);
                component.set('v.notifications', notifications);
                component.set('v.numAlerts', notifications.length);
                component.set('v.hideAlerts', false);
                
            }

        });

    },

    dismissAll: function(component) {

        var recordIds = [];

        component.get('v.notifications').forEach(function(item) {
            recordIds.push(item.Id);
        });

        var params = {
            notificationIdsList: recordIds
        };

        this.callServer(component, 'c.dismissNotifications', params, function (response) {
            if (response) {
                component.set('v.hideAlerts', true);
                component.set('v.showList', false);
                component.set('v.notifications', []);
                component.set('v.numAlerts', 0);
            }
        });

    },

    formatMessage: function(item) {

        var datetime = item.CreatedDate.split('T'),
            yearmonthday = datetime[0].split('-'),
            createdDate = yearmonthday[1] + '/' + yearmonthday[2] + '/' + yearmonthday[0];

        return item.Type__c + ' : ' + createdDate + ' ∙ ' + item.Description__c;

    }
})