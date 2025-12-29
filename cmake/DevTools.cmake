function(add_dev_tools_targets)
    set(options "")
    set(oneValueArgs INFRA_DIR)
    set(multiValueArgs "")
    cmake_parse_arguments(CONF "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    find_program(CLANG_FORMAT_EXE clang-format)
    if (CLANG_FORMAT_EXE)
        file(GLOB_RECURSE ALL_SOURCE_FILES
                "${CMAKE_SOURCE_DIR}/src/*.cc"
                "${CMAKE_SOURCE_DIR}/src/*.cpp"
                "${CMAKE_SOURCE_DIR}/src/*.hpp"
                "${CMAKE_SOURCE_DIR}/src/*.h"
        )

        if (EXISTS "${CMAKE_SOURCE_DIR}/.clang-format")
            message("Using local .clang-format")
            set(FORMAT_STYLE_PATH "file:${CMAKE_SOURCE_DIR}/.clang-format")
        else ()
            message("Using external .clang-format")
            set(FORMAT_STYLE_PATH "file:${CONF_INFRA_DIR}/.clang-format")
        endif ()

        if (ALL_SOURCE_FILES)
            add_custom_target(format COMMAND ${CLANG_FORMAT_EXE} -i -style=${FORMAT_STYLE_PATH} ${ALL_SOURCE_FILES})
        endif ()
    endif ()

    find_program(PYTHON_EXE python3)
    if (PYTHON_EXE)
        set(TIDY_SCRIPT "${CONF_INFRA_DIR}/scripts/run-clang-tidy.py")

        if (EXISTS "${CMAKE_SOURCE_DIR}/.clang-tidy")
            set(TIDY_CONFIG "${CMAKE_SOURCE_DIR}/.clang-tidy")
        else ()
            set(TIDY_CONFIG "${CONF_INFRA_DIR}/.clang-tidy")
        endif ()

        add_custom_target(tidy COMMAND ${PYTHON_EXE}
                "${TIDY_SCRIPT}"
                -p "${CMAKE_BINARY_DIR}"
                -config-file="${TIDY_CONFIG}"
                "${CMAKE_SOURCE_DIR}/src"
        )
    endif ()
endfunction()
