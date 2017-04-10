/**
 * Created by JK on 12/29/16.
 */
@isTest
public without sharing class LNE_Advertisement_T_Test {

    static final String RT_VENDOR = 'Account.Vendor';


    class TestSettings {

        public User adminUser;
        public User marketingUser;
        public AdPlan__c adPlan;
        public Map<ID, Schema.RecordTypeInfo> adRecordTypeIdObjectMap;
        public Map<String, Id> adRecordTypeStringIdMap = new Map<String, Id>();
        Set<String> trpRecordTypes = new Set<String>{'Television', 'Radio', 'Print'};

        public TestSettings(String buyType) {

            //insert test data
            String adminUserName = 'lne' + Math.round(Math.random() * 10000);
            String userName = 'lne' + Math.round(Math.random() * 10000);

            adminUser = LNE_TestObjectFactory.createAdminUser(adminUserName);
            marketingUser = LNE_TestObjectFactory.createMarketingUser(userName);

            System.runAs(adminUser){

                LNE_TestObjectFactory.prepStandardCustomSettings();

                //create a vendor
                Map<String,Id> accountRecordTypeMap = LNE_Util.getRecordTypes(
                        new String[]{RT_VENDOR}
                );

                ID RT_VENDOR_ID = accountRecordTypeMap.get(RT_VENDOR);

                Account vendor = LNE_TestObjectFactory.createAccount('Test Vendor');
                vendor.RecordTypeId = RT_VENDOR_ID;
                vendor.Format__c = 'Country';

                insert vendor;

                //Advertisement recordTypes
                adRecordTypeIdObjectMap = Schema.SObjectType.Advertisement__c.getRecordTypeInfosById();

                //ad buyTypes
                //insert adplan
                adPlan = new AdPlan__c(
                    AdPlanName__c = 'Test Ad Plan',
                    LNEAdPlanBudget__c = 1000000,
                    StandaloneDate__c = Date.today().addDays(7)
                );

                insert adPlan;

                //insert one Advertisement__c of each record type with buytype param
                List<Advertisement__c> ads = new List<Advertisement__c>();

                for(Id id : adRecordTypeIdObjectMap.keySet()){

                    RecordTypeInfo recordTypeInfo = adRecordTypeIdObjectMap.get(id);

                    if(recordTypeInfo.Name != 'Master'){
                        
                        adRecordTypeStringIdMap.put(recordTypeInfo.getName(), recordTypeInfo.getRecordTypeId());

                        Date startDate = Date.today();
                        Date endDate = startDate.addDays(7);

                        Advertisement__c ad = new Advertisement__c(
                            RecordTypeId = id,
                            AdPlan__c =  adPlan.Id,
                            BuyType__c = buyType,
                            StartDate__c = startDate,
                            EndDate__c = endDate,
                            StartTime__c = '6:00 AM',
                            EndTime__c = '10:00 PM',
                            Net__c = 100000,
                            Format__c = 'Country',
                            Vendor__c = vendor.Id
                        );

                        ads.add(ad);
                    }

                }

                insert ads;

                //create one insertion of each type for the tvp ads
                List<Insertion__c> insertions = new List<Insertion__c>();

                for(Advertisement__c ad : ads){
                    if(trpRecordTypes.contains(adRecordTypeIdObjectMap.get(ad.recordTypeId).getName())){

                        Integer diffDays = ad.StartDate__c.daysBetween(ad.EndDate__c);

                        if(ad.BuyType__c == LNE_Constants.AD_BUY_TYPE_REGULAR){
                            //AD_BUY_TYPE_REGULAR
                            //create one insertion with 10 spots for each date within the range

                            for(Integer i=0; i<=diffDays; i++){

                                Date cDate = ad.StartDate__c.addDays(i);

                                Insertion__c insertion = new Insertion__c(
                                        Date__c = cDate,
                                        NumberofSpots__c = 10,
                                        Advertisement__c = ad.Id
                                );

                                insertions.add(insertion);

                            }

                        }else if(ad.BuyType__c == LNE_Constants.AD_BUY_TYPE_PKG_DATES){
                            //AD_BUY_TYPE_PKG_DATES
                            //create one insertion with RunOnThisDate__c = true for each date within the range
                            //create master insertion with no date and 100 spots
                            for(Integer i=0; i<=diffDays; i++){

                                Date cDate = ad.StartDate__c.addDays(i);

                                Insertion__c insertion = new Insertion__c(
                                        Date__c = cDate,
                                        Advertisement__c = ad.Id
                                );

                                insertions.add(insertion);
                            }
                        }else{
                            //AD_BUY_TYPE_PKG_RANGE
                            //create master insertion with no date, no RunOnThisDate__c value and 100 spots
                            Insertion__c insertion = new Insertion__c(
                                    NumberofSpots__c = 100,
                                    Advertisement__c = ad.Id,
                                    RunOnThisDate__c = false
                            );

                            insertions.add(insertion);

                        }
                    }

                }

                insert insertions;


                //reselect and assert that the expected ads were created with the correct number of insertions
                ads = [Select Id, RecordTypeId, AdPlan__c, StartDate__c, EndDate__c, StartTime__c, EndTime__c, Name, BuyType__c, Net__c, Format__c, Vendor__c, (Select Id, Date__c, NumberofSpots__c, RunOnThisDate__c from Insertions__r) From Advertisement__c Where AdPlan__c = :adPlan.Id];

                System.assertEquals(6, ads.size(), 'Unexpected number of ads found.');

                //make sure only tpr ads (television, print, radio) have insertion records
                //verify that there are 8 insertions with counts=10 that have a date between the ad's start and end date
                for(Advertisement__c ad:ads){

                    String recordTypeName = adRecordTypeIdObjectMap.get(ad.RecordTypeId).getName();

                    if(trpRecordTypes.contains(recordTypeName)){
                        //assert that there are 8 insertions

                        if(ad.BuyType__c == LNE_Constants.AD_BUY_TYPE_REGULAR || ad.BuyType__c == LNE_Constants.AD_BUY_TYPE_PKG_DATES){

                            System.debug('ad.BuyType__c = ' + ad.BuyType__c);

                            System.assertEquals(8, ad.Insertions__r.size(), 'Advertisement__c has incorrect number of Insertion__c records');

                            for(Insertion__c insertion : ad.Insertions__r){

                                System.debug('insertion = ');
                                System.debug(insertion);

                                System.assertNotEquals(null, insertion.Date__c, 'Insertion__c is missing a value for Date__c');
                                System.assert(insertion.Date__c >= ad.StartDate__c && insertion.Date__c <= ad.EndDate__c, 'insertion.Date__c is not between ad.StartDate__c and ad.EndDate__c');

                                if(ad.BuyType__c == LNE_Constants.AD_BUY_TYPE_REGULAR){
                                    System.assertEquals(10, insertion.NumberofSpots__c, 'Incorrect value for insertion.NumberofSpots__c');
                                    //the default value of RunOnThisDate__c is true
                                    System.assertEquals(true, insertion.RunOnThisDate__c, 'Incorrect value for insertion.RunOnThisDate__c');
                                }else{
                                    System.assertEquals(null, insertion.NumberofSpots__c, 'Incorrect value for insertion.NumberofSpots__c');
                                    System.assertEquals(true, insertion.RunOnThisDate__c, 'Incorrect value for insertion.RunOnThisDate__c');
                                }

                            }

                            System.debug('----------------------');

                        }else{
                            System.assertEquals(1, ad.Insertions__r.size(), 'Advertisement__c has incorrect number of Insertion__c records');
                            System.assertEquals(100, ad.Insertions__r.get(0).NumberofSpots__c, 'Incorrect value for insertion.NumberofSpots__c');
                            System.assertEquals(false, ad.Insertions__r.get(0).RunOnThisDate__c, 'Incorrect value for insertion.RunOnThisDate__c');
                        }

                    }else{
                        //assert that there are 0 insertions
                        System.assertEquals(0, ad.Insertions__r.size(), 'Advertisement__c has unexpected number of Insertion__c records');
                    }
                }
            }
        }

        public void typicalSetup() {

        }


        public void finalize() {
        }
    }


    /**
     * create trp ads with regular buy type, then create master insertion and change buyType to Package Range
     * verify before and after state
     */
    @isTest
    static void testInsertionsRegular() {

        String buyType = LNE_Constants.AD_BUY_TYPE_REGULAR;

        Test.startTest();

        TestSettings ts = new TestSettings(buyType);
        ts.typicalSetup();

        //FIXME: running as marketingUser causes some sharing rule problem, probably because sharing group is not set up correctly
        //System.runAs(ts.marketingUser){
        System.runAs(ts.adminUser){

            //get all ads for ad plan
            List<Advertisement__c> ads = [Select Id, RecordTypeId, AdPlan__c, StartDate__c, EndDate__c, StartTime__c, EndTime__c, Name, BuyType__c, Net__c, Format__c, Vendor__c, (Select Id, Date__c, NumberofSpots__c, RunOnThisDate__c from Insertions__r) From Advertisement__c Where AdPlan__c = :ts.adPlan.Id];
            List<Insertion__c> newInsertions = new List<Insertion__c>();

            //we are reasserting the number of ads because we are (should be) running as a marketing user here, not an admin
            System.assertEquals(6, ads.size(), 'Unexpected number of ads found.');

            //prepare new insertion records
            for(Advertisement__c ad:ads){

                //create a master insertion record for each tvp ad with NumberofSpots__c = 100
                Insertion__c masterInsertion = new Insertion__c(
                        Advertisement__c = ad.Id,
                        NumberofSpots__c=100
                );

                newInsertions.add(masterInsertion);
            }

            //insert new master insertion
            insert newInsertions;

            //change ad buytype to LNE_Constants.AD_BUY_TYPE_PKG_RANGE
            for(Advertisement__c ad:ads){
                ad.BuyType__c = LNE_Constants.AD_BUY_TYPE_PKG_RANGE;
            }

            //save ad
            update ads;

            //select insertions for ad
            ads = [Select Id, RecordTypeId, AdPlan__c, StartDate__c, EndDate__c, StartTime__c, EndTime__c, Name, BuyType__c, Net__c, Format__c, Vendor__c, (Select Id, Date__c, NumberofSpots__c, RunOnThisDate__c from Insertions__r) From Advertisement__c Where AdPlan__c = :ts.adPlan.Id];

            System.assertEquals(6, ads.size(), 'Incorrect number of Advertisement__c records found.');

            //verify that one insertion is returned and that it is the previously created master insertion record
            for(Advertisement__c ad:ads){

                String recordTypeName = ts.adRecordTypeStringIdMap.get(ad.RecordTypeId);

                if(ts.trpRecordTypes.contains(recordTypeName)){
                    //assert that there is now 1 insertions
                    //the only remaining insertion should be the master insertion, all others should have been deleted
                    System.assertEquals(1, ad.Insertions__r.size(), 'Advertisement__c has incorrect number of Insertion__c records');

                    for(Insertion__c insertion : ad.Insertions__r){
                        System.assertEquals(null, insertion.Date__c, 'Insertion__c has incorrect value for Date__c');
                        System.assertEquals(100, insertion.NumberofSpots__c, 'Insertion__c has incorrect value for NumberofSpots__c');
                        System.assertEquals(false, insertion.RunOnThisDate__c, 'Insertion__c has incorrect value for RunOnThisDate__c');
                    }
                }
            }
        }

        Test.stopTest();

    }

    /**
     * create trp ads with regular package range buy type, then create date insertions for a range of dates that fall inside and outside of ad date range and change buyType to Package (Select Dates)
     * verify before and after state
     */
    @isTest
    static void testInsertionsRange() {
        String buyType = LNE_Constants.AD_BUY_TYPE_PKG_RANGE;

        Test.startTest();

        TestSettings ts = new TestSettings(buyType);
        ts.typicalSetup();

        //FIXME: running as marketingUser causes some sharing rule problem, probably because sharing group is not set up correctly
        //System.runAs(ts.marketingUser){
        System.runAs(ts.adminUser){

            //get all ads for ad plan
            List<Advertisement__c> ads = [Select Id, RecordTypeId, AdPlan__c, StartDate__c, EndDate__c, StartTime__c, EndTime__c, Name, BuyType__c, Net__c, Format__c, Vendor__c, (Select Id, Date__c, NumberofSpots__c, RunOnThisDate__c from Insertions__r) From Advertisement__c Where AdPlan__c = :ts.adPlan.Id];
            List<Insertion__c> newInsertions = new List<Insertion__c>();

            //we are reasserting the number of ads because we are (should be) running as a marketing user here, not an admin
            System.assertEquals(6, ads.size(), 'Unexpected number of ads found.');

            //prepare new insertion records
            for(Advertisement__c ad:ads){

                Date startDate = ad.StartDate__c.addDays(-3);
                Date endDate = ad.EndDate__c.addDays(4);
                Integer diffDays = startDate.daysBetween(endDate);

                //there should already be a master insertion record, so we do not need to create another

                //create 14 insertion records, 3 of which are before the ad's start date and 4 of which are after.
                Insertion__c dateInsertion;

                for(Integer i=0; i<=diffDays; i++){
                     dateInsertion = new Insertion__c(
                          Advertisement__c = ad.Id,
                          Date__c=startDate.addDays(i)
                    );

                    newInsertions.add(dateInsertion);
                }

            }

            //insert new master insertion
            insert newInsertions;

            //change buyType to LNE_Constants.AD_BUY_TYPE_PKG_DATES
            for(Advertisement__c ad:ads){
                ad.BuyType__c = LNE_Constants.AD_BUY_TYPE_PKG_DATES;
            }

            //save ad
            update ads;

            //verify that each trp ad has *9* insertion records.
            //there should be 8 that have a date between the ads start and end dates, no NumberofSpots__c value, and true for RunOnThisDate__c
            //there should be 1 that has the value of 100 for NumberofSpots__c, no date, and no value for RunOnThisDate__c
            for(Advertisement__c ad:ads){

                String recordTypeName = ts.adRecordTypeStringIdMap.get(ad.RecordTypeId);

                if(ts.trpRecordTypes.contains(recordTypeName)){
                    //assert that there are now 9 insertions
                    System.assertEquals(9, ad.Insertions__r.size(), 'Advertisement__c has incorrect number of Insertion__c records');

                    Integer numberOfMasterInsertions = 0;
                    Insertion__c masterInsertion = null;
                    List<Insertion__c> dateInsertions = new List<Insertion__c>();

                    for(Insertion__c insertion : ad.Insertions__r){

                        if(insertion.Date__c==null && insertion.RunOnThisDate__c==false){
                            if(masterInsertion==null){
                                masterInsertion = insertion;
                            }
                            numberOfMasterInsertions++;
                        }else{
                            dateInsertions.add(insertion);
                            System.assertEquals(true, insertion.RunOnThisDate__c, 'unexpected value for insertion.RunOnThisDate__c');
                            System.assertNotEquals(null, insertion.Date__c, 'unexpected value for insertion.Date__c');
                            System.assertEquals(null, insertion.NumberofSpots__c, 'unexpected value for insertion.NumberofSpots__c');
                            System.assert(insertion.Date__c >= ad.StartDate__c && insertion.Date__c <= ad.EndDate__c, 'insertion.Date__c is not between ad.StartDate__c and ad.EndDate__c');
                        }

                        System.assertNotEquals(null, masterInsertion, 'No master Insertion__c record found for ad.');
                        System.assertEquals(1, numberOfMasterInsertions, 'Wrong number of master Insertion__c records found for ad.');
                        System.assertEquals(8, dateInsertions.size(), 'Wrong number of date Insertion__c records found for ad.');

                    }
                }
            }
        }

        Test.stopTest();

    }

    @isTest
    static void testInsertionsDates() {

        String buyType = LNE_Constants.AD_BUY_TYPE_PKG_DATES;

        Test.startTest();

        TestSettings ts = new TestSettings(buyType);
        ts.typicalSetup();

        //FIXME: running as marketingUser causes some sharing rule problem, probably because sharing group is not set up correctly
        //System.runAs(ts.marketingUser){
        System.runAs(ts.adminUser){

            //get all ads for ad plan
            List<Advertisement__c> ads = [Select Id, RecordTypeId, AdPlan__c, StartDate__c, EndDate__c, StartTime__c, EndTime__c, Name, BuyType__c, Net__c, Format__c, Vendor__c, (Select Id, Date__c, NumberofSpots__c, RunOnThisDate__c from Insertions__r) From Advertisement__c Where AdPlan__c = :ts.adPlan.Id];
            List<Insertion__c> newInsertions = new List<Insertion__c>();

            //we are reasserting the number of ads because we are (should be) running as a marketing user here, not an admin
            System.assertEquals(6, ads.size(), 'Unexpected number of ads found.');

            //prepare new insertion records
            for(Advertisement__c ad:ads){

                Date startDate = ad.StartDate__c.addDays(-3);
                Date endDate = ad.EndDate__c.addDays(4);
                Integer diffDays = startDate.daysBetween(endDate);

                //create 14 insertion records, 3 of which are before the ad's start date and 4 of which are after.
                Insertion__c dateInsertion;

                for(Integer i=0; i<=diffDays; i++){
                    dateInsertion = new Insertion__c(
                            Advertisement__c = ad.Id,
                            NumberofSpots__c = 10,
                            Date__c=startDate.addDays(i)
                    );

                    newInsertions.add(dateInsertion);
                }

            }

            //insert new master insertion
            insert newInsertions;

            //change buyType to LNE_Constants.AD_BUY_TYPE_REGULAR
            for(Advertisement__c ad:ads){
                ad.BuyType__c = LNE_Constants.AD_BUY_TYPE_REGULAR;
            }

            //save ad
            update ads;

            //verify that each trp ad has *8* insertion records.
            //there should be 8 that have a date between the ads start and end dates, NumberofSpots__c = 10, and true for RunOnThisDate__c
            for(Advertisement__c ad:ads){

                String recordTypeName = ts.adRecordTypeStringIdMap.get(ad.RecordTypeId);

                if(ts.trpRecordTypes.contains(recordTypeName)){
                    //assert that there are now 9 insertions
                    System.assertEquals(8, ad.Insertions__r.size(), 'Advertisement__c has incorrect number of Insertion__c records');

                    Integer numberOfMasterInsertions = 0;
                    Insertion__c masterInsertion = null;
                    List<Insertion__c> dateInsertions = new List<Insertion__c>();

                    for(Insertion__c insertion : ad.Insertions__r){

                        if(insertion.Date__c==null && insertion.RunOnThisDate__c==false){
                            if(masterInsertion==null){
                                masterInsertion = insertion;
                            }
                            numberOfMasterInsertions++;
                        }else{
                            dateInsertions.add(insertion);

                            System.assertEquals(true, insertion.RunOnThisDate__c, 'unexpected value for insertion.RunOnThisDate__c');
                            System.assertNotEquals(null, insertion.Date__c, 'unexpected value for insertion.Date__c');
                            System.assertEquals(10, insertion.NumberofSpots__c, 'unexpected value for insertion.NumberofSpots__c');
                            System.assert(insertion.Date__c >= ad.StartDate__c && insertion.Date__c <= ad.EndDate__c, 'insertion.Date__c is not between ad.StartDate__c and ad.EndDate__c');
                        }

                        System.assertEquals(null, masterInsertion, 'A master Insertion__c record was found for ad when there should be none.');
                        System.assertEquals(0, numberOfMasterInsertions, 'Wrong number of master Insertion__c records found for ad.');
                        System.assertEquals(8, dateInsertions.size(), 'Wrong number of date Insertion__c records found for ad.');

                    }
                }
            }
        }

        Test.stopTest();
    }
}