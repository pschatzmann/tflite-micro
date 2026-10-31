// Runs the float sine model from TFLM's hello_world example and prints the
// prediction next to sin(x). Platform independent: only needs Serial.
#include <TensorFlowLite.h>
#include <math.h>

#include "models_hello_world_float_model_data.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"

namespace {
constexpr int kTensorArenaSize = 3000;
alignas(16) uint8_t tensor_arena[kTensorArenaSize];

tflite::MicroMutableOpResolver<1> op_resolver;
tflite::MicroInterpreter* interpreter = nullptr;
float x = 0.0f;
}  // namespace

void setup() {
  tflite::InitializeTarget();

  const tflite::Model* model = tflite::GetModel(g_hello_world_float_model_data);
  if (model->version() != TFLITE_SCHEMA_VERSION) {
    Serial.println("Model schema version mismatch");
    return;
  }
  op_resolver.AddFullyConnected();

  static tflite::MicroInterpreter static_interpreter(
      model, op_resolver, tensor_arena, kTensorArenaSize);
  if (static_interpreter.AllocateTensors() != kTfLiteOk) {
    Serial.println("AllocateTensors() failed");
    return;
  }
  interpreter = &static_interpreter;
}

void loop() {
  if (interpreter == nullptr) {
    delay(1000);
    return;
  }
  interpreter->input(0)->data.f[0] = x;
  if (interpreter->Invoke() != kTfLiteOk) {
    Serial.println("Invoke() failed");
    return;
  }
  Serial.print("x=");
  Serial.print(x);
  Serial.print(" predicted=");
  Serial.print(interpreter->output(0)->data.f[0]);
  Serial.print(" sin(x)=");
  Serial.println(sinf(x));

  x += 0.5f;
  if (x > 2.0f * (float)M_PI) x = 0.0f;
  delay(500);
}
