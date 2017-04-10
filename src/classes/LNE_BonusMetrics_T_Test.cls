@isTest
private class LNE_BonusMetrics_T_Test {
	
    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
	class TestSettings {
        
        //-- global setup here
        GLAccount__c touringGL;
        Event__c evt1;
        Account[] artists;
        Account venue;
        Deal__c testDeal1;
        BonusDetail__c bonusDetail1;
        BonusDetail__c bonusDetail2;
		
        public TestSettings() {
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );
        }
        
        public void typicalSetup(){
        	
        	LNE_FinancialCalculator.pushRunningTrigger('LNE_BonusMetrics_T_Test');

            //-- just use the default hierarchy
            LNE_TestObjectFactory.VenueHierarchy acctHierarchy = LNE_TestObjectFactory.createVenueHierarchy(
            	LNE_TestObjectFactory.ACCT_TYPE_DIVISION, null, null
            );
            venue = acctHierarchy.venue;
        	
        	Evt1 = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Venue__c = venue.Id,
                Status__c = 'Draft'
            );
            Map<String,Id> standardData = LNE_TestObjectFactory.createStandardDataSet( Evt1, acctHierarchy );

            artists = new Account[]{
				LNE_TestObjectFactory.createAccount( 'Artist1' ),
				LNE_TestObjectFactory.createAccount( 'Artist2' ),
                LNE_TestObjectFactory.createAccount( 'Artist3' )
			};
           	insert artists;
           	
           	Id primaryId = standardData.get( LNE_TestObjectFactory.STANDARD_DATA_DEAL );
           	System.assert( primaryId != null, 'primary deal must be found' );
            
            testDeal1 = new Deal__c( Id=primaryId, Type__c='Primary Headliner', Artist__c = artists[0].Id, GuaranteeAmount__c = 200, DealType__c = 'Flat', DealCalculation__c = 'Guarantee Only', Event__c = Evt1.Id, StageType__c = 'Plan' );
            update testDeal1;
            
            bonusDetail1 = new BonusDetail__c(Deal__c = testDeal1.Id, BonusBase__c = 'Paid Tickets', Type__c = 'Step Up', ApplyTo__c = 'Guarantee', BonusAmount__c = 1, StartPoint__c = 2001, EndPoint__c = 3000, Increment__c = 1 );
            bonusDetail2 = new BonusDetail__c(Deal__c = testDeal1.Id, BonusBase__c = 'Paid Tickets', Type__c = 'Retro', ApplyTo__c = 'Guarantee', BonusAmount__c = 1, StartPoint__c = 2001, EndPoint__c = 3000, Increment__c = 1 );
            insert new List<BonusDetail__c>{bonusDetail1,bonusDetail2};
            
            LNE_FinancialCalculator.popRunningTrigger();
            LNE_FinancialCalculator.checkIfCanRunCalculations();
        }
        
        public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
        }
    }
    
    @isTest 
    static void testSetupExecutesWithoutException(){
    	try {
    		TestSettings ts = new TestSettings();
    		ts.typicalSetup();
    		ts.finalize();
    	} catch( Exception err ){
    		System.assert( false, 'Exception should not occur while performing setup:' + err.getMessage() );
    	}
    }
    
    //-- Test: Makes sure the wording of ArtistBonusExplanation__c was populated correctly in the trigger
    
    static testMethod void testBonusDetailsDescription() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        
        Test.startTest();
        System.debug( 'Start of test' );

        List<BonusDetail__c> bonuses = [SELECT ArtistBonusExplanation__c, Type__c FROM BonusDetail__c];
        system.assertEquals(2, bonuses.size());

        for (BonusDetail__c bd : bonuses) {
        	if (bd.Type__c == 'Step Up') {
        		system.assertEquals('Artist to receive a bonus of USD 1 starting at 2,001 paid tickets, plus USD 1 per 1 paid tickets increment up to 3,000 paid tickets.', bd.ArtistBonusExplanation__c);
        	}

        	if (bd.Type__c == 'Retro') {
        		system.assertEquals('If total paid tickets is between 2,001 and 3,000, Artist to receive a bonus of USD 1 per 1 paid tickets increment retroactive to the first paid ticket.', bd.ArtistBonusExplanation__c);
        	}
        }
        
        Test.stopTest();
	}
}