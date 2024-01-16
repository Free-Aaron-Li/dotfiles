## 设置


### 一、鼠标

1. 鼠标->指针速度慢2

### 二、触控板

1. 自然滚动（开）

### 三、显示

1. 模式：仅HDMI屏

### 四、电源

1. 通用->性能模式->高性能模式
2. 使用电池-> 笔记本合盖时（无任何操作）


### 五、更新

1. 更新设置->内测通道（开启）
2. 手动添加内核更新命令：sudo apt install linux-image-6.4.7-amd64-desktop-hwe linux-headers-6.4.7-amd64-desktop-hwe
3. 玲珑软件更新


### 六、键盘和语言

#### 快捷键

1. 终端 Shift+Ctrl+T
2. 控制中心（命令 dde-control-center --show）Super+i
3. 截图 Ctrl+O

#### 七、输入法

0. 很好的配置选项（https://bbs.deepin.org/post/256386）
1. 全局选项->向前/向后切换输入法（Shift）
2. 输入法管理->键盘-英语（美国）--- 拼音
3. 设置输入法皮肤
	1. 存储位置 /home/aaron/.local/share/fcitx5/themes
	2. 设置皮肤为Material-Color-Teal
		1. mkdir -p ~/.local/share/fcitx5/themes/Material-Color
		2. git clone https://github.com/hosxy/Fcitx5-Material-Color.git ~/.local/share/fcitx5/themes/Material-Color
	3. 具体配置方案（https://www.cnblogs.com/maicss/p/15056420.html）
	4. 使用emoji，
        > 下载noto-color-emoji字体（https://raw.githubusercontent.com/googlefonts/noto-emoji/main/fonts/NotoColorEmoji.ttf）。
        > 同时，需要在设置->个性化->等宽字体->设置为Noto Color emoji，之后再设置回来，这样emoji才会显示彩色
4. 拼音设置
	1. 启用颜文字
	2. 在程序中显示预编辑文本


### 八、个性化

1. 桌面->
	1. 模式->高效模式/时尚模式
	2. 位置-> 左/下
	3. 插件区域->全部关闭
2. 主题->
	1. 文字设置->字体大小 14
	2. 主题->
		1. 外观（浅色）
		2. 活动用色（黎色#75664d）
		3. 图标主题（vintage）
		4. 光标主题（Bibata-Rainbow-Modern）
            > 复制到/usr/share/icons 查询地址（https://www.gnome-look.org/）
3. 字体
	1. JetbrainsMono NerdFont（https://github.com/ryanoasis/nerd-fonts/releases）
	2. 思源宋体：https://github.com/adobe-fonts/source-han-serif/releases/
	3. 思源黑体：https://github.com/adobe-fonts/source-han-sans/releases/
	4. 新罗马字体：https://www.fontles.com/times-new-roman-font-free-download/
	
### 九、用户

1. 修改头像图标、名字

### 十、人脸

1. 无需

### 十一、通知

1. 系统通知（开启）

### 十二、通用

1. 跟换背景

### 十三、DNS
1. DNS1：
	阿里 AliDNS
	首选：223.5.5.5
	备选：223.6.6.6
2. DNS2：
	Public DNS+
	首选：119.29.29.29
	备选：182.254.116.116


## 图片

1. 复制Draw、head_image、people、Screenshots、Wallpapers

## 浏览器

### 常规设置
1. 创建Backup，导入浏览器书签
2. 设置->显示->显示书签栏（关闭）
3. 设置->显示->仅在新标签页上（关闭）

### 插件
删除下载器应用

