using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class Board
{
    public static Board Instance { get => _instance; }
    private static Board _instance;

    public Cell[,] Cells;
    public List<Chess> RedChess = new();
    public List<Chess> WhiteChess = new();
    private int _size;

    public Board(int size)
    {
        _instance = this;
        _size = size;
    }

    public bool IsCellFree(Vector3 position)
    {       
        Debug.Log($"Выделена клетка {(int)position.x}:{(int)position.z}");

        return Cells[(int)position.x, (int) position.z]._chess is null;
    }

    public Cell GetCell(Vector3 position)
    {
        return Cells[(int)position.x, (int)position.z];
    }

    public void GenerateBoard()
    {
        Cells = new Cell[_size, _size];

        for (int i = 0; i < _size; i++)
        {
            for (int j = 0; j < _size; j++)
            {
                if ((i + j) % 2 == 0)
                {
                    Cells[i, j] = CellSpawner.Instance.Spawn(i, j, CellType.Red);

                    if (i < 3)
                    {
                        Cells[i, j]._chess = ChessSpawner.Instance.Spawn(i, j, ChessType.Red);
                        RedChess.Add(Cells[i, j]._chess);
                    }

                    if (i > _size - 3 - 1)
                    {
                        Cells[i, j]._chess = ChessSpawner.Instance.Spawn(i, j, ChessType.White);
                        WhiteChess.Add(Cells[i, j]._chess);
                    }
                }
                else
                {
                    Cells[i, j] = CellSpawner.Instance.Spawn(i, j, CellType.White);
                }
            }
        }
    }
}
