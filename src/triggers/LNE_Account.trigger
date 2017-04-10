/**
 *  Router for all Accounts triggers.
 *  @author Paul Roth <proth@salesforce.com>
 *  @author John Casimiro <jcasimiro@salesforce.com>
 **/
trigger LNE_Account on Account (before insert, after insert, before update, after update){
    if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }
    
    if( Trigger.isBefore ){
        if( Trigger.isUpdate ){
            LNE_AccountTermsUpdated_T.execute( Trigger.new, Trigger.oldMap);
            LNE_AccountDMA_Autoassign_T.execute( Trigger.new, Trigger.oldMap);
        } else if( Trigger.isInsert ){
            LNE_AccountDMA_Autoassign_T.execute( Trigger.new, Trigger.oldMap);
        }
    } else if( Trigger.isAfter ){
        if( Trigger.isInsert ){
            LNE_ArtistAgencyAssign_T.execute( Trigger.new, Trigger.oldMap );
            LNE_VenueOfficeAssign_T.execute( Trigger.new, Trigger.oldMap );
        } else if( Trigger.isUpdate ){
            LNE_ArtistAgencyAssign_T.execute( Trigger.new, Trigger.oldMap );
            LNE_VenueOfficeAssign_T.execute( Trigger.new, Trigger.oldMap );
        }
    }
}