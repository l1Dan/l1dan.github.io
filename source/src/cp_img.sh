#!/bin/sh
# filename: cp_img.sh
# author: 李丹
#
# 将名为 `center_point_icon` 和 `current_point_icon` 的图片，
# 拷贝到百度地图 `mapapi.bundle/images` 文件夹中。

# 添加需要的图片
ADD_IMGS=("center_point_icon" "current_point_icon")
# 指定目标文件夹
DEST_DIR=$(find . -path '*mapapi.bundle/images')
# 执行拷贝操作
for IMG in ${ADD_IMGS[@]}
do
    find . -path ${DEST_DIR} -prune -o -name "${IMG}*.png" -print | xargs -I {} cp {} ${DEST_DIR}
done



