using System.Collections;
using UnityEngine;

public class UIOrchestrator : MonoBehaviour
{
    // ── Scroll de elementos ──────────────────────────────────────────────────
    [Header("Scroll (deslizar hacia arriba)")]
    public RectTransform[] scrollElements;
    [Tooltip("Distancia en pixels que suben desde su posicion inicial")]
    public float slideDistance   = 150f;
    public float slideDuration   = 0.8f;
    public float slideDelay      = 0f;
    public AnimationCurve slideCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

    // ── FadeUI ───────────────────────────────────────────────────────────────
    [Header("FadeUI  — _Progress  0 → 1")]
    public Material fadeUIMaterial;
    public float    fadeDuration = 1f;
    public float    fadeDelay    = 0f;

    // ── DistorcionUI ─────────────────────────────────────────────────────────
    [Header("DistorcionUI  — _Opacidad  0 → 1")]
    public Material distorcionUIMaterial;
    public float    distOpacidadDuration = 1f;
    public float    distOpacidadDelay    = 0f;

    [Header("DistorcionUI  — _Float1  2.5 → 0")]
    public float distFloat1Duration = 1f;
    public float distFloat1Delay    = 0f;

    // ── Titulo (empujar hacia arriba, queda en pantalla) ────────────────────
    [Header("Push Titulo (sube y queda en pantalla)")]
    public RectTransform tituloTransform;
    [Tooltip("Cantidad de pixels que sube el titulo")]
    public float tituloPushDistance = 100f;
    public float tituloPushDuration = 0.6f;
    public float tituloPushDelay    = 0f;
    public AnimationCurve tituloPushCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

    // ── BurnUI ───────────────────────────────────────────────────────────────
    [Header("BurnUI  — _Progress  -1 → 1")]
    public Material burnUIMaterial;
    public float    burnDuration = 1f;
    public float    burnDelay    = 0f;

    // ────────────────────────────────────────────────────────────────────────

    void Start() => Play();

    [ContextMenu("Play")]
    public void Play()
    {
        StopAllCoroutines();
        ResetAll();
        StartCoroutine(RunAll());
    }

    void ResetAll()
    {
        if (fadeUIMaterial         != null) fadeUIMaterial.SetFloat("_Progress",  0f);
        if (distorcionUIMaterial   != null) distorcionUIMaterial.SetFloat("_Opacidad", 0f);
        if (distorcionUIMaterial   != null) distorcionUIMaterial.SetFloat("_Float1",   2.5f);
        if (burnUIMaterial         != null) burnUIMaterial.SetFloat("_Progress",  -1f);
    }

    IEnumerator RunAll()
    {
        if (scrollElements != null && scrollElements.Length > 0)
            StartCoroutine(AnimateScroll());

        if (fadeUIMaterial != null)
            StartCoroutine(AnimateFloat(fadeUIMaterial, "_Progress", 0f, 1f, fadeDuration, fadeDelay));

        if (distorcionUIMaterial != null)
        {
            StartCoroutine(AnimateFloat(distorcionUIMaterial, "_Opacidad", 0f, 1f, distOpacidadDuration, distOpacidadDelay));
            StartCoroutine(AnimateFloat(distorcionUIMaterial, "_Float1",   2.5f, 0f, distFloat1Duration,  distFloat1Delay));
        }

        if (tituloTransform != null)
            StartCoroutine(AnimatePushTitulo());

        if (burnUIMaterial != null)
            StartCoroutine(AnimateFloat(burnUIMaterial, "_Progress", -1f, 1f, burnDuration, burnDelay));

        yield break;
    }

    // ── Coroutines ───────────────────────────────────────────────────────────

    IEnumerator AnimateScroll()
    {
        if (slideDelay > 0f) yield return new WaitForSeconds(slideDelay);

        // Partir de la posicion actual y salir hacia arriba
        Vector2[] origins = new Vector2[scrollElements.Length];
        for (int i = 0; i < scrollElements.Length; i++)
            origins[i] = scrollElements[i].anchoredPosition;

        float t = 0f;
        while (t < 1f)
        {
            t += Time.deltaTime / Mathf.Max(slideDuration, 0.001f);
            float eval = slideCurve.Evaluate(Mathf.Clamp01(t));
            for (int i = 0; i < scrollElements.Length; i++)
            {
                scrollElements[i].anchoredPosition = Vector2.LerpUnclamped(
                    origins[i],
                    origins[i] + new Vector2(0f, slideDistance),
                    eval
                );
            }
            yield return null;
        }

        // Asegurar posicion final exacta
        for (int i = 0; i < scrollElements.Length; i++)
            scrollElements[i].anchoredPosition = origins[i] + new Vector2(0f, slideDistance);
    }

    IEnumerator AnimatePushTitulo()
    {
        if (tituloPushDelay > 0f) yield return new WaitForSeconds(tituloPushDelay);

        Vector2 origin = tituloTransform.anchoredPosition;
        Vector2 target = origin + new Vector2(0f, tituloPushDistance);

        float t = 0f;
        while (t < 1f)
        {
            t += Time.deltaTime / Mathf.Max(tituloPushDuration, 0.001f);
            tituloTransform.anchoredPosition = Vector2.LerpUnclamped(
                origin, target, tituloPushCurve.Evaluate(Mathf.Clamp01(t))
            );
            yield return null;
        }

        tituloTransform.anchoredPosition = target;
    }

    IEnumerator AnimateFloat(Material mat, string prop, float from, float to, float duration, float delay)
    {
        if (delay > 0f) yield return new WaitForSeconds(delay);

        mat.SetFloat(prop, from);
        float t = 0f;
        while (t < 1f)
        {
            t += Time.deltaTime / Mathf.Max(duration, 0.001f);
            mat.SetFloat(prop, Mathf.Lerp(from, to, Mathf.Clamp01(t)));
            yield return null;
        }
        mat.SetFloat(prop, to);
    }
}
