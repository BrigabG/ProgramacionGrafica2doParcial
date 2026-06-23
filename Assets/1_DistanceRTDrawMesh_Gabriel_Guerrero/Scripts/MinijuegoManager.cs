using UnityEngine;

public class MinijuegoManager : MonoBehaviour
{
    [Header("Enjambre")]
    [Tooltip("Distintas mallas que se mezclarán en el enjambre.")]
    [SerializeField] private Mesh[] mallas;

    [Tooltip("Material compartido para todos los objetos. Debe exponer '_Color' o '_BaseColor'.")]
    [SerializeField] private Material materialBase;

    [Tooltip("Cantidad de objetos a dibujar.")]
    [SerializeField] private int cantidad = 300;

    [Tooltip("Profundidad máxima de distribución (Z en viewport).")]
    [SerializeField] private float areaSize = 15f;

    [Tooltip("Velocidad de rotación en grados por segundo.")]
    [SerializeField] private float velocidadRotacion = 60f;

    [Header("Exploración (Scroll y Pan)")]
    [Tooltip("Sensibilidad de la rueda del mouse para bucear en el enjambre.")]
    [SerializeField] private float velocidadScroll = 15f;

    [Tooltip("Sensibilidad del paneo con Mouse 2 presionado.")]
    [SerializeField] private float velocidadPan = 0.05f;

    [Header("Lógica del Juego y Foto")]
    [Tooltip("La cámara que usamos para el juego y para sacar la foto.")]
    [SerializeField] private Camera camaraPrincipal;

    [Tooltip("El script de los binoculares para apagarlo al sacar la foto.")]
    [SerializeField] private EfectoBinoculares scriptBinoculares;

    [Tooltip("RawImage en el Canvas donde se muestra la foto del acierto.")]
    [SerializeField] private UnityEngine.UI.RawImage uiFoto;

    [Tooltip("Radio en píxeles para considerar un clic como acierto sobre el objetivo.")]
    [SerializeField] private float radioClicPixeles = 50f;

    [Header("UI del Objetivo a Buscar")]
    [Tooltip("Cámara alejada (ej: Y=1000) que filmará el objeto a buscar.")]
    [SerializeField] private Camera camaraMuestra;

    [Tooltip("RawImage en el Canvas donde el jugador verá qué tiene que buscar.")]
    [SerializeField] private UnityEngine.UI.RawImage uiMuestra;

    // ── Posición 3D fija en el mundo, calculada una vez en Init ──────────
    private Vector3[] posicionesMundoOriginales;

    // Posición actual tras el desplazamiento de scroll — usada para el clic
    private Vector3[] posicionesMundoActuales;

    private float   avanceProfundidad = 0f;
    private Vector3 panOffset         = Vector3.zero;

    // ── Resto de datos por objeto ─────────────────────────────────────────
    private Vector3[]               escalas;
    private Vector3[]               ejesRotacion;
    private float[]                 offsetsRotacion;
    private int[]                   indiceMalla;

    private MaterialPropertyBlock[] propBlocks;
    private static readonly int     ColorID = Shader.PropertyToID("_Color");

    // ── Estado del juego ──────────────────────────────────────────────────
    private int           indiceObjetivoUnico;
    private RenderTexture fotoRT;
    private RenderTexture rtMuestra;

    // ──────────────────────────────────────────────────────────────────────

    void Start()
    {
        if (camaraPrincipal == null)
            camaraPrincipal = Camera.main;

        InicializarEnjambre();
    }

    void Update()
    {
        DibujarEnjambre();

        if (Input.GetMouseButtonDown(0))
            ComprobarClicObjetivo();
    }

    // ── Inicialización (una sola vez por ronda) ───────────────────────────

    void InicializarEnjambre()
    {
        if (mallas == null || mallas.Length == 0)
        {
            Debug.LogError("MinijuegoManager: asigná al menos una Mesh en el Inspector.");
            return;
        }
        if (materialBase == null)
        {
            Debug.LogError("MinijuegoManager: asigná un Material en el Inspector.");
            return;
        }

        posicionesMundoOriginales = new Vector3[cantidad];
        posicionesMundoActuales   = new Vector3[cantidad];
        escalas                   = new Vector3[cantidad];
        ejesRotacion              = new Vector3[cantidad];
        offsetsRotacion           = new float[cantidad];
        indiceMalla               = new int[cantidad];
        propBlocks                = new MaterialPropertyBlock[cantidad];

        avanceProfundidad = 0f;
        panOffset         = Vector3.zero;

        indiceObjetivoUnico = Random.Range(0, cantidad);

        for (int i = 0; i < cantidad; i++)
        {
            // Viewport garantiza spawn dentro de pantalla; guardamos la posición de mundo resultante
            Vector3 vp = new Vector3(
                Random.Range(0.1f, 0.9f),
                Random.Range(0.1f, 0.9f),
                Random.Range(5f, areaSize)
            );
            posicionesMundoOriginales[i] = camaraPrincipal != null
                ? camaraPrincipal.ViewportToWorldPoint(vp)
                : new Vector3(vp.x * 10f - 5f, vp.y * 10f - 5f, vp.z);

            float s = Random.Range(0.2f, 1.4f);
            escalas[i]         = new Vector3(s, s * Random.Range(0.7f, 1.3f), s);
            ejesRotacion[i]    = Random.onUnitSphere;
            offsetsRotacion[i] = Random.Range(0f, 360f);
            indiceMalla[i]     = Random.Range(0, mallas.Length);

            propBlocks[i] = new MaterialPropertyBlock();

            Color color = (i == indiceObjetivoUnico)
                ? Color.white
                : Random.ColorHSV(0f, 1f, 0.5f, 1f, 0.5f, 1f);

            propBlocks[i].SetColor(ColorID, color);
        }

        if (camaraMuestra != null && uiMuestra != null && rtMuestra == null)
        {
            rtMuestra = new RenderTexture(256, 256, 16);
            rtMuestra.Create();
            camaraMuestra.targetTexture = rtMuestra;
            uiMuestra.texture = rtMuestra;
        }

        Debug.Log($"MinijuegoManager: enjambre de {cantidad} objetos inicializado. Objetivo: #{indiceObjetivoUnico}");
    }

