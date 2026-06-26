using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using UnityEngine.EventSystems;

// Construye en runtime el menu principal: un boton por escena de ejercicio.
// No persiste entre escenas (solo vive en la escena Main); el ESC lo maneja SceneNavigator.
public class MainMenuUI : MonoBehaviour
{
    // (texto del boton, nombre de la escena en Build Settings)
    static readonly string[,] ENTRIES = new string[,]
    {
        { "1 - Distance RT / DrawMesh",   "Minijuego" },
        { "2 - Distance Wall-Through",    "DistanceWallThrough" },
        { "3 - Z-Buffer",                 "ZBuffer" },
        { "4 - Post-Process",             "PostProcess" },
        { "3+4 - ZBuffer y PostProcess",  "ZBuffer y PostProcess" },
        { "5 - Sprites / Agua 2D",        "Water2D" },
        { "6 - UI",                       "UI" },
        { "7 - Stencil & ZBuffer",        "Stencil&ZBuffer" },
        { "8 - Stencil / Carta",          "Carta" },
        { "9 - Projector Caustics",       "Punto09_Projector_Underwater_Caustics" },
        { "10 - Projector Windows Light", "Punto10_Projector_Real_WindowsLight" },
        { "11 - Projector Sensor SciFi",  "Punto11_Projector_SensorSciFi" },
    };

    Font font;

    void Start()
    {
        font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        if (font == null) font = Resources.GetBuiltinResource<Font>("Arial.ttf");

        if (FindObjectOfType<EventSystem>() == null)
        {
            var es = new GameObject("EventSystem", typeof(EventSystem), typeof(StandaloneInputModule));
        }

        // Canvas
        var canvasGO = new GameObject("MenuCanvas", typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
        var canvas = canvasGO.GetComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        var scaler = canvasGO.GetComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920, 1080);
        scaler.matchWidthOrHeight = 0.5f;

        // Titulo
        MakeText(canvasGO.transform, "Programacion Grafica - 2do Parcial", 56, FontStyle.Bold,
                 new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0, -90), new Vector2(1600, 90));
        MakeText(canvasGO.transform, "Elegi un ejercicio  ( ESC = volver al menu )", 28, FontStyle.Normal,
                 new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0.5f, 1f), new Vector2(0, -160), new Vector2(1600, 50));

        // Contenedor con grilla de botones (2 columnas)
        var panel = new GameObject("ButtonsPanel", typeof(RectTransform), typeof(GridLayoutGroup));
        panel.transform.SetParent(canvasGO.transform, false);
        var prt = panel.GetComponent<RectTransform>();
        prt.anchorMin = new Vector2(0.5f, 0.5f);
        prt.anchorMax = new Vector2(0.5f, 0.5f);
        prt.pivot = new Vector2(0.5f, 0.5f);
        prt.anchoredPosition = new Vector2(0, -40);
        prt.sizeDelta = new Vector2(1000, 640);
        var grid = panel.GetComponent<GridLayoutGroup>();
        grid.cellSize = new Vector2(470, 80);
        grid.spacing = new Vector2(30, 18);
        grid.childAlignment = TextAnchor.MiddleCenter;
        grid.constraint = GridLayoutGroup.Constraint.FixedColumnCount;
        grid.constraintCount = 2;

        for (int i = 0; i < ENTRIES.GetLength(0); i++)
            MakeButton(panel.transform, ENTRIES[i, 0], ENTRIES[i, 1]);
    }

    void MakeButton(Transform parent, string label, string sceneName)
    {
        var go = new GameObject("Btn_" + sceneName, typeof(RectTransform), typeof(Image), typeof(Button));
        go.transform.SetParent(parent, false);
        var img = go.GetComponent<Image>();
        img.color = new Color(0.20f, 0.28f, 0.42f, 1f);
        var btn = go.GetComponent<Button>();
        var colors = btn.colors; colors.highlightedColor = new Color(0.30f, 0.45f, 0.7f, 1f); btn.colors = colors;

        string target = sceneName;
        btn.onClick.AddListener(() => Go(target));

        var t = MakeText(go.transform, label, 26, FontStyle.Normal,
                         Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        t.alignment = TextAnchor.MiddleCenter;
        t.color = Color.white;
    }

    Text MakeText(Transform parent, string txt, int size, FontStyle style,
                  Vector2 aMin, Vector2 aMax, Vector2 pivot, Vector2 anchoredPos, Vector2 sizeDelta)
    {
        var go = new GameObject("Text", typeof(RectTransform), typeof(Text));
        go.transform.SetParent(parent, false);
        var rt = go.GetComponent<RectTransform>();
        rt.anchorMin = aMin; rt.anchorMax = aMax; rt.pivot = pivot;
        rt.anchoredPosition = anchoredPos; rt.sizeDelta = sizeDelta;
        var t = go.GetComponent<Text>();
        t.text = txt; t.font = font; t.fontSize = size; t.fontStyle = style;
        t.alignment = TextAnchor.MiddleCenter; t.color = Color.white;
        t.horizontalOverflow = HorizontalWrapMode.Overflow;
        return t;
    }

    void Go(string sceneName)
    {
        if (SceneNavigator.Instance != null) SceneNavigator.Instance.LoadScene(sceneName);
        else SceneManager.LoadScene(sceneName);
    }
}
