#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "device_launch_parameters.h"
#include <math.h>

#define N 1024 // Размер массива
#define BLOCK_SIZE (N/2) 

__device__ void Comparator(unsigned int& keyA, unsigned int& valA, unsigned int& keyB, unsigned int& valB, unsigned int dir)
{
    unsigned int t;
    if ((valA > valB) == dir) //поменять местами (keyA, valA) и (keyB, valB)
    {
        t = keyA; 
        keyA = keyB; 
        keyB = t;
        t = valA; 
        valA = valB; 
        valB = t;
    }
}
__global__ void bitonicSortShared(unsigned int* dstKey, unsigned int* dstVal, unsigned int* srcKey, unsigned int* srcVal, unsigned int arrayLength, unsigned int dir)
{
    __shared__ unsigned int sk[BLOCK_SIZE * 2];
    __shared__ unsigned int sv[BLOCK_SIZE * 2];
    int index = blockIdx.x * BLOCK_SIZE * 2 + threadIdx.x;

    sk[threadIdx.x] = srcKey[index]; sv[threadIdx.x] = srcVal[index];
    sk[threadIdx.x + BLOCK_SIZE] = srcKey[index + BLOCK_SIZE];  sv[threadIdx.x + BLOCK_SIZE] = srcVal[index + BLOCK_SIZE];

    for (unsigned int size = 2; size < arrayLength; size <<= 1)
    {//битоническое слияние
        unsigned int ddd = dir ^ ((threadIdx.x & (size / 2)) != 0);
        for (unsigned int stride = size >> 1; stride > 0; stride >>= 1)
        {
            __syncthreads();
            unsigned int pos = 2 * threadIdx.x - (threadIdx.x & (stride - 1));
            Comparator(sk[pos], sv[pos], sk[pos + stride], sv[pos + stride], ddd);
        }
    }
    //последний шаг - битоническое слияние
    for (unsigned int stride = arrayLength >> 1; stride > 0; stride >>= 1)
    {
        __syncthreads();
        unsigned int pos = 2 * threadIdx.x - (threadIdx.x & (stride - 1));
        Comparator(sk[pos], sv[pos], sk[pos + stride], sv[pos + stride], dir);
    }
    __syncthreads();

    dstKey[index] = sk[threadIdx.x]; dstVal[index] = sv[threadIdx.x];
    dstKey[index + BLOCK_SIZE] = sk[threadIdx.x + BLOCK_SIZE]; dstVal[index + BLOCK_SIZE] = sv[threadIdx.x + BLOCK_SIZE];
}

int main() {
    int* a = (int*)malloc(N * sizeof(int));
    int* result_GPU = (int*)malloc(N * sizeof(int));
    int* result_CPU = (int*)malloc(N * sizeof(int));

    // Выделение памяти на GPU
    int* dev_a, * dev_result_GPU;
    cudaMalloc((void**)&dev_a, N * sizeof(int));
    cudaMalloc((void**)&dev_result_GPU, N * sizeof(int));

    cudaEvent_t start, stop;		//описываем переменные типа  cudaEvent_t 
    float       gpuTime = 0.0f;
    // создаем события начала и окончания выполнения ядра 
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Инициализация массива случайными значениями
    for (int i = 0; i < N; i++) {
        a[i] = rand() % 100;
    }

    // Префиксная сумма на CPU
    for (int i = 0; i < N-1; i++) {
        Comparator(i, a[i], i + 1, a[i + 1], 1);
    }

    // Копирование данных с хоста на устройство
    cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice);

    //привязываем событие start  к данному месту 
    cudaEventRecord(start, 0);

    // Запуск ядра CUDA для вычисления префиксной суммы
    bitonicSortShared << <(N + 255) / 256, 256 >> > (dev_a, dev_result_GPU);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // запрашиваем время между событиями 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU: %.5f ms\n", gpuTime);

    // Копирование результатов с устройства на хост
    cudaMemcpy(result_GPU, dev_result_GPU, N * sizeof(int), cudaMemcpyDeviceToHost);

    // Проверка результатов префиксной суммы
    for (int i = 0; i < N; i++) {
        if (result_CPU[i] != result_GPU[i]) {
            printf("Verification failed at element %d!\n", i);
        }
    }

    // Освобождение памяти
    free(a);
    free(result_GPU);
    free(result_CPU);
    cudaFree(dev_a);
    cudaFree(dev_result_GPU);

    // уничтожаем созданные события 
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}