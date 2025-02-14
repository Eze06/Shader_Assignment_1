
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class BWRenderPassFeature : ScriptableRendererFeature
{
    private BWPass bwPass;

    public override void Create()
    {
        bwPass = new BWPass();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(bwPass);
    }


    
}

class BWPass : ScriptableRenderPass
{
    Material _mat;
    int bwID = Shader.PropertyToID("_Temp");
    RenderTargetIdentifier src, bw; //Render target identifiers 

    public BWPass()
    {
        if (!_mat)
        {
            _mat = CoreUtils.CreateEngineMaterial("Custom Post-Processing/BnW");
        }
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        RenderTextureDescriptor desc = renderingData.cameraData.cameraTargetDescriptor;
        src = renderingData.cameraData.renderer.cameraColorTargetHandle;
        cmd.GetTemporaryRT(bwID, desc, FilterMode.Bilinear);
        bw = new RenderTargetIdentifier(bwID);
        renderingData.cameraData.requiresDepthTexture = true;

    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer commandBuffer = CommandBufferPool.Get("BWRenderPassFeature");
        VolumeStack volumes = VolumeManager.instance.stack;
        BlackNWhite bwPP = volumes.GetComponent<BlackNWhite>();

        if (bwPP.IsActive())
        {
            //Debug.Log(_mat);
            _mat.SetFloat("_blend", (float)bwPP.blendIntensity);
            Blit(commandBuffer, src, bw, _mat, 0);
            Blit(commandBuffer, bw, src);
        }
        context.ExecuteCommandBuffer(commandBuffer);
        CommandBufferPool.Release(commandBuffer);
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(bwID);
    }
}