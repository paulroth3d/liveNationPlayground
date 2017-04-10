@isTest
private class LNE_SelectAncillaryCOGSEntries_Test {
    class TestSettings {
        
        public TestSettings() {

        }
        
        public void typicalSetup(){
        }
        
        public void finalize(){
        }
    }

    static GLAccount__c glaAccount1 {get;set;}
    static GLAccount__c glaAccount2 {get;set;}
    static GLAccount__c glaAccount3 {get;set;}
    static GLAccount__c glaAccount4 {get;set;}
    
    static Event__c setupEvent() {
        Event__c evnt = new Event__c();
        //insert evnt;
        LNE_TestObjectFactory.createStandardDataSet(evnt);
        return evnt;
    }
    
    static Event__c setupEventWRel() {
        Event__c evnt = new Event__c();
        // insert evnt;
        LNE_TestObjectFactory.createStandardDataSet(evnt);
        
        glaAccount1 = new GLAccount__c(
            Type__c = 'Ancillary',
            Name = 'Draft Beer',
            Category__c = 'Concession Revenue'
        );
        insert glaAccount1;
        
        glaAccount2 = new GLAccount__c(
            Type__c = 'COGS',
            Name = 'COGS - Beer',
            Category__c = 'COGS - Concessions'
        );
        insert glaAccount2;
        
        glaAccount3 = new GLAccount__c(
            Type__c = 'COGS',
            Name = 'COGS - Draft Beer',
            Category__c = 'COGS - Concessions'
        );
        insert glaAccount3;
        
        glaAccount4 = new GLAccount__c(
            Type__c = 'Ancillary',
            Name = 'Merchandise Revenue',
            Category__c = 'Merchandise Revenue'
        );
        insert glaAccount4;
        
        String ancillaryRecordTypeId = LNE_Util.getRecordTypes(new String[]{'LedgerEntry__c.Ancillary'}).get('LedgerEntry__c.Ancillary');
        
        LedgerEntry__c ledgerEntry1 = new LedgerEntry__c(
            GLAccount__c = glaAccount1.Id,
            Event__c = evnt.Id,
            RecordTypeId = ancillaryRecordTypeId
        );
        insert ledgerEntry1;
        
        String cogsRecordTypeId = LNE_Util.getRecordTypes(new String[]{'LedgerEntry__c.COGS'}).get('LedgerEntry__c.COGS');
        
        LedgerEntry__c ledgerEntry2 = new LedgerEntry__c(
            GLAccount__c = glaAccount2.Id,
            Event__c = evnt.Id,
            RecordTypeId = cogsRecordTypeId
        );
        insert ledgerEntry2;
        
        return evnt;
    }

    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
    
    static LNE_SelectAncillaryCOGSEntries setupCtrls(Event__c evnt) {
        LNE_SelectAncillaryCOGSEntries selectEntriesCtrl = new LNE_SelectAncillaryCOGSEntries();
        selectEntriesCtrl.eventId = evnt.Id;
        
        return selectEntriesCtrl;
    }
    
    @isTest static void validateAddOrRemoveRevenueExpenseEntries() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();

        Event__c evnt = setupEventWRel();
        
        Test.startTest();
        LNE_SelectAncillaryCOGSEntries selectEntriesCtrl = setupCtrls(evnt);
        selectEntriesCtrl.getRelatedRevenuesExpenses();
        List<Object> beforeJsonObj = (List<Object>) System.JSON.deserializeUntyped(selectEntriesCtrl.previousSelectedEntriesJson);
        
        selectEntriesCtrl.selectedEntriesJson = '[{"type":"Ancillary", "id":"' + glaAccount1.Id + '"}, {"type":"COGS", "id":"' + glaAccount3.Id + '"}]';
        selectEntriesCtrl.addOrRemoveRevenueExpenseEntries();
        selectEntriesCtrl.getRelatedRevenuesExpenses();
        Test.stopTest();
        
        List<Object> afterJsonObj = (List<Object>) System.JSON.deserializeUntyped(selectEntriesCtrl.previousSelectedEntriesJson);

        System.assert(beforeJsonObj.size() == 2);
        System.assert(afterJsonObj.size() == 2);
        System.assert(selectEntriesCtrl.previousSelectedEntriesJson != '[]');
    }
    
    @isTest static void validateAddAllRevenueExpenseEntries() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();

        Event__c evnt = setupEventWRel();
        
        Test.startTest();
        LNE_SelectAncillaryCOGSEntries selectEntriesCtrl = setupCtrls(evnt);
        selectEntriesCtrl.getRelatedRevenuesExpenses();
        List<Object> beforeJsonObj = (List<Object>) System.JSON.deserializeUntyped(selectEntriesCtrl.previousSelectedEntriesJson);
        
        selectEntriesCtrl.selectedEntriesJson = '[{"type":"COGS", "id":"' + glaAccount3.Id + '"}, {"type":"Ancillary", "id":"' + glaAccount4.Id + '"}]';
        selectEntriesCtrl.addOrRemoveRevenueExpenseEntries();
        selectEntriesCtrl.getRelatedRevenuesExpenses();
        Test.stopTest();
        
        List<Object> afterJsonObj = (List<Object>) System.JSON.deserializeUntyped(selectEntriesCtrl.previousSelectedEntriesJson);

        System.assert(beforeJsonObj.size() == 2);
        System.assert(afterJsonObj.size() == 2);
        System.assert(selectEntriesCtrl.previousSelectedEntriesJson != '[]');
    }
    
    @isTest static void validateRemoveAllRevenueExpenseEntries() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();

        Event__c evnt = setupEventWRel();
        
        Test.startTest();
        LNE_SelectAncillaryCOGSEntries selectEntriesCtrl = setupCtrls(evnt);
        selectEntriesCtrl.getRelatedRevenuesExpenses();
        List<Object> beforeJsonObj = (List<Object>) System.JSON.deserializeUntyped(selectEntriesCtrl.previousSelectedEntriesJson);
        
        selectEntriesCtrl.selectedEntriesJson = '[]';
        selectEntriesCtrl.addOrRemoveRevenueExpenseEntries();
        selectEntriesCtrl.getRelatedRevenuesExpenses();
        Test.stopTest();
        
        List<Object> afterJsonObj = (List<Object>) System.JSON.deserializeUntyped(selectEntriesCtrl.previousSelectedEntriesJson);
        
        System.assert(beforeJsonObj.size() == 2);
        System.assert(afterJsonObj.size() == 0);
        System.assert(selectEntriesCtrl.previousSelectedEntriesJson == '[]');
    }
    
    @isTest static void validateGetRelatedRevenuesExpensesWORel() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();

        Event__c evnt = setupEvent();
        
        Test.startTest();
        LNE_SelectAncillaryCOGSEntries selectEntriesCtrl = setupCtrls(evnt);
        selectEntriesCtrl.getRelatedRevenuesExpenses();
        Test.stopTest();
        
        System.assert(selectEntriesCtrl.previousSelectedEntriesJson == '[]');
    }
    
    @isTest static void validateGetRelatedRevenuesExpensesWRel() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        
        Event__c evnt = setupEventWRel();
        
        Test.startTest();
        LNE_SelectAncillaryCOGSEntries selectEntriesCtrl = setupCtrls(evnt);
        selectEntriesCtrl.getRelatedRevenuesExpenses();
        Test.stopTest();
        
        System.assert(selectEntriesCtrl.previousSelectedEntriesJson != '[]');
    }
}