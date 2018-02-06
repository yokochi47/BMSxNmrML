#!/bin/bash

#MAXPROCS=`cat /proc/cpuinfo 2> /dev/null | grep 'cpu cores' | uniq | sed 's/\s//g' | cut -d ':' -f 2`
MAXPROCS=`cat /proc/cpuinfo 2> /dev/null | grep 'cpu cores' | wc -l`

if [ $MAXPROCS = 0 ] ; then
 MAXPROCS=1
fi

DB_NAME=bmse

SRC_DIR=bms_xml_doc

weekday=`date -u +"%w"`

if [ $weekday -ge 1 ] && [ $weekday -le 4 ] ; then
 rsync -av --delete rsync://bmrbpub.protein.osaka-u.ac.jp/bmrb-xml/$SRC_DIR .
fi

xml_file_total=xml_file_total

updated=`find $SRC_DIR/* -iname "*.xml.gz" -mtime -4 | wc -l`

if [ $updated = 0 ] || [ ! -e $xml_file_total ] ; then

 last=0

 if [ -e $xml_file_total ] ; then
  last=`cat $xml_file_total`
 fi

 total=`find $SRC_DIR/* -name '*.xml.gz' | wc -l`

 if [ $total = $last ] ; then
  echo $DB_NAME is update.
 else
  echo $total > $xml_file_total
 fi

fi

RAW_DIR=bms_xml_raw

mkdir -p $RAW_DIR

errs=0

for file in `ls $SRC_DIR/bmse*.xml.gz 2> /dev/null`
do

 BASENAME=`basename $file .xml.gz`
 XML_ZIP=$SRC_DIR/$BASENAME.xml.gz
 XML_DOC=$RAW_DIR/$BASENAME.xml

 if [ -e $XML_ZIP ] && [ ! -e $XML_DOC ] ; then

  cp -f $XML_ZIP $RAW_DIR

  gunzip -f $XML_DOC.gz

  if [ $? = 0 ] ; then

    echo -n .

  else

   echo -e "${red}$BASENAME.xml failed.${normal}"
   let errs++

  fi

 fi

done

NMRML_XSD=schema/nmrML.xsd
CHEBI_OWL_IDX=schema/chebi_luceneidx

if [ ! -d $CHEBI_OWL_IDX ] ; then

 cd schema
 ./chebi_luceneidx.sh
 cd ..

fi

MIRROR_SITE=osaka

SAXON_JAR_FILE=extlibs/saxon9he.jar

EXT_EXP_ID_XSLT_CODE=schema/ext_exp_id.xsl
EXT_EXP_NAME_XSLT_CODE=schema/ext_exp_name.xsl
EXT_CHEM_COMP_XSLT_CODE=schema/ext_chem_comp.xsl
BMS_NMRML_XSLT_CODE=schema/bmrbx2nmrml.xsl

NMRML_DOC_DIR=nmrml_doc
NMRML_RAW_DIR=nmrml_raw
NMRML_TMP_DIR=nmrml_tmp
NMRML_OBS_DIR=nmrml_obs
NMRML_ERR_DIR=nmrml_err

EXP_LIST_NAME=experiment.list
CHEM_COMP_INFO=chem_comp.info

mkdir -p $NMRML_TMP_DIR

echo
echo XSL Transformation...

for file in `ls $RAW_DIR/bmse*.xml 2> /dev/null`
do

 BASENAME=`basename $file .xml`
 XML_DOC=$RAW_DIR/$BASENAME.xml
 NMRML_DIR=$NMRML_TMP_DIR/$BASENAME

 mkdir -p $NMRML_DIR

 exp_id=1
 _exp_id=`printf '%02d' $exp_id`

 NMRML_BASE=$NMRML_DIR/$BASENAME-exp$_exp_id
 NMRML_FILE=$NMRML_BASE.nmrML
 EXP_LIST_FILE=$NMRML_DIR/$EXP_LIST_NAME
 CHEM_COMP_FILE=$NMRML_DIR/$CHEM_COMP_INFO

 if [ -e $XML_DOC ] && [ ! -e $EXP_LIST_FILE ] ; then

  java -jar $SAXON_JAR_FILE -s:$XML_DOC -xsl:$EXT_EXP_NAME_XSLT_CODE -versionmsg:off > $EXP_LIST_FILE

 fi

 if [ -e $XML_DOC ] && [ ! -e $CHEM_COMP_FILE ] ; then

  java -jar $SAXON_JAR_FILE -s:$XML_DOC -xsl:$EXT_CHEM_COMP_XSLT_CODE -versionmsg:off > $CHEM_COMP_FILE

 fi

 if [ -e $XML_DOC ] && [ ! -e $NMRML_FILE ] ; then

  exp_ids=`java -jar $SAXON_JAR_FILE -s:$XML_DOC -xsl:$EXT_EXP_ID_XSLT_CODE -versionmsg:off`

  echo $BASENAME

  for exp_id in $exp_ids
  do

   _exp_id=`printf '%02d' $exp_id`

   NMRML_BASE=$NMRML_DIR/$BASENAME-exp$_exp_id
   NMRML_FILE=$NMRML_BASE.nmrML
   NMRML_ERR=$NMRML_BASE.err

   if [ ! -e $NMRML_FILE ] || [ -e $NMRML_ERR ] ; then

    java -jar $SAXON_JAR_FILE -s:$XML_DOC -xsl:$BMS_NMRML_XSLT_CODE -o:$NMRML_FILE -versionmsg:off exp_id=$exp_id mirror=$MIRROR_SITE 2> $NMRML_ERR

    if [ $? = 0 ] ; then
     rm -f $NMRML_ERR
    fi

    echo -n .

   fi

  done

  echo

 fi

