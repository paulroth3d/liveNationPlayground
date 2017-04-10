/**
 *  Test class for LNE_API_VendorSearch.
 *  (A result class when working with the LiveNation API for searching vendors)
 **/
@IsTest
public class LNE_API_VenueSearchResp_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"meta\": {'+
		'        \"status\": 200,'+
		'        \"message\": \"OK\"'+
		'    },'+
		'    \"pagination\": {'+
		'        \"total\": 1,'+
		'        \"offset\": 0,'+
		'        \"count\": 1'+
		'    },'+
		'    \"data\": ['+
		'        {'+
		'            \"id\": \"ven_14103\",'+
		'            \"name\": \"STAPLES Center\",'+
		'            \"lat\": \"34.043036\",'+
		'            \"lng\": \"-118.267339\",'+
		'            \"homepage\": \"http://staplescenter.com\",'+
		'            \"address\": {'+
		'                \"street\": \"1111 South Figueroa Street\",'+
		'                \"street2\": null,'+
		'                \"city\": \"Los Angeles\",'+
		'                \"state\": \"California\",'+
		'                \"postal_code\": \"90015\",'+
		'                \"country\": \"United States\"'+
		'            },'+
		'            \"phone\": \"2137427326\",'+
		'            \"ticketmaster_ids\": ['+
		'                \"73985\",'+
		'                \"360457\"'+
		'            ],'+
		'            \"box_office\": {'+
		'                \"directions\": \"To purchase Premier Seats for Lakers, Kings or Clippers games click the STAPLES Center TicketExchange logo at the bottom left of this page or go to http://www.staplescenter.com/ticketexchange    \\n   \\nDriving Directions To The STAPLES Center/Nokia Theatre/L.A. LIVE-West Garage:\\n                        \\n101 Fwy southbound from San Fernando/Santa Clarita Valleys to 110 Fwy southbound (Harbor Fwy/San Pedro) from Burband, Glendale, Pasadena\\n\\n* 110 Fwy southbound\\n* exit Olympic Blvd. and turn left at end of ramp\\n* at 11th Street turn left\\n* continue on 11th Street past Cherry Street\\n* turn left into the West Garage\\n\\n10 Fwy westbound from San Bernardino, Riverside, Pomona, Ontario, etc.\\n\\n* 10 Fwy westbound (towards Los Angeles)\\n* 110 Fwy northbound exit then take the Pico Blvd. off ramp\\n* continue north past Pico Blvd. (on Cherry St.) to    11th Street \\n* at 11th Street turn right\\n* turn left into the West Garage\\n\\n 405 Fwy southbound from Thousand Oaks, Simi Valley, etc. to 10 Fwy eastbound from Westside\\n\\n* 10 Fwy eastbound\\n* exit Hoover Street, turn left and continue to Alvarado St\\n* turn right at Pico Blvd.\\n* continue on Pico Blvd. to Cherry Street\\n* turn left into the West Garage\\n\\n405 Fwy northbound from San Diego, Orange County, Anaheim, etc\\n\\n* 405 Fwy norht to 110 Fwy north (Harbor Fwy/Los Angeles)\\n* take 110 Fwy north and transition to the 10 Fwy West\\n* take the Pico Blvd. off ramp\\n* continue north past Pico Blvd. (on Cherry Street) to 11th Street\\n* at 11th Street turn right\\n* turn left into the West Garage.\",'+
		'                \"phone\": \"800-745-3000\",'+
		'                \"phone_info\": \"213-742-7340\\n\",'+
		'                \"general_info\": \"Box office is located on North side of building at 11th and            \\nSouth Figueroa.            \\nBox office hours are 9am to 6pm, Monday through Saturday.            \\nIt is open extended hours on event day.            \\nPhone: 213-742-7340            \\n\\nSUMMER HOURS \\nClosed Saturdays and Sundays unless there is an event, the box office will open at 9am on Saturdays or 10am on Sundays only if there is an event.  The box office will have extended hours on all event days.\\n\\n\",'+
		'                \"will_call_info\": \"STAPLES Center does not accept Will Call drop off.\\n\\nAlternate Will Call Procedure (Alternate Pick Up)\\nIf a person (other than the person ordering and paying for the tickets) is picking up a Will Call order, the Alternate Pick-Up\'s name MUST be on the account. To add the name of an alternate pick-up to the account, the original purchaser must contact Ticketmaster Customer Service at 1-800-745-3000, verify their account information and request the addition an alternate pick-up.\\n\",'+
		'                \"rules\": {'+
		'                    \"child_rules\": \"Some events require all attendees, regardless of age, to present a ticket for entry. Please check the event ticket policies at the time of purchase.\\n\\nChildren age three (3) and above require a ticket for Los Angeles Lakers, Los Angeles Clippers, Los Angeles Kings and Los Angeles Sparks games.\\n\\n\",'+
		'                    \"general_rules\": \"No Bottles, Cans, Or Coolers.            \\nNo Smoking In Arena.            \\nNo Cameras Or Recording Devices At Concerts!            \\nCameras w/No Flash Allowed For Sporting Events Only!            \\n\"'+
		'                }'+
		'            },'+
		'            \"vdp_img_url\": null,'+
		'            \"time_zone\": \"America/Los_Angeles\",'+
		'            \"time_zone_abbr\": \"PST\",'+
		'            \"url_slug\": \"staples-center\",'+
		'            \"owned_by_ln\": false,'+
		'            \"websites\": ['+
		'            ],'+
		'            \"terrapass\": false'+
		'        }'+
		'    ]'+
		'}';
		LNE_API_VenueSearchResp obj = LNE_API_VenueSearchResp.parse(json);
		System.assert(obj != null);
	}
}