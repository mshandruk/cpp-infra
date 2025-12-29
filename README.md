# cpp-infra

Common infrastructure configurations and development tooling for C++ projects.
This repository provides a unified environment for code formatting, static analysis, and CMake automation.

## Install dependencies

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install clang-format clang-tidy
```

## Integration with your project

### 1. Add as git submodule

Run this from main project root directory

```bash
git submodule add https://github.com/mshandruk/cpp-infra
```

### 2. Configuration for your CMakeLists.txt

```cmake
# Enable compilation database generation for clang-tidy
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 1. Include the infrastructure module path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/external/cpp-infra/cmake")
include(DevTools)

# 2. Initialize developer targets
add_dev_tools_targets(INFRA_DIR "${CMAKE_SOURCE_DIR}/external/cpp-infra")
```

### Code Formatting

Format all .cpp, .cc, .hpp, h files in you src/ directory using clang-format

```bash
cmake --build build --target format
```

### Static analysis

```bash
cmake --build build --target tidy
```

### Customization

If your project requires specific rules, place a local .clang-format or .clang-tidy file in your project's root
directory. The system will automatically prioritize local configurations over the global ones provided by this
infrastructure.

# License

MIT License