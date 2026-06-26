using UnityEngine;

public class UIScreenSwitcher : MonoBehaviour
{
    [Header("Canvases")]
    public GameObject splashCanvas;
    public GameObject loadingCanvas;

    [Header("Orquestadores")]
    public UIOrchestrator            splashOrchestrator;
    public LoadingScreenOrchestrator loadingOrchestrator;

    [Header("Background compartido")]
    public Material backgroundMaterial;

    void Start()
    {
        ShowSplash();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1)) ShowSplash();
        if (Input.GetKeyDown(KeyCode.Alpha2)) ShowLoading();
    }

    void ShowSplash()
    {
        loadingCanvas.SetActive(false);
        if (backgroundMaterial != null)
            backgroundMaterial.SetFloat("_Progreso", 0f);
        splashCanvas.SetActive(true);
        splashOrchestrator.Play();
    }

    void ShowLoading()
    {
        splashCanvas.SetActive(false);
        loadingCanvas.SetActive(true);
        loadingOrchestrator.Play();
    }
}
