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
private class LNE_CurrencyUtil_Test {
	
	public static final String TYPE_USD = 'USD';
	public static final String TYPE_CAD = 'CAD';
	
    @testSetup
    static void setup(){
        //LNE_TestObjectFactory.prepStandardCustomSettings();
    	//LNE_TestObjectFactory.createStandardDataSet();
    }

    class TestSettings {
        
        //-- under ideal situations, there would be means to update currencyTypes or to add in new ones
        //-- however currencyTypes are one of the few types that cannot be updated through Apex/DML
        //-- so we ensure that there must be at least the two types of currencies required for the test to proceed.
        
        Map<String, CurrencyType> currencyTypeMap;
        
        CurrencyType corporateType;
        
        Decimal EPSILON = 0.00000000001;
        
        public Boolean testFloatEquals( Decimal amount1, Decimal amount2 ){
        	return( (amount1 + EPSILON) > amount2 && (amount1 - EPSILON) < amount2 );
        }
        
        public TestSettings() {
			//-- global setup here
            //-- currencyTypes cannot be created within apex, so it cannot occur here.
            
            currencyTypeMap = LNE_CurrencyUtil.getIsoMap();
            corporateType = LNE_CurrencyUtil.getCorporateType();
        }
        
        public void typicalSetup(){
			
        }
		
		public void finalize(){
			
		}
    }
    
	
    //-- test test methods here
	
	static testMethod void runSetupAWithoutException() {
        TestSettings ts = new TestSettings();
    	ts.typicalSetup();
    	ts.finalize();
        System.assert( true, 'No Exceptions have occurred in getting here' );
        
        //-- at the time of this writing, you cannot modify Currency Types within DML/Apex.
        System.assert( ts.currencyTypeMap.containsKey( TYPE_CAD ), 'The test uses CAD. CAD must be defined within Setup > Manage Currencies to contine' );
        System.assert( ts.currencyTypeMap.containsKey( TYPE_USD ), 'The test uses USD. USD must be defined within Setup > Manage Currencies to continue' );
        
        System.assert( ts.corporateType != null, 'There MUST be at least one currency type marked as corporate' );
        
        //-- for the current test, assume that the current type is USD.
        //-- if this assumption changes, it really is no biggie, but change the amounts below;
	}
	

   	//-- test functionality here
	
    static testMethod void testConvertFromCAD() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        
        //-- for now assume that the 
        Decimal canadianConversionRate = ts.currencyTypeMap.get( TYPE_CAD ).ConversionRate;
        Decimal amountInCAD = 131;
        Decimal expAmountInUSD = amountInCAD / canadianConversionRate;
        Decimal actualAmountInUSD = LNE_CurrencyUtil.convertToCorpCurrency( amountInCAD, TYPE_CAD );
        
        System.assert( ts.testFloatEquals( actualAmountInUSD, expAmountInUSD ), 'Converting ' + amountInCAD + ' from CAD to USD should be:' + expAmountInUSD + ' but was:' + actualAmountInUSD );
    }
    
    
    static testMethod void testConvertToCAD() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        
        //-- for now assume that the 
        Decimal canadianConversionRate = ts.currencyTypeMap.get( TYPE_CAD ).ConversionRate;
        Decimal amountInUSD = 100;
        Decimal expAmountInCAD = amountInUSD * canadianConversionRate;
        Decimal actualAmountInCAD = LNE_CurrencyUtil.convertFromCorpCurrency( amountInUSD, TYPE_CAD );
        
        System.assert( ts.testFloatEquals( actualAmountInCAD, expAmountInCAD ), 'Converting ' + amountInUSD + ' from USD to CAD should be:' + expAmountInCAD + ' but was:' + actualAmountInCAD );
    }
    
    static testMethod void testConvertToFrom() {
        TestSettings ts = new TestSettings();
        ts.typicalSetup();
        ts.finalize();
        
        //-- for now assume that the 
        Decimal canadianConversionRate = ts.currencyTypeMap.get( TYPE_CAD ).ConversionRate;
        Decimal usdConversionRate = ts.currencyTypeMap.get( TYPE_USD ).ConversionRate;
        
        Decimal amountInCAD = 131;
        Decimal expAmountInUSD = ( amountInCAD / canadianConversionRate ) * usdConversionRate;
        Decimal actualAmountInUSD = LNE_CurrencyUtil.convertToFromIso( amountInCAD, TYPE_CAD, TYPE_USD );
        
        System.assert( ts.testFloatEquals( actualAmountInUSD, expAmountInUSD ), 'Converting ' + amountInCAD + ' from CAD to USD should be:' + expAmountInUSD + ' but was:' + actualAmountInUSD );
        
        Decimal amountInUSD = 100;
        Decimal expAmountInCAD = amountInUSD * canadianConversionRate;
        Decimal actualAmountInCAD = LNE_CurrencyUtil.convertToFromIso( amountInUSD, TYPE_USD, TYPE_CAD );
        System.assert( ts.testFloatEquals( actualAmountInCAD, expAmountInCAD ), 'Converting ' + amountInUSD + ' from USD to CAD should be:' + expAmountInCAD + ' but was:' + actualAmountInCAD );
    }

}