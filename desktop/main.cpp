// Desktop entry point: includes the Arduino sketch and runs its setup()/loop().
// The Arduino IDE adds "Arduino.h" to every sketch; do the same here.
#include "Arduino.h"
// The sketch is included as text because CMake does not compile .ino files.
#include "../examples/hello_world/hello_world.ino"

int main() {
  setup();
  for (int i = 0; i < 10; ++i) {  // run a fixed number of iterations
    loop();
  }
  return 0;
}
