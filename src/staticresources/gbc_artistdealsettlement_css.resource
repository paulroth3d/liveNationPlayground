/*
//Filename:grunt_src/lib/common.css
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
.disabled {
	background-color: #BBB;
}

.fe-injected-validation,
.fe-cannot-save {
	border: 2px solid red;
	color: red;
	margin: 8px;
	padding: 8px;
}

.fe-injected-validation .error,
.fe-cannot-save .error {
	color: red;
	margin-left: 16px;
} 

.fe-injected-validation.hide,
.fe-cannot-save.hide {
	display: none;
}

.fe-injected-validation.show,
.fe-cannot-save.show {
	display: block;
}
/*
//Filename:grunt_src/artistdealsettlement.css
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
/*
-- your info goes here:artistdeal
-- to deploy run: grunt deployGridBuddyResource:artistdeal
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

    background: -moz-radial-gradient(center, ellipse cover,  rgba(255,255,255,0) 0%, rgba(255,255,255,0) 85%, #000000 100%);
    background: -webkit-gradient(radial, center center, 0px, center center, 85%, color-stop(0%,rgba(255,255,255,0)), color-stop(100%,rgba(255,255,255,0)), color-stop(100%,#000000));
    background: -webkit-radial-gradient(center, ellipse cover,  rgba(255,255,255,0) 0%,rgba(255,255,255,0) 85%,#000000 100%);
    background: -o-radial-gradient(center, ellipse cover,  rgba(255,255,255,0) 0%,rgba(255,255,255,0) 85%,#000000 100%);
    background: -ms-radial-gradient(center, ellipse cover,  rgba(255,255,255,0) 0%,rgba(255,255,255,0) 85%,#000000 100%);
    background: radial-gradient(ellipse at center, rgba(255,255,255,0) 0%,rgba(255,255,255,0) 85%,#000000 100%);
    background-size: 5px 5px;
}

#gbMainTable > tbody > tr.dr > td[name=v0]{
    text-align:center;
}

#gridFooter{
    z-index:2;
}
