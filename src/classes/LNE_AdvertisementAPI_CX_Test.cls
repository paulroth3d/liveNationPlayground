@isTest
public class LNE_AdvertisementAPI_CX_Test {
	static final String RT_VENDOR = 'Account.Vendor';
    
    class TestSettings {
        
        public TestSettings() {

        }
        
        public Advertisement__c typicalSetup(String advertRecordType, Decimal commission){

        	//insert vendor
            Map<String,Id> accountRecordTypeMap = LNE_Util.getRecordTypes(
                    new String[]{RT_VENDOR}
            );

        	ID RT_VENDOR_ID = accountRecordTypeMap.get(RT_VENDOR);

            Account vendor = LNE_TestObjectFactory.createAccount('Test Vendor');
            vendor.RecordTypeId = RT_VENDOR_ID;
            vendor.Format__c = 'Country';

            insert vendor;

        	//insert adplan
            AdPlan__c adPlan = new AdPlan__c(
                AdPlanName__c = 'Test Ad Plan',
                LNEAdPlanBudget__c = 1000000,
                StandaloneDate__c = Date.today().addDays(7)
            );

            insert adPlan;

            //insert advertisement

        	Id recordTypeId;
        	if(advertRecordType != null) recordTypeId =
        		[select Id, name, developername from RecordType where Name =: advertRecordType and SobjectType = 'Advertisement__c'].Id;
	        Date startDate = Date.today();
            Date endDate = startDate.addDays(7);
	        
	        Advertisement__c ad = new Advertisement__c(	            
	            AdPlan__c =  adPlan.Id,
	            BuyType__c = LNE_Constants.AD_BUY_TYPE_REGULAR,
	            StartDate__c = startDate,
	            EndDate__c = endDate,
	            StartTime__c = '6:00 AM',
	            EndTime__c = '10:00 PM',
	            Net__c = 100000,
	            Format__c = 'Country',
	            Vendor__c = vendor.Id
	        );
	        if(recordTypeId != null) ad.RecordTypeId = recordTypeId;
	        if(commission != null) ad.Commission__c = commission;
	        insert ad;
         	return ad;
        }

      public void finalize(){
      
      }
    }
    
  //-- test test methods here

  @testSetup
  static void setup(){
      LNE_TestObjectFactory.prepStandardCustomSettings();
  }

  static testMethod void testAdvertisementAPI_Digital_with_Commission() {
  	//Test null Advertisement
  	TestSettings ts = new TestSettings();
    Advertisement__c ad = ts.typicalSetup(null,3000);
	   
	PageReference pageRef = Page.LNE_AdvertisementAPI;
	pageRef.getParameters().put('Advertisement__c', JSON.serialize(ad));
	pageRef.getParameters().put('callback', 'testApiCallback2');
	pageRef.getParameters().put('type', 'null');
	Test.setCurrentPageReference(pageRef);
	LNE_AdvertisementAPI_CX api = new LNE_AdvertisementAPI_CX();
	api.processRequest();
  }

  static testMethod void testAdvertisementAPI_Digital() {
  	//Test Digital Advertisement
  	TestSettings ts = new TestSettings();
    Advertisement__c ad = ts.typicalSetup('Digital',null);
	   
	PageReference pageRef = Page.LNE_AdvertisementAPI;
	pageRef.getParameters().put('Advertisement__c', JSON.serialize(ad));
	pageRef.getParameters().put('callback', 'testApiCallback2');
	pageRef.getParameters().put('type', 'Digital');
	Test.setCurrentPageReference(pageRef);
	LNE_AdvertisementAPI_CX api = new LNE_AdvertisementAPI_CX();
	api.processRequest();
  }

  static testMethod void testAdvertisementAPI_Outdoor() {
  	//Test Outdoor Advertisement
  	TestSettings ts = new TestSettings();
    Advertisement__c ad = ts.typicalSetup('Outdoor',null);
	   
	PageReference pageRef = Page.LNE_AdvertisementAPI;
	pageRef.getParameters().put('Advertisement__c', JSON.serialize(ad));
	pageRef.getParameters().put('callback', 'testApiCallback2');
	pageRef.getParameters().put('type', 'outdoor');
	Test.setCurrentPageReference(pageRef);
	LNE_AdvertisementAPI_CX api = new LNE_AdvertisementAPI_CX();
	api.processRequest();
  }

  static testMethod void testAdvertisementAPI_Print() {
  	//Test Print Advertisement
  	TestSettings ts = new TestSettings();
    Advertisement__c ad = ts.typicalSetup('Print',null);
	   
	PageReference pageRef = Page.LNE_AdvertisementAPI;
	pageRef.getParameters().put('Advertisement__c', JSON.serialize(ad));
	pageRef.getParameters().put('callback', 'testApiCallback2');
	pageRef.getParameters().put('type', 'Print');
	Test.setCurrentPageReference(pageRef);
	LNE_AdvertisementAPI_CX api = new LNE_AdvertisementAPI_CX();
	api.processRequest();
  }

  static testMethod void testAdvertisementAPI_Radio() {
  	//Test Radio Advertisement
  	TestSettings ts = new TestSettings();
    Advertisement__c ad = ts.typicalSetup('Radio',null);
	   
	PageReference pageRef = Page.LNE_AdvertisementAPI;
	pageRef.getParameters().put('Advertisement__c', JSON.serialize(ad));
	pageRef.getParameters().put('callback', 'testApiCallback2');
	pageRef.getParameters().put('type', 'Radio');
	Test.setCurrentPageReference(pageRef);
	LNE_AdvertisementAPI_CX api = new LNE_AdvertisementAPI_CX();
	api.processRequest();
  }

  static testMethod void testAdvertisementAPI_Television() {
  	//Test Television Advertisement
  	TestSettings ts = new TestSettings();
    Advertisement__c ad = ts.typicalSetup('Television',null);
	   
	PageReference pageRef = Page.LNE_AdvertisementAPI;
	pageRef.getParameters().put('Advertisement__c', JSON.serialize(ad));
	pageRef.getParameters().put('callback', 'testApiCallback2');
	pageRef.getParameters().put('type', 'Television');
	Test.setCurrentPageReference(pageRef);
	LNE_AdvertisementAPI_CX api = new LNE_AdvertisementAPI_CX();
	api.processRequest();
  }
}