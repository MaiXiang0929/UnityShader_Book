Shader "Custom/ShaderBase/Chapter11/Water"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
        _Magnitude ("Distortion Magnitude", Float) = 1
        _Frequency ("Diatortion Frequency", Float) = 1
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
        _Speed ("Speed", Float) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "DisableBatching" = "True"
        }

        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;
                float _Magnitude;
                float _Frequency;
                float _InvWaveLength;
                float _Speed;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
        ENDHLSL

        Pass
        {
            Tags {"LightMode" = "UniversalForWard"}

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
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

                    float4 offset;
                    offset.yzw = float3(0.0, 0.0, 0.0);
                    offset.x = sin(_Frequency * _Time.y + input.positionOS.x * _InvWaveLength + input.positionOS.y * _InvWaveLength + input.positionOS.z * _InvWaveLength) * _Magnitude;

                    output.positionCS = TransformObjectToHClip(input.positionOS.xyz + offset);

                    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                    output.uv += float2(0.0, _Time.y * _Speed);

                    return output;
                }

                half4 frag(Varyings input) : SV_Target
                {
                    half4 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                    c.rgb *= _Color.rgb;

                    return c;
                }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    // FallBack "Universal Render Pipeline/Unlit"
}
