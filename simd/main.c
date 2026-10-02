#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

// Scalar
void add_arrays_c(float* a, float* b, float* res, int n) {
    for (int i = 0; i < n; i++) {
        res[i] = a[i] + b[i];
    }
}

// AVX
void add_arrays_asm(float* a, float* b, float* res, int n) {
    for (int i = 0; i < n; i += 8) {
        __asm__ volatile (
            "vmovups (%1), %%ymm0 \n\t"
            "vmovups (%2), %%ymm1 \n\t"
            "vaddps %%ymm1, %%ymm0, %%ymm0 \n\t"
            "vmovups %%ymm0, (%0) \n\t"
            :
            : "r" (res + i), "r" (a + i), "r" (b + i)
            : "ymm0", "ymm1", "memory"
        );
    }
}

void usage()
{
    printf("Usage : simd <size of array>");
}

int main(int argc, char** argv) {

    if (argc < 2)
    {
        usage();
        return 1;
    }
    uint64_t n = atoi(argv[1]);
    size_t size = n * sizeof(float);

    float *a   = (float*)aligned_alloc(32, size);
    float *b   = (float*)aligned_alloc(32, size);
    float *res = (float*)aligned_alloc(32, size);

    for (int i = 0; i < n; i++) {
        a[i] = (float)i;
        b[i] = (float)i * 2.0f;
    }

    struct timespec start, end;
    double time_c, time_asm;

    clock_gettime(CLOCK_MONOTONIC, &start);
    add_arrays_c(a, b, res, n);
    clock_gettime(CLOCK_MONOTONIC, &end);
    time_c = (end.tv_sec - start.tv_sec) * 1e6 + (end.tv_nsec - start.tv_nsec) / 1e3;

    clock_gettime(CLOCK_MONOTONIC, &start);
    add_arrays_asm(a, b, res, n);
    clock_gettime(CLOCK_MONOTONIC, &end);
    time_asm = (end.tv_sec - start.tv_sec) * 1e6 + (end.tv_nsec - start.tv_nsec) / 1e3;

    printf("Taille array      : %ld elements\n", n);
    printf("Temps version C   : %.2f microsecondes\n", time_c);
    printf("Temps version ASM : %.2f microsecondes\n", time_asm);
    printf("Acceleration      : x%.2f\n", time_c / time_asm);

    printf("Verification (index 100) : %.1f + %.1f = %.1f\n", a[100], b[100], res[100]);

    free(a); free(b); free(res);
    return 0;
}
