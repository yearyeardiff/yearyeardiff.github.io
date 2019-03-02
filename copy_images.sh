#!/bin/bash


# 字符串是否匹配正则
# 1 否；0 是
function is_string_match_regular(){
    str=$(echo $1 | grep -ioE $2)
    if test -z "$str"
    then
        return 1
    else
        return 0
    fi
}

function getdir(){
    for element in `ls $1`
    do  
        dir_or_file=$1"/"$element
        if [ -d $dir_or_file ];then

            is_string_match_regular "$dir_or_file" '.*\bimages$'

            if test 0 -eq $?;then
                echo "copy images : [$dir_or_file] ---> [$direction_dir]"
                cp -r "$dir_or_file/" "$direction_dir" 
            else
                getdir $dir_or_file
            fi    
        fi  
    done
}
root_dir="source/_posts"
direction_dir="source/images"
getdir $root_dir