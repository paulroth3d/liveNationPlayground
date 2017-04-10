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
//Filename:grunt_src/Digital_US513.css
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
//-- your info goes here:Digital_US513
//-- to deploy run: grunt deployGridBuddyResource:Digital_US513

/** Remove number spinners **/
input[type=number]::-webkit-inner-spin-button, 
input[type=number]::-webkit-outer-spin-button { 
  -webkit-appearance: none; 
  margin: 0; 
}