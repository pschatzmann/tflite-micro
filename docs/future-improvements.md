# Future improvements

## Optimized kernels per architecture

The library currently ships only the reference kernels, which are correct on every core but the slowest. Upstream has optimized kernels, [ESP-NN](https://github.com/espressif/esp-nn) for ESP32 and [CMSIS-NN](https://github.com/ARM-software/CMSIS-NN) for Arm Cortex-M4 and above. The idea is to ship all of them and let the preprocessor choose at compile time. This is not implemented or tested.

Upstream picks kernels when the tree is generated (`OPTIMIZED_KERNEL_DIR`), and the optimized files replace the reference files of the same name. Arduino compiles every file in `src/` and cannot select by architecture, so the choice has to be made with `#if` guards. Library builds also cannot pass compiler flags such as `-DCMSIS_NN`.

Plan:

1. Generate three variants in one run (reference, `esp_nn`, `cmsis_nn`) and keep each variant's kernels in its own folder under `src/`.
2. Guard each variant at file level so exactly one set compiles: `esp_nn` on `ARDUINO_ARCH_ESP32`, `cmsis_nn` on Arm cores with DSP support (`__ARM_FEATURE_DSP`), reference otherwise. The ESP-NN assembly is S3-specific, so it also needs a chip check such as `CONFIG_IDF_TARGET_ESP32S3`. Other ESP32 variants use the generic or reference code.
3. Replace upstream's `-DCMSIS_NN` / `-DESP_NN` checks with macros derived from the chip, defined in one shared config header, via patches in `scripts/MANIFEST.ini`.
4. Test each path on real cores (see below).

Do it in stages:

1. **Baseline (done):** reference kernels, tested on `rp2040:rp2040:rpipico`.
2. **ESP-NN:** the largest gain, on ESP32-S3. Needs the ESP32 core (about 3 GB) added to `scripts/cores.txt` and `scripts/platforms.txt`, and its index URL added to `scripts/docker/Dockerfile.test`.
3. **CMSIS-NN (optional):** only helps Cortex-M4 and above. It needs a Cortex-M4/M7 core that builds C++17, because the Arduino mbed and SAMD cores use gcc 7 and cannot compile current TFLM.

Risks: the library grows (CMSIS-NN adds several MB of sources), every upstream restructure breaks more manifest patches, and a wrong guard still compiles but silently picks the wrong kernel.
