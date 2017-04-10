@isTest
public class LNE_GridBuddyCalculationAPI_CX_Test {
	
	static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';
	
	class TestSettings {
		
		public TestSettings() {}
		
		public LedgerEntry__c typicalSetup(){
			
		 List<LedgerEntry__c> savedLedgerEntries = new List<LedgerEntry__c>();
			
		 Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
				new String[]{ RT_Ancillary }
			);
			Id RT_ANCILLARY_ID = recordTypeMap.get( RT_Ancillary );
		
			  GLAccount__c testGlaAcct1 = new GLAccount__c (
				Type__c = 'Ancillary',
				Name = 'Parking Revenue',
				Category__c = 'Other Event Revenue',
					GLCode__c = '12345'
			);
			
			insert testGlaAcct1;
			
			Event__c Evt1 = new Event__c(
				ProjectedPaidTickets__c = 20000,
				ProjectedDropCount__c = 30000
			);
			
			LNE_TestObjectFactory.createStandardDataSet( Evt1 );
			
			LedgerEntry__c Ledger1 = new LedgerEntry__c (
				GLAccount__c = testGlaAcct1.Id,
				BaseAmount__c = 33343,
				RateType__c = 'Flat', 
				RecordTypeId = RT_ANCILLARY_ID,
				Event__c = Evt1.Id
			); 

			insert Ledger1;
		   
			return Ledger1;
		}
		
		public void finalize(){}
	}
	
	//-- test test methods here

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
	
	static testMethod void runSetupAWithoutException() {
		try {
			TestSettings ts = new TestSettings();
			ts.typicalSetup();
			ts.finalize();
		} catch( Exception err ){
			System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
		}
	}
	
	//-- test functionality here
	
	static testMethod void testLedgerEntryAPI() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
		ledgerEntry.BaseAmount__c = 5;
		ledgerEntry.RateType__c = 'Per Cap';
		ledgerEntry.Min__c = 180000;
		ledgerEntry.Max__c = 300000;
		ledgerEntry.ApplyTicketScale__c = 'All Drop Count';
		ledgerEntry.ContraPercent__c = 0.44;
		ledgerEntry.ContraAmount__c = 0;
		ledgerEntry.X3rdPartyPercent__c = 0;
		ledgerEntry.ContraType__c = 'Per Cap';
		
		PageReference pageRef = Page.LNE_GridBuddyCalculationAPI;
		pageRef.getParameters().put('LedgerEntry__c', JSON.serialize(ledgerEntry));
		pageRef.getParameters().put('callback', 'testApiCallback2');
		Test.setCurrentPageReference(pageRef);
		LNE_GridBuddyCalculationAPI_CX api = new LNE_GridBuddyCalculationAPI_CX();
		api.processRequest();
	}

	static testMethod void testLedgerEntryBreakoutAPI() {
		TestSettings ts = new TestSettings();
		LedgerEntry__c ledgerEntry = ts.typicalSetup();
		ledgerEntry.BaseAmount__c = 5;
		ledgerEntry.RateType__c = 'Per Cap';
		ledgerEntry.Min__c = 180000;
		ledgerEntry.Max__c = 300000;
		ledgerEntry.ApplyTicketScale__c = 'All Drop Count';
		ledgerEntry.ContraPercent__c = 0.44;
		ledgerEntry.ContraAmount__c = 0;
		ledgerEntry.X3rdPartyPercent__c = 0;
		ledgerEntry.ContraType__c = 'Per Cap';
		
		Test.startTest();
		
		update ledgerEntry;

		LedgerEntryBreakout__c leb = new LedgerEntryBreakout__c (
            BaseAmount__c = 33343,
            RateType__c = 'Flat', 
            LedgerEntry__c = ledgerEntry.Id,
            OfferRate__c  = 123.5,                  
            InHouseRateType__c = 'Flat',
            InHouseRate__c = 98         
        );
		
		PageReference pageRef = Page.LNE_GridBuddyCalculationAPI;
		pageRef.getParameters().put('LedgerEntryBreakout__c', JSON.serialize(leb));
		pageRef.getParameters().put('callback', 'testApiCallback2');
		Test.setCurrentPageReference(pageRef);
		LNE_GridBuddyCalculationAPI_CX api = new LNE_GridBuddyCalculationAPI_CX();
		api.processRequest();
	}
}