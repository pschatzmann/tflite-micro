// Minimal Arduino API shim for building the library on a desktop host.
// Only used by the CMake build; the Arduino toolchain never sees this file.
#ifndef TFLM_DESKTOP_ARDUINO_H_
#define TFLM_DESKTOP_ARDUINO_H_

#include <chrono>
#include <cstdint>
#include <cstdio>
#include <thread>

namespace tflm_desktop {

class SerialShim {
 public:
  void begin(unsigned long) {}
  operator bool() const { return true; }

  void print(const char* s) { std::fputs(s, stdout); }
  void print(char c) { std::fputc(c, stdout); }
  void print(int v) { std::printf("%d", v); }
  void print(long v) { std::printf("%ld", v); }
  void print(unsigned long v) { std::printf("%lu", v); }
  void print(float v) { std::printf("%g", static_cast<double>(v)); }
  void print(double v) { std::printf("%g", v); }

  void println() { std::fputc('\n', stdout); }
  template <typename T>
  void println(T v) {
    print(v);
    println();
  }
};

inline SerialShim Serial;

inline unsigned long micros() {
  using namespace std::chrono;
  static const auto start = steady_clock::now();
  return static_cast<unsigned long>(
      duration_cast<microseconds>(steady_clock::now() - start).count());
}

inline unsigned long millis() { return micros() / 1000; }

inline void delay(unsigned long ms) {
  std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}

}  // namespace tflm_desktop

using tflm_desktop::Serial;
using tflm_desktop::delay;
using tflm_desktop::micros;
using tflm_desktop::millis;

#endif  // TFLM_DESKTOP_ARDUINO_H_
