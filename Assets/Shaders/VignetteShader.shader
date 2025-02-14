Shader "Custom Post-Processing/Vignette"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Radius("Radius", Float) = 1
        _Feather("Feather", Float) = 1
        _Tint("Tint", Color) = (0,0,0)
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
                uniform float _Radius;
                uniform float _Feather;
                uniform float4 _Tint;

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

                   float2 newUV = i.uv * 2 - 1;
                   float circle = length(newUV);
                   float mask = 1 - smoothstep(_Radius, _Radius + _Feather, circle);
                   float invertMask = 1 - mask;

                   float3 displayColor = c.rgb * mask;
                   float3 vignetteColor = (1 - c.rgb) * invertMask * _Tint;

                   return fixed4(vignetteColor + displayColor * mask,1);
                }
                ENDHLSL
            }
        }
}