using UnityEngine;

public class ThirdPersonCameraController : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private Vector3 targetOffset = new Vector3(0f, 1.2f, 0f);
    [SerializeField] private float distance = 8f;
    [SerializeField] private float minDistance = 3f;
    [SerializeField] private float maxDistance = 18f;
    [SerializeField] private float mouseSensitivity = 3f;
    [SerializeField] private float zoomSensitivity = 3f;
    [SerializeField] private float followSmoothness = 12f;
    [SerializeField] private float minPitch = -20f;
    [SerializeField] private float maxPitch = 65f;
    [SerializeField] private bool lockCursorOnPlay = true;

    private float yaw;
    private float pitch = 20f;
    private Vector3 smoothedTargetPosition;

    private void Awake()
    {
        if (target == null)
        {
            GameObject playerObject = GameObject.FindGameObjectWithTag("Player");
            if (playerObject != null)
            {
                target = playerObject.transform;
            }
        }

        Vector3 eulerAngles = transform.eulerAngles;
        yaw = eulerAngles.y;
        pitch = NormalizePitch(eulerAngles.x);

        if (target != null)
        {
            smoothedTargetPosition = target.position + targetOffset;
        }
    }

    private void OnEnable()
    {
        if (Application.isPlaying && lockCursorOnPlay)
        {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
    }

    private void OnDisable()
    {
        if (Application.isPlaying && lockCursorOnPlay)
        {
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }
    }

    private void LateUpdate()
    {
        if (target == null)
        {
            return;
        }

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }

        if (Input.GetMouseButtonDown(0) && lockCursorOnPlay)
        {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }

        if (Cursor.lockState == CursorLockMode.Locked || Input.GetMouseButton(1))
        {
            yaw += Input.GetAxis("Mouse X") * mouseSensitivity;
            pitch -= Input.GetAxis("Mouse Y") * mouseSensitivity;
            pitch = Mathf.Clamp(pitch, minPitch, maxPitch);
        }

        float scroll = Input.GetAxis("Mouse ScrollWheel");
        if (Mathf.Abs(scroll) > 0.001f)
        {
            distance = Mathf.Clamp(distance - scroll * zoomSensitivity, minDistance, maxDistance);
        }

        Vector3 desiredTargetPosition = target.position + targetOffset;
        float followT = 1f - Mathf.Exp(-followSmoothness * Time.deltaTime);
        smoothedTargetPosition = Vector3.Lerp(smoothedTargetPosition, desiredTargetPosition, followT);

        Quaternion rotation = Quaternion.Euler(pitch, yaw, 0f);
        Vector3 desiredPosition = smoothedTargetPosition - rotation * Vector3.forward * distance;

        transform.SetPositionAndRotation(desiredPosition, rotation);
    }

    private static float NormalizePitch(float angle)
    {
        if (angle > 180f)
        {
            angle -= 360f;
        }

        return angle;
    }
}
