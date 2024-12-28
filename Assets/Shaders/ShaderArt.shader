Shader "Custom/ShaderArt"
{
    Properties
    {
        _numIterations("Num Interations", Integer) = 1

    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            #include "UnityCG.cginc"
            uniform int _numIterations;

            
            struct vertexData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vertexShader(vertexData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float3 palette(float t)
            {
                float3 a = float3(0.5, 0.5, 0.5);
                float3 b = float3(0.5, 0.5, 0.5);
                float3 c = float3(1.0, 1.0, 1.0);
                float3 d = float3(0.263, 0.416, 0.557);

                return a + b * cos(6.28 * (c * t * d));
            }

            float4 fragmentShader(v2f i) : SV_Target
            {
                float3 finalColor = float3(0.0, 0.0, 0.0);
                i.uv = i.uv - 0.5;
                i.uv = i.uv * 2.0;

                float2 uv0 = i.uv;

                for (int index = 0; index < _numIterations; index++)
                {

                    i.uv = frac(i.uv * 2.0) - 0.5;


                    float d = length(i.uv) * exp(-length(uv0));

                    float3 col = float3(palette(length(uv0) + _Time.y));
                    d = sin(d * 8.0 + _Time.y) / 8.0f;
                    d = abs(d);

                    d = pow(0.01 / d, 1.2);

                    finalColor += col * d;
                }

                
                return float4(finalColor, 1);
            }

            ENDHLSL
        }
    }
}
