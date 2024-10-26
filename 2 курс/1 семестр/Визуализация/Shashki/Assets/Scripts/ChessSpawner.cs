
using UnityEngine;

public class ChessSpawner : MonoBehaviour
{
    public static ChessSpawner Instance { get => _instance; }
    private static ChessSpawner _instance;


    public GameObject RedChessPrefab;
    public GameObject WhiteChessPrefab;

    public void Awake()
    {
        _instance = this;
    }

    public Chess Spawn(int row, int column, ChessType type)
    {
        GameObject cellObject;
        Chess chess;

        if (type == ChessType.Red)
        {
            cellObject = Instantiate(RedChessPrefab, new Vector3(row, 0, column), Quaternion.identity, gameObject.transform);
            chess = cellObject.GetComponent<Chess>();
        }
        else
        {
            cellObject = Instantiate(WhiteChessPrefab, new Vector3(row, 0, column), Quaternion.identity, gameObject.transform);
            chess = cellObject.GetComponent<Chess>();
        }

        return chess;
    }
}