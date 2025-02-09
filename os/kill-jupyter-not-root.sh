#!/bin/bash
# 使用反引号或 $() 来获取命令的输出
ports=$(jupyter notebook list | awk -F[:/] '{print $5}')
for target_port in $ports; do
    # 直接使用 $target_port，无需再次赋值
    if [ "$target_port" != "8888" ]; then
        # 使用 $target_port 替代 $PORT
        kill -9 $(lsof -n -i4TCP:$target_port | cut -f 2 -d " ")
    else
        echo "Notebooks on port '$target_port' are still running ..."
    fi
done
