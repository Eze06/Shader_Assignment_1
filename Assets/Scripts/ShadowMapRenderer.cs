using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ShadowMapRenderer : MonoBehaviour
{
    [SerializeField] private LightObject lightObject;

    [SerializeField] private int shadowMapResolution = 1024;

    [SerializeField] private float shadowBias = 0.005f;

    private Camera lightCam;
    private RenderTexture shadowMap;

    // Start is called before the first frame update
    void Start()
    {
        lightObject = GetComponent<LightObject>();

        if(lightObject == null)
        {
            Debug.LogError("ShadowMapper requires a light object");
            return;
        }

        CreateLightCamera();
    }

    // Update is called once per frame
    void Update()
    {
        if (lightCam == null || shadowMap == null)
            return;

        UpdateLightCamera();
        SendShadowDataToSender();
    }

    void CreateLightCamera()
    {
        shadowMap = new RenderTexture(shadowMapResolution, shadowMapResolution, 24, RenderTextureFormat.Depth);
        shadowMap.Create();

        GameObject lightCamObject = new GameObject("Light Camera");
        lightCam = lightCamObject.AddComponent<Camera>();
        lightCam.enabled = false;
        lightCam.clearFlags = CameraClearFlags.Depth;
        lightCam.backgroundColor = Color.white;
        lightCam.targetTexture = shadowMap;

        lightCam.nearClipPlane = 0.1f;
        lightCam.farClipPlane = 100f;
        lightCam.orthographic = true;
        lightCam.orthographicSize = 30;

        lightCamObject.transform.SetParent(lightObject.transform, false);
    }

    void UpdateLightCamera()
    {
        lightCam.transform.position = lightObject.transform.position;
        lightCam.transform.forward = lightObject.GetDirection();

        lightCam.Render();
    }

    void SendShadowDataToSender()
    {
        Material material = lightObject.GetMaterial();
        if (material == null)
            return;

        Matrix4x4 lightViewProjMatrix = lightCam.projectionMatrix * lightCam.worldToCameraMatrix;

        material.SetTexture("_shadowMap", shadowMap);
        material.SetFloat("_shadowBias", shadowBias);
        material.SetMatrix("_lightViewProj", lightViewProjMatrix);
    }

    private void OnDestroy()
    {
        if(shadowMap != null)
        {
            shadowMap.Release();
        }
        if(lightCam != null)
        {
            Destroy(lightCam.gameObject);
        }
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(10, 10, 512, 512), shadowMap, ScaleMode.ScaleToFit, false);
    }


}
