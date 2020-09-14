using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrafficLight : MonoBehaviour
{
    private Material redLight;
    private Material yellowLight;
    private Material greenLight;
    struct LightData
    {
        public Vector4 defaultLight;
        public Vector4 updatedLight;
    }
    LightData RedData;
    LightData YellowData;
    LightData GreenData;

    enum LightMode
    {
        Stop,
        Move,
        Ready,
        Stop_Ready
    }
    void Start()
    {
        var allRenderers = transform.GetChild(0).GetComponent<MeshRenderer>().materials;
        float intensity = 2.5f;
        foreach (Material child in allRenderers)
        {
            if (child.name == "Red (Instance)")
            {
                redLight = child;
                RedData.defaultLight = redLight.GetVector("_EmissiveColor");
                RedData.updatedLight = Color.red * intensity;
            }

            if (child.name == "Green (Instance)")
            {
                greenLight = child;
                GreenData.defaultLight = greenLight.GetVector("_EmissiveColor");
                GreenData.updatedLight = Color.green * intensity;
            }

            if (child.name == "Amber (Instance)")
            {
                yellowLight = child;
                YellowData.defaultLight = yellowLight.GetVector("_EmissiveColor");
                YellowData.updatedLight = Color.yellow * intensity;
            }
        }
        StartCoroutine(WaitForRandomSeconds(10));         
    }
    void SetLight(LightMode mode)
    {
        switch (mode)
        {
            case LightMode.Stop:
                redLight.SetColor("_EmissiveColor", RedData.updatedLight);
                yellowLight.SetColor("_EmissiveColor", YellowData.defaultLight);
                greenLight.SetColor("_EmissiveColor", GreenData.defaultLight);
                break;
            case LightMode.Move:
                redLight.SetColor("_EmissiveColor", RedData.defaultLight);
                yellowLight.SetColor("_EmissiveColor", YellowData.defaultLight);
                greenLight.SetColor("_EmissiveColor", GreenData.updatedLight);
                break;
            case LightMode.Ready:
                redLight.SetColor("_EmissiveColor", RedData.defaultLight);
                yellowLight.SetColor("_EmissiveColor", YellowData.updatedLight);
                greenLight.SetColor("_EmissiveColor", GreenData.defaultLight);
                break;
            case LightMode.Stop_Ready:
                redLight.SetColor("_EmissiveColor", RedData.updatedLight);
                yellowLight.SetColor("_EmissiveColor", YellowData.updatedLight);
                greenLight.SetColor("_EmissiveColor", GreenData.defaultLight);
                break;
            default:
                redLight.SetColor("_EmissiveColor", RedData.defaultLight);
                yellowLight.SetColor("_EmissiveColor", YellowData.defaultLight);
                greenLight.SetColor("_EmissiveColor", GreenData.defaultLight);
                break;
        }
    }
    IEnumerator LoopLightCycle()
    {
        LightMode mode = LightMode.Stop;
        while (true)
        {
            if(mode == LightMode.Stop)
            {
                SetLight(LightMode.Stop);
                mode += 1;
                yield return new WaitForSeconds(5);
            }
            else if (mode == LightMode.Move)
            {
                SetLight(LightMode.Move);
                mode += 1;
                yield return new WaitForSeconds(5);
            }
            else if (mode == LightMode.Ready)
            {
                SetLight(LightMode.Ready);
                mode += 1;
                yield return new WaitForSeconds(4);
            }
            else //LightMode.Stop_Ready
            {
                SetLight(LightMode.Stop_Ready);
                mode = 0;
                yield return new WaitForSeconds(1);
            }            
        }             
    }
    IEnumerator WaitForRandomSeconds(float seconds)
    {
        float random = Random.Range(0, seconds);
        yield return new WaitForSeconds(random);
        StartCoroutine(LoopLightCycle());
    }
}
