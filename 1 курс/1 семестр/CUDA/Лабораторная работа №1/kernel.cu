#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define	N	(1024*1024)

__global__ void kernel(float* data)
{
    int   idx = blockIdx.x * blockDim.x + threadIdx.x;
    float x = 2.0f * 3.1415926f * (float)idx / (float)N;
    data[idx] = sinf(sqrtf(x));
}

void deviceQuery() 
{
    int		deviceCount;
    cudaDeviceProp	devProp;

    cudaGetDeviceCount(&deviceCount);
    printf("Found %d devices\n", deviceCount);

    for (int device = 0; device < deviceCount; device++)
    {
        cudaGetDeviceProperties(&devProp, device);
        printf("Device %d\n", device);
        printf("Compute capability     : %d.%d\n", devProp.major, devProp.minor);
        printf("Name                   : %s\n", devProp.name);
        printf("Total Global Memory    : %u\n", devProp.totalGlobalMem);
        printf("Shared memory per block: %d\n", devProp.sharedMemPerBlock);
        printf("Registers per block    : %d\n", devProp.regsPerBlock);
        printf("Warp size              : %d\n", devProp.warpSize);
        printf("Max threads per block  : %d\n", devProp.maxThreadsPerBlock);
        printf("Total constant memory  : %d\n", devProp.totalConstMem);
    }

}

int main(int argc, char* argv[])
{

    deviceQuery(); // Получение информации об устройстве и вывод в консоль

    float* a = (float*)malloc(N * sizeof(float));
    float* dev = nullptr;
    // выделить память на GPU
    cudaMalloc((void**)&dev, N * sizeof(float));

    cudaDeviceProp deviceProp; // Определение структуры cudaDeviceProp
    cudaGetDeviceProperties(&deviceProp, 0);

    cudaEvent_t start, stop;		//описываем переменные типа  cudaEvent_t 
    float       gpuTime = 0.0f;
    // создаем события начала и окончания выполнения ядра 
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Определение максимального количества блоков на мультипроцессор и максимального размера сетки
    int maxBlocksPerGrid;
    cudaOccupancyMaxActiveBlocksPerMultiprocessor(&maxBlocksPerGrid, kernel, 512, 0);
    int maxGridSize = maxBlocksPerGrid * deviceProp.multiProcessorCount;

    dim3 gridSize(maxGridSize, 1);
    dim3 blockSize(512, 1);

    //привязываем событие start  к данному месту 
    cudaEventRecord(start, 0);

    // конфигурация запуска N нитей
    kernel << <gridSize, blockSize >> > (dev);

    // скопировать результаты в память CPU
    cudaMemcpy(a, dev, N * sizeof(float), cudaMemcpyDeviceToHost);

    // освободить выделенную память
    cudaFree(dev);
    free(a);
    for (int idx = 0; idx < N; idx++)
        printf("a[%d] = %.5f\n", idx, a[idx]);

    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);
    // запрашиваем время между событиями 
    cudaEventElapsedTime(&gpuTime, start, stop);
    printf("time spent executing by the GPU: %.5f ms\n", gpuTime);
    // уничтожаем созданные события 
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
