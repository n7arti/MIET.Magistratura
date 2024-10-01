using UnityEngine;

public class CellSpawner : MonoBehaviour
{
    public static CellSpawner Instance { get => _instance; }
    private static CellSpawner _instance;


    public GameObject RedCellPrefab;
    public GameObject WhiteCellPrefab;

    public void Awake()
    {
        _instance = this;
    }

    public Cell Spawn(int row, int column, CellType type)
    {
        GameObject cellObject;

        if (type == CellType.Red)
        {
            cellObject = Instantiate(RedCellPrefab, new Vector3(row, 0, column), Quaternion.identity);
        }
        else
        {
            cellObject = Instantiate(WhiteCellPrefab, new Vector3(row, 0, column), Quaternion.identity);
        }

        return cellObject.GetComponent<Cell>();
    }
}