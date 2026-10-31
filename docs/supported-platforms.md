# Supported platforms

TFLM requires **C++17**: current upstream uses features such as `auto` template parameters and `std::is_integral_v`. A library cannot change a core's compiler flags, so whether it builds depends on the `-std` flag the core uses (`-std=gnu++17` or newer). The boards in [platforms.txt](../scripts/platforms.txt) are the ones the compile test builds.

| Core | C++ standard | Status |
|---|---|---|
| `arduino:renesas_uno` 1.6.0 (UNO R4) | gnu++17 | **Tested**: `hello_world` builds for `unor4wifi` (89 KB flash, 10 KB RAM), with the reference kernels |
| `rp2040:rp2040` (Raspberry Pi Pico) | gnu++17 | **Tested**: `hello_world` builds for `rpipico` (86 KB flash, 12 KB RAM, reference kernels) and `rpipico2` (91 KB flash, 13 KB RAM, CMSIS-NN) |
| `arduino:zephyr_main` 1.1.0 (Zephyr based cores) | modern | **Tested**: `hello_world` builds for `nano33ble` (99 KB flash, 38 KB RAM, CMSIS-NN) |
| `esp32:esp32` 3.3.12 (Espressif core) | gnu++2b | **Builds**: `hello_world` for `esp32s3` and `esp32` (checked by hand, not in the default test list because the core is about 3 GB). The core also has its own built-in TFLM, see [ESP32](esp32.md) |
| `arduino:mbed_nano` | gnu++14 | **Does not build** (`'auto' parameter not permitted`, `std::is_integral_v` missing) |
| `arduino:samd` | gnu++11 | **Does not build** (same errors) |
| AVR cores | gnu++11 or older | Not supported (compiler too old, and models do not fit in memory) |

To test another board, install its core with `arduino-cli` and add its FQBN to `scripts/platforms.txt`. Boards also need enough flash and RAM for the model you use; `hello_world` takes about 86 KB of flash and 12 KB of RAM on the Pico.

## Optimized kernels

The library ships the reference kernels, which are correct on every core but the slowest, plus optimized kernels that are selected at compile time:

| Variant | Used on | Status |
|---|---|---|
| Reference kernels | all boards | done |
| [CMSIS-NN](https://github.com/ARM-software/CMSIS-NN) | Arm cores with the DSP or MVE extension (Cortex-M4/M7/M33, M55/M85) **and GCC 12 or newer**: Pico 2, Zephyr Nano 33 BLE | implemented, see below |
| [ESP-NN](https://github.com/espressif/esp-nn) | ESP32 | **not planned**: the ESP32 core already ships TFLM with ESP-NN, see below |

### How CMSIS-NN is selected

Upstream picks kernels when the tree is generated (`OPTIMIZED_KERNEL_DIR`), and the optimized files replace the reference files of the same name. Arduino compiles every file in `src/` and cannot select by architecture, and a library cannot pass compiler flags such as `-DCMSIS_NN`. So:

1. `scripts/tools/generate.sh` generates the reference tree and a second tree with `OPTIMIZED_KERNEL_DIR=cmsis_nn` (listed in `MERGE_KERNEL_DIRS` in `scripts/config.env`). Only `kernels/cmsis_nn/` and `third_party/cmsis_nn/` are copied from the second tree into the first.
2. `scripts/templates/src/tensorflow/lite/micro/arduino_cmsis_nn_config.h` defines `CMSIS_NN` when the compiler reports `__ARM_FEATURE_DSP` or `__ARM_FEATURE_MVE` and is GCC 12 or newer (see below).
3. Patches in `scripts/MANIFEST.ini` wrap the 14 reference kernels in `#if !defined(CMSIS_NN)`, and the 14 CMSIS-NN kernels and all 113 CMSIS-NN C files in `#if defined(CMSIS_NN)`. They also add the config include to the headers that test `CMSIS_NN`, and rewrite the CMSIS-NN sources' bare `#include "arm_*.h"` lines to full paths from `src/`.

CMSIS-NN detects the CPU itself through the same compiler macros, so the separate CMSIS core headers (`third_party/cmsis`) are not needed and are not included.

Not covered by the compile tests:
- **Correct results and speed.** Only compile and link are checked. Nothing has been run on a board, and no speed was measured. I checked which variant each board got by looking for CMSIS-NN symbols (`arm_convolve_*`, `arm_fully_connected_*`) in the linked ELF: present for the Pico 2 and the Zephyr Nano 33 BLE, absent for the Pico and the UNO R4.
- **The Pico (RP2040).** Its Cortex-M0+ has no DSP extension, so it keeps the reference kernels. A Pico 2 (RP2350, Cortex-M33) uses CMSIS-NN.
- **The UNO R4 (Cortex-M4F).** Its core ships GCC 7, whose `arm_acle.h` has no `__sxtb16`; CMSIS-NN failed to link with `undefined reference to __sxtb16`. GCC 9 lacks it too, and GCC 12 has it. The rule therefore requires GCC 12 or newer, GCC 10 and 11 are untested, and the UNO R4 uses the reference kernels.
- **clang.** Excluded from CMSIS-NN because it was not tested.
- **Mixed boards.** A core that reports DSP but whose CMSIS-NN path fails to build would break that board. Each Arm board family needs its own compile test.

### ESP-NN (not planned)

ESP-NN will not be added to this library. The Arduino ESP32 core already ships TFLM (esp-tflite-micro) precompiled together with ESP-NN, so on ESP32 the optimized kernels are available without this library. [ESP32](esp32.md) explains how to use the core's copy. This library still builds on ESP32 with the reference kernels, but there is no plan to optimize it there.

### Risks

- The library grows, because CMSIS-NN adds about 2 MB of sources and every sketch compiles more files.
- Every upstream restructure breaks more manifest patches.
- A wrong guard still compiles but silently selects the wrong kernel.
