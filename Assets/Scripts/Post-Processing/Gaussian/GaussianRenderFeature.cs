using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class GaussianRenderFeature : ScriptableRendererFeature
{

    private GaussianPass gaussianBlurPass;

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(gaussianBlurPass);
    }

    public override void Create()
    {
        gaussianBlurPass = new GaussianPass();
        name = "Gaussian Blur";
    }


}

public class GaussianPass : ScriptableRenderPass
{
    private Material material;

    private GaussianEffect gaussianEffect;

    private RenderTargetIdentifier src;

    private RenderTargetHandle dest;

    private int texID;

    public GaussianPass() 
    { 
        if(!material)
        {
            material = CoreUtils.CreateEngineMaterial("Custom Post-Processing/Gaussian Blur");
        }

        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (gaussianEffect == null || !gaussianEffect.IsActive())
            return;

        CommandBuffer cmd = CommandBufferPool.Get("Custom/Gaussian Blur");

        int gridSize = Mathf.CeilToInt(gaussianEffect.blurIntensity.value * 6.0f);

        if(gridSize % 2 == 0)
        {
            gridSize += 1;
        }

        material.SetInteger("_gridSize", gridSize);
        material.SetFloat("_spread", gaussianEffect.blurIntensity.value);

        cmd.Blit(src, texID, material, 0);
        cmd.Blit(texID, src, material, 1);

        context.ExecuteCommandBuffer(cmd);

        cmd.Clear();
        cmd.Release();

    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        gaussianEffect = VolumeManager.instance.stack.GetComponent<GaussianEffect>();

        RenderTextureDescriptor desc = renderingData.cameraData.cameraTargetDescriptor;

        src = renderingData.cameraData.renderer.cameraColorTargetHandle;

        renderingData.cameraData.requiresDepthTexture = true;

    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        if (gaussianEffect == null || !gaussianEffect.IsActive())
            return;

        texID = Shader.PropertyToID("_MainTex");

        dest = new RenderTargetHandle();
        dest.id = texID;

        cmd.GetTemporaryRT(texID, cameraTextureDescriptor);

        base.Configure(cmd, cameraTextureDescriptor);
    }

    
}