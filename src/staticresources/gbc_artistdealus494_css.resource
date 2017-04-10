/*
//Filename:grunt_src/lib/common.css
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
.disabled {
	background-color: #BBB;
}
/*
//Filename:grunt_src/artistdealus494.css
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
/*
//-- your info goes here:artistdealus494
//-- to deploy run: grunt deployGridBuddyResource:artistdealus494
*/
#gbMainTable > tbody > tr.dr > [name=v0]{
    position:relative;
}

.handle{
    z-index:2;
    position:absolute;
    background-color:rgba(255, 255, 255, 0);
    top:0;
    left:0;
    width:100%;
    height: 100%;
    cursor:move;
}

#gbMainTable > tbody > tr.co-headliner > td[name=v0] input,
#gbMainTable > tbody > tr.support > td[name=v0] input{
    position:relative;
    z-index:1;
}

#gbMainTable > tbody > tr.co-headliner > td[name=v0],
#gbMainTable > tbody > tr.support > td[name=v0]{

    background: -moz-radial-gradient(center, ellipse cover,  rgba(255,255,255,0) 0%, rgba(255,255,255,0) 79%, #000000 85%);
    background: -webkit-gradient(radial, center center, 0px, center center, 85%, color-stop(0%,rgba(255,255,255,0)), color-stop(79%,rgba(255,255,255,0)), color-stop(85%,#000000));
    background: -webkit-radial-gradient(center, ellipse cover,  rgba(255,255,255,0) 0%,rgba(255,255,255,0) 79%,#000000 85%);
    background: -o-radial-gradient(center, ellipse cover,  rgba(255,255,255,0) 0%,rgba(255,255,255,0) 79%,#000000 85%);
    background: -ms-radial-gradient(center, ellipse cover,  rgba(255,255,255,0) 0%,rgba(255,255,255,0) 79%,#000000 85%);

    background: radial-gradient(ellipse at center, rgba(255,255,255,0) 0%,rgba(255,255,255,0) 79%,#000000 85%);
    background-size: 5px 5px;
}

#gbMainTable > tbody > tr.dr > td[name=v0]{
    text-align:center;
}