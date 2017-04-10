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
<body>
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
							<h1><a href='#'>Workflow Report</a></h1>
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
									<xsl:if test="sfdc:Workflow/sfdc:rules[sfdc:active='true']">
									<li><a href="#active">Active Rules</a></li>
									</xsl:if>
									<xsl:if test="sfdc:Workflow/sfdc:rules[sfdc:active!='true']">
									<li><a href="#inactive">InActive Rules</a></li>
									</xsl:if>
									<xsl:if test="sfdc:Workflow/sfdc:alerts">
									<li><a href="#alerts">Alerts</a></li>
									</xsl:if>
									<xsl:if test="sfdc:Workflow/sfdc:fieldUpdates">
									<li><a href="#field">Field Updates</a></li>
									</xsl:if>
									<xsl:if test="sfdc:Workflow/sfdc:outboundMessages">
									<li><a href="#outbound">Outbound Messages</a></li>
									</xsl:if>
									<xsl:if test="sfdc:Workflow/sfdc:tasks">
									<li><a href="#task">Tasks</a></li>
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
						<xsl:if test="sfdc:Workflow/sfdc:rules[sfdc:active='true']">
						<li data-magellan-arrival="active"><a href="#active">Active Rules</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Workflow/sfdc:rules[sfdc:active!='true']">
						<li data-magellan-arrival="inactive"><a href="#inactive">InActive Rules</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Workflow/sfdc:alerts">
						<li data-magellan-arrival="alerts"><a href="#alerts">Alerts</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Workflow/sfdc:fieldUpdates">
						<li data-magellan-arrival="field"><a href="#field">Field Updates</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Workflow/sfdc:outboundMessages">
						<li data-magellan-arrival="outbound"><a href="#outbound">Outbound Messages</a></li>
						</xsl:if>
						<xsl:if test="sfdc:Workflow/sfdc:tasks">
						<li data-magellan-arrival="task"><a href="#task">Tasks</a></li>
						</xsl:if>
					</ul>
				</div>
				
				<h1 id="top" data-magellan-destination="recordTypes">{{ObjectName}}</h1>
					
				<div class='row'>
				<div class="large-4 large-push-8 columns">
					<ul class='side-nav'>
					<xsl:if test="sfdc:Workflow/sfdc:rules[sfdc:active='true']">
						<li>Active Workflows</li>
					<xsl:for-each select="sfdc:Workflow/sfdc:rules">
						<xsl:sort select="sfdc:active" order="descending" />
						<xsl:sort select="sfdc:fullName" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#r_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:fullName' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Workflow/sfdc:rules[sfdc:active!='true']">
						<li class="divider" />
						<li>Inactive Workflows</li>
					<xsl:for-each select="sfdc:Workflow/sfdc:rules[sfdc:active!='true']">
						<xsl:sort select="sfdc:active" order="descending" />
						<xsl:sort select="sfdc:fullName" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#r_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:fullName' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Workflow/sfdc:alerts">
						<li class="divider" />
						<li>Alerts</li>
					<xsl:for-each select="sfdc:Workflow/sfdc:alerts">
						<xsl:sort select="sfdc:fullName" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:fullName' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Workflow/sfdc:fieldUpdates">
						<li class="divider" />
						<li>Field Updates</li>
					<xsl:for-each select="sfdc:Workflow/sfdc:fieldUpdates">
						<xsl:sort select="sfdc:fullName" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Workflow/sfdc:outboundMessages">
						<li class="divider" />
						<li>Outbound Messages</li>
					<xsl:for-each select="sfdc:Workflow/sfdc:outboundMessages">
						<xsl:sort select="sfdc:fullName" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></a></li>
					</xsl:for-each>
					</xsl:if>
					<xsl:if test="sfdc:Workflow/sfdc:tasks">
						<li class="divider" />
						<li>Tasks</li>
					<xsl:for-each select="sfdc:Workflow/sfdc:tasks">
						<xsl:sort select="sfdc:fullName" />
						<li><a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:subject' /></a></li>
					</xsl:for-each>
					</xsl:if>
					</ul>
				</div>
				<div class="large-8 large-pull-4 columns">
					<xsl:if test="sfdc:Workflow/sfdc:rules[sfdc:active='true']">
					<a name="active"></a>
					<h3 data-magellan-destination="active">Active Rules</h3>
					<ul class='disc'>
					<xsl:for-each select="sfdc:Workflow/sfdc:rules[sfdc:active='true']">
						<li><h4 class='alertFullName'><xsl:attribute name="id"><xsl:value-of select="concat('r_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:fullName' /></h4>
						<p><xsl:value-of select="sfdc:description" /></p>
						
						<span><b>If the following is true:</b> (<xsl:value-of select="sfdc:triggerType" />
							<xsl:for-each select="sfdc:workflowTimeTriggers">
								in <xsl:value-of select="sfdc:timeLength" />&#160;<xsl:value-of select="sfdc:workflowTimeTriggerUnit" />
							</xsl:for-each>)</span>
						<xsl:if test="sfdc:formula">
							<pre class="formula"><xsl:value-of select="sfdc:formula" /></pre>
						</xsl:if>
						<xsl:if test="sfdc:criteriaItems">
							<ul class='circle'>
							<xsl:for-each select="sfdc:criteriaItems">
								<li><xsl:value-of select="sfdc:field" /> - <xsl:value-of select="sfdc:operation" /> - [<xsl:value-of select="sfdc:value" />]</li>
							</xsl:for-each>
							</ul>
						</xsl:if>
						
						<br />
						<span><b>The following is performed:</b></span>
						<xsl:if test="sfdc:actions">
							<ul class='circle'>
							<xsl:for-each select="sfdc:actions">
								<li><xsl:value-of select="sfdc:type" /> - <a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select="sfdc:name" /></a></li>
							</xsl:for-each>
							</ul>
						</xsl:if>
						<xsl:if test="not(sfdc:actions)">
							<p><b>No actions registered for this workflow</b></p>
						</xsl:if>
						
						<br />
						</li>
					</xsl:for-each>
					</ul>
					</xsl:if>
					
					<xsl:if test="sfdc:Workflow/sfdc:rules[sfdc:active!='true']">
					<a name="inactive"></a>
					<h3 data-magellan-destination="inactive">Inactive Rules</h3>
					
					<ul class='disc'>
					<xsl:for-each select="sfdc:Workflow/sfdc:rules[sfdc:active!='true']">
						<li><h4 class='alertFullName'><xsl:attribute name="id"><xsl:value-of select="concat('r_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:fullName' /></h4>
						<p><xsl:value-of select="sfdc:description" /></p>
						
						<span><b>If the following is true:</b> (<xsl:value-of select="sfdc:triggerType" />
							<xsl:for-each select="sfdc:workflowTimeTriggers">
								in <xsl:value-of select="sfdc:timeLength" />&#160;<xsl:value-of select="sfdc:workflowTimeTriggerUnit" />
							</xsl:for-each>)</span>
						<xsl:if test="sfdc:formula">
							<pre class="formula"><xsl:value-of select="sfdc:formula" /></pre>
						</xsl:if>
						<xsl:if test="sfdc:criteriaItems">
							<ul class='circle'>
							<xsl:for-each select="sfdc:criteriaItems">
								<li><xsl:value-of select="sfdc:field" /> - <xsl:value-of select="sfdc:operation" /> - [<xsl:value-of select="sfdc:value" />]</li>
							</xsl:for-each>
							</ul>
						</xsl:if>
						
						<br />
						<span><b>The following is performed:</b></span>
						<xsl:if test="sfdc:actions">
							<ul class='circle'>
							<xsl:for-each select="sfdc:actions">
								<li><xsl:value-of select="sfdc:type" /> - <a><xsl:attribute name="href"><xsl:value-of select="concat('#_', sfdc:name)" /></xsl:attribute><xsl:value-of select="sfdc:name" /></a></li>
							</xsl:for-each>
							</ul>
						</xsl:if>
						<xsl:if test="not(sfdc:actions)">
							<p><b>No actions registered for this workflow</b></p>
						</xsl:if>
						
						<br />
						</li>
					</xsl:for-each>
					</ul>
					</xsl:if>
					
					<xsl:if test="sfdc:Workflow/sfdc:alerts">
					<a name="alerts"></a>
					<h3 data-magellan-destination="alerts">Alerts</h3>
					
					<ul class='disc'>
					<xsl:for-each select='sfdc:Workflow/sfdc:alerts'>
						<li><h4 class='alertFullName'><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:fullName' /></h4>
						<table border='1'>
							<tr><td>Template</td><td><xsl:value-of select="sfdc:template" /></td></tr>
							<tr><td>Sender Type</td><td><xsl:value-of select="sfdc:senderType" /></td></tr>
							<tr><td>Protected</td><td><xsl:value-of select="sfdc:protected" /></td></tr>
						</table>
						<p>CC'd users: <b><xsl:value-of select="sfdc:ccEmails" /></b></p>
						<p><xsl:value-of select="sfdc:description" /></p>
						</li>
					</xsl:for-each>
					</ul>
					</xsl:if>
					
					<xsl:if test="sfdc:Workflow/sfdc:fieldUpdates">
					<a name="field"></a>
					<h3 data-magellan-destination="field">Field Updates</h3>
					<ul class='disc'>
					<xsl:for-each select='sfdc:Workflow/sfdc:fieldUpdates'>
						<li><h4 class='fieldUpdateFullName'><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></h4>
						<p class='subscript'>(<xsl:value-of select='sfdc:fullName' />)</p>
						<xsl:choose>
							<xsl:when test="sfdc:operation = 'Formula'">
								<p>Sets field <b><xsl:value-of select='sfdc:field' /></b> to the following formula:</p>
								<pre class='formula'><xsl:value-of select='sfdc:formula' /></pre>
							</xsl:when>
							<xsl:otherwise>
								<p>Sets field <b><xsl:value-of select='sfdc:field' /></b> to the literal value: <b><xsl:value-of select='sfdc:literalValue' /></b></p>
							</xsl:otherwise>
						</xsl:choose>
						</li>
					</xsl:for-each>
					</ul>
					</xsl:if>
					
					
					
					<xsl:if test="sfdc:Workflow/sfdc:outboundMessages">
					<a name="outbound"></a>
					<h3 data-magellan-destination="outbound">Outbound Messages</h3>
					<ul class='disc'>
					<xsl:for-each select='sfdc:Workflow/sfdc:outboundMessages'>
						<li><h4 class='outboundFullName'><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:name' /></h4>
						<p class='subscript'>(<xsl:value-of select='sfdc:fullName' />)</p>
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
						
						</li>
					</xsl:for-each>
					</ul>
					</xsl:if>
					
					
					
					<xsl:if test="sfdc:Workflow/sfdc:tasks">
					<a name="task"></a>
					<h3 data-magellan-destination="task">Tasks</h3>
					<ul class='disc'>
					<xsl:for-each select='sfdc:Workflow/sfdc:tasks'>
						<li><h4 class='taskFullName'><xsl:attribute name="id"><xsl:value-of select="concat('_', sfdc:fullName)" /></xsl:attribute><xsl:value-of select='sfdc:subject' /></h4>
						<p class='subscript'>(<xsl:value-of select='sfdc:fullName' />)</p>
						<p><xsl:value-of select="sfdc:description" /></p>
						<p>A new task is assigned to <xsl:value-of select="sfdc:assignedToType" />:<xsl:value-of select="sfdc:assignedTo" />
							<xsl:if test="sfdc:dueDateOffset">due in <xsl:value-of select="sfdc:dueDateOffset" /> days from <xsl:value-of select="sfdc:offsetFromField" /></xsl:if>
						</p>
						<table border='1'>
							<tr><td>Assignee notified?</td><td><xsl:value-of select="sfdc:notifyAssignee" /></td></tr>
							<tr><td>Priority</td><td><xsl:value-of select="sfdc:priority" /></td></tr>
							<tr><td>Status</td><td><xsl:value-of select="sfdc:status" /></td></tr>
							<tr><td>Protected</td><td><xsl:value-of select="sfdc:protected" /></td></tr>
						</table>
						
						</li>
					</xsl:for-each>
					</ul>
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
