using UnityEngine;

public class CharacterWalk : MonoBehaviour
{
    public float speed = 1.5f;
    public float startZ = -9f;
    public float endZ = 7.3f;

    private float pauseTimer = 0f;

    // Cualquier sensor puede llamar a esto para frenar al personaje un rato.
    // Si dos sensores pidieran pausa casi al mismo tiempo, nos quedamos con la mas larga.
    public void PauseFor(float seconds)
    {
        pauseTimer = Mathf.Max(pauseTimer, seconds);
    }

    public bool IsPaused => pauseTimer > 0f;

    private void Update()
    {
        if (pauseTimer > 0f)
        {
            pauseTimer -= Time.deltaTime;
            return; // quieto mientras dura la pausa, no avanza
        }

        Vector3 pos = transform.position;
        pos.z += speed * Time.deltaTime;
        if (pos.z > endZ) pos.z = startZ; // vuelve a empezar, loop para la demo
        transform.position = pos;
    }
}
