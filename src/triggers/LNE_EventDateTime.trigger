/**
 *  Router for all Event Date Time triggers.
 *  @author Sebastian Gutierrez <sgutierrez@altimetrik.com>
 **/
trigger LNE_EventDateTime on EventDateTime__c (before insert, before update, before delete, after insert, after update, after delete) {

    if( GeneralSettings__c.getInstance().BypassAutomation__c == true || LNE_Util.IS_CURRENTLY_CLONING == true ){
        return;
    }
    
    if( Trigger.isBefore ){
    	if( Trigger.isInsert ){
    	    LNE_EventDateTimeUtil_T.checkVenueAccess(Trigger.new);
    	} else if( Trigger.isUpdate ){
    		
    	} else if( Trigger.isDelete ){
    		LNE_EventDateTimeUtil_T.deleteTicketScales(Trigger.oldMap);
    	}
    } else if( Trigger.isAfter ){
    	if( Trigger.isInsert ){
    	    LNE_EventShowCountCalculator_T.execute( Trigger.new );
    		LNE_EventStartEndTimeCalc_T.execute( Trigger.new, null );
            LNE_EventDateTimeUtil_T.checkForMultiScale(Trigger.new);
    	} else if( Trigger.isUpdate ){
    		LNE_EventStartEndTimeCalc_T.execute( Trigger.new, Trigger.oldMap );
    	} else if( Trigger.isDelete ){
    		LNE_EventDeletionUtil.checkIfHoldEventShouldBeDeleted(Trigger.old);
    	    LNE_EventShowCountCalculator_T.execute( Trigger.old );
    		LNE_EventStartEndTimeCalc_T.execute( null, Trigger.oldMap );
    	}
    }
    
}