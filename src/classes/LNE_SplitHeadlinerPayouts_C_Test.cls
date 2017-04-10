/**
 * Test class for LNE_SplitHeadlinerPayouts_C
 * @author Vinay
 * US648
 * @version - us648 
 **/
@isTest
private class LNE_SplitHeadlinerPayouts_C_Test
{
	
	@testSetup
    static void globalSetup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
		LNE_TestObjectFactory.createStandardDataSet();
    }

	class TestSettings {
        public TestSettings() {
            //-- global setup here//-- we don't need the financial calculator to run until we're done with all this
            
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );

		}

        //-- whatever your setups, and you can make it as varied as you'd like.
        public void typicalSetup(){
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Artist'});         
            Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );

            Event__c event = [Select Id, Status__c from Event__c limit 1];
            Account artist = [Select Id, Name from Account where RecordTypeId =: RT_ACCOUNT_ARTIST_ID limit 1];
            // Deal - Co Headliner
            Deal__c deal = new Deal__c();
            deal.Event__c = event.Id;
            deal.Type__c = 'Co-Headliner';
            deal.Artist__c = artist.Id;
            deal.GuaranteeAmount__c = 1000;
            deal.dealType__c = 'Flat';
            deal.DealCalculation__c = 'Guarantee Only';
            deal.StageType__c = 'Plan';
            
            LNE_FinancialCalculator.runUpdates = true;
            insert deal;
        }

        public void finalize(){
            //-- always should be called.
            
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
		} 
	}

    //-- test setups here to find out if errors have nothing to do with the test.
    static testMethod void runSetupAWithoutException() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        System.assert( true, 'No Exceptions have occurred in getting here' );
    }

    //-- test method with only one primary headliner with no co Headliner, assert page error messages.
    static testMethod void testWithOnlyPrimaryHeadliner() {
        TestSettings ts = new TestSettings();
        //ts.typicalSetup();
        ts.finalize();
        
        Event__c event = [Select Id, Status__c from Event__c limit 1];
        test.startTest();
            Test.setCurrentPage(Page.LNE_SplitHeadlinerPayouts);
            ApexPages.currentPage().getParameters().put('eventId', event.Id);
            ApexPages.currentPage().getParameters().put('stageType', 'Plan');
        	LNE_SplitHeadlinerPayouts_C lneSplitHeadlinerPayoutsController = new LNE_SplitHeadlinerPayouts_C();
        	lneSplitHeadlinerPayoutsController.init();
        test.stopTest();

        System.assert(ApexPages.hasMessages()); 
        List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;
		for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains('Atleast one Primary and one Co-Headliner should exist.')) b = true;
		}
		system.assert(b);
    }

    //-- test method to check for positive use case of positive split percentage adding to 100%
    static testMethod void testWithPrimaryandCoHeadlinerPositive() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        
        Event__c event = [Select Id, Status__c from Event__c limit 1];
        List<Id> dealIds = new List<Id>();
        test.startTest();
            Test.setCurrentPage(Page.LNE_SplitHeadlinerPayouts);
            ApexPages.currentPage().getParameters().put('eventId', event.Id);
            ApexPages.currentPage().getParameters().put('stageType', 'Plan');
            LNE_SplitHeadlinerPayouts_C lneSplitHeadlinerPayoutsController = new LNE_SplitHeadlinerPayouts_C();
            lneSplitHeadlinerPayoutsController.init();

            for(Deal__c deal : lneSplitHeadlinerPayoutsController.headlinerList){
                deal.SplitPercentage__c  = 50;
                dealIds.add(deal.Id);
            }  

            lneSplitHeadlinerPayoutsController.save();

        test.stopTest();

        //assert no errors and split are set.
        List<Deal__c> dealList = [SELECT Id, BackendPercent__c, Artist__c, Artist__r.Name, SplitPercentage__c
                                                          , SplitBackendPercent__c, Type__c FROM Deal__c where Id IN :dealIds];
        system.assertNOTEquals(NULL, dealList);
        for(Deal__c deal : dealList){
            system.assertEquals(50, deal.SplitPercentage__c);
        }
    }

    //-- test method to check for negative use case of split percentage not adding to 100%
    static testMethod void testWithPrimaryandCoHeadlinerNot100() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        
        Event__c event = [Select Id, Status__c from Event__c limit 1];
        List<Id> dealIds = new List<Id>();
        test.startTest();
            Test.setCurrentPage(Page.LNE_SplitHeadlinerPayouts);
            ApexPages.currentPage().getParameters().put('eventId', event.Id);
            ApexPages.currentPage().getParameters().put('stageType', 'Plan');
            LNE_SplitHeadlinerPayouts_C lneSplitHeadlinerPayoutsController = new LNE_SplitHeadlinerPayouts_C();
            lneSplitHeadlinerPayoutsController.init();

            for(Deal__c deal : lneSplitHeadlinerPayoutsController.headlinerList){
                deal.SplitPercentage__c  = 10;
                dealIds.add(deal.Id);
            }  

            lneSplitHeadlinerPayoutsController.save();

        test.stopTest();
        System.assert(ApexPages.hasMessages()); 
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('The Split % must total to 100%')) b = true;
        }
        system.assert(b);
    }

    //-- test method to check for negative use case of negative split percentage.
    static testMethod void testWithPrimaryandCoHeadlinerNegative() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        
        Event__c event = [Select Id, Status__c from Event__c limit 1];
        List<Id> dealIds = new List<Id>();
        test.startTest();
            Test.setCurrentPage(Page.LNE_SplitHeadlinerPayouts);
            ApexPages.currentPage().getParameters().put('eventId', event.Id);
            ApexPages.currentPage().getParameters().put('stageType', 'Plan');
            LNE_SplitHeadlinerPayouts_C lneSplitHeadlinerPayoutsController = new LNE_SplitHeadlinerPayouts_C();
            lneSplitHeadlinerPayoutsController.init();

            for(Deal__c deal : lneSplitHeadlinerPayoutsController.headlinerList){
                deal.SplitPercentage__c  = -10;
                dealIds.add(deal.Id);
            }  

            lneSplitHeadlinerPayoutsController.save();
            lneSplitHeadlinerPayoutsController.cancel();

        test.stopTest();
        System.assert(ApexPages.hasMessages()); 
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('The Split % must be positive')) b = true;
        }
        system.assert(b);
    }

}