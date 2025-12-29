function(add_dev_tools_targets)
    set(options "")
    set(oneValueArgs INFRA_DIR)
    set(multiValueArgs CHECK_DIRS)
    cmake_parse_arguments(CONF "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT CONF_CHECK_DIRS)
        set(CONF_CHECK_DIRS "${CMAKE_SOURCE_DIR}/src")
    endif ()

    find_program(CLANG_FORMAT_EXE clang-format)
    if (CLANG_FORMAT_EXE)
        set(ALL_SOURCE_FILES "")
        foreach (DIR ${CONF_CHECK_DIRS})
            file(GLOB_RECURSE FOUND_FILES
                    "${DIR}/*.cpp" "${DIR}/*.hpp" "${DIR}/*.h" "${DIR}/*.cc" "${DIR}/*.cxx"
            )
            list(APPEND ALL_SOURCE_FILES ${FOUND_FILES})
        endforeach ()

        if (EXISTS "${CMAKE_SOURCE_DIR}/.clang-format")
            set(FMT_PATH "${CMAKE_SOURCE_DIR}/.clang-format")
        else ()
            set(FMT_PATH "${CONF_INFRA_DIR}/.clang-format")
        endif ()

        if (ALL_SOURCE_FILES)
            add_custom_target(format COMMAND ${CLANG_FORMAT_EXE} -i "-style=file:${FMT_PATH}" ${ALL_SOURCE_FILES})
        endif ()
    endif ()

    find_program(PYTHON_EXE python3)
    if (PYTHON_EXE)
        set(TIDY_SCRIPT "${CONF_INFRA_DIR}/scripts/run-clang-tidy.py")

        if (NOT EXISTS "${CMAKE_SOURCE_DIR}/.clang-tidy")
            configure_file("${CONF_INFRA_DIR}/.clang-tidy" "${CMAKE_SOURCE_DIR}/.clang-tidy" COPYONLY)
        endif ()

        set(HEADER_FILTER "^(")
        foreach (DIR ${CONF_CHECK_DIRS})
            string(REPLACE "${CMAKE_SOURCE_DIR}" "" REL_DIR "${DIR}")
            set(HEADER_FILTER "${HEADER_FILTER}${REL_DIR}/|")
        endforeach ()
        set(HEADER_FILTER "${HEADER_FILTER}).*")
        string(REPLACE "/|" "|" HEADER_FILTER "${HEADER_FILTER}")

        add_custom_target(tidy COMMAND ${PYTHON_EXE}
                "${TIDY_SCRIPT}"
                -p "${CMAKE_BINARY_DIR}"
                -header-filter="${HEADER_FILTER}"
                ${CONF_CHECK_DIRS}
        )
    endif ()
endfunction()