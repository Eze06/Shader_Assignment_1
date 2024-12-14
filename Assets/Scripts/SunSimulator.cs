using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SunSimulator : MonoBehaviour
{
    private LightObject lightObject;

    public float minIntensity = 0.0f;  
    public float maxIntensity = 1.8f;  
    public float dayDuration = 48.0f;


    private float timeOfDay; 

    // Start is called before the first frame update
    void Start()
    {
        lightObject = GetComponent<LightObject>();
        timeOfDay = 0;
    }

    // Update is called once per frame
    void Update()
    {
        timeOfDay += Time.deltaTime / dayDuration;

        if (timeOfDay >= 1.0f)
        {
            timeOfDay = 0.0f; 
        }

        float intensity = Mathf.Sin(timeOfDay * Mathf.PI * 2.0f); 
        intensity = Mathf.Clamp01((intensity + 1.0f) / 2.0f);  

        lightObject.intensity = Mathf.Lerp(minIntensity, maxIntensity, intensity);
    }
}
