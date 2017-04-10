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

  generateRequestId: function(component) {

    var reqId = [];
    while (reqId.length < 10) {
      reqId.push(Math.random().toString(36));
    }
    reqId = reqId.join('').substring(0, 255);

    component.set('v.requestId', reqId);

  },

  getPicklists: function(component) {

    var params = {
      tourId: component.get('v.recordId')
    };

    this.callServer(component, 'c.getVendors', params, function(result) {
      component.set('v.vendors', result);
    });

    this.callServer(component, 'c.getTypes', params, function(result) {
      component.set('v.types', result);
    });

  },

  getRecords: function(component) {

    var helper = this,
        params = {
          tourId: component.get('v.recordId'),
          types: component.find('types').get('v.value').split(';'),
          vendors: component.find('vendors').get('v.value').split(';')
        };

    this.callServer(component, 'c.getTourCampaignAdPlans', params, function(result) {

      component.set('v.records', result);

      if (result.length > 0) {
        // build mapping of record.id => record index
        var id_mapping = {};
        result.forEach(function(r, i) {
          id_mapping[r.Id] = i;
        });
        component.set('v.recordIdIndices', id_mapping);
        component.set('v.isProcessing', true);
        // begin updates
        helper.processRecords(component, 0);
      }

    });

  },

  processRecords: function(component, offset) {

    var helper = this,
        recs = component.get('v.records'),
        total = recs.length,
        chunksize = 100; // never go higher than 100

    if (offset < total) {

      var chunk = recs.slice(offset, offset + chunksize);
      if (chunk.length) {

        // build payload
        var chunkIds = [];
        chunk.forEach(function(record) {
          chunkIds.push(record.Id);
        });

        var params = {
          recordIds: chunkIds,
          requestId: component.get('v.requestId')
        };

        this.callServer(component, 'c.updateShortUrls', params, function(result) {

          var id_mapping = component.get('v.recordIdIndices'),
              c = 0;

          for (var i in result) {
            var val = result[i] || 'Could not update',
                ix = id_mapping[i];
            recs[ix].ShortURL__c = val;
            c++;
          }

          component.set('v.numProcessed', component.get('v.numProcessed') + c);
          component.set('v.records', recs);

          //call next round
          helper.processRecords(component, offset + chunksize);

        });

      }

    }
    else {
      this.updateTour(component);
    }

  },

  updateTour: function(component) {

    var helper = this,
        params = {
          tourId: component.get('v.recordId'),
          requestId: component.get('v.requestId')
        };

    this.callServer(component, 'c.updateTour', params, function(result) {

      helper.naviagteToReport(component);

    });

  },

  naviagteToReport: function(component) {
    // all done, go to here
    var urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
        url: '/apex/loop__looplus?autorun=true&eid=' + component.get('v.recordId')
      });
    urlEvent.fire();
  }

})