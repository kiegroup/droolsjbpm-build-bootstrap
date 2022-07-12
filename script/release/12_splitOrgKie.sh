#!/bin/bash
set -ex
input_dir='org/kie'
imax=25
array_list=( $(ls $input_dir) )
echo "( ${array_list[@]} )"
ndirs=( ${#array_list[@]} )  # count of files and directories
echo $ndirs

for i in `seq 0 $imax $ndirs`; do
    is=$i
    ie=$(($is+$imax-1))
    ie=$((ie<$ndirs ? ie: $ndirs-1));
    echo "+-+-+-+-+-+-+-+-+-+-+-+-+-";
    echo "$(($i+1)) loop";

    for ii in `seq $is $ie`; do
        echo "is: $is; ie: $ie; ii: $ii";
        echo "****** $(($ii+1)). element:  ${array_list[$ii]} ******";
        zip -qr kie-$i.zip $input_dir/${array_list[$ii]}
    done
    curl --silent --upload-file kie-$i.zip -u $CREDS -v https://repository.jboss.org/nexus/service/local/repositories/$repoID/content-compressed -H "Connection: keep-alive" -H "Keep-Alive: timeout=1800000, max=0"
done