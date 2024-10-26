using System;
using UnityEngine;

public class ChessMover : MonoBehaviour
{
    Cell FirstCell;
    Cell SecondCell;

    private void Awake()
    {

    }

    public void Update()
    {
        DestroyObject();

        if (Input.GetMouseButtonDown(0))
        {
            if (FirstCell == null)
            {
                FirstSelect();
            }
            else
            {
                SecondSelect();

                FirstCell?._chess?.SelectedOff();
                SecondCell?._chess?.SelectedOff();
                FirstCell = null;
                SecondCell = null;
            }
        }
    }

    private void FirstSelect()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit))
        {
            Cell cell;

            if (!hit.collider.gameObject.TryGetComponent<Cell>(out cell))
            {
                return;
            }

            if (cell.IsCellFree())
            {
                return;
            }

            cell._chess.SelectedOn();
            FirstCell = cell;
        }
    }

    private void SecondSelect()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit))
        {
            Cell cell;

            if (!hit.collider.gameObject.TryGetComponent<Cell>(out cell))
            {
                return;
            }

            if (!cell.IsCellFree())
            {
                return;
            }

            SecondCell = cell;
            if (Mathf.Abs(cell.transform.position.x - FirstCell.transform.position.x) == 1 &&
                Mathf.Abs(cell.transform.position.z - FirstCell.transform.position.z) == 1)
            {
                FirstCell._chess.gameObject.transform.position = cell.transform.position;
                cell._chess = FirstCell._chess;
                FirstCell._chess = null;
            }

            TryEat();
        }
    }

    private void TryEat()
    {
        if (Mathf.Abs(SecondCell.transform.position.x - FirstCell.transform.position.x) == 2 &&
                    Mathf.Abs(SecondCell.transform.position.z - FirstCell.transform.position.z) == 2)
        {
            Vector3 dir = SecondCell.transform.position - FirstCell.transform.position;
            Vector3 maybeEnemyposition = FirstCell.transform.position + dir / 2;
            Debug.Log(maybeEnemyposition);
            if (!Board.Instance.IsCellFree(maybeEnemyposition))
            {
                Debug.Log(maybeEnemyposition + "Удаляем");
                FirstCell._chess.gameObject.transform.position = SecondCell.transform.position;
                SecondCell._chess = FirstCell._chess;
                FirstCell._chess = null;
                Cell EnemyCell = Board.Instance.GetCell(maybeEnemyposition);
                Destroy(EnemyCell._chess.gameObject);
                EnemyCell._chess = null;
            }
        }
    }

    public void DestroyObject()
    {
        if (Input.GetMouseButtonDown(1))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                Cell cell;

                if (hit.collider.gameObject.TryGetComponent<Cell>(out cell))
                {
                    Destroy(cell._chess.gameObject);
                    cell._chess = null;
                }

            }
        }
    }
}

