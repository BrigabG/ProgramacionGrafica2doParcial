using UnityEngine;

// Aplica shaders fullscreen por OnRenderImage (Graphics.Blit) en Built-in RP.
// Teclas en Play:
//   1 = Flash-bang (dispara el destello, se desvanece solo)
//   2 = Borracho (vision doble + bamboleo, continuo)
//   3 = Despertando (vinheta/blur que se abre)
//   0 = sin efecto
[ExecuteAlways]
[RequireComponent(typeof(Camera))]
public class PostProcessController : MonoBehaviour
{
    public enum Effect { None = 0, Flashbang = 1, Drunk = 2, WakeUp = 3 }

    [Header("Materiales (shaders de Amplify)")]
    public Material flashbangMat;
    public Material drunkMat;
    public Material wakeUpMat;

    [Header("Estado actual")]
    public Effect effect = Effect.None;

    [Header("Flash-bang")]
    [Range(0f, 1f)] public float flash = 0f;
    public float flashFadeSpeed = 0.8f;

    [Header("Despertando")]
    [Range(0f, 1f)] public float wakeProgress = 1f;   // 0 = recien despertando, 1 = despierto
    public float wakeDuration = 3.5f;

    void Update()
    {
        if (!Application.isPlaying) return;

        if (Input.GetKeyDown(KeyCode.Alpha1)) { effect = Effect.Flashbang; flash = 1f; }
        if (Input.GetKeyDown(KeyCode.Alpha2)) { effect = Effect.Drunk; }
        if (Input.GetKeyDown(KeyCode.Alpha3)) { effect = Effect.WakeUp; wakeProgress = 0f; }
        if (Input.GetKeyDown(KeyCode.Alpha0)) { effect = Effect.None; }

        if (effect == Effect.Flashbang)
            flash = Mathf.MoveTowards(flash, 0f, flashFadeSpeed * Time.deltaTime);

        if (effect == Effect.WakeUp)
            wakeProgress = Mathf.MoveTowards(wakeProgress, 1f, (1f / Mathf.Max(0.01f, wakeDuration)) * Time.deltaTime);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Material m = null;
        switch (effect)
        {
            case Effect.Flashbang:
                if (flashbangMat != null) { flashbangMat.SetFloat("_Flash", flash); m = flashbangMat; }
                break;
            case Effect.Drunk:
                m = drunkMat; // animado por _Time dentro del shader
                break;
            case Effect.WakeUp:
                if (wakeUpMat != null) { wakeUpMat.SetFloat("_Wake", wakeProgress); m = wakeUpMat; }
                break;
        }

        if (m != null) Graphics.Blit(src, dst, m);
        else Graphics.Blit(src, dst);
    }
}
