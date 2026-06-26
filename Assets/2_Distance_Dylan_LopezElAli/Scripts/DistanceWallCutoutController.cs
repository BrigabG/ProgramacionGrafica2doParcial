using System.Collections.Generic;
using UnityEngine;

public class DistanceWallCutoutController : MonoBehaviour
{
    [SerializeField] private Camera targetCamera;
    [SerializeField] private Transform player;
    [SerializeField] private Vector3 playerOffset = new Vector3(0f, 0.9f, 0f);
    [SerializeField] private LayerMask occluderMask = ~0;
    [SerializeField] private float detectionRadius = 1.25f;
    [SerializeField] private float cutoutRadius = 1.25f;
    [SerializeField] private float cutoutFade = 0.25f;
    [SerializeField] private float castInterval = 0.05f;
    [SerializeField] private float cutoutLerpSpeed = 12f;
    [SerializeField] private Material cutoutMaterial;

    private static readonly int StartId = Shader.PropertyToID("_CutoutStart");
    private static readonly int EndId = Shader.PropertyToID("_CutoutEnd");
    private static readonly int RadiusId = Shader.PropertyToID("_CutoutRadius");
    private static readonly int FadeId = Shader.PropertyToID("_CutoutFade");
    private static readonly int EnabledId = Shader.PropertyToID("_CutoutEnabled");

    private readonly Dictionary<Renderer, Material[]> originalMaterials = new Dictionary<Renderer, Material[]>();
    private readonly HashSet<Renderer> activeOccluders = new HashSet<Renderer>();
    private readonly HashSet<Renderer> detectedOccluders = new HashSet<Renderer>();
    private readonly Collider[] overlapResults = new Collider[64];
    private MaterialPropertyBlock propertyBlock;
    private float nextCastTime;
    private Vector3 smoothedStart;
    private Vector3 smoothedEnd;
    private float smoothedEnabled;
    private bool hasSmoothedValues;

    private void Awake()
    {
        propertyBlock = new MaterialPropertyBlock();

        if (targetCamera == null)
        {
            targetCamera = Camera.main;
        }

        if (player == null)
        {
            GameObject playerObject = GameObject.FindGameObjectWithTag("Player");
            if (playerObject != null)
            {
                player = playerObject.transform;
            }
        }
    }

    private void OnDisable()
    {
        RestoreAllOccluders();
    }

    private void LateUpdate()
    {
        if (targetCamera == null || player == null || cutoutMaterial == null)
        {
            RestoreAllOccluders();
            return;
        }

        Vector3 playerPosition = player.position + playerOffset;
        Vector3 cameraPosition = targetCamera.transform.position;

        if (!hasSmoothedValues)
        {
            smoothedStart = playerPosition;
            smoothedEnd = cameraPosition;
            hasSmoothedValues = true;
        }

        if (Time.time >= nextCastTime)
        {
            nextCastTime = Time.time + Mathf.Max(0.01f, castInterval);
            DetectOccluders(playerPosition, cameraPosition);
        }

        float targetEnabled = detectedOccluders.Count > 0 ? 1f : 0f;
        float lerpT = 1f - Mathf.Exp(-cutoutLerpSpeed * Time.deltaTime);
        smoothedStart = Vector3.Lerp(smoothedStart, playerPosition, lerpT);
        smoothedEnd = Vector3.Lerp(smoothedEnd, cameraPosition, lerpT);
        smoothedEnabled = Mathf.Lerp(smoothedEnabled, targetEnabled, lerpT);

        RestoreNoLongerDetectedRenderers();
        ApplyCutoutToDetectedRenderers();
    }

