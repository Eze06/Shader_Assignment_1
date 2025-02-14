using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class VignetteRenderFeature : ScriptableRendererFeature
{
    private VignettePass vignettePass;

    public override void Create()
    {
        vignettePass = new VignettePass();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        
        renderer.EnqueuePass(vignettePass);
        
    }
}

public class VignettePass : ScriptableRenderPass
{
    private Material material;
    private VignetteEffect vignetteEffect;

    private RenderTargetIdentifier src;

    private RenderTargetHandle dest;

    int texID;
    public VignettePass()
    {
        if(!material)
        {
            material = CoreUtils.CreateEngineMaterial("Custom Post-Processing/Vignette");
        }
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

    }
    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        var stack = VolumeManager.instance.stack;
        vignetteEffect = stack.GetComponent<VignetteEffect>();

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
        if (material == null || vignetteEffect == null) return;

        CommandBuffer cmd = CommandBufferPool.Get("Vignette Effect");

        material.SetFloat("_Intensity", vignetteEffect.intensity.value);
        material.SetFloat("_Radius", vignetteEffect.radius.value);
        material.SetFloat("_Feather", vignetteEffect.feather.value);
        material.SetColor("_Tint", vignetteEffect.tint.value);

        Blit(cmd, src, texID, material);
        Blit(cmd, texID, src);

        context.ExecuteCommandBuffer(cmd);

        CommandBufferPool.Release(cmd);
    }


}