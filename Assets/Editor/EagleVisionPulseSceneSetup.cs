using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

public static class EagleVisionPulseSceneSetup
{
    private const string ScenePath = "Assets/Scenes/ShaderTestScene.unity";
    private const string SetupKey = "EagleVisionPulseSceneSetup_v1";

    [DidReloadScripts]
    private static void AutoSetupAfterCompile()
    {
        if (SessionState.GetBool(SetupKey, false))
        {
            return;
        }

        if (SceneManager.GetActiveScene().path != ScenePath)
        {
            return;
        }

        SessionState.SetBool(SetupKey, true);
        EditorApplication.delayCall += Setup;
    }

    [MenuItem("Tools/Eagle Vision/Setup Pulse Scene")]
    public static void Setup()
    {
        EnsureFolders();

        Material writerMaterial = EnsureMaterial(
            "Assets/Materials/M_EV_StencilWriter.mat",
            Shader.Find("EV_StencilWriter"),
            Color.white);

        Material pulseVisualMaterial = EnsurePulseVisualMaterial();

        GameObject pulseRoot = EnsureGameObject("Eagle Vision Pulse");
        pulseRoot.transform.position = Vector3.zero;
        pulseRoot.transform.rotation = Quaternion.identity;
        pulseRoot.transform.localScale = Vector3.one * 0.01f;

        GameObject pulseMask = EnsurePrimitiveChild(
            pulseRoot.transform,
            "EV Pulse Stencil Mask",
            PrimitiveType.Sphere,
            writerMaterial);
        pulseMask.transform.localPosition = Vector3.zero;
        pulseMask.transform.localRotation = Quaternion.identity;
        pulseMask.transform.localScale = Vector3.one;

        GameObject pulseVisual = EnsurePrimitiveChild(
            pulseRoot.transform,
            "EV Pulse Visual",
            PrimitiveType.Sphere,
            pulseVisualMaterial);
        pulseVisual.transform.localPosition = Vector3.zero;
        pulseVisual.transform.localRotation = Quaternion.identity;
        pulseVisual.transform.localScale = Vector3.one;

        pulseRoot.SetActive(false);

        GameObject player = FindSceneObject("Player");
        if (player == null)
        {
            Debug.LogWarning("EagleVisionPulseSceneSetup: Player not found.");
            return;
        }

        AssignMaterialIfFound("Eagle Vision Pulse/EV Pulse Stencil Mask", writerMaterial);
        AssignMaterialIfFound("Eagle Vision Pulse/EV Pulse Visual", pulseVisualMaterial);
        AssignMaterialIfFound(
            "Player/StencilReader",
            AssetDatabase.LoadAssetAtPath<Material>("Assets/Materials/M_EV_PlayerAlwaysReader_Player.mat"));
        AssignMaterialIfFound(
            "Enemies/Enemy 1/StencilReader",
            AssetDatabase.LoadAssetAtPath<Material>("Assets/Materials/M_EV_PlayerReader_Enemy.mat"));
        AssignMaterialIfFound(
            "Enemies/Enemy 2/StencilReader",
            AssetDatabase.LoadAssetAtPath<Material>("Assets/Materials/M_EV_PlayerReader_Enemy.mat"));

        EagleVisionToggle toggle = player.GetComponent<EagleVisionToggle>();
        if (toggle == null)
        {
            toggle = player.AddComponent<EagleVisionToggle>();
        }

        List<GameObject> readers = new List<GameObject>();
        AddIfFound(readers, "Enemies/Enemy 1/StencilReader");
        AddIfFound(readers, "Enemies/Enemy 2/StencilReader");
        foreach (GameObject reader in readers)
        {
            if (reader.GetComponent<EagleVisionTarget>() == null)
            {
                reader.AddComponent<EagleVisionTarget>();
            }
        }

        GameObject playerReader = FindSceneObject("Player/StencilReader");
        if (playerReader != null)
        {
            EagleVisionTarget playerTarget = playerReader.GetComponent<EagleVisionTarget>();
            if (playerTarget != null)
            {
                Object.DestroyImmediate(playerTarget);
            }

            playerReader.SetActive(true);
            Renderer playerReaderRenderer = playerReader.GetComponent<Renderer>();
            if (playerReaderRenderer != null)
            {
                playerReaderRenderer.enabled = true;
                EditorUtility.SetDirty(playerReaderRenderer);
            }
        }

        SerializedObject serializedToggle = new SerializedObject(toggle);
        serializedToggle.FindProperty("pulseRoot").objectReferenceValue = pulseRoot;
        SerializedProperty autoFindTargetsProperty = serializedToggle.FindProperty("autoFindTargets");
        if (autoFindTargetsProperty != null)
        {
            autoFindTargetsProperty.boolValue = true;
        }

        SerializedProperty readersProperty = serializedToggle.FindProperty("readerObjects");
        readersProperty.arraySize = readers.Count;
        for (int i = 0; i < readers.Count; i++)
        {
            readersProperty.GetArrayElementAtIndex(i).objectReferenceValue = readers[i];
            readers[i].SetActive(false);
        }

        serializedToggle.FindProperty("pulseRadius").floatValue = 12f;
        serializedToggle.FindProperty("pulseDuration").floatValue = 1.4f;
        serializedToggle.FindProperty("holdDuration").floatValue = 2.5f;
        serializedToggle.FindProperty("shrinkDuration").floatValue = 0.9f;
        serializedToggle.ApplyModifiedProperties();

        EditorUtility.SetDirty(toggle);
        EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
        EditorSceneManager.SaveScene(SceneManager.GetActiveScene());
        AssetDatabase.SaveAssets();
        Debug.Log("Eagle Vision pulse scene setup completed.");
    }