done

echo

BMSX_NMRML_JAR_FILE=extlibs/bmsx-nmrml.jar
echo Completing nmrML documents...

java -jar $BMSX_NMRML_JAR_FILE --tmp-dir $NMRML_TMP_DIR --out-dir $NMRML_RAW_DIR --obs-dir $NMRML_OBS_DIR --err-dir $NMRML_ERR_DIR --nmrml-xsd $NMRML_XSD --chebi-owl-idx $CHEBI_OWL_IDX --max-thrds $MAXPROCS

if [ $? != 0 ] ; then
 exit 1
fi

need_file_list=need_file_list

grep NEED_ $NMRML_RAW_DIR/*/*.nmrML | cut -d ':' -f 1 > $need_file_list

while read need_file
do

 mv $need_file $NMRML_ERR_DIR

done < $need_file_list

rm -f $need_file_list

find $NMRML_ERR_DIR/*.nmrML &> /dev/null

if [ $? != 0 ] ; then
 rmdir $NMRML_ERR_DIR
fi

ZIP=gzip

if [ ! -d $NMRML_RAW_DIR ] ; then

 echo "Couldn't find $NMRML_RAW_DIR directory."
 exit 1

fi

mkdir -p $NMRML_DOC_DIR

for entry_dir in `ls $NMRML_RAW_DIR 2> /dev/null`
do

 NMRML_SRC_DIR=$NMRML_RAW_DIR/$entry_dir
 NMRML_DST_DIR=$NMRML_DOC_DIR/$entry_dir

 find $NMRML_SRC_DIR/*.nmrML &> /dev/null

 if [ $? != 0 ] ; then

  rm -rf $NMRML_SRC_DIR
  rm -rf $NMR_DST_DIR

  continue

 fi

 if [ ! -d $NMRML_DST_DIR ] ; then
  mkdir -p $NMRML_DST_DIR
 fi

 EXP_LIST_TMP_FILE=$NMRML_TMP_DIR/$entry_dir/$EXP_LIST_NAME
 EXP_LIST_SRC_FILE=$NMRML_SRC_DIR/$EXP_LIST_NAME
 EXP_LIST_DST_FILE=$NMRML_DST_DIR/$EXP_LIST_NAME

 if [ ! -e $EXP_LIST_SRC_FILE ] ; then
  cp -f $EXP_LIST_TMP_FILE $EXP_LIST_SRC_FILE
 fi

 if [ ! -e $EXP_LIST_DST_FILE ] ; then
  cp -f $EXP_LIST_TMP_FILE $EXP_LIST_DST_FILE
 fi

 CHEM_COMP_TMP_FILE=$NMRML_TMP_DIR/$entry_dir/$CHEM_COMP_INFO
 CHEM_COMP_SRC_FILE=$NMRML_SRC_DIR/$CHEM_COMP_INFO
 CHEM_COMP_DST_FILE=$NMRML_DST_DIR/$CHEM_COMP_INFO

 if [ ! -e $CHEM_COMP_SRC_FILE ] ; then
  cp -f $CHEM_COMP_TMP_FILE $CHEM_COMP_SRC_FILE
 fi

 if [ ! -e $CHEM_COMP_DST_FILE ] ; then
  cp -f $CHEM_COMP_TMP_FILE $CHEM_COMP_DST_FILE
 fi

 for NMRML_SRC_FILE in `ls $NMRML_SRC_DIR/*.nmrML 2> /dev/null`
 do

  BASENAME=`basename $NMRML_SRC_FILE`
  NMRML_DST_FILE=$NMRML_DST_DIR/$BASENAME

  if [ ! -e $NMRML_DST_FILE".gz" ] ; then

   cp -f $NMRML_SRC_FILE $NMRML_DST_FILE

   $ZIP -f $NMRML_DST_FILE
   echo $BASENAME".gz" done.

  fi

 done

done

