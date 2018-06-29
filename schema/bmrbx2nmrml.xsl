<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
  version="2.0"
  xmlns="http://nmrml.org/schema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:BMRBx="https://bmrbpub.pdbj.org/schema/mmcif_nmr-star.xsd">

  <xsl:param name="exp_id" required="yes"/>
  <xsl:param name="mirror"/>

  <xsl:output method="xhtml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:variable name="entry_id"><xsl:value-of select="/BMRBx:datablock/BMRBx:entryCategory/BMRBx:entry/@id"/></xsl:variable>

  <xsl:variable name="_exp_id"><xsl:value-of select="format-number($exp_id,'00')"/></xsl:variable>

  <xsl:variable name="bmr_entry_id">
    <xsl:choose>
      <xsl:when test="starts-with($entry_id, 'bms')"><xsl:value-of select="$entry_id"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="concat('bmr',$entry_id)"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="bmrb">
    <xsl:choose>
      <xsl:when test="starts-with($entry_id, 'bmse')">http://www.bmrb.wisc.edu/ftp/pub/bmrb/metabolomics/NMR_STAR_experimental_entries/</xsl:when>
      <xsl:when test="starts-with($entry_id, 'bmst')">http://www.bmrb.wisc.edu/ftp/pub/bmrb/metabolomics/NMR_STAR_theoretical_entries/</xsl:when>
      <xsl:otherwise>http://www.bmrb.wisc.edu/ftp/pub/bmrb/entry_lists/nmr-star3.1/</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="pdbj-bmrb">
    <xsl:choose>
      <xsl:when test="starts-with($entry_id, 'bmse')">https://bmrb.pdbj.org/ftp/pub/bmrb/metabolomics/NMR_STAR_experimental_entries/</xsl:when>
      <xsl:when test="starts-with($entry_id, 'bmst')">https://bmrb.pdbj.org/ftp/pub/bmrb/metabolomics/NMR_STAR_theoretical_entries/</xsl:when>
      <xsl:otherwise>https://bmrb.pdbj.org/ftp/pub/bmrb/entry_lists/nmr-star3.1/</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="bmrb-cerm">
    <xsl:choose>
      <xsl:when test="starts-with($entry_id, 'bmse')">http://bmrb.cerm.unifi.it/ftp/pub/bmrb/metabolomics/NMR_STAR_experimental_entries/</xsl:when>
      <xsl:when test="starts-with($entry_id, 'bmst')">http://bmrb.cerm.unifi.it/ftp/pub/bmrb/metabolomics/NMR_STAR_theoretical_entries/</xsl:when>
      <xsl:otherwise>http://bmrb.cerm.unifi.it/ftp/pub/bmrb/entry_lists/nmr-star3.1/</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="bmrb_urn">
    <xsl:choose>
      <xsl:when test="starts-with($entry_id, 'bms')">info:bmrb.metabolomics/</xsl:when>
      <xsl:otherwise>info:bmrb/</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="nmr-star_url">
    <xsl:choose>
      <xsl:when test="$mirror='osaka'"><xsl:value-of select="concat($pdbj-bmrb,$bmr_entry_id,'.str')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="concat($bmrb,$bmr_entry_id,'.str')"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="bmrb-xml_url">
    <xsl:value-of select="concat('https://bmrbpub.pdbj.org/archive/xml/',$bmr_entry_id,'.xml.gz')"/>
  </xsl:variable>

  <xsl:variable name="pdbj-bmrbdep">
    <xsl:choose>
      <xsl:when test="starts-with($entry_id, 'bms')">https://bmrbdep.pdbj.org/bms/</xsl:when>
      <xsl:otherwise>https://bmrbdep.pdbj.org/bmr/bmr</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="metabolomics_home_url">
    <xsl:text>http://www.bmrb.wisc.edu/metabolomics/</xsl:text>
  </xsl:variable>

  <xsl:variable name="metabolomics_data_url">
    <xsl:text>http://www.bmrb.wisc.edu/ftp/pub/bmrb/metabolomics/entry_directories/</xsl:text>
  </xsl:variable>

  <xsl:variable name="metabolomics_page_url">
    <xsl:choose>
      <xsl:when test="$mirror='osaka'"><xsl:value-of select="concat($pdbj-bmrbdep,$bmr_entry_id)"/></xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="starts-with($entry_id, 'bms')"><xsl:value-of select="$metabolomics_home_url"/>mol_summary/show_data.php?molName=<xsl:value-of select="/BMRBx:datablock/BMRBx:entryCategory/BMRBx:entry/BMRBx:bmrb_internal_directory_name"/>&amp;id=<xsl:value-of select="$bmr_entry_id"/>&amp;whichTab=1</xsl:when>
          <xsl:otherwise><xsl:value-of select="concat($pdbj-bmrbdep,$bmr_entry_id)"/></xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="experiment_name">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:experimentCategory/BMRBx:experiment[@id=$exp_id]">
      <xsl:value-of select="BMRBx:name"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="experiment_id">
    <xsl:value-of select="concat('experiment_',$exp_id)"/>
  </xsl:variable>

  <xsl:variable name="experiment_code">
    <xsl:value-of select="translate($experiment_name,' ','_')"/>
  </xsl:variable>

  <xsl:variable name="sample_spinning_rate">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:experimentCategory/BMRBx:experiment[@id=$exp_id]">
      <xsl:value-of select="BMRBx:sample_spinning_rate"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="number_of_dimensions">
    <xsl:choose>
      <xsl:when test="$number_of_dimensions_from_peak_list!=''">
        <xsl:value-of select="$number_of_dimensions_from_peak_list"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="substring-before($experiment_name,'D')"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="number_of_dimensions_from_peak_list">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:spectral_peak_listCategory/BMRBx:spectral_peak_list[BMRBx:experiment_id=$exp_id]">
      <xsl:value-of select="./BMRBx:number_of_spectral_dimensions"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="peak_char_count">
    <xsl:variable name="peak_chars">
      <xsl:for-each select="/BMRBx:datablock/BMRBx:peak_charCategory/BMRBx:peak_char[@spectral_peak_list_id=$spectral_peak_list_id]">
        <xsl:value-of select="' '"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="string-length($peak_chars)"/>
  </xsl:variable>

  <xsl:variable name="chem_comp_name">
    <xsl:value-of select="/BMRBx:datablock/BMRBx:chem_compCategory/BMRBx:chem_comp/BMRBx:name"/>
  </xsl:variable>

  <xsl:variable name="inchi_code">
    <xsl:value-of select="/BMRBx:datablock/BMRBx:chem_compCategory/BMRBx:chem_comp/BMRBx:inchi_code"/>
  </xsl:variable>

  <xsl:variable name="bmrb.metabolomics">https://bmrbdep.pdbj.org/bms/</xsl:variable>
  <xsl:variable name="pdb.ligand">http://ligand-expo.rcsb.org/pyapps/ldHandler.py?formid=cc-index-search&amp;operation=ccid&amp;target=</xsl:variable>

  <xsl:variable name="pubchem.substance">https://pubchem.ncbi.nlm.nih.gov/substance/</xsl:variable>
  <xsl:variable name="pubchem.compound">https://pubchem.ncbi.nlm.nih.gov/compound/</xsl:variable>
  <xsl:variable name="chembl">https://www.ebi.ac.uk/chembl/compound/inspect/</xsl:variable>
  <xsl:variable name="drugbank">https://www.drugbank.ca/drugs/</xsl:variable>
  <xsl:variable name="bdbm">https://www.bindingdb.org/bind/chemsearch/marvin/MolStructure.jsp?monomerid=</xsl:variable>
  <xsl:variable name="niaid">https://chemdb.niaid.nih.gov/CompoundDetails.aspx?AIDSNO=</xsl:variable>
  <xsl:variable name="cas">https://chem.nlm.nih.gov/chemidplus/rn/</xsl:variable>
  <xsl:variable name="biocyc">https://biocyc.org/compound?id=</xsl:variable>
  <xsl:variable name="zinc">http://zinc.docking.org/substance/</xsl:variable>
  <xsl:variable name="tci">http://www.tcichemicals.com/eshop/ja/jp/commodity/</xsl:variable>
  <xsl:variable name="specs">http://www.specs.net/enter.php?specsid=</xsl:variable>
  <xsl:variable name="sigma">http://www.sigmaaldrich.com/catalog/product/sigma/</xsl:variable>
  <xsl:variable name="aldrich">http://www.sigmaaldrich.com/catalog/product/aldrich/</xsl:variable>
  <xsl:variable name="lipidmaps">http://www.lipidmaps.org/data/LMSDRecord.php?LMID=</xsl:variable>
  <xsl:variable name="leadscope">http://www.leadscope.com/structure_search_results.php?ss_string=</xsl:variable>
  <xsl:variable name="kegg">http://www.kegg.jp/dbget-bin/www_bget?</xsl:variable>
  <xsl:variable name="hmdb">http://www.hmdb.ca/metabolites/</xsl:variable>
  <xsl:variable name="iuphar-db">http://www.guidetopharmacology.org/GRAC/LigandDisplayForward?ligandId=</xsl:variable>
  <xsl:variable name="chebi">http://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:</xsl:variable>
  <xsl:variable name="nist">http://webbook.nist.gov/cgi/inchi/</xsl:variable>
  <xsl:variable name="mmcd">http://mmcd.nmrfam.wisc.edu/test/cqsearch.py?cqid=</xsl:variable>
  <xsl:variable name="bbd">http://eawag-bbd.ethz.ch/servlets/pageservlet?ptype=c&amp;compID=</xsl:variable>
  <xsl:variable name="ctd">http://ctdbase.org/detail.go?type=chem&amp;acc=</xsl:variable>
  <xsl:variable name="chemdb">http://cdb.ics.uci.edu/cgibin/ChemicalDetailWeb.py?chemical_id=</xsl:variable>

  <xsl:variable name="pubchem.substance.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22###%22%5BCompleteSynonym%5D%20</xsl:variable>
  <xsl:variable name="pubchem.bhr.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22###%20(Beilstein%20Handbook%20Reference)%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="pubchem.nsc.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22NSC%20###%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="pubchem.hsdb.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22HSDB%20###%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="pubchem.fema.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22FEMA%20No.%20###%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="pubchem.epa.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22EPA%20Pesticide%20Chemical%20Code%20###%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="pubchem.einecs.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22EINECS%20###%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="pubchem.ec.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22EC%20###%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="pubchem.dsstox.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22DSSTox_CID_###%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="pubchem.ccris.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22CCRIS%20###%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="pubchem.caswell.search">https://www.ncbi.nlm.nih.gov/pcsubstance/?term=%22Caswell%20No.%20###%22%5BCompleteSynonym%5D</xsl:variable>
  <xsl:variable name="chemspider.search">http://www.chemspider.com/Chemical-Structure.###.html</xsl:variable>

  <xsl:variable name="sample_id">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:experimentCategory/BMRBx:experiment[@id=$exp_id]">
      <xsl:value-of select="./BMRBx:sample_id"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="sample_condition_list_id">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:experimentCategory/BMRBx:experiment[@id=$exp_id]">
      <xsl:value-of select="./BMRBx:sample_condition_list_id"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="ph">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:sample_condition_variableCategory/BMRBx:sample_condition_variable[@sample_condition_list_id=$sample_condition_list_id and @type='pH']">
      <xsl:value-of select="lower-case(./BMRBx:val)"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="temperature">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:sample_condition_variableCategory/BMRBx:sample_condition_variable[@sample_condition_list_id=$sample_condition_list_id and @type='temperature']">
      <xsl:value-of select="./BMRBx:val"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="spectral_peak_list_id">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:spectral_peak_listCategory/BMRBx:spectral_peak_list[BMRBx:experiment_id=$exp_id]">
      <xsl:value-of select="@id"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="nmr_spectrometer_id">
    <xsl:for-each select="BMRBx:datablock/BMRBx:experimentCategory/BMRBx:experiment[@id=$exp_id]">
      <xsl:value-of select="./BMRBx:nmr_spectrometer_id"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="nmr_spectrometer_label">
    <xsl:for-each select="BMRBx:datablock/BMRBx:experimentCategory/BMRBx:experiment[@id=$exp_id]">
      <xsl:value-of select="./BMRBx:nmr_spectrometer_label"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="spectrometer_manufacturer">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:nmr_spectrometerCategory/BMRBx:nmr_spectrometer[@id=$nmr_spectrometer_id]">
      <xsl:value-of select="./BMRBx:manufacturer"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="assigned_chem_shift_list_id">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:chem_shift_experimentCategory/BMRBx:chem_shift_experiment[@experiment_id=$exp_id]">
      <xsl:value-of select="@assigned_chem_shift_list_id"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="organization_full_name">
    <xsl:value-of select="/BMRBx:datablock/BMRBx:entry_srcCategory/BMRBx:entry_src/BMRBx:organization_full_name"/>
  </xsl:variable>

  <xsl:variable name="probe_manufacturer">
    <xsl:value-of select="/BMRBx:datablock/BMRBx:nmr_spectrometer_probeCategory/BMRBx:nmr_spectrometer_probe[@id='1']/BMRBx:manufacturer"/>
  </xsl:variable>

  <xsl:variable name="probe_model">
    <xsl:value-of select="/BMRBx:datablock/BMRBx:nmr_spectrometer_probeCategory/BMRBx:nmr_spectrometer_probe[@id='1']/BMRBx:model"/>
  </xsl:variable>

  <xsl:template match="/">
    <nmrML xsi:schemaLocation="http://nmrml.org/schema http://nmrml.org/schema/v1.0.0/nmrML.xsd" version="v1.0.0" accession="{$bmr_entry_id}" accession_url="{$metabolomics_page_url}" id="{$bmr_entry_id}-exp{$_exp_id}">
      <cvList>
        <cv id="NMRCV" fullName="nmrML Controlled Vocabulary" URI="http://nmrml.org/cv/v1.1.0/nmrCV.owl" version="1.1.0"/>
        <cv id="UO" fullName="Unit Ontology" URI="http://unit-ontology.googlecode.com/svn/trunk/uo.owl/" version="3.2.0"/>
        <cv id="ChEBI" fullName="Chemical entities of biological interest" URI="http://purl.obolibrary.org/obo/chebi.owl" version="ChEBI Release version 108"/>
      </cvList>
      <xsl:call-template name="file_description"/>
      <xsl:call-template name="contact_list"/>
      <xsl:call-template name="referenceable_param_group_list"/>
      <xsl:call-template name="source_file_list"/>
      <xsl:call-template name="software_list"/>
      <xsl:call-template name="instrument_configuration_list"/>
      <xsl:call-template name="data_processing_list"/>
      <xsl:call-template name="sample_list"/>
      <xsl:call-template name="acquisition"/>
      <xsl:call-template name="spectrum_list"/>
      <xsl:call-template name="spectrum_annotation_list"/>
    </nmrML>
  </xsl:template>

  <!-- fileDescription -->

  <xsl:template name="file_description">
    <fileDescription>
      <fileContent>
        <xsl:for-each select="BMRBx:datablock/BMRBx:experiment_fileCategory/BMRBx:experiment_file[@experiment_id=$exp_id]">
          <xsl:variable name="type"><xsl:value-of select="./BMRBx:type"/></xsl:variable>
          <xsl:variable name="details"><xsl:value-of select="./BMRBx:details"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$type='Time-domain (raw spectral data)' or ($type='text/directory' and $details='Time-domain (raw spectral data)')">
              <xsl:choose>
                <!-- 1D FID -->
                <xsl:when test="$number_of_dimensions='1'"><cvTerm cvRef="NMRCV" accession="NMR:1400159" name="1D FID"/></xsl:when>
                <!-- 2D FID -->
                <xsl:when test="$number_of_dimensions='2'"><cvTerm cvRef="NMRCV" accession="NMR:1400160" name="2D FID"/></xsl:when>
                <!-- nD FID -->
                <xsl:otherwise>
                  <xsl:element name="userParam">
                    <xsl:attribute name="name">
                      <xsl:value-of select="concat($number_of_dimensions,'D FID')"/>
                    </xsl:attribute>
                  </xsl:element>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$type='Peak lists' or ($type='text/xml' and $details='TopSpin peak list')">
              <xsl:if test="$spectral_peak_list_id!=''">
                <cvTerm cvRef="NMRCV" accession="NMR:1002005" name="peak-picked spectrum"/>
              </xsl:if>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
        <xsl:if test="$assigned_chem_shift_list_id!=''">
          <cvTerm cvRef="NMRCV" accession="NMR:1000223" name="chemical shift"/>
        </xsl:if>
      </fileContent>
    </fileDescription>
  </xsl:template>

  <!-- contactList -->

  <xsl:template name="contact_list">
    <contactList>
      <xsl:for-each select="BMRBx:datablock/BMRBx:entry_authorCategory/BMRBx:entry_author">
        <xsl:variable name="fullname"><xsl:value-of select="normalize-space(concat(BMRBx:given_name,' ',BMRBx:middle_initials,' ',BMRBx:family_name))"/></xsl:variable>
        <xsl:element name="contact">
          <xsl:attribute name="id"><xsl:value-of select="concat('entry_author_',@ordinal)"/></xsl:attribute>
          <xsl:attribute name="fullname"><xsl:value-of select="$fullname"/></xsl:attribute>
          <xsl:attribute name="organization"><xsl:value-of select="$organization_full_name"/></xsl:attribute>
          <xsl:attribute name="email">
            <xsl:choose>
              <xsl:when test="$fullname='Mark E. Anderson'">wombats@nmrfam.wisc.edu</xsl:when>
              <xsl:when test="$fullname='Francisca Jofre'">mfjofre@chem.wisc.edu</xsl:when>
              <xsl:when test="$fullname='John L. Markley'">markley@nmrfam.wisc.edu</xsl:when>
              <xsl:when test="$fullname='Hans J Vogel'">vogel@ucalgary.ca</xsl:when>
              <xsl:when test="$fullname='Dan Bearden'">dan.bearden@noaa.gov</xsl:when>
              <xsl:when test="$fullname='David S Wishart'">wishartadmin@mailman.srv.ualberta.ca</xsl:when>
              <xsl:when test="$fullname='Qiu Cui'">cui@nmrfam.wisc.edu</xsl:when>
              <xsl:when test="$fullname='Maria Nesterova'">mnesterova@wisc.edu</xsl:when>
              <xsl:when test="$fullname='Ian Lewis'">ian.lewis2@ucalgary.ca</xsl:when>
              <xsl:when test="$fullname='Brian Sykes'">brian.sykes@ualberta.ca</xsl:when>
              <xsl:otherwise>na</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:element>
      </xsl:for-each>
    </contactList>
  </xsl:template>

  <!-- referenceableParamGroupList -->

  <xsl:template name="referenceable_param_group_list">
    <!--referenceableParamGroupList/-->
  </xsl:template>

  <!-- sourceFileList -->

  <xsl:template name="source_file_list">
    <sourceFileList>
      <sourceFile id="NMR-STAR_3.1_FILE" name="{$bmr_entry_id}.str" location="{$nmr-star_url}">
        <cvTerm cvRef="NMRCV" accession="NMR:1000113" name="NMR Star 3.1 file format"/>
      </sourceFile>
      <sourceFile id="BMRB-XML_FILE" name="{$bmr_entry_id}.xml.gz" location="{$bmrb-xml_url}">
        <cvTerm cvRef="NMRCV" accession="NMR:1000439" name="BMRB/XML file format"/>
      </sourceFile>
      <xsl:for-each select="BMRBx:datablock/BMRBx:experiment_fileCategory/BMRBx:experiment_file[@experiment_id=$exp_id]">
        <xsl:variable name="type"><xsl:value-of select="./BMRBx:type"/></xsl:variable>
        <xsl:variable name="details"><xsl:value-of select="./BMRBx:details"/></xsl:variable>
        <xsl:variable name="destination"><xsl:value-of select="replace(@name,'/\*$','')"/></xsl:variable>
        <xsl:variable name="filename"><xsl:value-of select="tokenize($destination,'/')[last()]"/></xsl:variable>
        <xsl:variable name="directory_path"><xsl:value-of select="./BMRBx:directory_path"/></xsl:variable>
        <xsl:variable name="abs_dir_path"><xsl:value-of select="concat($metabolomics_data_url,$entry_id,'/',$directory_path)"/></xsl:variable>
        <xsl:variable name="experiment_url"><xsl:value-of select="concat($abs_dir_path,$destination)"/></xsl:variable>
        <xsl:choose>
          <xsl:when test="$type='Time-domain (raw spectral data)' or ($type='text/directory' and $details='Time-domain (raw spectral data)')">
            <xsl:choose>
              <!-- Bruker 1D FID -->
              <xsl:when test="$spectrometer_manufacturer='Bruker' and $number_of_dimensions='1'">
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">FID_FILE</xsl:attribute>
                  <xsl:attribute name="name">fid</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/fid')"/></xsl:attribute>
                  <xsl:attribute name="sha1">NEED_SHA1</xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1000264" name="Bruker FID file"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">PULSE_PROGRAM_FILE</xsl:attribute>
                  <xsl:attribute name="name">pulseprogram</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/pulseprogram')"/></xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1400122" name="pulse sequence file"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">ACQUISITION_FILE</xsl:attribute>
                  <xsl:attribute name="name">acqus</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/acqus')"/></xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1400165" name="1D NMR acquisition parameter set"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">PROCESSING_FILE</xsl:attribute>
                  <xsl:attribute name="name">procs</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/pdata/1/procs')"/></xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1000250" name="Bruker processing parameter file"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">REAL_DATA_FILE</xsl:attribute>
                  <xsl:attribute name="name">1r</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/pdata/1/1r')"/></xsl:attribute>
                  <xsl:attribute name="sha1">NEED_SHA1</xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1400161" name="1D spectrum"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1000319" name="1R file"/>
                </xsl:element>
              </xsl:when>
              <!-- Bruker 2D FID -->
              <xsl:when test="$spectrometer_manufacturer='Bruker' and $number_of_dimensions='2'">
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">FID_FILE</xsl:attribute>
                  <xsl:attribute name="name">ser</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/ser')"/></xsl:attribute>
                  <xsl:attribute name="sha1">NEED_SHA1</xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1000264" name="Bruker FID file"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">PULSEPROGRAM_FILE</xsl:attribute>
                  <xsl:attribute name="name">pulseprogram</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/pulseprogram')"/></xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1400122" name="pulse sequence file"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">ACQUISITION_FILE</xsl:attribute>
                  <xsl:attribute name="name">acqus</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/acqus')"/></xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1400165" name="1D NMR acquisition parameter set"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">ACQUISITION2_FILE</xsl:attribute>
                  <xsl:attribute name="name">acqu2s</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/acqu2s')"/></xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1400166" name="2D NMR acquisition parameter set"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">PROCESSING_FILE</xsl:attribute>
                  <xsl:attribute name="name">procs</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/pdata/1/procs')"/></xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1000250" name="Bruker processing parameter file"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">PROCESSING2_FILE</xsl:attribute>
                  <xsl:attribute name="name">proc2s</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/pdata/1/proc2s')"/></xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1000250" name="Bruker processing parameter file"/>
                </xsl:element>
                <xsl:element name="sourceFile">
                  <xsl:attribute name="id">REAL_DATA_FILE</xsl:attribute>
                  <xsl:attribute name="name">2rr</xsl:attribute>
                  <xsl:attribute name="location"><xsl:value-of select="concat($experiment_url,'/pdata/1/2rr')"/></xsl:attribute>
                  <xsl:attribute name="sha1">NEED_SHA1</xsl:attribute>
                  <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                  <cvParam cvRef="NMRCV" accession="NMR:1400162" name="2D spectrum"/>
                  <userParam name="2RR file"/>
                </xsl:element>
              </xsl:when>
              <!-- otherwise -->
              <xsl:otherwise>
                <sourceFile id="TIME-DOMAIN_DATA_DIRECTORY" location="{$experiment_url}">
                  <userParam name="A data directory contains FID, FT and associating acquisition and processing parameter files"/>
                </sourceFile>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$type='Peak lists' or ($type='text/plain' and $details='Peak list') or ($type='text/xml' and $details='TopSpin peak list')">
            <xsl:variable name="abs_peak_path"><xsl:value-of select="concat($metabolomics_data_url,$entry_id,'/',$directory_path,'/',$filename)"/></xsl:variable>
            <!--xsl:if test="$spectral_peak_list_id!=''"-->
              <sourceFile id="PEAK_LIST_FILE" name="{$filename}" location="{$abs_peak_path}">
                <cvParam cvRef="NMRCV" accession="NMR:1400320" name="Bruker UXNMR/XWIN-NMR format"/>
                <xsl:if test="$type='Peak lists' or ($type='text/plain' and $details='Peak list')">
                  <cvTerm cvRef="NMRCV" accession="NMR:1002005" name="text file"/>
                </xsl:if>
                <xsl:if test="$type='text/xml'">
                  <userParam name="TopSpin peak file in XML format"/>
                </xsl:if>
              </sourceFile>
            <!--/xsl:if-->
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </sourceFileList>
  </xsl:template>

  <!-- softwareList -->

  <xsl:template name="software_list">
    <softwareList>
      <xsl:for-each select="BMRBx:datablock/BMRBx:softwareCategory/BMRBx:software">
        <xsl:variable name="name"><xsl:value-of select="./BMRBx:name"/></xsl:variable>
        <xsl:if test="$name!='Gaussian'">
          <xsl:element name="software">
            <xsl:attribute name="id"><xsl:value-of select="$name"/></xsl:attribute>
            <xsl:if test="./BMRBx:version!=''">
              <xsl:attribute name="version"><xsl:value-of select="./BMRBx:version"/></xsl:attribute>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="$name='Mestrec'">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:attribute name="accession">NMR:1000239</xsl:attribute>
                <xsl:attribute name="name">Mestrelab software</xsl:attribute>
              </xsl:when>
              <xsl:when test="$name='NMRPipe'">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:attribute name="accession">NMR:1000093</xsl:attribute>
                <xsl:attribute name="name">NMRPipe software</xsl:attribute>
              </xsl:when>
              <xsl:when test="$name='NUTS'">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:attribute name="accession">NMR:1400270</xsl:attribute>
                <xsl:attribute name="name">Acorn NMR Inc</xsl:attribute>
              </xsl:when>
              <xsl:when test="$name='XWIN-NMR'">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:attribute name="accession">NMR:1400214</xsl:attribute>
                <xsl:attribute name="name">Bruker NMR software</xsl:attribute>
              </xsl:when>
              <xsl:when test="$name='TopSpin'">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:attribute name="accession">NMR:1400215</xsl:attribute>
                <xsl:attribute name="name">TopSpin 1.3 software</xsl:attribute>
              </xsl:when>
              <xsl:when test="$name='NMRbot'">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:attribute name="accession">NMR:1000168</xsl:attribute>
                <xsl:attribute name="name">NMR acquisition software</xsl:attribute>
              </xsl:when>
              <xsl:when test="$name='ACD'">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:attribute name="accession">NMR:1000240</xsl:attribute>
                <xsl:attribute name="name">ACD spectrus software</xsl:attribute>
              </xsl:when>
              <xsl:when test="$name='Gaussian'"></xsl:when>
              <xsl:when test="$name='NMRDraw'">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:attribute name="accession">NMR:1000322</xsl:attribute>
                <xsl:attribute name="name">NMR spectrum vizualisation software</xsl:attribute>
              </xsl:when>
            </xsl:choose>
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </softwareList>
  </xsl:template>

  <!-- instrumentConfigurationList -->

  <xsl:template name="instrument_configuration_list">
    <instrumentConfigurationList>
      <instrumentConfiguration id="{$nmr_spectrometer_label}">
        <xsl:for-each select="/BMRBx:datablock/BMRBx:nmr_spectrometerCategory/BMRBx:nmr_spectrometer[@id=$nmr_spectrometer_id]">
          <xsl:variable name="model"><xsl:value-of select="./BMRBx:model"/></xsl:variable>
          <xsl:variable name="field_strength"><xsl:value-of select="./BMRBx:field_strength"/></xsl:variable>
          <xsl:variable name="details"><xsl:value-of select="./BMRBx:details"/></xsl:variable>
          <xsl:if test="$spectrometer_manufacturer!=''">
            <cvParam cvRef="NMRCV" accession="NMR:1400255" name="NMR instrument vendor" value="{$spectrometer_manufacturer}"/>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$spectrometer_manufacturer='Bruker'">
              <xsl:if test="$model!=''">
                <cvParam cvRef="NMRCV" accession="NMR:1000122" name="Bruker instrument model" value="{$model}"/>
              </xsl:if>
              <xsl:if test="$details!=''">
                <cvParam cvRef="NMRCV" accession="NMR:1000032" name="instrument customization" value="{$details}"/>
              </xsl:if>
              <xsl:if test="$field_strength!=''">
                <cvParamWithUnit cvRef="NMRCV" accession="NMR:1400253" name="magnetic field strength" value="{$field_strength}" unitCvRef="UO" unitAccession="UO_0000325" unitName="megaHertz"/>
              </xsl:if>
              <cvTerm cvRef="NMRCV" accession="NMR:1400198" name="Bruker NMR instrument"/>
              <xsl:if test="$probe_manufacturer='Bruker' and contains($probe_model,'CryoProbe')">
                <cvTerm cvRef="NMRCV" accession="NMR:1400191" name="Bruker CryoProbe"/>
              </xsl:if>
              <xsl:if test="$probe_manufacturer='Bruker' and not(contains($probe_model,'CryoProbe'))">
                <cvTerm cvRef="NMRCV" accession="NMR:1400231" name="Bruker NMR probe"/>
              </xsl:if>
              <xsl:for-each select="/BMRBx:datablock/BMRBx:softwareCategory/BMRBx:software">
                <xsl:variable name="name"><xsl:value-of select="./BMRBx:name"/></xsl:variable>
                <xsl:if test="$name='XWIN-NMR' or $name='TopSpin'">
                  <softwareRef ref="{$name}"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <!-- not Bruker spectrometer -->
          </xsl:choose>
        </xsl:for-each>
      </instrumentConfiguration>
    </instrumentConfigurationList>
  </xsl:template>

  <!-- dataProcessingList -->

  <xsl:template name="data_processing_list">
    <!--dataProcessingList-->
  </xsl:template>

  <!-- sampleList -->

  <xsl:template name="sample_list">
    <sampleList>
      <xsl:for-each select="BMRBx:datablock/BMRBx:sampleCategory/BMRBx:sample[@id=$sample_id]">
        <xsl:element name="sample">
          <xsl:attribute name="originalBiologicalSampleReference"><xsl:value-of select="substring-before($chem_comp_db_link_rep,' ')"/></xsl:attribute>
          <xsl:if test="$ph!='' and $ph!='n/a'">
            <!--originalBiologicalSamplepH><xsl:value-of select="$ph"/></originalBiologicalSamplepH-->
            <postBufferpH><xsl:value-of select="$ph"/></postBufferpH>
          </xsl:if>
          <!-- buffer -->
          <xsl:for-each select="/BMRBx:datablock/BMRBx:sample_componentCategory/BMRBx:sample_component[@sample_id=$sample_id]">
            <xsl:variable name="type"><xsl:value-of select="lower-case(./BMRBx:type)"/></xsl:variable>
            <xsl:if test="$type='buffer'">
              <xsl:variable name="mol_common_name"><xsl:value-of select="./BMRBx:mol_common_name"/></xsl:variable>
              <xsl:choose>
                <xsl:when test="$mol_common_name='sodium phosphate' or $mol_common_name='phosphate'">
                  <buffer cvRef="ChEBI" accession="CHEBI_37586" name="sodium phosphate"/>
                </xsl:when>
              </xsl:choose>
            </xsl:if>
          </xsl:for-each>
          <!-- fieldFrequencyLock -->
          <xsl:variable name="lock_name">
            <xsl:for-each select="/BMRBx:datablock/BMRBx:sample_componentCategory/BMRBx:sample_component[@sample_id=$sample_id]">
              <xsl:variable name="type"><xsl:value-of select="lower-case(./BMRBx:type)"/></xsl:variable>
              <xsl:if test="$type='solvent'">
                <xsl:variable name="mol_common_name"><xsl:value-of select="./BMRBx:mol_common_name"/></xsl:variable>
                 <xsl:value-of select="concat($mol_common_name,' ')"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:if test="$lock_name!=''">
            <xsl:element name="fieldFrequencyLock">
              <xsl:attribute name="fieldFrequencyLockName">
                <xsl:value-of select="replace($lock_name, '\s$', '')"/>
              </xsl:attribute>
            </xsl:element>
          </xsl:if>
          <xsl:element name="chemicalShiftStandard">
            <xsl:for-each select="/BMRBx:datablock/BMRBx:sample_componentCategory/BMRBx:sample_component[@sample_id=$sample_id]">
              <xsl:variable name="type"><xsl:value-of select="lower-case(./BMRBx:type)"/></xsl:variable>
              <xsl:variable name="mol_common_name"><xsl:value-of select="./BMRBx:mol_common_name"/></xsl:variable>
              <xsl:if test="$type='reference'">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:choose>
                  <xsl:when test="$mol_common_name='DSS'">
                    <xsl:attribute name="accession">NMR:1000027</xsl:attribute>
                    <xsl:attribute name="name">2,2-Dimethyl-2-silapentane-5-sulfonate</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$mol_common_name='TMS'">
                    <xsl:attribute name="accession">NMR:1000029</xsl:attribute>
                    <xsl:attribute name="name">tetramethylsilane</xsl:attribute>
                  </xsl:when>
                </xsl:choose>
              </xsl:if>
            </xsl:for-each>
          </xsl:element>
          <!-- solventType (primary solute) -->
          <xsl:for-each select="/BMRBx:datablock/BMRBx:sample_componentCategory/BMRBx:sample_component[@sample_id=$sample_id]">
            <xsl:variable name="type"><xsl:value-of select="lower-case(./BMRBx:type)"/></xsl:variable>
            <xsl:if test="$type='solute'">
              <xsl:variable name="mol_common_name"><xsl:value-of select="./BMRBx:mol_common_name"/></xsl:variable>
              <xsl:variable name="concentration_val"><xsl:value-of select="./BMRBx:concentration_val"/></xsl:variable>
              <xsl:variable name="concentration_val_units"><xsl:value-of select="./BMRBx:concentration_val_units"/></xsl:variable>
              <xsl:element name="solventType">
                <xsl:attribute name="cvRef">ChEBI</xsl:attribute>
                <xsl:attribute name="accession">NEED_ACCESSION</xsl:attribute>
                <xsl:attribute name="name"><xsl:value-of select="$chem_comp_name"/></xsl:attribute>
                <xsl:if test="$concentration_val!='' and $concentration_val_units!='' and $concentration_val_units!='na'">
                  <xsl:attribute name="value"><xsl:value-of select="$concentration_val"/></xsl:attribute>
                  <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                  <xsl:choose>
                    <xsl:when test="$concentration_val_units='%'">
                      <xsl:attribute name="unitAccession">UO_0000187</xsl:attribute>
                      <xsl:attribute name="unitName">percent</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$concentration_val_units='mM'">
                      <xsl:attribute name="unitAccession">UO_0000063</xsl:attribute>
                      <xsl:attribute name="unitName">millimolar</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$concentration_val_units='uM'">
                      <xsl:attribute name="unitAccession">UO_0000064</xsl:attribute>
                      <xsl:attribute name="unitName">micromolar</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$concentration_val_units='mg/mL'">
                      <xsl:attribute name="unitAccession">UO_0000052</xsl:attribute>
                      <xsl:attribute name="unitName">milligram per milliliter</xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                </xsl:if>
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
          <!-- solventType (solvent) -->
          <xsl:for-each select="/BMRBx:datablock/BMRBx:sample_componentCategory/BMRBx:sample_component[@sample_id=$sample_id]">
            <xsl:variable name="type"><xsl:value-of select="lower-case(./BMRBx:type)"/></xsl:variable>
            <xsl:if test="$type='solvent'">
              <xsl:variable name="mol_common_name"><xsl:value-of select="./BMRBx:mol_common_name"/></xsl:variable>
              <xsl:variable name="concentration_val"><xsl:value-of select="./BMRBx:concentration_val"/></xsl:variable>
              <xsl:variable name="concentration_val_units"><xsl:value-of select="./BMRBx:concentration_val_units"/></xsl:variable>
              <xsl:element name="solventType">
                <xsl:attribute name="cvRef">ChEBI</xsl:attribute>
                <xsl:choose>
                  <xsl:when test="$mol_common_name='methanol' or $mol_common_name='CD3OD' or $mol_common_name='Methanol-d4'">
                    <xsl:attribute name="accession">CHEBI_17790</xsl:attribute>
                    <xsl:attribute name="name">methanol</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$mol_common_name='Acetone-d6'">
                    <xsl:attribute name="accession">CHEBI_78217</xsl:attribute>
                    <xsl:attribute name="name">acetone d6</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$mol_common_name='DMSO'">
                    <xsl:attribute name="accession">CHEBI_28262</xsl:attribute>
                    <xsl:attribute name="name">dimethyl sulfoxide</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$mol_common_name='ethanol'">
                    <xsl:attribute name="accession">CHEBI_16236</xsl:attribute>
                    <xsl:attribute name="name">ethanol</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$mol_common_name='D2O'">
                    <xsl:attribute name="accession">CHEBI_41981</xsl:attribute>
                    <xsl:attribute name="name">dideuterium oxide</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$mol_common_name='acetone'">
                    <xsl:attribute name="accession">CHEBI_15347</xsl:attribute>
                    <xsl:attribute name="name">acetone</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$mol_common_name='benzene'">
                    <xsl:attribute name="accession">CHEBI_16716</xsl:attribute>
                    <xsl:attribute name="name">benzene</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$mol_common_name='Chloroform-d' or $mol_common_name='CDCl3'">
                    <xsl:attribute name="accession">CHEBI_85365</xsl:attribute>
                    <xsl:attribute name="name">deuterated chloroform</xsl:attribute>
                </xsl:when>
              </xsl:choose>
              <xsl:if test="$concentration_val!='' and $concentration_val_units!='' and $concentration_val_units!='na'">
                <xsl:attribute name="value"><xsl:value-of select="$concentration_val"/></xsl:attribute>
                <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                <xsl:choose>
                  <xsl:when test="$concentration_val_units='%'">
                    <xsl:attribute name="unitAccession">UO_0000187</xsl:attribute>
                    <xsl:attribute name="unitName">percent</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$concentration_val_units='mM'">
                    <xsl:attribute name="unitAccession">UO_0000063</xsl:attribute>
                    <xsl:attribute name="unitName">millimolar</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$concentration_val_units='uM'">
                    <xsl:attribute name="unitAccession">UO_0000064</xsl:attribute>
                    <xsl:attribute name="unitName">micromolar</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$concentration_val_units='mg/mL'">
                    <xsl:attribute name="unitAccession">UO_0000052</xsl:attribute>
                    <xsl:attribute name="unitName">milligram per milliliter</xsl:attribute>
                  </xsl:when>
                </xsl:choose>
              </xsl:if>
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
          <!-- additionalSoluteList -->
          <additionalSoluteList>
            <xsl:for-each select="/BMRBx:datablock/BMRBx:sample_componentCategory/BMRBx:sample_component[@sample_id=$sample_id]">
              <xsl:variable name="type"><xsl:value-of select="lower-case(./BMRBx:type)"/></xsl:variable>
              <xsl:if test="$type!='' and $type!='reference' and $type!='solute' and $type!='solvent' and $type!='buffer'">
                <xsl:variable name="mol_common_name"><xsl:value-of select="./BMRBx:mol_common_name"/></xsl:variable>
                <xsl:variable name="concentration_val"><xsl:value-of select="./BMRBx:concentration_val"/></xsl:variable>
                <xsl:variable name="concentration_val_units"><xsl:value-of select="./BMRBx:concentration_val_units"/></xsl:variable>
                <solute name="{$mol_common_name}">
                  <xsl:if test="$concentration_val!='' and $concentration_val_units!='' and $concentration_val_units!='na'">
                    <xsl:element name="concentrationInSample">
                      <xsl:attribute name="value"><xsl:value-of select="$concentration_val"/></xsl:attribute>
                      <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                      <xsl:choose>
                        <xsl:when test="$concentration_val_units='%'">
                          <xsl:attribute name="unitAccession">UO_0000187</xsl:attribute>
                          <xsl:attribute name="unitName">percent</xsl:attribute>
                        </xsl:when>
                          <xsl:when test="$concentration_val_units='mM'">
                          <xsl:attribute name="unitAccession">UO_0000063</xsl:attribute>
                          <xsl:attribute name="unitName">millimolar</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$concentration_val_units='uM'">
                          <xsl:attribute name="unitAccession">UO_0000064</xsl:attribute>
                          <xsl:attribute name="unitName">micromolar</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$concentration_val_units='mg/mL'">
                          <xsl:attribute name="unitAccession">UO_0000052</xsl:attribute>
                          <xsl:attribute name="unitName">milligram per milliliter</xsl:attribute>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:element>
                  </xsl:if>
                </solute>
              </xsl:if>
            </xsl:for-each>
            </additionalSoluteList>
          <!-- concentrationStandard -->
        </xsl:element>
      </xsl:for-each>
    </sampleList>
  </xsl:template>

  <!-- acquisition -->

  <xsl:template name="acquisition">
    <xsl:element name="acquisition">
      <xsl:choose>
        <!-- acquisition1D -->
        <xsl:when test="$number_of_dimensions='1'">
          <acquisition1D>
            <xsl:element name="acquisitionParameterSet">
              <xsl:call-template name="acquisition_parameter_set"/>
              <xsl:element name="DirectDimensionParameterSet">
                <xsl:call-template name="direct_dimension_parameter_set"/>
              </xsl:element>
            </xsl:element>
            <xsl:call-template name="fid_data"/>
          </acquisition1D>
        </xsl:when>
        <!-- acquisitionMultiD (2D) -->
        <xsl:when test="$number_of_dimensions='2'">
          <acquisitionMultiD>
            <xsl:element name="acquisitionParameterSet">
              <xsl:call-template name="acquisition_parameter_set"/>
              <!--xsl:element name="hadamardParameterSet">
                <xsl:element name="hadamardFrequency">
                </xsl:element>
              </xsl:element-->
              <xsl:element name="directDimensionParameterSet">
                <xsl:call-template name="direct_dimension_parameter_set"/>
              </xsl:element>
              <xsl:element name="encodingScheme">
                <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
                <xsl:attribute name="accession">NEED_ACCESSION</xsl:attribute>
                <xsl:attribute name="name">NEED_NAME</xsl:attribute>
              </xsl:element>
              <xsl:element name="indirectDimensionParameterSet">
                <xsl:call-template name="direct_dimension_parameter_set">
                  <xsl:with-param name="dimension_id">2</xsl:with-param>
                </xsl:call-template>
              </xsl:element>
            </xsl:element>
            <xsl:call-template name="fid_data"/>
          </acquisitionMultiD>
        </xsl:when>
        <!-- acquisitionMultiD (nD: n > 2) -->
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="acquisition_parameter_set">
    <xsl:attribute name="numberOfSteadyStateScans">NEED_NUMBER_OF_STEADY_STATE_SCANS</xsl:attribute>
    <xsl:attribute name="numberOfScans">NEED_NUMBER_OF_SCANS</xsl:attribute>
    <!-- list holder -->
    <xsl:element name="contactRefList">
      <xsl:call-template name="contact_ref_list"/>
    </xsl:element>
    <xsl:variable name="collection_software_rep">
      <xsl:for-each select="BMRBx:datablock/BMRBx:softwareCategory/BMRBx:software">
        <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
        <xsl:variable name="name"><xsl:value-of select="./BMRBx:name"/></xsl:variable>
        <xsl:variable name="task">
          <xsl:for-each select="/BMRBx:datablock/BMRBx:taskCategory/BMRBx:task[@software_id=$id]">
            <xsl:value-of select="concat(lower-case(@task),' ')"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="contains($task,'collection')">
          <xsl:value-of select="concat($name,' ')"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="$collection_software_rep!=''">
      <xsl:element name="softwareRef">
        <xsl:attribute name="ref">
          <xsl:value-of select="substring-before($collection_software_rep,' ')"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:element name="sampleContainer">
      <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
      <xsl:attribute name="accession">NMR:1400132</xsl:attribute>
      <xsl:attribute name="name">NMR sample tube</xsl:attribute>
    </xsl:element>
    <xsl:element name="sampleAcquisitionTemperature">
      <xsl:attribute name="value"><xsl:value-of select="$temperature"/></xsl:attribute>
      <xsl:attribute name="unitCvRef">UO</xsl:attribute>
      <xsl:attribute name="unitAccession">UO_0000012</xsl:attribute>
      <xsl:attribute name="unitName">kelvin</xsl:attribute>
    </xsl:element>
    <!--xsl:element name="solventSuppressionMethod"/--> <!-- CVTerm -->
    <xsl:element name="spinningRate">
      <xsl:attribute name="value">
        <xsl:choose>
          <xsl:when test="$sample_spinning_rate!=''"><xsl:value-of select="$sample_spinning_rate"/></xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="unitCvRef">UO</xsl:attribute>
      <xsl:attribute name="unitAccession">UO_0000106</xsl:attribute>
      <xsl:attribute name="unitName">hertz</xsl:attribute>
    </xsl:element>
    <xsl:element name="relaxationDelay">
      <xsl:attribute name="value">NEED_RELAXATION_DELAY</xsl:attribute>
      <xsl:attribute name="unitCvRef">UO</xsl:attribute>
      <xsl:attribute name="unitAccession">UO_0000010</xsl:attribute>
      <xsl:attribute name="unitName">second</xsl:attribute>
    </xsl:element>
    <xsl:element name="pulseSequence">
      <xsl:element name="userParam">
        <xsl:attribute name="name">Pulse Program</xsl:attribute>
        <xsl:attribute name="value">NEED_PULSE_SEQUENCE</xsl:attribute>
      </xsl:element>
    </xsl:element>
    <xsl:element name="shapedPulseFile">
      <xsl:attribute name="ref">NEED_SHAPED_PULSE_FILE</xsl:attribute>
    </xsl:element>
    <xsl:element name="acquisitionParameterRefList">
      <xsl:choose>
        <xsl:when test="$number_of_dimensions='1'">
          <xsl:element name="acquisitionParameterFileRef">
            <xsl:attribute name="ref">ACQUISITION_FILE</xsl:attribute>
          </xsl:element>
        </xsl:when>
        <xsl:when test="$number_of_dimensions='2'">
          <xsl:element name="acquisitionParameterFileRef">
            <xsl:attribute name="ref">ACQUISITION_FILE</xsl:attribute>
          </xsl:element>
          <xsl:element name="acquisitionParameterFileRef">
            <xsl:attribute name="ref">ACQUISITION2_FILE</xsl:attribute>
          </xsl:element>
        </xsl:when>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="contact_ref_list">
    <xsl:for-each select="BMRBx:datablock/BMRBx:entry_authorCategory/BMRBx:entry_author">
      <xsl:element name="contactRef">
        <xsl:attribute name="ref"><xsl:value-of select="concat('entry_author_',@ordinal)"/></xsl:attribute>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="direct_dimension_parameter_set">
    <xsl:param name="dimension_id">1</xsl:param>
    <xsl:attribute name="decoupled">NEED_DECOUPLED</xsl:attribute>
    <xsl:attribute name="numberOfDataPoints">NEED_NUMBER_OF_DATA_POINTS</xsl:attribute>
    <xsl:element name="decouplingMethod"> <!-- CVTerm -->
    </xsl:element>
    <xsl:element name="acquisitionNucleus">
      <xsl:variable name="atom_type">
        <xsl:for-each select="BMRBx:datablock/BMRBx:spectral_dimCategory/BMRBx:spectral_dim[@id=$dimension_id and @spectral_peak_list_id=$spectral_peak_list_id]">
          <xsl:value-of select="@atom_type"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="atom_isotope_number">
        <xsl:for-each select="BMRBx:datablock/BMRBx:spectral_dimCategory/BMRBx:spectral_dim[@id=$dimension_id and @spectral_peak_list_id=$spectral_peak_list_id]">
          <xsl:value-of select="./BMRBx:atom_isotope_number"/>
        </xsl:for-each>
      </xsl:variable>
      <!-- nmrCV version -->
      <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
      <xsl:choose>
        <xsl:when test="$atom_type='H' and $atom_isotope_number='1'">
          <xsl:attribute name="accession">NMR:1400151</xsl:attribute>
          <xsl:attribute name="name">1H</xsl:attribute>
        </xsl:when>
        <xsl:when test="$atom_type='C' and $atom_isotope_number='13'">
          <xsl:attribute name="accession">NMR:1400154</xsl:attribute>
          <xsl:attribute name="name">13C</xsl:attribute>
        </xsl:when>
        <xsl:when test="$atom_type='N' and $atom_isotope_number='15'">
          <xsl:attribute name="accession">NMR:1000213</xsl:attribute>
          <xsl:attribute name="name">15N</xsl:attribute>
        </xsl:when>
        <xsl:when test="$atom_type='P' and $atom_isotope_number='31'">
          <xsl:attribute name="accession">NMR:1400158</xsl:attribute>
          <xsl:attribute name="name">31P</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="accession">NEED_ACCESSION</xsl:attribute>
          <xsl:attribute name="name">NEED_NAME</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <!-- ChEBI version
      <xsl:attribute name="cvRef">ChEBI</xsl:attribute>
      <xsl:choose>
        <xsl:when test="$atom_type='H'">
          <xsl:attribute name="accession">CHEBI_49637</xsl:attribute>
          <xsl:attribute name="name">hydrogen atom</xsl:attribute>
        </xsl:when>
        <xsl:when test="$atom_type='C'">
          <xsl:attribute name="accession">CHEBI_36928</xsl:attribute>
          <xsl:attribute name="name">carbon-13 atom</xsl:attribute>
        </xsl:when>
        <xsl:when test="$atom_type='N'">
          <xsl:attribute name="accession">CHEBI_36934</xsl:attribute>
          <xsl:attribute name="name">nitrogen-15 atom</xsl:attribute>
        </xsl:when>
        <xsl:when test="$atom_type='P'">
          <xsl:attribute name="accession">CHEBI_37971</xsl:attribute>
          <xsl:attribute name="name">phosphorus-31 atom</xsl:attribute>
        </xsl:when>
      </xsl:choose-->
    </xsl:element>
    <xsl:element name="effectiveExcitationField">
      <xsl:attribute name="value">NEED_EFFECTIVE_EXCITATION_FIELD</xsl:attribute>
      <xsl:attribute name="unitCvRef">UO</xsl:attribute>
      <xsl:attribute name="unitAccession">UO_0000325</xsl:attribute>
      <xsl:attribute name="unitName">megaHertz</xsl:attribute>
    </xsl:element>
    <xsl:element name="sweepWidth">
      <!--xsl:variable name="sweep_width">
        <xsl:for-each select="BMRBx:datablock/BMRBx:spectral_dimCategory/BMRBx:spectral_dim[@id=$dimension_id and @spectral_peak_list_id=$spectral_peak_list_id]">
          <xsl:value-of select="./BMRBx:sweep_width"/>
        </xsl:for-each>
      </xsl:variable-->
      <xsl:attribute name="value">NEED_SWEEP_WIDTH</xsl:attribute>
      <xsl:attribute name="unitCvRef">UO</xsl:attribute>
      <xsl:attribute name="unitAccession">UO_0000106</xsl:attribute>
      <xsl:attribute name="unitName">hertz</xsl:attribute>
    </xsl:element>
    <xsl:element name="pulseWidth">
      <xsl:attribute name="value">NEED_PULSE_WIDTH</xsl:attribute>
      <xsl:attribute name="unitCvRef">UO</xsl:attribute>
      <xsl:attribute name="unitAccession">UO_0000029</xsl:attribute>
      <xsl:attribute name="unitName">microsecond</xsl:attribute>
    </xsl:element>
    <xsl:element name="irradiationFrequency">
      <xsl:attribute name="value">NEED_IRRADIATION_FREQUENCY</xsl:attribute>
      <xsl:attribute name="unitCvRef">UO</xsl:attribute>
      <xsl:attribute name="unitAccession">UO_0000325</xsl:attribute>
      <xsl:attribute name="unitName">megaHertz</xsl:attribute>
    </xsl:element>
    <xsl:element name="decouplingNucleus"> <!-- CVTerm -->
    </xsl:element>
    <!-- uniform sampling -->
    <samplingStrategy cvRef="NMRCV" accession="NMR:1000349" name="uniform sampling"/>
    <!-- non-uniform sampling
    <xsl:element name="samplingTimePoints">
      <xsl:attribute name="compressed">
      </xsl:attribute>
      <xsl:attribute name="encodedLength">
      </xsl:attribute>
      <xsl:attribute name="byteFormat">
      </xsl:attribute>
    </xsl:element-->
  </xsl:template>

  <xsl:template name="fid_data">
    <xsl:element name="fidData"><xsl:attribute name="compressed">true</xsl:attribute><xsl:attribute name="encodedLength">NEED_ENCODED_LENGTH</xsl:attribute><xsl:attribute name="byteFormat">complex128</xsl:attribute>NEED_FID_DATA</xsl:element>
  </xsl:template>

  <!-- spectrumList -->

  <xsl:template name="spectrum_list">
    <xsl:if test="$spectral_peak_list_id!=''">
      <spectrumList>
        <xsl:choose>
          <!-- spectrum1D -->
          <xsl:when test="$number_of_dimensions='1'">
            <spectrum1D>
              <!-- spectrumType -->
              <xsl:attribute name="numberOfDataPoints">0</xsl:attribute> <!-- null data -->
              <xsl:attribute name="id"><xsl:value-of select="$experiment_id"/></xsl:attribute>
              <xsl:attribute name="name"><xsl:value-of select="$experiment_name"/></xsl:attribute>
              <!-- list holder -->
              <xsl:element name="processingSoftwareRefList">
                <xsl:call-template name="processing_software_list"/>
              </xsl:element>
              <xsl:element name="processingParameterFileRefList">
                <xsl:element name="processingParameterFileRef">
                  <xsl:attribute name="ref">PROCESSING_FILE</xsl:attribute>
                </xsl:element>
              </xsl:element>
              <spectrumDataArray compressed="false" encodedLength="0" byteFormat=""/> <!-- no content -->
              <xsl:element name="xAxis">
                <xsl:attribute name="unitAccession">UO_0000169</xsl:attribute>
                <xsl:attribute name="unitName">parts per million</xsl:attribute>
                <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                <xsl:attribute name="startValue">NEED_START_VALUE</xsl:attribute>
                <xsl:attribute name="endValue">NEED_END_VALUE</xsl:attribute>
              </xsl:element>
              <!--xsl:element name="processingParameterSet">
                <xsl:element name="postAcquisitionSolventSuppressionMethod"> - CVTerm -
                </xsl:element>
                <xsl:element name="calibrationCompound"> - CVTerm -
                </xsl:element>
                <xsl:element name="dataTransformationMethod"> - CVTerm -
                </xsl:element>
              </xsl:element-->
              <!-- firstDimensionProcessingParameterSet -->
              <xsl:element name="firstDimensionProcessingParameterSet">
                <xsl:element name="zeroOrderPhaseCorrection">
                  <xsl:attribute name="value">NEED_VALUE</xsl:attribute>
                  <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                  <xsl:attribute name="unitAccession">UO_0000185</xsl:attribute>
                  <xsl:attribute name="unitName">degree</xsl:attribute>
                </xsl:element>
                <xsl:element name="firstOrderPhaseCorrection">
                  <xsl:attribute name="value">NEED_VALUE</xsl:attribute>
                  <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                  <xsl:attribute name="unitAccession">UO_0000185</xsl:attribute>
                  <xsl:attribute name="unitName">degree</xsl:attribute>
                </xsl:element>
                <!--xsl:element name="calibrationReferenceShift">
                </xsl:element>
                <xsl:element name="spectralDenoisingMethod"> - CVTerm -
                </xsl:element>
                - list holder -
                <xsl:element name="windowFunction">
                  <xsl:element name="windowFunctionMethod"> - CVTerm -
                  </xsl:element>
                  <xsl:element name="windowFunctionParameter"> - CVParam -
                  </xsl:element>
                </xsl:element>
                <xsl:element name="baselineCorrectionMethod"> - CVTerm -
                </xsl:element-->
              </xsl:element>
            </spectrum1D>
          </xsl:when>
          <!-- spectrumMultiD (2D) -->
          <xsl:when test="$number_of_dimensions='2'">
            <spectrumMultiD>
              <!-- spectrumType -->
              <xsl:attribute name="numberOfDataPoints">0</xsl:attribute> <!-- null data -->
              <xsl:attribute name="id"><xsl:value-of select="$experiment_id"/></xsl:attribute>
              <xsl:attribute name="name"><xsl:value-of select="$experiment_name"/></xsl:attribute>
              <!-- list holder -->
              <xsl:element name="processingSoftwareRefList">
                <xsl:call-template name="processing_software_list"/>
              </xsl:element>
              <xsl:element name="processingParameterFileRefList">
                <xsl:element name="processingParameterFileRef">
                  <xsl:attribute name="ref">PROCESSING_FILE</xsl:attribute>
                </xsl:element>
                <xsl:element name="processingParameterFileRef">
                  <xsl:attribute name="ref">PROCESSING2_FILE</xsl:attribute>
                </xsl:element>
              </xsl:element>
              <spectrumDataArray compressed="false" encodedLength="0" byteFormat=""/> <!-- no content -->
              <xsl:element name="xAxis">
                <xsl:attribute name="unitAccession">UO_0000169</xsl:attribute>
                <xsl:attribute name="unitName">parts per million</xsl:attribute>
                <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                <xsl:attribute name="startValue">NEED_START_VALUE</xsl:attribute>
                <xsl:attribute name="endValue">NEED_END_VALUE</xsl:attribute>
              </xsl:element>
              <!--xsl:element name="processingParameterSet">
                <xsl:element name="postAcquisitionSolventSuppressionMethod"> - CVTerm -
                </xsl:element>
                <xsl:element name="calibrationCompound"> - CVTerm -
                </xsl:element>
                <xsl:element name="dataTransformationMethod"> - CVTerm -
                </xsl:element>
              </xsl:element-->
              <!-- firstDimensionProcessingParameterSet -->
              <xsl:element name="firstDimensionProcessingParameterSet">
                <xsl:element name="zeroOrderPhaseCorrection">
                  <xsl:attribute name="value">NEED_VALUE</xsl:attribute>
                  <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                  <xsl:attribute name="unitAccession">UO_0000185</xsl:attribute>
                  <xsl:attribute name="unitName">degree</xsl:attribute>
                </xsl:element>
                <xsl:element name="firstOrderPhaseCorrection">
                  <xsl:attribute name="value">NEED_VALUE</xsl:attribute>
                  <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                  <xsl:attribute name="unitAccession">UO_0000185</xsl:attribute>
                  <xsl:attribute name="unitName">degree</xsl:attribute>
                </xsl:element>
                <!--xsl:element name="calibrationReferenceShift">
                </xsl:element>
                <xsl:element name="spectralDenoisingMethod"> - CVTerm -
                </xsl:element>
                - list holder -
                <xsl:element name="windowFunction">
                  <xsl:element name="windowFunctionMethod"> - CVTerm -
                  </xsl:element>
                  <xsl:element name="windowFunctionParameter"> - CVParam -
                  </xsl:element>
                </xsl:element>
                <xsl:element name="baselineCorrectionMethod"> - CVTerm -
                </xsl:element-->
              </xsl:element>
              <!-- higherDimensionProcessingParameterSet (secondDimension) -->
              <xsl:element name="higherDimensionProcessingParameterSet">
                <xsl:element name="zeroOrderPhaseCorrection">
                  <xsl:attribute name="value">NEED_VALUE</xsl:attribute>
                  <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                  <xsl:attribute name="unitAccession">UO_0000185</xsl:attribute>
                  <xsl:attribute name="unitName">degree</xsl:attribute>
                </xsl:element>
                <xsl:element name="firstOrderPhaseCorrection">
                  <xsl:attribute name="value">NEED_VALUE</xsl:attribute>
                  <xsl:attribute name="unitCvRef">UO</xsl:attribute>
                  <xsl:attribute name="unitAccession">UO_0000185</xsl:attribute>
                  <xsl:attribute name="unitName">degree</xsl:attribute>
                </xsl:element>
                <!--xsl:element name="calibrationReferenceShift">
                </xsl:element>
                <xsl:element name="spectralDenoisingMethod"> - CVTerm -
                </xsl:element>
                - list holder -
                <xsl:element name="windowFunction">
                  <xsl:element name="windowFunctionMethod"> - CVTerm -
                  </xsl:element>
                  <xsl:element name="windowFunctionParameter"> - CVParam -
                  </xsl:element>
                </xsl:element>
                <xsl:element name="baselineCorrectionMethod"> - CVTerm -
                </xsl:element-->
              </xsl:element>
              <!-- projected3DProcessingParameterSet -
              <xsl:element name="projected3DProcessingParamaterSet">
                <xsl:attribute name="projectionAngle">
                </xsl:attribute>
                <xsl:attribute name="positiveProjectionMethod">
                </xsl:attribute>
                <xsl:element name="zeroOrderPhaseCorrection">
                </xsl:element>
                <xsl:element name="firstOrderPhaseCorrection">
                </xsl:element>
                <xsl:element name="calibrationReferenceShift">
                </xsl:element>
                <xsl:element name="spectralDenoisingMethod"> - CVTerm -
                </xsl:element>
                - list holder -
                <xsl:element name="windowFunction">
                  <xsl:element name="windowFunctionMethod"> - CVTerm -
                  </xsl:element>
                  <xsl:element name="windowFunctionParameter"> - CVParam -
                  </xsl:element>
                </xsl:element>
                <xsl:element name="baselineCorrectionMethod"> - CVTerm -
                </xsl:element>
              </xsl:element-->
            </spectrumMultiD>
          </xsl:when>
          <!-- spectrumMultiD (nD: n > 2) -->
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </spectrumList>
    </xsl:if>
  </xsl:template>

  <xsl:template name="processing_software_list">
    <xsl:for-each select="BMRBx:datablock/BMRBx:softwareCategory/BMRBx:software">
      <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
      <xsl:variable name="name"><xsl:value-of select="./BMRBx:name"/></xsl:variable>
      <xsl:variable name="task">
        <xsl:for-each select="/BMRBx:datablock/BMRBx:taskCategory/BMRBx:task[@software_id=$id]">
          <xsl:value-of select="concat(lower-case(@task),' ')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="contains($task,'processing')">
        <softwareRef ref="{$name}"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- spectrumAnnotationList -->

  <xsl:template name="spectrum_annotation_list">
    <xsl:if test="$spectral_peak_list_id!=''">
      <spectrumAnnotationList>
        <!-- resonance assignment of a pure compound -->
        <xsl:element name="atomAssignment">
          <xsl:attribute name="spectrumRef"><xsl:value-of select="$experiment_id"/></xsl:attribute>
          <xsl:element name="chemicalCompound">
            <xsl:call-template name="chem_comp"/>
          </xsl:element>
          <!-- list holder -->
          <xsl:element name="atomAssignmentList">
            <xsl:call-template name="spectral_peak"/>
          </xsl:element>
        </xsl:element>
        <!-- quantification and identification of compounds from mixuture
        <xsl:element name="quantification">
          <xsl:element name="quantificationMethod"> - CVTerm -
          </xsl:element>
          - list holder -
          <xsl:element name="quantifiedCompoundList">
            <xsl:element name="quantifiedCompound">
              <xsl:call-template name="chem_comp"/>
              <xsl:element name="concentration">
              </xsl:element>
              - list holder -
              <xsl:element name="clusterList">
                <xsl:element name="cluster">
                  <xsl:attribute name="center">
                  </xsl:attribute>
                  <xsl:attribute name="shift">
                  </xsl:attribute>
                  - list holder -
                  <xsl:element name="peakList">
                    <xsl:element name="peak">
                      <xsl:attribute name="center">
                      </xsl:attribute>
                      <xsl:attribute name="amplitude">
                      </xsl:attribute>
                      <xsl:attribute name="width">
                      </xsl:attribute>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
              - alternative list holder of clusterList -
              <xsl:element name="peakList">
                <xsl:element name="peak">
                  <xsl:attribute name="center">
                  </xsl:attribute>
                  <xsl:attribute name="amplitude">
                  </xsl:attribute>
                  <xsl:attribute name="width">
                  </xsl:attribute>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element-->
      </spectrumAnnotationList>
    </xsl:if>
  </xsl:template>

  <xsl:template name="chem_comp">
    <xsl:attribute name="name"><xsl:value-of select="$chem_comp_name"/></xsl:attribute>
    <xsl:element name="identifierList">
      <!-- list holder -->
      <xsl:element name="identifier">
        <xsl:attribute name="cvRef">ChEBI</xsl:attribute>
        <xsl:attribute name="accession">NEED_ACCESSION</xsl:attribute>
        <xsl:attribute name="name"><xsl:value-of select="$chem_comp_name"/></xsl:attribute>
      </xsl:element>
      <xsl:call-template name="chem_comp_db_link"/>
    </xsl:element>
    <xsl:element name="structure">
      <!-- list holder -->
      <xsl:element name="atomList">
        <xsl:call-template name="chem_comp_atom"/>
      </xsl:element>
      <!-- list holder -->
      <xsl:element name="bondList">
        <xsl:call-template name="chem_comp_bond"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:variable name="chem_comp_db_link_rep">
    <!-- PubChem CID should be selected first -->
    <xsl:for-each select="/BMRBx:datablock/BMRBx:chem_comp_db_linkCategory/BMRBx:chem_comp_db_link[BMRBx:author_supplied='yes']">
      <xsl:variable name="database_code"><xsl:value-of select="lower-case(@database_code)"/></xsl:variable>
      <xsl:variable name="accession_code"><xsl:value-of select="@accession_code"/></xsl:variable>
      <xsl:variable name="accession_code_type"><xsl:value-of select="BMRBx:accession_code_type"/></xsl:variable>
      <xsl:if test="$database_code='pubchem' and $accession_code_type='cid'">
        <xsl:call-template name="uri_of">
          <xsl:with-param name="database_code">pubchem</xsl:with-param>
          <xsl:with-param name="accession_code"><xsl:value-of select="$accession_code"/></xsl:with-param>
          <xsl:with-param name="accession_code_type">cid</xsl:with-param>
        </xsl:call-template>
        <xsl:value-of select="' '"/>
      </xsl:if>
    </xsl:for-each>
    <!--  Other author supplied URLs are available -->
    <xsl:for-each select="/BMRBx:datablock/BMRBx:chem_comp_db_linkCategory/BMRBx:chem_comp_db_link[BMRBx:author_supplied='yes']">
      <xsl:call-template name="uri_of">
        <xsl:with-param name="database_code"><xsl:value-of select="lower-case(@database_code)"/></xsl:with-param>
        <xsl:with-param name="accession_code"><xsl:value-of select="@accession_code"/></xsl:with-param>
        <xsl:with-param name="accession_code_type"><xsl:value-of select="./BMRBx:accession_code_type"/></xsl:with-param>
      </xsl:call-template>
      <xsl:value-of select="' '"/>
    </xsl:for-each>
    <!-- For a case author supplied URL is not available -->
    <xsl:value-of select="concat($metabolomics_page_url,' ')"/>
  </xsl:variable>

  <xsl:template name="chem_comp_db_link">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:chem_comp_db_linkCategory/BMRBx:chem_comp_db_link">
      <xsl:variable name="database_code"><xsl:value-of select="lower-case(@database_code)"/></xsl:variable>
      <xsl:variable name="accession_code"><xsl:value-of select="@accession_code"/></xsl:variable>
      <xsl:variable name="accession_code_type"><xsl:value-of select="./BMRBx:accession_code_type"/></xsl:variable>
      <xsl:variable name="uri_of">
        <xsl:call-template name="uri_of">
          <xsl:with-param name="database_code"><xsl:value-of select="$database_code"/></xsl:with-param>
          <xsl:with-param name="accession_code"><xsl:value-of select="$accession_code"/></xsl:with-param>
          <xsl:with-param name="accession_code_type"><xsl:value-of select="$accession_code_type"/></xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$uri_of!=''">
        <xsl:element name="databaseIdentifier">
          <xsl:attribute name="identifier">
            <xsl:call-template name="acc_of">
              <xsl:with-param name="database_code"><xsl:value-of select="$database_code"/></xsl:with-param>
              <xsl:with-param name="accession_code"><xsl:value-of select="$accession_code"/></xsl:with-param>
              <xsl:with-param name="accession_code_type"><xsl:value-of select="$accession_code_type"/></xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="URI"><xsl:value-of select="$uri_of"/></xsl:attribute>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="acc_of">
    <xsl:param name="database_code"/>
    <xsl:param name="accession_code"/>
    <xsl:param name="accession_code_type"/>
    <xsl:choose>
      <xsl:when test="$database_code='sigma'">
        <xsl:choose>
          <xsl:when test="ends-with($accession_code,'_SIGMA')">
            <xsl:value-of select="$accession_code"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($accession_code,'_SIGMA')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$database_code='sigma-aldrich'">
        <xsl:choose>
          <xsl:when test="ends-with($accession_code,'_SIGMA')">
            <xsl:value-of select="$accession_code"/>
          </xsl:when>
          <xsl:when test="ends-with($accession_code,'_ALDRICH')">
            <xsl:value-of select="$accession_code"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$accession_code"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$database_code='pubchem'">
        <xsl:if test="$accession_code_type='sid'">
          <xsl:value-of select="concat('SID',$accession_code)"/>
        </xsl:if>
        <xsl:if test="$accession_code_type='cid'">
          <xsl:value-of select="concat('CID',$accession_code)"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$accession_code"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="uri_of">
    <xsl:param name="database_code"/>
    <xsl:param name="accession_code"/>
    <xsl:param name="accession_code_type"/>
    <xsl:choose>
      <xsl:when test="$database_code='chemdb'">
        <xsl:value-of select="concat($chemdb,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='comparative toxicogenomics database'">
        <xsl:value-of select="concat($ctd,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='um-ddb'">
        <xsl:value-of select="concat($bbd,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='mmcd'">
        <xsl:value-of select="concat($mmcd,$accession_code)"/>
      </xsl:when>
      <xsl:when test="starts-with($database_code,'nist')">
        <xsl:value-of select="concat($nist,$inchi_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='chemspider'">
        <xsl:value-of select="replace($chemspider.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='chebi'">
        <xsl:value-of select="concat($chebi,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='iuphar-db'">
        <xsl:value-of select="concat($iuphar-db,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='hmdb' or $database_code='811'">
        <xsl:value-of select="concat($hmdb,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='kegg'">
        <xsl:value-of select="concat($kegg,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='leadscope'">
        <xsl:value-of select="concat($leadscope,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='lipidmaps'">
        <xsl:value-of select="concat($lipidmaps,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='sigma'">
        <xsl:value-of select="concat($sigma,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='sigma-aldrich'">
        <xsl:choose>
          <xsl:when test="ends-with($accession_code,'_SIGMA')">
            <xsl:value-of select="concat($sigma,replace($accession_code,'_SIGMA',''))"/>
          </xsl:when>
          <xsl:when test="ends-with($accession_code,'_ALDRICH')">
            <xsl:value-of select="concat($aldrich,replace($accession_code,'_ALDRICH',''))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="replace($pubchem.substance.search,'###',$accession_code)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$database_code='specs'">
        <xsl:value-of select="concat($specs,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='tci'">
        <xsl:value-of select="concat($tci,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='zinc'">
        <xsl:value-of select="concat($zinc,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='biocyc'">
        <xsl:value-of select="concat($biocyc,$accession_code)"/>
      </xsl:when>
      <xsl:when test="starts-with($database_code,'cas')">
        <xsl:value-of select="concat($cas,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='niaid'">
        <xsl:value-of select="concat($niaid,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='bdbm'">
        <xsl:value-of select="concat($bdbm,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='drugbank'">
        <xsl:value-of select="concat($drugbank,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='chembl'">
        <xsl:value-of select="concat($chembl,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='caswell no.'">
        <xsl:value-of select="replace($pubchem.caswell.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='ccris'">
        <xsl:value-of select="replace($pubchem.ccris.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='epa dsstox'">
        <xsl:value-of select="replace($pubchem.dsstox.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="starts-with($database_code,'ec')">
        <xsl:value-of select="replace($pubchem.ec.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='einecs'">
        <xsl:value-of select="replace($pubchem.einecs.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='epa pesticide chemical code'">
        <xsl:value-of select="replace($pubchem.epa.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="starts-with($database_code,'fema')">
        <xsl:value-of select="replace($pubchem.fema.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='hsdb'">
        <xsl:value-of select="replace($pubchem.hsdb.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='nsc'">
        <xsl:value-of select="replace($pubchem.nsc.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='beilstein handbook reference'">
        <xsl:value-of select="replace($pubchem.bhr.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='iccb-longwood/nsrb screening facility, harvard medical school' or $database_code='chembank' or $database_code='ambinter' or $database_code='center for chemical genomics, university of michigan' or $database_code='bidd' or $database_code='structural genomics consortium' or $database_code='pdsp' or $database_code='805'or $database_code='nih clinical collection' or $database_code='mlsmr' or $database_code='mtdp' or $database_code='ncgc' or $database_code='emory university molecular libraries screening center' or starts-with($database_code,'mdl')">
        <xsl:value-of select="replace($pubchem.substance.search,'###',$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='biological magnetic resonance data bank (bmrb)'">
        <xsl:value-of select="concat($bmrb.metabolomics,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='pdb'">
        <xsl:value-of select="concat($pdb.ligand,$accession_code)"/>
      </xsl:when>
      <xsl:when test="$database_code='pubchem'">
        <xsl:if test="$accession_code_type='cid'">
          <xsl:value-of select="concat($pubchem.compound,$accession_code)"/>
        </xsl:if>
        <xsl:if test="$accession_code_type='sid'">
          <xsl:value-of select="concat($pubchem.substance,$accession_code)"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="chem_comp_atom">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:chem_comp_atomCategory/BMRBx:chem_comp_atom">
      <xsl:element name="atom">
        <xsl:attribute name="id"><xsl:value-of select="@atom_id"/></xsl:attribute>
        <xsl:attribute name="elementType"><xsl:value-of select="./BMRBx:type_symbol"/></xsl:attribute>
        <xsl:attribute name="x"><xsl:value-of select="./BMRBx:drawing_2d_coord_x"/></xsl:attribute>
        <xsl:attribute name="y"><xsl:value-of select="./BMRBx:drawing_2d_coord_y"/></xsl:attribute>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="chem_comp_bond">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:chem_comp_bondCategory/BMRBx:chem_comp_bond">
      <xsl:variable name="value_order"><xsl:value-of select="./BMRBx:value_order"/></xsl:variable>
      <xsl:element name="bond">
        <xsl:attribute name="atomRefs"><xsl:value-of select="concat(./BMRBx:atom_id_1,' ',./BMRBx:atom_id_2)"/></xsl:attribute>
        <xsl:attribute name="order">
          <xsl:choose>
            <xsl:when test="$value_order='SING'">1</xsl:when>
            <xsl:when test="$value_order='DOUB'">2</xsl:when>
            <xsl:when test="$value_order='TRIP'">3</xsl:when>
            <xsl:when test="$value_order='AROM'">1.5</xsl:when>
          </xsl:choose>
        </xsl:attribute>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="spectral_peak">
    <xsl:choose>
      <xsl:when test="$peak_char_count!='0'">
        <xsl:call-template name="spectral_peak_char"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="spectral_peak_no_char"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="spectral_peak_char">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:peak_charCategory/BMRBx:peak_char[@spectral_peak_list_id=$spectral_peak_list_id]">
      <xsl:variable name="peak_id"><xsl:value-of select="@peak_id"/></xsl:variable>
      <xsl:variable name="spectral_dim_id"><xsl:value-of select="@spectral_dim_id"/></xsl:variable>
      <xsl:variable name="chem_shift_val"><xsl:value-of select="./BMRBx:chem_shift_val"/></xsl:variable>
      <xsl:variable name="coupling_pattern"><xsl:value-of select="./BMRBx:coupling_pattern"/></xsl:variable>
      <xsl:element name="multiplet">
        <xsl:attribute name="center"><xsl:value-of select="$chem_shift_val"/></xsl:attribute>
        <xsl:variable name="assigned_atom_ids">
          <xsl:for-each select="/BMRBx:datablock/BMRBx:assigned_peak_chem_shiftCategory/BMRBx:assigned_peak_chem_shift[@peak_id=$peak_id and @spectral_dim_id=$spectral_dim_id and @spectral_peak_list_id=$spectral_peak_list_id]">
            <xsl:variable name="atom_id"><xsl:value-of select="./BMRBx:atom_id"/></xsl:variable>
            <xsl:value-of select="concat($atom_id,' ')"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:element name="atoms">
          <xsl:attribute name="atomRefs">
              <xsl:value-of select="replace($assigned_atom_ids, '\s$', '')"/>
          </xsl:attribute>
        </xsl:element>
        <xsl:element name="multiplicity">
          <xsl:choose>
            <xsl:when test="$coupling_pattern='d' or $coupling_pattern='LR' or $coupling_pattern='1JCH'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000184</xsl:attribute>
              <xsl:attribute name="name">doublet feature</xsl:attribute>
            </xsl:when>
            <xsl:when test="$coupling_pattern='dd'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000192</xsl:attribute>
              <xsl:attribute name="name">doublet of doublets feature</xsl:attribute>
            </xsl:when>
            <xsl:when test="$coupling_pattern='ddd' or $coupling_pattern='dm' or $coupling_pattern='hpt' or $coupling_pattern='m' or $coupling_pattern='qd' or $coupling_pattern='sxt'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1400305</xsl:attribute>
              <xsl:attribute name="name">multiplet feature</xsl:attribute>
            </xsl:when>
            <xsl:when test="$coupling_pattern='dt'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000196</xsl:attribute>
              <xsl:attribute name="name">doublet of triplets</xsl:attribute>
            </xsl:when>
            <xsl:when test="$coupling_pattern='q'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000186</xsl:attribute>
              <xsl:attribute name="name">quatruplet feature</xsl:attribute>
            </xsl:when>
            <xsl:when test="$coupling_pattern='qn'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000195</xsl:attribute>
              <xsl:attribute name="name">quintet feature</xsl:attribute>
            </xsl:when>
            <xsl:when test="$coupling_pattern='s'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000194</xsl:attribute>
              <xsl:attribute name="name">singlet feature</xsl:attribute>
            </xsl:when>
            <xsl:when test="$coupling_pattern='t'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000185</xsl:attribute>
              <xsl:attribute name="name">triplet feature</xsl:attribute>
            </xsl:when>
            <xsl:when test="$coupling_pattern='td'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000197</xsl:attribute>
              <xsl:attribute name="name">triplet of douplets</xsl:attribute>
            </xsl:when>
            <xsl:when test="$coupling_pattern='tt'">
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000198</xsl:attribute>
              <xsl:attribute name="name">triplet of triplets</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
              <xsl:attribute name="accession">NMR:1000194</xsl:attribute>
              <xsl:attribute name="name">singlet feature</xsl:attribute>
            </xsl:otherwise>
