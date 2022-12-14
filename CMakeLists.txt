cmake_minimum_required(VERSION 3.12)

# set(CMAKE_C_COMPILER $ENV{TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc)
# set(CMAKE_CXX_COMPILER $ENV{TOOLCHAIN_PATH}/bin/arm-none-eabi-g++)

# Pull in SDK (must be before project)
include(pico_sdk_import.cmake)

project(blink C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)

if (PICO_SDK_VERSION_STRING VERSION_LESS "1.3.0")
  message(FATAL_ERROR "Raspberry Pi Pico SDK version 1.3.0 (or later) required. Your version is ${PICO_SDK_VERSION_STRING}")
endif()

# Initialize the SDK
pico_sdk_init()

# include(example_auto_set_url.cmake)

# set(BOOST_ROOT ${PROJECT_SOURCE_DIR}/external/boost/dist CACHE INTERNAL "")
# set($ENV{BOOST_ROOT} ${PROJECT_SOURCE_DIR}/external/boost/dist)
# set(BOOST_ROOT ${PROJECT_SOURCE_DIR}/external/boost/package)

# message($ENV{BOOST_ROOT})

set(BOOST_VERSION 1.80.0)
set(BOOST_ROOT ${PROJECT_SOURCE_DIR}/external/boost/dist)

set(Boost_DIR ${BOOST_ROOT}/lib/cmake/Boost-${BOOST_VERSION})
set(boost_headers_DIR ${BOOST_ROOT}/lib/cmake/boost_headers-${BOOST_VERSION})
set(boost_system_DIR ${BOOST_ROOT}/lib/cmake/boost_system-${BOOST_VERSION})

set(Boost_NO_SYSTEM_PATHS ON)
set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_STATIC_RUNTIME ON)
set(Boost_USE_MULTITHREADED OFF)

find_package(Boost
  COMPONENTS ALL
  )

#set(RANGES_VERBOSE_BUILD ON)
#set(RANGE_V3_PATH ${PROJECT_SOURCE_DIR}/external/range-v3)

#add_subdirectory(${RANGE_V3_PATH})

set(RANGE_V3_VERSION 0.12.0)
set(RANGE_V3_ROOT ${PROJECT_SOURCE_DIR}/external/range-v3/dist)

set(range-v3_DIR ${RANGE_V3_ROOT}/lib/cmake/range-v3)

find_package(
  range-v3 ${RANGE_V3_VERSION} EXACT CONFIG REQUIRED
)

if (range-v3_FOUND)
  message(
    STATUS
    "Found range-v3: "
    "${range-v3_CONFIG} "
    "(found version \"${range-v3_VERSION}\")"
  )
endif()

add_compile_options(-Wall
  -Wno-format          # int != int32_t as far as the compiler is concerned because gcc has int32_t as long int
  -Wno-unused-function # we have some for the docs that aren't called
  -Wno-maybe-uninitialized
  )

add_subdirectory(packages/blink)
