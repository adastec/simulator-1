using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AdastecUIExtension : MonoBehaviour
{
    Transform SpawnedObjects;
    public AdastecExtension adastecExtension;
    public GameObject[] cubes;
    public List<GameObject> CubeList;
    public bool flag;
    public Slider slider;
    private void Start()
    {
        SpawnedObjects = GameObject.FindGameObjectWithTag("SpawnedObjects").transform;
        adastecExtension = (AdastecExtension)FindObjectOfType(typeof(AdastecExtension));
        adastecExtension.adastecUI = this;
        cubes = GameObject.FindGameObjectsWithTag("FindCube");
        foreach (GameObject cube in cubes)
        {
            GameObject recent = cube.transform.GetChild(0).gameObject;
            CubeList.Add(recent);
            recent.SetActive(false);
        }
        slider.onValueChanged.AddListener(delegate { ValueChangeCheck(); });
    }
    public void ChangeStatus()
    {
        foreach (GameObject cube in CubeList)
        {
            cube.SetActive(!flag);
        }
        flag = !flag;
    }
    public void CleanSpawns()
    {
        foreach (Transform child in SpawnedObjects.transform)
        {
            Destroy(child.gameObject);
        }
    }
    public void ValueChangeCheck()
    {
        adastecExtension.DecideScaleofSpawn(slider.value);
    }
}
