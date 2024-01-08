/* Copyright (c) 2022, NVIDIA CORPORATION. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of NVIDIA CORPORATION nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

 /*
   Image box filtering example

   This sample uses CUDA to perform a simple box filter on an image
   and uses OpenGL to display the results.

   It processes rows and columns of the image in parallel.

   The box filter is implemented such that it has a constant cost,
   regardless of the filter width.

   Press '=' to increment the filter radius, '-' to decrease it

   Version 1.1 - modified to process 8-bit RGBA images
 */

 // OpenGL Graphics includes

#include "../Common/helper_gl.h"
#if defined(__APPLE__) || defined(__MACOSX)
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <GLUT/glut.h>
#ifndef glutCloseFunc
#define glutCloseFunc glutWMCloseFunc
#endif
#else
#endif

// CUDA utilities and system includes
#include <cuda_runtime.h>
#include <cuda_gl_interop.h>

// Helper functions
#include "../Common/helper_functions.h"  // CUDA SDK Helper functions
#include "../Common/helper_cuda.h"       // CUDA device initialization helper functions
#define STB_IMAGE_IMPLEMENTATION   
#include "../stb/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../stb/stb_image_write.h"

#define MAX_EPSILON_ERROR 5.0f
#define REFRESH_DELAY 10  // ms

const static char* sSDKsample = "CUDA Iterative Box Filter";

// Define the files that are to be save and the reference images for validation
const char* sOriginal[] = { "teapot1024_14.ppm", "teapot1024_22.ppm", NULL };

const char* sReference[] = { "ref_14.ppm", "ref_22.ppm", NULL };

const char* image_filename = "teapot1024.ppm";
int iterations = 1;
int filter_radius = 14;
int nthreads = 64;
unsigned int width = 1920, height = 1080;
unsigned int* h_img = NULL;
unsigned int* d_img = NULL;
unsigned int* d_temp = NULL;

GLuint pbo;                                      // OpenGL pixel buffer object
struct cudaGraphicsResource* cuda_pbo_resource;  // handles OpenGL-CUDA exchange
GLuint texid;                                    // Texture
GLuint shader;

StopWatchInterface* timer = NULL, * kernel_timer = NULL;

// Auto-Verification Code
int fpsCount = 0;  // FPS count for averaging
int fpsLimit = 8;  // FPS limit for sampling
int g_Index = 0;
int g_nFilterSign = 1;
float avgFPS = 0.0f;
unsigned int frameCount = 0;
unsigned int g_TotalErrors = 0;
bool g_bInteractive = false;

int* pArgc = NULL;
char** pArgv = NULL;

extern "C" int runSingleTest(char* ref_file, char* exec_path);
extern "C" int runBenchmark();
extern "C" void loadImageData(int argc, char** argv);
extern "C" void computeGold(float* id, float* od, int w, int h, int n);

// These are CUDA functions to handle allocation and launching the kernels
extern "C" void initTexture(int width, int height, void* pImage, bool useRGBA);
extern "C" void freeTextures();
extern "C" double boxFilter(float* d_src, float* d_temp, float* d_dest,
    int width, int height, int radius, int iterations,
    int nthreads, StopWatchInterface * timer);

extern "C" double boxFilterRGBA(unsigned int* d_src, unsigned int* d_temp,
    unsigned int* d_dest, int width, int height,
    int radius, int iterations, int nthreads,
    StopWatchInterface * timer);


void initCuda(bool useRGBA) {
    // allocate device memory
    cudaMalloc((void**)&d_img, (width * height * sizeof(unsigned int)));
        
    cudaMalloc((void**)&d_temp, (width * height * sizeof(unsigned int)));
        

    // Refer to boxFilter_kernel.cu for implementation
    initTexture(width, height, h_img, useRGBA);

    sdkCreateTimer(&timer);
    sdkCreateTimer(&kernel_timer);
}

void saveImageData(char* image_path)
{
    sdkSavePPM4ub(image_path, (unsigned char*)d_img, width, height);
    printf("Saved '%s', %d x %d pixels\n", image_path, width, height);
}

////////////////////////////////////////////////////////////////////////////////
//! Run a simple benchmark test for CUDA
////////////////////////////////////////////////////////////////////////////////

char* toBinary(int n, int len)
{
    char* binary = (char*)malloc(sizeof(char) * len);
    int k = 0;
    for (unsigned i = (1 << len - 1); i > 0; i = i / 2) {
        binary[k++] = (n & i) ? '1' : '0';
    }
    binary[k] = '\0';
    return binary;
}

void print_binary(unsigned char* n)
{
    int len = 8;
    char* binary = toBinary(n[0], len);
    printf("The binary representation of %d is %s\n", n[0], binary);
}

void print_binary(unsigned int* n)
{
    int len = 32;
    char* binary = toBinary(n[0], len);
    printf("The binary representation of %d is %s\n", n[0], binary);
}

void print_binary(float* n)
{
    int len = 32;
    char* binary = toBinary(n[0], len);
    printf("The binary representation of %d is %s\n", n[0], binary);
}


int runSingleTest() {
    int nTotalErrors = 0;
    char dump_file[256];

    printf("[runSingleTest]: [%s]\n", sSDKsample);

    print_binary(h_img);
    initCuda(true);

    unsigned int* d_result;
    unsigned int* h_result = (unsigned int*)malloc(width * height * sizeof(unsigned int));
    checkCudaErrors(cudaMalloc((void**)&d_result, width * height * sizeof(unsigned int)));

    //cudaMemcpy((unsigned int*)d_img, (unsigned int*)h_img,
    //    width * height * sizeof(unsigned int), cudaMemcpyHostToDevice);
    // run the sample radius
    
        printf("%s (radius=%d) (passes=%d) \n", sSDKsample, filter_radius,
            iterations);

        boxFilterRGBA(d_img, d_temp, d_result, width, height, filter_radius, 1, nthreads, kernel_timer);

        // check if kernel execution generated an error
        getLastCudaError("Error: boxFilterRGBA Kernel execution FAILED");
        checkCudaErrors(cudaDeviceSynchronize());

        // readback the results to system memory
        cudaMemcpy((unsigned int*)h_result, (unsigned int*)d_result,
            width * height * sizeof(unsigned int), cudaMemcpyDeviceToHost);

        print_binary(h_result);
        print_binary((unsigned char*)h_result);
        
        sdkSavePPM4ub("cat-out.ppm", (unsigned char*)h_result, width,
            height);

    free(h_result);
    checkCudaErrors(cudaFree(d_result));

    return nTotalErrors;
}

void loadImageData()
{
    h_img = (unsigned int*)malloc(width * height * sizeof(unsigned int));
    sdkLoadPPM4ub("cat-in.ppm", (unsigned char**)&h_img, &width, &height);
}



////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////
int main() {
    char* ref_file = NULL;

    // start logs
    printf("Starting...\n\n");

    // use command-line specified CUDA device, otherwise use device with highest
    // Gflops/s
    loadImageData();
    // load image to process
    //runBenchmark();
    runSingleTest();
}
