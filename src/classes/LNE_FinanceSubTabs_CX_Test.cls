@isTest
private class LNE_FinanceSubTabs_CX_Test {
    
    class TestSettings {
		public Event__c testEvent {get; set;}
		
		public TestSettings() {
		    
		}
		
		public void typicalSetup(){
		    testEvent = [select Id, Venue__c from Event__c limit 1];
		}
		
		public void finalize(){
		}
	}
	
	
	@testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet();
    }
    
	private static testMethod void test() {
	    TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		
	    ApexPages.StandardController standardEventCtlr = new ApexPages.StandardController(tsettings.testEvent);
        LNE_FinanceSubTabs_CX financeSubTabs = new LNE_FinanceSubTabs_CX(standardEventCtlr);
        
        Event__c evt = [select ArtistSettlementComplete__c, SettlementRecapComplete__c, EventRecapComplete__c,
        	MetricsComplete__c, FlashComplete__c, 
            FlashIntegrationStatus__c, OracleExportComplete__c, BoxOfficeImportComplete__c,
            ArtistSettlementCompletedBy__c, SettlementRecapCompletedBy__c, EventRecapCompletedBy__c,
            MetricsCompletedBy__c, FlashCompletedBy__c,
            OracleExportCompletedBy__c, BoxOfficeImportCompletedBy__c, Status__c
            from Event__c where id = :tsettings.testEvent.Id];
        evt.Status__c = 'Pending Likely';
        update evt;
        
        evt.Status__c = 'Flash Started';
        update evt;
            
        system.assertEquals(false, evt.SettlementRecapComplete__c);
        system.assertEquals(false, evt.MetricsComplete__c);
        system.assertEquals(false, evt.OracleExportComplete__c);
        system.assertEquals(false, evt.FlashComplete__c);
        
        //
        // Test 1: complete settlement recap
        //
        financeSubTabs.completeSettlementRecap();
        
        evt = [select ArtistSettlementComplete__c, SettlementRecapComplete__c, EventRecapComplete__c,
        	MetricsComplete__c, FlashComplete__c, 
            FlashIntegrationStatus__c, OracleExportComplete__c, BoxOfficeImportComplete__c,
            ArtistSettlementCompletedBy__c, SettlementRecapCompletedBy__c, EventRecapCompletedBy__c,
            MetricsCompletedBy__c, FlashCompletedBy__c,
            OracleExportCompletedBy__c, BoxOfficeImportCompletedBy__c
            from Event__c where id = :tsettings.testEvent.Id];
            
        system.assertEquals(true, evt.SettlementRecapComplete__c);
        system.assertEquals(false, evt.MetricsComplete__c);
        system.assertEquals(false, evt.OracleExportComplete__c);
        system.assertEquals(false, evt.FlashComplete__c);
        
        //
        // Test 2: complete Metrics
        //
        financeSubTabs.completeEventMetrics();
        
        evt = [select ArtistSettlementComplete__c, SettlementRecapComplete__c, EventRecapComplete__c,
        	MetricsComplete__c, FlashComplete__c, 
            FlashIntegrationStatus__c, OracleExportComplete__c, BoxOfficeImportComplete__c,
            ArtistSettlementCompletedBy__c, SettlementRecapCompletedBy__c, EventRecapCompletedBy__c,
            MetricsCompletedBy__c, FlashCompletedBy__c,
            OracleExportCompletedBy__c, BoxOfficeImportCompletedBy__c
            from Event__c where id = :tsettings.testEvent.Id];
            
        system.assertEquals(true, evt.SettlementRecapComplete__c);
        system.assertEquals(true, evt.MetricsComplete__c);
        system.assertEquals(false, evt.OracleExportComplete__c);
        system.assertEquals(false, evt.FlashComplete__c);
        financeSubTabs.refreshFlags();
        
        //
        // Test 3: complete flash
        //
        financeSubTabs.completeFlash();
        
        evt = [select ArtistSettlementComplete__c, SettlementRecapComplete__c, EventRecapComplete__c,
        	MetricsComplete__c, FlashComplete__c, 
            FlashIntegrationStatus__c, OracleExportComplete__c, BoxOfficeImportComplete__c,
            ArtistSettlementCompletedBy__c, SettlementRecapCompletedBy__c, EventRecapCompletedBy__c,
            MetricsCompletedBy__c, FlashCompletedBy__c,
            OracleExportCompletedBy__c, BoxOfficeImportCompletedBy__c
            from Event__c where id = :tsettings.testEvent.Id];
            
        system.assertEquals(true, evt.SettlementRecapComplete__c);
        system.assertEquals(true, evt.MetricsComplete__c);
        system.assertEquals(false, evt.OracleExportComplete__c);
        system.assertEquals(true, evt.FlashComplete__c);
        
        //
        // Test 4: export to oracle
        //
        financeSubTabs.exportToOracle();
        
        evt = [select ArtistSettlementComplete__c, SettlementRecapComplete__c, EventRecapComplete__c,
        	MetricsComplete__c, FlashComplete__c, 
            FlashIntegrationStatus__c, OracleExportComplete__c, BoxOfficeImportComplete__c,
            ArtistSettlementCompletedBy__c, SettlementRecapCompletedBy__c, EventRecapCompletedBy__c,
            MetricsCompletedBy__c, FlashCompletedBy__c,
            OracleExportCompletedBy__c, BoxOfficeImportCompletedBy__c
            from Event__c where id = :tsettings.testEvent.Id];
            
        system.assertEquals(true, evt.SettlementRecapComplete__c);
        system.assertEquals(true, evt.MetricsComplete__c);
        system.assertEquals(true, evt.OracleExportComplete__c);
        system.assertEquals(true, evt.FlashComplete__c);
        
        evt.FlashIntegrationStatus__c = 'Oracle Updated';
        update evt;
        
        financeSubTabs.refreshFlags();
        
        // @todo
        // Test 5: Test if not flash user
        //
        
        
        
	}

}