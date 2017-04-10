/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LNE_DMA_NameDefinition_T_Test {

	/** delimiter used in the external ids **/
	public static final String DELIMITER = '|';

	class TestSettings {
		
		//-- instance values
		DMA__c[] newDMAs;
		Map<Id,DMA__c> oldDMA_Map;

		public TestSettings(){
			//-- initialize common custom settings.
			LNE_TestObjectFactory.prepStandardCustomSettings();
			
			//-- we don't need the financial calculator to run until we're done with all this
			LNE_FinancialCalculator.currentlyRunning = true;
			LNE_FinancialCalculator.pushRunningTrigger( 'LNE_TicketScalesToLedgerController_Test' );

			//-- global setup here
		}
		
		public void setupDMA_Insert(){
			//-- specific setup here
			newDMAs = new DMA__c[]{
				LNE_TestObjectFactory.createDMA( 'CHICAGO', 'COOK', 'IL', '60402' )
			};
			
			oldDMA_Map = null;
		}
		
		public void setupDMA_Update(){
			newDMAs = new DMA__c[]{
				LNE_TestObjectFactory.createDMA( 'CHICAGO', 'COOK', 'IL', '60402' )
			};
			insert newDMAs;
			
			oldDMA_Map = new Map<Id,DMA__c>( newDMAs.deepClone( true,true,true )  );
			
			DMA__c updatedDMA = LNE_TestObjectFactory.createDMA( 'JACKSON', 'JACKSON', 'IL', '99999' );
			updatedDMA.Id = newDMAs[0].Id;
			newDMAs[0] = updatedDMA;
		}
		
		public void setupDMA_UpdateNoChange(){
			newDMAs = new DMA__c[]{
				LNE_TestObjectFactory.createDMA( 'CHICAGO', 'COOK', 'IL', '60402' )
			};
			insert newDMAs;
			
			oldDMA_Map = new Map<Id,DMA__c>( newDMAs.deepClone( true,true,true )  );
		}
		
		public void finalize(){
			//-- now we're done with updating everything, have the financial calculator run.
			LNE_FinancialCalculator.currentlyRunning = false;
			LNE_FinancialCalculator.popRunningTrigger();
		}
	}

	//-- test test methods here
	static testMethod void setupInsertWithoutInvokingException() {
		TestSettings ts = new TestSettings();
		ts.setupDMA_Insert();
		ts.finalize();
		System.assert( true, 'No Exceptions have occurred in getting here' );
	}

	static testMethod void setupUpdateWithoutInvokingException() {
		TestSettings ts = new TestSettings();
		ts.setupDMA_Insert();
		ts.finalize();
		System.assert( true, 'No Exceptions have occurred in getting here' );
	}

	//-- test functionality here
	
	static testMethod void testDMA_NameNoChange(){
		TestSettings ts = new TestSettings();
		ts.setupDMA_Insert();
		ts.finalize();
		
		DMA__c[] updatedDMAs = LNE_DMA_NameDefinition_T.execute( null, ts.oldDMA_Map );
		System.assert( updatedDMAs.size() < 1, 'if the newList is null, dont do anything' );
		
		//ts = new TestSettings();
		ts.setupDMA_UpdateNoChange();
		ts.finalize();
		updatedDMAs = LNE_DMA_NameDefinition_T.execute( ts.newDMAs, ts.oldDMA_Map );
		System.assert( updatedDMAs.size() < 1, 'there was no change, dont do anything' );
	}
	
	static testMethod void testDmaNameForNewDMAs(){
		TestSettings ts = new TestSettings();
		ts.setupDMA_Insert();
		ts.finalize();
		
		DMA__c[] updatedDMAs = LNE_DMA_NameDefinition_T.execute( ts.newDMAs, ts.oldDMA_Map );
		System.assertNotEquals( null, updatedDMAs );
		
		System.debug( 'updatedDMAs:' ); System.debug( updatedDMAs );
		System.assertEquals( 'CHICAGO' + DELIMITER + '60402', updatedDMAs[0].Name, 'Name should be updated with the delimiter' );
	}
	
	static testMethod void testDmaNameForUpdatedDMAs(){
		TestSettings ts = new TestSettings();
		ts.setupDMA_Update();
		ts.finalize();
		
		DMA__c[] updatedDMAs = LNE_DMA_NameDefinition_T.execute( ts.newDMAs, ts.oldDMA_Map );
		System.assertNotEquals( null, updatedDMAs );
		
		System.debug( 'updatedDMAs:' ); System.debug( updatedDMAs );
		System.assertEquals( 'JACKSON' + DELIMITER + '99999', updatedDMAs[0].Name, 'Name should be updated with the delimiter' );
	}

	static testMethod void testBypassAutomation(){
		TestSettings ts = new TestSettings();

		GeneralSettings__c gs = [SELECT BypassAutomation__c FROM GeneralSettings__c];
		gs.BypassAutomation__c = true;
		update gs;

		ts.setupDMA_Update();
		ts.finalize();
		
		DMA__c[] updatedDMAs = LNE_DMA_NameDefinition_T.execute( ts.newDMAs, ts.oldDMA_Map );
		System.assertNotEquals( null, updatedDMAs );
		
		System.debug( 'updatedDMAs:' ); System.debug( updatedDMAs );
		System.assertEquals( 'JACKSON' + DELIMITER + '99999', updatedDMAs[0].Name, 'Name should be updated with the delimiter' );
	}
}