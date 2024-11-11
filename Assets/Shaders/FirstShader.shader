Shader "Custom/FirstShader"
{
	Properties{
		_tint("Tint", Color) = (1,1,1,1)
	}

		SubShader{
			Pass {

				HLSLPROGRAM
				#include "UnityCG.cginc"

				#pragma vertex MyVertexShader
				#pragma fragment MyFragmentShader
				float4 _tint;

				struct fragmentVertex {
					float2 uv: TEXCOORD0;
					float4 position: SV_POSITION;
				};

				fragmentVertex MyVertexShader(float4 position : POSITION, float2 uv: TEXCOORD0)
				{
					fragmentVertex fv;
					fv.position = UnityObjectToClipPos(position);
					fv.uv = uv;
					return fv;
				}

				float4 MyFragmentShader(fragmentVertex fv) : SV_TARGET
				{
					return float4(_tint * fv.uv , 0, 1.0f);
				}


			ENDHLSL
		}
   }
}
