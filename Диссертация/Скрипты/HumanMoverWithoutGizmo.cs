using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor; // Для использования Handles
#endif

public class HumanMover : MonoBehaviour
{
    public GameObject RightArm;
    public GameObject RightForearm;
    public GameObject RightHand;

    private float Length_RightHand_RightForearm;
    private float Length_RightForearm_RightArm;

    private Vector3 RightHandCurrent;
    private Vector3 RightHandTarget;

    // Углы суставов (в радианах)
    private float thetaRightArm, thetaRightForearm, thetaRightHand;

    // Параметры для обратной кинематики
    public float Lambda = 0.01f; // Коэффициент сглаживания
    public int MaxIterations = 1000; // Максимальное количество итераций
    public float Tolerance = 0.001f; // Допустимая ошибка

    private bool isDragging = false;

    // Переменная для хранения выбранного сустава
    private GameObject selectedJoint;

    void Start()
    {
        // Рассчитываем длины сегментов на основе начальной позиции суставов
        Length_RightHand_RightForearm = Vector3.Distance(RightHand.transform.position, RightForearm.transform.position);
        Length_RightForearm_RightArm = Vector3.Distance(RightForearm.transform.position, RightArm.transform.position);

        RightHandCurrent = RightHand.transform.position;
    }

    void Update()
    {
        HandleDragging();
    }

    void HandleDragging()
    {
        if (Input.GetMouseButtonDown(0))
        {
            // Проверяем, попадает ли мышь на сустав
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                if (hit.collider.gameObject == RightHand || hit.collider.gameObject == RightForearm || hit.collider.gameObject == RightArm)
                {
                    selectedJoint = hit.collider.gameObject;
                    Debug.Log($"Выбран сустав: {selectedJoint.name}");
                }
            }
        }

        if (Input.GetMouseButtonUp(0))
        {
            selectedJoint = null;
        }
    }

#if UNITY_EDITOR
    // Рисуем манипуляторы для выбранного сустава
    void OnDrawGizmos()
    {
        if (selectedJoint != null)
        {
            Handles.color = Color.green;
            Vector3 newPos = Handles.PositionHandle(selectedJoint.transform.position, Quaternion.identity);

            // Если манипулятор был перемещён
            if (selectedJoint.transform.position != newPos)
            {
                Undo.RecordObject(selectedJoint.transform, "Move Joint");
                selectedJoint.transform.position = newPos;

                // Если это кисть, применяем обратную кинематику
                if (selectedJoint == RightHand)
                {
                    RightHandTarget = newPos;
                    PerformInverseKinematics();
                }
            }
        }
    }
#endif

    void PerformInverseKinematics()
    {
        for (int i = 0; i < MaxIterations; i++)
        {
            Vector3 handPosition = RightHand.transform.position;
            Vector3 forearmPosition = RightForearm.transform.position;
            Vector3 armPosition = RightArm.transform.position;

            Vector3 error = RightHandTarget - handPosition;

            if (error.magnitude < Tolerance)
            {
                Debug.Log($"Цель достигнута за {i} итераций.");
                break;
            }

            float maxReach = Length_RightHand_RightForearm + Length_RightForearm_RightArm;
            if (error.magnitude > maxReach)
            {
                Debug.LogWarning($"Целевая точка недостижима. Ограничиваем движение.");
                RightHandTarget = handPosition + error.normalized * maxReach;
            }

            RightHand.transform.position = Vector3.Lerp(handPosition, RightHandTarget, 0.5f);

            Vector3 toHand = handPosition - forearmPosition;
            if (toHand.magnitude == 0) toHand = Vector3.up * Length_RightHand_RightForearm;
            toHand = toHand.normalized * Length_RightHand_RightForearm;
            RightForearm.transform.position = handPosition - toHand;

            Vector3 toForearm = forearmPosition - armPosition;
            if (toForearm.magnitude == 0) toForearm = Vector3.up * Length_RightForearm_RightArm;
            toForearm = toForearm.normalized * Length_RightForearm_RightArm;
            RightArm.transform.position = forearmPosition - toForearm;

            if (CheckInvalidPosition(RightHand.transform.position) ||
                CheckInvalidPosition(RightForearm.transform.position) ||
                CheckInvalidPosition(RightArm.transform.position))
            {
                Debug.LogError("Некорректные значения в расчётах IK. Прерываем выполнение.");
                break;
            }
        }
    }

    bool CheckInvalidPosition(Vector3 position)
    {
        return float.IsNaN(position.x) || float.IsNaN(position.y) || float.IsNaN(position.z) ||
               float.IsInfinity(position.x) || float.IsInfinity(position.y) || float.IsInfinity(position.z);
    }
}
