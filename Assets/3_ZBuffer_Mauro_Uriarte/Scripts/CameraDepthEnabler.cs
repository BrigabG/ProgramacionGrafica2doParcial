using UnityEngine;

// El efecto X-Ray lee _CameraDepthTexture (nodo Depth Fade) para saber
// que tan tapado esta el personaje. En Built-in RP esa textura solo se
// genera si la camara lo pide explicitamente. Este componente lo asegura
// tanto en editor como en play.
[ExecuteAlways]
[RequireComponent(typeof(Camera))]
public class CameraDepthEnabler : MonoBehaviour
{
    void OnEnable()  { Apply(); }
    void Update()    { Apply(); }

    void Apply()
    {
        var cam = GetComponent<Camera>();
        if (cam != null)
            cam.depthTextureMode |= DepthTextureMode.Depth;
    }
}
