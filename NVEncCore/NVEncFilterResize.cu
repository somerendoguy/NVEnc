﻿// -----------------------------------------------------------------------------------------
// NVEnc by rigaya
// -----------------------------------------------------------------------------------------
//
// The MIT License
//
// Copyright (c) 2014-2016 rigaya
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// ------------------------------------------------------------------------------------------

#include <map>
#include <array>
#include "convert_csp.h"
#include "NVEncFilter.h"
#include "NVEncParam.h"
#pragma warning (push)
#pragma warning (disable: 4819)
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#pragma warning (pop)

#if defined(_WIN32) || defined(_WIN64)
#if __CUDACC_VER_MAJOR__ == 8
const TCHAR *NPPI_DLL_NAME_TSTR = _T("nppc64_80.dll");
#elif __CUDACC_VER_MAJOR__ == 9 && __CUDACC_VER_MINOR__ == 0
const TCHAR *NPPI_DLL_NAME_TSTR = _T("nppc64_90.dll");
#elif __CUDACC_VER_MAJOR__ == 9 && __CUDACC_VER_MINOR__ == 1
const TCHAR *NPPI_DLL_NAME_TSTR = _T("nppc64_91.dll");
#elif __CUDACC_VER_MAJOR__ == 9 && __CUDACC_VER_MINOR__ == 2
const TCHAR *NPPI_DLL_NAME_TSTR = _T("nppc64_92.dll");
#elif __CUDACC_VER_MAJOR__ == 10
const TCHAR *NPPI_DLL_NAME_TSTR = _T("nppc64_10.dll");
#elif __CUDACC_VER_MAJOR__ == 11
const TCHAR *NPPI_DLL_NAME_TSTR = _T("nppc64_11.dll");
#endif

#if __CUDACC_VER_MAJOR__ == 8
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_80.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_80.dll");
#elif __CUDACC_VER_MAJOR__ == 9 && __CUDACC_VER_MINOR__ == 0
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_90.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_90.dll");
#elif __CUDACC_VER_MAJOR__ == 9 && __CUDACC_VER_MINOR__ == 1
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_91.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_91.dll");
#elif __CUDACC_VER_MAJOR__ == 9 && __CUDACC_VER_MINOR__ == 2
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_92.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_92.dll");
#elif __CUDACC_VER_MAJOR__ == 10 && __CUDACC_VER_MINOR__ == 0
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_100_0.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_100.dll");
#elif __CUDACC_VER_MAJOR__ == 10 && __CUDACC_VER_MINOR__ == 1
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_101_0.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_101.dll");
#elif __CUDACC_VER_MAJOR__ == 10 && __CUDACC_VER_MINOR__ == 2
const TCHAR* NVRTC_DLL_NAME_TSTR = _T("nvrtc64_102_0.dll");
const TCHAR* NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_102.dll");
#elif __CUDACC_VER_MAJOR__ == 11 && __CUDACC_VER_MINOR__ == 0
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_110_0.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_110.dll");
#elif __CUDACC_VER_MAJOR__ == 11 && __CUDACC_VER_MINOR__ == 1
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_111_0.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_111.dll");
#elif __CUDACC_VER_MAJOR__ == 11 && __CUDACC_VER_MINOR__ == 2
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_112_0.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_112.dll");
#elif __CUDACC_VER_MAJOR__ == 11 && __CUDACC_VER_MINOR__ == 3
const TCHAR *NVRTC_DLL_NAME_TSTR = _T("nvrtc64_113_0.dll");
const TCHAR *NVRTC_BUILTIN_DLL_NAME_TSTR = _T("nvrtc-builtins64_113.dll");
#endif
#else //#if defined(_WIN32) || defined(_WIN64)
const TCHAR* NPPI_DLL_NAME_TSTR = _T("libnppc.so");
const TCHAR* NVRTC_DLL_NAME_TSTR = _T("libnvrtc.so");
const TCHAR* NVRTC_BUILTIN_DLL_NAME_TSTR = _T("");
#endif //#if defined(_WIN32) || defined(_WIN64)


#if (!defined(_M_IX86))
static const auto RGY_VPP_RESIZE_ALGO_TO_NPPI = make_array<std::pair<RGY_VPP_RESIZE_ALGO, NppiInterpolationMode>>(
    std::make_pair(RGY_VPP_RESIZE_NPPI_INTER_NN,                 NPPI_INTER_NN),
    std::make_pair(RGY_VPP_RESIZE_NPPI_INTER_LINEAR,             NPPI_INTER_LINEAR),
    std::make_pair(RGY_VPP_RESIZE_NPPI_INTER_CUBIC,              NPPI_INTER_CUBIC),
    std::make_pair(RGY_VPP_RESIZE_NPPI_INTER_CUBIC2P_BSPLINE,    NPPI_INTER_CUBIC2P_BSPLINE),
    std::make_pair(RGY_VPP_RESIZE_NPPI_INTER_CUBIC2P_CATMULLROM, NPPI_INTER_CUBIC2P_CATMULLROM),
    std::make_pair(RGY_VPP_RESIZE_NPPI_INTER_CUBIC2P_B05C03,     NPPI_INTER_CUBIC2P_B05C03),
    std::make_pair(RGY_VPP_RESIZE_NPPI_INTER_SUPER,              NPPI_INTER_SUPER),
    std::make_pair(RGY_VPP_RESIZE_NPPI_INTER_LANCZOS,            NPPI_INTER_LANCZOS),
    std::make_pair(RGY_VPP_RESIZE_NPPI_INTER_LANCZOS3_ADVANCED,  NPPI_INTER_LANCZOS3_ADVANCED),
    std::make_pair(RGY_VPP_RESIZE_NPPI_SMOOTH_EDGE,              NPPI_SMOOTH_EDGE)
    );

MAP_PAIR_0_1(vpp_resize_algo, rgy, RGY_VPP_RESIZE_ALGO, enc, NppiInterpolationMode, RGY_VPP_RESIZE_ALGO_TO_NPPI, RGY_VPP_RESIZE_UNKNOWN, NPPI_INTER_UNDEFINED);
#endif

