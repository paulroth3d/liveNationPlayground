/**
 *  Simple controller extension for the standard Event Standard Controller.
 *  <p>Simply performs the save, but returns true or false instead of redirecting the user.</p>
 *  <p>Redirecting the user fails in lightning experience + locker service, because
 *  it uses the wrong domain, instead of remaining in the same domain</p>
 *  @author Paul Roth <proth@salesforce.com
 **/
public class LNE_EventStandardController_CX {

	/** standard controller **/
	public ApexPages.StandardController std { get; private set; }
	
	/** whether the page should refresh **/
	public Boolean shouldPageRefresh { get; private set; }
	
	public LNE_EventStandardController_CX( ApexPages.StandardController std ){
		this.std = std;
		this.shouldPageRefresh = false;
	}
	
	public ApexPages.PageReference reloadRecord(){
		this.std.getRecord();
		return( null );
	}
	
	public void customSave(){
		this.std.save();
		
		this.shouldPageRefresh = true;
		
		/*
		//-- @TODO: review later why this doesn't work
		System.PageReference result = new System.PageReference( ApexPages.currentPage().getURL() );
		result.setRedirect(false);
		return( result );
		*/
	}
}