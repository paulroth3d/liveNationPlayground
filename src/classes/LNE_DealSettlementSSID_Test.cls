/**
 * 
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LNE_DealSettlementSSID_Test {
	
	public static final String GL_CODE_LEDGER_ENTRY = '40205';//'50103';
	
	public static final String CO_PRO_1 = 'Co Pro 1';
	public static final String CO_PRO_2 = 'Co Pro 2';
	
	static String RT_EXPENSES = 'LedgerEntry__c.Expenses';
	static String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
	static String RT_COPROMOTER = 'Account.CoPromoter';
	static String RT_DEAL_COPROMOTER = 'Deal__c.CoPromoter';
    
	static Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
	    new String[]{ RT_EXPENSES, RT_ANCILLARY, RT_COPROMOTER, RT_DEAL_COPROMOTER }
    );
	
	static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    static Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );
    static Id RT_ACCOUNT_COPROMOTER_ID = recordTypeMap.get( RT_COPROMOTER );
    static Id RT_DEAL_COPROMOTER_ID = recordTypeMap.get( RT_DEAL_COPROMOTER );
    
    public static Event__c currentEvent;
	
	public static final String CURRENT_EVENT_NAME = 'MyTestEvent';
	
	@testSetup
	static void setup(){
		
		Event__c event = new LNE_TestObjectFactory(
	        LNE_TestObjectFactory.createEvent()
		).addProperties( new Map<String,Object>{
			'EventName__c' => CURRENT_EVENT_NAME,
		    'Status__c' => 'Draft',
		    'TotalSupportActExpenses__c' => 0.0
		}).buildEvent();
		
		LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet( event );
	}

    class TestSettings {
    	
    	Map<String,GLAccount__c> glAccountsMap = LNE_Util.getGLAccounts(new String[] { GL_CODE_LEDGER_ENTRY });
    	
    	Account copro1, copro2;
    	Event__c event;
    	Deal__c currentDeal;
    	Deal__c newDeal;
    	LedgerEntry__c currentLedger;
    	DealSettlementLedger__c currentDSL;

        public TestSettings() {
        	
        	//-- disable the financial calculator for this test.
        	//-- it isn't needed, and only makes the test take longer.
        	LNE_FinancialCalculator.currentlyRunning = true;
			
            this.event = [ SELECT Id, EventName__c
            	FROM event__c
            	limit 1
            ];
            
            //-- generated from createStandardDataSet 
            Set<String> coProNames = new Set<String>{ CO_PRO_1, CO_PRO_2 };
            for( Account coPro: [SELECT Id, Name FROM Account WHERE name in :coProNames ]){
            	if( CO_PRO_1.equals( coPro.Name ) ){
            		this.copro1 = coPro;
            	} else if( CO_PRO_2.equals( coPro.name )){
            		this.copro2 = coPro;
            	}
            }

            glAccountsMap = LNE_Util.getGLAccounts(new String[] { GL_CODE_LEDGER_ENTRY });
            
            System.debug( 'glAccountsMap' );
            System.debug( glAccountsMap );
            
            //-- based on LNE_LedgerEntryDSLCreateDelete_T
            //-- appears to require that the recordTYpe is CoPromoter and the CoPromoter is not liveNation.
            this.currentLedger = new LedgerEntry__c(
	            GLAccount__c = glAccountsMap.get( GL_CODE_LEDGER_ENTRY ).Id,
	            Event__c = event.Id,
	            RecordTypeId = RT_ANCILLARY_ID,
	            SettleAtActual__c = false,
	            ExpenseAdjustment__c = 333,
	            OfferAtSellout__c = 200, // OfferAtSellout__c - InHouseatSellout__c = le.ExpenseAdjustmentatSellout__c //calculated in FC
	            InHouseatSellout__c = 100,
	            SourceSystemId__c = '309576-50138'
	        );
	        insert this.currentLedger;
	        
	        //-- based on LNE_LedgerEntryDSLCreateDelete_T
            //-- appears to require RecordType of Ancillary and appropriate GL CODE
            this.currentDeal = new Deal__c (
				Event__c = event.Id,
				Type__c = '3rd Party',
				CoPromoter__c = copro1.id,
				EventProfit__c = 50,
				EventLoss__c = 50,
				ExpenseAdjustmentProfit__c = 50,
				ExpenseAdjustmentLoss__c = 50,
				AncillaryRevenue__c = 50,
				PrimarySecondaryCoPromoter__c = 'Primary',
				ShareInTalentOverhead__c = True,
				DownsideRisk__c = True,
				RecordTypeId = RT_DEAL_COPROMOTER_ID,
				SourceSystemId__c = 'Deal-123423'
            );
            insert this.currentDeal;
            System.debug( 'currentDeal' );
            System.debug( currentDeal );
            
            //-- @TODO: support testing updates updates the SourceSystemId more thoroughly.
            //-- initial attempt seems to cause an exception where the account BillingCountryCode is null,
            //-- but it isn't null when trying it before..?
            /*
            this.newDeal = new Deal__c (
				Event__c = event.Id,
				Type__c = '3rd Party',
				CoPromoter__c = this.copro2.id,
				EventProfit__c = 50,
				EventLoss__c = 50,
				ExpenseAdjustmentProfit__c = 50,
				ExpenseAdjustmentLoss__c = 50,
				AncillaryRevenue__c = 50,
				PrimarySecondaryCoPromoter__c = 'Primary',
				ShareInTalentOverhead__c = True,
				DownsideRisk__c = True,
				RecordTypeId = RT_DEAL_COPROMOTER_ID,
				SourceSystemId__c = 'Deal-789789'
            );
            //insert this.newDeal;
            */
        }
        
        public void setupWithExistingDSL(){
        	System.debug( 'ledgerEntries' );
	        System.debug( [ SELECT Id, SourceSystemId__c from LedgerEntry__c ] );
	        
        	//-- dsl created for us.
        	//currentDSL = new DealSettlementLedger__c(
        	//	LedgerEntry__c = this.currentLedger.Id,
        	//	Deal__c = this.currentDeal.Id,
        	//	Share__c = false
        	//);
        	
        	this.currentDSL = [ SELECT Id, LedgerEntry__c, Deal__c, SourceSystemId__c
	        	FROM DealSettlementLedger__c
	        	WHERE LedgerEntry__c = :this.currentLedger.Id and Deal__c = :this.currentDeal.Id
	        	LIMIT 1
	        ];
        }
		
		public void finalize(){
			/*
			System.debug( 'ledgerEntries' );
	        System.debug( [ SELECT Id, SourceSystemId__c from LedgerEntry__c ] );
	        
	        System.debug( 'My Ledger Entry' );
	        System.debug( this.currentLedger );
	        
	        System.debug( 'MY Deal' );
	        System.debug( this.currentDeal );
	        
	        System.debug( 'currentDSL' );
	        System.debug( this.currentDSL );
	        
	        System.debug( 'ALLDSLs' );
	        System.debug( [ SELECT id, LedgerEntry__c, Deal__c, SourceSystemId__c from DealSettlementLedger__c ] );
	        
	        System.debug( 'what we want:' );
	        System.debug( [ SELECT Id, LedgerEntry__c, Deal__c, SourceSystemId__c
	        	FROM DealSettlementLedger__c
	        ]);
	        */
		}
    }
    
	
    //-- test test methods here
	
	static testMethod void setupDSL_WithExistingRecord() {
        TestSettings ts = new TestSettings();
    	ts.setupWithExistingDSL();
    	ts.finalize();
    	
    	System.debug( 'setupWithoutExceptions:' ); System.debug( ts.currentDSL );
    	
    	System.assert( ts.currentDSL != null, 'There must be a currentDSL made to get to this point' );
    	
        System.assert( true, 'No Exceptions have occurred in getting here' );
	}
	
	static testMethod void testExistingDSL_SourceSystemId(){
		TestSettings ts = new TestSettings();
        ts.setupWithExistingDSL();
        ts.finalize();
        
        //-- because we are querying, we assume that one is automatically created because of existing triggers.
        //-- so we use it.
        System.assert( ts.currentDSL != null, 'A DSL must have been generated at this point' );
        
        String expectedSourceSystemId = 'Deal-123423-309576-50138';
        System.assert( expectedSourceSystemId.equals( ts.currentDSL.SourceSystemId__c ), 'SourceSystemId__c must be the DealSSID-EventSSID');
	}
	
	//-- @TODO: support testing updated SourceSystemId more thoroughly.
}