template<typename TypePixel>
cudaError_t setTexFieldResize(cudaTextureObject_t& texSrc, const RGYFrameInfo* pFrame, cudaTextureFilterMode filterMode, cudaTextureReadMode readMode, int normalizedCord) {
    texSrc = 0;

    cudaResourceDesc resDescSrc;
    memset(&resDescSrc, 0, sizeof(resDescSrc));
    resDescSrc.resType = cudaResourceTypePitch2D;
    resDescSrc.res.pitch2D.desc = cudaCreateChannelDesc<TypePixel>();
    resDescSrc.res.pitch2D.pitchInBytes = pFrame->pitch;
    resDescSrc.res.pitch2D.width = pFrame->width;
    resDescSrc.res.pitch2D.height = pFrame->height;
    resDescSrc.res.pitch2D.devPtr = (uint8_t*)pFrame->ptr;

    cudaTextureDesc texDescSrc;
    memset(&texDescSrc, 0, sizeof(texDescSrc));
    texDescSrc.addressMode[0]   = cudaAddressModeClamp;
    texDescSrc.addressMode[1]   = cudaAddressModeClamp;
    texDescSrc.filterMode       = filterMode;
    texDescSrc.readMode         = readMode;
    texDescSrc.normalizedCoords = normalizedCord;

    return cudaCreateTextureObject(&texSrc, &resDescSrc, &texDescSrc, nullptr);
}

template<typename Type, int bit_depth>
__global__ void kernel_resize_texture(uint8_t *__restrict__ pDst, const int dstPitch, const int dstWidth, const int dstHeight,
    cudaTextureObject_t texObj,
    const float ratioX, const float ratioY) {
    const int ix = blockIdx.x * blockDim.x + threadIdx.x;
    const int iy = blockIdx.y * blockDim.y + threadIdx.y;
    if (ix < dstWidth && iy < dstHeight) {
        const float x = (float)ix + 0.5f;
        const float y = (float)iy + 0.5f;

        Type *ptr = (Type *)(pDst + iy * dstPitch + ix * sizeof(Type));
        ptr[0] = (Type)(tex2D<float>(texObj, x * ratioX, y * ratioY) * (float)((1<<bit_depth)-1));
    }
}

template<typename Type, int bit_depth>
void resize_texture(uint8_t *pDst, const int dstPitch, const int dstWidth, const int dstHeight, cudaTextureObject_t texObj, const float ratioX, const float ratioY, cudaStream_t stream) {
    dim3 blockSize(32, 8);
    dim3 gridSize(divCeil(dstWidth, blockSize.x), divCeil(dstHeight, blockSize.y));
    kernel_resize_texture<Type, bit_depth><<<gridSize, blockSize, 0, stream>>>(pDst, dstPitch, dstWidth, dstHeight, texObj, ratioX, ratioY);
}

template<typename Type, int bit_depth>
cudaError_t resize_texture_plane(RGYFrameInfo *pOutputFrame, const RGYFrameInfo *pInputFrame, RGY_VPP_RESIZE_ALGO interp, cudaStream_t stream) {
    const float ratioX = 1.0f / (float)(pOutputFrame->width);
    const float ratioY = 1.0f / (float)(pOutputFrame->height);

    cudaTextureObject_t texSrc = 0;
    auto cudaerr = cudaSuccess;
    if ((cudaerr = setTexFieldResize<Type>(texSrc, pInputFrame, (interp == RGY_VPP_RESIZE_BILINEAR) ? cudaFilterModeLinear : cudaFilterModePoint, cudaReadModeNormalizedFloat, 1)) != cudaSuccess) {
        return cudaerr;
    }
    resize_texture<Type, bit_depth>((uint8_t *)pOutputFrame->ptr,
        pOutputFrame->pitch, pOutputFrame->width, pOutputFrame->height,
        texSrc, ratioX, ratioY, stream);
    cudaerr = cudaGetLastError();
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    cudaerr = cudaDestroyTextureObject(texSrc);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    return cudaerr;
}

template<typename Type, int bit_depth>
static cudaError_t resize_texture_frame(RGYFrameInfo* pOutputFrame, const RGYFrameInfo* pInputFrame, RGY_VPP_RESIZE_ALGO interp, cudaStream_t stream) {
    const auto planeSrcY = getPlane(pInputFrame, RGY_PLANE_Y);
    const auto planeSrcU = getPlane(pInputFrame, RGY_PLANE_U);
    const auto planeSrcV = getPlane(pInputFrame, RGY_PLANE_V);
    const auto planeSrcA = getPlane(pInputFrame, RGY_PLANE_A);
    auto planeOutputY = getPlane(pOutputFrame, RGY_PLANE_Y);
    auto planeOutputU = getPlane(pOutputFrame, RGY_PLANE_U);
    auto planeOutputV = getPlane(pOutputFrame, RGY_PLANE_V);
    auto planeOutputA = getPlane(pOutputFrame, RGY_PLANE_A);

    auto cudaerr = resize_texture_plane<Type, bit_depth>(&planeOutputY, &planeSrcY, interp, stream);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    cudaerr = resize_texture_plane<Type, bit_depth>(&planeOutputU, &planeSrcU, interp, stream);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    cudaerr = resize_texture_plane<Type, bit_depth>(&planeOutputV, &planeSrcV, interp, stream);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    if (planeOutputA.ptr != nullptr) {
        cudaerr = resize_texture_plane<Type, bit_depth>(&planeOutputA, &planeSrcA, interp, stream);
        if (cudaerr != cudaSuccess) {
            return cudaerr;
        }
    }
    return cudaerr;
}

