#!/bin/bash -f
UNTAR_FILES=`cat $1`
tar_count=0
for tar_file in $UNTAR_FILES; do
    filename=$(basename $tar_file)
    file_name=${filename%.*}
    directory_name=${tar_file%.*}
    mkdir -p $directory_name
    tar -C $directory_name -xzf $tar_file
    rm -f $tar_file
    let tar_count=$tar_count+1
    echo "$directory_name" >> $HOME_DIRECTORY/lslist
#    echo "$directory_name" > "$HOME_DIRECTORY/lslist"
done

