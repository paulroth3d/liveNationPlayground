@isTest
private class LNE_CopyPrimaryHeadlinerToCoH_T_Test {
	
	@testSetup
    static void setup(){
        LNE_FinancialCalculator.currentlyRunning = true;
        LNE_TestObjectFactory.prepStandardCustomSettings();
        
        LNE_TestObjectFactory.VenueHierarchy acctHierarchy = LNE_TestObjectFactory.createVenueHierarchy(
            	LNE_TestObjectFactory.ACCT_TYPE_DIVISION, null, null
            );
        
        LNE_TestObjectFactory.createStandardDataSet( null, acctHierarchy );

        Deal__c testDeal1 = [SELECT Id FROM Deal__c WHERE Type__c = 'Primary Headliner' LIMIT 1];
        testDeal1 = new Deal__c(Id = testDeal1.Id,
                                Rank__c = 1,
                                GuaranteeAmount__c = 200,
                                DealType__c = 'Retro Gross Deal',
                                DealCalculation__c = 'Guarantee Only',
                                BackendPercent__c = 1,
                                DealApplicationType__c = 'Paid Tickets',
                                StageType__c = 'Plan');

        update testDeal1;
    }
    
    class TestSettings {
        Event__c testEvent;
        Account testArtist;

        public TestSettings() {

            LNE_FinancialCalculator.currentlyRunning = true;

            testEvent = [SELECT Id FROM Event__c LIMIT 1];
            
            Account[] artists = new Account[]{
                LNE_TestObjectFactory.createAccount( 'Artist1' ),
                LNE_TestObjectFactory.createAccount( 'Artist2' ),
                LNE_TestObjectFactory.createAccount( 'Artist3' )
            };
                
            insert artists;

            testArtist = artists[2];
            
            Deal__c testDeal2 = new Deal__c(Type__c='Co-Headliner',
                                            Rank__c = 2,
                                            Artist__c = artists[1].Id,
                                            GuaranteeAmount__c = 200,
                                            DealType__c = 'Step Up Gross Deal',
                                            DealCalculation__c = 'Inclusive of Other Talent Amount',
                                            Event__c = testEvent.Id,
                                            BackendPercent__c = 2,
                                            DealApplicationType__c = 'To Be Shared Amount',
                                            StageType__c = 'Plan');

            Deal__c testDeal3 = new Deal__c(Type__c='Primary Headliner',
                                            Rank__c = 3,
                                            Artist__c = artists[2].Id,
                                            GuaranteeAmount__c = 200,
                                            DealType__c = 'Step Up Net Deal',
                                            DealCalculation__c = 'Inclusive of Sound & Lights',
                                            Event__c = testEvent.Id,
                                            BackendPercent__c = 3,
                                            DealApplicationType__c = 'To Be Shared Amount',
                                            StageType__c = 'Settlement');

            insert new List<Deal__c>{testDeal2, testDeal3};
        }
        
        public void typicalSetup(){
                
        }
        
        public void finalize(){
        }
    }
    
    /**
     *  Test: The Co-Headliner records copy the values for the Deal Type, Deal Application Type, Backend %, and Deal Calculation 
     *          from the Primary Headliner record and updates after save of the Primary Headliner
     */ 
    static testMethod void testInsertPrimaryHeadliner() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        
        Test.startTest();

        Deal__c testDeal4 = new Deal__c(Type__c='Co-Headliner',
                                        Rank__c = 3,
                                        Artist__c = ts.testArtist.Id,
                                        GuaranteeAmount__c = 200,
                                        DealType__c = 'Retro Net Deal',
                                        DealCalculation__c = 'Inclusive of Support',
                                        Event__c = ts.testEvent.Id,
                                        BackendPercent__c = 4,
                                        DealApplicationType__c = 'Paid Tickets',
                                        StageType__c = 'Settlement');
        insert testDeal4;

        List<Deal__c> results = [SELECT Type__c,
                                        StageType__c,
                                        DealType__c,
                                        DealApplicationType__c,
                                        BackendPercent__c,
                                        DealCalculation__c
                                 FROM Deal__c
                                 WHERE Event__c = :ts.testEvent.Id AND Type__c IN ('Primary Headliner','Co-Headliner')];
        System.assertEquals(4, results.size());

        for (Deal__c d : results) {
            if (d.Type__c == 'Primary Headliner') {
                if (d.StageType__c == 'Plan') {
                    system.assertEquals('Retro Gross Deal', d.DealType__c);
                    system.assertEquals('Paid Tickets', d.DealApplicationType__c);
                    system.assertEquals(1, d.BackendPercent__c);
                    system.assertEquals('Guarantee Only', d.DealCalculation__c);
                }

                if (d.StageType__c == 'Settlement') {
                    system.assertEquals('Step Up Net Deal', d.DealType__c);
                    system.assertEquals('To Be Shared Amount', d.DealApplicationType__c);
                    system.assertEquals(3, d.BackendPercent__c);
                    system.assertEquals('Inclusive of Sound & Lights', d.DealCalculation__c);
                }
            }

            if (d.Type__c == 'Co-Headliner') {
                if (d.StageType__c == 'Plan') {
                    system.assertEquals('Retro Gross Deal', d.DealType__c);
                    system.assertEquals('Paid Tickets', d.DealApplicationType__c);
                    system.assertEquals(1, d.BackendPercent__c);
                    system.assertEquals('Guarantee Only', d.DealCalculation__c);
                }

                if (d.StageType__c == 'Settlement') {
                    system.assertEquals('Step Up Net Deal', d.DealType__c);
                    system.assertEquals('To Be Shared Amount', d.DealApplicationType__c);
                    system.assertEquals(3, d.BackendPercent__c);
                    system.assertEquals('Inclusive of Sound & Lights', d.DealCalculation__c);
                }
            }
        }

        Test.stopTest();
    }
}