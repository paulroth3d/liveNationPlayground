/** 
 *  Utility class to work with local date/time of the user
 *  @author Daniel Nakonieczny <dnakonieczny@salesforce.com>
 **/
public class LNE_DateTimeUtility {
	private static final String DATETIME_FORMAT = 'yyyy.MM.dd HH:mm:ss z'; //2017.01.11 16:00:00 CST

	public static String getCurrentUserDateTimeString() {
		return System.now().format(DATETIME_FORMAT);
	}

	public static String getCurrentUserFullName() {
		return UserInfo.getLastName() + ', ' + UserInfo.getFirstName(); //Smith, John
	}

	public static String getCurrentTimestampString() {
		return getCurrentUserFullName() + ' at ' + getCurrentUserDateTimeString(); //Smith, John at 2017.01.11 16:00:00 CST
	}
}