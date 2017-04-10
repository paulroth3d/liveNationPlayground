/**
 * last modified date: 03FEB2017
 * last modified by: Daniel Nakonieczny <dnakonieczny@salesforce.com>
 * description: fixed failing execution, refactored code to be more efficient
 */
@isTest
public class LNE_DealPrimaryHeadlinerArtist_T_Test {
	
    @testSetup
    static void setup(){
        LNE_TestObjectFactory.prepStandardCustomSettings();
    }
   
    static final String RT_Rental = 'Event__c.Rental';
    static final String RT_Hold = 'Event__c.Hold';
    class TestSettings {
        Deal__c[] newDeals;
        Deal__c[] oldDeals;        
        Map<Id, Deal__c> oldDealssMap;
        Event__c testEvent;
        Account venue;
        Account testArtist;
        
        public TestSettings() {
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_DealPrimaryHeadlinerArtist_T_Test' );
        
            //-- global setup here
            LNE_GeneralSettingsUtil.setLocalBypassSettings( true, true, true );
            
            Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
                new String[]{ RT_Rental, RT_Hold}
			);
			Id RT_Rental_ID = recordTypeMap.get( RT_Rental );
			Id RT_Hold_ID = recordTypeMap.get( RT_Hold );
	
            
            newDeals = new List<Deal__c>(); 
            oldDeals = new List<Deal__c>();
            
          	
            testEvent = new Event__c(
                ProjectedPaidTickets__c = 20000,
                ProjectedDropCount__c = 30000,
                Status__c = 'Draft',
               	RecordTypeId = RT_Rental_ID
            );
            Map<String,Id> dataSet = LNE_TestObjectFactory.createStandardDataSet( testEvent );
            
            Account[] artists = new Account[]{
				LNE_TestObjectFactory.createAccount( 'Artist1' ),
				LNE_TestObjectFactory.createAccount( 'Artist2' ),
                LNE_TestObjectFactory.createAccount( 'Artist3' )
			};
                
           	insert artists;

            testArtist = artists[2];
            
            System.assert( dataSet.containsKey( LNE_TestObjectFactory.STANDARD_DATA_DEAL ), 'Primary headliner must be the standard deal' );
            Id primaryHeadlinerId = dataSet.get( LNE_TestObjectFactory.STANDARD_DATA_DEAL );
            
            Deal__c[] dealsToUpdate = new Deal__c[]{};
            
            Deal__c testDeal1 = new Deal__c( Id=primaryHeadlinerId, Type__c='Primary Headliner', Artist__c = artists[0].Id, GuaranteeAmount__c = 200, DealType__c = 'Flat', DealCalculation__c = 'Guarantee Only', Event__c = testEvent.Id, StageType__c = 'Plan' );
            dealsToUpdate.add( testDeal1 );

            Deal__c testDeal2 = new Deal__c(Type__c='Support', Artist__c = artists[1].Id, GuaranteeAmount__c = 200, DealType__c = 'Flat', DealCalculation__c = 'Guarantee Only' , Event__c = testEvent.Id);
            dealsToUpdate.add( testDeal2 );
            
            upsert dealsToUpdate;
        }
        
        public void typicalSetup(){
                
        }
        
        public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
			
			LNE_GeneralSettingsUtil.removeCurrentUserOverride();
        }
    }
    
    //-- test functionality here

    /**
    * Test: Make sure only one Primary Headliner can be inserted per Event
    */
    static testMethod void testPrimaryHeadliner() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        
        Test.startTest();

        Deal__c testDeal3 = new Deal__c(Type__c='Primary Headliner', Artist__c = ts.testArtist.Id, GuaranteeAmount__c = 200, DealType__c = 'Flat', DealCalculation__c = 'Guarantee Only', Event__c = ts.testEvent.Id, StageType__c = 'Plan' );
            
        try{
             insert testDeal3;
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('You can only select one Primary Headliner per Event.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();

    }
}