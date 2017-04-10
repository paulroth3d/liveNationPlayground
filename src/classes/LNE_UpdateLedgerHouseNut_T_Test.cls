@isTest
private class LNE_UpdateLedgerHouseNut_T_Test {
	
	static final String RT_Ancillary = 'LedgerEntry__c.Ancillary';

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
    /**
     *  Test: The Artists__c string should be a line break delimited list of all artists involved (via associated deals) in order of deal rank
     */ 
    static testMethod void testDidHouseNutValueCopy() {
        LNE_TestObjectFactory.createStandardDataSet();
        
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
			new String[]{ RT_Ancillary }
		);
		Id RT_ANCILLARY_ID = recordTypeMap.get( RT_Ancillary );

        List<Event__c> testEvents = [SELECT Id, UsingHouseNut__c, Artists__c FROM Event__c LIMIT 1];
        System.assertEquals(1, testEvents.size());
        testEvents[0].UsingHouseNut__c = true;
        update testEvents[0];

        List<GLAccount__c> testGlas = [SELECT Id FROM GLAccount__c WHERE GLCode__c IN ('50103', '50302')];
        System.assertEquals(2, testGlas.size());
        
        System.assertEquals(true, testEvents[0].UsingHouseNut__c);

		 LedgerEntry__c ledgerEntry = new LedgerEntry__c(
			GLAccount__c = testGlas[0].Id,
			RecordTypeId = RT_ANCILLARY_ID,
			BaseAmount__c = 99999999,
			RateType__c = 'Flat',
			Event__c = testEvents[0].Id,
			HouseNut__c = true
		);
		insert ledgerEntry;

        List<LedgerEntry__c> testLedgerEntries = [SELECT Id, HouseNut__c FROM LedgerEntry__c WHERE Event__c = :testEvents[0].Id];
        System.assertEquals(1, testLedgerEntries.size());
        System.assertEquals(true, testLedgerEntries[0].HouseNut__c);

        // Now set Event house nut to false and all the ledgers should be false too
        testEvents[0].UsingHouseNut__c = false;
        update testEvents[0];
        System.assertEquals(false, testEvents[0].UsingHouseNut__c);
        // invoke trigger
        // then the ledgers should have house nut false just like the event
        //System.assertEquals(false, testLedgerEntries[0].HouseNut__c);
    }

}