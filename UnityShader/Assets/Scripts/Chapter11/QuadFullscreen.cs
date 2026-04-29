using UnityEngine;
/// <summary>
/// 自动调整Quad位置及大小 充满正交相机视野范围
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer))]
public class QuadFullscreen : MonoBehaviour
{
    [SerializeField] private Camera targetCamera;
    [SerializeField] private float distance = 10f;
    [SerializeField] private bool followCamera = true;
    
    private float lastAspect; // 缓存上次的屏幕宽高比，用于检测变化
    
    void Start()
    {
        targetCamera ??= Camera.main;
        UpdateSize();
    }
    
    void Update()
    {
        // 检测当前宽高比与缓存值差异，阈值0.001避免浮点误差
        if (Mathf.Abs(targetCamera.aspect - lastAspect) > 0.001f)
            UpdateSize();
    }
    
    void LateUpdate()
    {
        if (!followCamera) return; // 若不跟随摄像机，直接退出
        // 设置位置：摄像机位置 + 摄像机前方向量 × 距离
        transform.position = targetCamera.transform.position + targetCamera.transform.forward * distance;
        // 设置旋转：与摄像机相同朝向（面向摄像机前方）
        transform.rotation = targetCamera.transform.rotation;
    }
    
    private void UpdateSize()
    {
        float height = 2f * distance * Mathf.Tan(targetCamera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        float width = height * targetCamera.aspect;
        transform.localScale = new Vector3(width, height, 1f);
        lastAspect = targetCamera.aspect;
    }
}
