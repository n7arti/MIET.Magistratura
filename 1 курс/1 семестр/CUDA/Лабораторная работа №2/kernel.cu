#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "device_launch_parameters.h"
#include <math.h>

#define N 1024
#define BLOCK_SIZE 16 
void multiplyOnCPU(float* a, float* b, float* c) {
    for (int i = 0; i < N; i++) {
        if (c[i] != a[i] * b[i]) {
            printf("Verification failed at element %d!\n", i);
        }
    }
}

__global__ void multiplyOnGPU(float* a, float* b, float* c, int n) {
    int bx = blockIdx.x;  // индексы блока 
    int by = blockIdx.y;  // 

    int tx = threadIdx.x;  // индексы нити внутри блока 
    int ty = threadIdx.y;  // 

    float sum = 0.0f;

    // смещение для a[i][0]
    int ia = n * BLOCK_SIZE * by + n * ty;

    // смещение для b[0][i]
    int ib = BLOCK_SIZE * bx + tx;

    // смещение для результата 
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

    // выделить память на GPU
    cudaMalloc((void**)&dev_a, N * sizeof(float));
    cudaMalloc((void**)&dev_b, N * sizeof(float));
    cudaMalloc((void**)&dev_c, N * sizeof(float));

    cudaEvent_t start, stop;		//описываем переменные типа  cudaEvent_t 
    float       gpuTime = 0.0f;
    // создаем события начала и окончания выполнения ядра 
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Инициализация векторов на хосте
    for (int i = 0; i < N; i++) {
        a[i] = i; // Заполним векторы случайными значениями
        b[i] = i + 1;
    }

    // Копирование данных с хоста на устройство
    cudaMemcpy(dev_a, a, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, N * sizeof(float), cudaMemcpyHostToDevice);

    // Запуск ядра CUDA с блоками и потоками
    int blockSize = 256;
    int gridSize = (N + blockSize - 1) / blockSize;
    //привязываем событие start  к данному месту 
    cudaEventRecord(start, 0);
    // Запуск ядра на GPU
    multiplyOnGPU << <gridSize, blockSize >> > (dev_a, dev_b, dev_c, N);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // запрашиваем время между событиями 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU: %.5f ms\n", gpuTime);


    // Копирование результата с устройства на хост
    cudaMemcpy(с, dev_c, N * sizeof(float), cudaMemcpyDeviceToHost);

    // Верификация результата на CPU
    multiplyOnCPU(a, b, с);

    // Освобождение памяти
    free(a);
    free(b);
    free(с);
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);

    // уничтожаем созданные события 
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}