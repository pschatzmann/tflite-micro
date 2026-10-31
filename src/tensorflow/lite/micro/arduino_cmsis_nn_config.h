#ifndef TENSORFLOW_LITE_MICRO_ARDUINO_CMSIS_NN_CONFIG_H_
#define TENSORFLOW_LITE_MICRO_ARDUINO_CMSIS_NN_CONFIG_H_

// Selects the CMSIS-NN optimized kernels at compile time. Upstream enables them
// with a -DCMSIS_NN compiler flag, which an Arduino library cannot pass, so the
// choice is made from the architecture macros of the compiler instead.
//
// CMSIS-NN is used on Arm cores with the DSP extension (Cortex-M4/M7/M33/M35P)
// or the Helium (MVE) extension (Cortex-M55/M85). All other cores, e.g. the
// Cortex-M0+ of the RP2040, ESP32 and AVR, use the reference kernels.
//
// It also needs the ACLE SIMD32 intrinsics (e.g. __sxtb16) in <arm_acle.h>.
// GCC 7 and 9 do not have them (link error: undefined reference to
// `__sxtb16`), GCC 12 does. Versions 10 and 11 are untested, so they are
// excluded; clang is untested too.
#if !defined(CMSIS_NN) &&                                          \
    ((defined(__ARM_FEATURE_DSP) && (__ARM_FEATURE_DSP == 1)) ||    \
     (defined(__ARM_FEATURE_MVE) && (__ARM_FEATURE_MVE & 1))) &&    \
    !defined(__clang__) && defined(__GNUC__) && (__GNUC__ >= 12)
#define CMSIS_NN 1
#endif

#endif  // TENSORFLOW_LITE_MICRO_ARDUINO_CMSIS_NN_CONFIG_H_
