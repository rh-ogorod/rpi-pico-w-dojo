#!/bin/bash

set -eu
set -o pipefail

SDPATH="$(dirname "${BASH_SOURCE[0]}")"
if [ ! -d "${SDPATH}" ]; then SDPATH="${PWD}"; fi
readonly SDPATH="$(cd -P "${SDPATH}" && pwd)"

PRJ_ROOT_PATH="${SDPATH}/.."
readonly PRJ_ROOT_PATH="$(cd "${PRJ_ROOT_PATH}" && pwd)"

cd "${PRJ_ROOT_PATH}"; echo + cd "${PWD}"

readonly MERGE=$(realpath external/bazelbuild-rules-compdb/merge.js)
readonly UNBOX=$(realpath external/bazelbuild-rules-compdb/unbox.js)
readonly C2CDB=$(realpath external/commands_to_compilation_database/`
  `commands_to_compilation_database_py)

readonly COMPDB_TMPD_PATH="${PWD}/.cache/compdb"

echo
CMD=(rm -frv)
CMD+=("${COMPDB_TMPD_PATH}")
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=(mkdir -vp "${COMPDB_TMPD_PATH}")
echo + "${CMD[@]}" && "${CMD[@]}"

readonly BOOST_COMPDB_PATH="${COMPDB_TMPD_PATH}/boost-compile_commands.json"

(echo
 readonly BOOST_SRC_PATH="$(cd external/boost/package && pwd)"
 readonly BOOST_BUILD_LOG_0="$(realpath external/boost/build/boost-b2.log)"
 readonly BOOST_BUILD_LOG_1="${COMPDB_TMPD_PATH}/boost-b2-1.log"
 readonly BOOST_BUILD_LOG_2="${COMPDB_TMPD_PATH}/boost-b2.log"
 readonly BOOST_COMPDB_PATH_1="${COMPDB_TMPD_PATH}/`
   `boost-compile_commands-1.json"
 readonly BOOST_COMPDB_CONFIG_PATH="$(realpath unbox-bazel.config.js)"

 CMD=(cp "${BOOST_BUILD_LOG_0}" "${BOOST_BUILD_LOG_1}")
 echo + "${CMD[@]}" && "${CMD[@]}"

 CMD=(chmod "a-x,a+r" "${BOOST_BUILD_LOG_1}")
 echo + "${CMD[@]}" && "${CMD[@]}"

 CMD=(cp "${BOOST_BUILD_LOG_1}" "${BOOST_BUILD_LOG_2}")
 echo + "${CMD[@]}" && "${CMD[@]}"

 echo
 CMD=(cat "${BOOST_BUILD_LOG_2}")
 CMD+=('|')
 CMD+=("${C2CDB}")
 # CMD+=('--build-tool=Boost.Build')
 CMD+=("--compile-command-regex=`
   `'"'^ *"[^"]+arm-none-eabi-(g[^"]+)" .+ "([^"]+)"$'"'")
 CMD+=("--compilers=gcc,g++")
 CMD+=("--root-directory=${BOOST_SRC_PATH}")
 CMD+=("--output-filename=${BOOST_COMPDB_PATH_1}")
 echo + "${CMD[@]}" && eval "${CMD[@]}"

 echo
 CMD=("${UNBOX}")
 CMD+=("${BOOST_COMPDB_PATH}")
 CMD+=("${BOOST_COMPDB_PATH_1}")
 CMD+=("${PRJ_ROOT_PATH}")
 CMD+=("${BOOST_COMPDB_CONFIG_PATH}")
 echo + "${CMD[@]}" && "${CMD[@]}")

readonly MAIN_COMPDB_PATH="${COMPDB_TMPD_PATH}/main-compile_commands.json"

(echo
 readonly MAIN_COMPDB_PATH_0="$(realpath build/compile_commands.json)"
 readonly MAIN_COMPDB_PATH_1="${COMPDB_TMPD_PATH}/main-compile_commands-1.json"
 readonly MAIN_COMPDB_PATH_2="${COMPDB_TMPD_PATH}/main-compile_commands-2.json"
 readonly MAIN_COMPDB_CONFIG_PATH="$(realpath unbox-bazel.config.js)"

 CMD=(cp "${MAIN_COMPDB_PATH_0}" "${MAIN_COMPDB_PATH_1}")
 echo + "${CMD[@]}" && "${CMD[@]}"

 CMD=(cp "${MAIN_COMPDB_PATH_1}" "${MAIN_COMPDB_PATH_2}")
 echo + "${CMD[@]}" && "${CMD[@]}"

 echo
 CMD=("${UNBOX}")
 CMD+=("${MAIN_COMPDB_PATH}")
 CMD+=("${MAIN_COMPDB_PATH_2}")
 CMD+=("${PRJ_ROOT_PATH}")
 CMD+=("${MAIN_COMPDB_CONFIG_PATH}")
 echo + "${CMD[@]}" && "${CMD[@]}")

echo
CMD=("${MERGE}")
CMD+=(-o "${COMPDB_TMPD_PATH}/compile_commands.json")
CMD+=("${BOOST_COMPDB_PATH}")
CMD+=("${MAIN_COMPDB_PATH}")
echo + "${CMD[@]}" && "${CMD[@]}"

echo
CMD=(cp -vf)
CMD+=("${COMPDB_TMPD_PATH}/compile_commands.json")
CMD+=("${PRJ_ROOT_PATH}")
echo + "${CMD[@]}" && "${CMD[@]}"
