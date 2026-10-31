# Generating the library

The library in `src/` is generated from upstream; do not edit it by hand.

## Repository layout

| Path | Purpose |
|---|---|
| `src/`, `examples/` | **Generated.** Do not edit by hand; changes are overwritten. |
| `library.properties` | **Generated** from `scripts/templates/library.properties.in`. |
| `scripts/templates/` | Hand-written files copied into the library: `TensorFlowLite.h`, `system_setup.*`, `debug_log.cpp`, `micro_time.cpp`, and the `hello_world` sketch (stored as `hello_world.ino.in`, because the Library Manager lint rejects sketches outside `examples/`). |
| `scripts/` | What you run or edit. Run: `generate-docker.sh`, `test-compile.sh`. Edit: `config.env` (`UPSTREAM_REF`, `TARGET`, `OPTIMIZED_KERNEL_DIR`), `MANIFEST.ini` (files to add or remove and `sed` patches), `platforms.txt` (boards to compile). |
| `scripts/tools/` | Utilities used by the scripts, not run directly: `generate.sh` (container entrypoint), `create_tflm_arduino.py`, `transform_source.py`, `fix_arduino_subfolders.py`. |
| `scripts/docker/` | `Dockerfile` for the generator container. |

## Regenerating the library

Requires Docker and network access.

```bash
scripts/generate-docker.sh
```

To pin a different upstream version, edit `UPSTREAM_REF` in `scripts/config.env` (tag, branch or commit) first. Set `KEEP_TEMP=1` to keep the working tree for inspection.

The pipeline:

1. Shallow-clone `tensorflow/tflite-micro` at `UPSTREAM_REF`.
2. Run upstream's `create_tflm_tree.py` to produce a flat source tree.
3. Run `create_tflm_arduino.py` with `MANIFEST.ini` to rename files to `.cpp`, rewrite includes, apply patches and overlay the `scripts/templates/` files.
4. Move `signal/` under `src/` and write `src/` and `library.properties` into this repo.

You can also run `scripts/tools/generate.sh` directly on the host. It executes upstream code there, so the container is the safer choice.

## Testing

Compile `hello_world` for the boards in `scripts/platforms.txt`. This uses the cores installed on your machine, with `arduino-cli`:

```bash
scripts/test-compile.sh          # all boards in platforms.txt
scripts/test-compile.sh -s       # skip boards whose core is not installed
```

## When upstream changes

Upstream moves files around. If generation reports `Unknown path` for a patch, update the matching section in `scripts/MANIFEST.ini`.

## Origin and license

The generation tools (`create_tflm_arduino.py`, `transform_source.py`, `fix_arduino_subfolders.py` in `scripts/tools/`, and `scripts/MANIFEST.ini`) are adapted from [tflite-micro-arduino-examples](https://github.com/tensorflow/tflite-micro-arduino-examples), © The TensorFlow Authors. Everything is licensed under Apache-2.0; see [LICENSE](../LICENSE).
