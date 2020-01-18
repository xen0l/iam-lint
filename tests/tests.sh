#!/usr/bin/env bash

export PS4='[\D{%FT%TZ}]: ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export BASH_XTRACEFD=4
set -o xtrace

ROOT=$(cd $(dirname $0)/../ >/dev/null; pwd)

TESTS_DIR="${ROOT}/tests"
TEST_POLICY_DIR="${ROOT}/tests/test_policies"

oneTimeSetUp() {
    cd ${ROOT}
    docker build -t iam-lint . >/dev/null
}

#
# Argument tests
#
testArgumentsMinimumSeverity() {
    OUTPUT="$(docker run -e INPUT_MINIMUM_SEVERITY=HIGH -v ${TEST_POLICY_DIR}/invalid:/src iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -ne 1 ]"
    assertTrue "--minimum_severity HIGH not in output" \
                "[ $(echo ${OUTPUT} | grep -c -- "--minimum_severity HIGH") -eq 1 ]"
}

#
# Lint functionality tests
#
testLintEmptyPolicyDir() {
    OUTPUT="$(docker run -v ${TEST_POLICY_DIR}/empty:/src iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -eq 1 ]"
    assertTrue "iam-lint failed to validate valid policy files"\
    "[ $(echo ${OUTPUT} | grep -c 'No policy files found!') -eq 1 ]"

}

testLintValid() {
    OUTPUT="$(docker run -v ${TEST_POLICY_DIR}/valid:/src iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -eq 0 ]"
    assertTrue "iam-lint failed to validate valid policy files"\
    "[ $(echo ${OUTPUT} | grep -c OK) -eq 1 ]"
}

testLintValidMultiple() {
    OUTPUT="$(docker run -v ${TEST_POLICY_DIR}/valid_multiple:/src iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -eq 0 ]"
    assertTrue "iam-lint failed to validate valid policy files"\
    "[ $(echo ${OUTPUT} | grep -o OK| wc -l) -eq 2 ]"
}


testLintInvalid() {
    OUTPUT="$(docker run -v ${TEST_POLICY_DIR}/invalid:/src iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -ne 0 ]"
    assertTrue "iam-lint validated properly invalid policy files" \
                "[ $(echo ${OUTPUT} | grep -c FAILED) -eq 1 ]"
}

testLintInvalidMultiple() {
    OUTPUT="$(docker run -v ${TEST_POLICY_DIR}/invalid_multiple:/src iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -ne 0 ]"
    assertTrue "iam-lint validated properly invalid policy files" \
                "[ $(echo ${OUTPUT} | grep -o FAILED | wc -l) -eq 2 ]"
}

testLintValidInvalid() {
    OUTPUT="$(docker run -v ${TEST_POLICY_DIR}/valid_invalid:/src iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -ne 0 ]"
    assertTrue "Invalid number of properly validated valid policy files" \
                "[ $(echo ${OUTPUT} | grep -c OK) -eq 1 ]"
    assertTrue "Invalid number of properly validated invalid policy files" \
                "[ $(echo ${OUTPUT} | grep -c FAILED) -eq 1 ]"

}

# Execute tests
. ${TESTS_DIR}/shunit2
