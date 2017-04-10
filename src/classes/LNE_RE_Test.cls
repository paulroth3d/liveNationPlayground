@isTest
private class LNE_RE_Test {
   	//-- test functionality here
	
    static testMethod void testScenario() {

        //-- your logic off of any info from TS here
        
        System.assertNotEquals(null, LNE_RT.RT_COPROMOTER);
        System.assertNotEquals(null, LNE_RT.RT_ARTIST_ID);
        System.assertNotEquals(null, LNE_RT.RT_OFFICE_ID);
        System.assertNotEquals(null, LNE_RT.RT_VENUE_ID);
        
        System.assertNotEquals(null, LNE_RT.RT_BUYSELL_ID);
        System.assertNotEquals(null, LNE_RT.RT_RENTAL_ID);
        System.assertNotEquals(null, LNE_RT.RT_PROMOTEDSHOW_ID);
        System.assertNotEquals(null, LNE_RT.RT_GOSPELBRUNCH_ID);
        System.assertNotEquals(null, LNE_RT.RT_FESTIVAL_ID);
        
        
        System.assertNotEquals(null, LNE_RT.RT_ANCILLARY);
        System.assertNotEquals(null, LNE_RT.RT_COGS);
        System.assertNotEquals(null, LNE_RT.RT_TICKETREVENUE);
        System.assertNotEquals(null, LNE_RT.RT_EXPENSES);
        System.assertNotEquals(null, LNE_RT.RT_CONTRA);
        System.assertNotEquals(null, LNE_RT.RT_COPROMOTE_EXPENSE);
        System.assertNotEquals(null, LNE_RT.RT_COPROMOTE_EXPENSE);
        System.assertNotEquals(null, LNE_RT.RT_PROMOTEDSHOW_ID);
        System.assertNotEquals(null, LNE_RT.RT_OTHER);
        System.assertNotEquals(null, LNE_RT.RT_TALENT_FEES);
    }

}