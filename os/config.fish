function fish_greeting
    # 关闭shell启动语句
    set -U fish_greeting
    # bat主题选择
    set -x BAT_THEME Coldark-Cold
    # 在fish shell下使用vi模式绑定
	  fish_vi_key_bindings
    #-------------------------------------
	  # 环境
    # 添加aaron下的可执行环境
    set -x PATH /home/aaron/.local/bin $PATH
    # java 环境	
    set -x PATH /home/aaron/language/jdk_21/bin $PATH
    export JAVA_HOME='/home/aaron/language/jdk_21'
    # kotlin 环境
    set -x PATH /home/aaron/language/kotlin/kotlinc/bin $PATH
    set -x PATH /home/aaron/language/kotlin/kotlin-native/bin $PATH
    export KOTLIN_HOME='/home/aaron/language/kotlin/kotlinc'
    export KOTLIN_NATIVE_HOME='/home/aaron/language/kotlin/kotlin-native'
    # miniconda 环境
    # set -x PATH /home/aaron/Software/conda/Miniconda3/bin $PATH
    # git filter-repo 环境
    set -x PATH /home/aaron/Software/git-filter-repo $PATH
	  export BAT_CONFIG_PATH="/home/aaron/.bat.conf"
    #-------------------------------------
	  # 别名
    # 删除操作
    alias del='trash-put'
    # 对mv操作添加“是否覆盖”提示
    alias mv='mv -i'
    # 对git commit规范程序进行命令简化
    alias commit='npx cz-customizable'
    # 拍照
    alias Cheese='ffmpeg -i /dev/video0 -frames 1  -r 1  -f image2 image.jpg'
	  # neovide别名
	  alias nv="neovide"
    # keyboard配置
    alias keyboard="bash /home/aaron/.dotfiles/system/keyboard.sh"
    #-------------------------------------
    # 函数
    function web_on
    	cd /usr/local/mysql/support-files/ && sudo ./mysql.server start
    	cd /home/aaron/environment/apache-tomcat-9.0.80/bin/ && ./startup.sh 
      sudo systemctl start mssql-server

    	echo -e "web服务已启动"
    end

    function web_off
    	cd /usr/local/mysql/support-files/ && sudo ./mysql.server stop
    	cd /home/aaron/environment/apache-tomcat-9.0.80/bin/ && ./shutdown.sh 
      sudo systemctl stop mssql-server

    	echo -e "web服务已关闭"
    end
    #------------------------------------
    # 绑定快捷键
    # Preview file content using bat (https://github.com/sharkdp/bat)
    export FZF_CTRL_T_OPTS="
        --preview 'bat -n --color=always {}'
        --bind 'ctrl-/:change-preview-window(down|hidden|)'"
end
