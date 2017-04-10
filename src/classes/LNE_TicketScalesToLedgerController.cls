/** 
 *  Controller class for the LNE_AssignTicketScaleToLedgerEntries VF page
 *  
 *  @author Scott Will
 **/
 public class LNE_TicketScalesToLedgerController {

    private final Event__c record;
    private final Id ledgerEntryId;

    private Boolean isSettlement;

    public transient Boolean isMultiScale { get; private set; }
    public transient List<EventDateTime> eventDateTimes { get; private set; }

    /**
    *  Wrapper class to add extra metadata to TicketScale__c objects
    **/
    public class TicketScale {

        public Boolean checked { get; set; }
        public Id recordId { get; private set; }
        public String pricelevelMessage { get; private set; }
        public TicketScale__c record { get; private set; }

        public TicketScale(TicketScale__c record, Boolean checked) {

            this.record = record;
            this.recordId = record.Id;
            this.checked = checked;

            // settlements get different messaging from the rest
            this.priceLevelMessage = record.StageType__c == 'Settlement'
                ? String.format('({0} sold tickets)', new List<String> { String.valueOf(record.ActualSalesToDate__c) })
                : String.format('({0} tickets at forecast)', new List<String> { String.valueOf(record.ProjectedPaidTickets__c) });

        }

    }

    /**
    *  Wrapper class to add extra metadata to EventDateTime__c objects
    **/
    public class EventDateTime {

        public EventDateTime__c record { get; private set; }
        public Id recordId { get; private set; }
        public List<TicketScale> ticketScales { get; private set; }

        public EventDateTime(Id recordId, EventDateTime__c record) {

            this.recordId = recordId;
            this.record = record;
            this.ticketScales = new List<TicketScale>();

        }

    }

    /**
    *  Contructor
    * @param    ApexPages.StandardController
    **/
    public LNE_TicketScalesToLedgerController(ApexPages.StandardController sc) {

        this.record = (Event__c)sc.getRecord();

        // get assigned values if there is a ledger entry param
        try {
            this.ledgerEntryId = (Id)ApexPages.currentPage().getParameters().get('ledgerEntryId');
        }
        catch (System.StringException se) {}

        // is this a settlement?  Settlments have slightly different logic regarding if it isMultiScale
        this.isSettlement = ApexPages.currentPage().getParameters().containsKey('StageType')
            ? ApexPages.currentPage().getParameters().get('StageType') == 'Settlement'
            : this.record.StatusStage__c == 'Settlement';

        // check event for type of ui (multiscale or not).
        // this will controll if the tabs are used. isMultiScale == true == tabs visible
        this.isMultiScale = this.isSettlement
            ? this.record.ShowCount__c > 1
            : this.record.UsingMultiScale__c;

        getTicketScaleList();

    }
    
    /**
    *  builds the list of EventDateTimes for the UI to consume
    **/
    public void getTicketScaleList() {

        this.eventDateTimes = new List<EventDateTime>();

        EventDateTime currentEventDateTime;
        Set<String> currentAssignedScales = getCurrentlyAssignedScales();
        //
        String stageType = this.isSettlement
            ? 'Settlement'
            : this.record.StatusStage__c;

        for (TicketScale__c ticketScaleRecord : [
            select
                ActualSalesToDate__c,
                EventDateTime__c,
                EventDateTime__r.EventDate__c,
                EventDateTime__r.StartTime__c,
                PriceLevel__c,
                ProjectedPaidTickets__c,
                StageType__c
            from TicketScale__c
            where Event__c = :this.record.Id
            and StageType__c = :stageType
            order by 
                EventDateTime__r.EventDate__c,
                EventDateTime__c,
                PriceLevel__c
        ]) {

            // on the first loop it will be null so always run the block, otherwise check if we're using mutliple
            // eventdatetimes and if the parent id has changed from the last one
            if (currentEventDateTime == null
             || (this.isMultiScale && currentEventDateTime.recordId != ticketScaleRecord.EventDateTime__c)
            ) {
                // add the old event date time
                addEventDateTime(currentEventDateTime);
                // create a new one
                currentEventDateTime = new EventDateTime(ticketScaleRecord.EventDateTime__c, ticketScaleRecord.EventDateTime__r);
            }

            // if not multiscale use record, otherwise it must have a parent EventDateTime__c
            if (!this.isMultiScale || ticketScaleRecord.EventDateTime__c != null) {
                // was the ticketscale associated with the ledger entry? i.e. will its checkbox be checked
                Boolean isCurrentlyAssigned = currentAssignedScales.contains(((String)ticketScaleRecord.Id).substring(0,15));
                // create and add the ticket scale
                TicketScale ticketScale = new TicketScale(ticketScaleRecord, isCurrentlyAssigned);
                currentEventDateTime.ticketScales.add(ticketScale);
            }

        }

        // grab last eventdatetime
        addEventDateTime(currentEventDateTime);

    }

    private void addEventDateTime(EventDateTime edt) {
        if (edt != null) {
            this.eventDateTimes.add(edt);
        }
    }
    
    /**
    *  Builds a set of TicketScale__c Ids found on the leger record. 
    *   @return Set<String>
    **/
    private Set<String> getCurrentlyAssignedScales() {
        
        Set<String> assignedTicketScales = new Set<String>();

        if (this.ledgerEntryId != null) {

            // use the ledgerEntryId to query the object dynamically.  all the SObjects 
            // used have the same TicketScaleList__c field
            List<SObject> records = Database.query('select TicketScaleList__c from ' + this.ledgerEntryId.getSObjectType().getDescribe().getName() + ' where Id = :ledgerEntryId');
            if (!records.isEmpty()) {

                String ticketScaleStr = String.valueOf(records[0].get('TicketScaleList__c'));
                if (String.isNotBlank(ticketScaleStr)) {
                    List<String> ticketScaleList = ticketScaleStr.split('\\|');

                    for (String s : ticketScaleList) {
                        if (String.isNotBlank(s)) {
                            assignedTicketScales.add(s.substring(0,15));
                        }
                    }

                    assignedTicketScales.remove('');
                }
            }
        }

        return assignedTicketScales;

    }

    /**
    *  Update the supplied record with the new list of TicketScale Ids
    **/
    @RemoteAction
    public static Boolean updateLedgerEntry(Id ledgerEntryId, String newTicketScaleList) {

        // use the Id to build the SObject dynamically.  ledgerEntryId may be multiple
        // types of SObjects, all will have the same TicketScaleList__c field
        SObject record = ledgerEntryId.getSObjectType().newSObject(ledgerEntryId);
        record.put('TicketScaleList__c', newTicketScaleList);

        Database.SaveResult result = Database.update(record, false);
        return result.isSuccess();

    }

}