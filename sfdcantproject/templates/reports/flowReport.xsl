<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sfdc="http://soap.sforce.com/2006/04/metadata"
	exclude-result-prefixes="sfdc"
>
<!--
keep moving forward with
https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_visual_workflow.htm
-->
<xsl:output method="html" 
			  omit-xml-declaration="yes"
              encoding="UTF-8"
              indent="yes" />
<xsl:template match="/">
<html class="no-js" lang="en">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
	<title><xsl:value-of select="sfdc:label" /></title>
	<link rel="stylesheet" href="../_src/css/foundation.css" />
	<link rel="stylesheet" href="../_src/css/responsive-tables.css" />
	<link rel="stylesheet" href="../_src/css/main.css" />
	<script src="../_src/js/vendor/modernizr.js"></script>
</head>
<body id="flowReport">
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
							<h1><a href='#'>Flow Report</a></h1>
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
									<li><a href="#top">Top</a></li>
									<xsl:if test="sfdc:Flow/sfdc:decisions">
									<li><a href="#decisions">Decisions</a></li>
									</xsl:if>
									<xsl:if test="sfdc:Flow/sfdc:screens">
									<li><a href="#screens">Screens</a></li>
									</xsl:if>
									<xsl:if test="sfdc:Flow/sfdc:choices">
									<li><a href="#choices">Choices</a></li>
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
				
				<div data-magellan-expedition="fixed">
					<ul class="sub-nav">
						<li data-magellan-arrival="top"><a href="#top">Top</a></li>
						<xsl:if test="sfdc:Flow/sfdc:decisions">
						<li data-magellan-arrival="decisions"><a href="#decisions">Decisions</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:screens">
						<li data-magellan-arrival="screens"><a href="#screens">Screens</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:choices">
						<li data-magellan-arrival="choices"><a href="#choices">Choices</a></li>
						</xsl:if>
						
						<xsl:if test="sfdc:Flow/sfdc:assignments">
						<li data-magellan-arrival="assignments"><a href="#assignments">Assignments</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:constants">
						<li data-magellan-arrival="constants"><a href="#constants">Constants</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:dynamicChoiceSets">
						<li data-magellan-arrival="dynamicChoiceSets"><a href="#dynamicChoiceSets">Dynamic Choice Sets</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:formulas">
						<li data-magellan-arrival="formulas"><a href="#formulas">Formulas</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:loops">
						<li data-magellan-arrival="loops"><a href="#loops">Loops</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:recordCreates">
						<li data-magellan-arrival="recordCreates"><a href="#recordCreates">Record Creates</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:recordDeletes">
						<li data-magellan-arrival="recordDeletes"><a href="#recordDeletes">Record Deletes</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:recordLookups">
						<li data-magellan-arrival="recordLookups"><a href="#recordLookups">Record Lookups</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:recordUpdates">
						<li data-magellan-arrival="recordUpdates"><a href="#recordUpdates">Record Updates</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:subflows">
						<li data-magellan-arrival="subflows"><a href="#subflows">Sub Flows</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:textTemplates">
						<li data-magellan-arrival="textTemplates"><a href="#textTemplates">Text Templates</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:variables">
						<li data-magellan-arrival="variables"><a href="#variables">Variables</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Flow/sfdc:waits">
						<li data-magellan-arrival="waits"><a href="#waits">Waits</a></li>
						</xsl:if>
						
					</ul>
				</div>
				
				<h1 id="top" data-magellan-destination="recordTypes"><xsl:value-of select="sfdc:label" /></h1>
				<p id='flowDescr'><xsl:value-of select="sfdc:description" /></p>
					
				<div class='row'>
				<div class="large-4 large-push-8 columns">
					<ul class='side-nav'>
					<xsl:if test="sfdc:Flow/sfdc:decisions">
						<li class="divider" />
						<li>Decisions</li>
					<xsl:for-each select="sfdc:Flow/sfdc:decisions">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:label' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:screens">
						<li class="divider" />
						<li>Screens</li>
					<xsl:for-each select="sfdc:Flow/sfdc:screens">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:label' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:choices">
						<li class="divider" />
						<li>Choices</li>
					<xsl:for-each select="sfdc:Flow/sfdc:choices">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					
					
					<xsl:if test="sfdc:Flow/sfdc:assignments">
						<li class="divider" />
						<li>assignments</li>
					<xsl:for-each select="sfdc:Flow/sfdc:assignments">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:constants">
						<li class="divider" />
						<li>constants</li>
					<xsl:for-each select="sfdc:Flow/sfdc:constants">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:dynamicChoiceSets">
						<li class="divider" />
						<li>dynamicChoiceSets</li>
					<xsl:for-each select="sfdc:Flow/sfdc:dynamicChoiceSets">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:formulas">
						<li class="divider" />
						<li>formulas</li>
					<xsl:for-each select="sfdc:Flow/sfdc:formulas">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:loops">
						<li class="divider" />
						<li>loops</li>
					<xsl:for-each select="sfdc:Flow/sfdc:loops">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:recordCreates">
						<li class="divider" />
						<li>recordCreates</li>
					<xsl:for-each select="sfdc:Flow/sfdc:recordCreates">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:recordDeletes">
						<li class="divider" />
						<li>recordDeletes</li>
					<xsl:for-each select="sfdc:Flow/sfdc:recordDeletes">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:recordLookups">
						<li class="divider" />
						<li>recordLookups</li>
					<xsl:for-each select="sfdc:Flow/sfdc:recordLookups">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:recordUpdates">
						<li class="divider" />
						<li>recordUpdates</li>
					<xsl:for-each select="sfdc:Flow/sfdc:recordUpdates">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:subflows">
						<li class="divider" />
						<li>subflows</li>
					<xsl:for-each select="sfdc:Flow/sfdc:subflows">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:textTemplates">
						<li class="divider" />
						<li>textTemplates</li>
					<xsl:for-each select="sfdc:Flow/sfdc:textTemplates">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:variables">
						<li class="divider" />
						<li>variables</li>
					<xsl:for-each select="sfdc:Flow/sfdc:variables">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:waits">
						<li class="divider" />
						<li>waits</li>
					<xsl:for-each select="sfdc:Flow/sfdc:waits">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					
					
					<h2>Todo:</h2>
					<xsl:if test="sfdc:Flow/sfdc:actionCalls">
						<li class="divider" />
						<li>actionCalls</li>
					<xsl:for-each select="sfdc:Flow/sfdc:actionCalls">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:apexPluginCalls">
						<li class="divider" />
						<li>apexPluginCalls</li>
					<xsl:for-each select="sfdc:Flow/sfdc:apexPluginCalls">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:processMetadataValues">
						<li class="divider" />
						<li>processMetadataValues</li>
					<xsl:for-each select="sfdc:Flow/sfdc:processMetadataValues">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Flow/sfdc:steps">
						<li class="divider" />
						<li>steps</li>
					<xsl:for-each select="sfdc:Flow/sfdc:steps">
						<xsl:sort select="sfdc:name" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					
					</ul>
				</div>
				<div class="large-8 large-pull-4 columns">
					
					
					<!-- general -->
					<a name="general"></a>
					<h3 id='flowLabel'><xsl:value-of select="sfdc:Flow/sfdc:label" /></h3>
					<p><xsl:value-of select="sfdc:Flow/sfdc:processType" /> - 
						<xsl:if test="sfdc:Flow/sfdc:startElementReference">
							Starts with: <a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:Flow/sfdc:startElementReference)" /></xsl:attribute><xsl:value-of select='sfdc:Flow/sfdc:startElementReference' /></a>
						</xsl:if>
					</p>
					
					<!-- decisions -->
					<xsl:if test="sfdc:Flow/sfdc:decisions">
					<a name="decisions"></a>
					<h3 data-magellan-destination="decisions">Decisions</h3>
					<ul class='disc'>
					<xsl:for-each select='sfdc:Flow/sfdc:decisions'>
						<li><h4 class='decisionName'><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:label' /></h4>
						<p><span class='decisionName'><xsl:value-of select='sfdc:name' /></span> -
							<span class='subscript'>(Default Connector:
								<a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:defaultConnector/sfdc:targetReference)" /></xsl:attribute><xsl:value-of select='sfdc:defaultConnector/sfdc:targetReference' /></a>)
							</span>
						</p>
						
						<xsl:for-each select='sfdc:rules'>
							<h5 class='ruleName'><xsl:attribute name="id"><xsl:value-of select="concat('rule_', sfdc:name)" /></xsl:attribute>Rule: <xsl:value-of select='sfdc:label' /></h5>
							<table>
								<tr>
									<th>Condition</th>
									<th>Resource</th>
									<th>Operator</th>
									<th>Value</th>
								</tr>
								<xsl:for-each select='sfdc:conditions'>
								<tr>
									<td><xsl:value-of select='../sfdc:conditionLogic' /></td>
									<td><xsl:value-of select='sfdc:leftValueReference' /></td>
									<td><xsl:value-of select='sfdc:operator' /></td>
									<td>
										<xsl:if test="sfdc:rightValue/sfdc:booleanValue">
											<xsl:value-of select='sfdc:rightValue/sfdc:booleanValue' />
										</xsl:if>
										<xsl:if test="sfdc:rightValue/sfdc:dateTimeValue">
											<xsl:value-of select='sfdc:rightValue/sfdc:dateTimeValue' />
										</xsl:if>
										<xsl:if test="sfdc:rightValue/sfdc:dateValue">
											<xsl:value-of select='sfdc:rightValue/sfdc:dateValue' />
										</xsl:if>
										<xsl:if test="sfdc:rightValue/sfdc:numberValue">
											<xsl:value-of select='sfdc:rightValue/sfdc:dateValue' />
										</xsl:if>
										<xsl:if test="sfdc:rightValue/sfdc:stringValue">
											<xsl:value-of select='sfdc:rightValue/sfdc:stringValue' />
										</xsl:if>
										<xsl:if test="sfdc:rightValue/sfdc:elementReference">
											<a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:rightValue/sfdc:elementReference)" /></xsl:attribute><xsl:value-of select='sfdc:rightValue/sfdc:elementReference' /></a>
										</xsl:if>
									</td>
								</tr>
								</xsl:for-each>
							</table>
						</xsl:for-each>
						<!--
						<p><b><xsl:value-of select="sfdc:integrationUser" /></b> calls <b><xsl:value-of select="sfdc:endpointUrl" /></b></p>
						<table border='1'>
							<tr><td>Protected</td><td><xsl:value-of select="sfdc:protected" /></td></tr>
							<tr><td>Include SessionId</td><td><xsl:value-of select="sfdc:includeSessionId" /></td></tr>
							<tr><td>Use Dead Letter Queue</td><td><xsl:value-of select="sfdc:useDeadLetterQueue" /></td></tr>
							<tr><td>API Version</td><td><xsl:value-of select="sfdc:apiVersion" /></td></tr>
						</table>
						
						<p>The following data is sent:
							<ul class='disc'>
							<xsl:for-each select='sfdc:fields'>
								<li><xsl:value-of select="current()"/></li>
							</xsl:for-each>
							</ul>
						</p>
						-->
						</li>
					</xsl:for-each>
					</ul>
					</xsl:if>
					
					<!-- screens -->
					<xsl:if test="sfdc:Flow/sfdc:screens">
					<a name="screens"></a>
					<h3 data-magellan-destination="screens">Screens</h3>
					<ul class='disc'>
					<xsl:for-each select='sfdc:Flow/sfdc:screens'>
						<li><h4 class='screenName'><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:label' /> Screen</h4>
						<p class='subscript'>(<xsl:value-of select='sfdc:name' /> 
							<xsl:if test="contains( sfdc:allowBack, 'true' )">- <b>Allows Back</b></xsl:if>
							<xsl:if test="contains( sfdc:allowFinish, 'true' )">- <b>Allows Finish</b></xsl:if>
							<xsl:if test="contains( sfdc:allowPause, 'true' )">- <b>Allows Pause</b></xsl:if>
						)</p>
						
						<div><xsl:if test="sfdc:connector">
							Connects to: <a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:connector/sfdc:targetReference )" /></xsl:attribute><xsl:value-of select='sfdc:connector/sfdc:targetReference' /></a>
						</xsl:if></div>
						
						<table border='1'>
						<tr>
							<th>Name</th>
							<th>DataType</th>
							<th>Default</th>
							<th>FieldText</th>
							<th>FieldType</th>
							<th>Info</th>
							<!--<th>Validation?</th>-->
						</tr>
						<xsl:for-each select='sfdc:fields'>
						<tr>
							<td><xsl:value-of select="sfdc:name" />
								<xsl:choose>
									<xsl:when test='sfdc:isRequired="true"'><span class='isRequired'>*</span></xsl:when>
									<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
							</td>
							<td><xsl:value-of select="sfdc:dataType" /></td>
							<td><xsl:value-of select="sfdc:defaultSelectedChoiceReference" /></td>
							<td><xsl:value-of select="sfdc:fieldText" /></td>
							<td><xsl:value-of select="sfdc:fieldType" /></td>
							<td>
							<xsl:if test="sfdc:choiceReferences">
								<ul class="circle">
								<xsl:for-each select="sfdc:choiceReferences">
									<li><xsl:value-of select="current()" /></li>
								</xsl:for-each>
								</ul>
							</xsl:if>
							<xsl:if test="sfdc:helpText">
								<xsl:value-of select="sfdc:helpText" />
							</xsl:if>
							</td>
						</tr>
						</xsl:for-each>
						</table>
						
						<!--
						<p><b><xsl:value-of select="sfdc:integrationUser" /></b> calls <b><xsl:value-of select="sfdc:endpointUrl" /></b></p>
						<table border='1'>
							<tr><td>Protected</td><td><xsl:value-of select="sfdc:protected" /></td></tr>
							<tr><td>Include SessionId</td><td><xsl:value-of select="sfdc:includeSessionId" /></td></tr>
							<tr><td>Use Dead Letter Queue</td><td><xsl:value-of select="sfdc:useDeadLetterQueue" /></td></tr>
							<tr><td>API Version</td><td><xsl:value-of select="sfdc:apiVersion" /></td></tr>
						</table>
						
						<p>The following data is sent:
							<ul class='disc'>
							<xsl:for-each select='sfdc:fields'>
								<li><xsl:value-of select="current()"/></li>
							</xsl:for-each>
							</ul>
						</p>
						-->
						</li>
					</xsl:for-each>
					</ul>
					</xsl:if>
					
					<!-- choices -->
					<xsl:if test="sfdc:Flow/sfdc:choices">
					<a name="choices"></a>
					<h3 data-magellan-destination="choices">Choices</h3>
					
					<table class="choices"><tr>
						<th>Name</th><th>Label</th><th>DataType</th><th>Value</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
						<td><xsl:value-of select="sfdc:choiceText" /></td>
						<td><xsl:value-of select="sfdc:dataType" /></td>
						<td>
							<xsl:if test="sfdc:value/sfdc:booleanValue">
								<xsl:value-of select='sfdc:value/sfdc:booleanValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:dateTimeValue">
								<xsl:value-of select='sfdc:value/sfdc:dateTimeValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:dateValue">
								<xsl:value-of select='sfdc:value/sfdc:dateValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:numberValue">
								<xsl:value-of select='sfdc:value/sfdc:dateValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:stringValue">
								<xsl:value-of select='sfdc:value/sfdc:stringValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:elementReference">
								<a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:value/sfdc:elementReference)" /></xsl:attribute><xsl:value-of select='sfdc:value/sfdc:elementReference' /></a>
							</xsl:if>
						</td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- start -->
					
					<!-- assignments -->
					<!-- leave off for now -->
					<xsl:if test="sfdc:Flow/sfdc:assignments">
					<a name="assignments"></a>
					<h3 data-magellan-destination="assignments">assignments</h3>
					
					<table class="assignments"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- constants -->
					<xsl:if test="sfdc:Flow/sfdc:constants">
					<a name="constants"></a>
					<h3 data-magellan-destination="constants">Constants</h3>
					
					<table class="constants"><tr>
						<th>Name</th><th>Data Type</th><th>Value</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
						<td><xsl:value-of select='sfdc:dataType' /></td>
						<td>
							<xsl:if test="sfdc:value/sfdc:booleanValue">
								<xsl:value-of select='sfdc:value/sfdc:booleanValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:dateTimeValue">
								<xsl:value-of select='sfdc:value/sfdc:dateTimeValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:dateValue">
								<xsl:value-of select='sfdc:value/sfdc:dateValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:numberValue">
								<xsl:value-of select='sfdc:value/sfdc:dateValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:stringValue">
								<xsl:value-of select='sfdc:value/sfdc:stringValue' />
							</xsl:if>
							<xsl:if test="sfdc:value/sfdc:elementReference">
								<a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:value/sfdc:elementReference)" /></xsl:attribute><xsl:value-of select='sfdc:value/sfdc:elementReference' /></a>
							</xsl:if>
						</td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- dynamicChoiceSets -->
					<xsl:if test="sfdc:Flow/sfdc:dynamicChoiceSets">
					<a name="dynamicChoiceSets"></a>
					<h3 data-magellan-destination="dynamicChoiceSets">Dynamic Choice Sets</h3>
					
					<xsl:for-each select="sfdc:Flow/sfdc:dynamicChoiceSets">
						<h4><xsl:value-of select='sfdc:name' /></h4>
						<p>
							<xsl:value-of select="sfdc:valueField" /> =
							<xsl:if test="sfdc:object">
								<xsl:value-of select="sfdc:object" /> - 
							</xsl:if>
							<xsl:value-of select="sfdc:displayField" /> ( <xsl:value-of select="sfdc:dataType" /> )
						</p>
						
						<xsl:if test="sfdc:picklistObject">
							<p><xsl:value-of select="sfdc:picklistObject" />.<xsl:value-of select="sfdc:picklistField" /></p>
						</xsl:if>
						
						<xsl:if test="sfdc:sortField"><p>
							( sorted by 
							<xsl:value-of select="sfdc:sortField" />
							<xsl:if test="sfdc:sortOrder"> - <xsl:value-of select="sfdc:sortOrder" /></xsl:if>
							)
						</p></xsl:if>
						
						<xsl:if test="sfdc:filters" >
						<h5>Filters</h5>
						<ul>
						<xsl:for-each select="sfdc:filters">
							<li>
								<xsl:value-of select="sfdc:field" /> is <xsl:value-of select="sfdc:operator" /> the value of  
								<xsl:if test="sfdc:value/sfdc:booleanValue">
									<xsl:value-of select='sfdc:value/sfdc:booleanValue' />
								</xsl:if>
								<xsl:if test="sfdc:value/sfdc:dateTimeValue">
									<xsl:value-of select='sfdc:value/sfdc:dateTimeValue' />
								</xsl:if>
								<xsl:if test="sfdc:value/sfdc:dateValue">
									<xsl:value-of select='sfdc:value/sfdc:dateValue' />
								</xsl:if>
								<xsl:if test="sfdc:value/sfdc:numberValue">
									<xsl:value-of select='sfdc:value/sfdc:dateValue' />
								</xsl:if>
								<xsl:if test="sfdc:value/sfdc:stringValue">
									<xsl:value-of select='sfdc:value/sfdc:stringValue' />
								</xsl:if>
								<xsl:if test="sfdc:value/sfdc:elementReference">
									<a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:value/sfdc:elementReference)" /></xsl:attribute><xsl:value-of select='sfdc:value/sfdc:elementReference' /></a>
								</xsl:if>
							</li>
						</xsl:for-each>
						</ul>
						</xsl:if>
						
						<xsl:if test="sfdc:outputAssignments" >
						<h5>Output Assignments</h5>
						<ul>
						<xsl:for-each select="sfdc:outputAssignments">
							<li>
								<xsl:value-of select="sfdc:field" /> to <xsl:value-of select="sfdc:assignToReference" />
							</li>
						</xsl:for-each>
						</ul>
						</xsl:if>
					
					</xsl:for-each>
					
					</xsl:if>
					
					<!-- formulas -->
					<xsl:if test="sfdc:Flow/sfdc:formulas">
					<a name="formulas"></a>
					<h3 data-magellan-destination="formulas">formulas</h3>
					
					<table class="formulas"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- loops -->
					<!-- not currently used in the project -->
					<xsl:if test="sfdc:Flow/sfdc:loops">
					<a name="loops"></a>
					<h3 data-magellan-destination="loops">loops</h3>
					
					<table class="loops"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- recordCreates -->
					<xsl:if test="sfdc:Flow/sfdc:recordCreates">
					<a name="recordCreates"></a>
					<h3 data-magellan-destination="recordCreates">recordCreates</h3>
					
					<table class="recordCreates"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- recordDeletes -->
					<!-- not currently used -->
					<xsl:if test="sfdc:Flow/sfdc:recordDeletes">
					<a name="recordDeletes"></a>
					<h3 data-magellan-destination="recordDeletes">recordDeletes</h3>
					
					<table class="recordDeletes"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- recordLookups -->
					<xsl:if test="sfdc:Flow/sfdc:recordLookups">
					<a name="recordLookups"></a>
					<h3 data-magellan-destination="recordLookups">recordLookups</h3>
					
					<table class="recordLookups"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- recordUpdates -->
					<!-- not currently used -->
					<xsl:if test="sfdc:Flow/sfdc:recordUpdates">
					<a name="recordUpdates"></a>
					<h3 data-magellan-destination="recordUpdates">recordUpdates</h3>
					
					<table class="recordUpdates"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- subflows -->
					<xsl:if test="sfdc:Flow/sfdc:subflows">
					<a name="subflows"></a>
					<h3 data-magellan-destination="subflows">subflows</h3>
					
					<table class="subflows"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- textTemplates -->
					<!-- not currently used -->
					<xsl:if test="sfdc:Flow/sfdc:textTemplates">
					<a name="textTemplates"></a>
					<h3 data-magellan-destination="textTemplates">textTemplates</h3>
					
					<table class="textTemplates"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- variables -->
					<xsl:if test="sfdc:Flow/sfdc:variables">
					<a name="variables"></a>
					<h3 data-magellan-destination="variables">variables</h3>
					
					<table class="variables"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					<!-- waits -->
					<!-- not currently used -->
					<xsl:if test="sfdc:Flow/sfdc:waits">
					<a name="waits"></a>
					<h3 data-magellan-destination="waits">waits</h3>
					
					<table class="waits"><tr>
						<th>Name</th>
					</tr>
					<xsl:for-each select='sfdc:Flow/sfdc:choices'>
					<tr>
						<td><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:name)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></td>
					</tr>
					</xsl:for-each>
					</table>
					</xsl:if>
					
					

				</div>
				</div>

			</div>
			</div>
			
			<a class="exit-off-canvas"></a>
			
		<!-- </section> -->
		
		</div>
	</div>
    
	<script src="../_src/js/vendor/jquery.js"></script>
	<script src="../_src/js/foundation.min.js"></script>
	<script src="../_src/js/foundation/foundation.magellan.js"></script>
	<script src="../_src/js/foundation/responsive-tables.js"></script>
	<script src="../_src/js/foundation/foundation.reveal.js"></script>
	<script src="../_src/js/vendor/spin.js" />
	
	<script>
		$(document).foundation();
	</script>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
