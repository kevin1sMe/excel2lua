#!/bin/bash
#========================================================================
#   FileName: get_xls_changelist.sh
#     Author: kevinlin
#      Email: linjiang1205@qq.com
#       Desc: 获得增量要更新的配置列表(通过对比svn版本号来计算)
#     Create: 2014-12-15 11:21:31
#    History: v1.0 这功能在tofuli刚加入水浒项目组时我让他有空做一下，到如今他已经离职多日，仍然没开启， 我终于有点不满于现在的低效，只能自己写一个
# LastChange: 2014-12-15 11:50:06
#========================================================================

#取最新版本excel
svn up excel/ 2>&1 > /dev/null

#---------开始计算差异----------------
all_xls_version_file="all_xls_version.txt"

#如果没找到版本文件，新建一个
if [ ! -e $all_xls_version_file ]; then
    #echo "not found $all_xls_version_file"
    touch $all_xls_version_file
fi

mv $all_xls_version_file ${all_xls_version_file}.old

#生成新的版本文件; PS:这里的sed的用法你可能会疑惑:)
find excel/ -maxdepth 1 -type f   -name "*[.xls|.xlsx]" | xargs svn info | egrep "Name|Rev:" | sed 'N;s/\n/:/' | awk -F ':' '{print $2 $4}' > $all_xls_version_file

#对比两个版本，取出变化的xls/xlsx
diff ${all_xls_version_file} ${all_xls_version_file}.old | egrep -o  "[^ ]*\.xls|[^ ]*\.xlsx" |  sort | uniq 



