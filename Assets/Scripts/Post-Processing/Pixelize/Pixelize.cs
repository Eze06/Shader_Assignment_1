using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;
using System;

[Serializable, VolumeComponentMenuForRenderPipeline("Custom/Pixelize Post-Processing", typeof(UniversalRenderPipeline))]

public class PixelizeEffect : VolumeComponent, IPostProcessComponent
{

    public IntParameter screenHeight = new IntParameter(1080);
    public bool IsActive() => active;
    public bool IsTileCompatible() => false;
}

