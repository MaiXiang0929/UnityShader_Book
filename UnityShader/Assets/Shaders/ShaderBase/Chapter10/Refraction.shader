Shader "Custom/ShaderBase/Chapter10/Refraction"
{
    Properties
    {
        [Header(Base Settings)]
        _BaseColor ("Color Tint", Color) = (1, 1, 1, 1)
        _RefractionColor ("Refraction Color", Color) = (1, 1, 1, 1)
        _RefractionAmount ("Refraction Amount", Range(0, 1)) = 1
        _RefractionRatio ("Refraction Ratio (IOR)", Range(0.1, 1)) = 0.5

        [Header(Skybox Settings)]
        [NoScaleOffset] _Cubemap ("Refraction Cubemap", Cube) = "_Skybox" {}

        [Header(Box Projection Settings)]
        [Vector3] _BoxCenter ("Room Center (World)", Vector) = (0, 0, 0, 0)
        [Vector3] _BoxMin ("Room Min (World)", Vector) = (-5, -5, -5, 0)
        [Vector3] _BoxMax ("Room Max (World)", Vector) = (5, 5, 5, 0)
    }

    SubShader
    {
        Tags
        { 
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue"="Geometry"
        }

        HLSLINCLUDE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _RefractionColor;
                float _RefractionAmount;
                float _RefractionRatio;
                float3 _BoxCenter;
                float3 _BoxMin;
                float3 _BoxMax;
            CBUFFER_END

            TEXTURECUBE(_Cubemap);
            SAMPLER(sampler_Cubemap);

        ENDHLSL

        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}

            HLSLPROGRAM

                // #pragma multi_compile_forwardplus // 启用 Forward+ 渲染路径，支持多光源优化及多反射探针混合
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS // 主光源阴影开关
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE // 主光源级联阴影开关
                #pragma multi_compile _ _SHADOWS_SOFT // 阴影平滑开关

                #pragma vertex vert
                #pragma fragment frag

                struct Attributes
                {
                    float4 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                };

                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS : TEXCOORD0;
                    float3 normalWS : TEXCOORD1;
                };

                Varyings vert(Attributes input)
                {
                    Varyings output = (Varyings)0;
                    
                    // position
                    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                    output.positionCS = vertexInput.positionCS;
                    output.positionWS = vertexInput.positionWS;
                    
                    // normal
                    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
                    output.normalWS = normalInput.normalWS;
                    
                    return output;
                }

                half4 frag(Varyings input) : SV_Target
                {
                    // 1. 获取光照信息
                    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                    Light mainLight = GetMainLight(shadowCoord);
                    
                    half3 normalWS = normalize(input.normalWS);
                    half3 viewDirWS = normalize(GetWorldSpaceViewDir(input.positionWS));
                    half3 lightDirWS = normalize(mainLight.direction);

                    // 2. 环境光 (SH)
                    half3 ambient = SampleSH(normalWS);

                    // 3. 漫反射 (Diffuse)
                    half diff = saturate(dot(normalWS, lightDirWS));
                    half3 diffuse = mainLight.color * _BaseColor.rgb * diff;

                    // 4. 折射 (Refraction)
                    // 在像素着色器重新计算折射方向，效果更细腻
                    float3 refractDirWS = refract(-viewDirWS, normalWS, _RefractionRatio);
                    half3 refraction = SAMPLE_TEXTURECUBE(_Cubemap, sampler_Cubemap, refractDirWS).rgb * _RefractionColor.rgb;

                    // 5. 颜色混合
                    // 结合主光源阴影、漫反射和折射
                    half3 finalColor = ambient + lerp(diffuse, refraction, _RefractionAmount) * mainLight.shadowAttenuation;

                    return half4(finalColor, 1.0);
                }

            ENDHLSL
        }
        //     struct v2f {
        //         float4 pos : SV_POSITION;
        //         float3 worldPos : TEXCOORD0;
        //         float3 worldNormal : TEXCOORD1;
        //         float3 worldViewDir : TEXCOORD2;
        //         float3 worldRefr : TEXCOORD3;
        //         SHADOW_COORDS(4)
        //     };

        //     v2f vert(a2v v) {
        //         v2f o;
        //         o.pos = UnityObjectToClipPos(v.vertex);

        //         o.worldNormal = UnityObjectToWorldNormal(v.normal);

        //         o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

        //         o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

        //         // compute the refract dir in world space
        //         o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractionRatio);

        //         TRANSFER_SHADOW(o);

        //         return o;
        //     }

        //     fixed4 frag(v2f i) : SV_Target {
        //         fixed3 worldNormal = normalize(i.worldNormal);
        //         fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        //         fixed3 worldViewDir = normalize(i.worldViewDir);

        //         fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

        //         fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

        //         // use the refract dir in world space to access the cubemap
        //         fixed3 refraction = texCUBE(_Cubemap, i.worldRefr).rgb * _RefractionColor.rgb;

        //         UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

        //         // mix the diffuse color with the refract color
        //         fixed3 color = ambient + lerp(diffuse, refraction, _RefractionAmount) * atten;
                
        //         return fixed4(color, 1.0);
        //     }

        //     ENDCG
            
        // }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    //项目中用
    //FallBack "Universal Render Pipeline/Lit"
}
