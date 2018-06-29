<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:BMRBx="https://bmrbpub.pdbj.org/schema/mmcif_nmr-star.xsd">

  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <xsl:call-template name="exp_list"/>
  </xsl:template>

  <xsl:template name="exp_list">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:experimentCategory/BMRBx:experiment">
      <xsl:sort data-type="number" select="@id"/>
      <xsl:variable name="exp_name"><xsl:value-of select="./BMRBx:name"/></xsl:variable>
      <xsl:value-of select="concat('exp',format-number(@id,'00'),': ',$exp_name)"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[@xsi:nil='true']"/>
  <xsl:template match="*|text()|@*"/>

</xsl:stylesheet>
