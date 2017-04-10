/**
 *  Implementation of the trigger that keeps the name of the DMA record
 *  in sync with the value and postal code.
 *  @author Paul Roth <proth@salesforce.com>
 **/
public with sharing class LNE_DMA_NameDefinition_T {
    
    /**
     *  Defines the name of the DMA based on the Zip Code and the DMA value.
     *  <p>Assumes Before Update / Before Insert</p>
     *  @param DMA__c[] newRecords
     *  @param Map<Id,DMA__c> oldMap
     *  @return DMA__c[] - list of DMA Records updated.
     **/
    public static DMA__c[] execute( DMA__c[] newList, Map<Id,DMA__c> oldMap ){
        DMA__c[] results = new DMA__c[]{};
        
        if( newList == null ){
            return( results );
        }
        
        String delimiter = DataGenerationSettings__c.getInstance().CombinedKeyDelimiter__c;
        
        //DMA__c dma = null;
        DMA__c oldDMA = null;
        
        
        if( oldMap == null ){
            //System.debug( "Before Insert mode" );
            for( DMA__c dma : newList ){
                results.add( dma );
            }
        } else {
            //System.debug( "Before Update Mode" );
            for( DMA__c dma : newList ){
                if( oldMap.containsKey( dma.Id ) ){
                    oldDMA = oldMap.get( dma.Id );
                    
                    //-- if they are different
                    if( !dma.DMA__c.equals( oldDMA.DMA__c ) ||
                        !dma.PostalCode__c.equals( oldDMA.PostalCode__c )
                    ){
                        results.add( dma );
                    }
                }
            }
        }
        
        //-- update the name
        for( DMA__c dma : results ){
            dma.Name = dma.DMA__c + delimiter + dma.PostalCode__c;
        }
        
        return( results );
    }
}