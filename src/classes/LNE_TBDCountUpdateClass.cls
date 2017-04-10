/**
 * This class queries all events that has the TBDVenue__c
 * (All Account.TBDvenues__c=Y and not TBDEvents Record Type) flag, 
 * status is cofirmed or pending likely and not a filler show
 * Get the total count by venue, month and year and update 
 * the corresponding Event__c.TBDConfirmedCount__c 
 * 
 * @author Henry Akpala <hakpala@salesforce.com>
 **/
public class LNE_TBDCountUpdateClass {

            
           // public void TBDCountUpdateClass(){ 
             public void TBDCountUpdateClass(List<Event__c> listEvent){ 
                
                        Integer janCount=0,febCount=0,marCount=0,aprCount=0,mayCount=0,junCount=0,julCount=0,augCount=0,sepCount=0,octCount=0,novCount=0,decCount=0;
                       
                        //get current year
                        Date myDate = Date.today();
                        Integer intYear = myDate.Year();
                        List<Event__c> lstEvent = new List<Event__c>();
                        if(listEvent != null && listEvent.size()>0){
                            lstEvent.addAll( listEvent);
                        }else
                        {
                            //list of all events that are in tbd venues so they are flagged as tbdVenue__c = true
                                 lstEvent = new List<Event__c>([SELECT Id, Venue__c, TBDConfirmedCount__c,TBDMonth__c, TBDYear__c, TBDVenue__c, TBDMonthValue__c, TBDYearValue__c, EventLastDate__c from Event__c WHERE  RecordTypeName__c!='TBDEvents' AND (Status__c ='Pending Likely' OR Status__c ='Confirmed')
                             AND (SubType__c!='Filler Show') AND (TBDVenue__c=True) AND (TBDMonthValue__c != null) AND (TBDYearValue__c =:String.valueof(intYear) ) ]); 
                        }
                        //List of all TBD events records created for the TBD Events Record Type
                        List<Event__c> lstTBDEvents = new List<Event__c>([SELECT  Id, Status__c, Venue__c, TBDConfirmedCount__c, TBDVenue__c, TBDMonthValue__c, TBDMonth__c, TBDYear__c, TBDYearValue__c FROM Event__c WHERE RecordTypeName__c='TBDEvents' AND (TBDVenue__c=False) AND TBDYear__c=:String.valueof(intYear)  ]); 
                        
                        Set<Id> setTBDVenue = new Set<Id>();
                        //Get all the unique venues that are associated to Events in TBD Venues
                        for (Event__c e2 : lstTBDEvents){
                            setTBDVenue.add(e2.Venue__c);
                        }           
                        List<Event__c> lstToUpdate = new List<Event__c>();
                        // list of events for each tbdvenue
                        List<Event__c> lstSameVenue = new List<Event__c>();
                    
                        for (Id e3 : setTBDVenue){
                             
                              for (Event__c d : lstEvent){
                                    if( e3 == d.Venue__c){
                                          lstSameVenue.add(d);
                                          //get the count of each confirmed & pending likely event by month for all flagged tbd venues
                                          if (d.TBDMonthValue__c == '1')  {janCount++; }
                                          if (d.TBDMonthValue__c == '2')  {febCount++; }
                                          if (d.TBDMonthValue__c == '3')  {marCount++; }
                                          if (d.TBDMonthValue__c == '4')  {aprCount++; }
                                          if (d.TBDMonthValue__c == '5')  {mayCount++; }
                                          if (d.TBDMonthValue__c == '6')  {junCount++; }
                                          if (d.TBDMonthValue__c == '7')  {julCount++; }
                                          if (d.TBDMonthValue__c == '8')  {augCount++; }
                                          if (d.TBDMonthValue__c == '9')  {sepCount++; }
                                          if (d.TBDMonthValue__c == '10') {octCount++; }
                                          if (d.TBDMonthValue__c == '11') {novCount++; }
                                          if (d.TBDMonthValue__c == '12') {decCount++; }
                                    }
                              }//end for loop for event
                              //set the TBDConfirmedCount__c value for each month for all TBD Events.   
                              for (Event__c e : lstTBDEvents){
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '1') )  {e.TBDConfirmedCount__c    = janCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '2') )  {e.TBDConfirmedCount__c   = febCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '3') )  {e.TBDConfirmedCount__c   = marCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '4') )  {e.TBDConfirmedCount__c   = aprCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '5') )  {e.TBDConfirmedCount__c   = mayCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '6') )  {e.TBDConfirmedCount__c   = junCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '7') )  {e.TBDConfirmedCount__c   = julCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '8') )  {e.TBDConfirmedCount__c   = augCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '9') )  {e.TBDConfirmedCount__c   = sepCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '10'))  {e.TBDConfirmedCount__c   = octCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '11'))  {e.TBDConfirmedCount__c   = novCount; }
                                    if ( ( e3 == e.Venue__c) && (e.TBDMonth__c == '12'))  {e.TBDConfirmedCount__c   = decCount; }
                              }
                              janCount=0;febCount=0;marCount=0;aprCount=0;mayCount=0;junCount=0;julCount=0;augCount=0;sepCount=0;octCount=0;novCount=0;decCount=0;
                        }
                        //Update the TBD Events confirmed count value.
                        Database.update(lstTBDEvents);
                }
}