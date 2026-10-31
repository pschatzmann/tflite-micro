# tflite-micro

[![Arduino Library](https://img.shields.io/badge/Arduino-Library-blue.svg)](https://www.arduino.cc/reference/en/libraries/)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://www.apache.org/licenses/LICENSE-2.0)

[TensorFlow Lite for Microcontrollers](https://github.com/tensorflow/tflite-micro) (TFLM) as an Arduino library, generated automatically from the upstream repository.

In 2024 Google renamed TensorFlow Lite to [LiteRT](https://developers.google.com/edge/litert), and TFLM is now documented there as [LiteRT for Microcontrollers](https://developers.google.com/edge/litert/microcontrollers/overview). The code itself has kept its old names: the repository is still `tensorflow/tflite-micro`, the C++ namespace is still `tflite`, and models are the same `.tflite` files the LiteRT converter produces.

The official Arduino package, [tflite-micro-arduino-examples](https://github.com/tensorflow/tflite-micro-arduino-examples), stopped syncing with upstream in March 2023 and was archived in February 2025. This repo keeps the pipeline that builds the library from upstream.

Upstream does not publish versions, so neither does this library: it tracks the latest upstream `main` and is regenerated weekly by GitHub Actions.


## Usage

```cpp
#include <TensorFlowLite.h>
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"

void setup() {
  tflite::InitializeTarget();  // opens Serial for DebugLog()
  // ... register ops, load your model, build a MicroInterpreter
}
```

See `examples/hello_world`.

## Documentation

- [Supported platforms](https://github.com/pschatzmann/tflite-micro/wiki/Supported-Platforms)
- [ESP32: this library vs the core's built-in TFLM](https://github.com/pschatzmann/tflite-micro/wiki/ESP32)
- [Generating the library](https://github.com/pschatzmann/tflite-micro/wiki/Generating-the-Library): layout, regenerating from upstream, testing

Upstream TFLM has no generated class reference; the headers are the API documentation:

- [Get started with microcontrollers](https://developers.google.com/edge/litert/microcontrollers/get_started): loading a model, registering ops, running inference (some code predates current `main`, e.g. the `MicroInterpreter` constructor no longer takes an error reporter)
- [Upstream guides](https://github.com/tensorflow/tflite-micro/tree/main/docs): memory management, logging, error handling, profiling, optimized kernels
- API headers, also in `src/tensorflow/lite/micro/`: [micro_interpreter.h](https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/micro_interpreter.h), [micro_mutable_op_resolver.h](https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/micro_mutable_op_resolver.h)

## Installation in Arduino

You can download the library as zip and call include Library -> zip library. Or you can git clone this project into the Arduino libraries folder e.g. with

```
cd  ~/Documents/Arduino/libraries
git clone https://github.com/pschatzmann/tflite-micro.git
```

I recommend to use git because you can easily update to the latest version just by executing the ```git pull``` command in the project folder.

The library needs a board whose core compiles C++17, e.g. Arduino UNO R4 or Raspberry Pi Pico. See [Supported platforms](https://github.com/pschatzmann/tflite-micro/wiki/Supported-Platforms).


## License

Apache-2.0, see [LICENSE](LICENSE).
