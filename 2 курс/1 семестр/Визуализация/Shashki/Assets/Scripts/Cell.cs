using UnityEngine;

public class Cell : MonoBehaviour
{
    public bool isRed = false;
    public Chess _chess = null;

    public bool IsCellFree()
    {
        Vector3 position = transform.position;

        Debug.Log($"Выделена клетка {(int)position.x}:{(int)position.z}");

        return _chess is null;
    }

}