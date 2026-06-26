using System.Collections.Generic;
using UnityEngine;

public class ProjectionSciFiSceneController : MonoBehaviour
{
    public Renderer playerRenderer;
    public Material playerNormalMaterial;
    public Material playerThermalMaterial;
    public GameObject xraySkeleton;
    public GameObject lightBeamVolume;
    public Renderer resultPanelRenderer;
    public TextMesh resultText;
    public Material pendingMaterial;
    public Material approvedMaterial;
    public Material failedMaterial;
    public Light[] guideLights;
    public Renderer[] guideRenderers;
    public Material guideOffMaterial;
    public Material guideOnMaterial;

    private readonly HashSet<ProjectionSciFiSensorMode> passedSensors = new HashSet<ProjectionSciFiSensorMode>();
    private ProjectionSciFiSensorMode? activeMode;

    private void Awake()
    {
        SetXRayVisible(false);
        SetLightBeamsVisible(false);
        SetPlayerThermal(false);
        UpdateResultPanel();
        UpdateGuideLights();
    }

    public void EnterSensor(ProjectionSciFiSensorMode mode)
    {
        activeMode = mode;
        passedSensors.Add(mode);

        SetXRayVisible(mode == ProjectionSciFiSensorMode.XRay);
        SetPlayerThermal(mode == ProjectionSciFiSensorMode.Thermal);
        SetLightBeamsVisible(mode == ProjectionSciFiSensorMode.Light);

        UpdateResultPanel();
        UpdateGuideLights();
    }

    public void ExitSensor(ProjectionSciFiSensorMode mode)
    {
        if (activeMode == mode)
        {
            activeMode = null;
            SetXRayVisible(false);
            SetPlayerThermal(false);
            SetLightBeamsVisible(false);
        }
    }

    private void SetXRayVisible(bool visible)
    {
        if (xraySkeleton != null)
        {
            xraySkeleton.SetActive(visible);
        }
    }

    private void SetLightBeamsVisible(bool visible)
    {
        if (lightBeamVolume != null)
        {
            lightBeamVolume.SetActive(visible);
        }
    }

    private void SetPlayerThermal(bool active)
    {
        if (playerRenderer == null)
        {
            return;
        }

        Material targetMaterial = active ? playerThermalMaterial : playerNormalMaterial;
        if (targetMaterial != null)
        {
            playerRenderer.sharedMaterial = targetMaterial;
        }
    }

    private void UpdateResultPanel()
    {
        bool approved = passedSensors.Contains(ProjectionSciFiSensorMode.XRay)
            && passedSensors.Contains(ProjectionSciFiSensorMode.Thermal)
            && passedSensors.Contains(ProjectionSciFiSensorMode.Light);

        if (resultPanelRenderer != null)
        {
            resultPanelRenderer.sharedMaterial = approved ? approvedMaterial : pendingMaterial;
        }

        if (resultText != null)
        {
            resultText.text = approved ? "APROBADO" : "ESCANEO EN PROCESO";
            resultText.color = approved ? new Color(0.35f, 1f, 0.55f, 1f) : new Color(0.85f, 0.95f, 1f, 1f);
        }
    }

    private void UpdateGuideLights()
    {
        int litCount = Mathf.Clamp(passedSensors.Count + 1, 1, guideLights != null ? guideLights.Length : 0);

        if (guideLights != null)
        {
            for (int i = 0; i < guideLights.Length; i++)
            {
                bool active = i < litCount;
                if (guideLights[i] != null)
                {
                    guideLights[i].enabled = active;
                    guideLights[i].color = active ? new Color(0.25f, 0.9f, 1f) : Color.black;
                }
            }
        }

        if (guideRenderers != null)
        {
            for (int i = 0; i < guideRenderers.Length; i++)
            {
                bool active = i < litCount;
                if (guideRenderers[i] != null)
                {
                    guideRenderers[i].sharedMaterial = active ? guideOnMaterial : guideOffMaterial;
                }
            }
        }
    }
}
