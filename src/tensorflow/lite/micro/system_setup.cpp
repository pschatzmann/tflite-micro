#include "tensorflow/lite/micro/system_setup.h"

#include <stdarg.h>
#include <stdio.h>

#include "Arduino.h"
#include "tensorflow/lite/micro/debug_log.h"

// Some cores (e.g. Arduino DUE) use a different object for the monitor port.
#if defined(__SAM3X8E__)
#define DEBUG_SERIAL_OBJECT (SerialUSB)
#else
#define DEBUG_SERIAL_OBJECT (Serial)
#endif

// The Arduino ESP32 core links its own TFLM (esp-tflite-micro), which already
// defines DebugLog(); defining it again fails with a multiple definition error.
#if !defined(ARDUINO_ARCH_ESP32)
extern "C" void DebugLog(const char* format, va_list args) {
  char buffer[256];
  vsnprintf(buffer, sizeof(buffer), format, args);
  DEBUG_SERIAL_OBJECT.print(buffer);
}
#endif

namespace tflite {

constexpr unsigned long kSerialMaxInitWait = 4000;  // milliseconds

void InitializeTarget() {
  DEBUG_SERIAL_OBJECT.begin(115200);
  unsigned long start_time = millis();
  while (!DEBUG_SERIAL_OBJECT) {
    if (millis() - start_time > kSerialMaxInitWait) {
      break;
    }
  }
}

}  // namespace tflite
