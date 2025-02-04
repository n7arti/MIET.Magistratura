//using UnityEngine;

//public class InverseKinematics : MonoBehaviour
//{
//    public Transform redBall;     // Красный шар
//    public Transform greenBall;   // Зеленый шар
//    public Transform yellowBall;  // Желтый шар

//    public Transform redGreenCylinder;  // Цилиндр между красным и зеленым
//    public Transform greenYellowCylinder; // Цилиндр между зеленым и желтым

//    private float redToGreenDistance;  // Расстояние между красным и зеленым
//    private float greenToYellowDistance; // Расстояние между зеленым и желтым

//    public float offset = 0.5f; // Допустимый диапазон отклонений

//    private void Start()
//    {
//        // Вычисляем начальные расстояния между шарами
//        redToGreenDistance = Vector3.Distance(redBall.position, greenBall.position);
//        greenToYellowDistance = Vector3.Distance(greenBall.position, yellowBall.position);

//        // Обновляем длины цилиндров
//        UpdateCylinder(redGreenCylinder, redBall.position, greenBall.position);
//        UpdateCylinder(greenYellowCylinder, greenBall.position, yellowBall.position);
//    }

//    private void Update()
//    {
//        // Проверяем зажатие левой кнопки мыши и движение мыши
//        if (Input.GetMouseButton(0))
//        {
//            // Определяем позицию мыши в мировых координатах
//            Vector3 mousePosition = Input.mousePosition;
//            mousePosition.z = Camera.main.WorldToScreenPoint(redBall.position).z;
//            Vector3 targetPosition = Camera.main.ScreenToWorldPoint(mousePosition);

//            if (CanMoveRedBall(targetPosition))
//            {
//                // Перемещаем красный шар к целевой позиции
//                redBall.position = targetPosition;

//                // Привязываем зеленый шар к цилиндру между красным и зеленым
//                Vector3 redToGreenDir = (greenBall.position - redBall.position).normalized;
//                greenBall.position = redBall.position + redToGreenDir * redToGreenDistance;

//                // Привязываем желтый шар к цилиндру между зеленым и желтым
//                //Vector3 greenToYellowDir = (yellowBall.position - greenBall.position).normalized;
//                //yellowBall.position = greenBall.position + greenToYellowDir * greenToYellowDistance;

//                // Обновляем ориентацию цилиндров
//                UpdateCylinderOrientation(redGreenCylinder, redBall.position, greenBall.position);
//                UpdateCylinderOrientation(greenYellowCylinder, greenBall.position, yellowBall.position);
//            }
//        }
//    }

//    private bool CanMoveRedBall(Vector3 targetPosition)
//    {
//        // Направление от красного к зеленому
//        Vector3 redToGreenDir = (greenBall.position - redBall.position).normalized;

//        // Предсказанная позиция зеленого шара после перемещения красного
//        Vector3 predictedGreenPosition = targetPosition + redToGreenDir * redToGreenDistance;

//        // Проверяем, чтобы расстояние между красным и зеленым было в пределах длины цилиндра с учетом offset
//        float distanceToGreen = Vector3.Distance(targetPosition, greenBall.position);
//        bool isRedToGreenValid = distanceToGreen >= redToGreenDistance - offset &&
//                                 distanceToGreen <= redToGreenDistance + offset;

//        // Проверяем, чтобы расстояние между зеленым и желтым было в пределах длины цилиндра с учетом offset
//        float distanceToYellow = Vector3.Distance(predictedGreenPosition, yellowBall.position);
//        bool isGreenToYellowValid = distanceToYellow >= greenToYellowDistance - offset &&
//                                    distanceToYellow <= greenToYellowDistance + offset;

//        return isRedToGreenValid && isGreenToYellowValid;
//    }

//    private void UpdateCylinder(Transform cylinder, Vector3 start, Vector3 end)
//    {
//        // Обновляем позицию цилиндра как середину между двумя точками
//        cylinder.position = (start + end) / 2.0f;

//        // Обновляем длину цилиндра
//        float distance = Vector3.Distance(start, end);
//        cylinder.localScale = new Vector3(cylinder.localScale.x, distance / 2.0f, cylinder.localScale.z);

//        // Обновляем ориентацию цилиндра
//        Vector3 direction = (end - start).normalized;
//        cylinder.rotation = Quaternion.FromToRotation(Vector3.up, direction);
//    }

//    private void UpdateCylinderOrientation(Transform cylinder, Vector3 start, Vector3 end)
//    {
//        // Обновляем позицию цилиндра как середину между двумя точками
//        cylinder.position = (start + end) / 2.0f;

//        // Обновляем ориентацию цилиндра
//        Vector3 direction = (end - start).normalized;
//        cylinder.rotation = Quaternion.FromToRotation(Vector3.up, direction);
//    }
//}