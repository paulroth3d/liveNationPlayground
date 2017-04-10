public class LNE_RT {
	
	public static String RT_COPROMOTER = 'Account.CoPromoter';
	public static String RT_ARTIST = 'Account.Artist';
	public static String RT_OFFICE = 'Account.Office';
	public static String RT_VENUE = 'Account.Venue';
	
    public static String RT_BUYSELL = 'Event__c.BuySell';
    public static String RT_RENTAL = 'Event__c.Rental';
    public static String RT_PROMOTEDSHOW = 'Event__c.PromotedShow';
    public static String RT_GOSPELBRUNCH = 'Event__c.GospelBrunch';
    public static String RT_FESTIVAL = 'Event__c.Festival';
    
    public static String RT_ANCILLARY = 'LedgerEntry__c.Ancillary';
    public static String RT_COGS = 'LedgerEntry__c.COGS';
    public static String RT_TICKETREVENUE = 'LedgerEntry__c.TicketRevenue';
    public static String RT_EXPENSES = 'LedgerEntry__c.Expenses';
    public static String RT_CONTRA = 'LedgerEntry__c.Contra';
    public static String RT_COPROMOTE_EXPENSE = 'LedgerEntry__c.CoPromoteExpense';
    public static String RT_COPROMOTE_REVENUE = 'LedgerEntry__c.CoPromoteRevenue';
    public static String RT_OTHER = 'LedgerEntry__c.Other';
    public static String RT_TALENT_FEES = 'LedgerEntry__c.TalentFees';
    
    private static Map<String,Id> pRecordTypeMap = null;
	public static Map<String,Id> recordTypeMap {
		get {
			if (pRecordTypeMap == null) {
				pRecordTypeMap = LNE_Util.getRecordTypes(
	            	new String[]{ 
	            	    RT_COPROMOTER, RT_ARTIST, RT_OFFICE, RT_VENUE, 
	            	    RT_BUYSELL, RT_RENTAL,  RT_PROMOTEDSHOW, RT_GOSPELBRUNCH, 
	            		RT_ANCILLARY, RT_COGS,RT_TICKETREVENUE, RT_EXPENSES, RT_CONTRA, RT_FESTIVAL, RT_COPROMOTE_EXPENSE,
                        RT_COPROMOTE_REVENUE, RT_OTHER, RT_TALENT_FEES});
			}
			return pRecordTypeMap;
		}
	}
	
	public static Id RT_COPROMOTER_ID = recordTypeMap.get( RT_COPROMOTER );
	public static Id RT_ARTIST_ID = recordTypeMap.get( RT_ARTIST );
	public static Id RT_OFFICE_ID = recordTypeMap.get( RT_OFFICE );
	public static Id RT_VENUE_ID = recordTypeMap.get( RT_VENUE );
	
	public static Id RT_BUYSELL_ID = recordTypeMap.get( RT_BUYSELL );
    public static Id RT_RENTAL_ID = recordTypeMap.get( RT_RENTAL );
    public static Id RT_PROMOTEDSHOW_ID = recordTypeMap.get( RT_PROMOTEDSHOW );
    public static Id RT_GOSPELBRUNCH_ID = recordTypeMap.get( RT_GOSPELBRUNCH );
    public static Id RT_FESTIVAL_ID = recordTypeMap.get(RT_FESTIVAL);
        
    public static Id RT_ANCILLARY_ID = recordTypeMap.get( RT_ANCILLARY );
    public static Id RT_COGS_ID = recordTypeMap.get( RT_COGS );
    public static Id RT_TICKETREVENUE_ID = recordTypeMap.get( RT_TICKETREVENUE );
    public static Id RT_EXPENSES_ID = recordTypeMap.get( RT_EXPENSES );
    public static Id RT_CONTRA_ID = recordTypeMap.get( RT_CONTRA );	
    public static Id RT_COPROMOTE_EXPENSE_ID = recordTypeMap.get( RT_COPROMOTE_EXPENSE );
    public static Id RT_COPROMOTE_REVENUE_ID = recordTypeMap.get( RT_COPROMOTE_EXPENSE );
    public static Id RT_OTHER_ID = recordTypeMap.get( RT_OTHER );
    public static Id RT_TALENT_FEES_ID = recordTypeMap.get( RT_TALENT_FEES );
}