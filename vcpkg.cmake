# Use VCPKG by default, but do not override external toolchain
option(USE_VCPKG "Satisfy dependencies via VCPKG" ON)
if(USE_VCPKG AND NOT CMAKE_TOOLCHAIN_FILE)
    set(VCPKG_MANIFEST_MODE ON)
    set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/3rdparty/vcpkg/scripts/buildsystems/vcpkg.cmake)
    # Disable VCPKG metrics
    set(ENV{VCPKG_DISABLE_METRICS} 1)
endif()
