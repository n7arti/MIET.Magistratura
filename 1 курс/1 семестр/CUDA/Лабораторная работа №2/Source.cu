#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "device_launch_parameters.h"
#include <math.h>

#define N 1024
#define BLOCK_SIZE 16 
void multiplyOnCPU(float* a, float* b, float* c) {
    for (int i = 0; i < N*N; i++) {
        if (c[i] != a[i] * b[i]) {
            printf("Verification failed at element %d!\n", i);
        }
    }
}

__global__ void multiplyOnGPUShared(float* a, float* b, float* c, int n) {
    int bx = blockIdx.x;  // ������� ����� 
    int by = blockIdx.y;  // 

    int tx = threadIdx.x;  // ������� ���� ������ ����� 
    int ty = threadIdx.y;  // 

    int	aBegin = n * BLOCK_SIZE * by;
    int	aEnd = aBegin + n - 1;
    int aStep = BLOCK_SIZE;
    int	bBegin = bx * BLOCK_SIZE;
    int bStep = BLOCK_SIZE * n;
    float	sum = 0.0f;
    for (int ia = aBegin, ib = bBegin; ia <= aEnd; ia += aStep, ib += bStep)
    {
        __shared__ float	as[BLOCK_SIZE][BLOCK_SIZE];
        __shared__ float	bs[BLOCK_SIZE][BLOCK_SIZE];
        as[ty][tx] = a[ia + n * ty + tx];
        bs[ty][tx] = b[ib + n * ty + tx];
        __syncthreads(); // ��������, ��� ���������� ��������� ��������� 
        for (int k = 0; k < BLOCK_SIZE; k++)
            sum += as[ty][k] * bs[k][tx];
        __syncthreads(); // ��������, ��� ���������� ������ ������ �� ����� 
    }
    c[n * BLOCK_SIZE * by + BLOCK_SIZE * bx + n * ty + tx] = sum;

}

__global__ void multiplyOnGPUGlobal(float* a, float* b, float* c, int n) {
    int bx = blockIdx.x;  // ������� ����� 
    int by = blockIdx.y;  // 

    int tx = threadIdx.x;  // ������� ���� ������ ����� 
    int ty = threadIdx.y;  // 

    float sum = 0.0f;

    // �������� ��� a[i][0]
    int ia = n * BLOCK_SIZE * by + n * ty;

    // �������� ��� b[0][i]
    int ib = BLOCK_SIZE * bx + tx;

    // �������� ��� ���������� 
    int ic = n * BLOCK_SIZE * by + BLOCK_SIZE * bx;

    // ����������� � ��������� 
    for (int k = 0; k < n; k++)
        sum += a[ia + k] * b[ib + k * n];
    c[ic + n * ty + tx] = sum; // ���������� ��������� 

}

int main() {
    float* a = (float*)malloc(N * sizeof(float));
    float* b = (float*)malloc(N * sizeof(float));
    float* � = (float*)malloc(N * sizeof(float));

    float* dev_a, * dev_b, * dev_c;
    size_t size = N * N * sizeof(float);

    // �������� ������ �� GPU
    cudaMalloc((void**)&dev_a, size);
    cudaMalloc((void**)&dev_b,size);
    cudaMalloc((void**)&dev_c, size);

    cudaEvent_t start, stop;		//��������� ���������� ����  cudaEvent_t 
    float       gpuTime = 0.0f;
    // ������� ������� ������ � ��������� ���������� ���� 
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // ������������� �������� �� �����
    for (int i = 0; i < N*N; i++) {
        a[i] = i; // �������� ������� ���������� ����������
        b[i] = i + 1;
    }

    // ����������� ������ � ����� �� ����������
    cudaMemcpy(dev_a, a, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, N * sizeof(float), cudaMemcpyHostToDevice);

    // ������ ���� CUDA � ������� � ��������
    dim3 threadsPerBlock(BLOCK_SIZE, BLOCK_SIZE);
    dim3 blocksPerGrid((N + threadsPerBlock.x - 1) / threadsPerBlock.x,
        (N + threadsPerBlock.y - 1) / threadsPerBlock.y);
    //����������� ������� start  � ������� ����� 
    cudaEventRecord(start, 0);
    // ������ ���� �� GPU
    multiplyOnGPUGlobal << <blocksPerGrid, threadsPerBloc >> > (dev_a, dev_b, dev_c, N*N);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // ����������� ����� ����� ��������� 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU Global: %.5f ms\n", gpuTime);

    cudaEventRecord(start, 0);
    // ������ ���� �� GPU
    multiplyOnGPUShared << <blocksPerGrid, threadsPerBloc >> > (dev_a, dev_b, dev_c, N * N);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // ����������� ����� ����� ��������� 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU Shared: %.5f ms\n", gpuTime);


    // ����������� ���������� � ���������� �� ����
    cudaMemcpy(�, dev_c, size, cudaMemcpyDeviceToHost);

    // ����������� ���������� �� CPU
    multiplyOnCPU(a, b, �);

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