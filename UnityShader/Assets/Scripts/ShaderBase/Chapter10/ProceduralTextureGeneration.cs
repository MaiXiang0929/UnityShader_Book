using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;

    #region Material properties
    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 512;
    public int textureWidth
    {
        get { return m_textureWidth; }
        set
        {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    #endregion

    private void _UpdateMaterial()
{
    if (material != null)
    {
       
    }
}
}


