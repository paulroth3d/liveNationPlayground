@isTest
public class LNE_CheckLinkedToTour_T_Test{

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
			    'Tour__c' => null
			}).buildEvent();
        
        Tour__c tour = new Tour__c();
       	insert Tour;

        LNE_TestObjectFactory.prepStandardCustomSettings();
        LNE_TestObjectFactory.createStandardDataSet(event);
        
    }

	@isTest static void testCheckLinkedToTour() {
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
         
        system.assertEquals(tourLe.size(), 1);
            
        testEvent.Tour__c  = null;
        
        update testEvent;
        
        testEvent.Tour__c = testTour.Id;
        
        update testEvent; 
        
        tourLe = [SELECT Id FROM LedgerEntry__c WHERE Event__c =:testEvent.Id AND GLCode__c = :GL_CODE];
         
        system.assertEquals(tourLe.size(), 1);
        
		Test.stopTest();
	}
}