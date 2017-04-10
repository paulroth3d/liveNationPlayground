<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sfdc="http://soap.sforce.com/2006/04/metadata"
	exclude-result-prefixes="sfdc"
>
<xsl:output method="html" 
 encoding="UTF-8"
 indent="yes" />
<xsl:template match="/">
<html><body>
<table><tr><td style='font-size:3em' colspan='10'>{{ObjectName}}</td></tr></table>
<table height='50px' style='height:50px;'><tr height='50px' style='height:50px;'><td height='50px' style='height:50px;'></td></tr></table>

<table border='1'>
<tr><td colspan="2" style='padding:10px; font-size:2em; font-weight: bold; background-color: #EEE;'>General</td></tr>
<tr><td>Type</td><td>Is Enabled</td></tr>
<tr><td>Activities</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableActivities' /></td></tr>
<tr><td>Enhanced Lookup</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableEnhancedLookup' /></td></tr>
<tr><td>enableFeeds</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableFeeds' /></td></tr>
<tr><td>enableHistory</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableHistory' /></td></tr>
<tr><td>enableReports</td><td><xsl:value-of select='sfdc:CustomObject/sfdc:enableReports' /></td></tr>
</table>
<table height='50px' style='height:50px;'><tr height='50px' style='height:50px;'><td height='50px' style='height:50px;'></td></tr></table>

<xsl:if test="sfdc:CustomObject/sfdc:recordTypes">
<table border='1'>
<tr><td colspan="3" style='padding:10px; font-size:2em; font-weight: bold; background-color: #EEE;'>Record Types</td></tr>
<tr><td>Name</td><td>Is Active</td><td>Description</td></tr>
<xsl:for-each select='sfdc:CustomObject/sfdc:recordTypes'>
<tr>
	<td><xsl:value-of select='sfdc:fullName' /></td>
	<td><xsl:choose>
		<xsl:when test='sfdc:active!="true"'>
			: In-Active
		</xsl:when>
	</xsl:choose></td>
	<td><xsl:value-of select='sfdc:description' /></td>
</tr>
</xsl:for-each>
</table>
<table height='50px' style='height:50px;'><tr height='50px' style='height:50px;'><td height='50px' style='height:50px;'></td></tr></table>
</xsl:if>

<xsl:if test="sfdc:CustomObject/sfdc:fields[sfdc:type='Lookup'] or sfdc:CustomObject/sfdc:fields[sfdc:type='MasterDetail']">
<table border='1'>
<tr><td colspan='11' style='padding:10px; font-size:2em; font-weight: bold; background-color: #EEE;'>Relationships</td></tr>
<tr><td>API</td><td colspan='2'>Label</td><td>Reference To</td><td>Type</td><td>Relationship Name</td><td></td><td></td><td></td><td></td><td>Required</td></tr>
<xsl:for-each select="sfdc:CustomObject/sfdc:fields[sfdc:type='Lookup']">
	<xsl:sort select="sfdc:fullName" />
<tr>
	<td><xsl:value-of select='sfdc:fullName' /></td>
	<td colspan='2'><xsl:value-of select='sfdc:label' /></td>
	<td><xsl:value-of select='sfdc:referenceTo' /></td>
	<td>Lookup</td>
	<td><xsl:value-of select='sfdc:relationshipName' /></td><td></td><td></td><td></td><td></td>
	<td><xsl:value-of select='sfdc:required' /></td>
</tr>
</xsl:for-each>
<xsl:for-each select="sfdc:CustomObject/sfdc:fields[sfdc:type='MasterDetail']">
	<xsl:sort select="sfdc:fullName" />
<tr>
	<td><xsl:value-of select='sfdc:label' /></td>
	<td colspan='2'><xsl:value-of select='sfdc:fullName' /></td>
	<td><xsl:value-of select='sfdc:referenceTo' /></td>
	<td>MasterDetail</td>
	<td><xsl:value-of select='sfdc:relationshipName' /></td><td></td><td></td><td></td><td></td>
	<td><xsl:value-of select='sfdc:required' /></td>
</tr>
</xsl:for-each>
</table>
<table height='50px' style='height:50px;'><tr height='50px' style='height:50px;'><td height='50px' style='height:50px;'></td></tr></table>
</xsl:if>

<table border='1'>
<tr><td colspan='14' style='padding:10px; font-size:2em; font-weight: bold; background-color: #EEE;'>Fields</td></tr>
<tr>
	<td>Field Name</td>
	<td colspan='2'>Label</td>
	<td>Comments</td>
	<td>Data Type</td>
	<td><span data-tooltip="data-tooltip" class="has-tip" title="PickList Values / Formula / Summary">Options</span></td>
	<td>Default Value</td>
	<td>Standard ?</td>
	<td>Extern ?</td>
	<td>Reqd ?</td>
	<td>Uniq ?</td>
	<td>Hist ?</td>
	<td>Comments</td>
	<td>Inline Help</td>
