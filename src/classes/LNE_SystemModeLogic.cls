/** 
 *  Security Class that works in 'System Mode' (not based on user sharing rules.
 *  <p>This class should have the least amount of code possible to reduce security concerns.</p>
 *  @author Dominic Aveyard <daveyard@salesforce.com>
 *  @author Paul Roth <proth@salesforce.com>
 **/
public without sharing class LNE_SystemModeLogic {
    
    /**
     *  Method to save SalesForce changes when the current user may not have edit rights to do so.
     *  <p>For example: when performing a request on an account that the user is not an owner for.</p>
     *  <p>Note: Always include updates in wrappers as all other exceptions are still thrown</p>
     *  @param sObject (SObject)
     *  @return sObject
     *  @throws - additional errors
     **/
    public static SObject upsertRecords( SObject obj ){
        upsert obj;
        return obj;
    }
    
    /**
     *  Method to save SalesForce changes when the current user may not have edit rights to do so.
     *  <p>For example: when performing a request on an account that the user is not an owner for.</p>
     *  <p>Note: Always include updates in wrappers as all other exceptions are still thrown</p>
     *  @param objects (SObject[])
     *  @return sObject
     *  @throws - additional errors
     **/
    public static SObject[] upsertRecords( SObject[] objects ){
        upsert objects;
        return objects;
    }
}