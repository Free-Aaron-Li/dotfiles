#!/bin/bash

# 定义ffmpeg路径，确保该路径正确指向系统中ffmpeg可执行文件的位置
FFMPEG_PATH="/home/aaron/environment/ffmpeg-7.1/bin/ffmpeg"

# 使用for循环遍历当前目录下所有扩展名为mp4的文件
for file in *.mp4; do
    # 判断当前项是否为文件，如果不是则跳过本次循环
    [ -f "$file" ] || continue
    
    # 生成临时输出文件名，通过去掉原文件扩展名并添加"_temp.mp4"实现
    temp_output="${file%.*}_temp.mp4"
    
    # 调用ffmpeg命令进行音频降噪处理
    # -hide_banner                # 隐藏启动时的banner信息
    # -hwaccel cuda               # 启用CUDA硬件加速解码
    # -i "$file"                  # 指定输入文件
    # -af                         # 音频滤镜链配置
    #   afftdn=...                # 频域降噪滤镜配置
    #     nr=30                   # 降噪强度30dB
    #     nf=-45                  # 噪声地板-45dB
    #     nt=w                    # 噪声类型为白噪声
    #     tn=1                    # 启用噪声跟踪
    #     ad=0.3                  # 适应因子0.3
    #     fo=0.5                  # 噪声地板偏移因子0.5
    #     nl=min                  # 多声道噪声链接方式为最小值
    #     bm=1.0                  # 频段扩展因子1.0
    #     gs=10                   # 增益平滑半径10
    #   highpass=f=200            # 高通滤波器，截止频率200Hz
    #   lowpass=f=3000            # 低通滤波器，截止频率3000Hz
    #   anlmdn=...                # 时域降噪滤镜配置
    #     s=0.1                   # 降噪强度0.1
    #     p=0.002                 # 比较片段大小2毫秒（以秒为单位）
    #     r=0.006                 # 查找范围6毫秒（以秒为单位）
    #     m=11                    # 平滑因子11
    # -c:v h264_nvenc             # 使用NVIDIA硬件编码器对视频进行编码
    # -preset fast                # 编码速度与压缩效率的平衡预设，可替换为medium或slow以获取更好的压缩效果
    # -multipass 1                # 启用多通道编码，提升编码效率
    # -rc vbr                     # 使用可变速率编码，提高编码质量
    # -cq 20                      # 设置恒定质量，数值越小质量越高，编码速度可能越慢
    # "$temp_output"              # 指定输出文件名
    "$FFMPEG_PATH" -hide_banner -hwaccel cuda -i "$file" -af "afftdn=nr=30:nf=-45:nt=w:tn=1:ad=0.3:fo=0.5:nl=min:bm=1.0:gs=10,highpass=f=200,lowpass=f=3000,anlmdn=s=0.1:p=0.002:r=0.006:m=11" -c:v h264_nvenc -preset fast -multipass 1 -rc vbr -cq 20 "$temp_output"
    
    # 检查上一条命令的退出状态码，判断命令是否成功执行
    if [ $? -eq 0 ]; then
        # 如果命令执行成功，则将临时文件重命名为原文件名，覆盖原文件
        mv -f "$temp_output" "$file"
        # 输出处理成功的提示信息
        echo "✅ 已处理: $file"
    else
        # 如果命令执行失败，则删除生成的临时文件
        rm -f "$temp_output"
        # 输出处理失败的提示信息
        echo "❌ 处理失败: $file"
    fi
done

# 输出处理完成的提示信息
echo "处理完成！"
