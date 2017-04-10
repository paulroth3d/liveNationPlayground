public with sharing class LNE_EventDateTime_CX {
	private static final GeneralSettings__c GENERAL_SETTINGS = GeneralSettings__c.getInstance();
    public String gridLostFocusPollInterval; 

	public LNE_EventDateTime_CX(ApexPages.StandardController controller) {
		
	}

    public String getGridLostFocusPollInterval() {
        String res = GENERAL_SETTINGS.Grid_Lost_Focus_Poll_Interval__c;
        return res;
    }
}