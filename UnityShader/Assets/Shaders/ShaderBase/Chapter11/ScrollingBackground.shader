Shader "Custom/ScrollingBackground"
{
    Properties
    {
        _MainTex ("Base Layer (RGB)", 2D) = "white" {}
        _DetailTex ("2nd Layer (RGB)", 2D) = "white" {}
        _ScrollX ("Base layer Scroll Speed", Float) = 1.0
        _Scroll2X ("2nd layer Scroll Speed", Float) = 1.0
        _Multiplier ("Layer Multiplier", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _DetailTex_ST;
                float _ScrollX;
                float _Scroll2X;
                float _Multiplier;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_DetailTex);
            SAMPLER(sampler_DetailTex);
        ENDHLSL

        Pass
        {
            Tags {"LightMode" = "UniversalForward"}

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
                    float4 uv : TEXCOORD1;
                };

                Varyings vert(Attributes input)
                {
                    Varyings output = (Varyings)0;
                    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                    float2 uvMain = TRANSFORM_TEX(input.uv, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
                    float2 uvDetail = TRANSFORM_TEX(input.uv, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
                    
                    output.uv = float4(uvMain, uvDetail);

                    return output;
                }

                half4 frag(Varyings input) : SV_Target
                {
                    half4 firstLayer = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, input.uv.xy);
                    half4 secondLayer = SAMPLE_TEXTURE2D(_DetailTex,sampler_DetailTex, input.uv.zw);

                    half4 c = lerp(firstLayer, secondLayer, secondLayer.a);
                    c.rgb *= _Multiplier;

                    return c;
                }
            ENDHLSL
        }
        
    }
    Fallback "Hidden/Universal Render Pipeline/FallbackError"
    // FallBack "Universal Render Pipeline/Unlit"
}
