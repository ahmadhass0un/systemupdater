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
    # Piping apt through `tee` makes stdout a pipe, not a TTY, so apt
    # disables its download progress bar (e.g. "22% [2 brave-browser ...]").
    # When we're interactive, wrap apt in `script` to give it a pty while
    # still logging output for error detection.
    # NB: sudo must stay OUTSIDE script. sudo uses per-tty timestamps by
    # default (tty_tickets), so `script -c "sudo apt ..."` would authenticate
    # on a fresh pty every time and re-prompt for a password. With
    # `sudo script -c "apt ..."` auth happens on the original tty, reusing
    # the initial `sudo -v` credential.
    local apt_failed=0
    if [ -t 1 ] && command -v script >/dev/null 2>&1; then
        local cmd
        printf -v cmd '%q ' apt -o APT::Cmd::disable-script-warning=true "$@"
        if ! sudo script -qec "$cmd" /dev/null 2>&1 | tee "$log"; then
            apt_failed=1
        fi
    else
        if ! sudo apt -o APT::Cmd::disable-script-warning=true "$@" 2>&1 | tee "$log"; then
            apt_failed=1
        fi
    fi
    if [ "$apt_failed" -ne 0 ]; then
        report fail "$label"
        separator fail "$fail_message"
        rm -f "$log"
        exit 1
    fi
    # NB: pty output uses \r for progress-bar redraws, so translate them to
    # newlines before grepping, otherwise an "Err:" following a \r on the
    # same line would not match ^Err:.
    if tr '\r' '\n' < "$log" | grep -qE '^E:|^Err:|Failed to fetch'; then
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
