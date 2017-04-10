@isTest
private class LNE_GroupMembershipUtil_Test {

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
        	PermissionSet testPS = [SELECT Id FROM PermissionSet WHERE Name = 'Booking' LIMIT 1];
        	PermissionSetAssignment pse = new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId=testPS.Id);
        	insert pse;

        	Group g = new Group(Name='Test Booking');
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

    @isTest static void testGroupUtil() {
    	TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();

		LNE_GroupMembershipUtil util = new LNE_GroupMembershipUtil();
		map<Id, Group> groupMap = LNE_GroupMembershipUtil.getGroupsForProfile(ts.testUser.Profile.Name);
		system.assert(groupMap.keySet().size() > 0);
		groupMap = LNE_GroupMembershipUtil.getGroupsForRole(ts.testUser.UserRole.Name);		
		groupMap = LNE_GroupMembershipUtil.getGroupsForUser(UserInfo.getUserId());
		system.assert(groupMap.keySet().size() > 0);
		map<Id, User> userMap = LNE_GroupMembershipUtil.getUsersForGroup(ts.testGroup.Id);
		system.assert(userMap.keySet().size() > 0);
		Set<Id> groupIds = new Set<Id>();
		groupIds.add(ts.testGroup.Id);
		Set<id> userIdSet = LNE_GroupMembershipUtil.getUsersForGroupIds(groupIds);
		system.assert(userIdSet.size() > 0);

		Set<Id> subUserIds = LNE_GroupMembershipUtil.getRoleSubordinateUsers(UserInfo.getUserId());
		Set<Id> userIds = LNE_GroupMembershipUtil.GetUserIdsFromGroup(groupIds);
		system.assert(userIds.size() > 0);

		userIds = LNE_GroupMembershipUtil.getDirectAndIndirectUsersForGroupId(ts.testGroup.Id, new Set<String>{'Booking'});
		system.assert(userIds.size() > 0);
		Set<Id> newRoleIds = LNE_GroupMembershipUtil.getAllSubRoleIds(ts.roleIds);
		system.assert(newRoleIds.size() > 0);
    }
}