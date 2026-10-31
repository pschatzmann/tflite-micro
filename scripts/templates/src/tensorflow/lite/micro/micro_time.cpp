#include "tensorflow/lite/micro/micro_time.h"

#include "Arduino.h"

namespace tflite {
namespace micro {

uint32_t ticks_per_second() { return 1000000; }

uint32_t GetCurrentTimeTicks() { return micros(); }

}  // namespace micro
}  // namespace tflite
