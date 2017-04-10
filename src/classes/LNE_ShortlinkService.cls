/**
 *  Service Utility to short link urls.
 *
 *  @author Scott Will/Paul Roth
 **/
public with sharing class LNE_ShortlinkService {

	final static API_Settings__c apiSettings;

	static {
		apiSettings = API_Settings__c.getInstance();
		System.assertNotEquals(null, apiSettings.BitlyEndpointTemplate__c, 'API Settings.Bitly Endpoint Template is missing a value');
		System.assertNotEquals(null, apiSettings.BitlyKey__c, 'API Settings.Bitly Key is missing a value');
		System.assertNotEquals(null, apiSettings.BitlyUsername__c, 'API Settings.Bitly Username is missing a value');
	}

	/**
	 * For the given longUrl, calls the Bitly service and returns the shortened version of that url
	 * @param longUrl String - the long form URL to shorten
	 * @return BitlyResult - wrapper containing the shortened version of the URL
	**/
	public static BitlyResult shortenUrl(String longUrl) {

		HttpRequest request = createRequest(longUrl);
		HttpResponse response = new Http().send(request);
		BitlyResult result = parseResponse(response);

		return result;

	}

	private static HttpRequest createRequest(String longUrl) {

		// generate endpoint url
		String encodedUrl = EncodingUtil.urlEncode(longUrl, 'UTF-8');
		String endpoint = String.format(apiSettings.BitlyEndpointTemplate__c, new List<String> {
			apiSettings.BitlyUsername__c,
			apiSettings.BitlyKey__c,
			encodedUrl
		});

		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod('GET');

		return request;

	}

	private static BitlyResult parseResponse(HttpResponse response) {

		BitlyResult result = new BitlyResult();
		JSONParser parser = JSON.createParser(response.getBody());

		while (parser.nextToken() != null) {
		    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
		        String tokenName = parser.getText();
		        parser.nextToken();
				if (tokenName == 'errorCode') {
		        	result.errorCode = parser.getIntegerValue();
		        }
		        else if (tokenName == 'errorMessage') {
		        	result.errorMessage = parser.getText();
		        }
		        else if (tokenName == 'shortUrl') {
		        	result.shortenedUrl = parser.getText();
		        }
		    }
		}

		return result;

	}

	public class BitlyResult {

		public Integer errorCode {get;set;}
		public String errorMessage {get;set;}
		public String shortenedUrl {get;set;}

	}

}