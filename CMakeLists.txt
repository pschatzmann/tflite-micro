cmake_minimum_required(VERSION 3.16)
project(tflite_micro LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)

# Library: every generated source under src/, built without the Arduino core.
file(GLOB_RECURSE TFLM_SOURCES CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c
  ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc
  ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)

add_library(tflm STATIC ${TFLM_SOURCES}
  ${CMAKE_CURRENT_SOURCE_DIR}/desktop/debug_log_desktop.cpp)
target_include_directories(tflm PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}/desktop)
target_compile_definitions(tflm PRIVATE TF_LITE_STATIC_MEMORY)

# Example: hello_world as a desktop program (desktop/main.cpp includes the sketch).
add_executable(hello_world
  ${CMAKE_CURRENT_SOURCE_DIR}/desktop/main.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/examples/hello_world/models_hello_world_float_model_data.cpp)
target_link_libraries(hello_world PRIVATE tflm)
