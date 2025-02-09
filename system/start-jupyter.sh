#!/bin/bash
# 使用 nohup 命令在后台运行 Jupyter Lab
# --allow-root 允许以 root 用户身份运行 Jupyter Lab
# > 将标准输出重定向到文件
# 2>&1 将标准错误也重定向到文件
# & 将整个命令放到后台运行
# --ip=0.0.0.0 表示不限制该服务的ip来源
jupyter-lab --port=6789 --no-browser  >> /var/log/jupyter-lab.log 2>&1 &
jupyter notebook --port=8888 --no-browser >> /var/log/jupyter-notebook.log 2>&1 &