    // ── Dibujo frame a frame ──────────────────────────────────────────────

    void DibujarEnjambre()
    {
        if (posicionesMundoOriginales == null) return;

        float scroll = Input.GetAxis("Mouse ScrollWheel");
        avanceProfundidad += scroll * velocidadScroll;
        avanceProfundidad  = Mathf.Clamp(avanceProfundidad, -5f, areaSize - 4f);

        // Pan con Mouse 2 presionado — mueve los objetos en el plano XY de la cámara
        if (Input.GetMouseButton(2))
        {
            panOffset += camaraPrincipal.transform.right * (Input.GetAxis("Mouse X") * velocidadPan);
            panOffset += camaraPrincipal.transform.up    * (Input.GetAxis("Mouse Y") * velocidadPan);
        }

        float angulo = Time.time * velocidadRotacion;

        for (int i = 0; i < cantidad; i++)
        {
            // Los objetos se desplazan hacia la cámara (paralaje real)
            Vector3 posMundo = posicionesMundoOriginales[i] - (camaraPrincipal.transform.forward * avanceProfundidad) + panOffset;

            // Frustum culling: distancia en espacio local de la cámara
            float distanciaAlLente = camaraPrincipal.transform.InverseTransformPoint(posMundo).z;
            if (distanciaAlLente < camaraPrincipal.nearClipPlane) continue;

            posicionesMundoActuales[i] = posMundo;

            Quaternion rotacion = Quaternion.AngleAxis(offsetsRotacion[i] + angulo, ejesRotacion[i]);
            Matrix4x4  matriz   = Matrix4x4.TRS(posMundo, rotacion, escalas[i]);

            Graphics.DrawMesh(mallas[indiceMalla[i]], matriz, materialBase, 0, null, 0, propBlocks[i]);
        }

        // Preview del objetivo para la UI (solo para camaraMuestra)
        if (camaraMuestra != null)
        {
            Vector3    posMuestra    = camaraMuestra.transform.position + camaraMuestra.transform.forward * 3f;
            Quaternion rotMuestra    = Quaternion.Euler(20f, angulo, 0f);
            Matrix4x4  matrizMuestra = Matrix4x4.TRS(posMuestra, rotMuestra, Vector3.one);

            Graphics.DrawMesh(
                mallas[indiceMalla[indiceObjetivoUnico]],
                matrizMuestra,
                materialBase,
                0,
                camaraMuestra,
                0,
                propBlocks[indiceObjetivoUnico]
            );
        }
    }

    // ── Detección del clic (matemática 2D, sin Raycast ni Colliders) ──────

    void ComprobarClicObjetivo()
    {
        if (camaraPrincipal == null || posicionesMundoActuales == null) return;

        Vector3 posPantalla = camaraPrincipal.WorldToScreenPoint(posicionesMundoActuales[indiceObjetivoUnico]);
        if (posPantalla.z < 0f) return;

        float distancia = Vector2.Distance(
            Input.mousePosition,
            new Vector2(posPantalla.x, posPantalla.y)
        );

        Debug.Log($"Distancia al objetivo: {distancia:F1}px (umbral: {radioClicPixeles}px)");

        if (distancia < radioClicPixeles)
            TomarFotoYReiniciar();
    }

    // ── Foto + reinicio ────────────────────────────────────────────────────

    void TomarFotoYReiniciar()
    {
        LimpiarFoto();

        fotoRT = new RenderTexture(Screen.width, Screen.height, 16);
        fotoRT.Create();

        if (scriptBinoculares != null) scriptBinoculares.activarEfecto = false;

        camaraPrincipal.targetTexture = fotoRT;
        camaraPrincipal.Render();

        camaraPrincipal.targetTexture = null;
        if (scriptBinoculares != null) scriptBinoculares.activarEfecto = true;

        if (uiFoto != null)
            uiFoto.texture = fotoRT;

        Reiniciar();
    }

    // ── Limpieza de VRAM ──────────────────────────────────────────────────

    void LimpiarFoto()
    {
        if (fotoRT == null) return;

        if (camaraPrincipal != null && camaraPrincipal.targetTexture == fotoRT)
            camaraPrincipal.targetTexture = null;

        fotoRT.Release();
        Destroy(fotoRT);
        fotoRT = null;
    }

    void LimpiarMuestra()
    {
        if (rtMuestra == null) return;

        if (camaraMuestra != null && camaraMuestra.targetTexture == rtMuestra)
            camaraMuestra.targetTexture = null;

        rtMuestra.Release();
        Destroy(rtMuestra);
        rtMuestra = null;
    }

    void OnDestroy()
    {
        LimpiarFoto();
        LimpiarMuestra();
    }

    // ── API pública ───────────────────────────────────────────────────────

    public void Reiniciar()
    {
        InicializarEnjambre();
    }
}
