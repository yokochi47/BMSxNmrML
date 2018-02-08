#!/bin/bash

echo
echo "Do you want to clean? (y [n]) "

read ans

case $ans in
 y*|Y*)
  ;;
 *)
  echo skipped.;;
esac

rm -f xml_file_total

rm -rf bms_xml_* nmrml_*

