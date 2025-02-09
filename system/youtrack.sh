/home/aaron/software/youtrack/bin/youtrack.sh start

exit 0

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


