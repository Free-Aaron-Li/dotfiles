# 需要依赖：pypdf2 cn2an
import os
import re
from PyPDF2 import PdfMerger
import cn2an  # 用于中文数字转阿拉伯数字

# 定义目标目录和输出文件名
directory = "./"
output_file = "merged_book.pdf"

# 添加中文数字映射表
chinese_digits = {'零':0, '一':1, '二':2, '三':3, '四':4, 
                  '五':5, '六':6, '七':7, '八':8, '九':9, '十':10,'十一':11, '十二':12, '十三':13 }

def chinese_number_to_arabic(chinese_str):
    """将中文数字转换为阿拉伯数字（支持'十一'到'九十九'）"""
    try:
        return cn2an.cn2an(chinese_str, "normal")  # 示例：'十一'→11
    except:
        # 备用方案：自定义简单字典（适用于有限范围）
        return chinese_digits.get(chinese_str, 0)

def merge_pdfs_sorted(folder_path, output_file):
    merger = PdfMerger()

    # 1. 提取文件名并生成排序键
    files = []
    for f in os.listdir(folder_path):
        if f.endswith(".pdf"):
            # 正则提取章节中文数字（如匹配“十一章”中的“十一”）
            match = re.search(r"第(.*?)章", f)
            if match:
                ch_num = match.group(1)
                arabic_num = chinese_number_to_arabic(ch_num)
                files.append((arabic_num, f))

    # 2. 按转换后的数字排序
    files.sort(key=lambda x: x[0])

    # 3. 合并文件
    for _, filename in files:
        merger.append(os.path.join(folder_path, filename))

    merger.write(output_file)
    merger.close()
    print(f"合并完成！输出文件：{output_file}")

merge_pdfs_sorted(directory, output_file)
