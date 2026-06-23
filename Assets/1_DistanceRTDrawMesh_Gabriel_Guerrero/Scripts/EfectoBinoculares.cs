using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteAlways]
public class EfectoBinoculares : MonoBehaviour
{
    [Header("Efecto Binoculares")]
    [Tooltip("Material que usa el shader de binoculares.")]
    [SerializeField] private Material materialBinoculares;

    [Tooltip("Desactivalo temporalmente sin quitar el componente.")]
    [SerializeField] public bool activarEfecto = true;

    [Tooltip("Distancia entre los dos círculos en espacio UV (0-1).")]
    [SerializeField] private float separacionOjos = 0.08f;

    private static readonly int PropCentroIzq = Shader.PropertyToID("_CentroIzq");
    private static readonly int PropCentroDer = Shader.PropertyToID("_CentroDer");

    void Update()
    {
        if (activarEfecto && materialBinoculares != null)
            ActualizarCentros();
    }

    void ActualizarCentros()
    {
        float x = Input.mousePosition.x / Screen.width;
        float y = Input.mousePosition.y / Screen.height;

        materialBinoculares.SetVector(PropCentroIzq, new Vector4(x - separacionOjos, y, 0f, 0f));
        materialBinoculares.SetVector(PropCentroDer,  new Vector4(x + separacionOjos, y, 0f, 0f));
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (activarEfecto && materialBinoculares != null)
            Graphics.Blit(src, dest, materialBinoculares);
        else
            Graphics.Blit(src, dest);
    }
}
