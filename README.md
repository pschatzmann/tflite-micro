# tflite-micro

[TensorFlow Lite for Microcontrollers](https://github.com/tensorflow/tflite-micro) (TFLM) as an Arduino library, generated automatically from the upstream repository.

The official Arduino package, [tflite-micro-arduino-examples](https://github.com/tensorflow/tflite-micro-arduino-examples), was archived in February 2025. This repo keeps the pipeline that builds the library from upstream.


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

- [Supported platforms](docs/supported-platforms.md)
- [ESP32: this library vs the core's built-in TFLM](docs/esp32.md)
- [Generating the library](docs/generating.md): layout, regenerating from upstream, testing
- [Future improvements](docs/future-improvements.md)

## Installation in Arduino

You can download the library as zip and call include Library -> zip library. Or you can git clone this project into the Arduino libraries folder e.g. with

```
cd  ~/Documents/Arduino/libraries
git clone https://github.com/pschatzmann/tflite-micro.git
```

I recommend to use git because you can easily update to the latest version just by executing the ```git pull``` command in the project folder.

The library needs a board whose core compiles C++17, e.g. Arduino UNO R4 or Raspberry Pi Pico. See [Supported platforms](docs/supported-platforms.md).


## License

Apache-2.0, see [LICENSE](LICENSE).
