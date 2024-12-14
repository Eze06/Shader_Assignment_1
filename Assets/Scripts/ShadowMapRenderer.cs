using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ShadowMapRenderer : MonoBehaviour
{
    [SerializeField] private lightManager lightManager;

    [SerializeField] private int shadowMapResolution = 1024;

    [SerializeField] private float shadowBias = 0.005f;

    [SerializeField] private Material waterMat; 

    private Camera[] lightCam;
    private RenderTexture[] shadowMaps;

    // Start is called before the first frame update
    private void OnEnable()
    {
        shadowMaps = new RenderTexture[lightManager.numLights];
        lightCam = new Camera[lightManager.numLights];
    }
    void Start()
    {

        if(lightManager == null)
        {
            Debug.LogError("ShadowMapper requires a light object");
            return;
        }

        CreateLightCamera();
    }

    // Update is called once per frame
    void Update()
    {
        if (lightCam == null || shadowMaps == null)
            return;

        UpdateLightCamera();
        SendShadowDataToSender();
    }

    void CreateLightCamera()
    {


        for (int i = 0; i < lightManager.numLights; i++)
        {
            shadowMaps[i] = new RenderTexture(shadowMapResolution, shadowMapResolution, 24, RenderTextureFormat.Depth);
            shadowMaps[i].Create();

            GameObject lightCamObject = new GameObject("Light Camera");
            lightCam[i] = lightCamObject.AddComponent<Camera>();
            lightCam[i].enabled = false;
            lightCam[i].clearFlags = CameraClearFlags.Depth;
            lightCam[i].backgroundColor = Color.white;
            lightCam[i].targetTexture = shadowMaps[i];

            lightCam[i].nearClipPlane = 0.1f;
            lightCam[i].farClipPlane = 100f;
            lightCam[i].orthographic = true;
            lightCam[i].orthographicSize = 30;

            lightCam[i].cullingMask = ~(1 << LayerMask.NameToLayer("NoShadowCast"));

            lightCamObject.transform.SetParent(lightManager.lightObjects[i].transform, false);
        }

    }

    void UpdateLightCamera()
    {
        for(int i = 0; i < lightManager.numLights;i++)
        {
            lightCam[i].transform.position = lightManager.lightObjects[i].transform.position;
            lightCam[i].transform.forward = lightManager.lightObjects[i].GetDirection();
            lightCam[i].Render();

        }


    }

    void SendShadowDataToSender()
    {
        List<Material> materials = lightManager.materialList;
        if (materials == null)
            return;

        for(int j = 0; j < lightManager.numLights; j++)
        {
            Matrix4x4 lightViewProjMatrix = lightCam[j].projectionMatrix * lightCam[j].worldToCameraMatrix;

            for (int i = 0; i < materials.Count; i++)
            {
                if (materials[i] == waterMat) continue;
                materials[i].SetTexture($"_ShadowMap{j}", shadowMaps[j]);

                materials[i].SetFloat("_shadowBias", shadowBias);
                materials[i].SetMatrix($"_LightViewProj{j}", lightViewProjMatrix);
            }
        }


    }

    private void OnDestroy()
    {
        if (shadowMaps != null)
        {
            for (int i = 0; i < shadowMaps.Length; i++)
            {
                if (shadowMaps[i] != null)
                {
                    shadowMaps[i].Release();
                }
            }
        }
        for (int i = 0; i < lightManager.numLights; i++)
        {
            if (lightCam[i] != null)
            {
                Destroy(lightCam[i].gameObject);
            }
        }
    }

    //private void OnGUI()
    //{
    //    GUI.DrawTexture(new Rect(10, 10, 512, 512), shadowMap, ScaleMode.ScaleToFit, false);
    //}


}
