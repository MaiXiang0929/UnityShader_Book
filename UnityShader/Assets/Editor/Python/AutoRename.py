import os
from UnityEditor import AssetDatabase, Selection, EditorUtility

def fix_selected_material_prefixes():

    # 弹出 Unity 标准对话框，确认用户意图，防止误操作
    is_confirmed = EditorUtility.DisplayDialog(
        "TA Rename Tool", 
        "你确定要重命名选中文件夹下的所有材质球吗？", 
        "确定", 
        "取消"
    )
    
    # 如果用户点击“取消”，则打印日志并退出函数
    if not is_confirmed:
        print("[TA] Operation cancelled by user.")
        return
    
    # 获取当前在 Unity Project 窗口中选中物体的 GUID（全局唯一标识符）列表
    selected_guids = Selection.assetGUIDs
    print("Selected GUIDs Count: " + str(len(selected_guids)))
    
    # 如果没有选中任何物体，打印错误提示并返回
    if not selected_guids:
        print("[TA] Error: No selection detected by Python!")
        return

    renamed_count = 0 # 计数器：记录成功重命名的材质球数量
    
    # 遍历所有选中的物体（通常是文件夹）
    for folder_guid in selected_guids:
        # 将 GUID 转换为 Unity 工程内的相对路径
        folder_path = AssetDatabase.GUIDToAssetPath(folder_guid)
        print("Processing Folder: " + folder_path) 
        
        # 在指定的文件夹路径下搜索类型为 "Material" 的资源，返回它们的 GUID 列表
        guids = AssetDatabase.FindAssets("t:Material", [folder_path])
        print("Materials found in this folder: " + str(len(guids)))
        
        # 遍历找到的所有材质球
        for guid in guids:
            path = AssetDatabase.GUIDToAssetPath(guid)
            # 安全检查：确保文件扩展名确实是 .mat（排除干扰项）
            if not path.lower().endswith(".mat"):
                continue
                
            filename = os.path.basename(path)

             # 检查文件名是否已经以 "M_" 开头
            if not filename.startswith("M_"):
                new_name = "M_" + filename

                # 调用 Unity API 执行重命名操作
                # 注意：RenameAsset 成功时返回空字符串，失败时返回错误消息
                error = AssetDatabase.RenameAsset(path, new_name)
                if not error:
                    renamed_count += 1
                else:
                    print("Rename Error: " + error)

     # 如果有任何文件被修改，执行保存和刷新操作
    if renamed_count > 0:
        AssetDatabase.SaveAssets() # 保存
        AssetDatabase.Refresh() # 刷新
    
        print("TA Task: Renamed " + str(renamed_count) + " materials.")

# 脚本入口：执行定义的重命名函数
fix_selected_material_prefixes()