/**
 *  Queueable class to 
 *  @author Vinay Kanuganti
 **/
public class LNE_FinancialCalculatorQueueable implements Queueable, Database.AllowsCallouts {
	
	//Set of event Ids to be processed for LE creation.
    private Set<Id> eventIDsToProcess {get; set;}
    //Used to specify the corresponding logic/method to be executed.
    private String actionType{get;Set;}
    private static String BUILD_AS_PROMOTEDSHOW = 'Build as a Promoted Show';
    private static String BUILD_AS_RENTAL = 'Build Using Rental Accounts';
    private static final string DEAL_PRIMARY_HEADLINER = 'Primary Headliner';
    private static final string DEAL_TYPE_CO_HEADLINER = 'Co-Headliner'; 

    private static final String RT_TICKET_REVENUE = 'LedgerEntry__c.TicketRevenue';
    private static final String RT_EXPENSES = 'LedgerEntry__c.Expenses';
    private static final String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
    private static final String RT_COGS = 'LedgerEntry__c.COGS';
    private static final String RT_CONTRA = 'LedgerEntry__c.Contra';
    private static final String RT_DEAL_ARTIST = 'Deal__c.Artist';
    private static final String RT_DEAL_COPROMOTER = 'Deal__c.CoPromoter';
    private static final String RT_BUYSELL = 'Event__c.BuySell';

