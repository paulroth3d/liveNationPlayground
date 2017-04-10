@isTest
private class LNE_PrimarySecondaryCoPromoter_Test {
    static String RT_ARTIST = 'Account.Artist';
    static String RT_OFFICE = 'Account.Office';
    static String RT_VENUE = 'Account.Venue';
    static String RT_COPROMOTER = 'Account.CoPromoter';
    static String RT_TICKET_REVENUE = 'LedgerEntry__c.TicketRevenue';
	static String RT_EXPENSES = 'LedgerEntry__c.Expenses';
	static String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
	static String RT_COGS = 'LedgerEntry__c.COGS';
	static String RT_DEAL_COPROMOTER = 'Deal__c.CoPromoter';

	static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
	    new String[]{ RT_TICKET_REVENUE, RT_EXPENSES , RT_COPROMOTER, RT_ARTIST, RT_OFFICE, RT_VENUE, RT_ANCILLARY, RT_COGS, RT_DEAL_COPROMOTER}
    );

    static Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( RT_ARTIST );
    static Id RT_ACCOUNT_OFFICE_ID = recordTypeMap.get( RT_OFFICE );
    static Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( RT_VENUE );
    static Id RT_ACCOUNT_COPROMOTER_ID = recordTypeMap.get( RT_COPROMOTER );
    static Id RT_TICKET_REVENUE_ID = recordTypeMap.get( RT_TICKET_REVENUE );
    static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    static Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );
    static Id RT_COGS_ID = recordTypeMap.get( RT_COGS );
    static Id RT_DEAL_COPROMOTER_ID = recordTypeMap.get( RT_DEAL_COPROMOTER );
    
    static Map<String,GLAccount__c> glAccountsMap = LNE_Util.getGLAccounts(new String[] {'40100','40116', '40205','50103','50302','50339'});
    
     /** Co-Promote Expense GL CODE **/
    public static final String COPRO_EXPENSE_GL_CODE='50302';
     /** Building Co-Promote GL CODE **/
    public static final String COPRO_BOOKING_GL_CODE='50339';
    
    class TestSettings {
		public Event__c testEvent {get; set;}
		public Deal__c testPrimaryCoPromoter {get; set;}
		public Deal__c testSecondaryCoPromoter {get; set;}
		
		public TestSettings() {
		    
		}
		
		public void typicalSetup(){
		    testEvent = [select Id, Venue__c from Event__c limit 1];
		    
		    Deal__c headliner = [select Id from Deal__c where Type__c = 'Primary Headliner' and Event__c = :testEvent.Id];
		    
			//Bonus Detail
			BonusDetail__c bonus = new BonusDetail__c();
			bonus.BonusBase__c = 'Paid Tickets';
			bonus.Type__c = 'Retro';
			bonus.BonusAmount__c = 1;
			bonus.StartPoint__c = 0;
			bonus.Increment__c = 1;
			bonus.Deal__c = headliner.Id;
			LNE_FinancialCalculator.runUpdates = false;
			insert bonus;
		}
		
		public void finalize(){
		}
	}
	
	
	@testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet();
        
        LNE_Util.refreshGLAccountCache();
        
        glAccountsMap = LNE_Util.getGLAccounts(new String[] {'40100','40116','40205','50103','50302','50339'});
    }
	
	/**
	 * Testing Primary CoPromoter Calculations
	 * EventLoss
	 * TalentOverhead = True
	 * Expenses
	 * Ancillary
	 * */
	static testMethod void  verifyPrimaryCoPromoterCalculations1() {
		LNE_FinancialCalculator.currentlyRunning = true;
		
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];
		Account copro2 = [select Id from Account where name = 'Co Pro 2'];
		
		EventDateTime__c evtDateTime = new EventDateTime__c(
            event__c = tsettings.testEvent.Id, 
            EventYear__c = String.valueOf(System.now().year() + 2),
            StartTime__c = '8:00 PM');
        insert evtDateTime;
		
		test.startTest();

		//Expense
		LedgerEntry__c ledgerEntry1 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('50103').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_EXPENSES_ID,
            SettleAtActual__c = false,
            ExpenseAdjustment__c = 333,
            OfferAtSellout__c = 200, // OfferAtSellout__c - InHouseatSellout__c = le.ExpenseAdjustmentatSellout__c //calculated in FC
            InHouseatSellout__c = 100,
            OfferAtProjection__c = 334,
            InHouseProjection__c = 1,
            OfferRate__c = 334,
            OfferRateType__c = 'Flat',
            InHouseRate__c = 1,
            InHouseRateType__c = 'Flat'
        );
        
	    //Ancillary
	    LedgerEntry__c ledgerEntry2 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('40205').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_ANCILLARY_ID,
            RateType__c = 'Flat',
            NetRevenue__c = 111,
            NetRevenueatSellout__c = 222,
            BaseAmount__c = 111
        );
    
        insert new List<LedgerEntry__c>{ledgerEntry1, ledgerEntry2};
        
        LNE_FinancialCalculator.currentlyRunning = false;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        LNE_FinancialCalculator.checkIfCanRunCalculations();
        
        Deal__c PrimaryInternalDeal = [select Id from Deal__c where Type__c = 'Internal' AND PrimarySecondaryCoPromoter__c = 'Primary'];

        // 
        // Test 1: Test intial calculations(Financial Calculator and formulas on Deal, Ledger Entry, Deal Settlement Ledger)
        //
        
        Deal__c testDeal = [select 
                            Id, EventProfit__c, EventLoss__c,ExpenseAdjustmentProfit__c,ExpenseAdjustmentLoss__c,AncillaryRevenue__c,
                            ProfitShareAmountAtProjection__c,
                            ProfitShareAmountAtSellout__c,
                            ExpenseAdjustmentShareAmountAtProj__c,
                            ExpenseAdjustmentShareAmountAtSell__c,
                            CoPromoterBonusAtProjection__c,
                            CoPromoterBonusAtSellout__c,
                            CoPromoterWalkoutAtProjection__c,
                            CoPromoterWalkoutAtSellout__c,
                            AncillaryShareAmountAtProjection__c,
                            AncillaryShareAmountAtSellout__c,
                            Type__c,
                            PrimarySecondaryCoPromoter__c,
                            LNEExpenseAdjShareAmountAtProj__c
                            From Deal__c where Id =:PrimaryInternalDeal.id];
        
        System.assertEquals(-1200.00, testDeal.ProfitShareAmountAtProjection__c);
        System.assertEquals(-1200.00, testDeal.ProfitShareAmountAtSellout__c);
		System.assertEquals(333, testDeal.ExpenseAdjustmentShareAmountAtProj__c);
		System.assertEquals(333, testDeal.ExpenseAdjustmentShareAmountAtSell__c);
		System.assertEquals(0, testDeal.CoPromoterBonusAtProjection__c);
		System.assertEquals(0, testDeal.CoPromoterBonusAtSellout__c);
		System.assertEquals(-756.00, testDeal.CoPromoterWalkoutAtProjection__c);
		System.assertEquals(-756.00, testDeal.CoPromoterWalkoutAtSellout__c);
		System.assertEquals(111, testDeal.AncillaryShareAmountAtProjection__c);
		System.assertEquals(111, testDeal.AncillaryShareAmountAtSellout__c);
		
        // 
        // Test 2: Test percentage split calculation between copromoter and internal LNE Row.
        // At 50 % for all the splits the deal should be half the values above.
        //
        
		Deal__c deal1 = new Deal__c();
    	deal1.Event__c = tsettings.testEvent.Id;
        deal1.Type__c = '3rd Party';
        deal1.CoPromoter__c = copro1.id;
        deal1.EventProfit__c = 50;
        deal1.EventLoss__c = 50;
        deal1.ExpenseAdjustmentProfit__c = 50;
        deal1.ExpenseAdjustmentLoss__c = 50;
        deal1.AncillaryRevenue__c = 50;
        deal1.PrimarySecondaryCoPromoter__c = 'Primary';
        deal1.ShareInTalentOverhead__c = True;
        deal1.DownsideRisk__c = True;
        deal1.RecordTypeId = RT_DEAL_COPROMOTER_ID;

        PrimaryInternalDeal.EventProfit__c = 50;
        PrimaryInternalDeal.EventLoss__c = 50;
        PrimaryInternalDeal.ExpenseAdjustmentProfit__c = 50;
        PrimaryInternalDeal.ExpenseAdjustmentLoss__c = 50;
        PrimaryInternalDeal.AncillaryRevenue__c = 50;
        
        LNE_FinancialCalculator.runUpdates = true;
        update PrimaryInternalDeal;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        insert deal1;

        testDeal = [select 
                            Id,
                            ProfitShareAmountAtProjection__c,
                            ProfitShareAmountAtSellout__c,
                            ExpenseAdjustmentShareAmountAtProj__c,
                            ExpenseAdjustmentShareAmountAtSell__c,
                            CoPromoterBonusAtProjection__c,
                            CoPromoterBonusAtSellout__c,
                            CoPromoterWalkoutAtProjection__c,
                            CoPromoterWalkoutAtSellout__c,
                            AncillaryShareAmountAtProjection__c,
                            AncillaryShareAmountAtSellout__c,
                            Type__c,
                            PrimarySecondaryCoPromoter__c,
                            RollUpAncillaryShareAmtAtProj__c,
                            RollUpExpenseAdjustmentAtProjection__c,
                            RollUpPriCoProAncilShareAtProj__c,
                            RollUpPriCoProExpenseShareAtProj__c,
                            RollUpBonusDetailsCount__c
                                From Deal__c where event__c =:tsettings.testEvent.Id and id = :deal1.id];
                                 
        System.assertEquals(-600.00, testDeal.ProfitShareAmountAtProjection__c);
        System.assertEquals(-600.00, testDeal.ProfitShareAmountAtSellout__c);
		System.assertEquals(166.50, testDeal.ExpenseAdjustmentShareAmountAtProj__c);
		System.assertEquals(166.50, testDeal.ExpenseAdjustmentShareAmountAtSell__c);
		System.assertEquals(0, testDeal.CoPromoterBonusAtProjection__c);
		System.assertEquals(0, testDeal.CoPromoterBonusAtSellout__c);
		System.assertEquals(-378.00, testDeal.CoPromoterWalkoutAtProjection__c);
		System.assertEquals(-378.00, testDeal.CoPromoterWalkoutAtSellout__c);
		System.assertEquals(55.50, testDeal.AncillaryShareAmountAtProjection__c);
		System.assertEquals(55.50, testDeal.AncillaryShareAmountAtSellout__c);
		
		test.stopTest();
	}
	
	
	/**
	 * Testing Primary CoPromoter Calculations
	 * TalentOverhead = false
	 * COGS
	 * */
	static testMethod void  verifyPrimaryCoPromoterCalculations2() {
		LNE_FinancialCalculator.currentlyRunning = true;
		
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];
		Account copro2 = [select Id from Account where name = 'Co Pro 2'];
		
		test.startTest();

        //COGS
	    LedgerEntry__c ledgerEntry3 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('40205').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_COGS_ID,
            RateType__c = 'Flat',
            COGSAtForecast__c = 1234,
            COGSAtSellout__c = 4567,
            BaseAmount__c = 4567 // COGSAtSellout__c - FC set this value
        );
    
        insert new List<LedgerEntry__c>{ledgerEntry3};
        
        LNE_FinancialCalculator.currentlyRunning = false;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        LNE_FinancialCalculator.checkIfCanRunCalculations();
        
        Deal__c PrimaryInternalDeal = [select Id from Deal__c where Type__c = 'Internal' AND PrimarySecondaryCoPromoter__c = 'Primary'];

        //
        // Test 1: COGS value at Primary LNE Row
        //
        
        Deal__c testDeal = [select 
                            Id, EventProfit__c, EventLoss__c,ExpenseAdjustmentProfit__c,ExpenseAdjustmentLoss__c,AncillaryRevenue__c,
                            ProfitShareAmountAtProjection__c,
                            ProfitShareAmountAtSellout__c,
                            ExpenseAdjustmentShareAmountAtProj__c,
                            ExpenseAdjustmentShareAmountAtSell__c,
                            CoPromoterBonusAtProjection__c,
                            CoPromoterBonusAtSellout__c,
                            CoPromoterWalkoutAtProjection__c,
                            CoPromoterWalkoutAtSellout__c,
                            AncillaryShareAmountAtProjection__c,
                            AncillaryShareAmountAtSellout__c,
                            Type__c,
                            PrimarySecondaryCoPromoter__c
                                From Deal__c where Id =:PrimaryInternalDeal.id];
                                
        System.assertEquals(-4567, testDeal.AncillaryShareAmountAtSellout__c);
		
         //
         // Test 2: Test percentage split calculation between copromoter and internal LNE Row.
         // At 50 % for all the splits the deal should be half the values above.
         //
         
		Deal__c deal1 = new Deal__c();
    	deal1.Event__c = tsettings.testEvent.Id;
        deal1.Type__c = '3rd Party';
        deal1.CoPromoter__c = copro1.id;
        deal1.EventProfit__c = 50;
        deal1.EventLoss__c = 50;
        deal1.ExpenseAdjustmentProfit__c = 50;
        deal1.ExpenseAdjustmentLoss__c = 50;
        deal1.AncillaryRevenue__c = 50;
        deal1.PrimarySecondaryCoPromoter__c = 'Primary';
        deal1.ShareInTalentOverhead__c = false;
        deal1.DownsideRisk__c = True;
        deal1.RecordTypeId = RT_DEAL_COPROMOTER_ID;

        PrimaryInternalDeal.EventProfit__c = 50;
        PrimaryInternalDeal.EventLoss__c = 50;
        PrimaryInternalDeal.ExpenseAdjustmentProfit__c = 50;
        PrimaryInternalDeal.ExpenseAdjustmentLoss__c = 50;
        PrimaryInternalDeal.AncillaryRevenue__c = 50;
        
        LNE_FinancialCalculator.runUpdates = true;
        update PrimaryInternalDeal;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        insert deal1;

        testDeal = [select 
                            Id,
                            ProfitShareAmountAtProjection__c,
                            ProfitShareAmountAtSellout__c,
                            ExpenseAdjustmentShareAmountAtProj__c,
                            ExpenseAdjustmentShareAmountAtSell__c,
                            CoPromoterBonusAtProjection__c,
                            CoPromoterBonusAtSellout__c,
                            CoPromoterWalkoutAtProjection__c,
                            CoPromoterWalkoutAtSellout__c,
                            AncillaryShareAmountAtProjection__c,
                            AncillaryShareAmountAtSellout__c,
                            Type__c,
                            PrimarySecondaryCoPromoter__c,
                            RollUpAncillaryShareAmtAtProj__c,
                            RollUpExpenseAdjustmentAtProjection__c,
                            RollUpPriCoProAncilShareAtProj__c,
                            RollUpPriCoProExpenseShareAtProj__c,
                            RollUpBonusDetailsCount__c
                                From Deal__c where event__c =:tsettings.testEvent.Id and id = :deal1.id];
        
        System.assertEquals(-550.00, testDeal.ProfitShareAmountAtProjection__c); // Talent overhead = false. split 100
		System.assertEquals(-2283.50, testDeal.AncillaryShareAmountAtProjection__c);
		System.assertEquals(-2283.50, testDeal.AncillaryShareAmountAtSellout__c);
		
		test.stopTest();
	}
	
	/**
	 * Secondary Copromoter Calculations
	 * 
	 * */
	static testMethod void  verifySecondaryCoPromoterCalculations1() {
		LNE_FinancialCalculator.currentlyRunning = true;
		
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];
		Account copro2 = [select Id from Account where name = 'Co Pro 2'];
		
		test.startTest();

		//Expense
		LedgerEntry__c ledgerEntry1 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('50103').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_EXPENSES_ID,
            SettleAtActual__c = false,
            ExpenseAdjustment__c = 333,
            OfferAtSellout__c = 200, // OfferAtSellout__c - InHouseatSellout__c = le.ExpenseAdjustmentatSellout__c //calculated in FC
            InHouseatSellout__c = 100,
            OfferAtProjection__c = 334,
            InHouseProjection__c = 1,
            OfferRate__c = 334,
            OfferRateType__c = 'Flat',
            InHouseRate__c = 1,
            InHouseRateType__c = 'Flat'
        );
        
	    //Ancillary
	    LedgerEntry__c ledgerEntry2 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('40205').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_ANCILLARY_ID,
            RateType__c = 'Flat',
            NetRevenue__c = 111,
            NetRevenueatSellout__c = 222,
            BaseAmount__c = 111
        );
    
        insert new List<LedgerEntry__c>{ledgerEntry1, ledgerEntry2};
		
		Deal__c deal1 = new Deal__c();
    	deal1.Event__c = tsettings.testEvent.Id;
        deal1.Type__c = '3rd Party';
        deal1.CoPromoter__c = copro1.id;
        deal1.EventProfit__c = 50;
        deal1.EventLoss__c = 50;
        deal1.ExpenseAdjustmentProfit__c = 50;
        deal1.ExpenseAdjustmentLoss__c = 50;
        deal1.AncillaryRevenue__c = 50;
        deal1.PrimarySecondaryCoPromoter__c = 'Primary';
        deal1.ShareInTalentOverhead__c = True;
        deal1.DownsideRisk__c = True;
        deal1.RecordTypeId = RT_DEAL_COPROMOTER_ID;
		
		//** 
        // Test 1: Test percentage for Secondary CoPromoters
        // At 50 % for all the splits the deal should be half the values above.
        // 
         
        Deal__c deal2 = new Deal__c();
    	deal2.Event__c = tsettings.testEvent.Id;
        deal2.Type__c = '3rd Party';
        deal2.CoPromoter__c = copro1.id;
        deal2.EventProfit__c = 50;
        deal2.EventLoss__c = 50;
        deal2.ExpenseAdjustmentProfit__c = 50;
        deal2.ExpenseAdjustmentLoss__c = 50;
        deal2.AncillaryRevenue__c = 50;
        deal2.PrimarySecondaryCoPromoter__c = 'Secondary';
        deal2.ShareInTalentOverhead__c = True;
        deal2.DownsideRisk__c = True;
        deal2.RecordTypeId = RT_DEAL_COPROMOTER_ID;
        
        insert new List<Deal__c>{deal1,deal2};
        
        LNE_FinancialCalculator.currentlyRunning = false;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        LNE_FinancialCalculator.checkIfCanRunCalculations();
        
        Deal__c testDeal = [select 
                            Id,
                            ProfitShareAmountAtProjection__c,
                            ProfitShareAmountAtSellout__c,
                            ExpenseAdjustmentShareAmountAtProj__c,
                            ExpenseAdjustmentShareAmountAtSell__c,
                            CoPromoterBonusAtProjection__c,
                            CoPromoterBonusAtSellout__c,
                            CoPromoterWalkoutAtProjection__c,
                            CoPromoterWalkoutAtSellout__c,
                            AncillaryShareAmountAtProjection__c,
                            AncillaryShareAmountAtSellout__c,
                            Type__c,
                            PrimarySecondaryCoPromoter__c,
                            RollUpAncillaryShareAmtAtProj__c,
                            RollUpExpenseAdjustmentAtProjection__c,
                            RollUpPriCoProAncilShareAtProj__c,
                            RollUpPriCoProExpenseShareAtProj__c,
                            RollUpBonusDetailsCount__c
                                From Deal__c where event__c =:tsettings.testEvent.Id and id = :deal2.id];
                                 
        System.assertEquals(-600, testDeal.ProfitShareAmountAtProjection__c);
        System.assertEquals(-600, testDeal.ProfitShareAmountAtSellout__c);
		System.assertEquals(83.25, testDeal.ExpenseAdjustmentShareAmountAtProj__c);
		System.assertEquals(83.25, testDeal.ExpenseAdjustmentShareAmountAtSell__c);
		System.assertEquals(0, testDeal.CoPromoterBonusAtProjection__c);
		System.assertEquals(0, testDeal.CoPromoterBonusAtSellout__c);
		System.assertEquals(-489.00, testDeal.CoPromoterWalkoutAtProjection__c);
		System.assertEquals(-489.00, testDeal.CoPromoterWalkoutAtSellout__c);
		System.assertEquals(27.75, testDeal.AncillaryShareAmountAtProjection__c);
		System.assertEquals(27.75, testDeal.AncillaryShareAmountAtSellout__c);
		
		test.stopTest();
	}
	
	
	/**
	 * Secondary Copromoter Calculations
	 * EventProfit
	 * TalentOverhead = false
	 * */
	static testMethod void  verifySecondaryCoPromoterCalculations2() {
		LNE_FinancialCalculator.currentlyRunning = true;
		
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];
		Account copro2 = [select Id from Account where name = 'Co Pro 2'];
		
		test.startTest();
        
	    //Ancillary
	    LedgerEntry__c ledgerEntry2 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('40205').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_ANCILLARY_ID,
            RateType__c = 'Flat',
            NetRevenue__c = 100000,
            NetRevenueatSellout__c = 100000,
            BaseAmount__c = 100000
        );
        
        TicketScale__c ticketScale = new TicketScale__c();
		ticketScale.Type__c = 'Lawn';
		ticketScale.Capacity__c = 1000;
		ticketScale.Price__c = 100.00;
		ticketScale.Kills__c = 0;
		ticketScale.Comps__c = 0;
		ticketScale.ProjectedPaidTickets__c = 1000;
		ticketScale.Event__c = tsettings.testEvent.Id;
		ticketScale.LiftBeforeFee__c = 0;
		ticketScale.TMFeePercent__c = 0.0;
		LNE_FinancialCalculator.runUpdates = true;
		insert ticketScale;
    
        insert new List<LedgerEntry__c>{ledgerEntry2};
        
		Deal__c deal1 = new Deal__c();
    	deal1.Event__c = tsettings.testEvent.Id;
        deal1.Type__c = '3rd Party';
        deal1.CoPromoter__c = copro1.id;
        deal1.EventProfit__c = 50;
        deal1.EventLoss__c = 50;
        deal1.ExpenseAdjustmentProfit__c = 50;
        deal1.ExpenseAdjustmentLoss__c = 50;
        deal1.AncillaryRevenue__c = 50;
        deal1.PrimarySecondaryCoPromoter__c = 'Primary';
        deal1.ShareInTalentOverhead__c = false;
        deal1.DownsideRisk__c = True;
        deal1.RecordTypeId = RT_DEAL_COPROMOTER_ID;
		
		/*** 
         * Test 1: Test percentage for Secondary CoPromoters
         * At 50 % for all the splits the deal should be half the values above.
         * */
         
        Deal__c deal2 = new Deal__c();
    	deal2.Event__c = tsettings.testEvent.Id;
        deal2.Type__c = '3rd Party';
        deal2.CoPromoter__c = copro1.id;
        deal2.EventProfit__c = 50;
        deal2.EventLoss__c = 50;
        deal2.ExpenseAdjustmentProfit__c = 50;
        deal2.ExpenseAdjustmentLoss__c = 50;
        deal2.AncillaryRevenue__c = 50;
        deal2.PrimarySecondaryCoPromoter__c = 'Secondary';
        deal2.ShareInTalentOverhead__c = false;
        deal2.DownsideRisk__c = True;
        deal2.RecordTypeId = RT_DEAL_COPROMOTER_ID;
        
        insert new List<Deal__c>{deal1,deal2};
        
        LNE_FinancialCalculator.currentlyRunning = false;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        LNE_FinancialCalculator.checkIfCanRunCalculations();
        
        Deal__c testDeal = [select 
                            Id,
                            ProfitShareAmountAtProjection__c,
                            ProfitShareAmountAtSellout__c,
                            ExpenseAdjustmentShareAmountAtProj__c,
                            ExpenseAdjustmentShareAmountAtSell__c,
                            CoPromoterBonusAtProjection__c,
                            CoPromoterBonusAtSellout__c,
                            CoPromoterWalkoutAtProjection__c,
                            CoPromoterWalkoutAtSellout__c,
                            AncillaryShareAmountAtProjection__c,
                            AncillaryShareAmountAtSellout__c,
                            Type__c,
                            PrimarySecondaryCoPromoter__c,
                            RollUpAncillaryShareAmtAtProj__c,
                            RollUpExpenseAdjustmentAtProjection__c,
                            RollUpPriCoProAncilShareAtProj__c,
                            RollUpPriCoProExpenseShareAtProj__c,
                            RollUpBonusDetailsCount__c
                                From Deal__c where event__c =:tsettings.testEvent.Id and Id = :deal2.Id];
                                 
        System.assertEquals(-550, testDeal.ProfitShareAmountAtProjection__c);
        System.assertEquals(-550, testDeal.ProfitShareAmountAtSellout__c);
		test.stopTest();
	}
	
	/**
	 * US703:  Ledger Entries for Co-Promoter Payouts test
	 * 
	 * */
	static testMethod void  verifyLedgerPayouts1() {
        LNE_FinancialCalculator.currentlyRunning = true;
        
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];
		
		test.startTest();
		
		EventDateTime__c evtDateTime = new EventDateTime__c(
            event__c = tsettings.testEvent.Id, 
            EventYear__c = String.valueOf(System.now().year() + 2),
            StartTime__c = '8:00 PM');
        insert evtDateTime;
        
	    //Ancillary
	    LedgerEntry__c ledgerEntry2 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('40205').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_ANCILLARY_ID,
            RateType__c = 'Flat',
            NetRevenue__c = 100000,
            NetRevenueatSellout__c = 100000
        );
    
        insert new List<LedgerEntry__c>{ledgerEntry2};
        
		Deal__c deal1 = new Deal__c();
    	deal1.Event__c = tsettings.testEvent.Id;
        deal1.Type__c = '3rd Party';
        deal1.CoPromoter__c = copro1.id;
        deal1.EventProfit__c = 50;
        deal1.EventLoss__c = 50;
        deal1.ExpenseAdjustmentProfit__c = 50;
        deal1.ExpenseAdjustmentLoss__c = 50;
        deal1.AncillaryRevenue__c = 50;
        deal1.PrimarySecondaryCoPromoter__c = 'Primary';
        deal1.ShareInTalentOverhead__c = false;
        deal1.DownsideRisk__c = True;
        deal1.RecordTypeId = RT_DEAL_COPROMOTER_ID;
	
		LNE_FinancialCalculator.currentlyRunning = false;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        insert new List<Deal__c>{deal1};
        LNE_FinancialCalculator.currentlyRunning = true;
        
        //
        // Test 1: verify Co-Promote Expense ledger expense for Plan and Projection 
        //
        List<LedgerEntry__c> les = new List<LedgerEntry__c>();
        les =[select id, PlanAmount__c, ProjectionAmount__c from LedgerEntry__c 
            where Event__c =:tsettings.testEvent.Id and GLAccount__c =:glAccountsMap.get(COPRO_EXPENSE_GL_CODE).Id];
        
        system.assertEquals(1, les.size());
        system.assertNotEquals(null, les[0].PlanAmount__c);
        
        tsettings.testEvent.Status__c = 'Pending Likely';
        update tsettings.testEvent;
        
        test.stopTest();

        tsettings.testEvent.Status__c = 'Confirmed';
        update tsettings.testEvent;
        
        LNE_FinancialCalculator.currentlyRunning = false;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        LNE_FinancialCalculator.checkIfCanRunCalculations();
        
        les =[select id, PlanAmount__c, ProjectionAmount__c from LedgerEntry__c 
            where Event__c =:tsettings.testEvent.Id and GLAccount__c =:glAccountsMap.get(COPRO_EXPENSE_GL_CODE).Id];
            
        system.assertNotEquals(null, les[0].ProjectionAmount__c);
	}
	
	/**
	 * US703:  Ledger Entries for Co-Promoter Payouts test
	 * 
	 * */
	static testMethod void  verifyLedgerPayouts2() {
		LNE_FinancialCalculator.currentlyRunning = true;
		
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];
		
		EventDateTime__c evtDateTime = new EventDateTime__c(
            event__c = tsettings.testEvent.Id, 
            EventYear__c = String.valueOf(System.now().year() + 2),
            StartTime__c = '8:00 PM');
        insert evtDateTime;
		
		Account venue = [select Id from Account where Id = :tsettings.testEvent.Venue__c];
        venue.OwnershipType__c = 'Third Party';
        update venue;
        
		test.startTest();
        
	    //Ancillary
	    LedgerEntry__c ledgerEntry2 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('40205').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_ANCILLARY_ID,
            RateType__c = 'Flat',
            NetRevenue__c = 100000,
            NetRevenueatSellout__c = 100000
        );
    
        insert new List<LedgerEntry__c>{ledgerEntry2};
        
		Deal__c deal1 = new Deal__c();
    	deal1.Event__c = tsettings.testEvent.Id;
        deal1.Type__c = 'Venue';
        deal1.CoPromoter__c = copro1.id;
        deal1.EventProfit__c = 50;
        deal1.EventLoss__c = 50;
        deal1.ExpenseAdjustmentProfit__c = 50;
        deal1.ExpenseAdjustmentLoss__c = 50;
        deal1.AncillaryRevenue__c = 50;
        deal1.PrimarySecondaryCoPromoter__c = 'Primary';
        deal1.ShareInTalentOverhead__c = false;
        deal1.DownsideRisk__c = True;
        deal1.RecordTypeId = RT_DEAL_COPROMOTER_ID;
	
		LNE_FinancialCalculator.currentlyRunning = false;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        insert new List<Deal__c>{deal1};
        LNE_FinancialCalculator.currentlyRunning = true;
        
        //
        // Test 1: verify Building Co-Promote ledger expense for Plan and Projection 
        //
        List<LedgerEntry__c> les = new List<LedgerEntry__c>();
        les =[select id, PlanAmount__c, ProjectionAmount__c from LedgerEntry__c 
            where Event__c =:tsettings.testEvent.Id and GLAccount__c =:glAccountsMap.get(COPRO_BOOKING_GL_CODE).Id];
        
        system.assertEquals(1, les.size());
        system.assertNotEquals(null, les[0].PlanAmount__c);
        
        tsettings.testEvent.Status__c = 'Pending Likely';
        update tsettings.testEvent;

        Test.stopTest();

        tsettings.testEvent.Status__c = 'Confirmed';
        update tsettings.testEvent;
        
        LNE_FinancialCalculator.currentlyRunning = false;
        LNE_FinancialCalculator.runUpdates = true;
        LNE_FinancialCalculator.addEventId(tsettings.testEvent.Id);
        LNE_FinancialCalculator.checkIfCanRunCalculations();
        
        les =[select id, PlanAmount__c, ProjectionAmount__c from LedgerEntry__c 
            where Event__c =:tsettings.testEvent.Id and GLAccount__c =:glAccountsMap.get(COPRO_BOOKING_GL_CODE).Id];
            
        system.assertNotEquals(null, les[0].ProjectionAmount__c);
	}
}