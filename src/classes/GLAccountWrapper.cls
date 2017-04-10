global class GLAccountWrapper implements Comparable {
    public GLAccount__c glAccount;

    public GLAccountWrapper(GLAccount__c gla) {
        glAccount = gla;
    }

    global Integer compareTo(Object compareTo) {
        GLAccountWrapper compareToGlAccount = (GLAccountWrapper) compareTo;

        Integer returnValue = 0;
        
        if (glAccount.CategorySort__c > compareToGlAccount.glAccount.CategorySort__c) {
            returnValue = 1;
        } else if (glAccount.CategorySort__c < compareToGlAccount.glAccount.CategorySort__c) {
            returnValue = -1;
        }

        return returnValue;
    }
}