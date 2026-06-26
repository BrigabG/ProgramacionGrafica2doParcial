using UnityEngine;

/// <summary>
/// Controla en runtime los parámetros del material de cáusticas (AS_Caustics_Projector),
/// y opcionalmente anima la posición/rotación del Projector para simular el oleaje
/// de la superficie del agua moviendo el punto de entrada de la luz.
/// </summary>
public class CausticsController : MonoBehaviour
{
    [Header("Referencias")]
    public Material causticsMaterial;
    public Projector causticsProjector;
    public Renderer[] lightShaftSegments;
    public Renderer surfaceGlow;
    public ParticleSystem sedimentParticles;

    [Header("Cáusticas")]
    public Color causticsColor = new Color(0.55f, 0.95f, 1f);
    [Range(0f, 5f)] public float causticsIntensity = 1.5f;
    [Range(0f, 2f)] public float causticsSpeed = 0.25f;
    [Range(0.5f, 10f)] public float causticsScale = 3f;
    [Range(0f, 1f)] public float projectionOpacity = 0.85f;

    [Header("Haz vertical (superficie -> fondo)")]
    [Range(0f, 1f)] public float lightShaftOpacity = 0.045f;
    [Range(0f, 1f)] public float surfaceGlowOpacity = 0.12f;

    [Header("Oleaje del proyector (opcional)")]
    public bool animateSurfaceSway = true;
    [Range(0f, 10f)] public float swayAmount = 2f;
    [Range(0f, 1f)] public float swaySpeed = 0.15f;

    [Header("Bamboleo de los rayos (efecto agua en movimiento)")]
    public bool animateRaySway = true;
    [Range(0f, 20f)] public float raySwayDegrees = 6f;
    [Range(0f, 2f)] public float raySwaySpeed = 0.4f;
    [Range(0f, 1f)] public float rayFlickerAmount = 0.35f;
    [Range(0f, 3f)] public float rayFlickerSpeed = 0.8f;

    private Vector3 basePosition;
    private Quaternion[] shaftBaseRotations;

    private void Start()
    {
        if (causticsProjector != null)
        {
            basePosition = causticsProjector.transform.localPosition;
        }

        if (lightShaftSegments != null)
        {
            shaftBaseRotations = new Quaternion[lightShaftSegments.Length];
            for (int i = 0; i < lightShaftSegments.Length; i++)
            {
                if (lightShaftSegments[i] != null)
                {
                    shaftBaseRotations[i] = lightShaftSegments[i].transform.localRotation;
                }
            }
        }
    }

    private void Update()
    {
        ApplyMaterialValues();
        ApplyLightShaftValues();
        ApplyRaySway();

        if (animateSurfaceSway && causticsProjector != null)
        {
            float offsetX = Mathf.Sin(Time.time * swaySpeed) * swayAmount * 0.05f;
            float offsetZ = Mathf.Cos(Time.time * swaySpeed * 0.7f) * swayAmount * 0.05f;
            causticsProjector.transform.localPosition = basePosition + new Vector3(offsetX, 0f, offsetZ);
        }
    }

    private void ApplyMaterialValues()
    {
        if (causticsMaterial == null) return;

        causticsMaterial.SetColor("_CausticsColor", causticsColor);
        causticsMaterial.SetFloat("_CausticsIntensity", causticsIntensity);
        causticsMaterial.SetFloat("_CausticsSpeed", causticsSpeed);
        causticsMaterial.SetFloat("_CausticsScale", causticsScale);
        causticsMaterial.SetFloat("_Alpha", projectionOpacity);
    }

    private void ApplyLightShaftValues()
    {
        // El brillo del haz acompaña a la intensidad de las cáusticas, asi van siempre
        // coherentes entre si (mas intensidad = haz mas notorio).
        float intensityFactor = Mathf.Clamp01(causticsIntensity / 2.5f);

        if (lightShaftSegments != null)
        {
            for (int i = 0; i < lightShaftSegments.Length; i++)
            {
                Renderer segment = lightShaftSegments[i];
                if (segment == null) continue;

                // Cada rayo parpadea con su propia fase, para que no titilen todos a la vez
                // (eso es lo que rompe la sensación de "agua moviéndose" y se ve mecánico).
                float phase = i * 2.3f;
                float flicker = 1f + Mathf.Sin(Time.time * rayFlickerSpeed + phase) * rayFlickerAmount;

                Color shaftColor = causticsColor;
                shaftColor.a = lightShaftOpacity * intensityFactor * Mathf.Max(0f, flicker);

                segment.material.color = shaftColor;
                if (segment.material.HasProperty("_TintColor"))
                {
                    segment.material.SetColor("_TintColor", shaftColor);
                }
            }
        }

        if (surfaceGlow != null)
        {
            Color glowColor = causticsColor;
            glowColor.a = surfaceGlowOpacity * intensityFactor;
            surfaceGlow.material.color = glowColor;
            if (surfaceGlow.material.HasProperty("_TintColor"))
            {
                surfaceGlow.material.SetColor("_TintColor", glowColor);
            }
        }

        if (sedimentParticles != null)
        {
            var main = sedimentParticles.main;
            Color dustColor = Color.Lerp(Color.white, causticsColor, 0.5f);
            dustColor.a = Mathf.Clamp(intensityFactor, 0.2f, 0.5f);
            main.startColor = dustColor;
        }
    }

    private void ApplyRaySway()
    {
        if (!animateRaySway || lightShaftSegments == null || shaftBaseRotations == null) return;

        for (int i = 0; i < lightShaftSegments.Length; i++)
        {
            Renderer segment = lightShaftSegments[i];
            if (segment == null) continue;

            // Cada rayo se bambolea alrededor del eje del haz con su propia fase y velocidad
            // levemente distinta, simulando que el angulo de refraccion cambia con el oleaje
            // de la superficie. Esto es justo lo que hace que se "sientan" reflejados en agua
            // en vez de fijos como un objeto solido.
            float phase = i * 1.7f;
            float speedVariation = 1f + i * 0.15f;
            float sway = Mathf.Sin(Time.time * raySwaySpeed * speedVariation + phase) * raySwayDegrees;

            Quaternion swayRotation = Quaternion.Euler(0f, 0f, sway);
            segment.transform.localRotation = swayRotation * shaftBaseRotations[i];
        }
    }
}
