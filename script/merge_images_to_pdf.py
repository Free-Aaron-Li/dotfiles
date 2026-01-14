import os
import re
from PIL import Image
from datetime import datetime

def merge_images_to_pdf(image_folder, output_pdf=None):
    # 处理中文路径
    image_folder = os.path.abspath(image_folder)
    image_files = sorted(
        [os.path.join(image_folder, f) for f in os.listdir(image_folder)
         if re.match(r'g\d{3}\.(png|jpg|jpeg|webp)', f, re.IGNORECASE)],
        key=lambda x: int(re.search(r'g(\d{3})', x, re.I).group(1))
    )

    images = []
    for img_path in image_files:
        try:
            with Image.open(img_path) as img:  # 使用上下文管理器
                if img.mode != 'RGB':
                    img = img.convert('RGB')
                images.append(img.copy())      # 关键：复制到内存
                print(f"已加载：{os.path.basename(img_path)}")
        except Exception as e:
            print(f"错误：{img_path} 加载失败 - {str(e)}")
            continue

    if not images:
        raise ValueError("无有效图片可合并！")

    # 生成输出路径
    output_pdf = output_pdf or f"combined_{datetime.now().strftime('%Y%m%d%H%M%S')}.pdf"

    # 保存PDF（检查首图是否有效）
    if images[0]:
        images[0].save(
            output_pdf, save_all=True, append_images=images[1:],
            resolution=300, quality=95
        )
        print(f"PDF 已生成：{output_pdf}")
    else:
        print("错误：首张图片无效，无法生成PDF")

if __name__ == "__main__":
    merge_images_to_pdf("./")
