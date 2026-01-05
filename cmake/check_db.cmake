if (NOT EXISTS "${DB_FILE}")
    message(FATAL_ERROR
            "\n[!] Error: compile_commands.json not found in build directory.\n"
            "[!] Solution: Run 'cmake -B build -DENABLE_TESTS=ON' first to generate it.\n"
    )
endif ()