template<typename Type, int bit_depth, int radius, int block_x, int block_y>
__global__ void kernel_resize_spline(uint8_t *__restrict__ pDst, const int dstPitch, const int dstWidth, const int dstHeight,
    cudaTextureObject_t texObj,
    const float ratioX, const float ratioY, const float ratioDistX, const float ratioDistY, const float *__restrict__ pgFactor) {
    const int ix = blockIdx.x * block_x + threadIdx.x;
    const int iy = blockIdx.y * block_y + threadIdx.y;

    //重みをsharedメモリにコピー
    __shared__ float psCopyFactor[radius][4];
    static_assert(radius * 4 < block_x, "radius * 4 < block_x");
    if (threadIdx.y == 0 && threadIdx.x < radius * 4) {
        ((float *)psCopyFactor[0])[threadIdx.x] = pgFactor[threadIdx.x];
    }
    __syncthreads();

    if (ix < dstWidth && iy < dstHeight) {
        //ピクセルの中心を算出してからスケール
        const float x = ((float)ix + 0.5f) * ratioX;
        const float y = ((float)iy + 0.5f) * ratioY;

        float pWeightX[radius * 2];
        float pWeightY[radius * 2];

        #pragma unroll
        for (int i = 0; i < radius * 2; i++) {
            //+0.5fはピクセル中心とするため
            const float sx = floorf(x) + i - radius + 1.0f + 0.5f;
            const float sy = floorf(y) + i - radius + 1.0f + 0.5f;
            //拡大ならratioDistXは1.0f、縮小ならratioの逆数(縮小側の距離に変換)
            const float dx = std::abs(sx - x) * ratioDistX;
            const float dy = std::abs(sy - y) * ratioDistY;
            float *psWeightX = psCopyFactor[min((int)dx, radius-1)];
            float *psWeightY = psCopyFactor[min((int)dy, radius-1)];
            //重みを計算
            float wx = psWeightX[3];
            float wy = psWeightY[3];
            wx += dx * psWeightX[2];
            wy += dy * psWeightY[2];
            const float dx2 = dx * dx;
            const float dy2 = dy * dy;
            wx += dx2 * psWeightX[1];
            wy += dy2 * psWeightY[1];
            wx += dx2 * dx * psWeightX[0];
            wy += dy2 * dy * psWeightY[0];
            pWeightX[i] = wx;
            pWeightY[i] = wy;
        }

        float weightSum = 0.0f;
        float clr = 0.0f;
        for (int j = 0; j < radius * 2; j++) {
            const float sy = floorf(y) + j - radius + 1.0f + 0.5f;
            const float weightY = pWeightY[j];
            #pragma unroll
            for (int i = 0; i < radius * 2; i++) {
                const float sx = floorf(x) + i - radius + 1.0f + 0.5f;
                const float weightXY = pWeightX[i] * weightY;
                clr += tex2D<float>(texObj, sx, sy) * weightXY;
                weightSum += weightXY;
            }
        }

        Type *ptr = (Type *)(pDst + iy * dstPitch + ix * sizeof(Type));
        ptr[0] = (Type)clamp(clr * __frcp_rn(weightSum) * (1<<bit_depth), 0.0f, (1<<bit_depth) - 0.1f);
    }
}

template<typename Type, int bit_depth, int radius>
void resize_spline(uint8_t *pDst, const int dstPitch, const int dstWidth, const int dstHeight,
    cudaTextureObject_t texObj, const float ratioX, const float ratioY, const float ratioDistX, const float ratioDistY, const float *pgFactor, cudaStream_t stream) {
    const int BLOCK_X = 32;
    const int BLOCK_Y = 8;
    dim3 blockSize(BLOCK_X, BLOCK_Y);
    dim3 gridSize(divCeil(dstWidth, blockSize.x), divCeil(dstHeight, blockSize.y));
    kernel_resize_spline<Type, bit_depth, radius, BLOCK_X, BLOCK_Y><<<gridSize, blockSize, 0, stream>>>(
        pDst, dstPitch, dstWidth, dstHeight, texObj, ratioX, ratioY, ratioDistX, ratioDistY, pgFactor);
}

template<typename Type, int bit_depth, int radius>
static cudaError_t resize_spline_plane(RGYFrameInfo *pOutputFrame, const RGYFrameInfo *pInputFrame, const float *pgFactor, cudaStream_t stream) {
    const float ratioX = pInputFrame->width / (float)(pOutputFrame->width);
    const float ratioY = pInputFrame->height / (float)(pOutputFrame->height);
    const float ratioDistX = (pInputFrame->width <= pOutputFrame->width) ? 1.0f : pOutputFrame->width / (float)(pInputFrame->width);
    const float ratioDistY = (pInputFrame->height <= pOutputFrame->height) ? 1.0f : pOutputFrame->height / (float)(pInputFrame->height);

    cudaTextureObject_t texSrc = 0;
    auto cudaerr = cudaSuccess;
    if ((cudaerr = setTexFieldResize<Type>(texSrc, pInputFrame, cudaFilterModePoint, cudaReadModeNormalizedFloat, 0)) != cudaSuccess) {
        return cudaerr;
    }
    resize_spline<Type, bit_depth, radius>((uint8_t *)pOutputFrame->ptr,
        pOutputFrame->pitch, pOutputFrame->width, pOutputFrame->height,
        texSrc, ratioX, ratioY, ratioDistX, ratioDistY, pgFactor, stream);
    cudaerr = cudaGetLastError();
    cudaDestroyTextureObject(texSrc);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    return cudaerr;
}

