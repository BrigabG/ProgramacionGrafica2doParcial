using UnityEngine;

/// <summary>
/// Sigue al Character a una distancia fija, mirando siempre un poco mas adelante de el.
/// Como el personaje solo se mueve en Z, la camara lo acompaña y siempre deja a la vista
/// el gate que esta cruzando en ese momento, en vez de quedar fija mirando un solo punto.
/// </summary>
public class CameraFollow : MonoBehaviour
{
    public Transform target;
    public Vector3 offset = new Vector3(1.8f, 2.2f, -5f);
    public float lookAheadDistance = 3f;
    public float followSpeed = 4f;

    // LateUpdate (no Update): se ejecuta DESPUES de que CharacterWalk ya movió al personaje
    // este mismo frame, así la cámara nunca queda "atrasada" un frame respecto a él.
    private void LateUpdate()
    {
        if (target == null) return;

        Vector3 desiredPos = target.position + offset;
        transform.position = Vector3.Lerp(transform.position, desiredPos, followSpeed * Time.deltaTime);

        Vector3 lookPoint = target.position + Vector3.forward * lookAheadDistance;
        transform.LookAt(lookPoint);
    }
}
