using System.Collections;
using UnityEngine;

public class LoadingScreenOrchestrator : MonoBehaviour
{
    // ── RotateUI ─────────────────────────────────────────────────────────────
    [Header("RotateUI Material")]
    public Material rotateUIMaterial;

    [Header("Fase 1 — Carga")]
    public float loadingDuration = 3f;

    [Header("Fase 2a — Vanish")]
    public float          vanishDuration = 1f;
    public AnimationCurve vanishCurve;

    // ── BackGround ────────────────────────────────────────────────────────────
    [Header("Fase 2b — BackGround")]
    public Material backgroundMaterial;
    public float    backgroundDuration = 2f;

    // ─────────────────────────────────────────────────────────────────────────

    // Reset() se invoca cuando el componente se agrega en el Editor,
    // por eso la curva aparece pre-cargada en el Inspector.
    void Reset()
    {
        vanishCurve = MakeEaseInCurve();
    }

    void Start() => Play();

    [ContextMenu("Play")]
    public void Play()
    {
        StopAllCoroutines();
        // Fallback por si se serializo vacia
        if (vanishCurve == null || vanishCurve.length == 0)
            vanishCurve = MakeEaseInCurve();

        ResetShaders();
        StartCoroutine(RunSequence());
    }

    void ResetShaders()
    {
        if (rotateUIMaterial != null)
        {
            rotateUIMaterial.SetFloat("_Progress", 0f);
            rotateUIMaterial.SetFloat("_Vanish",  -1f);
        }
        if (backgroundMaterial != null)
            backgroundMaterial.SetFloat("_Progreso", 0f);
    }

    IEnumerator RunSequence()
    {
        // ── Fase 1: barra de carga lineal ────────────────────────────────────
        if (rotateUIMaterial != null)
            yield return StartCoroutine(
                AnimateFloat(rotateUIMaterial, "_Progress", 0f, 1f,
                             loadingDuration, AnimationCurve.Linear(0, 0, 1, 1))
            );

        // ── Fase 2: Vanish y fondo arrancan juntos, Vanish termina antes ─────
        if (rotateUIMaterial != null)
            StartCoroutine(
                AnimateFloat(rotateUIMaterial, "_Vanish", -1f, 1f,
                             vanishDuration, vanishCurve)
            );

        if (backgroundMaterial != null)
            yield return StartCoroutine(
                AnimateFloat(backgroundMaterial, "_Progreso", 0f, 1.5f,
                             backgroundDuration, AnimationCurve.Linear(0, 0, 1, 1))
            );
    }

    // ── Coroutine generica ────────────────────────────────────────────────────

    IEnumerator AnimateFloat(Material mat, string prop,
                             float from, float to,
                             float duration, AnimationCurve curve)
    {
        mat.SetFloat(prop, from);
        float t = 0f;
        while (t < 1f)
        {
            t += Time.deltaTime / Mathf.Max(duration, 0.001f);
            mat.SetFloat(prop, Mathf.LerpUnclamped(from, to, curve.Evaluate(Mathf.Clamp01(t))));
            yield return null;
        }
        mat.SetFloat(prop, to);
    }

    static AnimationCurve MakeEaseInCurve()
    {
        return new AnimationCurve(
            new Keyframe(0f, 0f, 0f, 0f),  // arranque plano = lento
            new Keyframe(1f, 1f, 3f, 3f)   // llegada empinada = rapido
        );
    }
}