template<typename Type, int bit_depth, int radius>
static cudaError_t resize_spline_frame(RGYFrameInfo* pOutputFrame, const RGYFrameInfo* pInputFrame, const float* pgFactor, cudaStream_t stream) {
    const auto planeSrcY = getPlane(pInputFrame, RGY_PLANE_Y);
    const auto planeSrcU = getPlane(pInputFrame, RGY_PLANE_U);
    const auto planeSrcV = getPlane(pInputFrame, RGY_PLANE_V);
    const auto planeSrcA = getPlane(pInputFrame, RGY_PLANE_A);
    auto planeOutputY = getPlane(pOutputFrame, RGY_PLANE_Y);
    auto planeOutputU = getPlane(pOutputFrame, RGY_PLANE_U);
    auto planeOutputV = getPlane(pOutputFrame, RGY_PLANE_V);
    auto planeOutputA = getPlane(pOutputFrame, RGY_PLANE_A);

    auto cudaerr = resize_spline_plane<Type, bit_depth, radius>(&planeOutputY, &planeSrcY, pgFactor, stream);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    cudaerr = resize_spline_plane<Type, bit_depth, radius>(&planeOutputU, &planeSrcU, pgFactor, stream);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    cudaerr = resize_spline_plane<Type, bit_depth, radius>(&planeOutputV, &planeSrcV, pgFactor, stream);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    if (planeOutputA.ptr != nullptr) {
        cudaerr = resize_spline_plane<Type, bit_depth, radius>(&planeOutputA, &planeSrcA, pgFactor, stream);
        if (cudaerr != cudaSuccess) {
            return cudaerr;
        }
    }
    return cudaerr;
}

template<int radius>
__inline__ __device__
float lanczos_factor(float x) {
    const float pi = (float)M_PI;
    if (x == 0.0f) return 1.0f;
    if (x >= (float)radius) return 0.0f;
    const float pi_x = pi * x;
    return (float)radius * __sinf(pi_x) * __sinf(pi_x * (1.0f / (float)radius)) * __frcp_rn(pi_x * pi_x);
}

template<typename Type, int bit_depth, int radius, int block_x, int block_y>
__global__ void kernel_resize_lanczos(uint8_t* __restrict__ pDst, const int dstPitch, const int dstWidth, const int dstHeight,
    cudaTextureObject_t texObj,
    const float ratioX, const float ratioY, const float ratioDistX, const float ratioDistY) {
    const int ix = blockIdx.x * block_x + threadIdx.x;
    const int iy = blockIdx.y * block_y + threadIdx.y;

    if (ix < dstWidth && iy < dstHeight) {
        //ピクセルの中心を算出してからスケール
        const float x = ((float)ix + 0.5f) * ratioX;
        const float y = ((float)iy + 0.5f) * ratioY;

        float pWeightX[radius * 2];
        float pWeightY[radius * 2];

        #pragma unroll
        for (int i = 0; i < radius * 2; i++) {
            //+0.5fはピクセル中心とするため
            const float sx = floorf(x) + i - radius + 1.0f + 0.5f;
            const float sy = floorf(y) + i - radius + 1.0f + 0.5f;
            //拡大ならratioDistXは1.0f、縮小ならratioの逆数(縮小側の距離に変換)
            const float dx = std::abs(sx - x) * ratioDistX;
            const float dy = std::abs(sy - y) * ratioDistY;
            pWeightX[i] = lanczos_factor<radius>(dx);
            pWeightY[i] = lanczos_factor<radius>(dy);
        }

        float weightSum = 0.0f;
        float clr = 0.0f;
        for (int j = 0; j < radius * 2; j++) {
            const float sy = floorf(y) + j - radius + 1.0f + 0.5f;
            const float weightY = pWeightY[j];
            #pragma unroll
            for (int i = 0; i < radius * 2; i++) {
                const float sx = floorf(x) + i - radius + 1.0f + 0.5f;
                const float weightXY = pWeightX[i] * weightY;
                clr += tex2D<float>(texObj, sx, sy) * weightXY;
                weightSum += weightXY;
            }
        }

        Type* ptr = (Type*)(pDst + iy * dstPitch + ix * sizeof(Type));
        ptr[0] = (Type)clamp(clr * __frcp_rn(weightSum) * (1<<bit_depth), 0.0f, (1<<bit_depth) - 0.1f);
    }
}

template<typename Type, int bit_depth, int radius>
void resize_lanczos(uint8_t* pDst, const int dstPitch, const int dstWidth, const int dstHeight,
    cudaTextureObject_t texObj, const float ratioX, const float ratioY, const float ratioDistX, const float ratioDistY, cudaStream_t stream) {
    const int BLOCK_X = 32;
    const int BLOCK_Y = 8;
    dim3 blockSize(BLOCK_X, BLOCK_Y);
    dim3 gridSize(divCeil(dstWidth, blockSize.x), divCeil(dstHeight, blockSize.y));
    kernel_resize_lanczos<Type, bit_depth, radius, BLOCK_X, BLOCK_Y><<<gridSize, blockSize, 0, stream>>>(
        pDst, dstPitch, dstWidth, dstHeight, texObj, ratioX, ratioY, ratioDistX, ratioDistY);
}

template<typename Type, int bit_depth, int radius>
static cudaError_t resize_lanczos_plane(RGYFrameInfo* pOutputFrame, const RGYFrameInfo* pInputFrame, cudaStream_t stream) {
    const float ratioX = pInputFrame->width / (float)(pOutputFrame->width);
    const float ratioY = pInputFrame->height / (float)(pOutputFrame->height);
    const float ratioDistX = (pInputFrame->width <= pOutputFrame->width) ? 1.0f : pOutputFrame->width / (float)(pInputFrame->width);
    const float ratioDistY = (pInputFrame->height <= pOutputFrame->height) ? 1.0f : pOutputFrame->height / (float)(pInputFrame->height);

    cudaTextureObject_t texSrc = 0;
    auto cudaerr = cudaSuccess;
    if ((cudaerr = setTexFieldResize<Type>(texSrc, pInputFrame, cudaFilterModePoint, cudaReadModeNormalizedFloat, 0)) != cudaSuccess) {
        return cudaerr;
    }
    resize_lanczos<Type, bit_depth, radius>((uint8_t*)pOutputFrame->ptr,
        pOutputFrame->pitch, pOutputFrame->width, pOutputFrame->height,
        texSrc, ratioX, ratioY, ratioDistX, ratioDistY, stream);
    cudaerr = cudaGetLastError();
    cudaDestroyTextureObject(texSrc);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    return cudaerr;
}

