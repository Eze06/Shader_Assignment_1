Shader "Custom/ReflectionShader"
{
	Properties{
		_mainTexture("Diffuse Texture", 2D) = "white"{}
		_normalTexture("Normal Texture", 2D) = "white"{}
		_reflectionTexture("Reflection Texture", Cube) = "white"{}

		_useNormalMap("Use Normal Map", Range(0,1)) = 0
		_useReflectionMap("Use Reflection Map", Range(0,1)) = 0
		_reflectionPower("Reflection Power", Range(0,20)) = 20.0

		_tint("Tint", Color) = (1,1,1,1) 
		_alphaCutOff("AlphaCutOff", Range(0, 1)) = 0.5
		_mainTexAlpha("MainTextureAlpha", Range(0,1)) = 0.5
		_lightPosition("Light Position", Vector) = (0,0,0)
		_lightDirection("Light Direction", Vector) = (0,-1,0)
		_lightColor("Light Color", Color) = (1,1,1,1)
		_specularStrength("Specular Strength", Range(0,1)) = 0.5
		_smoothness("Smoothness", Range(0,1)) = 0.5
		_lightType("Light Type", Integer) = 1
		_lightIntensity("Light Intensity", float) = 1
		_attenuation("Light Attenuation", Vector) = (1.0, 0.09, 0.032)
		_spotLightCutOff("Spot Light CutOff", Range(0, 360)) = 70.0
		_spotLightInnerCutOff("Spot Light Inner CutOff", Range(0,360)) = 25.0

		_numLights("Num Lights", Integer) = 1

		_shadowSoftness("Shadow Softness", Float) = 1.0

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
				uniform sampler2D _normalTexture;
				uniform samplerCUBE _reflectionTexture;

				uniform float4 _mainTexture_ST;
				uniform float _alphaCutOff;

				uniform float _useNormalMap;
				uniform float _useReflectionMap;
				uniform float _reflectionPower;

				uniform float _mainTexAlpha;

				uniform int _numLights;


				uniform sampler2D _ShadowMap0;
				uniform sampler2D _ShadowMap1; 
				uniform sampler2D _ShadowMap2;


				uniform float4x4 _LightViewProj0;
				uniform float4x4 _LightViewProj1; 
				uniform float4x4 _LightViewProj2;

				uniform float _shadowBias;
				uniform float _shadowSoftness;

				uniform float _specularStrength;

				float ShadowCalculation(float4 fragPosLightSpace, sampler2D _shadowMap);


				struct vertexData {
					float2 uv: TEXCOORD0;
					float4 position: POSITION;
					float3 normal: NORMAL;
					float3 tangent : TANGENT;
				};

				struct vertex2Fragment
				{
					float2 uv : TEXCOORD0;
					float4 position : SV_POSITION;
					float3 normal: NORMAL;
					float3 binormal : BINORMAL;
					float3 tangent : TANGENT;
					float3 worldPosition : POSITION1;
					float4 shadowCoord: POSITION2;
				};

				struct Light
				{
					float3 _lightPosition;
					float3 _lightDirection;
					float4 _lightColor;
					float _smoothness;
					int _lightType;
					float _lightIntensity;
					float3 _attenuation;
					float _spotLightCutOff;
					float _spotLightInnerCutOff;
				};

				StructuredBuffer<Light> _lights;

				vertex2Fragment MyVertexShader(vertexData vd)
				{
					vertex2Fragment v2f;
					v2f.position = UnityObjectToClipPos(vd.position);	
					v2f.worldPosition = mul(unity_ObjectToWorld, vd.position);
					v2f.uv = TRANSFORM_TEX(vd.uv, _mainTexture);
					v2f.normal = UnityObjectToWorldNormal(vd.normal);
					float3 binormal = cross(vd.normal, vd.tangent);
					v2f.binormal = UnityObjectToWorldNormal(binormal);
					v2f.tangent = UnityObjectToWorldNormal(vd.tangent);


					return v2f;
				}

				float4 MyFragmentShader(vertex2Fragment v2f) : SV_TARGET
				{

					v2f.normal = normalize(v2f.normal);
					v2f.binormal = normalize(v2f.binormal);
					v2f.tangent = normalize(v2f.tangent);

					float4 albedo = tex2D(_mainTexture, v2f.uv) * _tint;
					
					float3 Normal;
					if (_useNormalMap >= 0.5f)
					{
						float4 normalTex = tex2D(_normalTexture, v2f.uv) * 2 - 1;
						float3x3 TBN = float3x3(v2f.tangent, v2f.binormal, v2f.normal);
						Normal = normalize(mul(normalTex, TBN));
					}
					else
					{
						Normal = v2f.normal;
					}
					float3 specular;
					float3 specularColor;
					float3 diffuse;
					float3 finalColor;


					for (int i = 0; i < _numLights; i++)
					{
						if (albedo.a < _alphaCutOff)
							discard;

						float shadowFactor;

						if (i == 0)
						{
							v2f.shadowCoord = mul(_LightViewProj0, float4(v2f.worldPosition, 1.0));
							shadowFactor = ShadowCalculation(v2f.shadowCoord, _ShadowMap0);

						}
						else if (i == 1)
						{
							v2f.shadowCoord = mul(_LightViewProj1, float4(v2f.worldPosition, 1.0));
							shadowFactor = ShadowCalculation(v2f.shadowCoord, _ShadowMap1);

						}
						else if (i == 2)
						{
							v2f.shadowCoord = mul(_LightViewProj2, float4(v2f.worldPosition, 1.0));
							shadowFactor = ShadowCalculation(v2f.shadowCoord, _ShadowMap2);

						}

						float3 finalLightDirection;
						float3 attenuation = 1.0;

						if (_lights[i]._lightType == 0) //If light is directional Light
						{
							finalLightDirection = _lights[i]._lightDirection;
						}
						else //if spot light / point light
						{
							finalLightDirection = normalize(v2f.worldPosition - _lights[i]._lightPosition);


							float distance = length(v2f.worldPosition - _lights[i]._lightPosition);
							attenuation = 1.0 / (_lights[i]._attenuation.x + _lights[i]._attenuation.y * distance + _lights[i]._attenuation.z * distance * distance);

							if (_lights[i]._lightType == 2)
							{

								float theta = dot(finalLightDirection, _lights[i]._lightDirection);
								float angle = cos(radians(_lights[i]._spotLightCutOff));
								if (theta > angle)
								{
									float epsilon = cos(radians(_lights[i]._spotLightInnerCutOff)) - angle;
									float intensity = clamp((theta - angle) / epsilon, 0.0, 1.0);
									attenuation *= intensity;
								}
								else
								{
									attenuation = 0.0;
								}
							}

						}

						float3 viewDirection = normalize(_WorldSpaceCameraPos - v2f.worldPosition);
						/*if ()
						{

						}*/
						//float4 fresnel = pow((1 - dot(viewDirection, v2f.normal)), 5);

						float3 reflectionDirection = reflect(-viewDirection, v2f.normal);
						reflectionDirection.yz = reflectionDirection.zy;
						float4 reflection = texCUBE(_reflectionTexture, reflectionDirection) * _reflectionPower;

						float3 halfVector = normalize((viewDirection - finalLightDirection));


						specular += pow(float(saturate(dot(Normal, halfVector))), _lights[i]._smoothness * 100) ;
						specularColor += specular * _specularStrength * _lights[i]._lightColor.rgb;
						diffuse += albedo.xyz * _lights[i]._lightColor * saturate(dot(-finalLightDirection, Normal)) * reflection;
						finalColor += (specularColor + diffuse) * _lights[i]._lightIntensity * attenuation * shadowFactor;
					}
				
					
					return float4(finalColor, albedo.a);

				}

				float ShadowCalculation(float4 fragPosLightSpace, sampler2D _shadowMap)
				{
					float3 shadowCoord = fragPosLightSpace.xyz / fragPosLightSpace.w;
					shadowCoord = shadowCoord * 0.5 + 0.5;

					if (shadowCoord.x < 0.0 || shadowCoord.x > 1.0 || shadowCoord.y < 0.0 || shadowCoord.y > 1.0)
					{
						return 1.0;
					}

					const int pcfSamples = 4;
					float shadowFactor = 0.0;
					float sampleRadius = lerp(1.0 / 4096, 1.0 / 500.0, shadowCoord.z);

					for (int x = -pcfSamples; x <= pcfSamples; x++)
					{
						for (int y = -pcfSamples; y <= pcfSamples; y++)
						{
							float2 offset = float2(x, y) * sampleRadius;
							float shadowDepth = tex2D(_shadowMap, shadowCoord.xy + offset).r;

							shadowFactor += (shadowCoord.z - _shadowBias > (1.0 - shadowDepth)) ? 0.0 : 1.0;
						}
					}

					shadowFactor /= pow((pcfSamples * 2 + 1), 2);

					return saturate(shadowFactor);
				}

			ENDHLSL
		}
	}
}
	