    private void DetectOccluders(Vector3 playerPosition, Vector3 cameraPosition)
    {
        detectedOccluders.Clear();

        Vector3 playerToCamera = cameraPosition - playerPosition;
        float distanceToCamera = playerToCamera.magnitude;
        if (distanceToCamera <= 0.01f)
        {
            return;
        }

        Vector3 direction = playerToCamera / distanceToCamera;
        Vector3 capsuleStart = playerPosition + direction * 0.15f;
        Vector3 capsuleEnd = cameraPosition - direction * 0.15f;
        float radius = Mathf.Max(0.01f, detectionRadius);

        int overlapCount = Physics.OverlapCapsuleNonAlloc(
            capsuleStart,
            capsuleEnd,
            radius,
            overlapResults,
            occluderMask,
            QueryTriggerInteraction.Ignore);

        for (int i = 0; i < overlapCount; i++)
        {
            Collider hitCollider = overlapResults[i];
            overlapResults[i] = null;

            if (hitCollider == null || hitCollider.transform.IsChildOf(player))
            {
                continue;
            }

            Renderer hitRenderer = hitCollider.GetComponentInParent<Renderer>();
            if (hitRenderer == null || hitRenderer.sharedMaterial == null || hitRenderer.transform.IsChildOf(player))
            {
                continue;
            }

            if (!IsBetweenPlayerAndCamera(hitRenderer.bounds, playerPosition, direction, distanceToCamera))
            {
                continue;
            }

            detectedOccluders.Add(hitRenderer);
        }
    }

    private bool IsBetweenPlayerAndCamera(Bounds bounds, Vector3 playerPosition, Vector3 playerToCameraDirection, float distanceToCamera)
    {
        Vector3 closestPointToPlayer = bounds.ClosestPoint(playerPosition);
        float distanceAlongView = Vector3.Dot(closestPointToPlayer - playerPosition, playerToCameraDirection);
        return distanceAlongView > 0.02f && distanceAlongView < distanceToCamera - 0.02f;
    }

    private void ApplyCutoutToDetectedRenderers()
    {
        foreach (Renderer occluder in detectedOccluders)
        {
            if (occluder == null)
            {
                continue;
            }

            if (!originalMaterials.ContainsKey(occluder))
            {
                originalMaterials.Add(occluder, occluder.sharedMaterials);
            }

            Material[] cutoutMaterials = occluder.sharedMaterials;
            for (int i = 0; i < cutoutMaterials.Length; i++)
            {
                cutoutMaterials[i] = cutoutMaterial;
            }
            occluder.sharedMaterials = cutoutMaterials;

            occluder.GetPropertyBlock(propertyBlock);
            propertyBlock.SetVector(StartId, smoothedStart);
            propertyBlock.SetVector(EndId, smoothedEnd);
            propertyBlock.SetFloat(RadiusId, Mathf.Max(0.01f, cutoutRadius));
            propertyBlock.SetFloat(FadeId, Mathf.Max(0.001f, cutoutFade));
            propertyBlock.SetFloat(EnabledId, smoothedEnabled);
            occluder.SetPropertyBlock(propertyBlock);

            activeOccluders.Add(occluder);
        }
    }

    private void RestoreNoLongerDetectedRenderers()
    {
        List<Renderer> toRestore = null;

        foreach (Renderer activeOccluder in activeOccluders)
        {
            if (activeOccluder == null || !detectedOccluders.Contains(activeOccluder))
            {
                if (toRestore == null)
                {
                    toRestore = new List<Renderer>();
                }

                toRestore.Add(activeOccluder);
            }
        }

        if (toRestore == null)
        {
            return;
        }

        for (int i = 0; i < toRestore.Count; i++)
        {
            RestoreOccluder(toRestore[i]);
        }
    }

    private void RestoreAllOccluders()
    {
        if (activeOccluders.Count == 0)
        {
            return;
        }

        List<Renderer> toRestore = new List<Renderer>(activeOccluders);
        for (int i = 0; i < toRestore.Count; i++)
        {
            RestoreOccluder(toRestore[i]);
        }
    }

    private void RestoreOccluder(Renderer occluder)
    {
        if (occluder != null && originalMaterials.TryGetValue(occluder, out Material[] materials))
        {
            occluder.sharedMaterials = materials;
            occluder.SetPropertyBlock(null);
        }

        activeOccluders.Remove(occluder);
        originalMaterials.Remove(occluder);
    }
}
