using UnityEngine;

public class EagleVisionTarget : MonoBehaviour
{
    [SerializeField] private Renderer[] targetRenderers;

    private void Awake()
    {
        CacheRenderersIfNeeded();
    }

    private void OnValidate()
    {
        CacheRenderersIfNeeded();
    }

    public void SetVisionActive(bool value)
    {
        CacheRenderersIfNeeded();
        gameObject.SetActive(value);

        foreach (Renderer targetRenderer in targetRenderers)
        {
            if (targetRenderer != null)
            {
                targetRenderer.enabled = value;
            }
        }
    }

    private void CacheRenderersIfNeeded()
    {
        if (targetRenderers == null || targetRenderers.Length == 0)
        {
            targetRenderers = GetComponentsInChildren<Renderer>(true);
        }
    }
}
