#!/bin/bash

# 参考：https://www.cnblogs.com/whiteHand/p/10714759.html
# 笔记本默认键盘，通常均为该名
DEFAULT_KEYBOARD_DEV='AT Translated Set 2 keyboard'
# 外设键盘	
PERIPHERAL_KEYBOARD_DEV='Compx 2.4G Wireless Receiver'
# 外设键盘简称
PERIPHERAL_KEYBOARD_FOR_SHORT='RK R65'

# 设置设备状态
function setStatus(){
  # 获取传入设备的id，设备id往往不止有一个
	IDS=` xinput list | grep "$2" | awk  -F 'id=' '{print $2}' | awk '{print $1}' `
  # 最终执行命令
	for elem in $IDS 
	do 
		xinput $1 $elem
	done
}

# 外设键盘是否插入
EXIST_PERIPHERAL_KEYBOARD=`xinput list | grep "$PERIPHERAL_KEYBOARD_DEV"`

# 判断该选择哪个键盘
if [ "" != "$EXIST_PERIPHERAL_KEYBOARD" ]
then
  # 若外设键盘存在，则关闭笔记本键盘，并开启外接键盘
	setStatus --disable $DEFAULT_KEYBOARD_DEV
	# setStatus --enable $PERIPHERAL_KEYBOARD_DEV
  echo "已禁用默认键盘，启动\"$PERIPHERAL_KEYBOARD_FOR_SHORT\"键盘。"
else
  # 若外设键盘不存在，则开启笔记本键盘，并关闭外接键盘
	setStatus --enable $DEFAULT_KEYBOARD_DEV
	# setStatus --disable $PERIPHERAL_KEYBOARD_DEV
  echo "未检测到外设键盘，启动默认键盘。"
fi

# 建议：
# 如果希望设置开机自启动，可以在/etc/xdg/autostart目录下创建desktop文件
# 如果采用systemd方式，可能会出现：Unable to connect to X server 情况
# 具体设置方式：
# sudo vim /etc/xdg/autostart/keyboard.desktop
# 写入以下内容：
#
# [Desktop Entry]
# Name=Test	 		#可执行文件名字
# Exec=/root/Test 	#可执行文件路径
# Type=Application	#可执行文件类型
#
# 保存并重启或注销账户即可开机自启动。

exit 0

