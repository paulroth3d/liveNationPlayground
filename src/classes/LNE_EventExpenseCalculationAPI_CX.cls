/**
 *  Controller for the Example JSONP endpoint to perform an API request.
 *  <p>For more information, see page 10 of the GridBuddyCustomizationGuide</p>
 *  @author Daniel Nakonieczny
 *  @param GET callback (String) - name of the JSONP function to call on success.
 *  @param POST callback (String) - name of the JSONP function to call on success.
 *  @param POST LedgerEntry__c (Object) - LedgerEntry object.
 *      Id (Id)
 *      RateType__c (String)
 *      BaseAmount__c (float)
 *  @return (JSONP)
 *      Id (Id)
 *      RateType__c (String)
 *      BaseAmount__c (float)
 *      GrossRevenue__c (float)
**/

public with sharing class LNE_EventExpenseCalculationAPI_CX {

    public static final string DELIMITER = DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;

    /** SUCCESS STATUS **/
    public static final string STATUS_SUCCESS = 'success';
    /** FAILURE STATUS **/
    public static final string STATUS_FAILURE = 'failure';
    
    /** Default name of the function to call for jsonpResults **/
    public static final string DEFAULT_JSONP_CALLBACK='testApiCallback2';
    
    /** parameter - defines the name of the jsonp function to call on results **/
    public static final string PARAM_JSONP_CALLBACK='callback';
    /** parameter - defines the LedgerEntry with the parameters sent **/
    public static final string PARAM_LEDGER_ENTRY='LedgerEntry__c';
    public static final string PARAM_LEDGER_ENTRY_BREAKOUT='LedgerEntryBreakout__c';
    
    public static final string API_NAME = 'LNE_TestGridBuddyAPI-test';
    
    /** name of the jsonp callback to execute **/
    public String jsonpCallback {get; private set;}
    
    /** Response String **/
    public String jsonResponse {get; private set;}
    
    /** Custom settings instance **/
    private static final GeneralSettings__c GENERAL_SETTINGS = GeneralSettings__c.getInstance();
    
    public LNE_EventExpenseCalculationAPI_CX(){
        this.jsonpCallback = DEFAULT_JSONP_CALLBACK;
        this.jsonResponse = '';
    }

    /**
     *  Actual endpoint code.
     *  Get EVERYTHING from the Ledger Entry
     *  and update Everything back on the same record
    **/
    public void processRequest(){
        ResponseMessage response = new ResponseMessage( API_NAME );

        try {
            Map<String,String> params = ApexPages.currentPage().getParameters();
            
            //-- in case its ever needed, debug all params sent
            /*if( false ){
                response.message = '';
                for( string keyName : params.keySet() ){
                    response.message += 'KeyName†' + keyName + '†\nvalue‡' + params.get(keyName) + '‡\n\n';
                }
                return;
            }*/
            
            //-- allow the script to say the name of the callback
            if( params.containsKey( PARAM_JSONP_CALLBACK )){
                this.jsonpCallback = params.get( PARAM_JSONP_CALLBACK );
                System.debug( 'jsonpCallback:' + this.jsonpCallback );
            }
            System.debug(params.get(PARAM_LEDGER_ENTRY_BREAKOUT));
            System.debug(params.get(PARAM_LEDGER_ENTRY));
            if(params.get(PARAM_LEDGER_ENTRY) != null){
            string ledgerJSON = params.get( PARAM_LEDGER_ENTRY );
            //System.debug( 'ledgerJSON:' );
            //System.debug( ledgerJSON );
            
            //-- @TODO: review why this doesn't work.
            //http://salesforce.stackexchange.com/questions/7523/what-is-the-correct-json-to-deserialize-a-map-of-sobjects
            LedgerEntry__c ledgerEntry = (LedgerEntry__c)JSON.deserialize( ledgerJSON, LedgerEntry__c.class );
            System.debug( 'ledgerEntry' ); System.debug( ledgerEntry );
            //-- #  #   #   #   #   #   #   #   #   #   #   #   #   #   #   #
            
            //-- Logic specific for this API
            updateLedgerEntry( ledgerEntry );
            System.debug( 'ledgerEntry2' ); System.debug( ledgerEntry );
            
            //--    #   #   #   #   #   #   #   #   #   #   #   #   #   #   #
            
            response.data = ledgerEntry;
            }else if(params.get(PARAM_LEDGER_ENTRY_BREAKOUT) != null){
                string ledgerJSON = params.get( PARAM_LEDGER_ENTRY_BREAKOUT );
            //System.debug( 'ledgerJSON:' );
            //System.debug( ledgerJSON );
            
            //-- @TODO: review why this doesn't work.
            //http://salesforce.stackexchange.com/questions/7523/what-is-the-correct-json-to-deserialize-a-map-of-sobjects
            LedgerEntryBreakout__c ledgerEntry = (LedgerEntryBreakout__c)JSON.deserialize( ledgerJSON, LedgerEntryBreakout__c.class );
            System.debug( 'ledgerEntryBreakout' ); System.debug( ledgerEntry );
            //-- #  #   #   #   #   #   #   #   #   #   #   #   #   #   #   #
            
            //-- Logic specific for this API
            updateLedgerEntryBreakout( ledgerEntry );
            System.debug( 'ledgerEntryBreakout2' ); System.debug( ledgerEntry );
            
            //--    #   #   #   #   #   #   #   #   #   #   #   #   #   #   #
             response.data = ledgerEntry;
            }
            
        
        
        } catch( Exception err ){
            response.isSuccessful = false;
            String errorMessage = err.getMessage();
            
            //-- @TODO: cleanup. we shouldn't show dev errors.
            
            if (GENERAL_SETTINGS.DebugAPI__c == true) {
                errorMessage += '\n\n' +err.getStackTraceString();
            }
            
            response.message = errorMessage;
        }
        
        //-- @TODO: review how to make this work.
        //-- the sub objects are always treated as a doubly encoded string.
        //this.jsonResponse = JSON.serialize( response );
        JSONGenerator generator = JSON.createGenerator(true);
        response.toJSON( generator );
        this.jsonResponse = generator.getAsString();
    }

    /**
     *  THE LOGIC SPECIFIC FOR THIS API, all the stuff above is more or less boilerplate.
    **/
    private void updateLedgerEntry( LedgerEntry__c ledgerEntry ){
        
        System.debug( 'updateLedgerEntry' ); System.debug( ledgerEntry );



        // TODO: MOVE TO A SEPARATE CLASS (or use LNE_LedgerEntryFieldCalculationLogic)

        LedgerEntry__c savedLedgerEntry = [SELECT Id, TicketScaleList__c, Event__c FROM LedgerEntry__c WHERE Id =:ledgerEntry.Id];
        List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>(); // SW 21/02/17: this doesnt look to be used
        if(savedLedgerEntry.TicketScaleList__c != null){
           String[] listOfTicketScaleIds = savedLedgerEntry.TicketScaleList__c.split('\\' + DELIMITER);
            //if(Test.isRunningTest()){
            //    listOfTicketScaleIds = savedLedgerEntry.TicketScaleList__c.split('\\|');
            //}
            listOfTicketScales = [SELECT Id, ProjectedPaidTickets__c, Comps__c, Event__c FROM TicketScale__c WHERE Id IN :listOfTicketScaleIds];     
        }
        Event__c relatedEvent = [SELECT NumberofTrucks__c,
                                        SelloutDropCount__c,
                                        SelloutPaidTickets__c,
                                        NetGrossPotential__c,
                                        GrossPotential__c,
                                        AdjustedGrossPotential__c,
                                        ProjectedDropCount__c,
                                        ProjectedPaidTickets__c,
                                        ProjectedNetGross__c,
                                        ProjectedGross__c,
                                        ProjectedAdjustedGross__c
                                 FROM Event__c
                                 WHERE Id =:savedLedgerEntry.Event__c ];
        
        /*
        if( relatedEvent == null ){
            throw( new CustomException( ERR_NO_RELATED_EVENT ));
        }
        */

        LNE_FinancialCalculator.expenseCalculation(new LNE_FinancialCalculator.LNE_Event(relatedEvent), ledgerEntry);

        //String rateType = ledgerEntry.OfferRateType__c;
        //String inHouseRateType = ledgerEntry.InHouseRateType__c;
        //ledgerEntry.OfferAtSellout__c = null;
        //ledgerEntry.OfferAtProjection__c = null;

        //if (ledgerEntry.OfferRate__c == 0) {
        //    ledgerEntry.OfferAtSellout__c = 0;
        //    ledgerEntry.OfferAtProjection__c = 0;
        //}
        
        //if (ledgerEntry.InHouseRate__c == 0) {
        //    ledgerEntry.InHouseProjection__c = 0;
        //}
        
        //if (ledgerEntry.OfferRate__c != null) {
        //    if (rateType == 'Flat') {
        //        ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c;
        //        ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c;
        //    } else if (relatedEvent != null) {
        //        if (rateType == 'Per Truck' && relatedEvent.NumberofTrucks__c != null) {
        //            ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c * relatedEvent.NumberofTrucks__c;
        //            ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c * relatedEvent.NumberofTrucks__c;
        //        } else if (rateType == 'Per Drop Count') {
        //            if (relatedEvent.SelloutDropCount__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c * relatedEvent.SelloutDropCount__c;    
        //            }

        //            if (relatedEvent.ProjectedDropCount__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c * relatedEvent.ProjectedDropCount__c;   
        //            }
        //        } else if (rateType == 'Per Paid Ticket') {
        //            if (relatedEvent.SelloutPaidTickets__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c * relatedEvent.SelloutPaidTickets__c;  
        //            }

        //            if (relatedEvent.ProjectedPaidTickets__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c * relatedEvent.ProjectedPaidTickets__c;
        //            }
        //        } else if (rateType == '% of Net Gross') {
        //            if (relatedEvent.NetGrossPotential__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.NetGrossPotential__c; 
        //            }

        //            if (relatedEvent.ProjectedNetGross__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.ProjectedNetGross__c;
        //            }
        //        } else if (rateType == '% of Gross') {
        //            if (relatedEvent.GrossPotential__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.GrossPotential__c;    
        //            }

        //            if (relatedEvent.ProjectedGross__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.ProjectedGross__c; 
        //            }
        //        } else if (rateType == '% of Adjusted Gross') {
        //            if (relatedEvent.AdjustedGrossPotential__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.AdjustedGrossPotential__c;    
        //            }

        //            if (relatedEvent.ProjectedAdjustedGross__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.ProjectedAdjustedGross__c; 
        //            }
        //        }
        //    } 
        //}

        //ledgerEntry.InHouseProjection__c = null;

        //if (ledgerEntry.InHouseRate__c != null) {
        //    if (inHouseRateType == 'Flat') {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c;
        //    } else if (inHouseRateType == 'Per Truck' && relatedEvent.NumberofTrucks__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c * relatedEvent.NumberofTrucks__c;
        //    } else if (inHouseRateType == 'Per Drop Count' && relatedEvent.ProjectedDropCount__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c * relatedEvent.ProjectedDropCount__c;
        //    } else if (inHouseRateType == 'Per Paid Ticket' && relatedEvent.ProjectedPaidTickets__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c * relatedEvent.ProjectedPaidTickets__c;
        //    } else if (inHouseRateType == '% of Net Gross' && relatedEvent.ProjectedNetGross__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c / 100 * relatedEvent.ProjectedNetGross__c;
        //    } else if (inHouseRateType == '% of Gross' && relatedEvent.ProjectedGross__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c / 100 * relatedEvent.ProjectedGross__c;
        //    } else if (inHouseRateType == '% of Adjusted Gross' && relatedEvent.ProjectedAdjustedGross__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c / 100 * relatedEvent.ProjectedAdjustedGross__c;
        //    }
        //}

        //ledgerEntry.ExpenseAdjustment__c = null;

        //if (ledgerEntry.SettleAtActual__c == true) {
        //    ledgerEntry.ExpenseAdjustment__c = 0;
        //} else if (ledgerEntry.OfferAtProjection__c != null && ledgerEntry.InHouseProjection__c != null) {
        //    ledgerEntry.ExpenseAdjustment__c = ledgerEntry.OfferAtProjection__c - ledgerEntry.InHouseProjection__c;
        //}
        
        //// If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        ////-- US473 - verify this works.
        
        ////Offer min/max
        //if(ledgerEntry.OfferMin__c != null && ledgerEntry.OfferMin__c > 0){
        //    if (ledgerEntry.OfferAtSellout__c != null && ledgerEntry.OfferAtSellout__c < ledgerEntry.OfferMin__c) {
        //        ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferMin__c;
        //    }
            
        //    if (ledgerEntry.OfferAtProjection__c != null && ledgerEntry.OfferAtProjection__c < ledgerEntry.OfferMin__c) {
        //        ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferMin__c;
        //    }
        //}
        
        //if(ledgerEntry.OfferMax__c != null && ledgerEntry.OfferMax__c > 0){
        //    if (ledgerEntry.OfferAtSellout__c != null && ledgerEntry.OfferAtSellout__c > ledgerEntry.OfferMax__c) {
        //        ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferMax__c;
        //    }
            
        //    if (ledgerEntry.OfferAtProjection__c != null && ledgerEntry.OfferAtProjection__c > ledgerEntry.OfferMax__c) {
        //        ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferMax__c;
        //    }
        //}
        
        
        ////In House min/max
        //if(ledgerEntry.InHouseMin__c != null && ledgerEntry.InHouseMin__c > 0){
        //    if (ledgerEntry.InHouseProjection__c != null && ledgerEntry.InHouseProjection__c < ledgerEntry.InHouseMin__c) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseMin__c;
        //    }
        //}
        
        //if(ledgerEntry.InHouseMax__c != null && ledgerEntry.InHouseMax__c > 0){
        //    if (ledgerEntry.InHouseProjection__c != null && ledgerEntry.InHouseProjection__c > ledgerEntry.InHouseMax__c) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseMax__c;
        //    }
        //}

        //LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntry);
        System.debug( 'updateLedgerEntry' ); System.debug( ledgerEntry );
    }
    
    private void updateLedgerEntryBreakout( LedgerEntryBreakout__c ledgerEntry ){
        
        System.debug( 'updateLedgerEntryBreakout' ); System.debug( ledgerEntry );



        // TODO: MOVE TO A SEPARATE CLASS (or use LNE_LEBreakoutCalculationLogic)

        LedgerEntryBreakout__c savedLedgerEntry = [SELECT Id, TicketScaleList__c, LedgerEntry__c FROM LedgerEntryBreakout__c WHERE Id =:ledgerEntry.Id];
        LedgerEntry__c ledgerEntryGL = [SELECT Id, Event__c FROM LedgerEntry__c WHERE Id =:savedLedgerEntry.LedgerEntry__c];
        List<TicketScale__c> listOfTicketScales = new List<TicketScale__c>(); // SW 21/02/17: this doesnt look to be used
        if(savedLedgerEntry.TicketScaleList__c != null){
           String[] listOfTicketScaleIds = savedLedgerEntry.TicketScaleList__c.split('\\' + DELIMITER);
            if(Test.isRunningTest()){
                listOfTicketScaleIds = savedLedgerEntry.TicketScaleList__c.split('\\|');
            }
            listOfTicketScales = [SELECT Id, ProjectedPaidTickets__c, Comps__c, Event__c FROM TicketScale__c WHERE Id IN :listOfTicketScaleIds];     
        }
        Event__c relatedEvent = [SELECT NumberofTrucks__c,
                                        SelloutDropCount__c,
                                        SelloutPaidTickets__c,
                                        NetGrossPotential__c,
                                        GrossPotential__c,
                                        AdjustedGrossPotential__c,
                                        ProjectedDropCount__c,
                                        ProjectedPaidTickets__c,
                                        ProjectedNetGross__c,
                                        ProjectedGross__c,
                                        ProjectedAdjustedGross__c
                                 FROM Event__c
                                 WHERE Id =:ledgerEntryGL.Event__c ];
        
        /*
        if( relatedEvent == null ){
            throw( new CustomException( ERR_NO_RELATED_EVENT ));
        }
        */

        LNE_FinancialCalculator.expenseBreakoutCalculation(new LNE_FinancialCalculator.LNE_Event(relatedEvent), ledgerEntry);

        //String rateType = ledgerEntry.OfferRateType__c;
        //String inHouseRateType = ledgerEntry.InHouseRateType__c;
        //ledgerEntry.OfferAtSellout__c = null;
        //ledgerEntry.OfferAtProjection__c = null;

        //if (ledgerEntry.OfferRate__c == 0) {
        //    ledgerEntry.OfferAtSellout__c = 0;
        //    ledgerEntry.OfferAtProjection__c = 0;
        //}
        
        //if (ledgerEntry.InHouseRate__c == 0) {
        //    ledgerEntry.InHouseProjection__c = 0;
        //}
        
        //if (ledgerEntry.OfferRate__c != null) {
        //    if (rateType == 'Flat') {
        //        ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c;
        //        ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c;
        //    } else if (relatedEvent != null) {
        //        if (rateType == 'Per Truck' && relatedEvent.NumberofTrucks__c != null) {
        //            ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c * relatedEvent.NumberofTrucks__c;
        //            ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c * relatedEvent.NumberofTrucks__c;
        //        } else if (rateType == 'Per Drop Count') {
        //            if (relatedEvent.SelloutDropCount__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c * relatedEvent.SelloutDropCount__c;    
        //            }

        //            if (relatedEvent.ProjectedDropCount__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c * relatedEvent.ProjectedDropCount__c;   
        //            }
        //        } else if (rateType == 'Per Paid Ticket') {
        //            if (relatedEvent.SelloutPaidTickets__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c * relatedEvent.SelloutPaidTickets__c;  
        //            }

        //            if (relatedEvent.ProjectedPaidTickets__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c * relatedEvent.ProjectedPaidTickets__c;
        //            }
        //        } else if (rateType == '% of Net Gross') {
        //            if (relatedEvent.NetGrossPotential__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.NetGrossPotential__c; 
        //            }

        //            if (relatedEvent.ProjectedNetGross__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.ProjectedNetGross__c;
        //            }
        //        } else if (rateType == '% of Gross') {
        //            if (relatedEvent.GrossPotential__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.GrossPotential__c;    
        //            }

        //            if (relatedEvent.ProjectedGross__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.ProjectedGross__c; 
        //            }
        //        } else if (rateType == '% of Adjusted Gross') {
        //            if (relatedEvent.AdjustedGrossPotential__c != null) {
        //                ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.AdjustedGrossPotential__c;    
        //            }

        //            if (relatedEvent.ProjectedAdjustedGross__c != null) {
        //                ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferRate__c / 100 * relatedEvent.ProjectedAdjustedGross__c; 
        //            }
        //        }
        //    } 
        //}

        //ledgerEntry.InHouseProjection__c = null;

        //if (ledgerEntry.InHouseRate__c != null) {
        //    if (inHouseRateType == 'Flat') {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c;
        //    } else if (inHouseRateType == 'Per Truck' && relatedEvent.NumberofTrucks__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c * relatedEvent.NumberofTrucks__c;
        //    } else if (inHouseRateType == 'Per Drop Count' && relatedEvent.ProjectedDropCount__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c * relatedEvent.ProjectedDropCount__c;
        //    } else if (inHouseRateType == 'Per Paid Ticket' && relatedEvent.ProjectedPaidTickets__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c * relatedEvent.ProjectedPaidTickets__c;
        //    } else if (inHouseRateType == '% of Net Gross' && relatedEvent.ProjectedNetGross__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c / 100 * relatedEvent.ProjectedNetGross__c;
        //    } else if (inHouseRateType == '% of Gross' && relatedEvent.ProjectedGross__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c / 100 * relatedEvent.ProjectedGross__c;
        //    } else if (inHouseRateType == '% of Adjusted Gross' && relatedEvent.ProjectedAdjustedGross__c != null) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseRate__c / 100 * relatedEvent.ProjectedAdjustedGross__c;
        //    }
        //}

        //ledgerEntry.ExpenseAdjustment__c = null;

        //if (ledgerEntry.SettleAtActual__c == true) {
        //    ledgerEntry.ExpenseAdjustment__c = 0;
        //} else if (ledgerEntry.OfferAtProjection__c != null && ledgerEntry.InHouseProjection__c != null) {
        //    ledgerEntry.ExpenseAdjustment__c = ledgerEntry.OfferAtProjection__c - ledgerEntry.InHouseProjection__c;
        //}
        
        //// If the resulting Gross Revenue is below the min or above the max, it takes the value of those fields.
        ////-- US473 - verify this works.
        
        ////Offer min/max
        //if(ledgerEntry.OfferMin__c != null && ledgerEntry.OfferMin__c > 0){
        //    if (ledgerEntry.OfferAtSellout__c != null && ledgerEntry.OfferAtSellout__c < ledgerEntry.OfferMin__c) {
        //        ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferMin__c;
        //    }
            
        //    if (ledgerEntry.OfferAtProjection__c != null && ledgerEntry.OfferAtProjection__c < ledgerEntry.OfferMin__c) {
        //        ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferMin__c;
        //    }
        //}
        
        //if(ledgerEntry.OfferMax__c != null && ledgerEntry.OfferMax__c > 0){
        //    if (ledgerEntry.OfferAtSellout__c != null && ledgerEntry.OfferAtSellout__c > ledgerEntry.OfferMax__c) {
        //        ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferMax__c;
        //    }
            
        //    if (ledgerEntry.OfferAtProjection__c != null && ledgerEntry.OfferAtProjection__c > ledgerEntry.OfferMax__c) {
        //        ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferMax__c;
        //    }
        //}
        
        
        ////In House min/max
        //if(ledgerEntry.InHouseMin__c != null && ledgerEntry.InHouseMin__c > 0){
        //    if (ledgerEntry.InHouseProjection__c != null && ledgerEntry.InHouseProjection__c < ledgerEntry.InHouseMin__c) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseMin__c;
        //    }
        //}
        
        //if(ledgerEntry.InHouseMax__c != null && ledgerEntry.InHouseMax__c > 0){
        //    if (ledgerEntry.InHouseProjection__c != null && ledgerEntry.InHouseProjection__c > ledgerEntry.InHouseMax__c) {
        //        ledgerEntry.InHouseProjection__c = ledgerEntry.InHouseMax__c;
        //    }
        //}
        
        
        
        //LNE_LedgerEntryFieldCalculationLogic.calculateFieldsOnGrid(ledgerEntry);
        System.debug( 'updateLedgerEntry' ); System.debug( ledgerEntry );
    }


    /** internal class representing a response **/
    class ResponseMessage {
        boolean isSuccessful;
        String message;
        Object data;
        String api;
        
        ResponseMessage( String apiName ){
            this.api = apiName;
            this.isSuccessful = true;
        }
        
        void toJSON( JSONGenerator generator ){
            generator.writeStartObject();
            generator.writeBooleanField( 'isSuccessful', this.isSuccessful );
            generator.writeStringField( 'api', this.api );
            
            //-- this seems absolutely silly, but otherwise will get the following error
            //00:47:40.0 (11217688)|FATAL_ERROR|System.NullPointerException: null argument for JSONGenerator.writeStringField()
            if( this.message != null ){
                generator.writeStringField( 'message', this.message );
            } else {
                generator.writeNullField( 'message' );
            }
            
            if( this.data != null ){
                generator.writeObjectField( 'data', this.data );
            } else {
                generator.writeNullField( 'data' );
            }
            generator.writeEndObject();
        }
    }
}