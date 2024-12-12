using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

[Serializable]
public class Waves
{
    public float amplitude;
    public float frequency;
    public float speed;
    public Vector3 direction;
}

public class Water : MonoBehaviour
{

    private Material material;
    int waveCount;
    [SerializeField] Waves[] waves = new Waves[4]; // Max Waves 

    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
                
    }
}
