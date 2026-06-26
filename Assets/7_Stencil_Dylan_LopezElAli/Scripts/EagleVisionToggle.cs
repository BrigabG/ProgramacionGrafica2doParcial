using UnityEngine;

public class EagleVisionToggle : MonoBehaviour
{
    [SerializeField] private KeyCode toggleKey = KeyCode.E;
    [SerializeField] private GameObject pulseRoot;
    [SerializeField] private bool autoFindTargets = true;
    [SerializeField] private GameObject[] readerObjects;
    [SerializeField] private float pulseRadius = 12f;
    [SerializeField] private float pulseDuration = 1.4f;
    [SerializeField] private float holdDuration = 2.5f;
    [SerializeField] private float shrinkDuration = 0.9f;

    private float pulseTimer;
    private bool active;

    private void Awake()
    {
        StopPulse();
    }

    private void Update()
    {
        if (Input.GetKeyDown(toggleKey))
        {
            StartPulse();
        }

        if (!active)
        {
            return;
        }

        pulseTimer += Time.deltaTime;
        float currentRadius = GetCurrentRadius();

        if (pulseRoot != null)
        {
            pulseRoot.transform.position = transform.position;
            pulseRoot.transform.localScale = Vector3.one * (currentRadius * 2f);
        }

        if (pulseTimer >= pulseDuration + holdDuration + shrinkDuration)
        {
            StopPulse();
        }
    }

    private void StartPulse()
    {
        active = true;
        pulseTimer = 0f;

        if (pulseRoot != null)
        {
            pulseRoot.transform.position = transform.position;
            pulseRoot.transform.localScale = Vector3.one * 0.01f;
            pulseRoot.SetActive(true);
        }

        SetReadersActive(true);
    }

    private void StopPulse()
    {
        active = false;
        pulseTimer = 0f;

        if (pulseRoot != null)
        {
            pulseRoot.SetActive(false);
            pulseRoot.transform.localScale = Vector3.one * 0.01f;
        }

        SetReadersActive(false);
    }

    private float GetCurrentRadius()
    {
        const float minRadius = 0.01f;

        if (pulseTimer <= pulseDuration)
        {
            float growT = pulseDuration <= 0f ? 1f : Mathf.Clamp01(pulseTimer / pulseDuration);
            return Mathf.Lerp(minRadius, pulseRadius, growT);
        }

        float shrinkStart = pulseDuration + holdDuration;
        if (pulseTimer <= shrinkStart)
        {
            return pulseRadius;
        }

        float shrinkT = shrinkDuration <= 0f ? 1f : Mathf.Clamp01((pulseTimer - shrinkStart) / shrinkDuration);
        return Mathf.Lerp(pulseRadius, minRadius, shrinkT);
    }

    private void SetReadersActive(bool value)
    {
        if (autoFindTargets)
        {
            EagleVisionTarget[] targets = Resources.FindObjectsOfTypeAll<EagleVisionTarget>();
            foreach (EagleVisionTarget target in targets)
            {
                if (target != null && target.gameObject.scene.IsValid())
                {
                    target.SetVisionActive(value);
                }
            }
        }

        if (readerObjects == null)
        {
            return;
        }

        foreach (GameObject readerObject in readerObjects)
        {
            if (readerObject != null)
            {
                readerObject.SetActive(value);
            }
        }
    }
}
