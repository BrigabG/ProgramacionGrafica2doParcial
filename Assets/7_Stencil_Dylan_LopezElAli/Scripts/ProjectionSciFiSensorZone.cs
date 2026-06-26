using UnityEngine;

public enum ProjectionSciFiSensorMode
{
    XRay,
    Thermal,
    Light
}

public class ProjectionSciFiSensorZone : MonoBehaviour
{
    public ProjectionSciFiSceneController controller;
    public ProjectionSciFiSensorMode mode;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            controller?.EnterSensor(mode);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            controller?.ExitSensor(mode);
        }
    }
}
