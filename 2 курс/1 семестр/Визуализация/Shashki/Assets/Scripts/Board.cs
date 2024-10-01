public class Board
{
    public Cell[,] Cells;
    private int _size;

    public Board(int size)
    {
        _size = size;
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
                }
                else
                {
                    Cells[i, j] = CellSpawner.Instance.Spawn(i, j, CellType.White);
                }
            }
        }
    }
}
