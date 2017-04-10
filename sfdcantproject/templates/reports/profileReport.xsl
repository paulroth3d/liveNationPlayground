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
	<title>{{ProfileName}}</title>
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
							<h1><a href='#'>Profile Report</a></h1>
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
						<li data-magellan-arrival="recordType"><a href="#recordType">Record Type Level</a></li>
						<li data-magellan-arrival="object"><a href="#object">Object Level</a></li>
						<li data-magellan-arrival="field"><a href="#field">Field Level</a></li>
					</ul>
				</div>
				
				<h1 id="top" data-magellan-destination="recordTypes">{{ProfileName}}</h1>
				
				<a name="recordType"></a>
				<h3 data-magellan-destination="recordType">Record Type Level Securities</h3>
				<table>
					<tr>
						<th>Record Type</th>
						<th>Visible</th>
						<th>Default</th>
					</tr>
				<xsl:for-each select="sfdc:Profile/sfdc:recordTypeVisibilities">
					<xsl:sort select="sfdc:recordType" />
					<xsl:sort select="sfdc:visible" />
					<xsl:sort select="sfdc:default" />
					
					<tr class='rtRow'>
						<xsl:choose><xsl:when test='sfdc:default="true"'>
						<td class='defaultrt'><xsl:value-of select='sfdc:recordType' /><span class='defMarker'>*</span></td>
						</xsl:when><xsl:otherwise>
						<td class='notdefaultrt'><xsl:value-of select='sfdc:recordType' /></td>
						</xsl:otherwise></xsl:choose>
						
						
						<xsl:choose>
							<xsl:when test='sfdc:visible="true"'>
						<td class='visible'>TRUE</td>
							</xsl:when>
							<xsl:otherwise>
						<td class='notvisible'><xsl:value-of select='sfdc:visible' /> </td>
							</xsl:otherwise>
						</xsl:choose>
						
						
						<xsl:choose>
							<xsl:when test='sfdc:default="true"'>
						<td class='default'>TRUE</td>
							</xsl:when>
							<xsl:otherwise>
						<td class='notdefault'><xsl:value-of select='sfdc:default' /> </td>
							</xsl:otherwise>
						</xsl:choose>
					</tr>
				</xsl:for-each>
				</table>
				
				<a name="object"></a>
				<h3 data-magellan-destination="object">Object Level Securities</h3>
				<table class='object'>
					<tr><th>Object</th><th>Rights</th></tr>
					<xsl:for-each select="sfdc:Profile/sfdc:objectPermissions">
						<xsl:sort select="sfdc:object" />
					<tr>
						<td><xsl:value-of select="sfdc:object" /></td>
						<td>
							<xsl:choose><xsl:when test='sfdc:allowCreate="true"'>C</xsl:when><xsl:otherwise>_</xsl:otherwise></xsl:choose>
							<xsl:choose><xsl:when test='sfdc:allowRead="true"'>R</xsl:when><xsl:otherwise>_</xsl:otherwise></xsl:choose>
							<xsl:choose><xsl:when test='sfdc:allowEdit="true"'>U</xsl:when><xsl:otherwise>_</xsl:otherwise></xsl:choose>
							<xsl:choose><xsl:when test='sfdc:allowDelete="true"'>D</xsl:when><xsl:otherwise>_</xsl:otherwise></xsl:choose>
							<xsl:choose><xsl:when test='sfdc:modifyAllRecords="true"'>M</xsl:when><xsl:otherwise>_</xsl:otherwise></xsl:choose>
							<xsl:choose><xsl:when test='sfdc:viewAllRecords="true"'>V</xsl:when><xsl:otherwise>_</xsl:otherwise></xsl:choose>
						</td>
					</tr>
					</xsl:for-each>
				</table>
				
				<a name="field"></a>
				<h3 data-magellan-destination="field">Field Level Securities</h3>
				<table class='field'>
					<tr><th>Field</th><th>Is Editable</th><th>Is Hidden</th></tr>
					<xsl:for-each select="sfdc:Profile/sfdc:fieldPermissions">
						<xsl:sort select="sfdc:field" />
					<tr>
						<td><xsl:value-of select="sfdc:field" /></td>
						<xsl:choose>
							<xsl:when test='sfdc:editable="true"'>
						<td class='edit'><b>True</b></td>
							</xsl:when>
							<xsl:otherwise>
						<td class='notedit'><xsl:value-of select="sfdc:editable" /> </td>
							</xsl:otherwise>
						</xsl:choose>
						
						<xsl:choose>
							<xsl:when test='sfdc:hidden="true"'>
						<td class='hide'>True</td>
							</xsl:when>
							<xsl:otherwise>
						<td class='nohide'><xsl:value-of select='sfdc-hidden' /> </td>
							</xsl:otherwise>
						</xsl:choose>
					</tr>
					</xsl:for-each>
				</table>
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
