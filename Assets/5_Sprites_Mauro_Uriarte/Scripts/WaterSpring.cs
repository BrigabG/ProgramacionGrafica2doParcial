using UnityEngine;

// Agua 2D con superficie de "resortes" (springs).
//  - Ondula siempre (ola senoidal base).
//  - Cada resorte oscila y propaga el movimiento a sus vecinos => olas.
//  - Reacciona a objetos que entran/salen (OnTrigger2D -> Splash).
// Genera y actualiza una malla; el material usa el shader Water2D (refraccion).
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class WaterSpring : MonoBehaviour
{
    [Header("Dimensiones (local)")]
    public float width = 18f;
    public float depth = 7f;
    public int columns = 90;

    [Header("Ola base (idle)")]
    public float idleAmplitude = 0.10f;
    public float idleFrequency = 0.9f;
    public float idleSpeed = 1.4f;

    [Header("Resortes / reaccion")]
    [Range(0f, 0.2f)] public float springConstant = 0.025f;
    [Range(0f, 0.2f)] public float damping = 0.03f;
    [Range(0f, 0.5f)] public float spread = 0.25f;
    public float splashForce = 0.35f;
    [Tooltip("Tope de la velocidad de impacto que se usa para el splash (evita golpes enormes si cae muy rapido)")]
    public float maxSplashSpeed = 6f;

    float[] height, velocity, lDelta, rDelta;
    Mesh mesh;
    Vector3[] verts;

    public float SurfaceWorldY => transform.position.y;

    void Start()
    {
        int n = columns + 1;
        height = new float[n];
        velocity = new float[n];
        lDelta = new float[n];
        rDelta = new float[n];
        BuildMesh();
    }

    void BuildMesh()
    {
        int n = columns + 1;
        mesh = new Mesh { name = "WaterMesh" };
        verts = new Vector3[n * 2];
        var uv = new Vector2[n * 2];
        var tris = new int[columns * 6];
        for (int i = 0; i < n; i++)
        {
            float t = (float)i / columns;
            float x = -width * 0.5f + t * width;
            verts[i] = new Vector3(x, 0f, 0f);
            verts[i + n] = new Vector3(x, -depth, 0f);
            uv[i] = new Vector2(t, 1f);
            uv[i + n] = new Vector2(t, 0f);
        }
        for (int i = 0; i < columns; i++)
        {
            int ti = i * 6;
            tris[ti] = i; tris[ti + 1] = i + 1; tris[ti + 2] = i + n;
            tris[ti + 3] = i + 1; tris[ti + 4] = i + 1 + n; tris[ti + 5] = i + n;
        }
        mesh.vertices = verts; mesh.uv = uv; mesh.triangles = tris;
        mesh.RecalculateBounds();
        GetComponent<MeshFilter>().sharedMesh = mesh;
    }

    void Update()
    {
        int n = columns + 1;

        // 1) cada resorte tiende a volver a 0 (Hooke + amortiguacion)
        for (int i = 0; i < n; i++)
        {
            float force = -springConstant * height[i] - velocity[i] * damping;
            velocity[i] += force;
            height[i] += velocity[i];
        }

        // 2) propagacion a vecinos (clasico algoritmo de aguas 2D)
        for (int pass = 0; pass < 2; pass++)
        {
            for (int i = 0; i < n; i++)
            {
                if (i > 0)      { lDelta[i] = spread * (height[i] - height[i - 1]); velocity[i - 1] += lDelta[i]; }
                if (i < n - 1)  { rDelta[i] = spread * (height[i] - height[i + 1]); velocity[i + 1] += rDelta[i]; }
            }
            for (int i = 0; i < n; i++)
            {
                if (i > 0)      height[i - 1] += lDelta[i];
                if (i < n - 1)  height[i + 1] += rDelta[i];
            }
        }

        // 3) actualizar vertices de la superficie = ola base + resorte
        float time = Time.time;
        for (int i = 0; i < n; i++)
        {
            float x = verts[i].x;
            float idle = idleAmplitude * Mathf.Sin(x * idleFrequency + time * idleSpeed);
            verts[i].y = idle + height[i];
        }
        mesh.vertices = verts;
        mesh.RecalculateBounds();
    }

    // velocityY negativo = salpicadura hacia abajo (objeto entrando)
    public void Splash(float worldX, float velocityY)
    {
        int n = columns + 1;
        float localX = transform.InverseTransformPoint(new Vector3(worldX, 0f, 0f)).x;
        float t = Mathf.InverseLerp(-width * 0.5f, width * 0.5f, localX);
        int idx = Mathf.Clamp(Mathf.RoundToInt(t * columns), 0, n - 1);
        float f = velocityY * splashForce;
        velocity[idx] += f;
        if (idx > 0)     velocity[idx - 1] += f * 0.5f;
        if (idx < n - 1) velocity[idx + 1] += f * 0.5f;
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        var rb = other.attachedRigidbody;
        float v = rb ? rb.velocity.y : -3f;
        v = Mathf.Clamp(v, -maxSplashSpeed, -0.8f);           // entra: hacia abajo, acotado
        Splash(other.transform.position.x, v);
    }

    void OnTriggerExit2D(Collider2D other)
    {
        var rb = other.attachedRigidbody;
        float v = rb ? rb.velocity.y : 3f;
        v = Mathf.Clamp(v, 0.8f, maxSplashSpeed) * 0.6f;      // sale: hacia arriba, acotado
        Splash(other.transform.position.x, v);
    }
}
