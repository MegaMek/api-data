#!/bin/bash

swift test --enable-code-coverage

BUILD_BIN_PATH=`swift build --show-bin-path`
# CODE_COV_PATH=`swift test --show-codecov-path > test.output && tail -n 1 test.output`

# PROF_DATA_PATH="${CODE_COV_PATH%/*}/default.profdata"

XCTEST_PATH="$(find ${BUILD_BIN_PATH} -name '*.xctest')"
IGNORE_FILENAME_REGEX="(\.build|TestUtils|Tests)"

llvm-cov report $XCTEST_PATH --format=text --instr-profile=".build/debug/codecov/default.profdata" --ignore-filename-regex="$IGNORE_FILENAME_REGEX"
