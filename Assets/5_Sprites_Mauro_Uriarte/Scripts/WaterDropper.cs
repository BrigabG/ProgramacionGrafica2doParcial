using UnityEngine;

// Suelta 1 cubo cada 'dropInterval' segundos, indefinidamente, en una X aleatoria
// arriba de la pantalla (cae al agua). El click izquierdo tambien suelta uno.
public class WaterDropper : MonoBehaviour
{
    public WaterSpring water;
    public Camera cam;
    public float objectScale = 0.7f;

    [Header("Spawn automatico")]
    [Tooltip("Cada cuantos segundos cae un cubo")]
    public float dropInterval = 1.5f;
    [Tooltip("Segundos hasta que el cubo se autodestruye (0 = nunca, ojo que se acumulan)")]
    public float objectLifetime = 12f;
    [Tooltip("Margen horizontal respecto del borde de la pantalla")]
    public float edgeMargin = 1f;

    static readonly Color[] palette = {
        new Color(0.95f,0.35f,0.25f), new Color(0.95f,0.8f,0.2f),
        new Color(0.4f,0.85f,0.4f), new Color(0.6f,0.4f,0.9f), new Color(0.95f,0.55f,0.8f)
    };

    Sprite squareSprite;
    float timer;

    void Start()
    {
        if (cam == null) cam = Camera.main;
        squareSprite = Sprite.Create(Texture2D.whiteTexture, new Rect(0, 0, 4, 4), new Vector2(0.5f, 0.5f), 4f);
        timer = dropInterval; // tira uno apenas arranca
    }

    void Update()
    {
        timer += Time.deltaTime;
        if (timer >= dropInterval)
        {
            timer = 0f;
            SpawnRandom();
        }

        if (Input.GetMouseButtonDown(0))
        {
            Vector3 p = cam.ScreenToWorldPoint(Input.mousePosition);
            p.z = 0f;
            Spawn(p);
        }
    }

    // X aleatoria a lo ancho de la pantalla, cayendo desde arriba de la vista
    void SpawnRandom()
    {
        float halfW = cam.orthographicSize * cam.aspect;
        float x = Random.Range(-halfW + edgeMargin, halfW - edgeMargin);
        float y = cam.orthographicSize + 1f;
        Spawn(new Vector3(x, y, 0f));
    }

    void Spawn(Vector3 pos)
    {
        var go = new GameObject("Drop");
        go.transform.position = pos;
        go.transform.localScale = Vector3.one * objectScale;
        go.transform.rotation = Quaternion.Euler(0, 0, Random.Range(0f, 360f));

        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = squareSprite;
        sr.color = palette[Random.Range(0, palette.Length)];
        sr.sortingOrder = 10; // delante del agua, siempre visible

        var rb = go.AddComponent<Rigidbody2D>();
        rb.gravityScale = 1.4f;
        go.AddComponent<BoxCollider2D>();

        var b = go.AddComponent<Buoyancy2D>();
        b.water = water;

        if (objectLifetime > 0f)
            Destroy(go, objectLifetime);
    }
}
