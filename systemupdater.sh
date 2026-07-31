#!/usr/bin/env bash
set -uo pipefail

sudo -v

report() {
    local state=$1
    shift
    case "$state" in
        ok)
            printf 'OK:   %s\n' "$*"
            ;;
        fail)
            printf 'FAIL: %s\n' "$*"
            ;;
    esac
}

separator() {
    local color=$1
    shift
    case "$color" in
        ok)
            printf '\033[32m----- %s -----\033[0m\n' "$*"
            ;;
        fail)
            printf '\033[31m----- %s -----\033[0m\n' "$*"
            ;;
    esac
}

run_step() {
    local label=$1
    local ok_message=$2
    local fail_message=$3
    shift 3
    if "$@" 2>&1; then
        report ok "$label"
        separator ok "$ok_message"
    else
        report fail "$label"
        separator fail "$fail_message"
        exit 1
    fi
}

run_upgrade() {
    if ! sudo apt -y upgrade 2>&1; then
        return 1
    fi
    if grep -q '^E:' /var/log/apt/term.log 2>/dev/null; then
        return 1
    fi
    return 0
}

run_step "Package list updated" "The package list has been updated." "The package list was not updated." sudo apt update

if run_upgrade; then
    report ok "System upgraded"
    separator ok "The system has been updated."
else
    report fail "System upgrade"
    separator fail "The system was not updated."
    exit 1
fi

run_step "System cleaned" "The system has been cleaned." "The system was not cleaned." sudo apt autoclean
run_step "Unnecessary packages removed" "The unnecessary packages have been removed." "The unnecessary packages have not been removed." sudo apt autoremove -y
