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

        set(SRC_FMT "${CONF_INFRA_DIR}/.clang-format")
        set(DST_FMT "${CMAKE_SOURCE_DIR}/.clang-format")

        if (EXISTS ${SRC_FMT} AND NOT EXISTS ${DST_FMT})
            message(STATUS "Creating symlink for clang-format")
            file(CREATE_LINK "${SRC_FMT}" "${DST_FMT}" SYMBOLIC)
        endif ()

        foreach (DIR ${CONF_CHECK_DIRS})
            file(GLOB_RECURSE FOUND_FILES
                    "${DIR}/*.cpp" "${DIR}/*.hpp" "${DIR}/*.h" "${DIR}/*.cc" "${DIR}/*.cxx"
            )
            list(APPEND ALL_SOURCE_FILES ${FOUND_FILES})
        endforeach ()

        if (ALL_SOURCE_FILES)
            add_custom_target(format
                    COMMAND ${CLANG_FORMAT_EXE} -i -style=file ${ALL_SOURCE_FILES}
                    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                    COMMENT "Formatting source files in ${CONF_CHECK_DIRS}..."
            )
        endif ()
    endif ()

    find_program(PYTHON_EXE python3)
    if (PYTHON_EXE)
        set(TIDY_SCRIPT "${CONF_INFRA_DIR}/scripts/run-clang-tidy.py")

        set(SRC_TIDY "${CONF_INFRA_DIR}/.clang-tidy")
        set(DST_TIDY "${CMAKE_SOURCE_DIR}/.clang-tidy")

        if (EXISTS ${SRC_TIDY} AND NOT EXISTS ${DST_TIDY})
            message(STATUS "Creating symlink for clang-tidy")
            file(CREATE_LINK "${SRC_TIDY}" "${DST_TIDY}" SYMBOLIC)
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