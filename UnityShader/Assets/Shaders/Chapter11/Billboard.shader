Shader "Custom/ShaderBase/Chapter11/Billboard"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "DisableBatching" = "True"
        }

        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;
                float _VerticalBillboarding;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
        ENDHLSL
        
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha // 标准透明混合 最终颜色 = 源颜色 × 源Alpha + 目标颜色 × (1 - 源Alpha)
            Cull Off

            HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                struct Attributes
                {
                    float4 positionOS : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float2 uv : TEXCOORD0;
                };

                Varyings vert(Attributes input)
                {
                    Varyings output = (Varyings)0;
                    // Suppose the center in object space is fixed
                    float3 center = float3(0, 0, 0);
                    float3 viewer = TransformWorldToObject(_WorldSpaceCameraPos);

                    float3 normalDir = viewer - center;
                    // If _VerticalBillboarding = 1, we use the desired view dir as the normal dir, which means the normal dir is fixed;
                    // Or if _VerticalBillboarding = 0, the y of normal is 0, which means the up dir is fixed
                    // 防止零向量
                    float lenSq = dot(normalDir, normalDir);
                    if (lenSq < 0.0001)
                    {
                        normalDir = float3(0, 0, 1);  // 默认朝向 Z 轴
                    }
                    else
                    {
                        normalDir.y *= _VerticalBillboarding;
                        normalDir = normalize(normalDir);
                    }

                    // Get the approximate up dir
                    // If normal dir is already towards up, then the up dir is towards front
                    float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                    float3 rightDir = normalize(cross(upDir, normalDir));
                    upDir = normalize(cross(normalDir, rightDir));

                    float3 centerOffs = input.positionOS.xyz - center;
                    float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y +normalDir * centerOffs.z;

                    output.positionCS = TransformObjectToHClip(localPos);

                    output.uv = TRANSFORM_TEX(input.uv, _MainTex);

                    return output;
                }

                half4 frag(Varyings input) : SV_Target
                {
                    float4 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                    c.rgb *= _Color.rgb;

                    return c;
                }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    // FallBack "Universal Render Pipeline/Unlit"
}