    private static void EnsureFolders()
    {
        if (!AssetDatabase.IsValidFolder("Assets/Materials"))
        {
            AssetDatabase.CreateFolder("Assets", "Materials");
        }
    }

    private static Material EnsureMaterial(string path, Shader shader, Color color)
    {
        Material material = AssetDatabase.LoadAssetAtPath<Material>(path);
        if (material == null)
        {
            material = new Material(shader);
            AssetDatabase.CreateAsset(material, path);
        }

        material.shader = shader;
        if (material.HasProperty("_Color"))
        {
            material.color = color;
        }

        EditorUtility.SetDirty(material);
        return material;
    }

    private static Material EnsurePulseVisualMaterial()
    {
        Material material = EnsureMaterial(
            "Assets/Materials/M_EV_PulseVisual.mat",
            Shader.Find("Standard"),
            new Color(0f, 0.85f, 1f, 0.16f));

        material.SetFloat("_Mode", 3f);
        material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
        material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
        material.SetInt("_ZWrite", 0);
        material.DisableKeyword("_ALPHATEST_ON");
        material.EnableKeyword("_ALPHABLEND_ON");
        material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
        material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent + 20;

        if (material.HasProperty("_EmissionColor"))
        {
            material.EnableKeyword("_EMISSION");
            material.SetColor("_EmissionColor", new Color(0f, 0.55f, 0.75f, 1f));
        }

        EditorUtility.SetDirty(material);
        return material;
    }

    private static GameObject EnsureGameObject(string name)
    {
        GameObject gameObject = FindSceneObject(name);
        return gameObject != null ? gameObject : new GameObject(name);
    }

    private static GameObject EnsurePrimitiveChild(
        Transform parent,
        string name,
        PrimitiveType primitiveType,
        Material material)
    {
        Transform existing = parent.Find(name);
        GameObject gameObject = existing != null ? existing.gameObject : GameObject.CreatePrimitive(primitiveType);
        gameObject.name = name;
        gameObject.transform.SetParent(parent, false);

        Collider collider = gameObject.GetComponent<Collider>();
        if (collider != null)
        {
            Object.DestroyImmediate(collider);
        }

        Renderer renderer = gameObject.GetComponent<Renderer>();
        if (renderer != null)
        {
            renderer.sharedMaterial = material;
        }

        gameObject.SetActive(true);
        EditorUtility.SetDirty(gameObject);
        return gameObject;
    }

    private static void AddIfFound(List<GameObject> gameObjects, string path)
    {
        GameObject gameObject = FindSceneObject(path);
        if (gameObject != null)
        {
            gameObjects.Add(gameObject);
        }
    }

    private static void SetInactiveIfFound(string path)
    {
        GameObject gameObject = FindSceneObject(path);
        if (gameObject != null)
        {
            gameObject.SetActive(false);
        }
    }

    private static void AssignMaterialIfFound(string path, Material material)
    {
        GameObject gameObject = FindSceneObject(path);
        if (gameObject == null || material == null)
        {
            return;
        }

        Renderer renderer = gameObject.GetComponent<Renderer>();
        if (renderer == null)
        {
            return;
        }

        renderer.sharedMaterial = material;
        EditorUtility.SetDirty(renderer);
    }

    private static GameObject FindSceneObject(string path)
    {
        foreach (GameObject gameObject in Resources.FindObjectsOfTypeAll<GameObject>())
        {
            if (EditorUtility.IsPersistent(gameObject))
            {
                continue;
            }

            if (!gameObject.scene.IsValid() || !gameObject.scene.isLoaded)
            {
                continue;
            }

            string objectPath = gameObject.name;
            Transform parent = gameObject.transform.parent;
            while (parent != null)
            {
                objectPath = parent.name + "/" + objectPath;
                parent = parent.parent;
            }

            if (objectPath == path || gameObject.name == path)
            {
                return gameObject;
            }
        }

        return null;
    }
}