template<typename Type, int bit_depth, int radius>
static cudaError_t resize_lanczos_frame(RGYFrameInfo* pOutputFrame, const RGYFrameInfo* pInputFrame, cudaStream_t stream) {
    const auto planeSrcY = getPlane(pInputFrame, RGY_PLANE_Y);
    const auto planeSrcU = getPlane(pInputFrame, RGY_PLANE_U);
    const auto planeSrcV = getPlane(pInputFrame, RGY_PLANE_V);
    const auto planeSrcA = getPlane(pInputFrame, RGY_PLANE_A);
    auto planeOutputY = getPlane(pOutputFrame, RGY_PLANE_Y);
    auto planeOutputU = getPlane(pOutputFrame, RGY_PLANE_U);
    auto planeOutputV = getPlane(pOutputFrame, RGY_PLANE_V);
    auto planeOutputA = getPlane(pOutputFrame, RGY_PLANE_A);

    auto cudaerr = resize_lanczos_plane<Type, bit_depth, radius>(&planeOutputY, &planeSrcY, stream);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    cudaerr = resize_lanczos_plane<Type, bit_depth, radius>(&planeOutputU, &planeSrcU, stream);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    cudaerr = resize_lanczos_plane<Type, bit_depth, radius>(&planeOutputV, &planeSrcV, stream);
    if (cudaerr != cudaSuccess) {
        return cudaerr;
    }
    if (planeOutputA.ptr != nullptr) {
        cudaerr = resize_lanczos_plane<Type, bit_depth, radius>(&planeOutputA, &planeSrcA, stream);
        if (cudaerr != cudaSuccess) {
            return cudaerr;
        }
    }
    return cudaerr;
}

template<typename Type, int bit_depth>
static cudaError_t resize_frame(RGYFrameInfo *pOutputFrame, const RGYFrameInfo *pInputFrame, RGY_VPP_RESIZE_ALGO interp, const float *pgFactor, cudaStream_t stream) {
    switch (interp) {
    case RGY_VPP_RESIZE_BILINEAR:
    case RGY_VPP_RESIZE_NEAREST: return resize_texture_frame<Type, bit_depth>(pOutputFrame, pInputFrame, interp, stream);
    case RGY_VPP_RESIZE_SPLINE16: return resize_spline_frame<Type, bit_depth, 2>(pOutputFrame, pInputFrame, pgFactor, stream);
    case RGY_VPP_RESIZE_SPLINE36: return resize_spline_frame<Type, bit_depth, 3>(pOutputFrame, pInputFrame, pgFactor, stream);
    case RGY_VPP_RESIZE_SPLINE64: return resize_spline_frame<Type, bit_depth, 4>(pOutputFrame, pInputFrame, pgFactor, stream);
    case RGY_VPP_RESIZE_LANCZOS2: return resize_lanczos_frame<Type, bit_depth, 2>(pOutputFrame, pInputFrame, stream);
    case RGY_VPP_RESIZE_LANCZOS3: return resize_lanczos_frame<Type, bit_depth, 3>(pOutputFrame, pInputFrame, stream);
    case RGY_VPP_RESIZE_LANCZOS4: return resize_lanczos_frame<Type, bit_depth, 4>(pOutputFrame, pInputFrame, stream);
    default:  return cudaErrorUnknown;
    }
}

template<typename T, typename Tfunc>
static NppStatus resize_nppi_yv12(RGYFrameInfo *pOutputFrame, const RGYFrameInfo *pInputFrame, Tfunc funcResize, NppiInterpolationMode interpMode) {
    const double factorX = pOutputFrame->width / (double)pInputFrame->width;
    const double factorY = pOutputFrame->height / (double)pInputFrame->height;
    auto srcSize = nppisize(pInputFrame);
    auto srcRect = nppiroi(pInputFrame);
    auto dstRect = nppiroi(pOutputFrame);
    const auto planeSrcY = getPlane(pInputFrame, RGY_PLANE_Y);
    const auto planeSrcU = getPlane(pInputFrame, RGY_PLANE_U);
    const auto planeSrcV = getPlane(pInputFrame, RGY_PLANE_V);
    auto planeOutputY = getPlane(pOutputFrame, RGY_PLANE_Y);
    auto planeOutputU = getPlane(pOutputFrame, RGY_PLANE_U);
    auto planeOutputV = getPlane(pOutputFrame, RGY_PLANE_V);
    //Y
    NppStatus sts = funcResize(
        (const T *)planeSrcY.ptr,
        srcSize, planeSrcY.pitch, srcRect,
        (T *)planeOutputY.ptr,
        planeOutputY.pitch, dstRect,
        factorX, factorY, 0.0, 0.0, interpMode);
    if (sts != NPP_SUCCESS) {
        return sts;
    }
    //U
    srcSize.width  >>= 1;
    srcSize.height >>= 1;
    srcRect.width  >>= 1;
    srcRect.height >>= 1;
    dstRect.width  >>= 1;
    dstRect.height >>= 1;
    sts = funcResize(
        (const T *)planeSrcU.ptr,
        srcSize, planeSrcU.pitch, srcRect,
        (T *)planeOutputU.ptr,
        planeOutputU.pitch, dstRect,
        factorX, factorY, 0.0, 0.0, interpMode);
    if (sts != NPP_SUCCESS) {
        return sts;
    }
    //V
    sts = funcResize(
        (const T *)planeSrcV.ptr,
        srcSize, planeSrcV.pitch, srcRect,
        (T *)planeOutputV.ptr,
        planeOutputV.pitch, dstRect,
        factorX, factorY, 0.0, 0.0, interpMode);
    return sts;
}

