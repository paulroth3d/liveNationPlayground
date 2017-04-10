/**
 *  Runs the neccessary calculation for the field Deal__c.InclusiveArtistExpensesPerDealCalc__c
 *
 *  @author Scott Will
 *  @group Trigger
 *
**/
public with sharing class LNE_InclusiveArtistExpensesPerDealCalc_T {
    
    private static final Id RT_ARTIST_ID;
    
    private static final Set<String> FIELDS_DEAL = new Set<String> {
        'ArtistSuppliedSL__c',
        'DealCalculation__c',
        'OtherTalentAmount__c',
        'SplitPercentage__c'
    };
    private static final Set<String> FIELDS_EVENT = new Set<String> {
        'TotalSupportActExpenses__c'
    };

    private static final String VALUE_GUARANTEE_ONLY = 'Guarantee Only';
    private static final String VALUE_INCLUSIVE_OTHER_TALENT_AMOUNT = 'Inclusive of Other Talent Amount';
    private static final String VALUE_INCLUSIVE_SOUND_LIGHTS_OTHER_TALENT_AMOUNT = 'Inclusive of Sound & Lights & Other Talent Amount';
    private static final String VALUE_INCLUSIVE_SOUND_LIGHTS_SUPPORT_OTHER_TALENT_AMOUNT = 'Inclusive of Sound & Lights & Support & Other Talent Amount';
    private static final String VALUE_INCLUSIVE_SOUND_LIGHTS_SUPPORT = 'Inclusive of Sound & Lights & Support';
    private static final String VALUE_INCLUSIVE_SOUND_LIGHTS = 'Inclusive of Sound & Lights';
    private static final String VALUE_INCLUSIVE_SUPPORT_OTHER_TALENT_AMOUNT = 'Inclusive of Support And Other Talent Amount';
    private static final String VALUE_INCLUSIVE_SUPPORT = 'Inclusive of Support';

    static {

        // none of this is needed outside of the static construction, we only need the IDs
        String RT_ARTIST = 'Deal__c.Artist';
        Map<String,Id> recordTypeMap = LNE_Util.getRecordTypes(
            new String[]{ RT_ARTIST }
        );

        RT_ARTIST_ID = recordTypeMap.get( RT_ARTIST );

    }

    private Map<Id,Event__c> events = new Map<Id,Event__c>();
    private List<Deal__c> deals = new List<Deal__c>();

    public LNE_InclusiveArtistExpensesPerDealCalc_T() {
        this.events = new Map<Id,Event__c>();
        this.deals = new List<Deal__c>();
    }

    /**
     *  The public entry point.  Prepares any information needed and call the calculation logic.
     *
     *  @param oldMap Map<Id,SObject>
     *  @param newList Sobject[]
     *  @return void
     *
    **/
    public void execute(Map<Id,SObject> oldObjects, List<SObject> newObjects) {

        Boolean needsSave = false;
        SObjectType objType = newObjects[0].getSObjectType();

        // if oldObjects are null then it's an insert, just make it empty
        if (oldObjects == null) {
            oldObjects = new Map<Id,SObject>();
        }

        // figure out how to load the relevant information depending upon the SObjectType
        if (objType == Deal__c.getSObjectType()) {
            // prepare from Deal perspective, will load related parent events
            Map<Id,Deal__c> dealsMap = new Map<Id,Deal__c>((List<Deal__c>)oldObjects.values());
            prepareDeal(dealsMap, newObjects);
        }
        else if (objType == Event__c.getSObjectType()) {
            // prepare from the event perspective, will load related child deals
            Map<Id,Event__c> eventsMap = new Map<Id,Event__c>((List<Event__c>)oldObjects.values());
            prepareEvent(eventsMap, newObjects);
            needsSave = true;
        }

        if (!this.deals.isEmpty()) {
            
            // call thr calculation logic for any relevant deals
            calculateInclusiveArtistExpensesPerDealCalc();

            // save the deals if the trigger is from the event
            if (needsSave) {
                update this.deals;
            }

        }

    }

    /**
     *  Runs the actual calculation against Deal__c.InclusiveArtistExpensesPerDealCalc__c
     *  @return void
    **/
    private void calculateInclusiveArtistExpensesPerDealCalc() {

        // for each deal run the math that corresponds to each type of Deal Calculation
        for (Deal__c deal : this.deals) {
            
            Decimal totalSupportActExpenses = 0.0;
            Event__c parent = events.get(deal.Event__c);

            if (parent != null) {
                Decimal safeSplit = safeDecimal(deal.SplitPercentage__c, deal.Type__c == 'Primary Headliner' ? 100 : 0) / 100;
                totalSupportActExpenses = safeMul(new List<Decimal> { parent.TotalSupportActExpenses__c, safeSplit });
            }

            // build a mapping of the possible calculations.  avoids heavy if-branching
            Map<String,Decimal> calculations = new Map<String,Decimal> {
                VALUE_INCLUSIVE_OTHER_TALENT_AMOUNT => safeDecimal(deal.OtherTalentAmount__c),
                VALUE_INCLUSIVE_SOUND_LIGHTS_OTHER_TALENT_AMOUNT => safeAdd(new List<Decimal> { deal.ArtistSuppliedSL__c, deal.OtherTalentAmount__c }),
                VALUE_INCLUSIVE_SOUND_LIGHTS_SUPPORT_OTHER_TALENT_AMOUNT => safeAdd(new List<Decimal> { deal.ArtistSuppliedSL__c, deal.OtherTalentAmount__c, totalSupportActExpenses }),
                VALUE_INCLUSIVE_SOUND_LIGHTS_SUPPORT => safeAdd(new List<Decimal> { deal.ArtistSuppliedSL__c, totalSupportActExpenses }),
                VALUE_INCLUSIVE_SOUND_LIGHTS => safeAdd(new List<Decimal> { deal.ArtistSuppliedSL__c }),
                VALUE_INCLUSIVE_SUPPORT_OTHER_TALENT_AMOUNT => safeAdd(new List<Decimal> { deal.OtherTalentAmount__c, totalSupportActExpenses })
            };

            // get back the specific calculation, giving the default 0
            deal.InclusiveArtistExpensesPerDealCalc__c = calculations.containsKey(deal.DealCalculation__c)
                ? safeDecimal(calculations.get(deal.DealCalculation__c), totalSupportActExpenses)
                : 0.0;

        }

    }

    /**
     *  Prepares the neccessary data starting from the POV of a Deal__c
     *  @param oldDeals, Map{Id=>Deal__c}
     *  @param newDeals, Deal__c[]
     *  @return void
    **/
    private void prepareDeal(Map<Id,Deal__c> oldDeals, List<Deal__c> newDeals) {

        // get back just the specific deals that need an update
        List<Deal__c> relevantDeals = getRelevantRecords(oldDeals, newDeals, FIELDS_DEAL);

        if (!relevantDeals.isEmpty()) {

            // find their parent event ids
            List<Deal__c> artistDeals = new List<Deal__c>();
            Set<Id> parentEventIds = new Set<Id>();
            for (Deal__c newDeal : newDeals) {
                if (newDeal.RecordTypeId == RT_ARTIST_ID) {
                    parentEventIds.add(newDeal.Event__c);
                    artistDeals.add(newDeal);
                }
            }

            if (!parentEventIds.isEmpty()) {
                // load up the events and deals
                this.events.putAll([
                    select
                        TotalSupportActExpenses__c
                    from Event__c
                    where Id in :parentEventIds
                ]);
                this.deals.addAll(artistDeals);
            }

        }

    }

    /**
     *  Prepares the neccessary data starting from the POV of an Event__c
     *  @param oldEvents, Map{Id=>Event__c}
     *  @param newEvents, Event__c[]
     *  @return void
    **/
    private void prepareEvent(Map<Id,Event__c> oldEvents, List<Event__c> newEvents) {

        // get back just the specific events whose deals will need an update
        List<Event__c> relevantEvents = getRelevantRecords(oldEvents, newEvents, FIELDS_EVENT);

        if (!relevantEvents.isEmpty()) {

            // load up the events and deals
            this.events.putAll(relevantEvents);
            this.deals.addAll([
                select
                    ArtistSuppliedSL__c,
                    DealCalculation__c,
                    Event__c,
                    OtherTalentAmount__c,
                    SplitPercentage__c,
                    Type__c
                from Deal__c
                where Event__c in :events.keySet()
            ]);

        }

    }

    /**
     *  Generic method to loop over a set of SObjects and look for any change (simple OR)
     *  @param objObjects, SObject[]
     *  @param newObjects, SObject[]
     *  @param fields, Set the list of fields to check
     *  @return SObject[] list of objects that had a change
    **/
    private static List<SObject> getRelevantRecords(Map<Id,SObject> oldObjects, List<SObject> newObjects, Set<String> fields) {

        List<SObject> relevantRecords = new List<SObject>();

        for (SObject newObject : newObjects) {

            SObject oldObject = oldObjects.get(newObject.Id);
            if (hasChange(oldObject, newObject, fields)) {
                relevantRecords.add(newObject);
            }

        }

        return relevantRecords;

    }

    /**
     *  Checks for a change amongst any of the supplied fields
     *  @param objObject, SObject
     *  @param newObject, SObject
     *  @param fields, Set the list of fields to check
     *  @return Boolean, true if a change is detected on any of the supplied fields
    **/
    private static Boolean hasChange(SObject oldObject, SObject newObject, Set<String> fields) {

        if (oldObject == null) {
            return true;
        }

        ChangedEvent objChange = new ChangedEvent(oldObject, newObject);
        for (String field : fields) {
            if (objChange.notEquals(field)) {
                return true;
            }
        }

        return false;

    }

    private static Decimal safeAdd(List<Decimal> parts) {
        Decimal sum = 0;
        for (Decimal d : parts) {
            sum += safeDecimal(d);
        }
        return sum;
    }

    private static Decimal safeMul(List<Decimal> parts) {
        Decimal product = 1;
        for (Decimal d : parts) {
            product *= safeDecimal(d, 1);
        }
        return product;
    }

    private static Decimal safeDecimal(Decimal d) {
        return safeDecimal(d, 0);
    }

    private static Decimal safeDecimal(Decimal d, Decimal def) {
        return d == null ? def : d;
    }

    private class ChangedEvent extends LNE_SObjectChange {
        
        ChangedEvent( SObject oldObject, SObject newObject ){
            super( oldObject, newObject );
        }

    }

}