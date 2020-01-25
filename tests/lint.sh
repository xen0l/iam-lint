#!/usr/bin/env bash

ROOT=$(cd $(dirname $0)/../ >/dev/null; pwd)

shellcheck "${ROOT}/iam-lint"