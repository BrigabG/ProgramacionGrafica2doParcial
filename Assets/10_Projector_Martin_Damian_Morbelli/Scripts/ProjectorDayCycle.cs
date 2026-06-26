using UnityEngine;

public class ProjectorDayCycle : MonoBehaviour
{
    public enum CycleMode
    {
        Automatic,
        Manual
    }

    public enum DayMoment
    {
        Morning,
        Afternoon,
        Night
    }

    [Header("Mode")]
    public CycleMode cycleMode = CycleMode.Manual;

    [Range(0f, 1f)]
    public float timeOfDay = 0f;

    public float cycleSpeed = 0.003f;

    [Header("Manual")]
    public DayMoment manualMoment = DayMoment.Morning;

    [Header("References")]
    public Material projectorMaterial;
    public Projector windowProjector;
    public Light directionalLight;
    public Transform sunVisual;
    public Light sunPointLight;
    public Renderer lightBeamRenderer;
    public Renderer[] lightBeamExtraSegments;
    public float[] lightBeamExtraAlphaMultipliers;
    [Range(0f, 1f)] public float lightBeamBaseAlpha = 0.22f;
    public Light nightLampLight;
    public Light ceilingLampLight;
    public ParticleSystem windowDustParticles;

    [Header("Morning Settings")]
    public Color morningColor = new Color(1f, 0.92f, 0.75f);
    public float morningIntensity = 1.2f;
    public float morningAlpha = 0.55f;
    public Vector3 morningProjectorRotation = new Vector3(40f, 165f, 0f);
    public Vector3 morningSunPosition = new Vector3(-8f, 5f, 6f);
    public float morningLampIntensity = 0f;

    [Header("Afternoon Settings")]
    public Color afternoonColor = new Color(1f, 0.55f, 0.2f);
    public float afternoonIntensity = 1.8f;
    public float afternoonAlpha = 0.65f;
    public Vector3 afternoonProjectorRotation = new Vector3(58f, 180f, 0f);
    public Vector3 afternoonSunPosition = new Vector3(0f, 6f, 6f);
    public float afternoonLampIntensity = 0f;

    [Header("Night Settings")]
    public Color nightColor = new Color(0.25f, 0.35f, 1f);
    public float nightIntensity = 0.35f;
    public float nightAlpha = 0.25f;
    public Vector3 nightProjectorRotation = new Vector3(74f, 190f, 0f);
    public Vector3 nightSunPosition = new Vector3(8f, 3f, 6f);
    public float nightLampIntensity = 1.4f;

    private void Update()
    {
        if (cycleMode == CycleMode.Automatic)
        {
            timeOfDay += Time.deltaTime * cycleSpeed;

            if (timeOfDay > 1f)
            {
                timeOfDay = 0f;
            }

            ApplyAutomaticCycle();
        }
        else
        {
            ApplyManualMoment();
        }
    }

    private void ApplyAutomaticCycle()
    {
        if (timeOfDay < 0.5f)
        {
            float t = timeOfDay / 0.5f;
            t = Mathf.SmoothStep(0f, 1f, t);

            ApplyValues(
                Color.Lerp(morningColor, afternoonColor, t),
                Mathf.Lerp(morningIntensity, afternoonIntensity, t),
                Mathf.Lerp(morningAlpha, afternoonAlpha, t),
                Vector3.Lerp(morningProjectorRotation, afternoonProjectorRotation, t),
                Vector3.Lerp(morningSunPosition, afternoonSunPosition, t),
                Mathf.Lerp(morningLampIntensity, afternoonLampIntensity, t)
            );
        }
        else
        {
            float t = (timeOfDay - 0.5f) / 0.5f;
            t = Mathf.SmoothStep(0f, 1f, t);

            ApplyValues(
                Color.Lerp(afternoonColor, nightColor, t),
                Mathf.Lerp(afternoonIntensity, nightIntensity, t),
                Mathf.Lerp(afternoonAlpha, nightAlpha, t),
                Vector3.Lerp(afternoonProjectorRotation, nightProjectorRotation, t),
                Vector3.Lerp(afternoonSunPosition, nightSunPosition, t),
                Mathf.Lerp(afternoonLampIntensity, nightLampIntensity, t)
            );
        }
    }

