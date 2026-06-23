using UnityEngine;

[RequireComponent(typeof(Camera))]
public class ImageAdjustPostProcess : MonoBehaviour
{
    [SerializeField] private Shader shader;
    private Material material;

    // Variables públicas para modificar en runtime (desde UI, otros scripts o el Inspector)
    [Range(0f, 3f)] public float nivelBrillo = 1f;
    [Range(0f, 3f)] public float nivelContraste = 1f;
    [Range(0f, 1f)] public float nivelSaturacion = 0f; 
    [Range(0f, 1f)] public float nivelTono = 0f; 

    private void Awake()
    {
        // Creamos la instancia
        material = new Material(shader); 
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Pasamos los valores actualizados de la CPU al Material (GPU)
        material.SetFloat("_Brillo", nivelBrillo);
        material.SetFloat("_Contraste", nivelContraste);
        material.SetFloat("_Saturacion", nivelSaturacion);
        material.SetFloat("_Tono", nivelTono);

        // Renderizamos
        Graphics.Blit(source, destination, material); 
    }
}