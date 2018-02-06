#!/bin/bash

OWL_NAME=chebi.owl

DB_FTP=ftp.ebi.ac.uk/pub/databases/chebi/ontology/
GZ_FILE=$OWL_NAME.gz

WGET_LOG=wget.log

CHEBI_OWL_INDEX=chebi_luceneidx

if [ -d $CHEBI_OWL_INDEX ] ; then

 echo
 echo "Do you want to update lucene index? (y [n]) "

 read ans

 case $ans in
  y*|Y*) ;;
  *) echo stopped.
   exit 1;;
 esac

 rm -rf $CHEBI_OWL_INDEX

fi

if [ ! -e $OWL_NAME ] ; then

 wget -c -m ftp://$DB_FTP/$GZ_FILE -o $WGET_LOG

 if [ $? != 0 ] ; then

  cat $WGET_LOG
  exit 1

 fi

 grep 'not retrieving' $WGET_LOG > /dev/null

 if [ $? = 0 ] && [ -d $CHEBI_OWL_INDEX ] ; then
  echo $OWL_NAME is update.
  exit 0
 fi

 grep 'No such file' $WGET_LOG > /dev/null

 if [ $? = 0 ] ; then
  exit $?
 fi

 cp -f $DB_FTP/$GZ_FILE $GZ_FILE
 gunzip $GZ_FILE

fi

java -classpath owl-indexer.jar owl2luceneidx --owl $OWL_NAME --idx-dir $CHEBI_OWL_INDEX --xmlns rdfs=http://www.w3.org/2000/01/rdf-schema# --attr rdfs:label

