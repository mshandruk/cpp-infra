function(add_dev_tools_targets)
    set(options "")
    set(oneValueArgs INFRA_DIR)
    set(multiValueArgs CHECK_DIRS)
    cmake_parse_arguments(CONF "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT CONF_CHECK_DIRS)
        set(CONF_CHECK_DIRS "${CMAKE_SOURCE_DIR}/src")
    endif ()

    find_program(CLANG_FORMAT_EXE clang-format)
    find_program(CLANG_TIDY_EXE clang-tidy)
    find_program(PYTHON_EXE python3)

    foreach (CONFIG .clang-format .clang-tidy)
        if (EXISTS "${CONF_INFRA_DIR}/${CONFIG}")
            configure_file("${CONF_INFRA_DIR}/${CONFIG}" "${CMAKE_SOURCE_DIR}/${CONFIG}" COPYONLY)
        endif ()
    endforeach ()

    set(ALL_FILES "")
    set(TIDY_SOURCES "")
    foreach (DIR ${CONF_CHECK_DIRS})
        file(GLOB_RECURSE FOUND_FILES LIST_DIRECTORIES false "${DIR}/*")
        foreach (F ${FOUND_FILES})
            if (F MATCHES ".*\\.(hpp|h|inl|cpp|cc|cxx)$")
                list(APPEND ALL_FILES ${F})
                if (F MATCHES ".*\\.(cpp|cc|cxx)$")
                    list(APPEND TIDY_SOURCES ${F})
                endif ()
            endif ()
        endforeach ()
    endforeach ()

    if (CLANG_FORMAT_EXE AND ALL_FILES)
        add_custom_target(format
                COMMAND ${CLANG_FORMAT_EXE} -i -style=file ${ALL_FILES}
                COMMENT "Clang-format: fixing your code..."
                VERBATIM)
    endif ()

    if (CLANG_TIDY_EXE AND PYTHON_EXE AND TIDY_SOURCES)
        set(TIDY_SCRIPT "${CONF_INFRA_DIR}/scripts/run-clang-tidy.py")
        cmake_host_system_information(RESULT CORES QUERY NUMBER_OF_LOGICAL_CORES)

        string(REPLACE "\\" "/" SAFE_ROOT "${CMAKE_SOURCE_DIR}")
        set(HEADER_FILTER "^${SAFE_ROOT}/.*")

        add_custom_target(tidy
                COMMAND ${CMAKE_COMMAND} -E echo "Checking for compilation database..."
                COMMAND ${CMAKE_COMMAND} -DDB_FILE="${CMAKE_BINARY_DIR}/compile_commands.json"
                -P "${CONF_INFRA_DIR}/cmake/check_db.cmake"
                COMMAND ${PYTHON_EXE} "${TIDY_SCRIPT}"
                -p "${CMAKE_BINARY_DIR}"
                -j ${CORES}
                -header-filter="${HEADER_FILTER}"
                -quiet
                ${TIDY_SOURCES}
                COMMENT "Clang-tidy: checking on ${CORES} cores..."
                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                USES_TERMINAL
        )
    endif ()
endfunction()
