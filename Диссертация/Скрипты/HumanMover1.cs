using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HumanMover : MonoBehaviour
{
    public GameObject RightArm;
    public GameObject RightForearm;
    public GameObject RightHand;

    public GameObject GizmoPrefab; // ������ ������������
    private GameObject activeGizmo;

    private GameObject selectedJoint = null;
    private Camera mainCamera;

    private bool isDraggingGizmo = false;

    // ���� �������� (� ��������)
    private float thetaRightArm, thetaRightForearm, thetaRightHand;

    // ��������� ��� �������� ����������
    public float Lambda = 0.01f; // ����������� �����������
    public int MaxIterations = 1000; // ������������ ���������� ��������
    public float Tolerance = 0.001f; // ���������� ������

    private bool isDragging = false;

    // Start is called before the first frame update
    void Start()
    {
        mainCamera = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        HandleJointSelection();
        HandleGizmoDragging();
        HandleDragging();
    }

    void HandleJointSelection()
    {
        if (Input.GetMouseButtonDown(0))
        {
            // ���������, �������� �� ���� �� ������
            Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                if (hit.collider.gameObject == RightHand || hit.collider.gameObject == RightForearm || hit.collider.gameObject == RightArm)
                {
                    selectedJoint = hit.collider.gameObject;
                    ShowGizmoAtJoint(selectedJoint);
                }
                else
                {
                    HideGizmo();
                }
            }
        }
    }

    void ShowGizmoAtJoint(GameObject joint)
    {
        // ������� ����� ��� ���������� ������������
        if (activeGizmo == null)
        {
            activeGizmo = Instantiate(GizmoPrefab);
        }

        activeGizmo.transform.position = joint.transform.position;
        activeGizmo.SetActive(true);
    }

    void HideGizmo()
    {
        if (activeGizmo != null)
        {
            activeGizmo.SetActive(false);
        }

        selectedJoint = null;
    }

    void HandleGizmoDragging()
    {
        if (activeGizmo == null || selectedJoint == null)
            return;

        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit) && hit.collider.gameObject == activeGizmo)
            {
                isDraggingGizmo = true;
            }
        }

        if (Input.GetMouseButtonUp(0))
        {
            isDraggingGizmo = false;
        }

        if (isDraggingGizmo)
        {
            // ���������� ����� � ��������������� ������
            Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                activeGizmo.transform.position = hit.point;
                selectedJoint.transform.position = hit.point;
            }
        }
    }

    void HandleDragging()
    {
        if (Input.GetMouseButtonDown(0))
        {
            // ���������, �������� �� ���� �� ����
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit) && hit.collider.gameObject == RightHand)
            {
                Debug.Log($"�����");
                isDragging = true;
            }
        }

        if (Input.GetMouseButtonUp(0))
        {
            Debug.Log($"��������");
            isDragging = false;
        }

        if (isDragging)
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                // ��������� ������� ������� �� ������ ��������� ����
                RightHand.transform.position = hit.point;
                PerformInverseKinematics();
            }
        }
    }

    void PerformInverseKinematics()
    {
        // ������ ���������� ��������� ���������� ��� ����������� ����
        for (int iteration = 0; iteration < MaxIterations; iteration++)
        {
            Vector3 currentPos = RightHand.transform.position;
            Vector3 targetPos = RightHand.transform.position; // ���� ����������� (����� ������ ��� �������)
            Vector3 delta = targetPos - currentPos;

            if (delta.magnitude < Tolerance)
            {
                Debug.Log($"���� ���������� ����� {iteration} ��������");
                break;
            }

            // ��������� ������� �������� (���������� ���� ������ ����������)
            RightForearm.transform.position += delta * 0.5f; // ���������� ������
            RightArm.transform.position += delta * 0.25f;

            // �������������� ������ ��� ���������� ����� ����� ����� ���� ��������� �����
        }
    }
}
