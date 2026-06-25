using UnityEngine;

// Camara voladora estilo editor (funciona en Play Mode):
//   - Mantener CLICK DERECHO para mirar con el mouse
//   - WASD para moverse, Q/E para bajar/subir
//   - Mantener Shift para acelerar
[AddComponentMenu("Camara/Fly Camera")]
public class FlyCamera : MonoBehaviour
{
    [Header("Movimiento")]
    [Tooltip("Velocidad base en unidades/segundo")]
    public float moveSpeed = 6f;
    [Tooltip("Multiplicador de velocidad al mantener Shift")]
    public float boostMultiplier = 3f;

    [Header("Mouse")]
    [Tooltip("Sensibilidad del giro con el mouse")]
    public float lookSensitivity = 2f;
    [Tooltip("Si esta activo, WASD solo se mueve mientras se mantiene el click derecho")]
    public bool requireRightClickToMove = false;

    float yaw;
    float pitch;

    void OnEnable()
    {
        // arranca desde la orientacion actual de la camara
        Vector3 e = transform.eulerAngles;
        yaw = e.y;
        pitch = e.x;
    }

    void Update()
    {
        bool looking = Input.GetMouseButton(1); // boton derecho

        // ---------- Mirar ----------
        if (looking)
        {
            yaw   += Input.GetAxis("Mouse X") * lookSensitivity;
            pitch -= Input.GetAxis("Mouse Y") * lookSensitivity;
            pitch = Mathf.Clamp(pitch, -89f, 89f); // evita dar la vuelta
            transform.rotation = Quaternion.Euler(pitch, yaw, 0f);

            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
        else
        {
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }

        // ---------- Mover ----------
        if (requireRightClickToMove && !looking)
            return;

        float x = (Input.GetKey(KeyCode.D) ? 1f : 0f) - (Input.GetKey(KeyCode.A) ? 1f : 0f);
        float z = (Input.GetKey(KeyCode.W) ? 1f : 0f) - (Input.GetKey(KeyCode.S) ? 1f : 0f);
        float y = (Input.GetKey(KeyCode.E) ? 1f : 0f) - (Input.GetKey(KeyCode.Q) ? 1f : 0f);

        // adelante/lados relativos a la camara; subir/bajar en eje del mundo
        Vector3 move = transform.right * x + transform.forward * z + Vector3.up * y;

        float speed = moveSpeed * (Input.GetKey(KeyCode.LeftShift) ? boostMultiplier : 1f);
        transform.position += move.normalized * speed * Time.deltaTime;
    }
}