    private static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
        new String[]{ RT_TICKET_REVENUE, RT_EXPENSES, RT_ANCILLARY, RT_COGS, RT_DEAL_ARTIST, RT_DEAL_COPROMOTER, RT_CONTRA, RT_BUYSELL}
    );

    private static Id RT_TICKET_REVENUE_ID = recordTypeMap.get( RT_TICKET_REVENUE );
    private static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    private static Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );
    private static Id RT_COGS_ID = recordTypeMap.get( RT_COGS );
    private static Id RT_CONTRA_ID = recordTypeMap.get( RT_CONTRA );
    private static Id RT_DEAL_ARTIST_ID = recordTypeMap.get( RT_DEAL_ARTIST );
    private static Id RT_DEAL_COPROMOTER_ID = recordTypeMap.get( RT_DEAL_COPROMOTER );
    private static Id RT_BUYSELL_ID = recordTypeMap.get( RT_BUYSELL );

    private static Map<String, Id> glAccountTypeToRecordTypeIdMap = new Map<String, Id>{'Ancillary' => RT_ANCILLARY_ID,
                                                                                         'COGS' => RT_COGS_ID,
                                                                                         'Ticket Revenue' => RT_TICKET_REVENUE_ID,
                                                                                         'Expenses' => RT_EXPENSES_ID,
                                                                                         'Contra' => RT_CONTRA_ID
                                                                                        };
    private static Map<String, Id> glAccountMap = new Map<String, Id>();
    /** Special Events Revenue - GL CODE **/
    public static final String SPECIAL_EVENTS_REVENUE_GL_CODE='40223';
    /** Booking Revenue - GL CODE **/
    public static final String BOOKING_GL_CODE='42019';

    private static Map<String,GLAccount__c> glAccountsMap = LNE_Util.getGLAccounts(new String[] {SPECIAL_EVENTS_REVENUE_GL_CODE,BOOKING_GL_CODE});

	public LNE_FinancialCalculatorQueueable(Set<Id> eventIDs, String actionType) {
		this.eventIDsToProcess = eventIDs;
		this.actionType = actionType;
	}

	/**
     * @Interface method. 
     * 
     **/
    public void execute(QueueableContext context) {
    	if(this.eventIDsToProcess != null){
    		//run the query for list of events
    		List<Event__c> events = [SELECT Id,
                                        AdjustedGrossPotential__c,
                                        GrossPotential__c,
                                        ProjectedAdjustedGross__c,
                                        ProjectedGross__c,
                                        ProjectedDropCount__c,
                                        SelloutDropCount__c,
                                        ProjectedDropCountPct__c,
                                        DropCountAdjustment__c,
                                        SelloutGrossSales__c,
                                        PlatinumLift__c,
                                        Status__c,
                                        NumberofTrucks__c,
                                        SelloutPaidTickets__c,
                                        UsingTicketFeed__c,
                                        ProjectedToBeSharedAmount__c,
                                        PotentialToBeSharedAmount__c,
                                        PotentialSplitPoint__c,
                                        ProjectedSplitPoint__c,
                                        ProjectedNetPot__c,
                                        NetPotPotential__c,
                                        ProjectedNetGross__c,
                                        Tour__c,
                                        SettlementDealType__c,
                                        SettlementDealCalculation__c,
                                        SettlementBackendPercentage__c,
                                        SettlementArtistSuppliedSL__c,
                                        SettlementGuarantee__c,
                                        SettlementOtherTalentAmount__c,
                                        StatusStage__c,
                                        Venue__r.OwnershipType__c,
                                        SettlementGrossSales__c,
                                        SettlementPaidTickets__c,
                                        ActualDropCount__c,
                                        SettlementNetGross__c,
                                        PaidAttendance__c,
                                        ShowCount__c,
                                        UsingMultiScale__c,
                                        RentalBuildOption__c,
                                        RecordTypeId, 
                                        TotalSupportActExpenses__c, 
                                        (SELECT Id,
                                                ProjectedPaidTickets__c,
                                                SellableCapacity__c,
                                                ProjectedGrossSales__c,
                                                LiftBeforeTaxes__c,
                                                GrossSales__c,
                                                BeforeAdjustedDeductions__c,
                                                PlatinumBeforeAdjustedDeductions__c,
                                                Comps__c,
                                                Type__c,
                                                StageType__c,
                                                ActualSalesToDate__c,
                                                ActualGrossToDate__c,
                                                MatchesEventStage__c
                                         FROM TicketScales__r),
                                         
                                         (SELECT Id
                                         FROM EventDateTimes__r),

                                        (SELECT Id,
                                                DeductionAtSellout__c,
                                                DeductionAtProjection__c,
                                                RateType__c,
                                                AmountRate__c,
                                                ApplyTicketScale__c,
                                                TicketScaleList__c,
                                                BeforeAfter__c,
                                                StageType__c,
                                                IncludeInAuditPrice__c,
                                                TotalBaseAmount__c,
                                                MatchesEventStage__c,
                                                Adjustment__c
                                         FROM Deductions__r
                                         WHERE BeforeAfter__c = 'Before Adjusted' OR
                                               BeforeAfter__c = 'After Adjusted'),

                                        (SELECT Id,
                                                GLAccount__c,
                                                GLAccount__r.GLCode__c,
                                                OfferAtSellout__c,
                                                OfferAtProjection__c,
                                                RecordTypeId,
                                                InHouseRate__c,
                                                InHouseRateType__c,
                                                InHouseMax__c,
                                                InHouseMin__c,
                                                InHouseatSellout__c,
                                                SettleAtActual__c,
                                                ExpenseAdjustmentatSellout__c,
                                                ExpenseAdjustment__c,
                                                BaseAmount__c,
                                                TicketScaleList__c,
                                                Min__c,
                                                Max__c,
                                                ContraAmount__c,
                                                RateType__c,
                                                ContraType__c,
                                                ApplyTicketScale__c,
                                                ContraPercent__c,
                                                X3rdPartyPercent__c,
                                                GrossRevenueatSellout__c,
                                                ContraatSellout__c,
                                                NetRevenueatSellout__c,
                                                ContraAtForecast__c,
                                                GrossRevenue__c,
                                                COGSAtSellout__c,
                                                COGSAtForecast__c,
                                                NetRevenue__c,
                                                PrimaryCoProShareAtProjection__c,
                                                PrimaryCoProShareAtSellout__c,
                                                EndofTourDinner__c,
                                                PerDiems__c,
                                                TE__c,
                                                TourRep__c,
                                                GLCode__c,
                                                MiscExpense__c,
                                                RollUpCount__c,
                                                Settlement__c,
                                                FlashRateAmount__c,
                                                FlashRateType__c,
                                                CurrentFlash__c,
                                                OfferRateType__c,
                                                OfferRate__c,
                                                OfferMin__c,
                                                OfferMax__c,
                                                InHouseProjection__c,
                                                GLAccount__r.RentalMap__c,
                                                GLAccountRelatedContra__c,
                                                ExternalId__c,
                                                PlanAmount__c,
                                                ProjectionAmount__c
                                         FROM LedgerEntries__r),

                                        (SELECT Id,
                                                InclusiveArtistExpensesPerDealCalc__c,
                                                PotentialInclusiveArtistExpenses__c,
                                                Event__c,
                                                EventProfit__c,
                                                EventLoss__c,
                                                ArtistWalkoutPotential__c,
                                                RollUpTalentOverheadAmount__c,
                                                ShareInTalentOverhead__c,
                                                ProjectedArtistWalkout__c,
                                                ProfitShareAmountAtSellout__c,
                                                ProfitShareAmountAtProjection__c,
                                                ExpenseAdjustmentShareAmountAtSell__c,
                                                ExpenseAdjustmentShareAmountAtProj__c,
                                                AncillaryShareAmountAtSellout__c,
                                                AncillaryShareAmountAtProjection__c,
                                                CoPromoterBonusAtSellout__c,
                                                CoPromoterBonusAtProjection__c,
                                                CoPromoterWalkoutAtSellout__c,
                                                CoPromoterWalkoutAtProjection__c,
                                                Type__c,
                                                PrimarySecondaryCoPromoter__c,
                                                GuaranteeAmount__c,
                                                ArtistSuppliedSL__c,
                                                OtherTalentAmount__c,
                                                DealType__c,
                                                BackendPercent__c,
                                                Rank__c,
                                                DealCalculation__c,
                                                StageType__c,
                                                RollUpBonusDetailsCount__c,
                                                ProjectedOverage__c,
                                                BackendPotential__c,
                                                SettlementBackend__c,
                                                ProjectedBackend__c,
                                                ArtistBackendCalculationPotential__c,
                                                ProjectedArtistBackendCalculation__c,
                                                SettlementArtistBackendCalculation__c,
                                                SplitBackendPercent__c,
                                                RecordTypeId
                                         FROM Deals__r),

                                        (SELECT Id,
                                                Event__c,
                                                RadioSpendPercent__c,
                                                DigitalSpendPercent__c,
                                                OutdoorSpendPercent__c,
                                                PrintSpendPercent__c,
                                                ProductionMiscellaneousSpendPercent__c,
                                                TelevisionSpendPercent__c,
                                                TourDigitalSpendPercent__c,
                                                TourOtherSpendPercent__c,
                                                LNEAdPlanBudget__c,
                                                RadioSpend__c,
                                                DigitalSpend__c,
                                                OutdoorSpend__c,
                                                PrintSpend__c,
                                                ProductionMiscellaneousSpend__c,
                                                TelevisionSpend__c,
                                                TourDigitalSpend__c,
                                                TourOtherSpend__c,
                                                LastModifiedDate  
                                        FROM AdPlans__r
                                        )

                                 FROM Event__c
                                 WHERE Id IN :eventIDsToProcess];

         	if(events != null && !events.isEmpty()){
         		if(this.actionType == 'RecalcuatePromotedSpecialLedgerEntry'){
         			recalcuatePromotedSpecialLedgerEntry(events);
         		}
         		if(this.actionType == 'RecalcuatePromotedShowLedgerEntries'){
         			recalcuatePromotedShowLedgerEntries(events);
         		}
         		if(this.actionType == 'RecalcuateRentalSpecialLedgerEntry'){
         			recalcuateRentalSpecialLedgerEntry(events);
         		}
         		if(this.actionType == 'BuildRentalLedgerEntries'){
         			buildRentalLedgerEntries(events);
         		}
                if(this.actionType == 'RecalculateBuySellLedgerEntries'){
                    recalculateBuySellLedgerEntries(events);
                }
         	}
    	}
	}

	/**
     * Method to recalculate Special Events Revenue LE  - GL Account 40223 for Build as a Promoted Show
     **/
	public void recalcuatePromotedSpecialLedgerEntry(List<Event__c> eventList){
		List<LedgerEntry__c> ledgerEntriesToUpsert = new List<LedgerEntry__c>();
        if(eventList != null && !eventList.isEmpty()){
			for(Event__c event : eventList){
                system.debug(LoggingLevel.ERROR,'@@@ event.RentalBuildOption__c  - '+ event.RentalBuildOption__c + ' - '+BUILD_AS_PROMOTEDSHOW);
                if(event.RentalBuildOption__c == BUILD_AS_PROMOTEDSHOW){
    				LedgerEntry__c rentalSpecialLE = getLedgerForEvent(event, SPECIAL_EVENTS_REVENUE_GL_CODE);
                    system.debug(LoggingLevel.ERROR,'@@@ rentalSpecialLE - '+ rentalSpecialLE);
    				if(rentalSpecialLE != null){
    					decimal calculatedAmount = 0.0;

    					/* Event.Net Gross -
    						Sum(Ledger Entry.In House Projection where Record Type = Expenses) -
    						Artist Expenses excluded from Artist Deal per Deal Calc (see notes) -
    						Sum(Deal.Projected Artist Walkout where Record Type = Artist) -
    						Sum(Deal.Co-Promoter Walkout At Projection where Record Type = Co-Promoter and Type <> Internal)
    					*/

    					calculatedAmount += (event.ProjectedNetGross__c == null ? 0.0 : event.ProjectedNetGross__c);
    					for(LedgerEntry__c le : event.LedgerEntries__r){
    						if(le.RecordTypeId == RT_EXPENSES_ID){
    							calculatedAmount -= (le.InHouseProjection__c == null ? 0.0 : le.InHouseProjection__c);
    						}
    					}

    					for(Deal__c deal : event.Deals__r){
    						if(deal.RecordTypeId == RT_DEAL_ARTIST_ID){
    							calculatedAmount -= (deal.ProjectedArtistWalkout__c == null ? 0.0 : deal.ProjectedArtistWalkout__c);
    						}
    						if(deal.RecordTypeId == RT_DEAL_COPROMOTER_ID && deal.Type__c != 'Internal'){
    							calculatedAmount -= (deal.CoPromoterWalkoutAtProjection__c == null ? 0.0 : deal.CoPromoterWalkoutAtProjection__c);
    						}
    					}

    					if(event.StatusStage__c == 'Plan'){
    						rentalSpecialLE.PlanAmount__c = calculatedAmount;
    					} else if(event.StatusStage__c == 'Projection'){
    						rentalSpecialLE.ProjectionAmount__c = calculatedAmount;
    					} 

    					ledgerEntriesToUpsert.add(rentalSpecialLE);
    				}
                }
			}
            system.debug(LoggingLevel.ERROR,'@@@ ledgerEntriesToUpsert special - '+ ledgerEntriesToUpsert);
			if(ledgerEntriesToUpsert != null && !ledgerEntriesToUpsert.isEmpty()){
				upsert ledgerEntriesToUpsert ExternalId__c;
			}			
		}
	}

	public void recalcuatePromotedShowLedgerEntries(List<Event__c> eventList){
		if(eventList != null && !eventList.isEmpty()){
            //first recalculate the Special Events Revenue LE - GL Account 40223
            recalcuatePromotedSpecialLedgerEntry(eventList);

			//Remap Ledger Entries according to the GL Account identified in GL Account.Rental Map
    		Map<String, GLAccount__c> glIdToGLAccountMap = new Map<String, GLAccount__c>();
			for(Event__c event : eventList){
                if(event.RentalBuildOption__c == BUILD_AS_PROMOTEDSHOW){
    				if(event != null && event.LedgerEntries__r != null && !event.LedgerEntries__r.isEmpty()){
    	    			for(LedgerEntry__c le : event.LedgerEntries__r){
    	    				if(le.GLAccount__r.RentalMap__c != null){
    	    					glIdToGLAccountMap.put(le.GLAccount__r.RentalMap__c , new GLAccount__c());
    	    				}
    	    			}
        			}
                }
			}

    		if(glIdToGLAccountMap != null && !glIdToGLAccountMap.isEmpty()){
    			glIdToGLAccountMap = LNE_Util.getGLAccounts(new List<String>(glIdToGLAccountMap.keySet()));
    		}

            system.debug(LoggingLevel.ERROR,'@@@ glIdToGLAccountMap promoted - '+ glIdToGLAccountMap);

    		/*
				Event Stage Type = "Plan" then Ledger Entry.Plan Amount = Calculations below
				Event Stage Type = "Projection" then Ledger Entry.Projection Amount = Calculations below
				Sum(Ledger Entry.Net Revenue where Record Type = Ancillary and Related Contra = null and same GL Account.Rental Map) to the GL Account identified in GL Account.Rental Map
				Sum(Ledger Entry.Gross Revenue where Record Type = Ancillary and Related Contra <> null and same GL Account.Rental Map) to the GL Account identified in GL Account.Rental Map
				Sum(Ledger Entry.Contra At Forecast where Record Type = Contra and same GL Account.Rental Map) to the GL Account identified in GL Account.Rental Map
				Sum(Ledger Entry.COGS At Forecast where Record Type = COGS and same GL Account.Rental Map) to the GL Account identified in GL Account.Rental Map
			*/

    		Map<String, LedgerEntry__c> eventGLAccountToLedgerEntryMap = new Map<String, LedgerEntry__c>();
    		for(Event__c event : eventList){
                if(event.RentalBuildOption__c == BUILD_AS_PROMOTEDSHOW){
        			if(event != null && event.LedgerEntries__r != null && !event.LedgerEntries__r.isEmpty()){
    	    			for(LedgerEntry__c le : event.LedgerEntries__r){
    	    				if(le.GLAccount__r.RentalMap__c != null){
    	    					String leKey = event.Id+le.GLAccount__r.RentalMap__c;
                                LedgerEntry__c newLE = (eventGLAccountToLedgerEntryMap.containsKey(leKey)) ? eventGLAccountToLedgerEntryMap.get(leKey) 
                                                            :  getLedgerForEvent(event, le.GLAccount__r.RentalMap__c, glIdToGLAccountMap);
    	    					system.debug(LoggingLevel.ERROR,'@@@ promoted newLE - '+ newLE);
                                if(le.RecordTypeId == RT_ANCILLARY_ID){
    		    					//check if map already has the 
    		    					
    		    					if(String.isBlank(le.GLAccountRelatedContra__c)){
    		    						if(event.StatusStage__c == 'Plan'){
    		    							newLE.PlanAmount__c += (le.NetRevenue__c == null ? 0 : le.NetRevenue__c);
    		    						}else if(event.StatusStage__c == 'Projection'){
    		    							newLE.ProjectionAmount__c += (le.NetRevenue__c == null ? 0 : le.NetRevenue__c);
    		    						}
    		    					}else if(!(String.isBlank(le.GLAccountRelatedContra__c))){
    		    						if(event.StatusStage__c == 'Plan'){
    		    							newLE.PlanAmount__c += (le.GrossRevenue__c == null ? 0 : le.GrossRevenue__c);
    		    						}else if(event.StatusStage__c == 'Projection'){
    		    							newLE.ProjectionAmount__c += (le.GrossRevenue__c == null ? 0 : le.GrossRevenue__c);
    		    						}
    		    					}
    	    					}
    	    					if(le.RecordTypeId == RT_CONTRA_ID){
    	    						if(event.StatusStage__c == 'Plan'){
    	    							newLE.PlanAmount__c += (le.ContraAtForecast__c == null ? 0 : le.ContraAtForecast__c);
    	    						}else if(event.StatusStage__c == 'Projection'){
    	    							newLE.ProjectionAmount__c += (le.ContraAtForecast__c == null ? 0 : le.ContraAtForecast__c);
    	    						}
    	    					}
    	    					if(le.RecordTypeId == RT_COGS_ID){
    	    						if(event.StatusStage__c == 'Plan'){
    	    							newLE.PlanAmount__c += (le.CogsAtForecast__c == null ? 0 : le.CogsAtForecast__c);
    	    						}else if(event.StatusStage__c == 'Projection'){
    	    							newLE.ProjectionAmount__c += (le.CogsAtForecast__c == null ? 0 : le.CogsAtForecast__c);
    	    						}
    	    					}
                                eventGLAccountToLedgerEntryMap.put(leKey, newLE);
    	    				}
    	    			}
        			}
                }
    		}

            system.debug(LoggingLevel.ERROR,'@@@ ledgerEntriesToUpsert promoted - '+ eventGLAccountToLedgerEntryMap);
            if(eventGLAccountToLedgerEntryMap != null && !eventGLAccountToLedgerEntryMap.isEmpty()){
                upsert eventGLAccountToLedgerEntryMap.values() ExternalId__c;
            }		
		}
	}

	/**
     * Method to recalculate Special Events Revenue LE - GL Account 40223 for Build Using Rental Accounts
     **/
	public void recalcuateRentalSpecialLedgerEntry(List<Event__c> eventList){
		List<LedgerEntry__c> ledgerEntriesToUpsert = new List<LedgerEntry__c>();
		if(eventList != null && !eventList.isEmpty()){
			for(Event__c event : eventList){
                if(event.RentalBuildOption__c == BUILD_AS_RENTAL){
    				LedgerEntry__c rentalSpecialLE = getLedgerForEvent(event, SPECIAL_EVENTS_REVENUE_GL_CODE);

    				if(rentalSpecialLE != null){
    					decimal calculatedAmount = 0.0;

    					/* Event.Net Gross -
    						Artist Expenses excluded from Artist Deal per Deal Calc (see notes) -
    						Sum(Deal.Projected Artist Walkout where Record Type = Artist) -
    						Sum(Deal.Co-Promoter Walkout At Projection where Record Type = Co-Promoter and Type <> Internal)
    						Expenses and Ancillaries follow the standard process with the rental GL Accounts being used
    						*/

    					calculatedAmount += (event.ProjectedNetGross__c == null ? 0.0 : event.ProjectedNetGross__c);
    					for(Deal__c deal : event.Deals__r){
    						if(deal.RecordTypeId == RT_DEAL_ARTIST_ID){
    							calculatedAmount -= (deal.ProjectedArtistWalkout__c == null ? 0.0 : deal.ProjectedArtistWalkout__c);
    						}
    						if(deal.RecordTypeId == RT_DEAL_COPROMOTER_ID && deal.Type__c != 'Internal'){
    							calculatedAmount -= (deal.CoPromoterWalkoutAtProjection__c == null ? 0.0 : deal.CoPromoterWalkoutAtProjection__c);
    						}
    					}

    					if(event.StatusStage__c == 'Plan'){
    						rentalSpecialLE.PlanAmount__c = calculatedAmount;
    					} else if(event.StatusStage__c == 'Projection'){
    						rentalSpecialLE.ProjectionAmount__c = calculatedAmount;
    					} 

    					ledgerEntriesToUpsert.add(rentalSpecialLE);
    				}
                }
			}

			if(ledgerEntriesToUpsert != null && !ledgerEntriesToUpsert.isEmpty()){
				upsert ledgerEntriesToUpsert ExternalId__c;
			}			
		}
	}

	/**
     * Method to calculate Rental Ledger Entries for the passed events.
     **/
    private void buildRentalLedgerEntries(List<Event__c> eventList) {
    	//first recalculate the Special Events Revenue LE - GL Account 40223
    	recalcuateRentalSpecialLedgerEntry(eventList);

    	if(eventList != null && !eventList.isEmpty()){
    		//Remap Ledger Entries according to the GL Account identified in GL Account.Rental Map
    		Map<String, GLAccount__c> glIdToGLAccountMap = new Map<String, GLAccount__c>();
    		for(Event__c event : eventList){
                if(event.RentalBuildOption__c == BUILD_AS_RENTAL){
        			if(event != null && event.LedgerEntries__r != null && !event.LedgerEntries__r.isEmpty()){
    	    			for(LedgerEntry__c le : event.LedgerEntries__r){
    	    				if(le.GLAccount__r.RentalMap__c != null){
    	    					glIdToGLAccountMap.put(le.GLAccount__r.RentalMap__c , new GLAccount__c());
    	    				}
    	    			}
        			}
    		    }
            }

    		if(glIdToGLAccountMap != null && !glIdToGLAccountMap.isEmpty()){
    			glIdToGLAccountMap = LNE_Util.getGLAccounts(new List<String>(glIdToGLAccountMap.keySet()));
    		}

    		Map<String, LedgerEntry__c> eventGLAccountToLedgerEntryMap = new Map<String, LedgerEntry__c>();
    		List<LedgerEntry__c> leListForDelete = new List<LedgerEntry__c>();
    		for(Event__c event : eventList){
                if(event.RentalBuildOption__c == BUILD_AS_RENTAL){
        			if(event != null && event.LedgerEntries__r != null && !event.LedgerEntries__r.isEmpty()){
    	    			for(LedgerEntry__c le : event.LedgerEntries__r){
    	    				if(le.GLAccount__r.RentalMap__c != null){
    	    					String leKey = event.Id+le.GLAccount__r.RentalMap__c;
                                LedgerEntry__c newLE = (eventGLAccountToLedgerEntryMap.containsKey(leKey)) ? eventGLAccountToLedgerEntryMap.get(leKey) 
                                                            :  getLedgerForEvent(event, le.GLAccount__r.RentalMap__c, glIdToGLAccountMap);
                                    
    	    					if(le.RecordTypeId == RT_EXPENSES_ID){
    		    					//check if map already has the 
    		    					newLE.OfferRateType__c = 'Flat';
    		    					newLE.OfferRate__c += (le.OfferAtProjection__c == null ? 0 : le.OfferAtProjection__c);
    		    					newLE.InHouseRateType__c = 'Flat';
    		    					newLE.InHouseRate__c = (le.InHouseProjection__c == null ? 0 : le.InHouseProjection__c);
    	    					}
    	    					else if(le.RecordTypeId == RT_ANCILLARY_ID){
    		    					newLE.RateType__c = 'Flat';
    		    					newLE.BaseAmount__c += (le.GrossRevenue__c == null ? 0 : le.GrossRevenue__c);
    		    					newLE.ContraType__c = 'Flat';
    		    					newLE.ContraAmount__c = (le.ContraAtForecast__c == null ? 0 : le.ContraAtForecast__c);
    	    					}
    	    					else if(le.RecordTypeId == RT_COGS_ID){
    		    					//check if map already has the 
    		    					newLE.RateType__c = 'Flat';
    		    					newLE.BaseAmount__c += (le.COGSAtForecast__c == null ? 0 : le.COGSAtForecast__c);
    		    					newLE.ContraType__c = 'Flat';
    	    					}
                                eventGLAccountToLedgerEntryMap.put(leKey, newLE);
                                leListForDelete.add(le);
    	    				}
    	    			}
        			}
                }
    		}

    		if(eventGLAccountToLedgerEntryMap != null && !eventGLAccountToLedgerEntryMap.isEmpty()){
    			insert eventGLAccountToLedgerEntryMap.values();
    		}

    		if(leListForDelete != null && !leListForDelete.isEmpty()){
    			delete leListForDelete;
    		}

    	}
	}


    /**
     * Method to recalculate Booking Revenue LE - GL Account 42019 for Buy Sell Events. US746
     **/
    public void recalculateBuySellLedgerEntries(List<Event__c> eventList){
        List<LedgerEntry__c> ledgerEntriesToUpsert = new List<LedgerEntry__c>();
        if(eventList != null && !eventList.isEmpty()){
            for(Event__c event : eventList){
                if(event.RecordTypeId == RT_BUYSELL_ID){
                    LedgerEntry__c bookingLE = getLedgerForEvent(event, BOOKING_GL_CODE);

                    if(bookingLE != null){
                        decimal calculatedAmount = 0.0;

                        /* Event.Net Gross +
                                Sum(Ledger Entry.Net Revenue where Record Type = Ancillary) -
                                Sum(Ledger Entry.In House Projection where Record Type = Expenses) -
                                Artist Expenses excluded from Artist Deal per Deal Calc (see notes) -
                                Sum(Ledger Entry.COGS At Forecast where Record Type = COGS) -
                                Sum(Deal.Projected Artist Walkout where Record Type = Artist) -
                                Sum(Deal.Co-Promoter Walkout At Projection where Record Type = Co-Promoter and Type <> Internal)
                            */

                        calculatedAmount += (event.ProjectedNetGross__c == null ? 0.0 : event.ProjectedNetGross__c);
                        for(LedgerEntry__c le : event.LedgerEntries__r){
                            if(le.RecordTypeId == RT_ANCILLARY_ID){
                                calculatedAmount += (le.NetRevenue__c == null ? 0.0 : le.NetRevenue__c);
                            }
                            if(le.RecordTypeId == RT_EXPENSES_ID){
                                calculatedAmount -= (le.InHouseProjection__c == null ? 0.0 : le.InHouseProjection__c);
                            }
                            if(le.RecordTypeId == RT_COGS_ID){
                                calculatedAmount -= (le.COGSAtForecast__c == null ? 0.0 : le.COGSAtForecast__c);
                            }
                        }

                        Boolean eventExpenseIncluded_Guarantee = false;
                        Boolean eventExpenseIncluded_OtherTalent = false;
                        Boolean eventExpenseIncluded_Sound = false;
                        Boolean eventExpenseIncluded_SoundAndOtherTalent = false;

                        for(Deal__c deal : event.Deals__r){
                            if(deal.RecordTypeId == RT_DEAL_ARTIST_ID){
                                calculatedAmount -= (deal.ProjectedArtistWalkout__c == null ? 0.0 : deal.ProjectedArtistWalkout__c);
                            }
                            if(deal.RecordTypeId == RT_DEAL_COPROMOTER_ID && deal.Type__c != 'Internal'){
                                calculatedAmount -= (deal.CoPromoterWalkoutAtProjection__c == null ? 0.0 : deal.CoPromoterWalkoutAtProjection__c);
                            }
                            if(deal.Type__c == DEAL_PRIMARY_HEADLINER || deal.Type__c == DEAL_TYPE_CO_HEADLINER)
                            {
                                if(deal.DealCalculation__c == 'Guarantee Only'){
                                    calculatedAmount -= (deal.ArtistSuppliedSL__c + deal.OtherTalentAmount__c);
                                    if(eventExpenseIncluded_Guarantee == false){
                                       calculatedAmount -= event.TotalSupportActExpenses__c; 
                                       eventExpenseIncluded_Guarantee = true;
                                    }
                                }
                                if(deal.DealCalculation__c == 'Inclusive of Other Talent Amount'){
                                    calculatedAmount -= (deal.ArtistSuppliedSL__c);
                                    if(eventExpenseIncluded_OtherTalent == false){
                                       calculatedAmount -= event.TotalSupportActExpenses__c; 
                                       eventExpenseIncluded_OtherTalent = true;
                                    }
                                }
                                if(deal.DealCalculation__c == 'Inclusive of Sound & Lights'){
                                    calculatedAmount -= (deal.OtherTalentAmount__c);
                                    if(eventExpenseIncluded_Sound == false){
                                       calculatedAmount -= event.TotalSupportActExpenses__c; 
                                       eventExpenseIncluded_Sound = true;
                                    }
                                }
                                if(deal.DealCalculation__c == 'Inclusive of Sound & Lights & Other Talent Amount'){
                                    if(eventExpenseIncluded_SoundAndOtherTalent == false){
                                       calculatedAmount -= event.TotalSupportActExpenses__c; 
                                       eventExpenseIncluded_SoundAndOtherTalent = true;
                                    }
                                }
                                if(deal.DealCalculation__c == 'Inclusive of Sound & Lights & Support'){
                                    calculatedAmount -= (deal.OtherTalentAmount__c);
                                }
                                if(deal.DealCalculation__c == 'Inclusive of Support'){
                                    calculatedAmount -= (deal.ArtistSuppliedSL__c + deal.OtherTalentAmount__c);
                                }
                                if(deal.DealCalculation__c == 'Inclusive of Support And Other Talent Amount'){
                                    calculatedAmount -= (deal.ArtistSuppliedSL__c);
                                }
                            }
                        }

                        if(event.StatusStage__c == 'Plan'){
                            bookingLE.PlanAmount__c = calculatedAmount;
                        } else if(event.StatusStage__c == 'Projection'){
                            bookingLE.ProjectionAmount__c = calculatedAmount;
                        } 

                        ledgerEntriesToUpsert.add(bookingLE);
                    }
                }
            }

            if(ledgerEntriesToUpsert != null && !ledgerEntriesToUpsert.isEmpty()){
                upsert ledgerEntriesToUpsert ExternalId__c;
            }           
        }
    }

	private static LedgerEntry__c getLedgerForEvent(Event__c e, String code, Map<String, GLAccount__c> glCodeTOAccountMap) {
        Map<String, LedgerEntry__c> ledgers = new Map<String, LedgerEntry__c>();
        for (LedgerEntry__c l : e.LedgerEntries__r) {
            ledgers.put(l.GLAccount__r.GLCode__c, l);
        }

        LedgerEntry__c l = ledgers.get(code);

        if (l == null) {
            GLAccount__c glAccount = glCodeTOAccountMap.get(code);
            //set recordtype based on GL Account type
            Id recordtypeId = glAccountTypeToRecordTypeIdMap.get(glAccount.Type__c);

            l = new LedgerEntry__c(Event__c=e.Id,
                                   GLAccount__c=glAccount.Id,
                                   ExternalId__c = e.Id + code,
                                   RecordTypeId = recordtypeId);
        }
        if(l.PlanAmount__c == NULL) l.PlanAmount__c = 0.0;
        if(l.ProjectionAmount__c == NULL) l.ProjectionAmount__c = 0.0;

        return l;
    }

    private static LedgerEntry__c getLedgerForEvent(Event__c e, String code) {
        Map<String, LedgerEntry__c> ledgers = new Map<String, LedgerEntry__c>();
        for (LedgerEntry__c l : e.LedgerEntries__r) {
            if(l.GLAccount__c != null && l.GLAccount__r.GLCode__c != null){
                ledgers.put(l.GLAccount__r.GLCode__c, l);
            }
        }

        LedgerEntry__c l = ledgers.get(code);
        system.debug(LoggingLevel.ERROR,'@@@ getLedgerForEvent - '+ ledgers + ' - '+ l+ ' - '+ code);

        if (l == null && glAccountsMap.get(code) != null) {

            //set recordtype based on GL Account type
            GLAccount__c glAccount = glAccountsMap.get(code);
            Id recordtypeId = glAccountTypeToRecordTypeIdMap.get(glAccount.Type__c);

            l = new LedgerEntry__c(Event__c=e.Id,
                                   GLAccount__c=glAccount.Id,
                                   ExternalId__c = e.Id + code,
                                   RecordTypeId = recordtypeId);
            system.debug(LoggingLevel.ERROR,'@@@ getLedgerForEvent instantiated new- '+ l + ' - '+glAccount.Id + ' - '+code);
        }
        if(l.PlanAmount__c == NULL) l.PlanAmount__c = 0.0;
        if(l.ProjectionAmount__c == NULL) l.ProjectionAmount__c = 0.0;

        return l;
    }


}
