using Unity.VisualScripting;
using UnityEngine;

public class Chess : MonoBehaviour
{
    public Material NaturalMaterial;
    public Material SelectedMaterial;

    public void SelectedOn()
    {
        Debug.Log("popitkaON");
        GetComponent<MeshRenderer>().material = SelectedMaterial;
    }

    public void SelectedOff()
    {
        Debug.Log("popitkaOFF");
        GetComponent<MeshRenderer>().material = NaturalMaterial;
    }
}