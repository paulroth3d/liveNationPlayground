/**
 * Created by JK on 1/12/17.
 */

public with sharing class LNE_PromoScale_T {

    public static void calculateTotalTicketValues(Map<Id, PromoScale__c> newMap){

        List<PromoPromoScale__c> promoPromoScales = [Select Id, Promo_Scale__c, NumberofTickets__c, TicketValue__c From PromoPromoScale__c where Promo_Scale__c in :newMap.keySet()];
        List<PromoPromoScale__c> promoPromoScalesToUpdate = new List<PromoPromoScale__c>();

        PromoScale__c ps;
        Decimal correctTotal;

        for(PromoPromoScale__c pps : promoPromoScales){
            ps = newMap.get(pps.Promo_Scale__c);
            correctTotal = pps.NumberofTickets__c * ps.Price__c;
            if(correctTotal != pps.TicketValue__c){
                pps.TicketValue__c = correctTotal;
                promoPromoScalesToUpdate.add(pps);
            }
        }

        if(!promoPromoScalesToUpdate.isEmpty()){
            update promoPromoScalesToUpdate;
        }

    }
}