1. flowVPN(插件迷）
2. SimpleExtManager
3. 腾讯翻译
	1. 选项->Alt+w
4. iTab新标签页


## 软件

1. 火狐
    1. 下载（https://www.firefox.com.cn/）
2. 下载chrome (http://www.google.cn/chrome/index.html）
3. deepin浏览器（卸载原生浏览器，通过玲珑网页商城（https://store.linglong.dev/）下载更新）
4. CLion
	1. 安装（https://www.jetbrains.com/zh-cn/clion/download/#section=linux）
	2. 修改runtime(https://github.com/AlanSune/JetBrainsRuntime-for-Linux-x64/releases/)
	3. 复制Source文件夹
	4. 安装git(sudo apt install git)
		> git config --global user.name 你的英文名 #,此英文名不需要跟GitHub账号保持一致
		> git config --global user.email 你的邮箱  #此邮箱不需要跟GitHub账号保持一致
		> git config --global push.default matching
		> git config --global core.quotepath false
		> git config --global core.editor "vim"
	5. 导入配置文件
	6. 安装插件
		0. 启用云同步（如果有）
		1. Chinese(Simplified)Language Pack/中文语言包
		2. wakatime
            >（启用api（https://wakatime.com/login?next=https://wakatime.com/dashboard））
		3. IdeaVimExtension（需要将键盘-英文设置在第一优先位）
		4. CodeGlance Pro
		5. IdeaVim
		6. KJump
		7. Mermaid
		8. Rainbow Brackets Lite - Free and OpenSource
		9. Translation
	7. 配置工具链
		1. 安装g++(sudo apt install g++)
		2. 设置C编译器为/usr/bin/gcc
		3. 设置C++编译器为/usr/bin/g++
		4. 安装mingw(sudo apt-get install mingw-w64)
		5. 设置C编译器为/usr/bin/x86_64-mingw32-gcc
		6. 设置C++编译器为/usr/bin/x86_64-mingw32-g++
	8. 复制.ideavimrc
	9. 外观与行为
		1. 使用自定义字体：Noto Sans 17
	10. 工具窗口
		1. 目录->设置视图模式为窗口
		2. 终端->设置视图模式为窗口
5. Toolbox
	1. 安装（https://www.jetbrains.com/zh-cn/toolbox-app/）
6. Virtualbox
	1. 安装（https://www.virtualbox.org/wiki/Linux_Downloads）
	2. 依赖
		1. libssl1.1
            >（http://ftp.de.debian.org/debian/pool/main/o/openssl/libssl1.1_1.1.1n-0+deb10u3_amd64.deb）
		2. libvpx5
            >（http://ftp.de.debian.org/debian/pool/main/libv/libvpx/libvpx5_1.7.0-3+deb10u1_amd64.deb）
	3. 采用deb方式安装可能存在问题，改为：https://bbs.deepin.org/zh/post/254728
    3. 修复”无法枚举USB设备“问题
        > 1. sudo vi  /etc/group
        >
        > 修改 “vboxusers❌125”行，添加用户名

7. utools
	1. 安装（https://u.tools/）
	2. 设置
		1. 关闭悬浮球
		2. 修改账户头像
	3. 安装插件
		1. 网页快开
		2. C++函数速查
		3. 编码小助手
		4. 易翻翻译
8. LX-Music
	1. 安装（https://github.com/lyswhut/lx-music-desktop/releases）

9. deepin-editor
	1. 卸载玲珑版本的deepin-editor。
        > 因为玲珑目前（V23B2）版本下存在权限问题，卸载命令：（ ll-cli uninstall org.deepin.editor）
	2. 安装（sudo apt install deepin-editor）
10. pot-app
	1. 安装（https://github.com/pot-app/pot-desktop/releases/）
	2. 添加有道云翻译API（https://ai.youdao.com/console/#/）
11. IDEA
	1. 安装（toolbox)
12. Timeshift
	1. 安装（应用市场）
13. neovide
	1. 安装（https://github.com/neovide/neovide/releases/）
14. bilibili
	1. 下载
		1.（https://github.com/msojocs/bilibili-linux/releases/）
		2. 星火商店
18. 微信
	1. 下载（应用市场）
19. QQ
	1. 下载（https://im.qq.com/linuxqq/index.shtml）
20. VScode
    1. 下载（https://code.visualstudio.com/docs/?dv=linux64_deb)
    2. 加速下载
        > 将az764295.vo.msecnd.net替换成vscode.cdn.azure.cn
    3. 设置标题栏
        > setting->Layout Control -> toggles
21. steam
    1. 安装（flatpak install flathub com.valvesoftware.Steam）
    2. 复制软件快捷方式
        > sudo cp /var/lib/flatpak/app/com.valvesoftware.Steam/current/active/export/share/applications/com.valvesoftware.Steam.desktop /usr/share/applications/
    3. 复制图标
        > 将/var/lib/flatpak/app/com.valvesoftware.Steam/current/active/export/share/icons/hicolor/ 文件夹下面的4个文件夹复制到/usr/share/icons/hicolor
22. motrix
    1. 安装
        > https://motrix.app/download
23. windows ISO
    1. ISO下载地址（https://next.itellyou.cn/Original/）
24. wps
    1. 下载（https://linux.wps.cn/）
    2. 卸载LibreOffice
    3. 安装缺失字体
        > git clone git@github.com:dv-anomaly/ttf-wps-fonts.git
        >
        > cd ttf-wps-fontsp
        >
        > sudo bash install.sh
25. eog
    1. 下载（sudo apt install eog）
26. 星火商店
    1. 下载（https://gitee.com/deepin-community-store/spark-store/releases/）
27. mathmatica
    1. 下载（https://wdm-reborn.itsu.eu.org/Rasis/Mathematica/13.3.1.0/BNDL_Chinese）/ 存在于硬盘
    2. 激活（https://ibug.io/blog/2019/05/mathematica-keygen/）
    3. 参考（https://tiebamma.github.io/InstallTutorial/）

28. matlab
    1. 参考（https://zhuanlan.zhihu.com/p/572662952）存在于硬盘
	> https://zhuanlan.zhihu.com/p/53887734
	> https://blog.csdn.net/weixin_28949825/article/details/79433925
    2. 修复：
	> 创建/usr/lib/dri目录
	> 建立软路由：
	> kms_swrast_dri.so -> /usr/lib/x86_64-linux-gnu/dri/kms_swrast_dri.so
	> radeonsi_dri.so -> /usr/lib/x86_64-linux-gnu/dri/radeonsi_dri.so
	> swrast_dri.so -> /usr/lib/x86_64-linux-gnu/dri/swrast_dri.so
	> zink_dri.so -> /usr/lib/x86_64-linux-gnu/dri/zink_dri.so
	> 修改matlab中libstdc++.so.6的软路由
	> libstdc++.so.6 来自于/usr/lib/x86_64-linux-gnu，复制到/home/aaron/Software/matlab/R2023b/sys/os/glnxa64下并修改软路由：
	> libstdc++.so.6 -> /home/aaron/Software/matlab/R2023b/sys/os/glnxa64/libstdc++.so.6.0.29
29. annepro2键盘配置软件
    1. 下载（https://www.hexcore.xyz/zh/obinskit）
30. Strtchly 视觉抗疲劳
	1. 下载（https://github.com/hovancik/stretchly/releases/download/v1.14.1/Stretchly_1.14.1_amd64.deb）
31. XDM
	1. 下载（https://github.com/subhra74/xdm/releases/）
32. obsidian 
	1. 下载（https://obsidian.md/download）
33. navicat
	> rm -rf ~/.config/navicat
       > rm -rf ~/.config/dconf/user

## 终端

0. 设置root账户，命令（sudo passwd root）

1. 关闭蜂鸣器
	1. sudo vi /etc/modprobe.d/nobeep.conf
	2.添加内容：
		> blacklist pcspkr
		> 
		> blacklist snd_pcsp
	3. 保存退出
	
2. 软件
	1. 常用命令替换
		1. bat，替代cat
			1. 安装（https://github.com/sharkdp/bat/releases/)
			2. 设置主题
                > 在终端（明亮）下，bat默认主题显示不清楚，在shell配置文件中添加命令（ export BAT_THEME="Solarized (light)")，具体可以查看文档（https://github.com/sharkdp/bat#customization）
		2. exa，替代ls
			1. 安装（https://github.com/ogham/exa/releases/）
			2. 命令（cp ./exa ~/.local/bin）
                > 如果没有则创建~/.local/bin，并将其设置配置路径（bashrc下为：export PATH=/home/aaron/.local/bin:$PATH）
			3. man手册安装，将man文件夹下的文件复制到/usr/share/man目录下的对应manX中。
		3. trash-cli，替代rm
			1. 安装（sudo pip install trash-cli），需要V23具有pip，具体可见下方安装pip3
			2. 使用命令
				1. 文档（https://github.com/andreafrancia/trash-cli/blob/master/README_zh-CN.rst）
				2. 简单归纳：
					> trash-put		将文件或目录移动到回收站
					>
					> trash-empty		清空回收站
					>
					> trash-list		列出回收站文件
					>
					> trash-restore	恢复回收站文件（通过文件列表编号选择）
					>
					> trash-rm		删除回收站文件
					> 
					> trash回收的位置位于~/.local/share/Trash/
				3. 设置别名（alias del='trash-put')
				4. 设置提示
                    >（alias rm='echo "This is not the command you are looking for, you maybe need \"trash-put\",or alias \"del\". oh if you must do it, please enter \"\rm\"."; false'）。如果真的需要rm命令，则需要在rm前添加\
        4. tldr，替代man
			1. 安装（sudo npm install -g tldr)
            2. 更新（tldr --update)
		5. rg，替代grep
			1. 安装（https://github.com/BurntSushi/ripgrep/releases/）
		6. fd，替代find
			1. 安装（https://github.com/sharkdp/fd/releases）
	2. man
		1. 手册页缺失，需要两个依赖补充包（https://bbs.deepin.org/post/261437）
		2. 补充手册页，将手册页文件复制到/usr/share/man目录下，根据实际需求复制到man1~man5
	3. pip3
		1. 安装（sudo apt install python3-pip）
		2. 换源（pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple）
	4. fish
		1. 参考（https://www.cnblogs.com/aaroncoding/p/17118251.html）
		2. 错误解决。
            > 如果出现问题（error: Unable to open universal variable file '/': Permission denied），解决方法（cd /home/user/.config/fish/ && chown user:user fish_variables）
		3. 复制配置文件config.fish
	5. neovim
		1. 安装（https://github.com/neovim/neovim/releases/） 
                2. 配置 复制 “.config/nvim”、".local/share/nvim“和“.local/state”配置文件 
                3. man 复制 “/home/user/Software/neovim/man/man1/nvim.1”文件至“ /usr/share/man/man1/”
    6. ffmpeg 文件格式转换命令行
		1. 安装（sudo apt-get install ffmpeg）
		2. 转换方式：ffmpeg -i file_1 file_2
    7. 安装node&&npm
        1. 安装（https://blog.csdn.net/u011262253/article/details/104903255）
        2. 加速（ npm config set registry https://registry.npmmirror.com）
    8. git
		1. 配置邮箱与用户名
			> git config --global user.email "..."
			>
			> git config --global user.name "..."
        2. 创建密钥
            > ssh-keygen -t rsa -C "..."
    9.  flatpak
        1. 安装（sudo apt install flatpak）
        2. 添加软件仓库
            >（sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo)
        3. 远程仓库换源
            > sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
    10. 查看文件大小——du
	  11. 参考
		> https://www.cnblogs.com/Sungeek/p/11661554.html
		> 
		> https://www.cnblogs.com/sweet22353/p/9481217.html
		>
		> https://www.cnblogs.com/sweet22353/p/9481217.html
    11.  binutils
        1. 下载（http://ftp.gnu.org/gnu/binutils/）
        2. 安装：
            1. ./configure
            2. make
            3. sudo make install
    12. docker
	12. 安装（curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun）
	13. 修改docker.sock权限
		> sudo chown root:docker /var/run/docker.sock
		> sudo gpasswd -a $USER docker
		> newgrp docker # 更新docker 用户组
		> reboot
	14. fzf(模糊查询)
    	1. 安装（https://github.com/junegunn/fzf/releases/)
    	2. 前置依赖
          	1. fzf.fish(https://github.com/PatrickF1/fzf.fish)
          	2. fish(https://fishshell.com/)
          	3. fd(https://github.com/sharkdp/fd)
          	4. bat(https://github.com/sharkdp/bat)
          	5. delta(https://github.com/dandavison/delta) 请查看详细配置以完成对终端色彩的管理
    13. tmux
	1. 安装（sudo apt install tmux）
    14. vim
	1. 安装（https://blog.csdn.net/ECNU_LZJ/article/details/104475139）
3. 配置文件
    1. 复制～/.clang-format
    2. 删除系统存在的快捷键（Alt+Space)
        > 在~/.config/kglobalshortcutsrc中删除`Window Operations Menu`中对应快捷键
        > 
        > 注销、重启
	3. CLion插件列表：
	 > Chinese(Simplified) Language Pack / 中文语言包   
        > codeGlance Pro  
        > GitHub Theme     
        > IdeaVim   
        > IdeaVimExtension    
        > KJump    
        > Mermaid   
        > Rainbow Brackets Lite - Free and OpenSource   
        > Translation   
        > WakaTime   
## 语言

1. java
	1. 下载（https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html）
    2. 配置
        > set -x PATH /home/aaron/language/jdk/bin/ $PATH
 

## 虚拟机

1. macOS
	1. 参考（https://blog.csdn.net/u012332816/article/details/122186899）

---
mysql:
参考：https://www.cnblogs.com/MrYoodb/p/15811199.html
```bash
sudo cp Downloads/mysql /usr/local/ -r
cd /usr/local/mysql/
sudo mkdir data
root:
groupadd mysql
useradd -g mysql mysql
chown -R mysql:mysql /usr/local/mysql/
cd bin/
./mysqld --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --initialize
cd support-files/
sudo ./mysql.server start
./mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';

vi /home/aaron/.config/fish/config.fish 

    function web_on
    cd /usr/local/mysql/support-files/ && sudo ./mysql.server start
    cd /home/aaron/environment/apache-tomcat-9.0.80/bin/ && ./startup.sh 
    echo -e "web服务已启动"
    end

    function web_off
    cd /usr/local/mysql/support-files/ && sudo ./mysql.server stop
    cd /home/aaron/environment/apache-tomcat-9.0.80/bin/ && ./shutdown.sh 
    echo -e "web服务已关闭"
    end

exec fish

```