RGY_ERR NVEncFilterResize::resizeNppiYV12(RGYFrameInfo *pOutputFrame, const RGYFrameInfo *pInputFrame) {
#if _M_IX86
    AddMessage(RGY_LOG_ERROR, _T("npp filter not supported on x86.\n"));
    return RGY_ERR_UNSUPPORTED;
#else
    RGY_ERR sts = RGY_ERR_NONE;
    if (m_pParam->frameOut.csp != m_pParam->frameIn.csp) {
        AddMessage(RGY_LOG_ERROR, _T("csp does not match.\n"));
        return RGY_ERR_INVALID_PARAM;
    }
    auto pResizeParam = std::dynamic_pointer_cast<NVEncFilterParamResize>(m_pParam);
    if (!pResizeParam) {
        AddMessage(RGY_LOG_ERROR, _T("Invalid parameter type.\n"));
        return RGY_ERR_INVALID_PARAM;
    }
    const auto interp = vpp_resize_algo_rgy_to_enc(pResizeParam->interp);
    if (interp == NPPI_INTER_UNDEFINED) {
        AddMessage(RGY_LOG_ERROR, _T("Unknown nppi interp mode: %d.\n"), (int)pResizeParam->interp);
        return RGY_ERR_UNSUPPORTED;
    }
    static const auto supportedCspYV12High = make_array<RGY_CSP>(RGY_CSP_YV12_09, RGY_CSP_YV12_10, RGY_CSP_YV12_12, RGY_CSP_YV12_14, RGY_CSP_YV12_16);
    NppStatus nppsts = NPP_SUCCESS;
    if (m_pParam->frameIn.csp == RGY_CSP_YV12) {
        nppsts = resize_nppi_yv12<Npp8u>(pOutputFrame, pInputFrame, nppiResizeSqrPixel_8u_C1R, interp);
        if (nppsts != NPP_SUCCESS) {
            AddMessage(RGY_LOG_ERROR, _T("failed to resize: %d, %s.\n"), nppsts, char_to_tstring(_cudaGetErrorEnum(nppsts)).c_str());
            sts = RGY_ERR_CUDA;
        }
    } else if (std::find(supportedCspYV12High.begin(), supportedCspYV12High.end(), m_pParam->frameIn.csp) != supportedCspYV12High.end()) {
        nppsts = resize_nppi_yv12<Npp16u>(pOutputFrame, pInputFrame, nppiResizeSqrPixel_16u_C1R, interp);
        if (nppsts != NPP_SUCCESS) {
            AddMessage(RGY_LOG_ERROR, _T("failed to resize: %d, %s.\n"), nppsts, char_to_tstring(_cudaGetErrorEnum(nppsts)).c_str());
            sts = RGY_ERR_CUDA;
        }
    } else {
        AddMessage(RGY_LOG_ERROR, _T("unsupported csp.\n"));
        sts = RGY_ERR_UNSUPPORTED;
    }
    return sts;
#endif
}

template<typename T, typename Tfunc>
static NppStatus resize_nppi_yuv444(RGYFrameInfo *pOutputFrame, const RGYFrameInfo *pInputFrame, Tfunc funcResize, NppiInterpolationMode interpMode) {
    const double factorX = pOutputFrame->width / (double)pInputFrame->width;
    const double factorY = pOutputFrame->height / (double)pInputFrame->height;
    auto srcSize = nppisize(pInputFrame);
    auto srcRect = nppiroi(pInputFrame);
    auto dstRect = nppiroi(pOutputFrame);
    const auto planeSrcY = getPlane(pInputFrame, RGY_PLANE_Y);
    const auto planeSrcU = getPlane(pInputFrame, RGY_PLANE_U);
    const auto planeSrcV = getPlane(pInputFrame, RGY_PLANE_V);
    auto planeOutputY = getPlane(pOutputFrame, RGY_PLANE_Y);
    auto planeOutputU = getPlane(pOutputFrame, RGY_PLANE_U);
    auto planeOutputV = getPlane(pOutputFrame, RGY_PLANE_V);
    const T *pSrc[3] = {
        (const T *)planeSrcY.ptr,
        (const T *)planeSrcU.ptr,
        (const T *)planeSrcV.ptr
    };
    T *pDst[3] = {
        (T *)planeOutputY.ptr,
        (T *)planeOutputU.ptr,
        (T *)planeOutputV.ptr
    };
    NppStatus sts = funcResize(
        pSrc,
        srcSize, planeSrcY.pitch, srcRect,
        pDst,
        planeOutputY.pitch, dstRect,
        factorX, factorY, 0.0, 0.0, interpMode);
    if (sts != NPP_SUCCESS) {
        return sts;
    }
    return sts;
}

RGY_ERR NVEncFilterResize::resizeNppiYUV444(RGYFrameInfo *pOutputFrame, const RGYFrameInfo *pInputFrame) {
#if _M_IX86
    AddMessage(RGY_LOG_ERROR, _T("npp filter not supported on x86.\n"));
    return RGY_ERR_UNSUPPORTED;
#else
    RGY_ERR sts = RGY_ERR_NONE;
    if (m_pParam->frameOut.csp != m_pParam->frameIn.csp) {
        AddMessage(RGY_LOG_ERROR, _T("csp does not match.\n"));
        return RGY_ERR_INVALID_PARAM;
    }
    auto pResizeParam = std::dynamic_pointer_cast<NVEncFilterParamResize>(m_pParam);
    if (!pResizeParam) {
        AddMessage(RGY_LOG_ERROR, _T("Invalid parameter type.\n"));
        return RGY_ERR_INVALID_PARAM;
    }
    const auto interp = vpp_resize_algo_rgy_to_enc(pResizeParam->interp);
    if (interp == NPPI_INTER_UNDEFINED) {
        AddMessage(RGY_LOG_ERROR, _T("Unknown nppi interp mode: %d.\n"), (int)pResizeParam->interp);
        return RGY_ERR_UNSUPPORTED;
    }
    static const auto supportedCspYUV444High = make_array<RGY_CSP>(RGY_CSP_YUV444_09, RGY_CSP_YUV444_10, RGY_CSP_YUV444_12, RGY_CSP_YUV444_14, RGY_CSP_YUV444_16);
    NppStatus nppsts = NPP_SUCCESS;
    if (m_pParam->frameIn.csp == RGY_CSP_YUV444) {
        nppsts = resize_nppi_yuv444<Npp8u>(pOutputFrame, pInputFrame, nppiResizeSqrPixel_8u_P3R, interp);
        if (nppsts != NPP_SUCCESS) {
            AddMessage(RGY_LOG_ERROR, _T("failed to resize: %d, %s.\n"), nppsts, char_to_tstring(_cudaGetErrorEnum(nppsts)).c_str());
            sts = RGY_ERR_CUDA;
        }
    } else if (std::find(supportedCspYUV444High.begin(), supportedCspYUV444High.end(), m_pParam->frameIn.csp) != supportedCspYUV444High.end()) {
        nppsts = resize_nppi_yuv444<Npp16u>(pOutputFrame, pInputFrame, nppiResizeSqrPixel_16u_P3R, interp);
        if (nppsts != NPP_SUCCESS) {
            AddMessage(RGY_LOG_ERROR, _T("failed to resize: %d, %s.\n"), nppsts, char_to_tstring(_cudaGetErrorEnum(nppsts)).c_str());
            sts = RGY_ERR_CUDA;
        }
    } else {
        AddMessage(RGY_LOG_ERROR, _T("unsupported csp.\n"));
        sts = RGY_ERR_UNSUPPORTED;
    }
    return sts;
#endif
}

