using UnityEngine;

public class SalaContenedora : MonoBehaviour
{
    [SerializeField] private Material materialSala;
    [SerializeField] private Vector3  escala  = new Vector3(40f, 25f, 40f);
    [SerializeField] private Vector3  centro  = Vector3.zero;

    private Mesh meshCubo;

    void Start()
    {
        // Obtiene la mesh del cubo primitivo sin dejar un GameObject en escena
        GameObject tmp = GameObject.CreatePrimitive(PrimitiveType.Cube);
        meshCubo = tmp.GetComponent<MeshFilter>().sharedMesh;
        Destroy(tmp);
    }

    void Update()
    {
        if (meshCubo == null || materialSala == null) return;

        Matrix4x4 matriz = Matrix4x4.TRS(centro, Quaternion.identity, escala);
        Graphics.DrawMesh(meshCubo, matriz, materialSala, 0);
    }
}
