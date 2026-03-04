using UnityEngine;

[ExecuteInEditMode]
// Box大小可视化调节脚本
// 适用于静态场景，数值调好后将挂载该脚本的空物体删除即可
public class BoxProjectionVolume : MonoBehaviour
{
    public Material targetMaterial; // 目标反射材质

    void Update()
    {
        if (targetMaterial == null) return;

        // 计算 AABB 的 Min 和 Max
        Vector3 center = transform.position;
        Vector3 size = transform.localScale;
        Vector3 min = center - size * 0.5f;
        Vector3 max = center + size * 0.5f;

        // 自动将数据传递给 Shader
        targetMaterial.SetVector("_BoxCenter", new Vector4(center.x, center.y, center.z, 0));
        targetMaterial.SetVector("_BoxMin", new Vector4(min.x, min.y, min.z, 0));
        targetMaterial.SetVector("_BoxMax", new Vector4(max.x, max.y, max.z, 0));
    }

    // 在 Scene 窗口画一个绿色的框，方便观察
    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.green;
        Gizmos.matrix = transform.localToWorldMatrix;
        Gizmos.DrawWireCube(Vector3.zero, Vector3.one);
        
        // 画出中心点
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(Vector3.zero, 0.1f);
    }
}