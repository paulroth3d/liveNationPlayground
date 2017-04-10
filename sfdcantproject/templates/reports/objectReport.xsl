<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sfdc="http://soap.sforce.com/2006/04/metadata"
	exclude-result-prefixes="sfdc"
>
<xsl:output method="html" 
			  omit-xml-declaration="yes"
              encoding="UTF-8"
              indent="yes" />
<xsl:template match="/">
<html class="no-js" lang="en">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
	<title>{{ObjectName}}</title>
	<link rel="stylesheet" href="../_src/css/foundation.css" />
	<link rel="stylesheet" href="../_src/css/responsive-tables.css" />
	<link rel="stylesheet" href="../_src/css/main.css" />
	<script src="../_src/js/vendor/modernizr.js"></script>
</head>
<body id='rep_Object'>
	<a name="top"></a>
		
	<!-- <section role="main"> -->
	<div class="row">
		<div class="medium-12 columns" style='position:relative'>
				
			<div class="off-canvas-wrap">
			<div class="inner-wrap">
				<div class="contain-to-grid">
				<nav class="top-bar" data-topbar="">
					<ul class="title-area">
						<li class="name">
							<h1><a href='#'>Object Report</a></h1>
						</li>
						<li class="toggle-topbar menu-icon"><a href=""><span>Menu</span></a></li>
					</ul>
					
					<section class="top-bar-section">
						<ul class="left">
							<a class="left-off-canvas-toggle menu-icon" ><span></span></a>
						</ul>
						
						<ul class="right">
							<li class=""><a href="../index.html">Home</a></li>
							<li class="has-dropdown">
								<a href="#">Reports</a>
								<ul class="dropdown">
									<StartGlobalNav></StartGlobalNav>
									<EndGlobalNav></EndGlobalNav>
								</ul>
							</li>
							<li class="has-dropdown">
								<a href="#">Sections</a>
								<ul class="dropdown">
									<li><a href="#general">General</a></li>
									<xsl:if test="sfdc:CustomObject/sfdc:recordTypes">
										<li><a href="#recordTypes">RecordTypes</a></li>
									</xsl:if>
									<xsl:if test="sfdc:CustomObject/sfdc:fields[sfdc:type='Lookup'] or sfdc:CustomObject/sfdc:fields[sfdc:type='MasterDetail']">
										<li><a href="#relationships">Relationships</a></li>
									</xsl:if>
									<li><a href="#fields">Fields</a></li>
									<xsl:if test="sfdc:CustomObject/sfdc:fieldSets">
										<li><a href="#fieldSets">FieldSets</a></li>
									</xsl:if>
									<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active='true']">
										<li><a href="#validActive">Active Validation</a></li>
									</xsl:if>
									<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active!='true']">
										<li><a href="#validInactive">Inactive Validation</a></li>
									</xsl:if>
								</ul>
							</li>
						</ul>
					</section>
				</nav>
				</div>
			
				<aside class="left-off-canvas-menu">
					<ul class='off-canvas-list'>
						{{indexStr}}
					</ul>
				</aside>
				
				<!--
				<aside class="right-off-canvas-menu">
					<ul class="off-canvas-list">
						<li><a href="#general">General</a></li>
						<xsl:if test="sfdc:CustomObject/sfdc:recordTypes">
							<li><a href="javascript:redirectToSelf('#recordTypes');" class="exit-off-canvas-link">RecordTypes</a></li>
						</xsl:if>
						<xsl:if test="sfdc:CustomObject/sfdc:fields[sfdc:type='Lookup'] or sfdc:CustomObject/sfdc:fields[sfdc:type='MasterDetail']">
							<li><a href="javascript:redirectToSelf('#relationships')" class="exit-off-canvas-link">Relationships</a></li>
						</xsl:if>
						<li><a href="javascript:redirectToSelf('#fields')" class="exit-off-canvas-link">Fields</a></li>
						<xsl:if test="sfdc:CustomObject/sfdc:fieldSets">
							<li><a href="javascript:redirectToSelf('#fieldSets')" class="exit-off-canvas-link">FieldSets</a></li>
						</xsl:if>
						<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active='true']">
							<li><a href="javascript:redirectToSelf('#validActive')" class="exit-off-canvas-link">Active Validation</a></li>
						</xsl:if>
						<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active!='true']">
							<li><a href="javascript:redirectToSelf('#validInactive')" class="exit-off-canvas-link">Inactive Validation</a></li>
						</xsl:if>
					</ul>
				</aside>
				-->
				
				<div data-magellan-expedition="fixed">
					<ul class="sub-nav">
						<li data-magellan-arrival="top"><a href="#top">Top</a></li>
						<li data-magellan-arrival="general"><a href="#general">General</a></li>
						<xsl:if test="sfdc:CustomObject/sfdc:recordTypes">
							<li data-magellan-arrival="recordTypes"><a href="#recordTypes" class="exit-off-canvas-link">RecordTypes</a></li>
						</xsl:if>
						<xsl:if test="sfdc:CustomObject/sfdc:fields[sfdc:type='Lookup'] or sfdc:CustomObject/sfdc:fields[sfdc:type='MasterDetail']">
							<li data-magellan-arrival="relationships"><a href="#relationships" class="exit-off-canvas-link">Relationships</a></li>
						</xsl:if>
						<li data-magellan-arrival="fields"><a href="#fields" class="exit-off-canvas-link">Fields</a></li>
						<xsl:if test="sfdc:CustomObject/sfdc:fieldSets">
							<li data-magellan-arrival="fieldSets"><a href="#fieldSets" class="exit-off-canvas-link">FieldSets</a></li>
						</xsl:if>
						<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active='true']">
							<li data-magellan-arrival="validActive"><a href="#validActive" class="exit-off-canvas-link">Active Validation</a></li>
						</xsl:if>
						<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active!='true']">
							<li data-magellan-arrival="validInactive"><a href="#validInactive" class="exit-off-canvas-link">Inactive Validation</a></li>
						</xsl:if>
					</ul>
				</div>
				
				<!--
				<div class="contain-to-grid">
					<div data-magellan-expedition="fixed">
						<dl class="sub-nav">
							<dd data-magellan-arrival="general"><a href="#general">General</a></dd>
							<xsl:if test="sfdc:CustomObject/sfdc:recordTypes">
								<dd data-magellan-arrival="recordTypes"><a href="#recordTypes">RecordTypes</a></dd>
							</xsl:if>
							<xsl:if test="sfdc:CustomObject/sfdc:fields[sfdc:type='Lookup'] or sfdc:CustomObject/sfdc:fields[sfdc:type='MasterDetail']">
								<dd data-magellan-arrival="relationships"><a href="#relationships">Relationships</a></dd>
							</xsl:if>
							<dd data-magellan-arrival="fields"><a href="#fields">Fields</a></dd>
							<xsl:if test="sfdc:CustomObject/sfdc:fieldSets">
								<dd data-magellan-arrival="fieldSets"><a href="#fieldSets">FieldSets</a></dd>
							</xsl:if>
							<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active='true']">
								<dd data-magellan-arrival="validActive"><a href="#validActive">Active Validation</a></dd>
							</xsl:if>
							<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active!='true']">
								<dd data-magellan-arrival="validInactive"><a href="#validInactive">Inactive Validation</a></dd>
							</xsl:if>
						</dl>
					</div>
				</div>
				-->
				
				<h1 id="top" data-magellan-destination="recordTypes">{{ObjectName}}<xsl:if test="sfdc:CustomObject/sfdc:label"> (<xsl:value-of select='sfdc:CustomObject/sfdc:label' />)</xsl:if></h1>
				<p><xsl:value-of select='sfdc:CustomObject/sfdc:description' /></p>
				
				<a name="general"></a>
				<h3 data-magellan-destination="general">General</h3>
				<table class='general'>
					<tr><th>Type</th><th>Is Enabled</th></tr>
					<tr><td>Activities</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableActivities' /></td></tr>
					<tr><td>Enhanced Lookup</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableEnhancedLookup' /></td></tr>
					<tr><td>enableFeeds</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableFeeds' /></td></tr>
					<tr><td>enableHistory</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableHistory' /></td></tr>
					<tr><td>enableReports</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableReports' /></td></tr>
				</table>
				
				<xsl:if test="sfdc:CustomObject/sfdc:recordTypes">
				<a name="recordTypes"></a>
				<hr />
				<h3 data-magellan-destination="recordTypes">Record Types</h3>
				<ul>
				<xsl:for-each select='sfdc:CustomObject/sfdc:recordTypes'>
					<li><h4 class='fullName' style='display:inline'><xsl:value-of select='sfdc:fullName' />
					<xsl:choose>
						<xsl:when test='sfdc:active!="true"'>
							: In-Active
						</xsl:when>
					</xsl:choose>
					</h4>
					<xsl:if test="sfdc:description"><pre><xsl:value-of select='sfdc:description' /></pre></xsl:if>
					</li>
				</xsl:for-each>
				</ul>
				</xsl:if>
				
				<xsl:if test="sfdc:CustomObject/sfdc:fields[sfdc:type='Lookup'] or sfdc:CustomObject/sfdc:fields[sfdc:type='MasterDetail']">
				<a name="relationships"></a>
				<hr />
				<h3 data-magellan-destination="relationships">Relationships</h3>
				<table class="responsive">
					<tr>
						<th>Type</th>
						<th>Label</th>
						<th>API</th>
						<th>Reference To</th>
						<!--<th>Relationship Label</th>-->
						<th>Relationship Name</th>
						<th>Required</th>
					</tr>
					<xsl:for-each select="sfdc:CustomObject/sfdc:fields[sfdc:type='Lookup']">
						<xsl:sort select="sfdc:fullName" />
						<tr>
							<td>Lookup</td>
							<td><xsl:value-of select='sfdc:label' /></td>
							<td><xsl:value-of select='sfdc:fullName' /></td>
							<td><a><xsl:attribute name="href"><xsl:value-of select='concat( sfdc:referenceTo, ".html" )' /></xsl:attribute><xsl:value-of select='sfdc:referenceTo' /></a></td>
							<!--<td><xsl:value-of select='sfdc:relationshipLabel' /></td>-->
							<td><xsl:value-of select='sfdc:relationshipName' /></td>
							<td><xsl:value-of select='sfdc:required' /></td>
						</tr>
					</xsl:for-each>
					<xsl:for-each select="sfdc:CustomObject/sfdc:fields[sfdc:type='MasterDetail']">
						<xsl:sort select="sfdc:fullName" />
						<tr>
							<td>MasterDetail</td>
							<td><xsl:value-of select='sfdc:label' /></td>
							<td><xsl:value-of select='sfdc:fullName' /></td>
							<td><a><xsl:attribute name="href"><xsl:value-of select='concat( sfdc:referenceTo, ".html" )' /></xsl:attribute><xsl:value-of select='sfdc:referenceTo' /></a></td>
							<!--<td><xsl:value-of select='sfdc:relationshipLabel' /></td>-->
							<td><xsl:value-of select='sfdc:relationshipName' /></td>
							<td><xsl:value-of select='sfdc:required' /></td>
						</tr>
					</xsl:for-each>
				</table>
				</xsl:if>
				
				<a name="fields"></a>
				<hr />
				<h3 data-magellan-destination="fields">Fields</h3>
				<a href="#" data-reveal-id="fieldSelect">Choose Columns</a>
				
				<table class="fields responsive">
					<thead>
						<tr>
							<th class='f_name'>Field Name</th>
							<th class='f_label'>Label</th>
							<th class='f_dt'>Data Type</th>
							<th class='f_opt'><span data-tooltip="data-tooltip" class="has-tip" title="PickList Values / Formula / Summary">Options</span></th>
							<th class='f_def isHidden'>Default Value</th>
							<!--<th class='f_alpha'>Alpha Sort?</th>-->
							<th class='f_std isHidden'>Standard ?</th>
							<th class='f_ext'>Extern ?</th>
							<th class='f_req isHidden'>Reqd ?</th>
							<th class='f_uniq isHidden'>Uniq ?</th>
							<th class='f_hist isHidden'>Hist ?</th>
							<th class='f_cmt'>Comments</th>
							<th class='f_help isHidden'>Help</th>
							<!-- <th class='f_hid'>Default Hidden</th> -->
						</tr>
					</thead>
					<tbody>
					<xsl:for-each select="sfdc:CustomObject/sfdc:fields">
						<xsl:sort select="sfdc:fullName" />
						<tr >
							<td class='f_name'><xsl:value-of select="sfdc:fullName" /></td>
							<td class='f_label'><xsl:value-of select="sfdc:label" /></td>
							<td class='f_dt'>
							<xsl:if test="sfdc:formula">Formula: </xsl:if>
							<xsl:choose>
								<xsl:when test="sfdc:length" >
									<xsl:value-of select="sfdc:type" />[<xsl:value-of select="sfdc:length" />]
								</xsl:when>
								<xsl:when test="sfdc:type = 'Lookup'">Lookup - <xsl:value-of select="sfdc:referenceTo" /></xsl:when>
								<xsl:when test="sfdc:type = 'MasterDetail'">MasterDetail - <xsl:value-of select="sfdc:referenceTo" /></xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="sfdc:type" />
								</xsl:otherwise>
							</xsl:choose>
							</td>
							<td class='f_opt'>
								<xsl:if test="sfdc:type = 'Picklist' or sfdc:formula or sfdc:type = 'Summary'">
									<a class='optionsShowBtn'>Show</a>
								</xsl:if>
								<div class='options'>
								<xsl:choose>
									<xsl:when test="sfdc:type = 'Picklist'">
										<xsl:for-each select="sfdc:picklist/sfdc:picklistValues">
											<xsl:value-of select="sfdc:fullName" />
											<xsl:if test="sfdc:default = 'true'"> - default</xsl:if>
											<xsl:text disable-output-escaping="yes"><br /></xsl:text>
										</xsl:for-each>
									</xsl:when>
									<xsl:when test="sfdc:formula">               
										<xsl:value-of select="sfdc:formula" />
									</xsl:when>
									<xsl:when test="sfdc:type = 'Summary'">
										<xsl:value-of select="sfdc:summaryOperation" /> - <b><xsl:value-of select="sfdc:summarizedField" /></b> on <b><xsl:value-of select="sfdc:summaryForeignKey" /></b>
									</xsl:when>
									<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
								</div>
								<!--
								picklist: picklist.picklistValues(fullName,default)&#13;summary:summarizedField,summaryForeignKey,summaryOperation&#13;function: formula
								-->
							</td>
							
							<td class='f_def isHidden'><xsl:value-of select="sfdc:defaultValue" /></td>
							
							<td class='f_std isHidden'>
								<xsl:choose>
									<xsl:when test="contains( sfdc:fullName, '__c' )"><b>Custom</b></xsl:when>
									<xsl:otherwise>Standard</xsl:otherwise>
								</xsl:choose>
							</td>
							
							<td class='f_ext'><xsl:choose>
								<xsl:when test='sfdc:externalId="true"'><b>External</b></xsl:when>
								<xsl:otherwise>_</xsl:otherwise>
							</xsl:choose></td>
							<td class='f_req isHidden'><xsl:choose>
								<xsl:when test='sfdc:required="true"'><b>Required</b></xsl:when>
								<xsl:otherwise>_</xsl:otherwise>
							</xsl:choose></td>
							<td class='f_uniq isHidden'><xsl:choose>
								<xsl:when test='sfdc:unique="true"'><b>Unique</b></xsl:when>
								<xsl:otherwise>_</xsl:otherwise>
							</xsl:choose></td>
							<td class='f_hist isHidden'><xsl:choose>
								<xsl:when test='sfdc:trackHistory="true"'><b>History</b></xsl:when>
								<xsl:otherwise>_</xsl:otherwise>
							</xsl:choose></td>
							<td class='f_cmt'><xsl:value-of select="sfdc:description" /></td>
							<td class='f_help isHidden'><xsl:value-of select="sfdc:inlineHelpText" /></td>
						</tr>
					</xsl:for-each>
					</tbody>
				</table>
				
				<xsl:if test="sfdc:CustomObject/sfdc:fieldSets">
				<a name="fieldSets"></a>
				<hr />
				<h3 data-magellan-destination="fieldSets">FieldSets</h3>
				<xsl:for-each select='sfdc:CustomObject/sfdc:fieldSets'>
					<h2 class='fullName'><xsl:value-of select='sfdc:fullName' /></h2>
					<div class='descr'><pre>Description: <xsl:value-of select='sfdc:description' /></pre></div>
					
					<ul>
					<xsl:for-each select="./sfdc:displayedFields">
						<xsl:sort select="sfdc:field" />
						<xsl:choose>
							<xsl:when test='sfdc:isRequired=false'>
						<li class='req'><xsl:value-of select='sfdc:field' />*</li>
							</xsl:when>
							<xsl:otherwise>
						<li class='noreq'><xsl:value-of select='sfdc:field' /></li>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					</ul>
				</xsl:for-each>
				</xsl:if>
				
				<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active='true']">
				<a name="validActive"></a>
				<hr />
				<h3 data-magellan-destination="validActive">Active Validation Rules</h3>
				<ul>
				<xsl:for-each select="sfdc:CustomObject/sfdc:validationRules[sfdc:active='true']">
					<xsl:sort select="sfdc:active" />
					<li class='validation'>
						<h3><xsl:value-of select='sfdc:fullName' /></h3>
						<p class='desc'><xsl:value-of select='sfdc:description' /></p>
						<p class='msg'>Error Message: <xsl:value-of select='sfdc:errorMessage' /></p>
						<pre class='formula'><xsl:value-of select='sfdc:errorConditionFormula' /></pre>
					</li>
				</xsl:for-each>
				</ul>
				</xsl:if>
				
				
				<xsl:if test="sfdc:CustomObject/sfdc:validationRules[sfdc:active!='true']">
				<a name="validInactive"></a>
				<hr />
				<h3 data-magellan-destination="validInactive">Inactive Validation Rules</h3>
				<ul>
				<xsl:for-each select="sfdc:CustomObject/sfdc:validationRules[sfdc:active!='true']">
					<xsl:sort select="sfdc:active" />
					<li class='validation'>
						<h3><xsl:value-of select='sfdc:fullName' /></h3>
						<p class='desc'><xsl:value-of select='sfdc:description' /></p>
						<p class='msg'>Error Message: <xsl:value-of select='sfdc:errorMessage' /></p>
						<pre class='formula'><xsl:value-of select='sfdc:errorConditionFormula' /></pre>
					</li>
				</xsl:for-each>
				</ul>
				</xsl:if>
			</div>
			</div>
			
			<a class="exit-off-canvas"></a>
			
		<!-- </section> -->
		
		</div>
	</div>
  
	<div id="myModal" class="reveal-modal" data-reveal="data-reveal">
		<div class="panel content"></div>
		<a class="close-reveal-modal">&#215;</a>
	</div>
	
	<div id='fieldSelect' class='reveal-modal medium' data-reveal="data-reveal">
		<form>
			<fieldset id="fs_visibleFields">
				<legend>Visible Fields</legend>
				<div class='row'>
					<div class="large-6 columns">
						<input type="checkbox" checked='checked' id='fs_name'><label for='fs_name'>API Name</label></input><br />
						<input type="checkbox" checked='checked' id='fs_label'><label for='fs_label'>Label</label></input><br />
						<input type="checkbox" checked='checked' id='fs_dt'><label for='fs_dt'>Data Type</label></input><br />
						<input type="checkbox" id='fs_opt'><label for='fs_opt'>Options</label></input><br />
						<input type="checkbox" id='fs_def'><label for='fs_def'>Default Value</label></input><br />
						<input type="checkbox" id='fs_std'><label for='fs_std'>Standard ?</label></input><br />
					</div>
					<div class="large-6 columns">
						<input type="checkbox" id='fs_ext'><label for='fs_ext'>External ?</label></input><br />
						<input type="checkbox" id='fs_req'><label for='fs_req'>Required ?</label></input><br />
						<input type="checkbox" id='fs_uniq'><label for='fs_uniq'>Unique ?</label></input><br />
						<input type="checkbox" id='fs_hist'><label for='fs_hist'>History ?</label></input><br />
						<input type="checkbox" checked='checked' id='fs_cmt'><label for='fs_cmt'>Comments</label></input><br />
						<input type="checkbox" id='fs_help'><label for='fs_help'>Inline Help</label></input>
					</div>
				</div>
			</fieldset>
			<!--
			<a href='#' id='fs_toggleAll' class="button small [radius round]">Toggle All</a>
			-->
			<a href='#' id='fs_closeBtn' class="button small [radius round]" style='float:right;'>close</a>
		</form>
		<a class="close-reveal-modal">&#215;</a>
	</div>
    
	<script src="../_src/js/vendor/jquery.js"></script>
	<script src="../_src/js/foundation.min.js"></script>
	<script src="../_src/js/foundation/foundation.magellan.js"></script>
	<script src="../_src/js/foundation/responsive-tables.js"></script>
	<script src="../_src/js/foundation/foundation.reveal.js"></script>
	<script src="../_src/js/vendor/spin.js" />
	
	<script>
		$(document).foundation();
		
		function redirectToSelf( anchor ){
			window.location = "?rand=" + Math.random() + anchor;
		}
		
		function revealModal( el ){
			//debugger;
			var o = el.siblings( ".options" );
			$("#myModal .content").html( o.html() );
			$("#myModal").foundation( "reveal","open" );
		}
		
		$("a.optionsShowBtn").on( "click", function( evt ){
			revealModal( $(this) );
		});
		
		$("#fieldSelect fieldset#fs_visibleFields :checkbox").on( "click", function( evt ){
			//debugger;
			toggleFieldSelect( evt.target.id, evt.target.checked );
		});
		$("#fieldSelect #fs_toggleAll").on( "click", function(){
			var areAllChecked = $("#fieldSelect fieldset#fs_visibleFields input:checkbox").length == $("#fieldSelect fieldset#fs_visibleFields :checked").length;
			//debugger;
			$("#fieldSelect fieldset#fs_visibleFields input:checkbox").each( function( index, element ){
				element.checked=!areAllChecked;
				toggleFieldSelect( element.id, !areAllChecked );
			});
			$("#myModal").foundation('reveal', 'close');
		});
		$("#fieldSelect #fs_closeBtn").on( "click", function(){
			//debugger;
			$("#myModal").foundation('reveal', 'close');
		});
		
		function toggleFieldSelect( fieldName, isVisible ){
			//debugger;
			var targetField = "." + fieldName.replace( "fs_", "f_" );
			$( targetField ).toggleClass( "isHidden", !isVisible );
		}
		
		function startSpinner(){
			if( !document.spinner ){
				document.spinner = new Spinner( { color: '#000', lines:12, left: "20%", top: "20%", position: "fixed" }).spin( document.body );
			}
		}
		
		function stopSpinner(){
			if( document.spinner ){
				document.spinner.stop();
				delete document.spinner;
			}
		}
	</script>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
