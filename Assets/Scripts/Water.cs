using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Waves
{
    public float amplitude;
    public float frequency;
    public float speed;
    public float direction;
}

public class Water : MonoBehaviour
{

    private Material material;
    [SerializeField] private int waveCount;


    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
