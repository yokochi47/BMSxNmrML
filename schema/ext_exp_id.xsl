<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:BMRBx="http://bmrbpub.pdbj.org/schema/mmcif_nmr-star.xsd">

  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <xsl:apply-templates select="BMRBx:datablock/BMRBx:experimentCategory/BMRBx:experiment"/>
  </xsl:template>

  <xsl:template match="BMRBx:experiment">
    <xsl:value-of select="concat(@id,' ')"/>
  </xsl:template>

  <xsl:template match="*[@xsi:nil='true']"/>
  <xsl:template match="*|text()|@*"/>

</xsl:stylesheet>
