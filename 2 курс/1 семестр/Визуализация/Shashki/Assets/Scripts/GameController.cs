
using UnityEngine;

public class GameController : MonoBehaviour
{
    public int Size = 8;

    public void Start()
    {
        Board board = new Board(Size);

        board.GenerateBoard();
    }

}

