# XLua tests

`xlua_tests` is one test program. It compiles all sources of the `xlua2` plugin and the committed glue in
`SDK/XLua_glue`, and links them with a fake of the X-Plane plugin API (XPLM). The tests then run XLua as
X-Plane does: they call the five plugin entry points, run frames, read datarefs and fire commands.

- `gen_xplm_stubs.py` writes a weak no-op definition of each function in `SDK/CHeaders/XPLM`.
- `fake_xplm.cpp` gives the real definitions that the tests need: the log, the clock, datarefs, commands,
  flight loops, windows and paths. They override the weak stubs.
- `host.cpp` makes a temporary aircraft folder, starts XLua and does the checks that apply to all tests.
- `scripts/<name>/<name>.lua` are the Lua scripts that the tests load.

ctest runs each test case in its own process, because XLua keeps state in static variables.
The tests run on Linux and macOS. The weak stubs need a GCC or Clang linker, so Windows is not supported.

## Run the tests

```sh
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DXLUA_BUILD_TESTS=ON
cmake --build build --target xlua_tests
ctest --test-dir build --output-on-failure
```

On Linux, install `libgl1-mesa-dev` first, because the plugin target needs it at configure time.

## Run the tests with sanitizers

This build uses a LuaJIT with the system allocator and API checks, so AddressSanitizer also sees errors
in Lua objects:

```sh
tests/build_test_luajit.sh build-asan/luajit
cmake -B build-asan -DCMAKE_BUILD_TYPE=Debug -DXLUA_BUILD_TESTS=ON \
      -DXLUA_TEST_LUAJIT=$PWD/build-asan/luajit/src/libluajit.a \
      "-DCMAKE_CXX_FLAGS=-fsanitize=address,undefined -fno-sanitize-recover=undefined -fno-omit-frame-pointer" \
      "-DCMAKE_EXE_LINKER_FLAGS=-fsanitize=address,undefined"
cmake --build build-asan --target xlua_tests
ctest --test-dir build-asan --output-on-failure
```

## Write a test

- Load scripts with `xlua_plugin` (the whole plugin) or `module_host` (single modules, for a test that
  closes one script while another one runs).
- Call `finish()` at the end of each test. It closes the scripts and checks that no callback of a closed
  script can run Lua code.
- A script that checks itself writes `XLUATEST <name>: DONE pass=<n> fail=<n>` when it is done. Use
  `check_script_result` to check that line.
- Use dataref and command names that start with `xluatest/`.
