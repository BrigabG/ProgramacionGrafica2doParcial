using UnityEngine;

public class DistanceWallDetection : MonoBehaviour
{
    [SerializeField] private Transform player;
    [SerializeField] private string positionProperty = "_Position";

    private Material material;
    private static readonly int FallbackPositionId = Shader.PropertyToID("_Position");

    private void Awake()
    {
        Renderer targetRenderer = GetComponent<Renderer>();
        if (targetRenderer != null)
        {
            material = targetRenderer.material;
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

    private void Update()
    {
        if (material == null || player == null)
        {
            return;
        }

        int propertyId = string.IsNullOrEmpty(positionProperty)
            ? FallbackPositionId
            : Shader.PropertyToID(positionProperty);

        material.SetVector(propertyId, player.position);
    }
}
