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
//Filename:grunt_src/components/insertionWidget.css
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
.childData{
    display:block;
}

.cr .crDataContainer.firstChildGrid .branch .childTable{
    display:none;
}

.branch .toggleData{
    display:none;
}

.insertionInputContainer th{
    text-align:center;
}

.insertionInputContainer input{
    width:30px;
    display:block;
}

.outsideRange{
    background:lightgray;
    color:gray;
}

.outsideRange input{
    opacity: 0.5;
    -moz-opacity: 0.5;
    -wekit-opacity: 0.5;
}

/** Remove number spinners **/
input[type=number]::-webkit-inner-spin-button,
input[type=number]::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
}
/*
//Filename:grunt_src/television.css
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
//-- your info goes here:television
//-- to deploy run: grunt deployGridBuddyResource:television
