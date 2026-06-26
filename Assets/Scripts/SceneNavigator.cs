using UnityEngine;
using UnityEngine.SceneManagement;

// Persiste entre escenas (DontDestroyOnLoad). Con ESC vuelve al menu principal.
// Singleton para no duplicarse al volver al menu.
public class SceneNavigator : MonoBehaviour
{
    public static SceneNavigator Instance;
    public string mainSceneName = "Main";

    void Awake()
    {
        if (Instance != null && Instance != this) { Destroy(gameObject); return; }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape) &&
            SceneManager.GetActiveScene().name != mainSceneName)
        {
            SceneManager.LoadScene(mainSceneName);
        }
    }

    public void LoadScene(string sceneName)
    {
        SceneManager.LoadScene(sceneName);
    }
}
