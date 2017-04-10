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
public class LNE_TBDCountUpdateClass_Batch_Test{
    

    static testMethod void testMethod1() 
    {
         LNE_GeneralSettingsUtil.setLocalBypassSettings(true, true, true);
          
            List<RecordType> rT = new List<RecordType>([SELECT Id, sObjectType, DeveloperName From RecordType Where  (DeveloperName='Rental' OR DeveloperName='Venue' OR DeveloperName='TBDEvents'OR DeveloperName='Office') ] ) ;
            String sRental, sVenue, sTBD;
            String sOffice;
            
            for (RecordType r : rT){
                 if(r.DeveloperName =='Rental' ) {sRental=r.Id;}
                 if(r.DeveloperName =='Venue' ) {sVenue=r.Id;}
                 if(r.DeveloperName =='TBDEvents' ) {sTBD=r.Id;}
                 if(r.DeveloperName =='Office' ) {sOffice=r.Id;}
            
            }
            System.debug(sOffice + ' , ' + sRental + ' , ' +  sVenue + ' , ' +  sTBD);
            
            List<Account> acL = new List<Account>(); 
            Integer i=0;
            Account c ;
            for(i=0;  i< 5 ; i++){
                               
              c = new  Account(TBDVenue__c =True, Name='TBDVENUE' +i , RecordTypeId=sVenue,BillingState='California', BillingPostalCode='92929', BillingCity='Same',BillingStreet='112 SAME' );
             acL.add(c);
            }
            insert acL; 
            
            Account tbdVenue2 = acL[2];
            System.debug(' tbdVenue2  = ' + tbdVenue2.Name);
            System.Assert(acL.size() == 5);
            /*
            System.debug(' sOffice  = ' + sOffice);
            List<Account> aLO = new  List<Account>( [SELECT Id,RecordTypeId,Name from Account Where RecordTypeId=:sOffice]);
            System.debug(aLO.size() +  '   '  + aLO[0]  );
            
            System.Assert(aLO[0].RecordTypeId == sOffice);
            */
             c = new  Account( Name='OFFICE', RecordTypeId=sOffice,BillingState='California', BillingPostalCode='92929', BillingCity='Same',BillingStreet='112 SAME',Type=
             'Office');
            insert c; 
            System.Assert(c.Id != null);
            
                        
                        date k1 = date.newInstance(2017, 01, 21);
                        date k2 = date.newInstance(2017, 02, 21);
                        date k3 = date.newInstance(2017, 03, 21);
                        date k4 = date.newInstance(2017, 04, 21);
                        date k5 = date.newInstance(2017, 05, 21);
                        date k6 = date.newInstance(2017, 06, 21);
                        date k7 = date.newInstance(2017, 07, 21);
                        date k8 = date.newInstance(2017, 08, 21);
                        date k9 = date.newInstance(2017, 09, 21);
                        date k10 = date.newInstance(2017, 10, 21);
                        date k11 = date.newInstance(2017, 11, 21);
                        date k12 = date.newInstance(2017, 12, 21);

                        List<Event__c> eL  = new List<Event__c>();
                        Event__c e;
                        Integer i1 = 0;
                         for (Account a : acL){
                                System.debug('i1  => ' + i1);
                                i1= i1+1;
                                System.debug('i1  => ' + i1);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k1, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k2, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k3, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k4, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k5, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k6, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k7, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k8, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k9, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k10, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k11, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,EventLastDate__c=k12, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                eL.add(e);
                                
                                
                                if (i1==3){
                                    e = new Event__c(Office__c=c.Id,EventLastDate__c=k12, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                    eL.add(e);
                                    e = new Event__c(Office__c=c.Id,EventLastDate__c=k12, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                    eL.add(e);
                                    e = new Event__c(Office__c=c.Id,EventLastDate__c=k12, Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sRental );
                                    eL.add(e);
                                    
                                    System.debug('i1  => ' + i1);
                                
                                
                                }
                        
                        }
                        insert eL;
                        System.Assert(eL.size() == 63);
                        eL  = new List<Event__c>();
                        for (Account a : acL){
                        
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='1', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='2', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='3', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='4', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='5', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='6', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='7', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='8', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='9', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='10', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='11', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                                e = new Event__c(Office__c=c.Id,TBDMonth__c='12', TBDYear__c='2017', Status__c='Confirmed', Venue__c=a.Id,RecordTypeId=sTBD );
                                eL.add(e);
                        
                        }
                             insert eL;
        
        
        Test.startTest();
        String q = 'SELECT Id, Venue__c, TBDConfirmedCount__c,TBDMonth__c, TBDYear__c, TBDVenue__c, TBDMonthValue__c, TBDYearValue__c, EventLastDate__c from Event__c WHERE  RecordTypeName__c!=:TBDEvents  AND SubType__c!=:FillerShow AND TBDVenue__c=True AND TBDMonthValue__c != null AND  TBDYearValue__c =: Year AND (Status__c  =: PendingLikely  OR Status__c  =:Confirmed) ';
       
            LNE_TBDCountUpdateClass_Batch obj = new LNE_TBDCountUpdateClass_Batch(q);
            Database.executeBatch(obj); 
            
        Test.stopTest();
    }
    
}