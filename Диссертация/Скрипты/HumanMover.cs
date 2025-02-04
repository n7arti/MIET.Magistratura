//using System.Collections;
//using System.Collections.Generic;
//using UnityEngine;

//public class HumanMover : MonoBehaviour
//{
//    public GameObject RightArm;
//    public GameObject RightForearm;
//    public GameObject RightHand;

//    private Transform targetObject;

//    private float Length_RightHand_RightForearm;
//    private float Length_RightForearm_RightArm;

//    private Vector3 RightHandCurrent;
//    private Vector3 RightHandTarget;

//    // Углы суставов (в радианах)
//    private float thetaX_RightForearmRightArm, thetaRightForearmRightArm_RightHandRightForearm, thetaY;

//    // Параметры для обратной кинематики
//    public float Lambda = 0.01f; // Коэффициент сглаживания
//    public int MaxIterations = 2; // Максимальное количество итераций
//    public float Tolerance = 0.001f; // Допустимая ошибка

//    private bool isDragging = false;

//    void Start()
//    {
//        // Рассчитываем длины сегментов на основе начальной позиции суставов
//        Length_RightHand_RightForearm = Vector3.Distance(RightHand.transform.position, RightForearm.transform.position);
//        Length_RightForearm_RightArm = Vector3.Distance(RightForearm.transform.position, RightArm.transform.position);

//        RightHandCurrent = RightHand.transform.position;
//    }

//    void Update()
//    {
//        HandleDragging();
//    }

//    private void HandleDragging()
//    {
//        Vector3 offset = new Vector3();

//        if (Input.GetMouseButtonDown(0)) // Нажата левая кнопка мыши
//        {
//            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
//            if (Physics.Raycast(ray, out RaycastHit hit) && hit.collider.tag == "Human")
//            {
//                isDragging = true;
//                offset = RightHand.transform.position - GetMouseWorldPosition();
//            }
//        }

//        if (Input.GetMouseButtonUp(0)) // Отпущена левая кнопка мыши
//        {
//            isDragging = false;
//        }

//        if (isDragging)
//        {
//            Vector3 newPosition = GetMouseWorldPosition() + offset;
//            RightHandTarget = new Vector3(newPosition.x, newPosition.y, RightHand.transform.position.z); // Ограничение по осям X и Y
//            PerformInverseKinematics();
//        }
//    }

//    private Vector3 GetMouseWorldPosition()
//    {
//        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
//        if (Physics.Raycast(ray, out RaycastHit hit))
//        {
//            return hit.point;
//        }

//        return Vector3.zero;
//    }

//    void PerformInverseKinematics()
//    {
//        // Текущая позиция конечной точки
//        RightHandCurrent = RightHand.transform.position;

//        // Ошибка между текущей и целевой позициями
//        Vector3 delta = RightHandTarget - RightHandCurrent;

//        // Матрица Якоби (вычисляется для текущих углов)
//        Matrix4x4 jacobian = CalculateJacobian();

//        //// Транспонированная матрица Якоби
//        //Matrix4x4 jacobianT = jacobian.transpose;

//        //// Псевдообратная матрица Якоби
//        //Matrix4x4 jacobianPseudoInverse = PseudoInverse(jacobian, jacobianT, Lambda);

//        //// Изменения углов
//        //Vector3 deltaTheta = MultiplyMatrixVector(jacobianPseudoInverse, delta);

//        //// Обновление углов суставов
//        //thetaRightArm += deltaTheta.x;
//        //thetaRightForearm += deltaTheta.y;
//        //thetaRightHand += deltaTheta.z;


//        //// Применение углов к суставам
//        //ApplyJointRotationsAndPositions();
//    }

//    Matrix4x4 CalculateJacobian()
//    {
//        // Матрица Якоби для 3 суставов
//        Matrix4x4 jacobian = new Matrix4x4();

//        Vector3 joint1Pos = RightArm.transform.position;
//        Vector3 joint2Pos = RightForearm.transform.position;
//        Vector3 joint3Pos = RightHand.transform.position;

//        Vector3 arm1 = joint2Pos - joint1Pos;
//        Vector3 arm2 = joint3Pos - joint2Pos;

//        jacobian.SetRow(0, new Vector4(-arm1.y, -arm2.y, 0, 0));
//        jacobian.SetRow(1, new Vector4(arm1.x, arm2.x, 0, 0));
//        jacobian.SetRow(2, new Vector4(0, 0, 1, 0));

//        return jacobian;
//    }

//    //Matrix4x4 PseudoInverse(Matrix4x4 jacobian, Matrix4x4 jacobianT, float lambda)
//    //{
//    //    Matrix4x4 identity = Matrix4x4.identity;
//    //    Matrix4x4 jacobianProduct = jacobianT * jacobian;

//    //    // Добавляем сглаживание
//    //    for (int i = 0; i < 4; i++)
//    //    {
//    //        jacobianProduct[i, i] += lambda;
//    //    }

//    //    // Инвертируем матрицу
//    //    Matrix4x4 inverse = jacobianProduct.inverse;

//    //    return inverse * jacobianT;
//    //}

//    //Vector3 MultiplyMatrixVector(Matrix4x4 matrix, Vector3 vector)
//    //{
//    //    return new Vector3(
//    //        matrix.m00 * vector.x + matrix.m01 * vector.y + matrix.m02 * vector.z,
//    //        matrix.m10 * vector.x + matrix.m11 * vector.y + matrix.m12 * vector.z,
//    //        matrix.m20 * vector.x + matrix.m21 * vector.y + matrix.m22 * vector.z
//    //    );
//    //}

//    //void ApplyJointRotationsAndPositions()
//    //{
//    //    // Обновление вращения суставов
//    //    RightArm.transform.localRotation = Quaternion.Euler(0, thetaRightArm * Mathf.Rad2Deg, 0);

//    //    // Позиция RightForearm относительно RightArm
//    //    Vector3 armDirection = new Vector3(Mathf.Sin(thetaRightArm), 0, Mathf.Cos(thetaRightArm));
//    //    Vector3 rightForearmTargetPosition = RightArm.transform.position + armDirection.normalized * Length_RightForearm_RightArm;
//    //    RightForearm.transform.position = rightForearmTargetPosition;

//    //    RightForearm.transform.localRotation = Quaternion.Euler(0, thetaRightForearm * Mathf.Rad2Deg, 0);

//    //    // Позиция RightHand относительно RightForearm
//    //    Vector3 forearmDirection = new Vector3(Mathf.Sin(thetaRightForearm), 0, Mathf.Cos(thetaRightForearm));
//    //    Vector3 rightHandTargetPosition = RightForearm.transform.position + forearmDirection.normalized * Length_RightHand_RightForearm;
//    //    RightHand.transform.position = rightHandTargetPosition;

//    //    RightHand.transform.localRotation = Quaternion.Euler(0, 0, thetaRightHand * Mathf.Rad2Deg);

//    //    Debug.Log($"Позиции обновлены: Hand {RightHand.transform.position}, Forearm {RightForearm.transform.position}");
//    //}
//}
