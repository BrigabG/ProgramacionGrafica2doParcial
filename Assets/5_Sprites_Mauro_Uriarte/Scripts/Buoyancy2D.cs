using UnityEngine;

// Flotabilidad simple: empuja el objeto hacia arriba segun cuanto este sumergido,
// con arrastre dentro del agua. Asi los objetos entran, se hunden un poco y rebotan
// hacia la superficie (entrando y saliendo del agua).
[RequireComponent(typeof(Rigidbody2D))]
public class Buoyancy2D : MonoBehaviour
{
    public WaterSpring water;
    public float floatForce = 22f;
    public float waterDrag = 1.8f;
    public float maxDepth = 3f;

    Rigidbody2D rb;
    void Awake() { rb = GetComponent<Rigidbody2D>(); }

    void FixedUpdate()
    {
        if (water == null) return;
        float submerged = water.SurfaceWorldY - transform.position.y;
        if (submerged > 0f)
        {
            float f = floatForce * Mathf.Clamp01(submerged / maxDepth);
            rb.AddForce(Vector2.up * f, ForceMode2D.Force);
            rb.velocity *= Mathf.Clamp01(1f - waterDrag * Time.fixedDeltaTime);
        }
    }
}