<!--
   d    doublet
   dd    'doublet of doublets'
   ddd    'doublet of doublets of doublets'
   dm    'doublet of multiplets'
   dt    'doublet of triplets'
   hpt    heptet (spetet)
   m    multiplet
   q    quartet
   qd    'quartet of doublets'
   qn    quintet
   s    singlet
   sxt    sextet
   t    triplet
   td    'triplet of doublets'
   tt    'triplet of triplets'
   LR    'long-range coupling'
   1JCH    'one J carbon-proton couplings'
-->
          </xsl:choose>
        </xsl:element>
        <!-- list holder -->
        <xsl:call-template name="spectral_transition">
          <xsl:with-param name="spectral_dim_id"><xsl:value-of select="$spectral_dim_id"/></xsl:with-param>
          <xsl:with-param name="chem_shift_center_val"><xsl:value-of select="$chem_shift_val"/></xsl:with-param>
          <xsl:with-param name="chem_shift_center_val_err">0.3</xsl:with-param>
        </xsl:call-template>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="spectral_transition">
    <xsl:param name="spectral_dim_id"/>
    <xsl:param name="chem_shift_center_val"/>
    <xsl:param name="chem_shift_center_val_err"/>
    <xsl:variable name="spectral_transition_ids">
      <xsl:for-each select="/BMRBx:datablock/BMRBx:spectral_transition_charCategory/BMRBx:spectral_transition_char[@spectral_dim_id=$spectral_dim_id and @spectral_peak_list_id=$spectral_peak_list_id]">
        <xsl:variable name="chem_shift_val"><xsl:value-of select="./BMRBx:chem_shift_val"/></xsl:variable>
        <xsl:if test="abs(number($chem_shift_val)-number($chem_shift_center_val))&lt;number($chem_shift_center_val_err)">
          <xsl:value-of select="concat(@spectral_transition_id,' ')"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="$spectral_transition_ids!=''">
      <xsl:element name="peakList">
        <xsl:for-each select="/BMRBx:datablock/BMRBx:spectral_transition_charCategory/BMRBx:spectral_transition_char[@spectral_dim_id=$spectral_dim_id and @spectral_peak_list_id=$spectral_peak_list_id]">
          <xsl:variable name="spectral_transition_id"><xsl:value-of select="@spectral_transition_id"/></xsl:variable>
          <xsl:variable name="chem_shift_val"><xsl:value-of select="./BMRBx:chem_shift_val"/></xsl:variable>
          <xsl:variable name="line_width_val"><xsl:value-of select="./BMRBx:line_width_val"/></xsl:variable>
          <xsl:if test="abs(number($chem_shift_val)-number($chem_shift_center_val))&lt;number($chem_shift_center_val_err)">
            <xsl:element name="peak">
              <xsl:attribute name="center"><xsl:value-of select="$chem_shift_val"/></xsl:attribute>
              <xsl:variable name="intensity_val">
                <xsl:for-each select="/BMRBx:datablock/BMRBx:spectral_transition_general_charCategory/BMRBx:spectral_transition_general_char[@spectral_transition_id=$spectral_transition_id and @spectral_peak_list_id=$spectral_peak_list_id]">
                  <xsl:value-of select="@intensity_val"/>
                </xsl:for-each>
              </xsl:variable>
              <xsl:if test="$intensity_val!=''">
                <xsl:attribute name="amplitude"><xsl:value-of select="$intensity_val"/></xsl:attribute>
              </xsl:if>
              <xsl:if test="$line_width_val!=''">
                <xsl:attribute name="width"><xsl:value-of select="$line_width_val"/></xsl:attribute>
              </xsl:if>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="spectral_peak_no_char">
    <xsl:for-each select="/BMRBx:datablock/BMRBx:spectral_transition_charCategory/BMRBx:spectral_transition_char[@spectral_peak_list_id=$spectral_peak_list_id]">
      <xsl:variable name="spectral_transition_id"><xsl:value-of select="@spectral_transition_id"/></xsl:variable>
      <xsl:variable name="spectral_dim_id"><xsl:value-of select="@spectral_dim_id"/></xsl:variable>
      <xsl:variable name="chem_shift_val"><xsl:value-of select="./BMRBx:chem_shift_val"/></xsl:variable>
      <xsl:element name="multiplet">
        <xsl:attribute name="center"><xsl:value-of select="$chem_shift_val"/></xsl:attribute>
        <xsl:element name="atoms">
          <xsl:attribute name="atomRefs"/>
        </xsl:element>
        <xsl:element name="multiplicity">
          <xsl:attribute name="cvRef">NMRCV</xsl:attribute>
          <xsl:attribute name="accession">NMR:1000194</xsl:attribute>
          <xsl:attribute name="name">singlet feature</xsl:attribute>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[@xsi:nil='true']"/>
  <xsl:template match="*|text()|@*"/>

</xsl:stylesheet>
