cmake_minimum_required(VERSION 3.19)

# Standalone-friendly version detection: fall back to 0.0.0/unknown with a
# warning when git tags are unavailable (e.g. fresh HorneroOS/shell clone).
if(NOT DEFINED VERSION)
    execute_process(COMMAND git describe --tags --abbrev=0
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        OUTPUT_VARIABLE VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    if("${VERSION}" STREQUAL "")
        message(WARNING "VERSION is not set and failed to get from git; using 0.0.0")
        set(VERSION "0.0.0")
    endif()
endif()

if(NOT DEFINED GIT_REVISION)
    execute_process(COMMAND git rev-parse HEAD
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        OUTPUT_VARIABLE GIT_REVISION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    if("${GIT_REVISION}" STREQUAL "")
        message(WARNING "GIT_REVISION is not set and failed to get from git; using unknown")
        set(GIT_REVISION "unknown")
    endif()
endif()

string(REGEX REPLACE "^v" "" VERSION "${VERSION}")

project(hornero-shell VERSION ${VERSION} LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

set(DISTRIBUTOR "Unset" CACHE STRING "Distributor")
set(ENABLE_MODULES "extras;plugin;shell" CACHE STRING "Modules to build/install")
set(INSTALL_LIBDIR "usr/lib/hornero" CACHE STRING "Library install dir")
set(INSTALL_QMLDIR "usr/lib/qt6/qml" CACHE STRING "QML install dir")
set(INSTALL_QSCONFDIR "etc/xdg/quickshell/hornero" CACHE STRING "Quickshell config install dir")

add_compile_options(
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion
    -Wold-style-cast -Wnull-dereference -Wdouble-promotion
    -Wformat=2 -Wfloat-equal -Woverloaded-virtual
    -Wsign-conversion -Wredundant-decls -Wswitch
    -Wunreachable-code
)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-Wunused-lambda-capture)
endif()

if("extras" IN_LIST ENABLE_MODULES)
    if(EXISTS "${CMAKE_SOURCE_DIR}/extras/CMakeLists.txt")
        add_subdirectory(extras)
    else()
        message(WARNING "extras module requested but extras/CMakeLists.txt is missing; skipping")
    endif()
endif()

if("plugin" IN_LIST ENABLE_MODULES)
    if(EXISTS "${CMAKE_SOURCE_DIR}/plugin/CMakeLists.txt")
        add_subdirectory(plugin)
    else()
        message(WARNING "plugin module requested but plugin/CMakeLists.txt is missing; skipping")
    endif()
endif()

if("shell" IN_LIST ENABLE_MODULES)
    foreach(dir assets components config modules services utils)
        install(DIRECTORY ${dir} DESTINATION "${INSTALL_QSCONFDIR}")
    endforeach()
    install(FILES shell.qml LICENSE.GPL-3.0 NOTICE DESTINATION "${INSTALL_QSCONFDIR}")
    install(DIRECTORY presets DESTINATION "${INSTALL_QSCONFDIR}")
    # Welcome Center launcher entry; picked up by the launcher through the
    # system DesktopEntries service (no shell-side registration needed).
    install(FILES assets/hornero-welcome.desktop DESTINATION "share/applications")
endif()
