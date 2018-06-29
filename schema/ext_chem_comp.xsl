<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:BMRBx="https://bmrbpub.pdbj.org/schema/mmcif_nmr-star.xsd">

  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <xsl:call-template name="chem_comp"/>
  </xsl:template>

  <xsl:template name="chem_comp">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:chem_compCategory/BMRBx:chem_comp">
      <xsl:variable name="entry_id"><xsl:value-of select="./@entry_id"/></xsl:variable>
      <xsl:value-of select="concat('Entry ID    : ',$entry_id)"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:variable name="name"><xsl:value-of select="./BMRBx:name"/></xsl:variable>
      <xsl:value-of select="concat('Chem. Comp. : ',$name)"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:variable name="formula"><xsl:value-of select="./BMRBx:formula"/></xsl:variable>
      <xsl:value-of select="concat('Formula     : ',$formula)"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:variable name="formula_weight"><xsl:value-of select="./BMRBx:formula_weight"/></xsl:variable>
      <xsl:value-of select="concat('Formula Wt. : ',$formula_weight)"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:variable name="inchi_code"><xsl:value-of select="./BMRBx:inchi_code"/></xsl:variable>
      <xsl:value-of select="concat('InChi Code  : ',$inchi_code)"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:variable name="aromatic"><xsl:value-of select="./@aromatic"/></xsl:variable>
      <xsl:value-of select="concat('is Aromatic : ',$aromatic)"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[@xsi:nil='true']"/>
  <xsl:template match="*|text()|@*"/>

</xsl:stylesheet>
