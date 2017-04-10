/**
 *  Class that handles requesting updates to account information.
 *  User submits a text field. This class then:
 *      Appends the desired change to RequestedAccountUpdates__c
 *      Saves desired change to LatestAccountRequest__c
 *      Updates account status to 
 *  
 *  @author Dominic Aveyard <daveyard@salesforce.com>
 *
 **/

 public class LNE_RequestAccountUpdate_CX {

    private final SObject parent;
    private final Account updateAccount;

    /**
     *	hideToggle is a flag used by the VF page to know if any error/success messages 
	 * 	should be the shown. In other words, was the form just submitted
     *  TODO: There has to be a better name? even despite the inherint goofiness of naming toggles like this
     **/
    public Boolean hideToggle {get; set;}

    public String LatestAccountRequest {get; set;}
    public String formattedLatestAccountRequest {get; set;}

    String requestDate = date.today().format();
    String requester = userinfo.getName();
    String allUpdates = '';
    String successMsg = 'Thank you for your update, it has been marked for review.';

    public LNE_RequestAccountUpdate_CX(ApexPages.StandardController controller){ 
        parent = controller.getRecord();
        updateAccount = [SELECT Id, LatestAccountRequest__c, RequestedAccountUpdates__c, Status__c FROM Account 
            WHERE Id = :parent.id];
        hideToggle = true;
    }

    public Account getAccount() {
        return updateAccount;
    }

    public PageReference submit() {
        if (LatestAccountRequest.length() < 5) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Please enter an update that is 5 characters or longer.'));
        } else {
            allUpdates = updateAccount.RequestedAccountUpdates__c != null ? updateAccount.RequestedAccountUpdates__c : '';
            updateAccount.LatestAccountRequest__c = requestDate + ' ' + requester + ':\n' + LatestAccountRequest;
            formattedLatestAccountRequest = updateAccount.LatestAccountRequest__c;
            updateAccount.RequestedAccountUpdates__c = updateAccount.LatestAccountRequest__c + '\n\n' + allUpdates;
            updateAccount.Status__c = 'In Review';

            try {
                LNE_SystemModeLogic.upsertRecords(updateAccount);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, successMsg));
                hideToggle = false;
            } catch (Exception e) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }

        }

        return null;
    }
   
    
 }