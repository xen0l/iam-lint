#!/usr/bin/env bash

ROOT=$(cd $(dirname $0)/../ >/dev/null; pwd)

TESTS_DIR="${ROOT}/tests"
TEST_POLICY_DIR="${ROOT}/tests/test_policies"
TEST_CONFIG_DIR="${ROOT}/tests/test_configs"
TEST_PRIVATE_AUDITORS_DIR="${ROOT}/tests/private_auditors"

oneTimeSetUp() {
    cd ${ROOT}
    docker build -t iam-lint . >/dev/null
}

#
# Argument tests
#
testArgumentsPath() {
    OUTPUT="$(docker run -v ${TEST_POLICY_DIR}/invalid:/policies iam-lint /policies)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -eq 1 ]"
    assertTrue "Path /policies not in output" \
                "[ $(echo ${OUTPUT} | grep -c -- "/policies") -eq 1 ]"
}

testArgumentsMinimumSeverity() {
    OUTPUT="$(docker run -e INPUT_MINIMUM_SEVERITY=HIGH -v ${TEST_POLICY_DIR}/invalid:/src iam-lint /src)"
    RC=$?


    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -ne 1 ]"
    assertTrue "--minimum_severity HIGH not in output" \
                "[ $(echo ${OUTPUT} | grep -c -- "--minimum_severity HIGH") -eq 1 ]"
}

testArgumentsConfig() {
    OUTPUT="$(docker run -e INPUT_CONFIG=/config_override.yaml \
                        -v ${TEST_POLICY_DIR}/invalid:/src \
                        -v ${TEST_CONFIG_DIR}/invalid.yaml:/config_override.yaml \
                        iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -eq 1 ]"
    assertTrue "--config custom_config.yml not in output" \
                "[ $(echo ${OUTPUT} | grep -c -- "--config /config_override.yaml") -eq 1 ]"
    assertTrue "config severity override didn't work as expected" \
                "[ $(echo ${OUTPUT} | grep -c "HIGH - Unknown action") -eq 1 ]"
}

testArgumentsPrivateAuditors() {
    OUTPUT="$(docker run -e INPUT_PRIVATE_AUDITORS=private_auditors \
                         -e INPUT_CONFIG=private_auditors/config_override.yaml \
                         -v ${TEST_POLICY_DIR}/private_auditors:/src \
                         -v ${TEST_PRIVATE_AUDITORS_DIR}:/private_auditors \
                         iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -eq 1 ]"
    assertTrue "--private_auditors private_auditors not in output" \
                "[ $(echo ${OUTPUT} | grep -c -- "--private_auditors private_auditors") -eq 1 ]"
    assertTrue "private_auditors didn't work as expected" \
                "[ $(echo ${OUTPUT} | grep -c "MEDIUM - Sensitive bucket access") -eq 1 ]"
}

testArgumentsCommunityAuditors() {
    OUTPUT="$(docker run -e INPUT_COMMUNITY_AUDITORS=true \
                         -v ${TEST_POLICY_DIR}/valid:/src \
                         iam-lint /src)"
    RC=$?

    assertTrue "iam-lint exited with a different return code than expected: ${RC}" \
                "[ ${RC} -eq 0 ]"
    assertTrue "--include-community-auditors not in output" \
                "[ $(echo ${OUTPUT} | grep -c -- "--include-community-auditors") -eq 1 ]"
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

# Execute tests
. ${TESTS_DIR}/shunit2