    private void ApplyManualMoment()
    {
        if (manualMoment == DayMoment.Morning)
        {
            ApplyValues(morningColor, morningIntensity, morningAlpha, morningProjectorRotation, morningSunPosition, morningLampIntensity);
        }
        else if (manualMoment == DayMoment.Afternoon)
        {
            ApplyValues(afternoonColor, afternoonIntensity, afternoonAlpha, afternoonProjectorRotation, afternoonSunPosition, afternoonLampIntensity);
        }
        else
        {
            ApplyValues(nightColor, nightIntensity, nightAlpha, nightProjectorRotation, nightSunPosition, nightLampIntensity);
        }
    }

    private void ApplyValues(Color color, float intensity, float alpha, Vector3 projectorRotation, Vector3 sunPosition, float lampIntensity)
    {
        if (projectorMaterial != null)
        {
            projectorMaterial.SetColor("_LightColor", color);
            projectorMaterial.SetFloat("_Intensity", intensity);
            projectorMaterial.SetFloat("_Alpha", alpha);
        }

        if (windowProjector != null)
        {
            windowProjector.transform.rotation = Quaternion.Euler(projectorRotation);
        }

        if (directionalLight != null)
        {
            directionalLight.color = new Color(0.30f, 0.32f, 0.36f);
            directionalLight.intensity = 0.32f;
        }

        if (sunVisual != null)
        {
            sunVisual.position = sunPosition;
        }

        if (sunPointLight != null)
        {
            sunPointLight.color = color;
            sunPointLight.intensity = intensity;
        }

        if (lightBeamRenderer != null)
        {
            Color beamColor = color;
            beamColor.a = alpha * lightBeamBaseAlpha;

            lightBeamRenderer.material.color = beamColor;

            if (lightBeamRenderer.material.HasProperty("_TintColor"))
            {
                lightBeamRenderer.material.SetColor("_TintColor", beamColor);
            }
        }

        if (lightBeamExtraSegments != null)
        {
            for (int i = 0; i < lightBeamExtraSegments.Length; i++)
            {
                Renderer segment = lightBeamExtraSegments[i];
                if (segment == null) continue;

                float multiplier = 1f;
                if (lightBeamExtraAlphaMultipliers != null && i < lightBeamExtraAlphaMultipliers.Length)
                {
                    multiplier = lightBeamExtraAlphaMultipliers[i];
                }

                Color segColor = color;
                segColor.a = alpha * lightBeamBaseAlpha * multiplier;
                segment.material.color = segColor;

                if (segment.material.HasProperty("_TintColor"))
                {
                    segment.material.SetColor("_TintColor", segColor);
                }
            }
        }

        if (nightLampLight != null)
        {
            bool lampOn = lampIntensity > 0.02f;
            nightLampLight.gameObject.SetActive(lampOn);

            if (lampOn)
            {
                nightLampLight.intensity = lampIntensity;
            }
        }

        if (ceilingLampLight != null)
        {
            bool lampOn = lampIntensity > 0.02f;
            ceilingLampLight.gameObject.SetActive(lampOn);

            if (lampOn)
            {
                ceilingLampLight.intensity = lampIntensity * 0.85f;
            }
        }

        if (windowDustParticles != null)
        {
            bool dustVisible = alpha > 0.05f;

            if (dustVisible != windowDustParticles.gameObject.activeSelf)
            {
                windowDustParticles.gameObject.SetActive(dustVisible);
            }

            if (dustVisible)
            {
                var main = windowDustParticles.main;
                Color dustColor = Color.Lerp(Color.white, color, 0.4f);
                dustColor.a = Mathf.Clamp(alpha * 0.9f, 0.25f, 0.55f);
                main.startColor = dustColor;
            }
        }
    }
}