NVEncFilterResize::NVEncFilterResize() : m_bInterlacedWarn(false) {
    m_sFilterName = _T("resize");
}

NVEncFilterResize::~NVEncFilterResize() {
    close();
}

RGY_ERR NVEncFilterResize::init(shared_ptr<NVEncFilterParam> pParam, shared_ptr<RGYLog> pPrintMes) {
    RGY_ERR sts = RGY_ERR_NONE;
    m_pPrintMes = pPrintMes;
    auto pResizeParam = std::dynamic_pointer_cast<NVEncFilterParamResize>(pParam);
    if (!pResizeParam) {
        AddMessage(RGY_LOG_ERROR, _T("Invalid parameter type.\n"));
        return RGY_ERR_INVALID_PARAM;
    }
#if defined(_WIN32) || defined(_WIN64)
    // linuxではnppは静的リンクにしたので、下記チェックは不要になった
    if (pResizeParam->interp > RGY_VPP_RESIZE_OPENCL_CUDA_MAX && !check_if_nppi_dll_available()) {
        AddMessage(RGY_LOG_WARN, _T("--vpp-resize %s requires \"%s\", not available on your system.\n"), get_chr_from_value(list_vpp_resize, pResizeParam->interp), NPPI_DLL_NAME_TSTR);
        pResizeParam->interp = RGY_VPP_RESIZE_SPLINE36;
        AddMessage(RGY_LOG_WARN, _T("switching to %s."), get_chr_from_value(list_vpp_resize, pResizeParam->interp));
    }
#endif
    //パラメータチェック
    if (pResizeParam->frameOut.height <= 0 || pResizeParam->frameOut.width <= 0) {
        AddMessage(RGY_LOG_ERROR, _T("Invalid parameter.\n"));
        return RGY_ERR_INVALID_PARAM;
    }

    auto cudaerr = AllocFrameBuf(pResizeParam->frameOut, 1);
    if (cudaerr != cudaSuccess) {
        AddMessage(RGY_LOG_ERROR, _T("failed to allocate memory: %s.\n"), char_to_tstring(cudaGetErrorName(cudaerr)).c_str());
        return RGY_ERR_MEMORY_ALLOC;
    }
    pResizeParam->frameOut.pitch = m_pFrameBuf[0]->frame.pitch;

    if (m_weightSpline.ptr == nullptr
        && (pResizeParam->interp == RGY_VPP_RESIZE_SPLINE16 || pResizeParam->interp == RGY_VPP_RESIZE_SPLINE36 || pResizeParam->interp == RGY_VPP_RESIZE_SPLINE64)) {
        static const auto SPLINE16_WEIGHT = std::vector<float>{
            1.0f,       -9.0f/5.0f,  -1.0f/5.0f, 1.0f,
            -1.0f/3.0f,  9.0f/5.0f, -46.0f/15.0f, 8.0f/5.0f
        };
        static const auto SPLINE36_WEIGHT = std::vector<float>{
            13.0f/11.0f, -453.0f/209.0f,    -3.0f/209.0f,  1.0f,
            -6.0f/11.0f,  612.0f/209.0f, -1038.0f/209.0f,  540.0f/209.0f,
             1.0f/11.0f, -159.0f/209.0f,   434.0f/209.0f, -384.0f/209.0f
        };
        static const auto SPLINE64_WEIGHT = std::vector<float>{
             49.0f/41.0f, -6387.0f/2911.0f,     -3.0f/2911.0f,  1.0f,
            -24.0f/41.0f,  9144.0f/2911.0f, -15504.0f/2911.0f,  8064.0f/2911.0f,
              6.0f/41.0f, -3564.0f/2911.0f,   9726.0f/2911.0f, -8604.0f/2911.0f,
             -1.0f/41.0f,   807.0f/2911.0f,  -3022.0f/2911.0f,  3720.0f/2911.0f
        };
        const std::vector<float>* weight = nullptr;
        switch (pResizeParam->interp) {
        case RGY_VPP_RESIZE_SPLINE16: weight = &SPLINE16_WEIGHT; break;
        case RGY_VPP_RESIZE_SPLINE36: weight = &SPLINE36_WEIGHT; break;
        case RGY_VPP_RESIZE_SPLINE64: weight = &SPLINE64_WEIGHT; break;
        default: {
            AddMessage(RGY_LOG_ERROR, _T("unknown interpolation type: %d.\n"), pResizeParam->interp);
            return RGY_ERR_INVALID_PARAM;
        }
        }

        m_weightSpline = CUMemBuf(sizeof((*weight)[0]) * weight->size());
        if (cudaSuccess != (cudaerr = m_weightSpline.alloc())) {
            AddMessage(RGY_LOG_ERROR, _T("failed to allocate memory: %s.\n"), char_to_tstring(cudaGetErrorName(cudaerr)).c_str());
            return RGY_ERR_MEMORY_ALLOC;
        }
        cudaerr = cudaMemcpy(m_weightSpline.ptr, weight->data(), m_weightSpline.nSize, cudaMemcpyHostToDevice);
        if (cudaerr != cudaSuccess) {
            AddMessage(RGY_LOG_ERROR, _T("failed to send weight to gpu memory: %s.\n"), char_to_tstring(cudaGetErrorName(cudaerr)).c_str());
            return RGY_ERR_CUDA;
        }
    }

    setFilterInfo(pResizeParam->print());

    //コピーを保存
    m_pParam = pResizeParam;
    return sts;
}

