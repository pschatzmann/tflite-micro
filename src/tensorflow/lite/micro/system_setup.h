#ifndef TENSORFLOW_LITE_MICRO_SYSTEM_SETUP_H_
#define TENSORFLOW_LITE_MICRO_SYSTEM_SETUP_H_

namespace tflite {

// Called during initialization of TFLM binaries and tests. On Arduino this
// opens the default Serial port used by DebugLog().
void InitializeTarget();

}  // namespace tflite

#endif  // TENSORFLOW_LITE_MICRO_SYSTEM_SETUP_H_
