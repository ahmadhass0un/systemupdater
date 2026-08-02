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

run_apt() {
    local label=$1
    local ok_message=$2
    local fail_message=$3
    shift 3
    local log
    log=$(mktemp)
    if ! sudo apt -o APT::Cmd::disable-script-warning=true "$@" 2>&1 | tee "$log"; then
        report fail "$label"
        separator fail "$fail_message"
        rm -f "$log"
        exit 1
    fi
    if grep -qE '^E:|^Err:|Failed to fetch' "$log"; then
        report fail "$label"
        separator fail "$fail_message"
        rm -f "$log"
        exit 1
    fi
    report ok "$label"
    separator ok "$ok_message"
    rm -f "$log"
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

run_apt "Package list updated" "The package list has been updated." "The package list was not updated." update
run_apt "System upgraded" "The system has been updated." "The system was not updated." -y upgrade

run_step "System cleaned" "The system has been cleaned." "The system was not cleaned." sudo apt autoclean
run_step "Unnecessary packages removed" "The unnecessary packages have been removed." "The unnecessary packages have not been removed." sudo apt autoremove -y
