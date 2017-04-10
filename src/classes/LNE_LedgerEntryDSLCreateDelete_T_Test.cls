@isTest
private class LNE_LedgerEntryDSLCreateDelete_T_Test {
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
    
    //
    // Test1: DSL Creation on insert of Ledger Entry where SettleAtActual__c = false
    ///
	private static testMethod void test1() {
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];
		Deal__c PrimaryInternalDeal = [select Id from Deal__c where Type__c = 'Internal' AND PrimarySecondaryCoPromoter__c = 'Primary'];
		
		test.startTest();
		
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
        insert deal1;

		//Expense
		LedgerEntry__c ledgerEntry1 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('50103').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_EXPENSES_ID,
            SettleAtActual__c = false,
            ExpenseAdjustment__c = 333,
            OfferAtSellout__c = 200, // OfferAtSellout__c - InHouseatSellout__c = le.ExpenseAdjustmentatSellout__c //calculated in FC
            InHouseatSellout__c = 100
        );
    
        insert new List<LedgerEntry__c>{ledgerEntry1};
        
        DealSettlementLedger__c[] dsls = new DealSettlementLedger__c[]{};
        dsls = [select id from DealSettlementLedger__c where LedgerEntry__c = :ledgerEntry1.Id and Deal__c =:deal1.id];
        
        // did trigger create DSL?
        system.assertEquals(1, dsls.size());
        
        //
        // Test 2: DSL deletion on update when LedgerEntry__c.SettleAtActual__c = true
        //
        ledgerEntry1.SettleAtActual__c = true;
        update ledgerEntry1;
        
        dsls = [select id from DealSettlementLedger__c where LedgerEntry__c = :ledgerEntry1.Id and Deal__c =:deal1.id];
        
        // did trigger delete DSL?
        system.assertEquals(0, dsls.size());
        
		test.stopTest();
	}
	
	//
    // Test 3: DSL Creation on update of Ledger Entry where SettleAtActual__c is updated from true to false
    ///
	private static testMethod void test2() {
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];
		Deal__c PrimaryInternalDeal = [select Id from Deal__c where Type__c = 'Internal' AND PrimarySecondaryCoPromoter__c = 'Primary'];
		
		test.startTest();
		
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
        insert deal1;

		//Expense
		LedgerEntry__c ledgerEntry1 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('50103').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_EXPENSES_ID,
            SettleAtActual__c = true,
            ExpenseAdjustment__c = 333,
            OfferAtSellout__c = 200, // OfferAtSellout__c - InHouseatSellout__c = le.ExpenseAdjustmentatSellout__c //calculated in FC
            InHouseatSellout__c = 100
        );
    
        insert new List<LedgerEntry__c>{ledgerEntry1};
        
        DealSettlementLedger__c[] dsls = new DealSettlementLedger__c[]{};
        
        //
        // Test 3: DSL creation on update when LedgerEntry__c.SettleAtActual__c = false
        //
        ledgerEntry1.SettleAtActual__c = false;
        update ledgerEntry1;
        
        dsls = [select id from DealSettlementLedger__c where LedgerEntry__c = :ledgerEntry1.Id and Deal__c =:deal1.id];
        
        // did trigger delete DSL?
        system.assertEquals(1, dsls.size());
        
		test.stopTest();
	}
	
	//
    // Test 4: test deleting ledger entry trigger financial calculator
    ///
	private static testMethod void test3() {
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];

		test.startTest();

		//Expense
		LedgerEntry__c ledgerEntry1 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('50103').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_EXPENSES_ID,
            SettleAtActual__c = true,
            ExpenseAdjustment__c = 333,
            OfferAtSellout__c = 200, // OfferAtSellout__c - InHouseatSellout__c = le.ExpenseAdjustmentatSellout__c //calculated in FC
            InHouseatSellout__c = 100
        );
    
        insert new List<LedgerEntry__c>{ledgerEntry1};
        
        // Test 4: test deleting ledger entry trigger financial calculator
        LNE_LedgerEntryDSLCreateDelete_T.executeDelete(new List<LedgerEntry__c>{ledgerEntry1});
        
		test.stopTest();
	}

}