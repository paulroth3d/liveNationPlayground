/**
 *  Test that a GL level ledger entry cannot be deleted except by a system administrator.
 *  @author Sebastian Gutierrez
 *  @see US220
 *  @see US696
 */
@isTest
public class LNE_BlockDeletingTourLE_T_Test{

	public static final String GL_CODE='50360';

    
	class TestSettings {
		public Event__c testEvent;
		
		public TestSettings() {

		}
		
		public void typicalSetup(){
			Event__c e = [SELECT Id FROM Event__c LIMIT 1];
			testEvent = e;
		}
		
		public void finalize(){
		}
	}

    @testSetup
    static void setup(){
    	Event__c event = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createEvent()
			).addProperties( new Map<String,Object>{
			    'Tour__c' => null,
                'SettlementStarted__c' => true
			}).buildEvent();
        
        Tour__c tour = new Tour__c();
       	insert Tour;

        LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet(event);
        
    }

	@isTest static void testBlockDeletingTour() {
		TestSettings tsettings = new TestSettings();
		tsettings.typicalSetup();
		tsettings.finalize();

		Test.startTest();

		Event__c testEvent = [SELECT Id, Tour__c
							   FROM Event__c LIMIT 1];
		Tour__c testTour = [SELECT Id
                           	FROM Tour__c LIMIT 1];
		
		testEvent.Tour__c = testTour.Id;
        
        update testEvent;
        
        List<LedgerEntry__c> tourLe = [SELECT Id FROM LedgerEntry__c WHERE Event__c =:testEvent.Id AND GLCode__c = :GL_CODE];
         
       	system.assertEquals(tourLe.size(),1);
        
        tourLe[0].OfferRate__c = 200;
        tourLe[0].InHouseRate__c = 200;
        
        update tourLe[0];
       
        try{
            delete tourLe[0];
        }catch(Exception e){
            system.assertNotEquals(e, null);
        }finally{
            test.stopTest();
        }
        
	}
}