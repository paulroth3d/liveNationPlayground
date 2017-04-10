/**
 *  Router for all LNE_ArtistRetroStepUpDetail triggers.
 *  @author Dominic Aveyard <daveyard@salesforce.com>
 **/

trigger LNE_ArtistRetroStepUpDetail on ArtistRetroStepUpDetail__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

     System.debug('LNE_ArtistRetroStepUpDetail trigger fired');
     
    if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }
    
    if( Trigger.isBefore ){
        if (Trigger.isInsert) {
            LNE_RetroStepUpStartRangeValidation_T.execute( Trigger.new, Trigger.oldMap );  
                        LNE_ArtistRetroCopy_T.execute(Trigger.new);

        } 
        else if (Trigger.isUpdate) {
            LNE_RetroStepUpStartRangeValidation_T.execute( Trigger.new, Trigger.oldMap );
                        LNE_ArtistRetroCopy_T.execute(Trigger.new);

        } 
    }
    
}