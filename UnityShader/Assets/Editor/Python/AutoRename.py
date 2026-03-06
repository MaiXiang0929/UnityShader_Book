"""
工具名称：材质球前缀自动修复工具
作者：MaiX
版本：v2.1
功能：
    1. 扫描 Assets 目录下所有的 .mat 资源。
    2. 自动为未命名规范（缺少 M_ 前缀）的材质球添加前缀。
    3. 自动忽略内嵌在模型（.obj, .fbx）中的材质，防止损坏模型文件。
    4. 自动过滤 Packages 目录下的只读资源。
"""

import os
from UnityEditor import AssetDatabase

def fix_mat_prefixes_v2():
    """
    核心执行函数：遍历资源数据库并执行重命名逻辑
    """
    # 1. 使用过滤器查找所有材质资源 (t:Material)
    # 这会返回所有材质球的 GUID（全局唯一标识符）
    all_mat_guids = AssetDatabase.FindAssets("t:Material")
    
    renamed_count = 0
    ignored_count = 0
    
    print("--- [TA] 开始扫描项目材质球 ---")
    
    for guid in all_mat_guids:
        # 将 GUID 转换为项目内的相对路径 (例如: Assets/Art/Stone.mat)
        asset_path = AssetDatabase.GUIDToAssetPath(guid)
        
        # 过滤 A: 必须在 Assets 目录下，忽略 Packages 里的只读资源
        if not asset_path.startswith("Assets/"):
            continue
            
        # 过滤 B: 精准匹配 .mat 后缀，防止误伤 .obj 或 .fbx 模型文件
        # .lower() 确保对 .MAT 等大写后缀也有效
        if not asset_path.lower().endswith(".mat"):
            ignored_count += 1
            continue
            
        # 获取纯文件名 (例如: "Stone.mat")
        file_name = os.path.basename(asset_path)
        
        # 检查是否缺少 "M_" 前缀
        if not file_name.startswith("M_"):
            new_name = "M_" + file_name
            
            # 执行重命名
            # 注意：AssetDatabase.RenameAsset 只需要新文件名，不需要完整路径
            error_msg = AssetDatabase.RenameAsset(asset_path, new_name)
            
            if not error_msg:
                print(f"[SUCCESS] 重命名: {file_name} -> {new_name}")
                renamed_count += 1
            else:
                # 如果重命名失败（例如文件被占用或重名），打印错误信息
                print(f"[ERROR] 无法重命名 {file_name}: {error_msg}")

    # 只有在确实发生修改时，才执行保存和刷新，优化编辑器性能
    if renamed_count > 0:
        # 保存资源修改并刷新磁盘缓存
        AssetDatabase.SaveAssets()
        AssetDatabase.Refresh()
        
    print("--- [TA] 扫描任务结束 ---")
    print(f"统计结果: 已修复: {renamed_count} | 已忽略非.mat资源: {ignored_count}")

# ----------------------------------------------------------------
# 执行入口
# ----------------------------------------------------------------
if __name__ == "__main__":
    fix_mat_prefixes_v2()