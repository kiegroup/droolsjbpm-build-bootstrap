#!/bin/bash
pushd $1
imgpath=`realpath ../../../../../_images/`
sedcommand=s\|$imgpath\|_images\|g
sed  "$sedcommand" <index.html >index-new
cp -R ../../../../../_images _images
mv index-new index.html
popd
