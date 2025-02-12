Shader "Custom Post-Processing/BnW"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _blend("B & W blend", Range(0,1)) = 0
    }
        SubShader
        {
            Cull Off ZWrite Off ZTest Always

            Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                uniform sampler2D _MainTex;
                uniform float _blend;

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
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                   float4 c = tex2D(_MainTex, i.uv);

                   float lum = c.r * .3 + c.g * .59 + c.b * .11;

                   float3 bwc = float3(lum, lum, lum);

                   float4 result = c;

                   result.rgb = lerp(c.rgb, bwc, _blend);
                   return result;
                }
                ENDHLSL
            }
        }
}