using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;
using System.Runtime.InteropServices;
using Random = UnityEngine.Random;

[Serializable]
public struct Waves
{
    public float amplitude;
    public float wavelength;
    public float speed;
    public Vector3 direction;

}



public class Water : MonoBehaviour
{

    [SerializeField] private Material material;
    const int waveCount = 4;
    [SerializeField] Waves[] waves; // Max Waves 
    private ComputeBuffer waveBuffer;
    [Range(0,3)]
    [SerializeField] float amplitudeStart;

    private void OnEnable()
    {
        waves = new Waves[waveCount]; // Max Waves 
        waves[0] = new Waves()
        {
            wavelength = 20f,
            direction = Random.insideUnitCircle.normalized,
            amplitude = amplitudeStart,
            speed = Random.Range(10f, 30f),
        };
        GenerateWaves();

        waveBuffer = new ComputeBuffer(waveCount, Marshal.SizeOf(typeof(Waves)));
    }

    void Start()
    {
    }

    public void GenerateWaves()
    {
        for(int i = 0; i < waveCount; i++)
        {
            if (i == 0) continue;
            waves[i] = new Waves()
            {
                wavelength = waves[i-1].wavelength * 1.18f,
                amplitude = waves[i-1].amplitude * 0.82f,          
                direction = Random.insideUnitCircle.normalized,
                speed = Random.Range(10f, 30f),

            };
        }
    }
    // Update is called once per frame
    void Update()
    {
        material.SetInteger("_waveCount", waveCount);

        waveBuffer.SetData(waves);
        material.SetBuffer("_waves", waveBuffer);
    }
    private void OnDisable()
    {
        if (waveBuffer != null)
        {
            waveBuffer.Release();
            waveBuffer = null;
        }
    }

    public void RandomizeWaves()
    {

    }
}
