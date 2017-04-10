/**
 * Way to get around the Process Builder limitation,
 * where an action is always required. (Seems silly)
 * @author Paul Roth <proth@salesforce.com>
 **/
public class LNE_ProcessBuilderNoAction {
	
	/**
	 * Action to do nothing.
	 * I swore I would not tell a joke here.
	 **/
    @InvocableMethod
    public static void noop(){
        
        /**
         * Explanation: This method will be invoked from the Process Builder when the Salesforce admin
         * does not want to execute any actions.
         * 
         * Once this idea is implemented https://success.salesforce.com/ideaView?id=08730000000DqGRAA0
         * this code will no longer be needed
         **/
        
    }
}