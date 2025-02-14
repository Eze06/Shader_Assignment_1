Shader "Custom Post-Processing/Outline"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineThickness("Outline Thickness", Float) = 1.0
    }

        SubShader
        {
            Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
            Cull Back
            ZWrite On
            HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            ENDHLSL

            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                sampler2D _MainTex;
                float4 _OutlineColor;
                float _OutlineThickness;
                float4 _MainTex_TexelSize;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = TransformObjectToHClip(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    float4 baseColor = tex2D(_MainTex, i.uv);

                    float2 offset = _OutlineThickness * _MainTex_TexelSize.xy;

                    float4 left = tex2D(_MainTex, i.uv + float2(-offset.x, 0));
                    float4 right = tex2D(_MainTex, i.uv + float2(offset.x, 0));
                    float4 top = tex2D(_MainTex, i.uv + float2(0, offset.y));
                    float4 bottom = tex2D(_MainTex, i.uv + float2(0, -offset.y));

                    float outline = step(0.5, left.a) + step(0.5, right.a) + step(0.5, top.a) + step(0.5, bottom.a);
                    outline = step(1, outline); 

                    return float4(outline * _OutlineColor.rgb + baseColor.rgb * (1 - outline), 1);
                }
                ENDHLSL
            }
        }
}