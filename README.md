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
git submodule add https://github.com/mshandruk/cpp-infra external/cpp-infra
```

### 2. Configuration for your CMakeLists.txt

```cmake
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/external/cpp-infra/cmake")
include(DevTools)
add_dev_tools_targets(
        INFRA_DIR "${CMAKE_SOURCE_DIR}/external/cpp-infra"
        CHECK_DIRS "${CMAKE_SOURCE_DIR}/src" "${CMAKE_SOURCE_DIR}/tests"
)
```

### 3. Settings .gitignore

During CMake configuration, symbolic link `.clang-format` and `.clang-tidy` are automatically created,
pointing to the configuration files from `cpp-infra`.
These symbolic links **should not be committed** to the repository - they are recreated in each
machine when CMake is run.

If your have a .gitignore file then add these lines to it:

```
# Created from external/cpp-infra
.clang-format
.clang-tidy
```

If you don't have a .gitignore file, run these commands:

```bash
   cp external/cpp-infra/templates/gitignore_template .gitignore
   git add .gitignore
   git commit -m "chore(git): add .gitignore from cpp-infra template"
```

### Don't forget to commit the new submodule

```bash
git add .gitmodules external/cpp-infra
git commit -m "chore(infra): add cpp-infra submodule for development tooling"
# if this initial commit:
# git commit -m "initial: project skeleton with cpp-infra dev tools"
```

### Code Formatting

Format all .cpp, .cc, .hpp, .h files in your src/ directory using clang-format

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

## Updating Infrastructure

If the `cpp-infra` repository has been updated, and you want to pull the latest
changes (e.g., new linting rules or script fixes) into your project:

1. Update the submodule to the latest version:

    ```bash
    cd external/cpp-infra
    git checkout master
    git pull origin master
    cd ../..
    ```

2. Commit the update in your main project

    ```bash
    git add external/cpp-infra
    git commit -m "chore(infra): update cpp-infra to the latest version"
    ```

# License

MIT License