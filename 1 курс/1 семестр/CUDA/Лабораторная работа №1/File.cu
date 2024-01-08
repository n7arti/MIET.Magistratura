#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define N 1024

// ������� �� CPU ��� ����������� ����������
void multiplyOnCPU(float* a, float* b, float* c) {
    for (int i = 0; i < N; i++) {
        c[i] = a[i] * b[i];
    }
}

__global__ void multiplyOnGPU(float* a, float* b, float* c) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N) {
        c[idx] = a[idx] * b[idx];
    }
}

int main() { 
    float* a = (float*)malloc(N * sizeof(float));
    float* b = (float*)malloc(N * sizeof(float));
    float* � = (float*)malloc(N * sizeof(float));

    float* dev_a, * dev_b, * dev_c;

    // �������� ������ �� GPU
    cudaMalloc((void**)&dev_a, N * sizeof(float));
    cudaMalloc((void**)&dev_b, N * sizeof(float));
    cudaMalloc((void**)&dev_c, N * sizeof(float));

    cudaEvent_t start, stop;		//��������� ���������� ����  cudaEvent_t 
    float       gpuTime = 0.0f;
    // ������� ������� ������ � ��������� ���������� ���� 
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // ������������� �������� �� �����
    for (int i = 0; i < N; i++) {
        a[i] = i; // �������� ������� ���������� ����������
        b[i] = i+1;
    }

    // ����������� ������ � ����� �� ����������
    cudaMemcpy(dev_a, a, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, N * sizeof(float), cudaMemcpyHostToDevice);

    //����������� ������� start  � ������� ����� 
    cudaEventRecord(start, 0);
    // ������ ���� �� GPU
    multiplyOnGPU << <dim3((N / 512), 1), dim3(512, 1) >> > (d_a, d_b, d_c);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // ����������� ����� ����� ��������� 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU: %.5f ms\n", gpuTime);
   

    // ����������� ���������� � ���������� �� ����
    cudaMemcpy(�, dev_c, N * sizeof(float), cudaMemcpyDeviceToHost);

    // ����������� ���������� �� CPU
    multiplyOnCPU(a, b, �);

    // �������� �����������
    for (int i = 0; i < N; i++) {
        if (�[i] != a[i] * b[i]) {
            printf("������: c[%d] = %.2f, ��������� %.2f\n", i, �[i], a[i] * b[i]);
            break;
        }
    }

    // ������������ ������
    free(a);
    free(b);
    free(�);
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);

    // ���������� ��������� ������� 
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}