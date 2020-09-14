using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AdastecExtension : MonoBehaviour
{
    Ray ray;
    public GameObject Target;
    public GameObject SpawnObject;
    public Transform SpawnedObjects;
    public AdastecUIExtension adastecUI;
    private void Start()
    {
        SpawnObject.transform.localScale = new Vector3(1f, 1f, 1f);
    }
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Q)) // Input.GetMouseButtonDown(0) || 
        {
            Debug.Log("MouseDown");
            // Reset ray with new mouse position
            ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit[] hits = Physics.RaycastAll(ray);
            Tuple<bool, RaycastHit> tuple = SetBool(hits);
            RaycastHit hit = tuple.Item2;
            if (tuple.Item1)
            {                
                foreach (RaycastHit a in hits)
                {
                    Debug.Log(a.collider.transform.name);
                    if (a.collider.CompareTag("RaycastRoad"))
                    {
                        Target = a.collider.gameObject;
                        Debug.Log("Hit");
                    }
                }
                Spawn(hit);
            }            
        }
    }
    private Tuple<bool,RaycastHit> SetBool(RaycastHit[] hits)
    {
        RaycastHit hit = hits[0];
        //Simply set the bool true if the objects that the ray hits are LaneBoxes before the road. If it hits another object, behave like the ray hit a let's say
        //building before road. If it directly hits a road, spawn the cube.
        if (hits[0].transform.name == "LaneBox")
        {            
            int l = hits.Length;
            bool value = true;
            for (int i = 1; i < l; i++)
            {
                if (hits[i].transform.name != "LaneBox" && !hits[i].collider.CompareTag("RaycastRoad"))
                {
                    if (hits[i].transform.name == "allTerrain_combined 2") break; //temporary workaround.
                    value = false;
                    break;
                }
                else if 
                    (hits[i].transform.name == "LaneBox") value = true;
                else
                {
                    hit = hits[i];
                    value = true;
                    break;
                }
            }
            return new Tuple<bool, RaycastHit>(value, hit);
        }
        else if (hits[0].collider.CompareTag("RaycastRoad"))
        {
            hit = hits[0];
            return new Tuple<bool, RaycastHit>(true, hit);
        }
        else
        {
            return new Tuple<bool, RaycastHit>(false, hit);
        }
    }

    void Spawn(RaycastHit hit)
    {
        GameObject.Instantiate(SpawnObject, hit.point + new Vector3(0f,2.5f,0f), UnityEngine.Random.rotation, SpawnedObjects);
    }
    public void DecideScaleofSpawn(float scale)
    {
        switch (scale)
        {
            case 1:
                SpawnObject.transform.localScale = new Vector3(0.25f, 0.25f, 0.25f);
                break;
            case 2:
                SpawnObject.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
                break;
            case 3:
                SpawnObject.transform.localScale = new Vector3(1f, 1f, 1f);
                break;
            case 4:
                SpawnObject.transform.localScale = new Vector3(2f, 2f, 2f);
                break;
            case 5:
                SpawnObject.transform.localScale = new Vector3(3f, 3f, 3f);
                break;
            default:
                break;
        }     
    }
}


