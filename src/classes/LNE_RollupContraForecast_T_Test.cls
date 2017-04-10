@isTest
private class LNE_RollupContraForecast_T_Test {

    class TestSettings {
        String COMBINED_KEY_DELIMITER = '|';            
        Account geoOffice;
        Account divisionOffice;    
        Account buUnitOffice;
        Account amphiOffice;     
        Account[] newAccounts;
        Event__c myEvent;
        GLAccount__c ancillaryGL;
        GLAccount__c contraGL;
        Map<Id,Account> oldAccountsMap;
        DataGenerationSettings__c dataSettings;
        DMA__c[] dmaList;        
        String RT_VENUE_NAME = 'Account.Venue';
        String RT_OFFICE_NAME = 'Account.Office';
        String RT_LEDGER_ANCILLARY = 'LedgerEntry__c.Ancillary';
        String RT_LEDGER_CONTRA = 'LedgerEntry__c.Contra';
        ID RT_VENUE_ID;
        ID RT_OFFICE_ID; 
        ID RT_LEDGER_ANCILLARY_ID;                           
        ID RT_LEDGER_CONTRA_ID;        
        LNE_TestObjectFactory factory;          
        
        public TestSettings() {
        
            //important rule to allow duplicates within the unit tests.
            
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            dataSettings = new DataGenerationSettings__c(CombinedKeyDelimiter__c = COMBINED_KEY_DELIMITER);
            insert dataSettings;
            
            //get recordtypes
            
            dmaList = new DMA__c[]{LNE_TestObjectFactory.createDMA( 'CHICAGO', 'COOK', 'IL', '60402' ),
                LNE_TestObjectFactory.createDMA( 'PADUCAH-CAPE GIRARD-HARSBG', 'JACKSON', 'IL', '62274' )};
            insert dmaList;             
            
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{RT_VENUE_NAME, RT_OFFICE_NAME, RT_LEDGER_ANCILLARY,RT_LEDGER_CONTRA });
            RT_OFFICE_ID = recordTypeMap.get(RT_OFFICE_NAME);
            RT_VENUE_ID = recordTypeMap.get(RT_VENUE_NAME); 
            RT_LEDGER_ANCILLARY_ID =  recordTypeMap.get(RT_LEDGER_ANCILLARY);
            RT_LEDGER_CONTRA_ID = recordTypeMap.get(RT_LEDGER_CONTRA);            
            
            myEvent = new Event__c(ProjectedPaidTickets__c = 20000, ProjectedDropCount__c = 30000);
            
            List<Event__c> events = new List<Event__c>{myEvent};
            Map<String, Id> objectToId = LNE_TestObjectFactory.createStandardDataSetList(events);  
            
            geoOffice = [SELECT Id, Name, Type
                             FROM Account
                            WHERE Id = :objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_VENUE)];
                            
