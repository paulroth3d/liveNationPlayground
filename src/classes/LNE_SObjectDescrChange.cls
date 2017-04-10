/**
 *  Class that represents a change between two objects.
 *  <p>Used internally to represent a change between two objects
 *  	and can be subclassed as needed.<p>
 *  <p>Please note, although some of these methods can build off one another.
 *  	These are expanded as far as possible to enhance speed.</p>
 *  @author Paul Roth <proth@salesforce.com>
**/
public abstract class LNE_SObjectDescrChange {
	
	/** old object **/
	public SObject oldObject;
	
	/** new object **/
	public SObject newObject;
	
	public LNE_SObjectDescrChange( SObject oldObject, SObject newObject ){
		this.oldObject = oldObject;
		this.newObject = newObject;
	}
	
	/**
	 *  Determines whether two fields are different.
	 *  @see equals
	 *  @param fieldDescribe (Schema.DescribeFieldResult) - ex: Schema.SObjectType.User.fields.username
	 *  @param ignoreCase (String) - whether to ignore string cases.
	 *  @return Boolean - whether the values are different.
	**/
	public Boolean notEquals( Schema.DescribeFieldResult fieldDescribe, Boolean ignoreCase ){
		Schema.DisplayType fieldType = fieldDescribe.getType();
		String fieldName = fieldDescribe.getName();
		Object oldValue = this.oldObject.get( fieldName );
		Object newValue = this.newObject.get( fieldName );
		//System.debug( 'oldValue[' + oldValue + '] newValue [' + newValue + ']' );
		
		if( fieldType == Schema.DisplayType.String ||
			fieldType == Schema.DisplayType.TextArea ||
			fieldType == Schema.DisplayType.Picklist ||
			fieldType == Schema.DisplayType.MultiPicklist
		){
			return( !areStringsEqual( (String)oldValue, (String)newValue, ignoreCase ));
		} else if( oldValue != newValue ){
			//System.debug( 'values are the same' );
			return( true );
		}
		
		if( fieldType == Schema.DisplayType.String ||
			fieldType == Schema.DisplayType.TextArea ||
			fieldType == Schema.DisplayType.Picklist ||
			fieldType == Schema.DisplayType.MultiPicklist
		){
			return( !areStringsEqual( (String)oldValue, (String)newValue, ignoreCase ));
		} else if( oldValue == newValue ){
			return( false );
		}
		
		return( true );
	}
	public Boolean notEquals( Schema.DescribeFieldResult fieldDescribe ){
		return( notEquals( fieldDescribe, false ));
	}
	
	/**
	 * Determines if two string values are the same
	 * @param str1 (String)
	 * @param str2 (String)
	 * @param isCaseSensitive (Boolean)
	 * @return (Boolean)
	 **/
	public static Boolean areStringsEqual( String oldVal, String newVal, Boolean ignoreCase ){
		//System.debug( 'oldValue[' + oldVal + '] newValue [' + newVal + '] ignorecase:' + ignoreCase );
		if( newVal != null ){
			if( ignoreCase ){
				return( newVal.equalsIgnoreCase( oldVal ) );
			} else {
				return( newVal.equals( oldVal ) );
			}
		} else {
			return( newVal == oldVal );
		}
	}
	
	//-- re implement to avoid multiple stack levels.
	/**
	 *  Determines whether two fields are different.
	 *  @see equals
	 *  @param propName
	 *  @return Boolean - whether the values are different.
	**/
	public Boolean equals( Schema.DescribeFieldResult fieldDescribe, Boolean ignoreCase ){
		Schema.DisplayType fieldType = fieldDescribe.getType();
		String fieldName = fieldDescribe.getName();
		
		Object oldValue = this.oldObject.get( fieldName );
		Object newValue = this.newObject.get( fieldName );
		//System.debug( 'oldValue[' + oldValue + '] newValue [' + newValue + ']' );
		
		if( fieldType == Schema.DisplayType.String ||
			fieldType == Schema.DisplayType.TextArea ||
			fieldType == Schema.DisplayType.Picklist ||
			fieldType == Schema.DisplayType.MultiPicklist
		){
			return( areStringsEqual( (String)oldValue, (String)newValue, ignoreCase ));
		} else if( oldValue == newValue ){
			//System.debug( 'values are the same' );
			return( true );
		}
		
		return( false );
	}
	public Boolean equals( Schema.DescribeFieldResult fieldDescribe ){
		return( equals( fieldDescribe, true ));
	}

}