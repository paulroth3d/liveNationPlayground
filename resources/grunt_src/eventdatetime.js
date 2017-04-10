/**
 *  logic collapses the manual ticket counts
 *  <p>Called on document.ready</p>
 **/

function collapseManualTicketCount() {

    var rows = jq("#gbMainTable").find(".dr");
    for (var i = 0; i < rows.length; i++) {
        var div = rows[i].closest("div");
        var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[
                i]).attr("name") + "].cr")[1];
    	jq(childrenRow).css("display", "table-row");
        console.log(jq(childrenRow).find("h3.toggleData"));
        jq(jq(childrenRow).find("h3.toggleData")[0]).attr("class",
                "toggleData collapsed");
       	jq(jq(childrenRow).find("h3.toggleData")[1]).attr("class",
                "toggleData fixed none collapsed");
        jq(childrenRow).find(".childData").attr("class",
                "childData");
       	jq(childrenRow).find(".childData").css("display", "none");

    }


}


jq(document).ready(function() {
    var initialFocus = true;
   
   	collapseManualTicketCount();
	gridStateMessagingController();
});