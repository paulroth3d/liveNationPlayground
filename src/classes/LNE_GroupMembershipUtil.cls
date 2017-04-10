public without sharing class LNE_GroupMembershipUtil {
	public LNE_GroupMembershipUtil() {
		
	}

	// Return groups that have an active member with the listed profile.
	// Returns a map because it provides the greatest degree of flexibility.
	public static map<Id, Group> getGroupsForProfile(String profileName) {
	  map<Id, User> userMap = new map<Id, User>(
	  [SELECT Id, Name FROM User WHERE IsActive = true AND Profile.Name = :profileName]);
	  set<Id> groupIds = getGroupsForUserIds(userMap.keySet());
	  return new map<Id, Group>(
	    [SELECT Id, Name, Type FROM Group WHERE Id IN :groupIds]);
	}

	// Return groups that have an active member with the listed role.
	public static map<Id, Group> getGroupsForRole(String roleName) {
	  map<Id, User> userMap = new map<Id, User>(
	    [SELECT Id, Name FROM User WHERE IsActive = true AND UserRole.Name = :roleName]);
	  set<Id> groupIds = getGroupsForUserIds(userMap.keySet());
	  return new map<Id, Group>(
	    [SELECT Id, Name, Type FROM Group WHERE Id IN :groupIds]);
	}
	 
	// Return groups that have a member with this user ID.
	// This member may or may not be active.
	public static map<Id, Group> getGroupsForUser(Id userId) {
	  set<Id> groupIds = getGroupsForUserIds(new set<Id>{ userId });
	  return new map<Id, Group>(
	    [SELECT Id, Name, Type FROM Group WHERE Id IN :groupIds]);
	}

	// Return  groups that these users belong to; groups can belong
	// to other groups; recursive call may fail with a sufficiently
	// large hierarchy.
	public static set<Id> getGroupsForUserIds(set<Id> userOrGroupIds) {
	  set<Id> retVal = new set<Id>();
	   set<Id> nestedIds = new set<Id>();
	   // "Regular" groups are public groups.
	   // We are ignoring queues, roles, etc. on purpose.
	  list<GroupMember> members = 
	    [SELECT Id, GroupId, UserOrGroupId
	       FROM GroupMember
	      WHERE UserOrGroupId = :userOrGroupIds
	        AND UserOrGroupId != null
	        AND Group.Type = 'Regular'];
	  for (GroupMember member : members) {
	    // If UserOrGroupId is not a user, then add it to the list for recursion.
	    if (Schema.User.SObjectType != member.UserOrGroupId.getSobjectType()) {
	      nestedIds.add(member.UserOrGroupId);   
	    } else {
	      // We found a user, so add that group to the list.
	      retVal.add(member.GroupId);
	    }
	  }
	  // Recursive call.
	  if (nestedIds.size() > 0) {
	    // Relies on the uniqueness property of sets to prevent duplicates.
	    retVal.addAll(getGroupsForUserIds(nestedIds));
	  }
	  return retVal;
	}
	
	/*
	*	Retrieves the list of all the groups that a person belongs to
	*/
	public static Map<Id,Set<id>> getDirectAndIndirectGroupsForUserIdMult( Id userId ){
	    return( getDirectandIndirectGroupsForUserIdMult( new Id[]{ userId } ));
	}
	public static Map<Id,Set<id>> getDirectAndIndirectGroupsForUserIdMult( Id[] userIds ){
		//Groups directly associated to user
		Map<Id,Set<Id>> groupsUsersRelateTo = new Map<Id,Set<id>>();
		
		//-- determine role hierarchies
		
		Map<id,id> roleParentMap = new Map<id,id>();
		Map<Id,Set<id>> roleChildrenMap = new Map<id,Set<id>>();
		for( UserRole r : [ select id, name, parentRoleId from UserRole ] ){
		    roleParentMap.put( r.id, r.parentRoleId );
		    
		    if( !roleChildrenMap.containsKey( r.parentRoleId )){
		        roleChildrenMap.put( r.parentRoleId, new Set<Id>{ r.id } );
		    } else {
		        roleChildrenMap.get( r.parentRoleId ).add( r.id );
		    }
		}
		
		//-- @INVARIANT = roleParentMap is a map of all roles with that roles parentId
		//-- @INVARIANT = roleChildrenMap is a map of all roles with the immediate role subordinates
		
		//-- determine group memberships.
		
		Map<Id,Set<Id>> groupMembershipMap = new Map<Id,Set<Id>>();
		for(GroupMember gr : [
		    select id,UserOrGroupId,Groupid
		    from GroupMember where
		        (Group.Type = 'Regular' OR Group.Type='Role' OR Group.Type='RoleAndSubordinates')])
		{
		    if( !groupMembershipMap.containsKey( gr.UserOrGroupId )){
		        groupMembershipMap.put( gr.UserOrGroupId, new Set<Id>{ gr.GroupId } );
		    } else {
			    groupMembershipMap.get( gr.UserOrGroupId ).add( gr.GroupId );
		    }
		}
		
		System.debug( 'groupmembershipMap:' ); System.debug( groupMembershipMap );
		
		//-- @INVARIANT: groupMembershipMap is now a map for any member and the list of all the groups they belong to.
		
		Map<Id,Set<id>> relatedGroupMap = new Map<id,Set<Id>>();
		for( Group allGroup: [
		    select id, name, developerName, relatedId
		    from group
		]){
			if( allGroup.relatedId != null ){
    			if( !relatedGroupMap.containsKey( allGroup.relatedId )){
    			    relatedGroupMap.put( allGroup.relatedId, new Set<Id>{ allGroup.Id } );
    			} else {
    			    relatedGroupMap.get( allGroup.relatedId ).add( allGroup.Id );
    			}
			}
		}
		
		System.debug( 'relatedGroupMap:' ); System.debug( relatedGroupMap );
		
		//-- @INVARIANT: relatedGroupMap is a map of all relatedids - assumed role ids - by the groups related to them.
		
		Set<id> currentResults = new Set<Id>();
		Id userRoleId = null, userId = null;
		Set<id> userRoles = null, parentRoles = null, childrenRoles = null;
		Set<Id> currentMemberships = null;
		//Id roleId = null;
		for( user u : [ select id, UserRoleId from user where id in :userIds ]){
		    currentResults = new Set<id>();
		    
		    userId = u.id;
		    userRoleId = u.userRoleId;
		    parentRoles = getRoleParents( userRoleId, roleParentMap );
		    childrenRoles = getRoleChildren( userRoleId, roleChildrenMap);
		    
    		System.debug( 'currentUserRoleId[' + userId + ']:' + userRoleId );
    		System.debug( 'parentRoles[' + userId + ']:' + parentRoles );
    		System.debug( 'childrenRoles[' + userId + ']:' + childrenRoles );
    		
    		userRoles = new Set<id>{ userRoleId };
    		userRoles.addAll( parentRoles );
    		userRoles.addAll( childrenRoles );
		    
		    currentMemberships = new Set<id>();
		    for( Id roleId : userRoles ){
    		    if( relatedGroupMap.containsKey( roleId )){
        		    currentMemberships.addAll( relatedGroupMap.get( roleId ));
        		}
		    }
    		
    		if( groupMembershipMap.containsKey( userId )){
    		    currentMemberships.addAll( groupMembershipMap.get( userId ));
    		}
    		System.debug( 'currentMemberships[' + userId +']' ); System.debug( currentMemberships );
    		
    		currentResults.addAll( currentMemberships );
    		currentResults.addAll( getRelatedSubGroupMembership( currentMemberships, relatedGroupMap, groupMembershipMap ));
    		
    		System.debug( 'currentResults[' + userId +']:' ); System.debug( currentResults );
    		
		    groupsUsersRelateTo.put( userId, currentResults );
		}

        System.debug('####### End result of getDirectAndIndirectGroupsForUserIdMult' );
        System.debug(groupsUsersRelateTo);
        
		return( groupsUsersRelateTo );
	}
	
	/**
	 *  Retrieves the list of all the parent roles that contain a specific role
	 *  @param roleId (Id)
	 *  @param roleParents Map<Id,Set<id>>
	 *  @return set<id> - list of all roles that are the parent ids of the current role
	 **/
	private static set<id> getRoleParents( Id roleId, Map<id,id> roleParents ){
	    Set<Id> results = new Set<id>();
	    
	    //results.add( roleId );
	    
	    Id currentRoleId = roleId;
	    Id newParentRoleId = null;
	    while( currentRoleId != null ){
	        if( roleParents.containsKey( roleId )){
	            newParentRoleId = roleParents.get( currentRoleId );
	            if( newParentRoleId != null ){
	                results.add( newParentRoleId );
	            }
	            currentRoleId = newParentRoleId;
	        } else {
    	        currentRoleId = null;
	        }
	    }
	    
	    return( results );
	}
	
	/**
	 *  Gets all the children roles that this role considers subordinate
	 *  @param roleId (id)
	 *  @param roleParents Map<Id,Set<id>>
	 *  @return set<id> - set of roles that are subordinate
	 **/
	private static Set<id> getRoleChildren( Id role, Map<id,Set<Id>> roleChildrenMap ){
	    return( getRoleChildren( new Set<Id>{ role }, roleChildrenMap ));
	}
	private static Set<id> getRoleChildren( Set<id> currentRoles, Map<id,Set<Id>> roleChildrenMap ){
	    Set<id> results = new Set<Id>();
	    
	    System.debug( 'currentRoles:' ); System.debug( currentRoles );
	    
	    for( id currentRole : currentRoles ){
    		if( roleChildrenMap.containsKey( currentRole )){
    		    results.addAll( roleChildrenMap.get( currentRole ));
    		}
	    }
	    
	    System.debug( 'getRoleChildren_sub:' ); System.debug( results );
	    
	    if( results.size() > 0 ){
	        results.addAll( getRoleChildren( results, roleChildrenMap ));
	    }
	    
	    System.debug( 'getRoleChildren_sub2:' ); System.debug( results );
	    
	    return( results );
	}
	
	/**
	 * Determines all the groups that contain or are related to roles
	 * @param currentMemberships set<Id>
	 * @param relatedGroupMap Map<Id,Set<id>>
	 * @param groupMembershipMap Map<id,Set<id>>
	 * @return set<id> - set of all memberships that are related to those current memberships
	 **/
	private static Set<id> getRelatedSubGroupMembership( Set<id> currentMemberships, Map<Id,Set<id>> relatedGroupMap, Map<id,Set<id>> groupMembershipMap ){
	    Set<id> results = new Set<Id>();
	    
	    //System.debug( 'currentMemberships_sub:' ); System.debug( currentMemberships );
	    
	    for( id currentMembership : currentMemberships ){
    		/*
    		if( relatedGroupMap.containsKey( currentMembership )){
    		    results.addAll( relatedGroupMap.get( currentMembership ));
    		}
    		*/
    		
    		if( groupMembershipMap.containsKey( currentMembership )){
    		    results.addAll( groupMembershipMap.get( currentMembership ));
    		}
	    }
	    
	    //System.debug( 'results_sub:' ); System.debug( results );
	    
	    if( results.size() > 0 ){
	        results.addAll( getRelatedSubGroupMembership( results, relatedGroupMap, groupMembershipMap ));
	    }
	    
	    //System.debug( 'results_sub2:' ); System.debug( results );
	    
	    return( results );
	}
	
	
	// Return users who belong to a group and its sub-groups.
	public static map<Id, User> getUsersForGroup(Id groupId) {
	  set<Id> userIds = getUsersForGroupIds(new set<Id>{ groupId });
	  return new map<Id, User>(
	    [SELECT Id, Name, Email, IsActive, Profile.Name, UserRole.Name 
	       FROM User WHERE Id IN :userIds]);
	}
	 
	// Return users who belong to a group and its sub-groups.
	public static set<Id> getUsersForGroupIds(set<Id> groupIds) {
	  set<Id> retVal = new set<Id>();
	  set<Id> nestedIds = new set<Id>();
	  list<GroupMember> members = 
	    [SELECT Id, GroupId, UserOrGroupId
	       FROM GroupMember
	      WHERE GroupId = :groupIds
	        AND UserOrGroupId != null
	        AND Group.Type = 'Regular'];
	  for (GroupMember member : members) {
	    if (Schema.User.SObjectType != member.UserOrGroupId.getSobjectType()) {
	      nestedIds.add(member.UserOrGroupId);   
	    } else {
	      retVal.add(member.UserOrGroupId);
	    }
	  }
	  // Recursive call.
	  if (nestedIds.size() > 0) {
	    retVal.addAll(getUsersForGroupIds(nestedIds));
	  }
	  return retVal;  
	}


	public static Set<id> getDirectAndIndirectUsersForGroupId( Id groupId, Set<String> permissionSetNamesToFilter ){
		System.debug('!!!!! getDirectAndIndirectUsersForGroupId');

		List<GroupMember> baseGroupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :groupId];

		Set<Id> userIDs = new Set<Id>();
		Set<Id> roleIDs = new Set<Id>();
		Set<Id> groupIDs = new Set<Id>();

		for (GroupMember g : baseGroupMembers) {
			if (g.UserOrGroupId.getSObjectType() == Schema.User.SObjectType) {
				userIDs.add(g.UserOrGroupId);
			} else if (g.UserOrGroupId.getSObjectType() == Schema.Group.SObjectType) {
				groupIDs.add(g.UserOrGroupId);
			}
		}

		Set<Id> tempGroupIDs = new Set<Id>();
		tempGroupIDs.addAll(groupIDs);

		while (!tempGroupIDs.isEmpty()) {
			List<Group> groups = [SELECT Name, RelatedId FROM Group WHERE Id IN :tempGroupIDs];
			List<GroupMember> gm = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :groupIDs];
			tempGroupIDs = new Set<Id>();
			groupIDs = new Set<Id>();

			for (Group g : groups) {
				if (g.RelatedId != null) {
					if (g.RelatedId.getSObjectType() == Schema.UserRole.SObjectType) {
						roleIDs.add(g.RelatedId);
					} else if (g.RelatedId.getSObjectType() == Schema.Group.SObjectType) {
						groupIDs.add(g.RelatedId);
						tempGroupIDs.add(g.RelatedId);
					}
				}
			}

			for (GroupMember g : gm) {
				if (g.UserOrGroupId.getSObjectType() == Schema.User.SObjectType) {
					userIDs.add(g.UserOrGroupId);
				} else if (g.UserOrGroupId.getSObjectType() == Schema.Group.SObjectType) {
					groupIDs.add(g.UserOrGroupId);
					tempGroupIDs.add(g.UserOrGroupId);
				}
			}
		}

		List<UserRole> roles = [SELECT ParentRoleId FROM UserRole WHERE Id IN :roleIDs];
		Set<Id> parentRoleIds = new Set<Id>();

		for (UserRole ur : roles) {
			if (ur.ParentRoleId != null) {
				parentRoleIds.add(ur.ParentRoleId);
			}
		}

		Set<Id> idsToQuery = new Set<Id>();
		idsToQuery.addAll(parentRoleIds);
		roleIDs.addAll(parentRoleIds);

		while (!idsToQuery.isEmpty()) {
			List<UserRole> roleList = [SELECT ParentRoleId FROM UserRole WHERE Id IN :idsToQuery];
			idsToQuery = new Set<Id>();
			for (UserRole ur : roleList) {
				if (ur.ParentRoleId != null) {
					idsToQuery.add(ur.ParentRoleId);
					roleIDs.add(ur.ParentRoleId);
				}
			}
		}

		Map<Id, User> users = new Map<Id, User>([SELECT Name FROM User WHERE Id IN :userIDs OR UserRoleId IN :roleIDs]);
		system.debug(users); 

		Set<Id> results = new Set<Id>();  

		if (permissionSetNamesToFilter != null && permissionSetNamesToFilter.size() > 0) {
			List<PermissionSetAssignment> sets =  [select AssigneeId from PermissionSetAssignment where PermissionSet.Name IN :permissionSetNamesToFilter AND AssigneeId IN :users.keySet()];
			system.debug(sets);      

			for ( PermissionSetAssignment a : sets ) {
				results.add(a.AssigneeId);
			}
		} else {
			results.addAll(users.keySet());
		}
 		
 		System.debug('Final results from getDirectAndIndirectUsersForGroupId');
 		System.debug(results);

        return results;
	}

	public static Set<id> GetUserIdsFromGroup(Set<Id> groupIds) {
        // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<Id> groupIdProxys = new Set<Id>();
        // Loop through all group members in a group
        for(GroupMember m : [Select Id, UserOrGroupId, Group.Type, Group.RelatedId From GroupMember Where GroupId in :groupIds])
        {
            // If the user or group id is a user
            if(((String)m.UserOrGroupId).startsWith(userType))
            {
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m.UserOrGroupId).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
                groupIdProxys.add(m.userOrGroupId);
                
            }
        }
        if(groupIdProxys.size() > 0)
        {    
            Set<id> groupId = new set<id>();
            Set<id> roleId = new set<id>();
            Set<id> roleAndSubId = new set<Id>();

            for(Group g2 : [Select Id, Type, relatedId From Group Where Id = :groupIdProxys]){
                if(g2.Type == 'Role'){
                    roleId.add(g2.relatedId);    
                }
                else if(g2.Type== 'RoleAndSubordinates'){
                    roleAndSubId.add(g2.relatedId);    
                }
                else if(g2.Type== 'PRMOrganization'){
                    roleId.add(g2.relatedId);    
                }
                else if(g2.Type== 'Regular'){
                    groupId.add(g2.id);    
                }
                system.debug(g2);
            }
            if(roleAndSubId.size()>0){
                roleId.addAll(getAllSubRoleIds(roleAndSubId));
            }
            if(roleId.size()>0){
                for(User u: [select id from user where UserRoleId IN: roleId]){
                    result.add(u.id);
                }
            }
            if(groupId.size()>0){
                for(GroupMember gm : [select id, UserOrGroupId from GroupMember where GroupId IN: groupId]){
                    result.add(gm.UserOrGroupId);        
                }
            }
        }
        return result;  
    }
    
	public static Set<ID> getRoleSubordinateUsers(Id userId) {
		// get requested user's role
		Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
		// get all of the roles underneath the user
		Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
		// get all of the ids for the users in those roles
		Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
		  UserRoleId IN :allSubRoleIds]);

		System.debug('getRoleSubordinateUsers returns ' + users.keySet());


		// return the ids as a set so you can do what you want with them
		return users.keySet();
	}

	public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
		Set<ID> currentRoleIds = new Set<ID>();

		// get all of the roles underneath the passed roles
		for(UserRole userRole :[select Id from UserRole where ParentRoleId 
		  IN :roleIds AND ParentRoleID != null])
		currentRoleIds.add(userRole.Id);

		// go fetch some more roles
		if(currentRoleIds.size() > 0)
		  currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

		return currentRoleIds;
	}


}