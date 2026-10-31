# Supported platforms

TFLM requires **C++17**: current upstream uses features such as `auto` template parameters and `std::is_integral_v`. A library cannot change a core's compiler flags, so whether it builds depends on the `-std` flag the core uses (`-std=gnu++17` or newer). The boards in [platforms.txt](../scripts/platforms.txt) are the ones the compile test builds.

| Core | C++ standard | Status |
|---|---|---|
| `arduino:renesas_uno` 1.6.0 (UNO R4) | gnu++17 | **Tested**: `hello_world` builds for `unor4wifi` (89 KB flash, 10 KB RAM) |
| `rp2040:rp2040` (Raspberry Pi Pico) | gnu++17 | **Tested**: `hello_world` builds for `rpipico` (86 KB flash, 12 KB RAM) |
| `esp32:esp32` 3.3.12 (Espressif core) | gnu++2b | **Builds**: `hello_world` for `esp32s3` and `esp32` (checked by hand, not in the default test list because the core is about 3 GB). The core also has its own built-in TFLM, see [ESP32](esp32.md) |
| `arduino:mbed_nano` | gnu++14 | **Does not build** (`'auto' parameter not permitted`, `std::is_integral_v` missing) |
| `arduino:samd` | gnu++11 | **Does not build** (same errors) |
| AVR cores | gnu++11 or older | Not supported (compiler too old, and models do not fit in memory) |

To test another board, add its FQBN to `scripts/platforms.txt`, its core to `scripts/cores.txt`, and its board index URL to `scripts/docker/Dockerfile.test`. Boards also need enough flash and RAM for the model you use; `hello_world` takes about 86 KB of flash and 12 KB of RAM on the Pico.
