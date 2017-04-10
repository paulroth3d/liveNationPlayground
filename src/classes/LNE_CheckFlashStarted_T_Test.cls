@isTest
private class LNE_CheckFlashStarted_T_Test {
    
    class TestSettings {
    	public TestSettings() {
            
    	}
    
    	public List<Event__c> typicalSetup(){
			 
            LNE_TestObjectFactory.prepStandardCustomSettings();
            GLAccount__c testGlaAcct1 = new GLAccount__c (
				Type__c = 'Ancillary',
				Name = 'Parking Revenue',
				Category__c = 'Other Event Revenue',
				GLCode__c = '12345',
               	ApplyToBuySellEvent__c = true,
                ApplyToGospelBrunchEvent__c = true,
                ApplyToHOBEvent__c = true,
                ApplyToNAMusicEvent__c = true,
                ApplyToPromotedEvent__c =true,
                ApplyToRentalEvent__c = true
                    
			);
			
			insert testGlaAcct1;
			
            List<Event__c> events = new List<Event__c>();
			Event__c Evt1 = new Event__c(
				ProjectedPaidTickets__c = 10000,
				ProjectedDropCount__c = 10000,
                ActualDropCount__c = 10000,
                RecordTypeId = LNE_RT.RT_BUYSELL_ID
			);
			
			events.add(Evt1);
            
            Event__c Evt2 = new Event__c(
				ProjectedPaidTickets__c = 10000,
				ProjectedDropCount__c = 10000,
                ActualDropCount__c = 10000,
                RecordTypeId = LNE_RT.RT_PROMOTEDSHOW_ID
			);
			
			events.add(Evt2);
            
            Event__c Evt3 = new Event__c(
				ProjectedPaidTickets__c = 10000,
				ProjectedDropCount__c = 10000,
                ActualDropCount__c = 10000,
                RecordTypeId = LNE_RT.RT_GOSPELBRUNCH_ID
			);
			
			events.add(Evt3);
            
            Event__c Evt4 = new Event__c(
				ProjectedPaidTickets__c = 10000,
				ProjectedDropCount__c = 10000,
                ActualDropCount__c = 10000,
                RecordTypeId = LNE_RT.RT_RENTAL_ID
			);
			
			events.add(Evt4);
            
            LNE_TestObjectFactory.createStandardDataSetList(events);
            
            return events;
        
        }
    
    	public void updateSetup(){
    		
    	}
    	
    	public void finalize(){
		}
    }
    
    static testMethod void testCheckFlashStartedRental() {
    	TestSettings ts = new TestSettings();
    	List<Event__c> events = ts.typicalSetup();
    	ts.finalize();
    	
    	Test.startTest();
        
        for(Event__c evt: events){
            evt.Status__c='Flash Started';
        }
        
        update events;
    	Test.stopTest();
        
        List<LedgerEntry__c> createdLe = [SELECT Id FROM LedgerEntry__c];
        
        System.assertEquals(4, createdLe.size());
    	
    }
    
    
}