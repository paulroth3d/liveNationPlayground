/**
 *  Class to automatically default any null value decimal fields to a default value
 *  @author Scott Will
 **/
 public with sharing class LNE_SObjectFieldDefaulter {

	final static Decimal DEFAULT_DECIMAL_VALUE = 0.0;

	// for any object.field that needs a default other than DEFAULT_DECIMAL_VALUE
	// formatting must be: NormalCaseOnObject__c.lowercaseonfield__c
	final static Map<String,Decimal> specialDefaults = new Map<String,Decimal> {
		'Deal__c.splitbackendpercent__c' => 1,
		'LedgerEntry__c.artistmax__c' => null,
		'LedgerEntry__c.artistmin__c' => null,
		'LedgerEntry__c.contraamount__c' => null,
		'LedgerEntry__c.inhousemax__c' => null,
		'LedgerEntry__c.inhousemin__c' => null,
		'LedgerEntry__c.lntouringmax__c' => null,
		'LedgerEntry__c.lntouringmin__c' => null,
		'LedgerEntry__c.max__c' => null,
		'LedgerEntry__c.min__c' => null,
		'LedgerEntry__c.offermax__c' => null,
		'LedgerEntry__c.offermin__c' => null,
		'LedgerEntry__c.promotermax__c' => null,
		'LedgerEntry__c.promotermin__c' => null,
		'LedgerEntry__c.venuemax__c' => null,
		'LedgerEntry__c.venuemin__c' => null,
		'LedgerEntryBreakout__c.contraamount__c' => null
	};

	// used for caching
	final static Map<String,Set<String>> objDecimalFields = new Map<String,Set<String>>();
	
	/**
	*  Defaults all null-value Decimal fields on the object.
	*  <p>If the object was construsted in memory, then every Decimal field on the record will be defaulted</p>
	*  <p>If the object was queried for, then only those fields in the query that are nulled Decimal fields will be updated.</p>
	*  @param obj SObject
	*  @return void
	**/
	public static void defaultDecimalFields(SObject obj) {

		// get object type
		Schema.DescribeSObjectResult objTypeDesc = obj.getSObjectType().getDescribe();
		// keep track of what fields to default
		Map<String,Decimal> defaultedFields = new Map<String,Decimal>();

		// for each decimal field on the object type
		for (String fnom : getDecimalFields(objTypeDesc)) {
			try {
				// get field value
				Object fval = obj.get(fnom);
				// if null default it
				if (fval == null) {
					// get object.field notation
					String objectDotField = objTypeDesc.getName() + '.' + fnom;
					// get special default value if it exists
					Decimal defVal = specialDefaults.containsKey(objectDotField)
						? specialDefaults.get(objectDotField)
						: DEFAULT_DECIMAL_VALUE;
					// store it
					defaultedFields.put(fnom, defVal);
				}
			} 
			catch (System.SObjectException se) {
				// field wasnt queried, do nothing
			}
		}

		// needed to make putting the value a separate action from the get.  for whatever reason if they are together
		// in the try/catch above then all fields will get defaulted even if not queried for, which would cause 
		// non-queried fields to get defaulted and worse yet possibly saved, thereby overriding the original non-queried value
		if (!defaultedFields.isEmpty()) {
			for (String fnom : defaultedFields.keySet()) {
				obj.put(fnom, defaultedFields.get(fnom));
			}
		}

	}

	
	private static Set<String> getDecimalFields(Schema.DescribeSObjectResult objTypeDesc) {

		String objName = objTypeDesc.getName();
		if (!objDecimalFields.containsKey(objName)) {
			// loop over fields and build set of updateable decimal fields
			Map<String, Schema.SObjectField> fieldMap = objTypeDesc.fields.getMap();
			Set<String> decimalFields = new Set<String>();
			for (String fnom : fieldMap.keySet()) {

				Schema.SObjectField objField = fieldMap.get(fnom);
				Schema.DescribeFieldResult dfr = objField.getDescribe();
				if (dfr.getSoapType() == Schema.SOAPType.Double && dfr.isUpdateable()) {
					decimalFields.add(fnom);
				}
			}
			// cache all of this so it only has to be done once per object per transaction
			objDecimalFields.put(objName, decimalFields);
		}

		return objDecimalFields.get(objName);

	}

}