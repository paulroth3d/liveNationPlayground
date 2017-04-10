@isTest
private class LNE_UserOfficeAccessBatch_Test {
	static String officeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Office').getRecordTypeId();

	class TestSettings {
		Group testGroup;
        User testUser;
        Set<Id> roleIds;
        
        public TestSettings() {
            //- Need to comment out this custom setting init, otherwise we're getting
            //- the MIXED_DML_OPERATION exception
            //LNE_TestObjectFactory.prepStandardCustomSettings();
        }
        
        public void typicalSetup(){

        	Group g = new Group(Name='Test Test Test Booking');
        	insert g;

        	Group g2 = new Group(Name='Test Group');
        	insert g2;

        	GroupMember gm = new GroupMember();
        	gm.GroupId = g.Id;
        	gm.UserOrGroupId = UserInfo.getUserId();
        	insert gm;

        	GroupMember gm2 = new GroupMember();
        	gm2.GroupId = g.Id;
        	gm2.UserOrGroupId = g2.id;
        	insert gm2;

        	testGroup = g;

            testUser = [SELECT Profile.Name, UserRole.Name, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];

            UserRole newRole = new UserRole(Name='TestRole12345');
            insert newRole;

            UserRole newRole2 = new UserRole(Name='TestRole99999');
            insert newRole2;

            UserRole newRole3 = new UserRole(Name='TestRole00000');
            insert newRole3;

            newRole.ParentRoleId = newRole2.Id;
            update newRole;

            newRole2.ParentRoleId = newRole3.Id;
            update newRole2;

            testUser.UserRoleId = newRole.Id;
            update testUser;

            roleIds = new Set<Id>{newRole.Id, newRole2.Id, newRole3.Id}; 
        }
        
        public void finalize(){
        }
    }

    @TestSetup static void setupData() {
    	LNE_TestObjectFactory.prepStandardCustomSettings();
    	LNE_TestObjectFactory.createStandardDataSet();

    	Account office = [SELECT OfficeID__c FROM Account WHERE RecordTypeId = :officeRecordTypeId LIMIT 1];
    	office.OfficeID__c = 'TS';
    	office.Name = 'Test Test Test';
    	update office;
    }

    @isTest static void testOfficeAssignment() {
    	TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();

    	Test.startTest();

    	LNE_UserOfficeAccessBatch b = new LNE_UserOfficeAccessBatch();
		Database.executeBatch(b);

		Test.stopTest();

		User u = [SELECT OfficeAccess__c FROM User WHERE Id = :UserInfo.getUserId()];
		system.assert(u.OfficeAccess__c.contains('TS'));
    }
}