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
    int bx = blockIdx.x;  // индексы блока 
    int by = blockIdx.y;  // 

    int tx = threadIdx.x;  // индексы нити внутри блока 
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
        __syncthreads(); // ”бедимс€, что подматрицы полностью загружены 
        for (int k = 0; k < BLOCK_SIZE; k++)
            sum += as[ty][k] * bs[k][tx];
        __syncthreads(); // ”бедимс€, что подматрицы никому больше не нужны 
    }
    c[n * BLOCK_SIZE * by + BLOCK_SIZE * bx + n * ty + tx] = sum;

}

__global__ void multiplyOnGPUGlobal(float* a, float* b, float* c, int n) {
    int bx = blockIdx.x;  // индексы блока 
    int by = blockIdx.y;  // 

    int tx = threadIdx.x;  // индексы нити внутри блока 
    int ty = threadIdx.y;  // 

    float sum = 0.0f;

    // смещение дл€ a[i][0]
    int ia = n * BLOCK_SIZE * by + n * ty;

    // смещение дл€ b[0][i]
    int ib = BLOCK_SIZE * bx + tx;

    // смещение дл€ результата 
    int ic = n * BLOCK_SIZE * by + BLOCK_SIZE * bx;

    // перемножаем и суммируем 
    for (int k = 0; k < n; k++)
        sum += a[ia + k] * b[ib + k * n];
    c[ic + n * ty + tx] = sum; // запоминаем результат 

}

int main() {
    float* a = (float*)malloc(N * sizeof(float));
    float* b = (float*)malloc(N * sizeof(float));
    float* с = (float*)malloc(N * sizeof(float));

    float* dev_a, * dev_b, * dev_c;
    size_t size = N * N * sizeof(float);

    // выделить пам€ть на GPU
    cudaMalloc((void**)&dev_a, size);
    cudaMalloc((void**)&dev_b,size);
    cudaMalloc((void**)&dev_c, size);

    cudaEvent_t start, stop;		//описываем переменные типа  cudaEvent_t 
    float       gpuTime = 0.0f;
    // создаем событи€ начала и окончани€ выполнени€ €дра 
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // »нициализаци€ векторов на хосте
    for (int i = 0; i < N*N; i++) {
        a[i] = i; // «аполним векторы случайными значени€ми
        b[i] = i + 1;
    }

    //  опирование данных с хоста на устройство
    cudaMemcpy(dev_a, a, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, N * sizeof(float), cudaMemcpyHostToDevice);

    // «апуск €дра CUDA с блоками и потоками
    dim3 threadsPerBlock(BLOCK_SIZE, BLOCK_SIZE);
    dim3 blocksPerGrid((N + threadsPerBlock.x - 1) / threadsPerBlock.x,
        (N + threadsPerBlock.y - 1) / threadsPerBlock.y);
    //прив€зываем событие start  к данному месту 
    cudaEventRecord(start, 0);
    // «апуск €дра на GPU
    multiplyOnGPUGlobal << <blocksPerGrid, threadsPerBloc >> > (dev_a, dev_b, dev_c, N*N);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // запрашиваем врем€ между событи€ми 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU Global: %.5f ms\n", gpuTime);

    cudaEventRecord(start, 0);
    // «апуск €дра на GPU
    multiplyOnGPUShared << <blocksPerGrid, threadsPerBloc >> > (dev_a, dev_b, dev_c, N * N);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // запрашиваем врем€ между событи€ми 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU Shared: %.5f ms\n", gpuTime);


    //  опирование результата с устройства на хост
    cudaMemcpy(с, dev_c, size, cudaMemcpyDeviceToHost);

    // ¬ерификаци€ результата на CPU
    multiplyOnCPU(a, b, с);

    // ќсвобождение пам€ти
    free(a);
    free(b);
    free(с);
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);

    // уничтожаем созданные событи€ 
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}