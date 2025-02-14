using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;

public class PixelizeRenderFeature : ScriptableRendererFeature
{
    private PixelizePass customPass;


    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(customPass);
    }

    public override void Create()
    {
        customPass = new PixelizePass();
     }

}
public class PixelizePass : ScriptableRenderPass
{
    private PixelizeEffect pixelize;

    private RenderTargetIdentifier colorBuffer, pixelBuffer;
    private int pixelBufferID = Shader.PropertyToID("_PixelBuffer");

    //private RenderTargetIdentifier pointBuffer;
    //private int pointBufferID = Shader.PropertyToID("_PointBuffer");

    private Material material;
    private int pixelScreenHeight, pixelScreenWidth;

    public PixelizePass()
    {
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        if (material == null)
            material = CoreUtils.CreateEngineMaterial("Custom Post-Processing/Pixelize");
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        colorBuffer = renderingData.cameraData.renderer.cameraColorTarget;
        RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
        pixelize = VolumeManager.instance.stack.GetComponent<PixelizeEffect>();

        pixelScreenHeight = pixelize.screenHeight.value;
        pixelScreenWidth = (int)(pixelScreenHeight * renderingData.cameraData.camera.aspect + 0.5f);

        material.SetVector("_BlockCount", new Vector2(pixelScreenWidth, pixelScreenHeight));
        material.SetVector("_BlockSize", new Vector2(1.0f / pixelScreenWidth, 1.0f / pixelScreenHeight));
        material.SetVector("_HalfBlockSize", new Vector2(0.5f / pixelScreenWidth, 0.5f / pixelScreenHeight));

        descriptor.height = pixelScreenHeight;
        descriptor.width = pixelScreenWidth;

        cmd.GetTemporaryRT(pixelBufferID, descriptor, FilterMode.Point);
        pixelBuffer = new RenderTargetIdentifier(pixelBufferID);
        renderingData.cameraData.requiresDepthTexture = true;

    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, new ProfilingSampler("Pixelize Pass")))
        {

            Blit(cmd, colorBuffer, pixelBuffer, material);
            Blit(cmd, pixelBuffer, colorBuffer);
        }

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        if (cmd == null) throw new System.ArgumentNullException("cmd");
        cmd.ReleaseTemporaryRT(pixelBufferID);
        //cmd.ReleaseTemporaryRT(pointBufferID);
    }

}