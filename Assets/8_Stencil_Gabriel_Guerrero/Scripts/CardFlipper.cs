using UnityEngine;

public class CardFlipper : MonoBehaviour
{
    [Header("Flip Animation")]
    [Tooltip("Duración del flip automático en segundos")]
    public float flipDuration = 0.5f;
    [Tooltip("Curva de la animación del flip")]
    public AnimationCurve flipCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

    [Header("Mouse Drag")]
    [Tooltip("Sensibilidad al arrastrar con el mouse")]
    public float dragSensitivity = 1.5f;
    [Tooltip("Eje de rotación al arrastrar (X = voltear, Y = girar)")]
    public Vector3 dragAxis = Vector3.up;

    [Header("Auto Rotation")]
    [Tooltip("Activar rotación automática al inicio")]
    public bool autoRotate = false;
    [Tooltip("Velocidad de rotación automática (grados por segundo)")]
    public float autoRotateSpeed = 30f;

    [Header("Info (solo lectura)")]
    [Tooltip("Cara actual de la carta")]
    public bool showingFront = true;

    bool _isFlipping;
    float _flipProgress;
    float _startAngle;
    float _targetAngle;
    float _currentYAngle;

    bool _isDragging;
    Vector3 _lastMousePos;

    void Update()
    {
        HandleDrag();
        HandleFlipInput();
        HandleAutoRotate();
        HandleAnimatedFlip();
    }

    void HandleDrag()
    {
        if (Input.GetMouseButtonDown(0))
        {
            _isDragging = true;
            _lastMousePos = Input.mousePosition;
        }

        if (Input.GetMouseButtonUp(0))
            _isDragging = false;

        if (_isDragging && !_isFlipping)
        {
            Vector3 delta = Input.mousePosition - _lastMousePos;
            float rotation = -delta.x * dragSensitivity;
            transform.Rotate(dragAxis, rotation, Space.World);
            _currentYAngle += rotation;
            _lastMousePos = Input.mousePosition;
        }
    }

    void HandleFlipInput()
    {
        if (Input.GetKeyDown(KeyCode.F) && !_isFlipping)
            StartFlip();

        if (Input.GetKeyDown(KeyCode.R))
            autoRotate = !autoRotate;
    }

    void HandleAutoRotate()
    {
        if (autoRotate && !_isFlipping && !_isDragging)
        {
            float rotation = autoRotateSpeed * Time.deltaTime;
            transform.Rotate(dragAxis, rotation, Space.World);
            _currentYAngle += rotation;
        }
    }

    void StartFlip()
    {
        _isFlipping = true;
        _flipProgress = 0f;
        _startAngle = _currentYAngle;
        _targetAngle = _currentYAngle + 180f;
        showingFront = !showingFront;
    }

    void HandleAnimatedFlip()
    {
        if (!_isFlipping) return;

        _flipProgress += Time.deltaTime / flipDuration;
        _flipProgress = Mathf.Clamp01(_flipProgress);

        float t = flipCurve.Evaluate(_flipProgress);
        float angle = Mathf.Lerp(_startAngle, _targetAngle, t);
        float delta = angle - _currentYAngle;

        transform.Rotate(dragAxis, delta, Space.World);
        _currentYAngle = angle;

        if (_flipProgress >= 1f)
            _isFlipping = false;
    }

    public void Flip() => StartFlip();

    void OnGUI()
    {
        GUIStyle style = new GUIStyle(GUI.skin.label);
        style.fontSize = 16;
        style.normal.textColor = Color.white;

        GUI.Label(new Rect(10, 10, 500, 30), "[F] Flip carta    [R] Auto-rotación    [Click+Drag] Rotar", style);
        GUI.Label(new Rect(10, 35, 300, 30), $"Cara visible: {(showingFront ? "FRENTE" : "DORSO")}", style);
    }
}