tstring NVEncFilterParamResize::print() const {
    return strsprintf(_T("resize(%s): %dx%d -> %dx%d"),
        get_chr_from_value(list_vpp_resize, interp),
        frameIn.width, frameIn.height,
        frameOut.width, frameOut.height);
}

RGY_ERR NVEncFilterResize::run_filter(const RGYFrameInfo *pInputFrame, RGYFrameInfo **ppOutputFrames, int *pOutputFrameNum, cudaStream_t stream) {
    RGY_ERR sts = RGY_ERR_NONE;
    if (pInputFrame->ptr == nullptr) {
        return sts;
    }

    *pOutputFrameNum = 1;
    if (ppOutputFrames[0] == nullptr) {
        auto pOutFrame = m_pFrameBuf[m_nFrameIdx].get();
        ppOutputFrames[0] = &pOutFrame->frame;
        m_nFrameIdx = (m_nFrameIdx + 1) % m_pFrameBuf.size();
    }
    ppOutputFrames[0]->picstruct = pInputFrame->picstruct;
    if (interlaced(*pInputFrame)) {
        return filter_as_interlaced_pair(pInputFrame, ppOutputFrames[0], cudaStreamDefault);
    }
    const auto memcpyKind = getCudaMemcpyKind(pInputFrame->deivce_mem, ppOutputFrames[0]->deivce_mem);
    if (memcpyKind != cudaMemcpyDeviceToDevice) {
        AddMessage(RGY_LOG_ERROR, _T("only supported on device memory.\n"));
        return RGY_ERR_UNSUPPORTED;
    }
    if (m_pParam->frameOut.csp != m_pParam->frameIn.csp) {
        AddMessage(RGY_LOG_ERROR, _T("csp does not match.\n"));
        return RGY_ERR_UNSUPPORTED;
    }
    static const auto supportedCspYV12   = make_array<RGY_CSP>(RGY_CSP_YV12, RGY_CSP_YV12_09, RGY_CSP_YV12_10, RGY_CSP_YV12_12, RGY_CSP_YV12_14, RGY_CSP_YV12_16);
    static const auto supportedCspYUV444 = make_array<RGY_CSP>(RGY_CSP_YUV444, RGY_CSP_YUV444_09, RGY_CSP_YUV444_10, RGY_CSP_YUV444_12, RGY_CSP_YUV444_14, RGY_CSP_YUV444_16);

    auto pResizeParam = std::dynamic_pointer_cast<NVEncFilterParamResize>(m_pParam);
    if (!pResizeParam) {
        AddMessage(RGY_LOG_ERROR, _T("Invalid parameter type.\n"));
        return RGY_ERR_INVALID_PARAM;
    }
    if (pResizeParam->interp > RGY_VPP_RESIZE_OPENCL_CUDA_MAX) {
        if (std::find(supportedCspYV12.begin(), supportedCspYV12.end(), m_pParam->frameIn.csp) != supportedCspYV12.end()) {
            sts = resizeNppiYV12(ppOutputFrames[0], pInputFrame);
        } else if (std::find(supportedCspYUV444.begin(), supportedCspYUV444.end(), m_pParam->frameIn.csp) != supportedCspYUV444.end()) {
            sts = resizeNppiYUV444(ppOutputFrames[0], pInputFrame);
        } else {
            AddMessage(RGY_LOG_ERROR, _T("unsupported csp.\n"));
            sts = RGY_ERR_UNSUPPORTED;
        }
    } else {
        static const std::map<RGY_CSP, decltype(resize_frame<uint8_t, 8>)*> resize_list = {
            { RGY_CSP_YV12,       resize_frame<uint8_t,   8> },
            { RGY_CSP_YV12_16,    resize_frame<uint16_t, 16> },
            { RGY_CSP_YUV444,     resize_frame<uint8_t,   8> },
            { RGY_CSP_YUV444_16,  resize_frame<uint16_t, 16> },
            { RGY_CSP_YUVA444,    resize_frame<uint8_t,   8> },
            { RGY_CSP_YUVA444_16, resize_frame<uint16_t, 16> },
        };
        if (resize_list.count(pInputFrame->csp) == 0) {
            AddMessage(RGY_LOG_ERROR, _T("unsupported csp %s.\n"), RGY_CSP_NAMES[pInputFrame->csp]);
            return RGY_ERR_UNSUPPORTED;
        }
        resize_list.at(pInputFrame->csp)(ppOutputFrames[0], pInputFrame, pResizeParam->interp, (float *)m_weightSpline.ptr, cudaStreamDefault);
        auto cudaerr = cudaGetLastError();
        if (cudaerr != cudaSuccess) {
            AddMessage(RGY_LOG_ERROR, _T("error at resize(%s): %s.\n"),
                RGY_CSP_NAMES[pInputFrame->csp],
                char_to_tstring(cudaGetErrorString(cudaerr)).c_str());
            return RGY_ERR_CUDA;
        }
    }
    return sts;
}

void NVEncFilterResize::close() {
    m_pFrameBuf.clear();
    m_bInterlacedWarn = false;
}
