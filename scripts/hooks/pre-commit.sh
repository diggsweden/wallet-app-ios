#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
#
# SPDX-License-Identifier: EUPL-1.2

set -eu

if [ -t 1 ]; then
    BOLD=$'\033[1m'; RED=$'\033[31m'; YELLOW=$'\033[33m'
    GREEN=$'\033[32m'; DIM=$'\033[2m'; RESET=$'\033[0m'
else
    BOLD=''; RED=''; YELLOW=''; GREEN=''; DIM=''; RESET=''
fi

staged=()
while IFS= read -r -d '' f; do
    case "$f" in *.swift) staged+=("$f") ;; esac
done < <(git diff --cached --name-only --diff-filter=ACMR -z)

if [ ${#staged[@]} -eq 0 ]; then
    exit 0
fi

echo "${BOLD}Checking ${#staged[@]} staged Swift file(s):${RESET}"
for f in "${staged[@]}"; do
    echo "${DIM}  • ${f}${RESET}"
done
echo

if ! command -v swift-format >/dev/null 2>&1; then
    echo "${RED}❌ swift-format not found.${RESET} Run: ${YELLOW}mise install${RESET}"
    exit 2
fi
if ! command -v swiftlint >/dev/null 2>&1; then
    echo "${RED}❌ swiftlint not found.${RESET} Run: ${YELLOW}mise install${RESET}"
    exit 2
fi

failed=0

echo "${DIM}→ swift-format${RESET}"
swift-format lint --strict --parallel "${staged[@]}" || failed=1

echo "${DIM}→ swiftlint${RESET}"
swiftlint lint --strict --quiet "${staged[@]}" || failed=1

if [ "$failed" -ne 0 ]; then
    echo
    echo "${RED}❌ Commit blocked: lint issues found.${RESET}"
    echo "${BOLD}Run:${RESET} ${YELLOW}just fix${RESET}"
    exit 1
fi

echo "${GREEN}✓ swift-format and SwiftLint passed${RESET}"
