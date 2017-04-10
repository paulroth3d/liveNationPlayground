//-- your info goes here:bonushelpers
//-- to deploy run: grunt deployGridBuddyResource:bonushelpers


function lneBonusHelp(fieldInfo) {
    this.anyBonusRecs = [];
    this.$branch = '';
    this.$container = '';
    this.$currentRow = '';
    this.currentRunLogs = [];
    this.errorMsgs = [];
    this.fieldInfo = fieldInfo;
    this.lneBonusHelperLogs = [];
    this.map = {};
    this.newValues = [];
    this.numberRowsAdded = 0;
    this.relatedBonusRecs = []; 
    this.retroDealType = '';
    this.retroBonusRecs = [];
    this.$rows = '';
    this.showingError = false;

    this.boot();
}

lneBonusHelp.prototype = {
    boot: function() {
        var bh = this;
        var fieldDetail = {};
        var fieldInfo = bh.fieldInfo;
        var $buttonBar, cannotSaveMarkup;

        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Boot Start ' + fieldInfo.humanGridName + ' @@@@@@@@@@@@');

        var rowFieldChangeHandler = function(e) {

            try{
                var $branch, $currentRow, $label, $rowsParent;

                /**
                *   Make sure we know what type of bonus was changed.
                *   The inputs all get change handlers so we need to not process any mismatching bonus types.
                *   A single instance of bonusHelpers will process any Artist Retro bonuses, another instance any Artist Deal bonuses etc
                *
                */
                $currentRow = jq(e.target).closest('tr.dr');
                $rowsParent = $currentRow.closest('div.childData');
                $branch = $currentRow.closest('.branch');
                if ($branch.length === 0) {
                    $branch = $rowsParent.closest('.branch');
                    console.log('RESET $branch to ' );
                    console.log($branch);
                }
                //-- save $branch for when we append any error message markup later on
                bh.$branch = $branch;
                bh.currentRunLogs.push('closest branch');
                bh.currentRunLogs.push($branch);
                $label = $branch.find('.createNew[title="' + fieldInfo.tableNewRowLabel + '"]').first();
                bh.currentRunLogs.push('label');
                bh.currentRunLogs.push($label);

                bh.errorMsgs = [];

                var currentGridTitle = $branch.find('.toggleData:first').find('span').get(1).innerText;

                //-- Make sure we don't try and deal with something we are not supposed to
                //if (!$label || $label.attr('title') !== fieldInfo.tableNewRowLabel ) {
                 if (!currentGridTitle || currentGridTitle.indexOf(fieldInfo.humanGridName) == -1 ) {
                    bh.currentRunLogs.push('%%%%%%%%%%%%%%%%% rowFieldChangeHandler ' + fieldInfo.humanGridName + ' EXIT');
                    bh.currentRunLogs.push('Bonus helpers cannot determine current table to handle input changes. This will break overlap checks etc');
                    return false;
                } else {
                    bh.currentRunLogs.push('%%%%%%%%%%%%%%%%% rowFieldChangeHandler ' + fieldInfo.humanGridName + ' proceeeding!');
                    bh.currentRunLogs.push('$$$$$$$$$$$$$$$$$$ Change bonus detail ' + fieldInfo.humanGridName + ' $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
                    bh.currentRunLogs.push(e.target);
                    bh.prepOp('edit', e);

                    bh.checkStartRangeNotBlank();
                    bh.checkRange();
                    bh.checkHighestEndPoint();
                }
            }catch(e){
                console.log('there is a bug in rowFieldChangeHandler located in bonushelpers.js');
            }
        }
        
        //-- may or may not be displayed if in error
        $buttonBar = jq('div.gridBtns.top');
        cannotSaveMarkup = '<div id="fe-cannot-save" class="fe-cannot-save hide">Please correct errors below to save.</div>';
        if (!jq('#fe-cannot-save').hasClass('hide')) {
            $buttonBar.append(cannotSaveMarkup);
        }


        jq('body #gbMainTable').on('click', '.createNew[title="' + fieldInfo.tableNewRowLabel + '"]', function(e){ 
            bh.currentRunLogs.push('$$$$$$$$$$$$$$$$$$ New bonus detail ' + fieldInfo.humanGridName + ' $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
            bh.prepOp('new', e);
            bh.newBonusDetailPrefill();
        });

        jq('body #gbMainTable').on('change', 'input', function(e) {
            rowFieldChangeHandler(e);
        });

        if (bh.fieldInfo.uniqueness === 'copromoter' || bh.fieldInfo.uniqueness === 'artistdeal') {
            //-- Changing the Type can change if the end range should be blank or not
            //-- so try and catch it early
            jq('tbody td[name="v1"]').on('change', 'select', function(e) {
                rowFieldChangeHandler(e);
            });
        }

        $saveButton = jq('body .gridBtns').find('.saveBtn:not(.none)').first();

        $saveButton.on('click' , function(e) {
            var errorBoxSel = '.fe-injected-validation-' + bh.fieldInfo.shortGridName;

            if (bh.errorMsgs.length > 0) {
                e.preventDefault();
                e.stopPropagation();
                var $nosave = jq('body').find('#fe-cannot-save').first();
                $nosave.removeClass('hide');
                $nosave.addClass('show');
                bh.showingError = true;

                //-- When the validation runs again it will handle show/hide in bh.stopSave
                //-- for the first run we show it here as this will run after
                jq(errorBoxSel).removeClass('hide').addClass('show');
            } else {
                jq('#fe-cannot-save').removeClass('show').addClass('hide');
                bh.showingError = false;
            }
        });
    },
    compareContinuous: function(startArr,endArr){
          var isContinuous = [];
          var len = endArr.length;
          var isReversed; 

          //Don't check when new record is created and default is 0 and the reverse case 
          if(len <3 && startArr[0] != 0 || len <3 && startArr[0] < startArr[1] ){
            if(startArr[0] > startArr[1]){
                isReversed = true; 
              } else {
                isReversed = false; 
              }

          }else if(len >= 3 && startArr[0] != 0 || startArr[1] != 0 ){
                if( startArr[0] > startArr[1] && startArr[1] > startArr[2]) {
                isReversed = true; 
              } else {
                isReversed = false; 
              }
          }
          //The reverse messes up sometimes, check this 
          if(isReversed == false){
            var startArr = startArr.reverse();
            var endArr = endArr.reverse(); 
          }
            //If there's only 2 rows 
            if(len == 2){
                if (endArr[len-1] + 1 == startArr[0]){
                  isContinuous.push("true");
                }else{
                   isContinuous.push("false");
                }
            }
              
              //When there's 3 or more fields 
            if(len >2){
                for(var i=0; i<len; i++ ){
                    if(i+1 < len){
                        //check start & end points and special condition for the last null case 
                        if(startArr[i] == endArr[i+1] +1 || endArr[i+1] == null && i+1 == len-1){
                            isContinuous.push("true");
                        }else{
                            isContinuous.push("false");
                        }
                    }
                 
                }
            }
          
          
          if(isContinuous.indexOf("false") >= 0){
              return false; 
          }else{
              return true;
          }
    },
    prepOp: function(op, e) {
        var bh = this;
        if (this.fieldInfo.uniqueness) {
            bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ prepOp Start ' + this.fieldInfo.humanGridName + ' @@@@@@@@@@@@');
        } else {
            bh.currentRunLogs.push('$$$$$$$$$$$$$$ Warning! Cannot determine fieldInfo uniqueness - will cause later issues $$$$$$$$$$$$$$$$$$$');
        }

        var $branch, $con, $masterTable;
        var targetRow = jq(e.target).closest('tr.dr');
        //-- targetRow used to establish if row has focus later
        bh.targetRow = targetRow;

        if (op === 'new') {
            $container = jq(e.target).closest('.crDataContainer');
            $rowsParent = $container.find('div.childData');
            bh.$rows = $rowsParent.find('tr.dr:not(.none)');
            bh.$currentRow = bh.$rows[0];
            bh.$rowsParent = $rowsParent;
            bh.popBonusRecordsArray();
            bh.popRelatedBonusRecordsArray();
        } else if (op === 'edit') {
            $container = jq(e.target).closest('tr.dr');
            bh.$currentRow = $container;
            $rowsParent = $container.closest('div.childData');
            bh.$rows = $rowsParent.find('tr.dr:not(.none)');
            bh.$rowsParent = $rowsParent;
            bh.popBonusRecordsArray();
            bh.popRelatedBonusRecordsArray();    
        }

        if (bh.fieldInfo.uniqueness === 'artistretro' && op === 'edit') {
            //-- the deal type for artistretro is on the parent table (deal not bonus)
            $branch = bh.$currentRow.closest('.branch').first();
            $con = $branch.closest('tr').first();
            $masterTable = $con.prev('tr').first();
            bh.retroDealType = $masterTable.find('td[name="v8"] select').val();
            if (!bh.retroDealType) {
                bh.retroDealType = $masterTable.find('td[name="v8"] .plTxt').text();
            }

            bh.currentRunLogs.push('## bh.retroDealType is ' + bh.retroDealType);
        }

    },
    getCurrentRec: function(sub) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' getCurrentRec');
        var $cells = jq(bh.$currentRow).find('td');
        var currentRec = bh.popBonusRecordsObj($cells);
        if (bh.fieldInfo.uniqueness !== 'artistretro' && !currentRec.BonusBase__c) {
            // current row empty, use last entered
            $cells = jq(bh.$rows[1]).find('td');
            currentRec = bh.popBonusRecordsObj($cells);
        }

        currentRec = bh.filterOutCommas(currentRec);
        return currentRec;
    },
    checkStartRangeNotBlank: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkStartRangeNotBlank');

        var currentRec = bh.getCurrentRec();
        if (currentRec.rangeStart == '') {
            if (bh.errorMsgs.indexOf('startBlank') < 0) {
                bh.errorMsgs.push('startBlank');
            }
        } else {
            if (bh.errorMsgs.indexOf('startBlank') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('startBlank'), 1);
            }                
        }

        bh.checkError();
    },
    checkRange: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkRange');

        var amended = {};
        var anyBonusRecs = [];
        var $cells;
        var currentRec = bh.getCurrentRec();
        var endPoints = [];
        var highestEnd;
        var highestStart;
        var overlapEnd = false;
        var overlapStart = false;
        var related = bh.relatedBonusRecs;
        var startPoints = [];
        var results = [];

        for (var i = 0; i < related.length; i++) {
            if (related[i].rangeStart) {
                startPoints.push(parseInt(related[i].rangeStart));
            } else {
                startPoints.push(null);  
            }
            if (related[i].rangeEnd) {
                endPoints.push(parseInt(related[i].rangeEnd));
            } else {
                endPoints.push(null);
            }
        }


        if (startPoints) {
            highestStart = Math.max.apply(Math, startPoints) || null;
        }
        if (endPoints) {
            highestEnd = Math.max.apply(Math, endPoints) || null;
        }
        

        //Logic for looking at overlapping points 
        for (var i = 1; i < related.length; i++) {
            //-- only compare different rows
            bh.currentRunLogs.push('Standard range check!');
            //-- standard range check
            bh.currentRunLogs.push('related[i].rangeStart ' + related[i].rangeStart);
            bh.currentRunLogs.push('related[i].rangeEnd ' + related[i].rangeEnd);
            bh.currentRunLogs.push('currentRec.rangeStart ' + currentRec.rangeStart);
            bh.currentRunLogs.push('currentRec.rangeEnd ' + currentRec.rangeEnd);

            //check for overlap but remove check for when end is "" so it does the logic correctly 
            if (related[i].rangeStart && related[i].rangeEnd && i!= related.length -1 && currentRec.rangeEnd !="") {
                overlapStart = !bh.numberInRange(related[i].rangeStart, related[i].rangeEnd, currentRec.rangeStart);
                overlapEnd = !bh.numberInRange(related[i].rangeStart, related[i].rangeEnd, currentRec.rangeEnd);
                bh.currentRunLogs.push('overlapStart ' + overlapStart);
                bh.currentRunLogs.push('overlapEnd ' + overlapEnd);

                if (overlapStart || overlapEnd) {
                    results.push('true');
                } else {
                    results.push('false');
                }
            }
            //Check overlap when there's a blank end 
            else if(currentRec.rangeEnd == ""){
                //bh.compareContinuous(startPoints, endPoints)
                if(related[i].rangeStart == currentRec.rangeStart){
                     overlapStart = !bh.numberInRange(related[i-1].rangeStart, related[i-1].rangeEnd, currentRec.rangeStart);
                }else{
                     overlapStart = !bh.numberInRange(related[i].rangeStart, related[i].rangeEnd, currentRec.rangeStart);
                }
                 if(overlapStart){
                    results.push('true')
                 }else{
                    results.push('false');
                 }
            }
        }

        bh.currentRunLogs.push('results of overlap test');
        bh.currentRunLogs.push(results);

        if (results.length === 0) {
            bh.currentRunLogs.push('no results of overlap tests');
            bh.currentRunLogs.push('bh.relatedBonusRecs');
            bh.currentRunLogs.push(bh.relatedBonusRecs);
        }

        if (results.indexOf('true') >= 0) {
            overlap = true;
        } else {
            overlap = false;
        }

        if (overlap) {
            if (bh.errorMsgs.indexOf('overlap') < 0) {
                bh.errorMsgs.push('overlap');
            }
        } else {
            if (bh.errorMsgs.indexOf('overlap') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('overlap'), 1);
            }                
        }

        //Check if it's continous 
        var secondHighestEndPoint;
      
        
        if(startPoints.length > 1){

                if(startPoints && endPoints){
                    if(!bh.compareContinuous(startPoints, endPoints)){
                        if (bh.errorMsgs.indexOf('mustbeContinuous') < 0) {
                            bh.errorMsgs.push('mustbeContinuous');
                        }
                    }else{
                        if (bh.errorMsgs.indexOf('mustbeContinuous') >= 0) {
                            bh.errorMsgs.splice(bh.errorMsgs.indexOf('mustbeContinuous'), 1);
                        }
                    }
                }
                
        }
    
        if (parseInt(currentRec.rangeStart) && parseInt(currentRec.rangeEnd)) {
            if (parseInt(currentRec.rangeStart) > parseInt(currentRec.rangeEnd)) {
                if (bh.errorMsgs.indexOf('endIsLessThanStart') < 0) {
                    bh.errorMsgs.push('endIsLessThanStart');
                }
            } else {
                if (bh.errorMsgs.indexOf('endIsLessThanStart') >= 0) {
                    bh.errorMsgs.splice(bh.errorMsgs.indexOf('endIsLessThanStart'), 1);
                }
            }

            if (currentRec.rangeStart && highestStart && 
                    parseInt(currentRec.rangeStart) < highestStart && 
                    parseInt(currentRec.rangeEnd) > highestEnd 
                ) 
            {
                if (bh.errorMsgs.indexOf('highestEndNotHighestStart') < 0) {
                    bh.errorMsgs.push('highestEndNotHighestStart');
                }
            } else {
                if (bh.errorMsgs.indexOf('highestEndNotHighestStart') >= 0) {
                    bh.errorMsgs.splice(bh.errorMsgs.indexOf('highestEndNotHighestStart'), 1);
                }
            }
        }

        if (!currentRec.rangeEnd || currentRec.rangeEnd.length === 0) {
            bh.currentRunLogs.push('REMOVE FALSE POSITIVE endIsLessThanStart highestEndNotHighestStart');
            //-- if field now blank remove false positive
            if (bh.errorMsgs.indexOf('endIsLessThanStart') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('endIsLessThanStart'), 1);
            }
            if (bh.errorMsgs.indexOf('highestEndNotHighestStart') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('highestEndNotHighestStart'), 1);
            }  
        } else {
            bh.currentRunLogs.push('OTHER ROWS WITH A HIGHER START AND BLANK END?');
            bh.currentRunLogs.push(currentRec);
            bh.currentRunLogs.push(currentRec.rangeEnd);
            bh.currentRunLogs.push('currentRec.rangeEnd.length ' + currentRec.rangeEnd.length);
            //-- Are there other records that have a higher start point and blank end?
            //-- TODO: If the validator ran on every other row when you change one input this would be redundant...
            //--        although more intensive? 
            for (var r = 0; r < related.length; r++) {
                if (related[r].rangeEnd.length === 0) {
                    if (related[r].rangeStart > currentRec.rangeStart) {
                        if (bh.errorMsgs.indexOf('highestEndNotHighestStart') >= 0) {
                            bh.errorMsgs.splice(bh.errorMsgs.indexOf('highestEndNotHighestStart'), 1);
                        }  
                    }
                }
            }
        }

        bh.checkError();
    },
    numberInComflict: function(list){
        var inConflict = false; 
        for(var i=0; i< list.length; i++){
            if(list[i]){
                if(i == list.length){
                    return; 
                }
                if(list[i] > list[i+1] ){
                    inConflict = true;
                }
            }
        }

        return isConflict; 
    },
    secondMaxInArray: function(arr){ 
        var filteredList = [];

        arr.forEach(function(n){
          console.log(parseInt(n));
          var num = parseInt(n);
          if(isNaN(num)){
            
          }else{
            filteredList.push(num);
          }
        })

        var listArr = filteredList;

        var max = Math.max.apply(null, listArr);
        listArr.splice(arr.indexOf(max), 1); 
        return Math.max.apply(null, listArr); 
    },
    numberInRange: function(relatedStart, relatedEnd, newStart) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' numberInRange');
        return parseInt(relatedStart) <= parseInt(newStart) && parseInt(newStart) >= parseInt(relatedEnd);
    },
    filterOutCommas: function(amended) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' filterOutCommas');

        if (amended.rangeStart && amended.rangeStart.indexOf(',') >= 0) {
            amended.rangeStart = amended.rangeStart.replace(/,/g,'');
        } 

        if (amended.rangeEnd && amended.rangeEnd.indexOf(',') >= 0) {
            amended.rangeEnd =  amended.rangeEnd.replace(/,/g,'');
        } 
        
        return amended;            
    },
    checkHighestEndPoint: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkHighestEndPoint');

        var amended = {};
        var errorMsgs = [];
        var highestStart, tmp;
        var bonusRec = {};
        var related = bh.relatedBonusRecs;
        var startPoints = [];

        //--    When a Retro-type Bonus is defined, if the record with the highest Begin Point 
        //--        (and same Bonus Base, Type, and Apply To values) 
        //--    has a defined End Point, then the user is prompted and prevented from saving
        for (var ii = 0; ii < related.length; ii++) {
            if (parseInt(related[ii].rangeStart)) {
                startPoints.push(parseInt(related[ii].rangeStart));
            }
        }

        if (startPoints.length > 0) {
            highestStart = Math.max.apply(Math, startPoints);
        } else {
            highestStart = 0;
        }

        if (highestStart) {
            tmp = startPoints.indexOf(highestStart);
            bonusRec = related[tmp];
        } else {
            bonusRec = bh.getCurrentRec();
        }

        if (bonusRec && 
                (bonusRec.Type__c === 'Retro' && bh.fieldInfo.uniqueness === 'copromoter') ||
                (bonusRec.Type__c === 'Retro' && bh.fieldInfo.uniqueness === 'artistdeal') ||
                (bh.fieldInfo.uniqueness === 'artistretro')
                //(bh.retroDealType === 'Retro Gross Deal' || bh.retroDealType === 'Retro Net Deal' && bh.fieldInfo.uniqueness === 'artistretro') 
            ) 
        {
            

            if (bonusRec && bonusRec.rangeEnd) {
                bh.currentRunLogs.push(bonusRec.rangeEnd);
                bh.currentRunLogs.push(parseInt(bonusRec.rangeEnd));
            }

            //-- check it has no end point entered
            if (bonusRec && bonusRec.rangeEnd && parseInt(bonusRec.rangeEnd) > 0) {
                bh.currentRunLogs.push('bonusRec.rangeEnd is ' + bonusRec.rangeEnd);
                if (bh.errorMsgs.indexOf('endNotBlank') < 0) {
                    bh.errorMsgs.push('endNotBlank');
                    bh.currentRunLogs.push('adding endNotBlank error');
                }
            } else {
                bh.currentRunLogs.push('bonusRec.rangeEnd cannot be deteremined');
                if (bh.errorMsgs.indexOf('endNotBlank') >= 0) {
                    bh.errorMsgs.splice(bh.errorMsgs.indexOf('endNotBlank'), 1);
                    bh.currentRunLogs.push('removed endNotBlank error');
                }
            }
        } 

        bh.checkForMultipleBlankEndPoints();

    },
    countInArray: function(dataset,search){
        var count = dataset.reduce(function(n, val) {
              return n + (val === search);
        }, 0);
        return count; 
    },
    checkForMultipleBlankEndPoints: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkForMultipleBlankEndPoints');

        var amended = {};
        var currentRec = bh.getCurrentRec();
        var errorMsgs = [];
        var highestStart, tmp;
        var bonusRec = {};
        var endPoints = [];
        var related = bh.relatedBonusRecs;
        var startPoints = [];

        for (var ii = 0; ii < related.length; ii++) {
            if (parseInt(related[ii].rangeStart)) {
                startPoints.push(parseInt(related[ii].rangeStart));
            }
            if (related[ii].rangeEnd && parseInt(related[ii].rangeEnd)) {
                endPoints.push(parseInt(related[ii].rangeEnd));
            } else if (related[ii] && related[ii].rangeEnd === '') {
                bh.currentRunLogs.push('IS BLANK!');
                endPoints.push('blank');
            }
        }

       

        if (endPoints.indexOf('blank') >= 0 && !currentRec.rangeEnd) {
            //Only push end not there message when its there's more than 1 blank Cont for artist retro and artistdeal && type =retro
            if (bh.fieldInfo.uniqueness == 'artistretro' || bh.fieldInfo.uniqueness == 'artistdeal' || bh.fieldInfo.uniqueness == 'copromoter' && (related[0].Type__c== "Retro" || related[0].Type__c== "Step Up" ) ){
                var blankCount = bh.countInArray(endPoints,"blank");
                if(blankCount >= 2){
                    bh.errorMsgs.push('endMultipleBlanks');
                } 
            }else if(bh.errorMsgs.indexOf('endMultipleBlanks') === -1 ){
                bh.errorMsgs.push('endMultipleBlanks');
            }
        } else {
            if (bh.errorMsgs.indexOf('endMultipleBlanks') >= 0) {
                bh.currentRunLogs.push('found endMultipleBlanks in errorMsgs removing it');
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('endMultipleBlanks'), 1);
            }
        }

        if (!currentRec.rangeEnd && bh.errorMsgs.indexOf('endMultipleBlanks') === -1) {
            if (bh.errorMsgs.indexOf('endNotBlank') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('endNotBlank'), 1);
            }
        }

        bh.currentRunLogs.push('at end of checkForMultipleBlankEndPoints bh.errorMsgs is');
        bh.currentRunLogs.push(bh.errorMsgs);

        bh.checkError(); 
    },
    newBonusDetailPrefill: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' newBonusDetailPrefill');
        var fieldDetail = bh.fieldInfo.fields;
        var $cells, newValues;

        for (var i = 0; i < bh.$rows.length; i++){
            c = i + 1;

            $cells = jq(bh.$rows[i]).find('td');

            if (i === 1) {
                newValues = bh.popNewValuesArray($cells);
                //--filter out empty row
                //-- make sure starting point is 0
                if (newValues[0] && newValues[1] && !newValues[parseInt(fieldDetail.rangeStart.order)]) {
                    newValues[parseInt(fieldDetail.rangeStart.order)] = 0;
                }
            }
        }

        if (newValues) {
            $cells = jq(bh.$rows[0]).find('td');
            bh.updateMarkupDefaultValues($cells, newValues);
        } else {
            bh.currentRunLogs.push('newValues not set');
        }
    },
    popBonusRecordsArray: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' popBonusRecordsArray');
        var $cells, obj;
        bh.anyBonusRecs = [];

        for (var i = 0; i < bh.$rows.length; i++) {
            $cells = jq(bh.$rows[i]).find('td');
            obj = bh.popBonusRecordsObj($cells);
            obj = bh.filterOutCommas(obj);
            bh.anyBonusRecs.push(obj);                
            obj = {};
        }
    },
    popRelatedBonusRecordsArray: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' popRelatedBonusRecordsArray');

        var anyBonusRecs = [];
        var $cells;
        var currentRec = bh.getCurrentRec();
        var focus;
        var rec;
        var related = [];
        var $rows;
        var uniqueness = bh.fieldInfo.uniqueness;

        $rows = bh.$rowsParent.find('tr.dr:not(.none)');

        for (var ii = 0; ii < $rows.length; ii++) {
            //populated anyBonus recs 
            $cells = jq($rows[ii]).find('td');
            rec = bh.popBonusRecordsObj($cells);
            anyBonusRecs.push(rec);
        }

        for (var i = 0; i < anyBonusRecs.length; i++) {
            rec = bh.filterOutCommas(anyBonusRecs[i]);
            anyBonusRecs[i] = rec;

            bh.currentRunLogs.push('anyBonusRecs loop i ' + i);
            //-- same uniqueness as new entry? 
            //-- push to array
            if (uniqueness === 'copromoter') {
                if (currentRec.BonusBase__c == anyBonusRecs[i].BonusBase__c && 
                        currentRec.Type__c == anyBonusRecs[i].Type__c) 
                {
                    related.push(anyBonusRecs[i]);
                }
            } else if (uniqueness === 'artistdeal') {
                if (currentRec.BonusBase__c == anyBonusRecs[i].BonusBase__c && 
                        currentRec.Type__c == anyBonusRecs[i].Type__c &&
                        currentRec.ApplyTo__c == anyBonusRecs[i].ApplyTo__c ) 
                {
                    related.push(anyBonusRecs[i]);
                }
            } else if (uniqueness === 'artistretro') {
                related.push(anyBonusRecs[i]);
            }
        }


        bh.relatedBonusRecs = related;
        bh.currentRunLogs.push('bh.relatedBonusRecs set to at exit of popRelatedBonusRecordsArray');
        bh.currentRunLogs.push(bh.relatedBonusRecs);
    }, 
    updateMarkupDefaultValues: function($cells, newValues) {
        //Updates the properties of the dropdowns on prefill 
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' updateMarkupDefaultValues');
        var fieldInfo = bh.fieldInfo.fields;
        var highestStart, highestStartIndex, index, int, newStart, startPoints;
        highestStart = 0;
        int = 0;
        startPoints = [];

        for (var prop in fieldInfo) {
            if (fieldInfo.hasOwnProperty(prop)) {
                fieldDetail = fieldInfo[prop];
                index = parseInt(fieldDetail.order);

                if (newValues[index] !== null && newValues[index] !== '-' && fieldDetail.prepop === 'true') {
                    if (fieldDetail.type === 'drop') {
                        if (jq($cells[0]).find('.icon-ellipses').length > 0) {
                            jq($cells[parseInt(fieldDetail.order)]).change();
                            jq($cells[parseInt(fieldDetail.order)]).find('select').val(newValues[index]);
                            jq($cells[parseInt(fieldDetail.order)]).change();
                        } else {
                            jq($cells[parseInt(fieldDetail.order)]).find('select').val(newValues[index]);
                            jq($cells[parseInt(fieldDetail.order)]).find('select').change();
                        }
                    } else {
                        jq($cells[parseInt(fieldDetail.order)]).find('input').val(newValues[index]);
                        jq($cells[parseInt(fieldDetail.order)]).find('input').change();
                    }
                }
            }
        }

        if (fieldInfo.rangeStart.prepop === 'calc') {
            bh.currentRunLogs.push('CALC');
            bh.currentRunLogs.push(bh.relatedBonusRecs);
            //-- if new record has other rows with same base + type, find max start of that
            for (var ii = 0; ii < bh.relatedBonusRecs.length; ii++) {
                int = parseInt(bh.relatedBonusRecs[ii].rangeStart);
                startPoints.push(int);
            }
            
            if (startPoints.length > 0) {
                highestStart = Math.max.apply(Math, startPoints.filter(function(n) { return !isNaN(n); }));
            } else {
                highestStart = startPoints[0] || null;
            }

            highestStart = highestStart ? highestStart : 0;
            bh.currentRunLogs.push('highestStart is ' + highestStart);
            
            for (ii = 0; ii < bh.relatedBonusRecs.length; ii++) {
                if (parseInt(bh.relatedBonusRecs[ii].rangeStart) === parseInt(highestStart)) {
                    if (parseInt(bh.relatedBonusRecs[ii].rangeEnd)) {
                        newStart = parseInt(bh.relatedBonusRecs[ii].rangeEnd) + 1;
                        jq($cells[parseInt(fieldInfo.rangeStart.order)]).find('input').val(newStart);
                        jq($cells[parseInt(fieldInfo.rangeStart.order)]).find('input').change();
                    } 
                }
            }
        }
    },
    extractFromMarkup: function($cells) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' extractFromMarkup');
        var bonusRec = {};
        var fieldInfo = bh.fieldInfo.fields;
        var fieldOrder;
        var value;

        for (var prop in fieldInfo) {
            if (fieldInfo.hasOwnProperty(prop)) {
                fieldDetail = fieldInfo[prop];
                fieldOrder = fieldDetail.order;

                if (fieldDetail.type === 'drop') {
                    if (jq($cells[0]).find('.icon-ellipses').length > 0) {
                        value = jq($cells[parseInt(fieldOrder)]).find('.plTxt').text();
                        if (!value) {
                            bh.currentRunLogs.push('DID NOT FIND VALUE IN PLTXT TRYING SELECT');
                            value = jq($cells[parseInt(fieldOrder)]).find('select').val();
                        }
                    } else {
                        value = jq($cells[parseInt(fieldOrder)]).find('select').val();
                    }
                } else {
                    value = jq($cells[parseInt(fieldOrder)]).find('input').val();
                }

                bonusRec[prop] = value;
            }
        }

        return bonusRec;
    },
    popBonusRecordsObj: function($cells) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' popBonusRecordsObj');
        var bonusRec = bh.extractFromMarkup($cells);
        return bonusRec;
    },
    popNewValuesArray: function($cells) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' popNewValuesArray');
        var bonusRec = {};
        var fieldInfo = bh.fieldInfo.fields;
        var index = 0;
        var length = 0;
        var newValues;
        
        for (var prop in fieldInfo) {
            if (fieldInfo.hasOwnProperty(prop)) {
                length++;
            }
        }
        newValues = new Array(length + 1);
        newValues[0] = '-';

        bonusRec = bh.extractFromMarkup($cells);
        
        for (var prop in bonusRec) {
            if (bonusRec.hasOwnProperty(prop)) {
                index = fieldInfo[prop].order;
                newValues[parseInt(index)] = bonusRec[prop];
            }
        }
        return newValues;
    },
    checkError: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkError');

        if (bh.errorMsgs.length > 0) {
            bh.stopSave();
        } else {
            bh.allowSave();
        }
    },
    stopSave: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' stopSave');

        var shortGridName = bh.fieldInfo.shortGridName;
        var errorMsgs = bh.errorMsgs;
        var errorBoxSel = '.fe-injected-validation-' + shortGridName;
        var markup = '';
        var parent, pWithStyle, save;
        
        //jq(bh.$currentRow).attr('style','border: solid 2px red;');

        //-- now using bh.$branch
        //parent = jq('#gbMainTable').find('.crDataContainer').first();
        
        jq(errorBoxSel).remove();

        //-- Main error container
        markup += '<div class="fe-injected-validation fe-injected-validation-' + shortGridName +' hide"> ';
        markup += '<p>Please correct the following issues in the <span style="font-weight: 800;">';
        markup += bh.fieldInfo.humanGridName + '</span> grid to allow saving of your work.</p>';
        
        //-- Add individual errors
        pWithStyle = '<p class="error">';
        for (var i = 0; i < errorMsgs.length; i++) {

            if (errorMsgs[i] === 'endIsLessThanStart') {
                markup += pWithStyle + 'End point less than start point' + '</p>';
            }
            if (errorMsgs[i] === 'overlap') {
                markup += pWithStyle + 'Overlapping start and end points' + '</p>';
            }
            if (errorMsgs[i] === 'endNotBlank') {
                if (shortGridName == 'retro') {
                    markup += pWithStyle + 'Highest tier of the retro deal must have a blank Ending Range so the max is met' + '</p>';
                } else {
                    markup += pWithStyle + 'Highest tier of the bonus must have a blank End Point so the max is met' + '</p>'; 
                }
            }
            if (errorMsgs[i] === 'endMultipleBlanks') {
                markup += pWithStyle + 'Please ensure only the highest tier of the bonus has a blank End Point ';
                markup += '</p>';
            }
            if (errorMsgs[i] === 'startBlank') {
                markup += pWithStyle + 'Each start point must be entered' + '</p>';
            }
            if (errorMsgs[i] === 'startAndEndMatch') {
                markup += pWithStyle + 'The start and end range cannot match' + '</p>';
            }
            if (errorMsgs[i] === 'highestEndNotHighestStart') {
                markup += pWithStyle + 'Only the tier with the highest start range can have the highest end range' + '</p>';
            }
            if (errorMsgs[i] === 'mustbeContinuous') {
                markup += pWithStyle + 'Start Range must be continous from previous Ending Range' + '</p>';
            }
        }

        //-- CLose main error container
        markup += '<input class="fe-injected-validation-' +  shortGridName + '-anchor" style="display: none;" /></div>';

        //-- Add to page
        //--         jq(parent).append(jq(markup));
        bh.$branch.append(jq(markup));
        
        //-- Add error marking to save
        jq('body .gridBtns').find('.saveBtn:not(.none)').first().attr('style','border: 2px solid red;');
        bh.prepLogs();

        if (bh.showingError) {
            jq(errorBoxSel).removeClass('hide').addClass('show');
        }
    },
    allowSave: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' allowSave');
        bh.errorMsgs = [];
        var shortGridName = bh.fieldInfo.shortGridName;
        var errorBoxSel = '.fe-injected-validation-' + shortGridName;

        for (var i = 0; i < bh.$rows.length; i++) {
            jq(bh.$rows[i]).attr('style','border: none;');
        }

        jq(errorBoxSel).remove();
        jq('#fe-cannot-save').removeClass('show').addClass('hide');
        jq('body .gridBtns').find('.saveBtn:not(.none)').first().attr('style','border: none;');
        bh.showingError = false;
        bh.prepLogs();
    },
    prepLogs: function() {
        var bh = this;
        bh.lneBonusHelperLogs.push('OP START ' + new Date().toString());
        for (var i = 0; i < bh.currentRunLogs.length; i++) {
            bh.lneBonusHelperLogs.push(bh.currentRunLogs[i]);
            console.log(bh.currentRunLogs[i]);
        }
        bh.currentRunLogs = [];
    }
};


