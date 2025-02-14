using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class OutlineRenderFeature : ScriptableRendererFeature
{
    private OutlinePass outlinePass;

    public override void Create()
    {
        outlinePass = new OutlinePass();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {

        renderer.EnqueuePass(outlinePass);

    }
}

public class OutlinePass : ScriptableRenderPass
{
    private Material material;
    private OutlineEffect outlineEffect;

    private RenderTargetIdentifier src;

    private RenderTargetHandle dest;

    int texID;
    public OutlinePass()
    {
        if (!material)
        {
            material = CoreUtils.CreateEngineMaterial("Custom Post-Processing/Outline");
        }
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

    }
    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        var stack = VolumeManager.instance.stack;
        outlineEffect = stack.GetComponent<OutlineEffect>();

        RenderTextureDescriptor desc = renderingData.cameraData.cameraTargetDescriptor;

        src = renderingData.cameraData.renderer.cameraColorTargetHandle;

    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        texID = Shader.PropertyToID("_MainTex");

        dest = new RenderTargetHandle();
        dest.id = texID;

        cmd.GetTemporaryRT(texID, cameraTextureDescriptor);

        base.Configure(cmd, cameraTextureDescriptor);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (material == null || outlineEffect == null) return;

        CommandBuffer cmd = CommandBufferPool.Get("Vignette Effect");

        material.SetFloat("_OutlineThickness", outlineEffect.thickness.value);
 
        material.SetColor("_OutlineColor", outlineEffect.tint.value);

        Blit(cmd, src, texID, material);
        Blit(cmd, texID, src);

        context.ExecuteCommandBuffer(cmd);

        CommandBufferPool.Release(cmd);
    }


}