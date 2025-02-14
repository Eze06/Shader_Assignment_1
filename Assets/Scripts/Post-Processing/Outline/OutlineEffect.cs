using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;

[Serializable, VolumeComponentMenuForRenderPipeline("Custom/Outline Post-Processing", typeof(UniversalRenderPipeline))]
public class OutlineEffect : VolumeComponent, IPostProcessComponent
{
    public FloatParameter thickness = new FloatParameter(0);
    public ColorParameter tint = new ColorParameter(Color.white);

    public bool IsActive() => thickness.value > 0f;
    public bool IsTileCompatible() => false;
}