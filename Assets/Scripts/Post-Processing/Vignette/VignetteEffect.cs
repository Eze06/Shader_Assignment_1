using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenuForRenderPipeline("Custom/Vignette Post-Processing", typeof(UniversalRenderPipeline))]
public class VignetteEffect : VolumeComponent, IPostProcessComponent
{
    public FloatParameter intensity = new FloatParameter(0);
    public FloatParameter feather = new FloatParameter(10);
    public FloatParameter radius = new FloatParameter(0);
    public ColorParameter tint = new ColorParameter(Color.green);

    public bool IsActive() => intensity.value > 0f;
    public bool IsTileCompatible() => false;
}