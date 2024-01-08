#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define N 1024

// Функция на CPU для верификации результата
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
        b[i] = i+1;
    }

    // Копирование данных с хоста на устройство
    cudaMemcpy(dev_a, a, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, N * sizeof(float), cudaMemcpyHostToDevice);

    //привязываем событие start  к данному месту 
    cudaEventRecord(start, 0);
    // Запуск ядра на GPU
    multiplyOnGPU << <dim3((N / 512), 1), dim3(512, 1) >> > (d_a, d_b, d_c);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // запрашиваем время между событиями 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU: %.5f ms\n", gpuTime);
   

    // Копирование результата с устройства на хост
    cudaMemcpy(с, dev_c, N * sizeof(float), cudaMemcpyDeviceToHost);

    // Верификация результата на CPU
    multiplyOnCPU(a, b, с);

    // Проверка результатов
    for (int i = 0; i < N; i++) {
        if (с[i] != a[i] * b[i]) {
            printf("Ошибка: c[%d] = %.2f, ожидалось %.2f\n", i, с[i], a[i] * b[i]);
            break;
        }
    }

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