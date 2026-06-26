using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DistancePlayerOverlayController : MonoBehaviour
{
    [SerializeField] private Camera mainCamera;
    [SerializeField] private Transform player;
    [SerializeField] private Vector3 playerOffset = new Vector3(0f, 0.9f, 0f);
    [SerializeField] private LayerMask blockerMask = ~0;
    [SerializeField] private float blockerCastRadius = 0.18f;
    [SerializeField] private float cutoutRadius = 0.18f;
    [SerializeField] private float startCutoutRadius = 0.035f;
    [SerializeField] private float cutoutFade = 0.075f;
    [SerializeField] private float maskActivationPadding = 0.02f;
    [SerializeField] private float radiusBlendSpeed = 7f;
    [SerializeField] private float revealBlendSpeed = 10f;
    [SerializeField] private Color cutoutTint = new Color(0.75f, 0.95f, 1f, 0.18f);
    [SerializeField] private float revealOpacity = 1f;
    [SerializeField] private int renderTextureSize = 1024;
    [SerializeField] private string hiddenFromRevealLayerName = "CutoutHidden";
    [SerializeField] private Material overlayMaterial;

    private static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    private static readonly int CutoutScreenPosId = Shader.PropertyToID("_CutoutScreenPos");
    private static readonly int CutoutRadiusId = Shader.PropertyToID("_CutoutRadius");
    private static readonly int CutoutFadeId = Shader.PropertyToID("_CutoutFade");
    private static readonly int AspectId = Shader.PropertyToID("_Aspect");
    private static readonly int TintColorId = Shader.PropertyToID("_TintColor");
    private static readonly int PlayerOpacityId = Shader.PropertyToID("_PlayerOpacity");
    private static readonly int EnabledId = Shader.PropertyToID("_Enabled");

    private readonly HashSet<GameObject> detectedBlockers = new HashSet<GameObject>();
    private readonly HashSet<GameObject> activeBlockers = new HashSet<GameObject>();
    private readonly Dictionary<Transform, int> originalLayers = new Dictionary<Transform, int>();

    private Camera revealCamera;
    private Canvas overlayCanvas;
    private RawImage overlayImage;
    private RenderTexture revealTexture;
    private int hiddenFromRevealLayer;
    private float revealStrength;
    private float currentCutoutRadius;

    private void Awake()
    {
        if (mainCamera == null)
        {
            mainCamera = GetComponent<Camera>();
        }

        if (mainCamera == null)
        {
            mainCamera = Camera.main;
        }

        if (player == null)
        {
            GameObject playerObject = GameObject.FindGameObjectWithTag("Player");
            if (playerObject != null)
            {
                player = playerObject.transform;
            }
        }

        hiddenFromRevealLayer = LayerMask.NameToLayer(hiddenFromRevealLayerName);
        if (hiddenFromRevealLayer < 0)
        {
            Debug.LogWarning($"Layer '{hiddenFromRevealLayerName}' does not exist. The reveal camera will not be able to hide blockers.", this);
            hiddenFromRevealLayer = 0;
        }

        EnsureRenderTexture();
        EnsureRevealCamera();
        EnsureOverlayCanvas();
    }

    private void OnDisable()
    {
        RestoreAllBlockers();
        if (overlayCanvas != null)
        {
            overlayCanvas.enabled = false;
        }
    }

    private void OnDestroy()
    {
        RestoreAllBlockers();
        if (revealTexture != null)
        {
            revealTexture.Release();
            Destroy(revealTexture);
        }
    }

    private void LateUpdate()
    {
        if (mainCamera == null || player == null || overlayMaterial == null || revealCamera == null || overlayCanvas == null)
        {
            RestoreAllBlockers();
            return;
        }

        Vector3 playerWorldPosition = player.position + playerOffset;
        Vector3 playerViewportPosition = mainCamera.WorldToViewportPoint(playerWorldPosition);
        bool playerVisibleToCamera = playerViewportPosition.z > mainCamera.nearClipPlane;

        detectedBlockers.Clear();
        if (playerVisibleToCamera)
        {
            FindBlockersBetweenCameraAndPlayer(playerWorldPosition, playerViewportPosition);
        }

        float targetStrength = playerVisibleToCamera && detectedBlockers.Count > 0 ? 1f : 0f;
        float blendT = 1f - Mathf.Exp(-Mathf.Max(0.01f, revealBlendSpeed) * Time.deltaTime);
        revealStrength = Mathf.Lerp(revealStrength, targetStrength, blendT);

        float minimumRadius = Mathf.Max(0.001f, startCutoutRadius);
        float targetRadius = targetStrength > 0f ? Mathf.Max(minimumRadius, cutoutRadius) : minimumRadius;
        if (currentCutoutRadius <= 0f)
        {
            currentCutoutRadius = minimumRadius;
        }

        float radiusT = 1f - Mathf.Exp(-Mathf.Max(0.01f, radiusBlendSpeed) * Time.deltaTime);
        currentCutoutRadius = Mathf.Lerp(currentCutoutRadius, targetRadius, radiusT);

        RestoreNoLongerDetectedBlockers();
        HideDetectedBlockersFromRevealCamera();
        SyncRevealCamera();

        overlayCanvas.enabled = revealStrength > 0.01f;
        overlayImage.texture = revealTexture;
        overlayMaterial.SetTexture(MainTexId, revealTexture);
        overlayMaterial.SetVector(CutoutScreenPosId, new Vector4(playerViewportPosition.x, playerViewportPosition.y, playerViewportPosition.z, 0f));
        overlayMaterial.SetFloat(CutoutRadiusId, Mathf.Max(0.001f, currentCutoutRadius));
        overlayMaterial.SetFloat(CutoutFadeId, Mathf.Max(0.0001f, cutoutFade));
        overlayMaterial.SetFloat(AspectId, (float)Screen.width / Mathf.Max(Screen.height, 1));
        overlayMaterial.SetColor(TintColorId, cutoutTint);
        overlayMaterial.SetFloat(PlayerOpacityId, Mathf.Clamp01(revealOpacity));
        overlayMaterial.SetFloat(EnabledId, revealStrength);
    }

    private void FindBlockersBetweenCameraAndPlayer(Vector3 playerWorldPosition, Vector3 playerViewportPosition)
    {
        Vector3 cameraPosition = mainCamera.transform.position;
        Vector3 cameraToPlayer = playerWorldPosition - cameraPosition;
        float playerDistance = cameraToPlayer.magnitude;
        if (playerDistance <= 0.01f)
        {
            return;
        }

        float maxHitDistance = Mathf.Max(0f, playerDistance - 0.08f);
        RaycastHit[] hits = Physics.SphereCastAll(
            cameraPosition,
            Mathf.Max(0.01f, blockerCastRadius),
            cameraToPlayer / playerDistance,
            maxHitDistance,
            blockerMask,
            QueryTriggerInteraction.Ignore);

        for (int i = 0; i < hits.Length; i++)
        {
            Collider hitCollider = hits[i].collider;
            if (hitCollider == null || hitCollider.transform.IsChildOf(player))
            {
                continue;
            }

            if (hits[i].distance >= maxHitDistance)
            {
                continue;
            }

            Renderer hitRenderer = hitCollider.GetComponentInParent<Renderer>();
            GameObject blocker = hitRenderer != null ? hitRenderer.gameObject : hitCollider.gameObject;
            if (blocker == null || blocker.transform.IsChildOf(player))
            {
                continue;
            }

            if (hitRenderer != null && !IsRendererInsideCutoutMask(hitRenderer, playerViewportPosition))
            {
                continue;
            }

            detectedBlockers.Add(blocker);
        }
    }

    private bool IsRendererInsideCutoutMask(Renderer targetRenderer, Vector3 playerViewportPosition)
    {
        Bounds bounds = targetRenderer.bounds;
        Vector3 center = bounds.center;
        Vector3 extents = bounds.extents;
        float minX = float.PositiveInfinity;
        float minY = float.PositiveInfinity;
        float maxX = float.NegativeInfinity;
        float maxY = float.NegativeInfinity;
        bool hasVisiblePoint = false;

        for (int x = -1; x <= 1; x += 2)
        {
            for (int y = -1; y <= 1; y += 2)
            {
                for (int z = -1; z <= 1; z += 2)
                {
                    Vector3 worldCorner = center + Vector3.Scale(extents, new Vector3(x, y, z));
                    Vector3 viewportCorner = mainCamera.WorldToViewportPoint(worldCorner);
                    if (viewportCorner.z <= mainCamera.nearClipPlane)
                    {
                        continue;
                    }

                    float aspect = (float)Screen.width / Mathf.Max(Screen.height, 1);
                    float scaledX = viewportCorner.x * aspect;
                    minX = Mathf.Min(minX, scaledX);
                    maxX = Mathf.Max(maxX, scaledX);
                    minY = Mathf.Min(minY, viewportCorner.y);
                    maxY = Mathf.Max(maxY, viewportCorner.y);
                    hasVisiblePoint = true;
                }
            }
        }

        if (!hasVisiblePoint)
        {
            return false;
        }

        float maskRadius = Mathf.Max(0.001f, currentCutoutRadius + cutoutFade + maskActivationPadding);
        float playerX = playerViewportPosition.x * ((float)Screen.width / Mathf.Max(Screen.height, 1));
        float playerY = playerViewportPosition.y;
        float closestX = Mathf.Clamp(playerX, minX, maxX);
        float closestY = Mathf.Clamp(playerY, minY, maxY);
        float distanceToMask = Vector2.Distance(new Vector2(playerX, playerY), new Vector2(closestX, closestY));
        return distanceToMask <= maskRadius;
    }
    private void HideDetectedBlockersFromRevealCamera()
    {
        foreach (GameObject blocker in detectedBlockers)
        {
            if (blocker == null)
            {
                continue;
            }

            if (!activeBlockers.Contains(blocker))
            {
                StoreLayersRecursively(blocker.transform);
                activeBlockers.Add(blocker);
            }

            SetLayerRecursively(blocker.transform, hiddenFromRevealLayer);
        }
    }

    private void RestoreNoLongerDetectedBlockers()
    {
        List<GameObject> toRestore = null;
        foreach (GameObject blocker in activeBlockers)
        {
            if (blocker == null || !detectedBlockers.Contains(blocker))
            {
                if (toRestore == null)
                {
                    toRestore = new List<GameObject>();
                }

                toRestore.Add(blocker);
            }
        }

        if (toRestore == null)
        {
            return;
        }

        for (int i = 0; i < toRestore.Count; i++)
        {
            RestoreBlocker(toRestore[i]);
        }
    }

    private void RestoreAllBlockers()
    {
        List<GameObject> toRestore = new List<GameObject>(activeBlockers);
        for (int i = 0; i < toRestore.Count; i++)
        {
            RestoreBlocker(toRestore[i]);
        }
        originalLayers.Clear();
    }

    private void RestoreBlocker(GameObject blocker)
    {
        if (blocker != null)
        {
            RestoreLayersRecursively(blocker.transform);
        }
        activeBlockers.Remove(blocker);
    }

    private void StoreLayersRecursively(Transform target)
    {
        if (!originalLayers.ContainsKey(target))
        {
            originalLayers.Add(target, target.gameObject.layer);
        }

        for (int i = 0; i < target.childCount; i++)
        {
            StoreLayersRecursively(target.GetChild(i));
        }
    }

    private void RestoreLayersRecursively(Transform target)
    {
        if (originalLayers.TryGetValue(target, out int originalLayer))
        {
            target.gameObject.layer = originalLayer;
            originalLayers.Remove(target);
        }

        for (int i = 0; i < target.childCount; i++)
        {
            RestoreLayersRecursively(target.GetChild(i));
        }
    }

    private static void SetLayerRecursively(Transform target, int layer)
    {
        target.gameObject.layer = layer;
        for (int i = 0; i < target.childCount; i++)
        {
            SetLayerRecursively(target.GetChild(i), layer);
        }
    }

    private void EnsureRenderTexture()
    {
        if (revealTexture != null)
        {
            return;
        }

        revealTexture = new RenderTexture(renderTextureSize, renderTextureSize, 24, RenderTextureFormat.ARGB32)
        {
            name = "DistanceRevealRT",
            antiAliasing = 4
        };
        revealTexture.Create();
    }

    private void EnsureRevealCamera()
    {
        GameObject cameraObject = new GameObject("Distance Reveal Camera");
        cameraObject.transform.SetParent(transform, false);
        revealCamera = cameraObject.AddComponent<Camera>();
        revealCamera.enabled = true;
        revealCamera.targetTexture = revealTexture;
        revealCamera.depth = mainCamera.depth - 1f;
        SyncRevealCamera();
    }

    private void EnsureOverlayCanvas()
    {
        GameObject canvasObject = new GameObject("Distance Cutout Overlay");
        overlayCanvas = canvasObject.AddComponent<Canvas>();
        overlayCanvas.renderMode = RenderMode.ScreenSpaceOverlay;
        overlayCanvas.sortingOrder = 5000;
        canvasObject.AddComponent<CanvasScaler>();
        canvasObject.AddComponent<GraphicRaycaster>();

        GameObject imageObject = new GameObject("Distance Reveal RawImage");
        imageObject.transform.SetParent(canvasObject.transform, false);
        overlayImage = imageObject.AddComponent<RawImage>();
        overlayImage.texture = revealTexture;
        overlayImage.material = overlayMaterial;
        overlayImage.raycastTarget = false;

        RectTransform rect = overlayImage.rectTransform;
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;

        overlayCanvas.enabled = false;
    }

    private void SyncRevealCamera()
    {
        revealCamera.transform.SetPositionAndRotation(mainCamera.transform.position, mainCamera.transform.rotation);
        revealCamera.clearFlags = mainCamera.clearFlags;
        revealCamera.backgroundColor = mainCamera.backgroundColor;
        revealCamera.fieldOfView = mainCamera.fieldOfView;
        revealCamera.nearClipPlane = mainCamera.nearClipPlane;
        revealCamera.farClipPlane = mainCamera.farClipPlane;
        revealCamera.orthographic = mainCamera.orthographic;
        revealCamera.orthographicSize = mainCamera.orthographicSize;
        revealCamera.aspect = mainCamera.aspect;
        revealCamera.allowHDR = mainCamera.allowHDR;
        revealCamera.allowMSAA = mainCamera.allowMSAA;
        revealCamera.cullingMask = mainCamera.cullingMask & ~(1 << hiddenFromRevealLayer);
    }
}


