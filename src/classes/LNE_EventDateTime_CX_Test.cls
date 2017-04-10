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
private class LNE_EventDateTime_CX_Test {
  
  class TestSettings {
    
    //-- instance values
    public Event__c testEvent;
    EventDateTime__c evtDateTime;
    
    public TestSettings(){
          
        //-- global setup here
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(new String[]{ 'Account.Venue', 'Account.Office', 'Account.Artist', 'Event__c.PromotedShow'});         
        Id RT_ACCOUNT_VENUE_ID = recordTypeMap.get( 'Account.Venue' );
        Id RT_ACCOUNT_OFFICE_ID = recordTypeMap.get( 'Account.Office' );
        Id RT_ACCOUNT_ARTIST_ID = recordTypeMap.get( 'Account.Artist' );
        Id RT_EVENT_PROMOTEDSHOW_ID = recordTypeMap.get( 'Event__c.PromotedShow' );
        
        
        // create artist
        Account artist = new LNE_TestObjectFactory(LNE_TestObjectFactory.createAccount('The Artist', RT_ACCOUNT_ARTIST_ID)).buildAccount();
        artist.Genre__c = 'Classic Rock';
        insert artist;
        
        // create office
        Account office = new LNE_TestObjectFactory(LNE_TestObjectFactory.createAccount('The Office', RT_ACCOUNT_OFFICE_ID)).buildAccount();
        office.Type = 'Geography';
        office.BillingStreet = '123 main st.';
        office.BillingCity = 'chicago';
        office.BillingStateCode = 'IL';
        office.BillingPostalCode = '60654';
        office.BillingCountryCode = 'US';
        office.ShippingStreet = '123 main st.';
        office.ShippingCity = 'chicago';
        office.ShippingStateCode = 'IL';
        office.ShippingPostalCode = '60654';
        office.ShippingCountryCode = 'US';
        insert office;
        
        // create venue
        Account venue = new LNE_TestObjectFactory(LNE_TestObjectFactory.createAccount('The Venue', RT_ACCOUNT_VENUE_ID)).buildAccount();
        venue.BillingStreet = '123 main st.';
        venue.BillingCity = 'chicago';
        venue.BillingStateCode = 'IL';
        venue.BillingPostalCode = '60654';
        venue.BillingCountryCode = 'US';
        venue.ShippingStreet = '123 main st.';
        venue.ShippingCity = 'chicago';
        venue.ShippingStateCode = 'IL';
        venue.ShippingPostalCode = '60654';
        venue.ShippingCountryCode = 'US';
        venue.Market__c = 'Chicago';
        venue.Capacity__c = 100;
        venue.PrimaryOffice__c = office.id;
        insert venue;
        
        system.debug('VENUE = ' + [select BillingCountry, BillingCountryCode from Account where id = :venue.Id]);
          
        // create event
        system.debug('EVENT RT ID = ' + RT_EVENT_PROMOTEDSHOW_ID);
        Event__c event = new LNE_TestObjectFactory(
		        LNE_TestObjectFactory.createEvent()
			).addProperties( new Map<String,Object>{
			    'status__c' => 'Draft',
			    'Venue__c' => venue.Id,
			    'Artists__c' => 'Test Artist',
			    'RecordTypeId' => RT_EVENT_PROMOTEDSHOW_ID
			}).buildEvent();
      //  insert event;
        LNE_TestObjectFactory.createStandardDataSet(event);
        evtDateTime = new EventDateTime__c(
            event__c = event.Id, 
            EventYear__c = String.valueOf(System.now().year() + 2));
        insert evtDateTime;
    }
    
  
    public void typicalSetup(){
      //-- specific setup here
    }
    
    public void finalize(){
      
    }
  }

  @testSetup
  static void setup(){
      LNE_TestObjectFactory.prepStandardCustomSettings();
  }

  //-- test test methods here
  static testMethod void schedulesWithoutException() {
    TestSettings ts = new TestSettings();
    ts.typicalSetup();
    ts.finalize();
    System.assert( true, 'No Exceptions have occurred in getting here' );
  }
  
  //-- test functionality here
  static testMethod void test1() {
    TestSettings ts = new TestSettings();
    ts.typicalSetup();
    ts.finalize();
    LNE_EventDateTime_CX evtDateTimeCtrl = new LNE_EventDateTime_CX( new ApexPages.StandardController(ts.evtDateTime));
    String pollInterval = evtDateTimeCtrl.getGridLostFocusPollInterval();
  }  
  
}