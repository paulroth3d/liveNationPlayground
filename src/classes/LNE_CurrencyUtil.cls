/**
 *  Class to statically manage currency.
 *  @author Paul Roth <proth@salesforce.com>
 **/
public class LNE_CurrencyUtil {

	/**
	 *  Singleton map of all conversion rates - indexed by IsoCode (string).
	 **/
	private static Map<String,CurrencyType> CURRENCY_BY_ISO;
	
	/**
	 * Singleton corporate currency type.
	 * (used in cache to avoid additional log requests)
	 **/
	private static CurrencyType CORPORATE_TYPE;
	
	//-- getters/setters
	/**
	 *  Returns the map of all the conversion rates available by their isoCode.
	 **/
	public static Map<String,CurrencyType> getIsoMap(){
		refreshConversionRates( false );
		return( CURRENCY_BY_ISO.clone() );
	}
	
	/**
	 *  Returns the corporate conversion type.
	 **/
	public static CurrencyType getCorporateType(){
		refreshConversionRates( false );
		return( CORPORATE_TYPE.clone() );
	}
	
	/**
	 * Refreshes the map of conversion rates.
	 * Automatically called by any utility method, but helpful if conversion rates
	 * are adjusted within unit tests.
	 * @invariant - RATE_BY_ISO has all conversionRates indexed by IsoCode.
	 **/
	public static void refreshConversionRates(){
		refreshConversionRates( true );
	}
	
	/**
	 * Actually refreshes the map
	 * @param force (Boolean) - whether to force a refresh
	 **/
	private static void refreshConversionRates( Boolean force ){
		if( CURRENCY_BY_ISO == null || force == true ){
			CURRENCY_BY_ISO = new Map<String,CurrencyType>();
			CORPORATE_TYPE = null;
			
			for( CurrencyType rate : [ 
				SELECT IsoCode, ConversionRate, IsCorporate
				FROM CurrencyType
				WHERE IsActive = TRUE
			]){
				CURRENCY_BY_ISO.put( rate.IsoCode, rate );
				if( rate.IsCorporate ){
					CORPORATE_TYPE = rate;
				}
			}
			
			System.assert( CORPORATE_TYPE != null, 'At least one of the CurrencyTypes must be marked as corporate' );
		}
	}
	
	/**
	 *  Converts a value from the corporate ISO type to a currency type (i.e. USD amt to CAD)
	 *  <p>Assumption is that the conversion rate ALWAYS converts to the corporate rate amount</p>
	 *  @param fromAmount (Decimal)
	 *  @param toIsoCode (String)
	 *  @return (Decimal) - the amount in the target isoCode.
	 *  @see CORPORATE_TYPE - if that needs to be described anywhere.
	 **/
	public static Decimal convertFromCorpCurrency( Decimal fromAmount, String toIsoCode ){
		if( CORPORATE_TYPE == null ){
			refreshConversionRates();
		}
		return( convertToFromIso( fromAmount, CORPORATE_TYPE.IsoCode, toIsoCode ));
	}
	
	/**
	 * Converts a value from a currency type to the corporate ISO type (i.e. CAD to USD)
	 * @see convertToCorpCurrency
	 * @param fromAmount (Decimal)
	 * @param fromIsoCode (String)
	 * @return (Decimal) - the amount converted from the isoCode to corporate amounts.
	 **/
	public static Decimal convertToCorpCurrency( Decimal fromAmount, String fromIsoCode ){
		if( CORPORATE_TYPE == null ){
			refreshConversionRates();
		}
		return( convertToFromIso( fromAmount, fromIsoCode, CORPORATE_TYPE.IsoCode ));
	}
	
	/**
	 * Converts a value from a currency.
	 * @param fromValue (Decimal)
	 * @param fromIsoCode (String) - iso code to use or null if assumed corporate
	 * @param toIsoCode (String) - iso code to convert to or null if assumed corporate
	 * @return (Decimal) - the amount converted from the isoCode to isoCode
	 **/
	public static Decimal convertToFromIso( Decimal fromValue, String fromIsoCode, String toIsoCode ){
		if( CORPORATE_TYPE == null ){
			refreshConversionRates();
		}
		System.assert( CORPORATE_TYPE != null, 'Corporate type must be found after refreshing conversion rates' );
		
		Decimal result = fromValue;
		Decimal fromRate = 1;
		Decimal toRate = 1;
		
		if( fromIsoCode != null && !CORPORATE_TYPE.IsoCode.equals( fromIsoCode )){
			//-- avoid assert and contains for speed for now.
			//System.assert( CURRENCY_BY_ISO.containsKey( fromIsoCode ), 'IsoCode to convert from not found:' + fromIsoCode );
			fromRate = CURRENCY_BY_ISO.get( fromIsoCode ).ConversionRate;
			
			result = fromValue / fromRate;
		} else {
			result = fromValue;
		}
		
		if( toIsoCode != null && !CORPORATE_TYPE.IsoCode.equals( toIsoCode )){
			toRate = CURRENCY_BY_ISO.get( toIsoCode ).ConversionRate;
			
			result *= toRate;
		} else {
			//-- result is already in the corporate rate.
		}
		
		return( result );
	}
	
	/**
	 * Converts from a custom currency exchange rate
	 * @param fromValue (Decimal)
	 * @param customRate (Decimal)
	 * @return (Decimal)
	 **/
	public static Decimal convertFromCustomRate( Decimal fromValue, Decimal customRate ){
		//-- Placeholder
		return( fromValue / customRate );
	}
	
	/**
	 * converts to a value using a custom exchange rate.
	 * @param fromValue (Decimal)
	 * @param customRate (Decimal)
	 * @return (Decimal)
	 **/
	public static Decimal convertToCustomRate( Decimal fromValue, Decimal customRate ){
		//-- Placeholder
		return( fromValue * customRate );
	}
}