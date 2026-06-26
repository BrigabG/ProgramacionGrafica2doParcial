using UnityEngine;

public class ApprovalSensor : MonoBehaviour
{
    public Projector indicatorProjector;
    public Material passMaterial;
    public Material failMaterial;
    public Material neutralMaterial;
    [Range(0f, 1f)] public float passChance = 0.8f;

    [Header("Reset (cuando el personaje vuelve a empezar)")]
    public Transform character;
    public float resetMargin = 3f;

    private bool hasDecided;

    private void Update()
    {
        if (character == null) return;

        // Decide justo cuando el personaje llega a la altura del sensor (no antes, como
        // pasaba con el trigger por colision).
        if (!hasDecided && character.position.z >= transform.position.z)
        {
            hasDecided = true;
            bool approved = Random.value < passChance;
            if (indicatorProjector != null)
            {
                indicatorProjector.material = approved ? passMaterial : failMaterial;
            }
        }

        // El personaje esta bien atras de este gate -> recien se reinicio el recorrido.
        // Volvemos el indicador a su estado neutral, para la proxima vuelta.
        if (character.position.z < transform.position.z - resetMargin)
        {
            if (hasDecided && neutralMaterial != null && indicatorProjector != null)
            {
                indicatorProjector.material = neutralMaterial;
            }
            hasDecided = false;
        }
    }
}