/**
 *  Class that represents a change between two objects.
 *  <p>Used internally to represent a change between two objects
 *  	and can be subclassed as needed.<p>
 *  <p>Please note, although some of these methods can build off one another.
 *  	These are expanded as far as possible to enhance speed.</p>
 *  @author Paul Roth <proth@salesforce.com>
**/
public abstract class LNE_SObjectChange {
	
	/** old object **/
	public SObject oldObject;
	
	/** new object **/
	public SObject newObject;
	
	public LNE_SObjectChange( SObject oldObject, SObject newObject ){
		this.oldObject = oldObject;
		this.newObject = newObject;
	}
	
	/**
	 *  Determines whether two fields are different.
	 *  <p>Please note, if it is a string, then use notEqualsStr</p>
	 *  @param propName
	 *  @return Boolean - whether the values are different.
	**/
	public Boolean notEquals( String propName ){
		return( this.oldObject.get( propName ) != this.newObject.get( propName ) );
	}
	
	/**
	 *  Determines whether two fields are the same.
	 *  <p>Please note, if it is a string, then use equalsStr</p>
	 *  @param propName
	 *  @return Boolean - whether the values are the same.
	**/
	public Boolean equals( String propName ){
		return( this.oldObject.get( propName ) == this.newObject.get( propName ) );
	}
	
	/**
	 *  Determines whether two strings are different
	 *  @param propName (String) - the name of the prop off the objects to compare
	 *  @param ignoreCase (Boolean) - whether to ignore case
	 *  @return Boolean - whether the strings are different.
	**/
	public Boolean notEqualsStr( String propName, boolean ignoreCase ){
		String oldVal = (String)this.oldObject.get( propName );
		String newVal = (String)this.newObject.get( propName );
		
		if( newVal != null ){
			if( ignoreCase ){
				return( !newVal.equalsIgnoreCase( oldVal ) );
			} else {
				return( !newVal.equals( oldVal ) );
			}
		} else {
			return( newVal != oldVal );
		}
	}
	
	/**
	 *  Determines whether two strings are the same
	 *  @param propName (String) - the name of the prop off the objects to compare
	 *  @param ignoreCase (Boolean) - whether to ignore case
	 *  @return Boolean - whether the strings are different.
	**/
	public Boolean equalsStr( String propName, boolean ignoreCase ){
		String oldVal = (String)this.oldObject.get( propName );
		String newVal = (String)this.newObject.get( propName );
		
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
	
}