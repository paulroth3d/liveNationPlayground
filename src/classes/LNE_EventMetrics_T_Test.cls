@isTest
public class LNE_EventMetrics_T_Test {
	
	static final String RT_Expenses = 'LedgerEntry__c.Expenses';
	
	@testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
	
	class TestSettings {
		
		Event__c testEvent;
		Map<String,GLAccount__c> glAccountMap;
		LedgerEntry__c[] testLedgerEntries;
		
		public TestSettings() {}
		
		public void typicalSetup(){
			testEvent = new Event__c(
				ProjectedPaidTickets__c = 10000,
				ProjectedDropCount__c = 10000,
                ActualDropCount__c = 10000,
                SelloutDropCount__c= 3000,
                Status__c = 'Draft',
                EventStartTimeEntered__c = true
			);
            
            LNE_TestObjectFactory.createStandardDataSet(testEvent);
            
             EventDateTime__c evtdt1 = new EventDateTime__c(
            	EventDate__c = date.today(),
                StartTime__c = '11:00 AM',
                Event__c = testEvent.Id
            );
            
            insert evtdt1;
            
            this.glAccountMap = LNE_Util.refreshGLAccountCache();
		    
		    System.assert( glAccountMap != null && glAccountMap.size() > 0, 'GL Accounts should be created already from the createStandardDataSet method above' );
			Id glAccountId1 = this.glAccountMap.get( LNE_TestObjectFactory.GL_ALCOHOLIC_REVENUE ).Id;
			Id glAccountId2 = this.glAccountMap.get( LNE_TestObjectFactory.GL_PARKING_REVENUE ).Id;
			
			testLedgerEntries = new LedgerEntry__c[]{
				//-- first ledger entry
				new LedgerEntry__c(
			        GLAccount__c = glAccountId1,
			        BaseAmount__c = 111,
			        RateType__c = 'Flat',
			        PlanAmount__c = 111,
			        COGSAtForecast__c = 111,
			        InHouseProjection__c = 111,
			        GrossRevenue__c = 111,
			        NetRevenue__c = 111,
			        ContraAtForecast__c = 111,
			        Event__c = testEvent.Id
		        ),
				
				//-- second ledger entry
				new LedgerEntry__c(
			        GLAccount__c = glAccountId2,
			        BaseAmount__c = 111,
			        RateType__c = 'Flat',
			        PlanAmount__c = 111,
			        COGSAtForecast__c = 111,
			        InHouseProjection__c = 111,
			        GrossRevenue__c = 111,
			        NetRevenue__c = 111,
			        ContraAtForecast__c = 111,
			        Event__c = testEvent.Id
		        )
			};
			
			insert testLedgerEntries;
        }
        
		public void finalize() {}
	}
	
	static testMethod void runSetupAWithoutException() {
		try {
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_GeneralSettingsUtil.setLocalBypassSettings(false, true, false, false);
			Test.startTest();
			TestSettings ts = new TestSettings();
			ts.typicalSetup();
			ts.finalize();
		} catch( Exception err ){
			System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
		}
	}
	
	static testMethod void testLedgers_PlanToProjection() {
		LNE_FinancialCalculator.currentlyRunning = true;
		LNE_GeneralSettingsUtil.setLocalBypassSettings(false, true, false, false);
		
		Test.startTest();
		
		TestSettings ts = new TestSettings();
	 	ts.typicalSetup();
        
        List<LedgerEntry__c> ledgers = [SELECT PlanAmount__c, ProjectionAmount__c FROM LedgerEntry__c WHERE Id IN :ts.testLedgerEntries];
        
        system.assertEquals(2, ledgers.size());
        
        for (LedgerEntry__c l : ledgers) {
        	system.assertEquals(111, l.PlanAmount__c);
        	system.assertEquals(null, l.ProjectionAmount__c);
        }
    
    	ts.testEvent.Status__c = 'Pending Likely';
    	
    	update ts.testEvent;
    
      	ts.testEvent.Status__c = 'Confirmed';
    
    	update ts.testEvent;
    	
    	ledgers = [SELECT PlanAmount__c, ProjectionAmount__c FROM LedgerEntry__c WHERE Id IN :ts.testLedgerEntries];
        
        for (LedgerEntry__c l : ledgers) {
        	system.assertEquals(111, l.PlanAmount__c);
        	system.assertEquals(111, l.ProjectionAmount__c);
        }
        	
        Test.stopTest(); 
	}
	
	static testMethod void testLedgers_ProjectionToPlan() {
		LNE_FinancialCalculator.currentlyRunning = true;
		LNE_GeneralSettingsUtil.setLocalBypassSettings(false, true, false, false);
		
		Test.startTest();
		
		TestSettings ts = new TestSettings();
	 	ts.typicalSetup();
        
        List<LedgerEntry__c> ledgers = [SELECT PlanAmount__c, ProjectionAmount__c FROM LedgerEntry__c WHERE Id IN :ts.testLedgerEntries];
        
        system.assertEquals(2, ledgers.size());
        
        for (LedgerEntry__c l : ledgers) {
        	system.assertEquals(111, l.PlanAmount__c);
        	system.assertEquals(null, l.ProjectionAmount__c);
        }
    
    	ts.testEvent.Status__c = 'Pending Likely';
    	
    	update ts.testEvent;
    
      	ts.testEvent.Status__c = 'Confirmed';
    
    	update ts.testEvent;
    	
    	ledgers = [SELECT PlanAmount__c, ProjectionAmount__c FROM LedgerEntry__c WHERE Id IN :ts.testLedgerEntries];
        
        for (LedgerEntry__c l : ledgers) {
        	system.assertEquals(111, l.PlanAmount__c);
        	system.assertEquals(111, l.ProjectionAmount__c);
        	
        	l.ProjectionAmount__c = 222;
        }
        
        update ledgers;
        
        ts.testEvent.Status__c = 'Pending Likely';
    	
    	update ts.testEvent;
    	
    	ledgers = [SELECT PlanAmount__c, ProjectionAmount__c FROM LedgerEntry__c WHERE Id IN :ts.testLedgerEntries];
        
        for (LedgerEntry__c l : ledgers) {
        	system.assertEquals(222, l.PlanAmount__c);
        	system.assertEquals(222, l.ProjectionAmount__c);
        }
        	
        Test.stopTest(); 
	}
}