using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class PanelFoto : MonoBehaviour
{
    [Tooltip("RawImage dentro de este panel que muestra la foto.")]
    [SerializeField] private RawImage imagenPanel;

    [Tooltip("El RawImage chico en el HUD — destino de la animación.")]
    [SerializeField] private RawImage imagenDestino;

    [SerializeField] private float duracion = 0.7f;
    [SerializeField] private AnimationCurve curva = AnimationCurve.EaseInOut(0f, 0f, 1f, 1f);

    private RectTransform rtPanel;
    private RenderTexture fotoActual;

    void Awake()
    {
        rtPanel = GetComponent<RectTransform>();
        gameObject.SetActive(false);
    }

    public void MostrarFoto(RenderTexture foto)
    {
        fotoActual          = foto;
        imagenPanel.texture = foto;
        gameObject.SetActive(true);
        StopAllCoroutines();
        StartCoroutine(AnimarHaciaDestino());
    }

    IEnumerator AnimarHaciaDestino()
    {
        // Estado inicial: posición y escala actuales del panel (centro, grande)
        Vector3 posInicial    = rtPanel.position;
        Vector3 escalaInicial = Vector3.one;

        // Estado final: posición y escala para que el panel coincida con imagenDestino
        RectTransform rtDestino = imagenDestino.rectTransform;
        Vector3 posDestino      = rtDestino.position;

        float anchoDestino = rtDestino.rect.width  * rtDestino.lossyScale.x;
        float altoDestino  = rtDestino.rect.height * rtDestino.lossyScale.y;
        Vector3 escalaFinal = new Vector3(
            anchoDestino / rtPanel.rect.width,
            altoDestino  / rtPanel.rect.height,
            1f
        );

        float t = 0f;
        while (t < 1f)
        {
            t = Mathf.Clamp01(t + Time.deltaTime / duracion);
            float tc = curva.Evaluate(t);
            rtPanel.position   = Vector3.Lerp(posInicial, posDestino, tc);
            rtPanel.localScale = Vector3.Lerp(escalaInicial, escalaFinal, tc);
            yield return null;
        }

        // Transferir la textura al destino y resetear el panel
        imagenDestino.texture = fotoActual;
        rtPanel.position      = posInicial;
        rtPanel.localScale    = escalaInicial;
        gameObject.SetActive(false);
    }
}
