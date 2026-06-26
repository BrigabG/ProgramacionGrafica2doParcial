using UnityEngine;

public class SensorSweep : MonoBehaviour
{
    public float sweepWidth = 2.5f;
    public float sweepSpeed = 2f;
    private float baseX;

    private void Start() { baseX = transform.localPosition.x; }

    private void Update()
    {
        float offset = Mathf.Sin(Time.time * sweepSpeed) * sweepWidth;
        Vector3 pos = transform.localPosition;
        pos.x = baseX + offset;
        transform.localPosition = pos;
    }
}