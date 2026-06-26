using UnityEngine;

[RequireComponent(typeof(Camera))]
public class EfectoFlash : MonoBehaviour
{
    [SerializeField] private Material materialFlash;
    [SerializeField] private float duracion = 0.5f;

    private static readonly int PropIntensidad = Shader.PropertyToID("_FlashIntesidad");

    private bool  activo = false;
    private float timer  = 0f;

    public void Disparar()
    {
        timer  = 0f;
        activo = true;
    }

    void Update()
    {
        if (!activo) return;

        timer += Time.deltaTime;
        float t = Mathf.Clamp01(timer / duracion);

        // Pow < 1 hace que baje rápido al principio y luego suave (curva convexa)
        float intensidad = 1f - Mathf.Pow(t, 0.35f);
        materialFlash.SetFloat(PropIntensidad, intensidad);

        if (t >= 1f)
        {
            materialFlash.SetFloat(PropIntensidad, 0f);
            activo = false;
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (activo && materialFlash != null)
            Graphics.Blit(src, dest, materialFlash);
        else
            Graphics.Blit(src, dest);
    }
}
