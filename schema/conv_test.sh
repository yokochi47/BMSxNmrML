#!/bin/bash

SAXON=../extlibs/saxon9he.jar
BMRBX2NMRML_XSL=bmrbx2nmrml.xsl

rm -f *.nmrML

ENTRY_ID=bmse000400
EXP_ID=6
_EXP_ID=`printf '%02d' $exp_id`

XML_DOC=../bms_xml_raw/$ENTRY_ID.xml

if [ ! -e $XML_DOC ] ; then

 echo "Couldn't find "$XML_DOC
 exit 1

fi

NMRML_DOC=$ENTRY_ID-exp$_EXP_ID.nmrML
NMRML_ERR=$ENTRY_ID-exp$_EXP_ID.err

java -jar $SAXON -s:$XML_DOC -xsl:$BMRBX2NMRML_XSL -o:$NMRML_DOC -versionmsg:off exp_id=$EXP_ID 2> $NMRML_ERR

if [ $? = 0 ] ; then

 rm -f $NMRML_ERR
 vim $NMRML_DOC
 rm $NMRML_DOC

else

 cat $NMRML_ERR

fi

