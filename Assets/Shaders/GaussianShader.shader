Shader "Custom Post-Processing/Gaussian Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _spread("Standard Deviation", Float) = 0
        _gridSize("Grid Size", Integer) = 1
    }
    SubShader
    {

        Cull Off ZWrite Off ZTest Always

        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #define E 2.71828f

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        uint _gridSize;
        float _spread;

        float gaussian(int x)
        {
            float sigmaSqu = _spread * _spread;
            return (1.0 / sqrt(TWO_PI * sigmaSqu)) * pow(E, -(x * x) / (2 * sigmaSqu));
        }

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
            o.vertex = TransformObjectToHClip(v.vertex.xyz);
            o.uv = v.uv;
            return o;
        }

        ENDHLSL

        Pass
        {
            Name "Horizontal"
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag_horizontal

            float4 frag_horizontal(v2f i) : SV_Target
            {
                float3 col = float3(0.0f, 0.0f, 0.0f);
                float gridSum = 0.0f;

                int upper = ((_gridSize - 1) / 2);
                int lower = -upper;

                for (int x = lower; x <= upper; ++x)
                {
                    float gauss = gaussian(x);
                    gridSum += gauss;
                    float2 uv = i.uv + float2(_MainTex_TexelSize.x, 0.0f);
                    col += gauss * tex2D(_MainTex, uv).xyz;
                }

                col /= gridSum;
                return float4(col, 1.0f);

            }

            ENDHLSL
        }

        Pass
        {
            Name "Vertical"

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag_vertical

            float4 frag_vertical(v2f i) : SV_Target
            {
                float3 col = float3(0.0f, 0.0f, 0.0f);
                float gridSum = 0.0f;

                int upper = ((_gridSize - 1) / 2);
                int lower = -upper;

                for (int y = lower; y <= upper; ++y)
                {
                    float gauss = gaussian(y);
                    gridSum += gauss;
                    float2 uv = i.uv + float2(0.0f, _MainTex_TexelSize.y * y);
                    col += gauss * tex2D(_MainTex, uv).xyz;
                }
                    
                col /= gridSum;
                return float4(col, 1.0f);
            }
                ENDHLSL
        }
    }
}
