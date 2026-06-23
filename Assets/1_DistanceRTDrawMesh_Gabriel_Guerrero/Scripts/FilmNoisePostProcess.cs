using UnityEngine;

// Asegura que el GameObject tenga una cámara para que OnRenderImage funcione automáticamente [5]
[RequireComponent(typeof(Camera))]
public class FilmNoisePostProcess : MonoBehaviour
{
    [SerializeField] private Shader shader;
    private Material material;

    // Variables públicas para modificar el grano en runtime
    public float escalaRuido = 150f;
    public float velocidadRuido = 2f;
    [Range(0f, 1f)] public float intensidadRuido = 0.3f; 

    private void Awake()
    {
        // Creamos una instancia del material para no modificar el asset original [6]
        if (shader != null)
        {
            material = new Material(shader); 
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            // Enviamos los valores actualizados de la CPU a la GPU
            material.SetFloat("_EscalaRuido", escalaRuido);
            material.SetFloat("_VelocidadRuido", velocidadRuido);
            material.SetFloat("_IntensidadRuido", intensidadRuido);

            // Lee la imagen original, aplica el material con el ruido, y escupe la imagen final [2, 5]
            Graphics.Blit(source, destination, material); 
        }
        else
        {
            // Por seguridad, si no hay material, solo devolvemos la imagen intacta
            Graphics.Blit(source, destination);
        }
    }
}