</tr>
<xsl:for-each select="sfdc:CustomObject/sfdc:fields">
	<xsl:sort select="sfdc:fullName" />
<tr >
	<td><xsl:value-of select="sfdc:fullName" /></td>
	<td colspan='2'><xsl:value-of select="sfdc:label" /></td>
	<td><xsl:value-of select="sfdc:description" /></td>
	<td>
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
	<xsl:if test="sfdc:formula">{}</xsl:if>
	</td>
	<td>
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
	</td>
	<td><xsl:value-of select="sfdc:defaultValue" /></td>
	<td>
		<xsl:choose>
			<xsl:when test="contains( sfdc:fullName, '__c' )"><b>Custom</b></xsl:when>
			<xsl:otherwise>Standard</xsl:otherwise>
		</xsl:choose>
	</td>
	<td><xsl:choose>
		<xsl:when test='sfdc:externalId="true"'><b>External</b></xsl:when>
		<xsl:otherwise>_</xsl:otherwise>
	</xsl:choose></td>
	<td><xsl:choose>
		<xsl:when test='sfdc:required="true"'><b>Required</b></xsl:when>
		<xsl:otherwise>_</xsl:otherwise>
	</xsl:choose></td>
	<td><xsl:choose>
		<xsl:when test='sfdc:unique="true"'><b>Unique</b></xsl:when>
		<xsl:otherwise>_</xsl:otherwise>
	</xsl:choose></td>
	<td><xsl:choose>
		<xsl:when test='sfdc:trackHistory="true"'><b>History</b></xsl:when>
		<xsl:otherwise>_</xsl:otherwise>
	</xsl:choose></td>
	<td><xsl:value-of select="sfdc:description" /></td>
	<td><xsl:value-of select="sfdc:inlineHelpText" /></td>
</tr>
</xsl:for-each>
</table>
<table height='50px' style='height:50px;'><tr height='50px' style='height:50px;'><td height='50px' style='height:50px;'></td></tr></table>

<xsl:if test="sfdc:CustomObject/sfdc:fieldSets">
<table border='1'>
<tr><td colspan='4' style='padding:10px; font-size:2em; font-weight: bold; background-color: #EEE;'>Field Sets</td></tr>
<tr><td>Name</td><td>Description</td><td>Fields</td></tr>
<xsl:for-each select='sfdc:CustomObject/sfdc:fieldSets'>
<tr><td style='border-style:none !important'></td>
	<td><xsl:value-of select='sfdc:fullName' /></td>
	<td><xsl:value-of select='sfdc:description' /></td>
	<td></td>
	<td>
	<xsl:for-each select="./sfdc:displayedFields">
		<xsl:sort select="sfdc:field" />
		<xsl:choose>
			<xsl:when test='sfdc:isRequired=false'><xsl:value-of select='sfdc:field' />*</xsl:when>
			<xsl:otherwise><xsl:value-of select='sfdc:field' /></xsl:otherwise>
		</xsl:choose>,<br />
	</xsl:for-each>
	</td></tr>
</xsl:for-each>
</table>
<table height='50px' style='height:50px;'><tr height='50px' style='height:50px;'><td height='50px' style='height:50px;'></td></tr></table>
</xsl:if>

<xsl:if test="sfdc:CustomObject/sfdc:validationRules">
<table border='1'>
<tr><td colspan='13' style='padding:10px; font-size:2em; font-weight: bold; background-color: #EEE;'>Validation Rules</td></tr>
<tr><td>Name</td><td>IsActive</td><td>Description</td><td>Error Message</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td>Condition Formula</td></tr>
<xsl:for-each select="sfdc:CustomObject/sfdc:validationRules[sfdc:active='true']">
	<xsl:sort select="sfdc:active" />
<tr>
	<td><xsl:value-of select='sfdc:fullName' /></td>
	<td>true</td>
	<td><xsl:value-of select='sfdc:description' /></td>
	<td><xsl:value-of select='sfdc:errorMessage' /></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>
	<td><xsl:value-of select='sfdc:errorConditionFormula' /></td>
</tr>
</xsl:for-each>

<xsl:for-each select="sfdc:CustomObject/sfdc:validationRules[sfdc:active!='true']">
	<xsl:sort select="sfdc:active" />
<tr><td><xsl:value-of select='sfdc:fullName' /></td>
	<td>false</td>
	<td><xsl:value-of select='sfdc:description' /></td>
	<td><xsl:value-of select='sfdc:errorMessage' /></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>
	<td><xsl:value-of select='sfdc:errorConditionFormula' /></td>
</tr>
</xsl:for-each>
</table>
<table height='50px' style='height:50px;'><tr height='50px' style='height:50px;'><td height='50px' style='height:50px;'></td></tr></table>
</xsl:if>

</body></html>
</xsl:template>
</xsl:stylesheet>
