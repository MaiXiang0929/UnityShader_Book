# UnityShader_Practice

&emsp;&emsp;本项目是《Unity Shader入门精要》的学习笔记与代码实现，涵盖书中主要 Shader 案例，用于巩固渲染管线、光照模型、纹理映射、屏幕后处理、非真实感渲染、基于物理的渲染等核心概念。
This project is the learning note and code implementation of 《Unity Shader 入门精要》, covering the main Shader cases in the book. It is used to reinforce core concepts such as the rendering pipeline, lighting models, texture mapping, post-screen processing, non-photorealistic rendering, and physically-based rendering.

---

## 开发环境

- **Unity Editor**: 2022.3.62f3（LTS）
- **渲染管线**: Universal Render Pipeline(URP)
- **平台**: Windows

---

## 文件夹说明

| 文件夹 | 内容说明 |
|--------|---------|
| `Assets/Animation/` | 动画资源 |
| `../Editor/` | 自定义编辑器扩展脚本 |
| `../Materials/` | 各章节对应的材质球（`.mat`），按章节子文件夹组织 |
| `../Models/` | 公共模型资源 |
| `../Prefabs/` | 预制体 |
| `../Scenes/` | 各章节的演示场景（`.unity`），按章节子文件夹组织 |
| `../Scripts/` | C# 脚本，按章节子文件夹组织 |
| `../Settings/` | 项目设置相关 |
| `../Shaders/` | **核心文件夹**，包含所有 Shader 代码（`.shader`），按章节子文件夹组织 |
| `../Textures/` | 纹理资源，按章节子文件夹组织 |

---

## 主要内容

### Ch03 ShaderLab 基础
- **内容**: 第一个 Shader、Properties 属性类型、SubShader 结构
- **路径**:
  - Shader: `Shaders/Ch03/`
  - 材质: `Materials/Ch03/`
  - 场景: `Scenes/Ch03.unity`

---

## 效果展示

（此处放截图）

---

## 参考

- 冯乐乐. 《Unity Shader入门精要》. 人民邮电出版社, 2016.