            buUnitOffice = [SELECT Id, Name, Type
                              FROM Account
                             WHERE Id = :objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_OFFICE)];      
            
            ancillaryGL = [SELECT Id, Name, Category__c, RelatedContra__c, GLCode__c 
                             FROM GLAccount__c 
                            WHERE Id = :objectToId.get(LNE_TestObjectFactory.STANDARD_DATA_ANCILLARY)];
                            
            contraGL = new LNE_TestObjectFactory(
                LNE_TestObjectFactory.createGLAccount('Contra Rev - Concession', '11111'))
                    .addProperties(
    			        new Map<String,object>{
    			        	'Category__c' => 'Concession Revenue',
    				        'Type__c' => 'Contra',
    				        'RelatedContra__c' => ancillaryGL.Id
    			        }
    		        ).buildGLAccount();         
            insert contraGL;
            
            divisionOffice = new LNE_TestObjectFactory(LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'testDivision' )
            , RT_OFFICE_ID )).addBillingAddress( '1000 west illinois st', 'Chicago', '60402','Illinois', 'IL', 'United States', 'US'
            ).addProperties( new Map<String,Object>{'Phone' => '708-522-5307','Type' => 'Division','ApplyGlobalTermsTo__c' => 'Amphitheatre'
            ,'GlobalTerms__c' => 'Global Terms','ParentId' => geoOffice.Id, 'Status__c' => 'Active'}).buildAccount();
            divisionOffice.Type = 'Office';
            Database.insert(divisionOffice, dml);     
            
            buUnitOffice = new LNE_TestObjectFactory(LNE_TestObjectFactory.createAccount( LNE_TestObjectFactory.makeUnique( 'Chicago' )
            , RT_OFFICE_ID )).addBillingAddress( '1000 west illinois st', 'Chicago', '60402','Illinois', 'IL', 'United States', 'US' 
            ).addProperties( new Map<String,Object>{'Phone' => '708-522-5307','Type' => 'Business Unit','ParentId' => divisionOffice.Id
            , 'Status__c' => 'Active'}).buildAccount();
            buUnitOffice.Type = 'Office';
            Database.insert(buUnitOffice, dml);    
        }
        
        public boolean insertLedger(){
            LedgerEntry__c insertLedger = new LedgerEntry__c (
                GLAccount__c = contraGL.Id,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                Category__c = 'Concession Revenue',
                RecordTypeId = RT_LEDGER_ANCILLARY_ID,
                Event__c = myEvent.Id,
                contraatforecast__c = 20);     
            insert insertLedger ;
                
            LedgerEntry__c[] contraLedger = [Select id, contraatforecast__c from ledgerentry__c where glaccount__c = :contraGL.Id]; 
            return (contraLedger[0].contraatforecast__c == 20?True:False);         

        }
        
        public boolean updateLedger(){
            LedgerEntry__c insertUpdateLedger = new LedgerEntry__c (
                GLAccount__c = contraGL.Id,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                Category__c = 'Concession Revenue',
                RecordTypeId = RT_LEDGER_ANCILLARY_ID,
                Event__c = myEvent.Id,
                contraatforecast__c = 20);     
                insert insertUpdateLedger ;
            
            insertUpdateLedger.contraatforecast__c = 32;
            update  insertUpdateLedger;
                
            LedgerEntry__c[] contraLedger = [Select id, contraatforecast__c from ledgerentry__c where glaccount__c = :contraGL.Id];   
            system.debug('CONTRA = ' + contraLedger);
            return (contraLedger[0].contraatforecast__c == 32?True:False);         

        } 

        public boolean updateToDeleteLedger(){
            LedgerEntry__c UpdateDeleteLedger = new LedgerEntry__c (
                GLAccount__c = ancillaryGL.Id,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                Category__c = 'Concession Revenue',
                RecordTypeId = RT_LEDGER_ANCILLARY_ID,
                Event__c = myEvent.Id,
                contraatforecast__c = 20);     
                insert UpdateDeleteLedger ;
            
            UpdateDeleteLedger.contraatforecast__c = 0;
            update  UpdateDeleteLedger;
             
            List<ledgerentry__c> count =  [Select Id from ledgerentry__c where glaccount__c = :contraGL.Id];  
            return (count.size() == 0?True:False);         

        }  
        
        
        public boolean deleteLedger(){
            LedgerEntry__c deleteLedger = new LedgerEntry__c (
                GLAccount__c = ancillaryGL.Id,
                BaseAmount__c = 33343,
                RateType__c = 'Flat', 
                Category__c = 'Concession Revenue',
                RecordTypeId = RT_LEDGER_ANCILLARY_ID,
                Event__c = myEvent.Id,
                contraatforecast__c = 20);     
                insert deleteLedger ;
            
            delete  deleteLedger;
             
            Integer count =  [Select count() from ledgerentry__c where glaccount__c = :contraGL.Id];  
            return (count == 0?True:False);         

        }       
        
        public void finalize(){
        }
    }
    
    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }        

    static testMethod void insertLedgerWithoutException() {
        LNE_FinancialCalculator.currentlyRunning = true;
        TestSettings ts = new TestSettings();
        Test.startTest();
        Boolean result = ts.insertLedger();
        ts.finalize();
        System.assert( true, 'No Exceptions were thrown' );
    }    
    
    static testMethod void updateLedgerWithoutException() {
        LNE_FinancialCalculator.currentlyRunning = true;
        TestSettings ts = new TestSettings();
        Test.startTest();
        Boolean result = ts.updateLedger();
        Test.stopTest();
        ts.finalize();
        System.assert( true, 'No Exceptions were thrown' );
    }   
    
    static testMethod void updateToDeleteLedgerWithoutException() {
        LNE_FinancialCalculator.currentlyRunning = true;
        TestSettings ts = new TestSettings();
        Test.startTest();
        Boolean result = ts.updateToDeleteLedger();
        Test.stopTest();
        ts.finalize();
        System.assert( true, 'No Exceptions were thrown' );
    }    
    
    static testMethod void deleteLedgerWithoutException() {
        LNE_FinancialCalculator.currentlyRunning = true;
        TestSettings ts = new TestSettings();
        Test.startTest();
        Boolean result = ts.deleteLedger();
        ts.finalize();
        System.assert( true, 'No Exceptions were thrown' );
    } 
            
    static testMethod void insertLedgertest() {
        LNE_FinancialCalculator.currentlyRunning = true;
        TestSettings ts = new TestSettings();
        Test.startTest();
        Boolean result = ts.insertLedger();
        ts.finalize();        
        System.assert(result);
    } 
    
    static testMethod void updateLedgertest() {
        LNE_FinancialCalculator.currentlyRunning = true;
        TestSettings ts = new TestSettings();
        Test.startTest();
        Boolean result = ts.updateLedger();
        Test.stopTest();
        ts.finalize();        
        System.assert(result);
    }

    static testMethod void updateToDeleteLedgertest() {
        LNE_FinancialCalculator.currentlyRunning = true;
        TestSettings ts = new TestSettings();
        Test.startTest();
        Boolean result = ts.updateToDeleteLedger();
        Test.stopTest();
        ts.finalize();        
        System.assert(result);
    }     

    static testMethod void deleteLedgertest() {
        LNE_FinancialCalculator.currentlyRunning = true;
        TestSettings ts = new TestSettings();
        Test.startTest();
        Boolean result = ts.deleteLedger();
        ts.finalize();     
        System.assert(result);
    }
}