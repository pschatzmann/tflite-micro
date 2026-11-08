// Desktop implementation of the DebugVsnprintf() hook that micro_log.cpp
// needs. On Arduino, the core's TFLM build provides it; on desktop, use stdio.
#include <cstdarg>
#include <cstdio>

#include "tensorflow/lite/micro/debug_log.h"

extern "C" int DebugVsnprintf(char* buffer, size_t buf_size,
                              const char* format, va_list vlist) {
  return std::vsnprintf(buffer, buf_size, format, vlist);
}
