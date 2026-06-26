using UnityEngine;

public enum DoorStyle
{
    SlideUp,
    SlideDown,
    SplitSideways
}

/// <summary>
/// Va en cada Gate. Secuencia al detectar al personaje:
/// 1) Lo pausa y le sube la intensidad al sensor (escaneo visible, la puerta sigue cerrada).
/// 2) Recién cuando termina el escaneo, abre la puerta.
/// Cuando el personaje vuelve a arrancar desde el principio (loop de CharacterWalk),
/// cierra la puerta y reinicia todo para la próxima vuelta.
/// </summary>
public class GateDoorController : MonoBehaviour
{
    private enum State { Idle, Scanning, Opening }

    [Header("Personaje")]
    public CharacterWalk character;
    [Tooltip("Tiempo total parado en el sensor (escaneo + apertura de puerta)")]
    public float pauseDuration = 3.2f;
    [Tooltip("Cuánto dura el escaneo ANTES de que la puerta empiece a abrirse")]
    public float scanDuration = 1.3f;

    [Header("Puerta (posicionarla un poco después del sensor en Z)")]
    public DoorStyle doorStyle = DoorStyle.SlideUp;
    [Tooltip("Panel único (SlideUp / SlideDown) o panel IZQUIERDO (SplitSideways)")]
    public Transform doorPrimary;
    [Tooltip("Solo se usa con SplitSideways: el panel derecho")]
    public Transform doorSecondary;
    public float openDistance = 3.8f;
    public float doorSpeed = 2.2f;

    [Header("Resaltar el sensor mientras escanea")]
    public Material sensorMaterial;
    public string boostProperty = "_Intensity";
    public float boostMultiplier = 1.8f;

    [Header("Reset")]
    public float resetMargin = 3f;

    private Vector3 primaryClosedPos;
    private Vector3 secondaryClosedPos;
    private Vector3 primaryTargetPos;
    private Vector3 secondaryTargetPos;
    private float baseSensorValue;
    private bool boosted;
    private bool hasTriggered;
    private State state = State.Idle;
    private float stateTimer;

    private void Start()
    {
        if (doorPrimary != null)
        {
            primaryClosedPos = doorPrimary.localPosition;
            primaryTargetPos = primaryClosedPos;
        }
        if (doorSecondary != null)
        {
            secondaryClosedPos = doorSecondary.localPosition;
            secondaryTargetPos = secondaryClosedPos;
        }
        if (sensorMaterial != null && sensorMaterial.HasProperty(boostProperty))
        {
            baseSensorValue = sensorMaterial.GetFloat(boostProperty);
        }
    }

    private void Update()
    {
        // En vez de esperar el OnTriggerEnter (que dispara apenas el borde del collider se
        // superpone con el trigger, parando al personaje un poco ANTES del sensor real),
        // comparamos directo la posición Z: así el personaje siempre frena exactamente
        // debajo/a la altura del sensor, sin importar el tamaño de su collider.
        if (!hasTriggered && character != null && character.transform.position.z >= transform.position.z)
        {
            hasTriggered = true;

            // Lo clavamos en la Z exacta del sensor (puede haber pasado un poquito de largo
            // en ese mismo frame, dependiendo del framerate).
            Vector3 p = character.transform.position;
            p.z = transform.position.z;
            character.transform.position = p;

            character.PauseFor(pauseDuration);
            ApplyBoost();
            state = State.Scanning;
            stateTimer = 0f;
        }

        // Mientras esta "Scanning", la puerta NO se mueve todavia (sigue en su target cerrado).
        // Recien al pasar a "Opening" le cambiamos el target y arranca a deslizarse.
        if (state == State.Scanning)
        {
            stateTimer += Time.deltaTime;
            if (stateTimer >= scanDuration)
            {
                RevertBoost();
                OpenDoor();
                state = State.Opening;
            }
        }

        if (doorPrimary != null)
        {
            doorPrimary.localPosition = Vector3.MoveTowards(doorPrimary.localPosition, primaryTargetPos, doorSpeed * Time.deltaTime);
        }
        if (doorSecondary != null)
        {
            doorSecondary.localPosition = Vector3.MoveTowards(doorSecondary.localPosition, secondaryTargetPos, doorSpeed * Time.deltaTime);
        }

        // El personaje esta bien atras de este gate -> recien se reinicio el recorrido completo.
        // Volvemos todo a su estado inicial para la proxima vuelta.
        if (character != null && character.transform.position.z < transform.position.z - resetMargin)
        {
            CloseDoor();
            RevertBoost();
            hasTriggered = false;
            state = State.Idle;
            stateTimer = 0f;
        }
    }

    private void OpenDoor()
    {
        switch (doorStyle)
        {
            case DoorStyle.SlideUp:
                primaryTargetPos = primaryClosedPos + Vector3.up * openDistance;
                break;
            case DoorStyle.SlideDown:
                primaryTargetPos = primaryClosedPos + Vector3.down * openDistance;
                break;
            case DoorStyle.SplitSideways:
                primaryTargetPos = primaryClosedPos + Vector3.left * openDistance;
                secondaryTargetPos = secondaryClosedPos + Vector3.right * openDistance;
                break;
        }
    }

    private void CloseDoor()
    {
        primaryTargetPos = primaryClosedPos;
        secondaryTargetPos = secondaryClosedPos;
    }

    private void ApplyBoost()
    {
        if (boosted || sensorMaterial == null || !sensorMaterial.HasProperty(boostProperty)) return;
        sensorMaterial.SetFloat(boostProperty, baseSensorValue * boostMultiplier);
        boosted = true;
    }

    private void RevertBoost()
    {
        if (!boosted || sensorMaterial == null) return;
        sensorMaterial.SetFloat(boostProperty, baseSensorValue);
        boosted = false;
    }
}
