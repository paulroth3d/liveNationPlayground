@isTest
private class LNE_DealCoPromoter_T_Test {
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
	 * @description Test that DSLs are created when a CoPromoter Deals is created(if there are ledger entries)
	 * */
	static testMethod void  testCreateDSLs() {
        TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
		Account copro1 = [select Id from Account where name = 'Co Pro 1'];
		//Account copro2 = [select Id from Account where name = 'Co Pro 2'];
		
		test.startTest();

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
        
	    //Ancillary
	    LedgerEntry__c ledgerEntry2 = new LedgerEntry__c(
            GLAccount__c = glAccountsMap.get('40205').Id,
            Event__c = tsettings.testEvent.Id,
            RecordTypeId = RT_ANCILLARY_ID,
            RateType__c = 'Flat',
            NetRevenue__c = 111,
            NetRevenueatSellout__c = 222
        );
    
        insert new List<LedgerEntry__c>{ledgerEntry1, ledgerEntry2};
        
		Deal__c deal1 = new Deal__c();
    	deal1.Event__c = tsettings.testEvent.Id;
        deal1.Type__c = '3rd Party';
        deal1.CoPromoter__c = copro1.id;
        deal1.EventProfit__c = 20;
        deal1.EventLoss__c = 30;
        deal1.ExpenseAdjustmentProfit__c = 40;
        deal1.ExpenseAdjustmentLoss__c = 50;
        deal1.AncillaryRevenue__c = 60;
        deal1.PrimarySecondaryCoPromoter__c = 'Primary';
        deal1.ShareInTalentOverhead__c = True;
        deal1.DownsideRisk__c = True;
        deal1.RecordTypeId = RT_DEAL_COPROMOTER_ID;
        
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
        
        //
        // Test 1: test create DSLs
        //
        List<DealSettlementLedger__c> dsls = new List<DealSettlementLedger__c>();
        dsls = [select Id from DealSettlementLedger__c where Deal__c = :deal1.id];
        System.assertEquals(2, dsls.size());
        
        //
        // Test 2: test prevent delete of Live Nation CoPromoter Row if user doesn't have permission
        //
        Deal__c PrimaryLNERow = [select Id, CoPromoter__c, RecordTypeId from Deal__c where Type__c = 'Internal' AND PrimarySecondaryCoPromoter__c = 'Primary'];
        // manually turn off global data admin for current user so test will work
        GeneralSettings__c gs = [select id, GlobalDataAdministrator__c from GeneralSettings__c];
        gs.GlobalDataAdministrator__c = false;
        update gs;
        LNE_DealCoPromoter_T.checkDeletePermission(new List<Deal__c>{PrimaryLNERow});
    
        //
        // Test 3: test update remainders on the LNERow
        //
        // manually turn on global data admin for current user so test will work
        gs.GlobalDataAdministrator__c = true;
        update gs;

        LNE_DealCoPromoter_T.updateRemainderOnDelete(new List<Deal__c>{deal1, deal2});
        PrimaryLNERow = [select Id, CoPromoter__c, RecordTypeId, EventLoss__c, EventProfit__c, ExpenseAdjustmentLoss__c, ExpenseAdjustmentProfit__c, AncillaryRevenue__c from Deal__c where Type__c = 'Internal' AND PrimarySecondaryCoPromoter__c = 'Primary'];
        System.assertEquals(80, PrimaryLNERow.EventProfit__c);
        System.assertEquals(70, PrimaryLNERow.EventLoss__c);
        System.assertEquals(60, PrimaryLNERow.ExpenseAdjustmentProfit__c);
        System.assertEquals(50, PrimaryLNERow.ExpenseAdjustmentLoss__c);
        System.assertEquals(40, PrimaryLNERow.AncillaryRevenue__c);
        
        Deal__c SecondaryLNERow = [select Id, CoPromoter__c, RecordTypeId, EventLoss__c, EventProfit__c, ExpenseAdjustmentLoss__c, ExpenseAdjustmentProfit__c, AncillaryRevenue__c from Deal__c where Type__c = 'Internal' AND PrimarySecondaryCoPromoter__c = 'Secondary'];
        System.assertEquals(50, SecondaryLNERow.EventProfit__c);
        System.assertEquals(50, SecondaryLNERow.EventLoss__c);
        System.assertEquals(50, SecondaryLNERow.ExpenseAdjustmentProfit__c);
        System.assertEquals(50, SecondaryLNERow.ExpenseAdjustmentLoss__c);
        System.assertEquals(50, SecondaryLNERow.AncillaryRevenue__c);
                                 
  
		test.stopTest();
	}
	
	
	
	
}