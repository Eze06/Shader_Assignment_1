using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenuForRenderPipeline("Custom/Gaussian Post-Processing", typeof(UniversalRenderPipeline))]

public class GaussianEffect : VolumeComponent, IPostProcessComponent
{

    public FloatParameter blurIntensity = new ClampedFloatParameter(0f, 0f, 50.0f);
    public bool IsActive() 
    {
        return (blurIntensity.value > 0.0f) && active;
    }

    public bool IsTileCompatible()
    {
        throw new NotImplementedException();
    }
}
