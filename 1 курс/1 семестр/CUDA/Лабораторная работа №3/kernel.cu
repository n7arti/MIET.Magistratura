#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "device_launch_parameters.h"
#include <math.h>

#define N 1024 // Размер массива
#define BLOCK_SIZE 16
#define LOG_NUM_BANKS 4 
#define CONLICT_FREE_OFFS(i) ((i) >> LOG_NUM_BANKS) 

// CUDA Kernel для префиксной суммы
__global__ void scan(float* a, float* result, float* sums, int n) {
    __shared__ float temp[2 * BLOCK_SIZE + CONFLICT_FREE_OFFS(2 * BLOCK_SIZE)];
    int tid = threadIdx.x;
    int offset = 1;
    int ai = tid;
    int bi = tid + (n / 2);
    int offsA = CONFLICT_FREE_OFFS(ai);
    int offsB = CONFLICT_FREE_OFFS(bi);
    temp[ai + offsA] = a[ai + 2 * BLOCK_SIZE * blockIdx.x];
    temp[bi + offsB] = a[bi + 2 * BLOCK_SIZE * blockIdx.x];
    for (int d = n >> 1; d > 0; d >>= 1, offset <<= 1)
    {
        __syncthreads();
        if (tid < d)
        {
            int ai = offset * (2 * tid + 1) - 1;
            int bi = offset * (2 * tid + 2) - 1;
            ai += CONFLICT_FREE_OFFS(ai);
            bi += CONFLICT_FREE_OFFS(bi);
            temp[bi] += temp[ai];
        }
    }
    if (tid == 0)
    {
        int i = n - 1 + CONFLICT_FREE_OFFS(n-1);  // для scan больших массивов
        sums [blockIdx.x] = temp [i];             // для scan больших массивов
        temp[i] = 0; // clear the last element 
    }
    for (int d = 1; d < n; d <<= 1)
    {
        offset >>= 1;
        __syncthreads();
        if (tid < d)
        {
            int ai = offset * (2 * tid + 1) - 1;
            int bi = offset * (2 * tid + 2) - 1;
            float t;
            ai += CONFLICT_FREE_OFFS(ai);
            bi += CONFLICT_FREE_OFFS(bi);
            t = temp[ai];
            temp[ai] = temp[bi];
            temp[bi] += t;
        }
    }
    __syncthreads();
    result[ai + 2 * BLOCK_SIZE * blockIdx.x] = temp[ai + offsA];
    result[bi + 2 * BLOCK_SIZE * blockIdx.x] = temp[bi + offsB];
}

__global__ void scanDistribute(float* data, float* sums)
{
    data[threadIdx.x + blockIdx.x * 2 * BLOCK_SIZE] += sums[blockIdx.x];
}
void scanOnGPU(float* a, float* result, int n)
{
    int numBlocks = n / (2 * BLOCK_SIZE);
    float* sums; // суммы элементов для каждого блока 
    float* sums2; // результаты scan этих сумм 
    if (numBlocks < 1) numBlocks = 1;
    // выделяем память под массивы 
    cudaMalloc((void**)&sums, numBlocks * sizeof(float));
    cudaMalloc((void**)&sums2, numBlocks * sizeof(float));
    // поблочный scan
    dim3 threads(BLOCK_SIZE, 1, 1), blocks(numBlocks, 1, 1); 	scan << <blocks, threads >> > (inData, outData, sums, 2 * BLOCK_SIZE);
    // выполняем scan для сумм 
    if (n >= 2 * BLOCK_SIZE)
        scanOnCPU(sums, sums2, numBlocks);
    else cudaMemcpy(sums2, sums, numBlocks * sizeof(float), cudaMemcpyDeviceToDevice);
    // корректируем результат 
    threads = dim3(2 * BLOCK_SIZE, 1, 1);
    blocks = dim3(numBlocks - 1, 1, 1);
    scanDistribute << <blocks, threads >> > (outData + 2 * BLOCK_SIZE, sums2 + 1);
    cudaFree(sums);
    cudaFree(sums2);
}


void scanOnCPU(float* a, float* result, int n) {
    result[0] = 0;
    for (int i = 1; i < n; i++)
        result[i] = result[i - 1] + a[i - 1];

}

int main() {
    float* a = (float*)malloc(N * sizeof(float));
    float* result_GPU = (float*)malloc(N * sizeof(float));
    float* result_CPU = (float*)malloc(N * sizeof(float));

    // Выделение памяти на GPU
    float* dev_a, * dev_result_GPU;
    cudaMalloc((void**)&dev_a, N * sizeof(float));
    cudaMalloc((void**)&dev_result_GPU, N * sizeof(float));

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
    scanOnCPU(a, result_CPU, N);

    // Копирование данных с хоста на устройство
    cudaMemcpy(dev_a, a, N * sizeof(float), cudaMemcpyHostToDevice);

    //привязываем событие start  к данному месту 
    cudaEventRecord(start, 0);

    // Запуск ядра CUDA для вычисления префиксной суммы
    scanOnGPU << <(N + 255) / 256, 256 >> > (dev_a, dev_result_GPU);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // запрашиваем время между событиями 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU: %.5f ms\n", gpuTime);

    // Копирование результатов с устройства на хост
    cudaMemcpy(result_GPU, dev_result_GPU, N * sizeof(float), cudaMemcpyDeviceToHost);

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