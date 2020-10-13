using Simulator.Sensors;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
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
    public Slider jaywalkSlider;
    public Toggle mpcToggle;
    VehicleController vc;
    public Text SteerText;
    private void Start()
    {
        SpawnedObjects = GameObject.FindGameObjectWithTag("SpawnedObjects").transform;
        adastecExtension = (AdastecExtension)FindObjectOfType(typeof(AdastecExtension));
        adastecExtension.adastecUI = this;
        adastecExtension.ActivateSpawnsAndJaywalks((jaywalkSlider.value));
        cubes = GameObject.FindGameObjectsWithTag("FindCube");
        foreach (GameObject cube in cubes)
        {
            GameObject recent = cube.transform.GetChild(0).gameObject;
            CubeList.Add(recent);
            recent.SetActive(false);
        }
        slider.onValueChanged.AddListener(delegate { ValueChangeCheck(); });
        jaywalkSlider.onValueChanged.AddListener(delegate { JaywalkValueChangeCheck(); });
        vc = GameObject.FindGameObjectWithTag("Player").GetComponent<VehicleController>();
        SteerText.text = "Current Steer Rate:\n";
    }
    private void Update()
    {
        SteerText.text = vc.vcs.SteerDebug;
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
    public void JaywalkValueChangeCheck()
    {
        adastecExtension.ActivateSpawnsAndJaywalks(jaywalkSlider.value);
    }
    
    public void changeUseMPC()
    {
        vc.vcs.useMPC = !vc.vcs.useMPC;
    }
}
