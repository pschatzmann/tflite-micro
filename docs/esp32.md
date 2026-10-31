# TensorFlow Lite Micro on ESP32

On ESP32 there are two ways to get TensorFlow Lite Micro (TFLM): the copy built into the Arduino ESP32 core, or this library. This page explains the difference and how to use each.

## The two variants

| | Built into the ESP32 core | This library |
|---|---|---|
| Source | `esp-tflite-micro` from Espressif, shipped inside the core | tflite-micro `main`, generated into `src/` (see [Generating the library](generating.md)) |
| Version | 1.4.0 (core 3.3.12) | the commit recorded in `library.properties` |
| How it is built | precompiled static library, linked by default | compiled from source as part of your sketch |
| Optimized kernels | ESP-NN 1.3.2 (the library references `esp_nn_*_esp32s3` functions) | reference kernels only |
| Install | nothing, it ships with the core | install this library |
| Include in sketch | the `tensorflow/lite/micro/...` headers | `<TensorFlowLite.h>` plus the same headers |
| Other boards | ESP32 only | also RP2040, UNO R4, see [Supported platforms](supported-platforms.md) |

Versions are from the core installed when this page was written (`versions.txt` in the core's `esp32s3-libs` folder). Check your own core if it is a different release.

The core ships the library for several chips (the ESP32, S3, C3, C5 and C6 libraries all contain it).

## Variant 1: the core's built-in TFLM

Include only the TFLM headers. Do **not** include `<TensorFlowLite.h>`: that header belongs to this library, and including it makes the Arduino builder compile this library's sources as well.

```cpp
#include "model.h"  // your model as a byte array, e.g. from `xxd -i model.tflite`
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"

constexpr int kTensorArenaSize = 3000;
alignas(16) uint8_t tensor_arena[kTensorArenaSize];
tflite::MicroMutableOpResolver<1> op_resolver;
tflite::MicroInterpreter* interpreter = nullptr;

void setup() {
  Serial.begin(115200);
  const tflite::Model* model = tflite::GetModel(g_model);
  op_resolver.AddFullyConnected();
  static tflite::MicroInterpreter static_interpreter(
      model, op_resolver, tensor_arena, kTensorArenaSize);
  static_interpreter.AllocateTensors();
  interpreter = &static_interpreter;
}
```

I built a complete sketch of this form (the `hello_world` sine model, which is not kept in this repository) for `esp32:esp32:esp32s3` with core 3.3.12. It compiled, using 317,913 bytes of flash (24%) and 24,912 bytes of RAM (7%), and the build log contained no reference to this library's `src/`.

## Variant 2: this library

Install the library (see the [README](../README.md)) and include its header first:

```cpp
#include <TensorFlowLite.h>
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
```

The sketch then compiles this library's sources. The same sketch also builds on the other supported boards, which is the main reason to prefer this variant.

I built this library's `hello_world` for `esp32:esp32:esp32s3` (316 KB flash, 24%) and `esp32:esp32:esp32` (312 KB flash, 23%) with core 3.3.12. It needed one change: the core's precompiled TFLM already defines `DebugLog()`, so this library does not define its own on ESP32 (`scripts/templates/src/tensorflow/lite/micro/system_setup.cpp`). Without that, linking failed with `multiple definition of 'DebugLog'`. On ESP32 the output of TFLM's logging is therefore handled by the core's `DebugLog`, not by this library's `Serial` version.

The core's precompiled TFLM is still on the link line in this variant. The linker only takes an archive member when a symbol is still undefined, so it works as long as this library defines everything else. If a future change leaves a symbol undefined, the linker could silently take that part from the core's older copy. I only saw the `DebugLog` clash, so I do not know whether other members are pulled in.

## Which one to use

- **Only targeting ESP32:** use the core's built-in TFLM. Nothing to install, nothing to compile, and it includes the ESP-NN optimized kernels.
- **Same code on ESP32 and other boards (RP2040, UNO R4):** use this library.
- **You need newer TFLM features than the core's 1.4.0:** use this library.

Choose one per sketch. Do not mix them in one sketch.

## Not verified

- **Both variants in one sketch.** If the library is installed and the sketch includes its headers, both copies of TFLM can end up on the include path. I did not test which headers win.
- **Chips other than the S3 and the classic ESP32.** Variant 2 was built for those two; variant 1 only for the S3. The ESP-NN symbol check was for the S3 library.
- **Running on hardware.** Everything above is compile and link only. I did not run any sketch on a board.
- **Speed.** I did not measure any performance difference between the variants.
