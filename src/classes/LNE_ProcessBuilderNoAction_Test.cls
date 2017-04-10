/**
 * Test class for LNE_ProcessBuilderNoAction
 * @author Paul Roth <proth@salesforce.com>
 **/
@isTest
private class LNE_ProcessBuilderNoAction_Test {
	
	private static testMethod void testDoNothingDoesNothing() {
		try {
			LNE_ProcessBuilderNoAction.noop();
		} catch( Exception err ){
			System.assert( false, 'No Exceptions should be thrown when performing the noop' );
		}
	}
}