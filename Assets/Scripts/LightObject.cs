using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

[ExecuteInEditMode]
public class LightObject : MonoBehaviour
{

    public enum Type
    {
        DIRECTIONAL,
        POINT,
        SPOT
    }

    [SerializeField]
    private Vector3 direction = new Vector3(0, -1, 0);
    [SerializeField]
    private Material material;
    [SerializeField]
    private Color lightColor;
    [SerializeField]
    [Range(0, 1)]
    private float smoothness;
    [SerializeField]
    [Range(0f,10f)]
    private float intensity;

    [SerializeField]
    private Vector3 attenuation = new Vector3(1.0f, 0.09f, 0.032f);

    [Header("SpotLight Variables")]
    [SerializeField]
    [Range(0,360)]
    private float SpotLightCutOff;
    [SerializeField]
    [Range(0,360)]
    private float SpotLightInnerCutOff;

    [SerializeField] private Type type;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        direction = transform.rotation * new Vector3(0, -1, 0);
        direction = direction.normalized;

        SendToShader();
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, 1);
        Gizmos.DrawRay(transform.position, direction * 10f);
    }

    private void SendToShader()
    {
        material.SetVector("_lightPosition", transform.position);
        material.SetVector("_lightDirection", direction);
        material.SetColor("_lightColor", lightColor);
        material.SetFloat("_smoothness", smoothness);
        material.SetInteger("_lightType", (int)type);
        material.SetFloat("_lightIntensity", intensity);
        material.SetVector("_attenuation", attenuation);
        material.SetFloat("_spotLightCutOff", SpotLightCutOff);
        material.SetFloat("_spotLightInnerCutOff", SpotLightInnerCutOff);
    }

    public Vector3 GetDirection()
    {
        return direction;
    }

    public Material GetMaterial()
    {
        return material;
    }
}
