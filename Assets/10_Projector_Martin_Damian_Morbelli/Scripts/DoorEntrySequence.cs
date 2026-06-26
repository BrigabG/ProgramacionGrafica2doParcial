using UnityEngine;

/// <summary>
/// Simula a alguien entrando por la puerta y mirando la habitación de pared a pared.
/// Fase 1: camina desde afuera hacia el umbral (una vez).
/// Fase 2: una vez adentro, barre la mirada de una pared a la otra en bucle,
/// mientras el ciclo de día/noche (ProjectorDayCycle) sigue su curso en paralelo.
/// </summary>
public class DoorEntrySequence : MonoBehaviour
{
    [Header("Posiciones")]
    public Vector3 outsidePosition = new Vector3(0f, 1.6f, -5.6f);
    public Vector3 insidePosition = new Vector3(0f, 1.6f, -3.3f);

    [Header("Fase 1: Entrada")]
    public float enterDuration = 4f;
    public float entryLookPitch = 3f;

    [Header("Fase 2: Barrido pared a pared")]
    [Tooltip("Grados hacia cada lado, partiendo del centro")]
    public float lookAngleRange = 50f;
    [Tooltip("Segundos para completar un barrido izquierda-derecha-izquierda")]
    public float lookCycleDuration = 14f;
    public float lookPitch = 4f;

    private float elapsed = 0f;

    private void Update()
    {
        elapsed += Time.deltaTime;

        if (elapsed <= enterDuration)
        {
            float t = Mathf.SmoothStep(0f, 1f, elapsed / enterDuration);
            transform.position = Vector3.Lerp(outsidePosition, insidePosition, t);
            transform.rotation = Quaternion.Euler(entryLookPitch, 0f, 0f);
        }
        else
        {
            transform.position = insidePosition;

            float lookT = (elapsed - enterDuration) / lookCycleDuration;
            float yaw = Mathf.Sin(lookT * Mathf.PI * 2f) * lookAngleRange;

            transform.rotation = Quaternion.Euler(lookPitch, yaw, 0f);
        }
    }
}
