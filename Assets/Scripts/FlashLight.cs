using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlashLight : MonoBehaviour
{
    [SerializeField] LightObject lightObject;
    [SerializeField] float lightIntensity = 1.8f;
    // Start is called before the first frame update
    void Start()
    {
        lightObject = GetComponent<LightObject>();
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.F))
        {
            if(lightObject.intensity > 0)
            {
                lightObject.intensity = 0;
            }
            else
            {
                lightObject.intensity = lightIntensity;
            }
        }
    }
}
