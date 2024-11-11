Shader "Custom/DirectionalLightShader"
{
	Properties{
		_mainTexture("MainTexture", 2D) = "white"{}
		_subTexture("SubTexture", 2D) = "white"{}
		_tint("Tint", Color) = (1,1,1,1)
		_alphaCutOff("AlphaCutOff", Range(0, 1)) = 0.5
		_mainTexAlpha("MainTextureAlpha", Range(0,1)) = 0.5
		_subTexAlpha("SubTextureAlpha", Range(0,1)) = 0.5
	}

		SubShader{
			Tags{"Queue" = "Transparent" "Rendertype" = "Transparent"}
			Blend SrcAlpha OneMinusSrcAlpha
			Pass {

				HLSLPROGRAM
				#include "UnityCG.cginc"

				#pragma vertex MyVertexShader
				#pragma fragment MyFragmentShader
				uniform float4 _tint;
				uniform sampler2D _mainTexture;
				uniform sampler2D _subTexture;
				uniform float4 _mainTexture_ST;
				uniform float _alphaCutOff;

				uniform float _mainTexAlpha;
				uniform float _subTexAlpha;


				struct vertexData {
					float2 uv: TEXCOORD0;
					float4 position: POSITION;
					float3 normal: NORMAL;
				};

				struct vertex2Fragment
				{
					float2 uv : TEXCOORD0;
					float4 position : SV_POSITION;
					float3 normal: NORMAL;
				};

				vertex2Fragment MyVertexShader(vertexData vd)
				{
					vertex2Fragment v2f;
					v2f.position = UnityObjectToClipPos(vd.position);					
					v2f.uv = TRANSFORM_TEX(vd.uv, _mainTexture);
					v2f.normal = vd.normal;

					return v2f;
				}

				float4 MyFragmentShader(vertex2Fragment v2f) : SV_TARGET
				{
					float4 mainTexColor = tex2D(_mainTexture, v2f.uv);
					float4 subTexColor = tex2D(_subTexture, v2f.uv);

					float4 result = _tint * (mainTexColor * subTexColor);
					clip(result.a - _alphaCutOff);
					return result;
				}


			ENDHLSL
		}
	}
}
