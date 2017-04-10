/**
 * 
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class LNE_RunCalculation_Batch_Test{
    

    static testMethod void testMethod1() 
    {
        
         LNE_GeneralSettingsUtil.setLocalBypassSettings(true, true, true);
          
            List<RecordType> rT = new List<RecordType>([SELECT Id, sObjectType, DeveloperName From RecordType Where  (DeveloperName='Rental' OR DeveloperName='Venue' OR DeveloperName='Office') ] ) ;
            String sRental, sVenue;
            String sOffice;
            
            for (RecordType r : rT){
                 if(r.DeveloperName =='Rental' ) {sRental=r.Id;}
                 if(r.DeveloperName =='Venue' ) {sVenue=r.Id;}
                 if(r.DeveloperName =='Office' ) {sOffice=r.Id;}
            
            }
            System.debug(sOffice + ' , ' + sRental + ' , ' +  sVenue );
            
            List<Account> acL = new List<Account>(); 
            Integer i=0;
            Account c ;
            for(i=0;  i< 2 ; i++){
                               
              c = new  Account(TBDVenue__c =True, Name='TBDVENUE' +i , RecordTypeId=sVenue,BillingState='California', BillingPostalCode='92929', BillingCity='Same',BillingStreet='112 SAME' );
             acL.add(c);
            }
            insert acL; 
            
            Account tbdVenue1 = acL[1];
            System.debug(' tbdVenue1  = ' + tbdVenue1.Name);
            System.Assert(acL.size() == 2);
            
             c = new  Account( Name='OFFICE', RecordTypeId=sOffice,BillingState='California', BillingPostalCode='92929', BillingCity='Same',BillingStreet='112 SAME',Type=
             'Office');
            insert c; 
            System.Assert(c.Id != null);
            
            date k1  = Date.today();
          
            List<Event__c> evtE  = new List<Event__c>();
            Event__c e;
            
            for (Account a : acL){
                e = new Event__c(BatchFlag__c=false, Office__c=c.Id,EventLastDate__c=k1, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                evtE.add(e);                  
            }  
            insert evtE;
             
        
        Test.startTest();
            String q = 'Select  Id from Event__c where BatchFlag__c=false';
            
            LNE_RunCalculations_Batch obj = new LNE_RunCalculations_Batch(q);
            Database.executeBatch(obj); 
            
        Test.stopTest();
    }
 }