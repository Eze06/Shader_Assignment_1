Shader "Custom/WaterShader"
{
	Properties{
		_mainTexture("Albedo", 2D) = "white"{}
		_subTexture("SubTexture", 2D) = "white"{}

		_reflectionTexture("Reflection Texture", Cube) = "white"{}

		_tint("Tint", Color) = (1,1,1,1)
		_mainTexAlpha("MainTextureAlpha", Range(0,1)) = 0.5
		_subTexAlpha("SubTextureAlpha", Range(0,1)) = 0.5

			//Wave properties
		_waveCount("Wave Count", Integer) = 4

		_lightPosition("Light Position", Vector) = (0,0,0)
		_lightDirection("Light Direction", Vector) = (0,-1,0)
		_lightColor("Light Color", Color) = (1,1,1,1)
		_specularStrength("Specular Strength", Range(0,1)) = 0.5
		_smoothness("Smoothness", Range(0,1)) = 0.5
		_alphaCutOff("AlphaCutOff", Range(0, 1)) = 0.5

		_numLights("Num Lights", Integer) = 1
		_lightType("Light Type", Integer) = 1
		_lightIntensity("Light Intensity", float) = 1
		_attenuation("Light Attenuation", Vector) = (1.0, 0.09, 0.032)
		_spotLightCutOff("Spot Light CutOff", Range(0, 360)) = 70.0
		_spotLightInnerCutOff("Spot Light Inner CutOff", Range(0,360)) = 25.0
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
				uniform samplerCUBE _reflectionTexture;

				uniform float4 _mainTexture_ST;
				uniform float _alphaCutOff;

				uniform float _mainTexAlpha;
				uniform float _subTexAlpha;

				//Wave Data
				uniform int _waveCount;

				//Light Data
				uniform float3 _lightPosition;
				uniform float3 _lightDirection;
				uniform float4 _lightColor;
				uniform float _specularStrength;
				uniform float _smoothness;
				uniform int _lightType;
				uniform float _lightIntensity;
				uniform float3 _attenuation;
				uniform float _spotLightCutOff;
				uniform float _spotLightInnerCutOff;

				uniform sampler2D _shadowMap;
				uniform float4x4 _lightViewProj;
				uniform float _shadowBias;

				uniform int _numLights;


				uniform sampler2D _ShadowMap0;
				uniform sampler2D _ShadowMap1;
				uniform sampler2D _ShadowMap2;


				uniform float4x4 _LightViewProj0;
				uniform float4x4 _LightViewProj1;
				uniform float4x4 _LightViewProj2;


				float ShadowCalculation(float4 fragPosLightSpace, sampler2D _shadowMap);

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

				struct Waves
				{
					float amplitude;
					float wavelength;
					float speed;
					float3 direction;
				};

				uniform StructuredBuffer<Waves> _waves;
				uniform StructuredBuffer<Light> _lights;

				float getWaveHeight (float3 pos, float time)
				{
					float height = 0.0;
					for (int i = 0; i < _waveCount; i++)
					{
						float dotProd = dot(normalize(_waves[i].direction), pos.xz);
						float phaseConstant = _waves[i].speed * (2.0f / _waves[i].wavelength);
						height += _waves[i].amplitude * exp(sin(dotProd + _waves[i].wavelength + time * phaseConstant)-1);
					}
					return height;
				}

				vertex2Fragment MyVertexShader(vertexData vd)
				{
					vertex2Fragment v2f;

					float waveHeight = getWaveHeight(vd.position, _Time.y);
					float delta = 0.01;

					float heightX = getWaveHeight(vd.position + float3(delta, 0, 0), _Time.y);
					float heightZ = getWaveHeight(vd.position + float3(0, 0, delta), _Time.y);

					float3 gradientX = float3(delta, heightX - waveHeight, 0);
					float3 gradientZ = float3(0, heightZ - waveHeight, delta);

					float3 normal = normalize(cross(gradientZ, gradientX));

					v2f.normal = normalize(mul((float3x3)unity_ObjectToWorld, normal));

					float4 displacedPosition = vd.position;
					displacedPosition.y = waveHeight;

					v2f.position = UnityObjectToClipPos(displacedPosition);
					v2f.worldPosition = mul(unity_ObjectToWorld, displacedPosition);

					v2f.uv = TRANSFORM_TEX(vd.uv, _mainTexture);

					v2f.shadowCoord = mul(_lightViewProj, float4(v2f.worldPosition, 1.0));

					return v2f;
				}


				float4 MyFragmentShader(vertex2Fragment v2f) : SV_TARGET
				{
					v2f.normal = normalize(v2f.normal);
					
					float4 albedo = /*tex2D(_mainTexture, v2f.uv)*/ _tint;

					if (albedo.a < _alphaCutOff)
						discard;

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

						float4 fresnel = pow((1 - dot(viewDirection, v2f.normal)), 5);

						float3 reflectionDirection = reflect(-viewDirection, v2f.normal);
						reflectionDirection.yz = reflectionDirection.zy;
						float4 reflection = texCUBE(_reflectionTexture, reflectionDirection) * fresnel;

						float3 halfVector = normalize((viewDirection - finalLightDirection));

						specular += pow(float(saturate(dot(v2f.normal, halfVector))), _lights[i]._smoothness * 100);
						specularColor += specular * _specularStrength * _lights[i]._lightColor.rgb * fresnel;
						diffuse += reflection * albedo.xyz * _lights[i]._lightColor * saturate(dot(-finalLightDirection, v2f.normal));
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
	