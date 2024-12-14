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

    public Vector3 direction = new Vector3(0, -1, 0);
    public Color lightColor;
    [Range(0, 1)]
    public float smoothness;
    [Range(0f,10f)]
    public float intensity;

    public Vector3 attenuation = new Vector3(1.0f, 0.09f, 0.032f);

    [Header("SpotLight Variables")]
    [Range(0,360)]
    public float SpotLightCutOff;
    [Range(0,360)]
    public float SpotLightInnerCutOff;

    public Type type;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        direction = transform.rotation * new Vector3(0, -1, 0);
        direction = direction.normalized;

        //SendToShader();
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, 1);
        Gizmos.DrawRay(transform.position, direction * 10f);
    }



    public Vector3 GetDirection()
    {
        return direction;
    }

}
