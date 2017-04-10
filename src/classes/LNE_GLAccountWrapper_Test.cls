@isTest 
private class LNE_GLAccountWrapper_Test {

	class TestSettings {
        GLAccountWrapper[] glAccountList = new List<GLAccountWrapper>();
        
        public TestSettings() {
            //-- initialize common custom settings.
            LNE_TestObjectFactory.prepStandardCustomSettings();
        }
        
        public void typicalSetup(){
            glAccountList.add(new GLAccountWrapper(new GLAccount__c(
                Type__c = 'Expenses',
                Name = 'Travel Expense',
                Category__c = 'Production Expense',
                CategorySort__c = 4
            )));
            
            glAccountList.add(new GLAccountWrapper(new GLAccount__c(
                Type__c = 'Expenses',
                Name = 'Event Credit Card Charges',
                Category__c = 'Other Variable Expense',
                CategorySort__c = 2
            )));
            
            glAccountList.add(new GLAccountWrapper(new GLAccount__c(
                Type__c = 'Expenses',
                Name = 'Variable Rent/House Expense',
                Category__c = 'Event Rent Expense',
                CategorySort__c = 3
            )));
            
            glAccountList.add(new GLAccountWrapper(new GLAccount__c(
                Type__c = 'Expenses',
                Name = 'ASCAP/BMI/SESAC/GMR/BUMA Expense',
                Category__c = 'Other Variable Expense',
                CategorySort__c = 1
            )));
            
            glAccountList.sort();
        }
        
        public void finalize(){
        }
    }

    @isTest static void validateSortOrder() {
    	TestSettings ts = new TestSettings();
		ts.typicalSetup();
		ts.finalize();

        System.assertEquals('ASCAP/BMI/SESAC/GMR/BUMA Expense', ts.glAccountList[0].glAccount.Name);
        System.assertEquals('Event Credit Card Charges', ts.glAccountList[1].glAccount.Name);
        System.assertEquals('Variable Rent/House Expense', ts.glAccountList[2].glAccount.Name);
        System.assertEquals('Travel Expense', ts.glAccountList[3].glAccount.Name);
    }
}