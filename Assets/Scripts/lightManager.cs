using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Experimental.AI;

[Serializable]
[StructLayout(LayoutKind.Sequential)]
public struct Light
{
    public Vector3 _lightPosition;
    public Vector3 _lightDirection;
    public Color _lightColor;
    public float _smoothness;
    public int _lightType;
    public float _lightIntensity;
    public Vector3 _attenuation;
    public float _spotLightCutOff;
    public float _spotLightInnerCutOff;

}

public class lightManager : MonoBehaviour
{
    public const int numLights = 2;
    [SerializeField]
    public List<LightObject> lightObjects = new List<LightObject>(numLights);
    [SerializeField]
    private Light[] lights;

    [SerializeField]
    public List<Material> materialList;

    ComputeBuffer lightBuffer;
    private void OnEnable()
    {
        lights = new Light[numLights];

        lightBuffer = new ComputeBuffer(numLights, Marshal.SizeOf(typeof(Light)));

    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        prepLights();
        SendToShader();
    }

    private void prepLights()
    {
        for(int i = 0; i < numLights; i++)
        {
            if (lightObjects[i] == null) continue;
            lights[i] = new Light()
            {
                _lightPosition = lightObjects[i].transform.position,
                _lightDirection = lightObjects[i].GetDirection(),
                _lightColor = lightObjects[i].lightColor,
                //_specularStrength = 
                _smoothness = lightObjects[i].smoothness,
                _lightType = (int)lightObjects[i].type,
                _lightIntensity = lightObjects[i].intensity,
                _attenuation = lightObjects[i].attenuation,
                _spotLightCutOff = lightObjects[i].SpotLightCutOff,
                _spotLightInnerCutOff = lightObjects[i].SpotLightInnerCutOff
            };
        }
    }

    private void SendToShader()
    {
        for (int i = 0; i < materialList.Count; i++)
        {
            materialList[i].SetInteger("_numLights", numLights);
            lightBuffer.SetData(lights);
            materialList[i].SetBuffer("_lights", lightBuffer);
        }
    }

    private void OnDisable()
    {
        lightBuffer.Release();
    }
}
