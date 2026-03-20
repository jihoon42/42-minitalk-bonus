#!/bin/bash
# ============================================================================
#  minitalk_test.sh — macOS / Linux test for minitalk (42)
#  Usage:  bash minitalk_test.sh [--bonus] [usleep_value]
# ============================================================================

export LC_ALL=C

RED='\033[1;31m'; GRN='\033[1;32m'; YEL='\033[1;33m'
BLU='\033[1;34m'; MAG='\033[1;35m'; CYN='\033[1;36m'; NC='\033[0m'

PASS=0; FAIL=0; TOTAL=0; SERVER_PID=""
BONUS_MODE=0
TMPDIR_MT="/tmp/mt_$$"
mkdir -p "$TMPDIR_MT"

# ── Parse arguments ─────────────────────────────────────────────────────────
USLEEP_ARG=""
while [ $# -gt 0 ]; do
    case "$1" in
        --bonus|bonus) BONUS_MODE=1 ;;
        *) USLEEP_ARG="$1" ;;
    esac
    shift
done

ok()    { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); printf "${GRN}OK${NC}\n"; }
ko()    { FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); printf "${RED}KO${NC}  %s\n" "$1"; }
title() { printf "${BLU}%-40s${NC}: " "$1"; }

stop_server() {
    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
        kill "$SERVER_PID" 2>/dev/null
        wait "$SERVER_PID" 2>/dev/null
    fi
    SERVER_PID=""
}

final_cleanup() {
    stop_server
    rm -rf "$TMPDIR_MT"
}
trap final_cleanup EXIT

start_server() {
    stop_server
    sleep 0.2
    ./server > "$TMPDIR_MT/srv.txt" 2>&1 &
    SERVER_PID=$!
    local tries=0; S_PID=""
    while [ $tries -lt 20 ]; do
        if [ -s "$TMPDIR_MT/srv.txt" ]; then
            S_PID=$(head -1 "$TMPDIR_MT/srv.txt" 2>/dev/null)
            if [ -n "$S_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
                return 0
            fi
        fi
        sleep 0.1; tries=$((tries + 1))
    done
    printf "${RED}ERROR: server failed to start${NC}\n"
    return 1
}

# Run client with a timeout guard (prevents bonus client from blocking forever)
run_client() {
    local max_wait="$1"; shift
    ./client "$@" > "$TMPDIR_MT/cli_out.txt" 2>/dev/null &
    local cpid=$!
    local i=0
    while kill -0 "$cpid" 2>/dev/null && [ "$i" -lt "$((max_wait * 10))" ]; do
        sleep 0.1
        i=$((i + 1))
    done
    if kill -0 "$cpid" 2>/dev/null; then
        kill "$cpid" 2>/dev/null
        wait "$cpid" 2>/dev/null
        return 1
    fi
    wait "$cpid" 2>/dev/null
    return 0
}

# get server output (skip PID line, strip newlines)
srv_payload() {
    tail -n +2 "$TMPDIR_MT/srv.txt" 2>/dev/null | LC_ALL=C tr -d '\n'
}

send_and_check() {
    local name="$1" msg="$2" expected="$3" timeout="${4:-5}"
    title "$name"
    if ! start_server; then ko "server start failed"; return; fi
    run_client "$timeout" "$S_PID" "$msg"
    sleep 0.3
    local actual; actual=$(srv_payload)
    if [ "$actual" = "$expected" ]; then ok
    else ko "exp='$(printf '%.50s' "$expected")' got='$(printf '%.50s' "$actual")'"; fi
}

send_and_check_file() {
    local name="$1" expfile="$2" timeout="$3"
    title "$name"
    if ! start_server; then ko "server start failed"; return; fi
    run_client "$timeout" "$S_PID" "$(cat "$expfile")"
    sleep 0.3
    srv_payload > "$TMPDIR_MT/actual.txt"
    if diff -q "$expfile" "$TMPDIR_MT/actual.txt" > /dev/null 2>&1; then ok
    else
        local alen elen info
        alen=$(wc -c < "$TMPDIR_MT/actual.txt" | tr -d ' ')
        elen=$(wc -c < "$expfile" | tr -d ' ')
        info=$(python3 -c "
with open('$expfile','rb') as e, open('$TMPDIR_MT/actual.txt','rb') as a:
    eb,ab=e.read(),a.read()
    for i in range(min(len(eb),len(ab))):
        if eb[i]!=ab[i]: print(f'pos {i}: exp=0x{eb[i]:02x} got=0x{ab[i]:02x}'); break
    else: print(f'len: exp={len(eb)} got={len(ab)}')
" 2>/dev/null || echo "?")
        ko "exp=$elen got=$alen $info"
    fi
}

# ── Setup ───────────────────────────────────────────────────────────────────
DIR="$(cd "$(dirname "$0")" && pwd)"; cd "$DIR"

if [ "$BONUS_MODE" -eq 1 ]; then
    MODE_LABEL="BONUS"
else
    MODE_LABEL="MANDATORY"
fi

printf "${MAG}══════════════════════════════════════════════════════${NC}\n"
printf "${MAG}  minitalk test  —  $(date +%F)  ($(uname -s))  [${MODE_LABEL}]${NC}\n"
printf "${MAG}══════════════════════════════════════════════════════${NC}\n\n"

# Kill stale servers from previous runs
pkill -f '\./server$' 2>/dev/null || true; sleep 0.2

# ── Patch usleep if requested ───────────────────────────────────────────────
PATCHED=""
if [ -n "$USLEEP_ARG" ]; then
    if [ "$BONUS_MODE" -eq 1 ]; then
        TARGET_FILE="client_bonus.c"
    else
        TARGET_FILE="client.c"
    fi
    printf "${YEL}[patch]${NC} %s: usleep -> ${CYN}%s${NC}\n" "$TARGET_FILE" "$USLEEP_ARG"
    cp "$TARGET_FILE" "${TARGET_FILE}.bak"; PATCHED="$TARGET_FILE"
    if [ "$(uname -s)" = "Darwin" ]; then
        sed -i '' "s/usleep([0-9]*)/usleep($USLEEP_ARG)/" "$TARGET_FILE"
    else
        sed -i "s/usleep([0-9]*)/usleep($USLEEP_ARG)/" "$TARGET_FILE"
    fi
fi

# ── Compile ─────────────────────────────────────────────────────────────────
if [ "$BONUS_MODE" -eq 1 ]; then
    printf "${CYN}[compile]${NC} make fclean bonus ... "
    if make fclean bonus > "$TMPDIR_MT/make.log" 2>&1; then printf "${GRN}OK${NC}\n\n"
    else printf "${RED}FAIL${NC}\n"; cat "$TMPDIR_MT/make.log"; exit 1; fi
else
    printf "${CYN}[compile]${NC} make re ... "
    if make re > "$TMPDIR_MT/make.log" 2>&1; then printf "${GRN}OK${NC}\n\n"
    else printf "${RED}FAIL${NC}\n"; cat "$TMPDIR_MT/make.log"; exit 1; fi
fi

# ═══════════════════════════════════════════════════════════════════════════
#  Common tests (mandatory + bonus)
# ═══════════════════════════════════════════════════════════════════════════

send_and_check "1. Basic string" "Hello, 42!" "Hello, 42!" 3

title "2. Empty string (null byte only)"
if start_server; then
    run_client 3 "$S_PID" ""
    sleep 0.3
    LC=$(wc -l < "$TMPDIR_MT/srv.txt" | tr -d ' ')
    if [ "$LC" -ge 2 ]; then ok; else ko "expected >=2 lines, got $LC"; fi
else ko "server start failed"; fi

send_and_check "3. Special chars" \
    'Test `~!@#$%^&*()_+-=[]{}|;:,.<>?' \
    'Test `~!@#$%^&*()_+-=[]{}|;:,.<>?' 3

send_and_check "4. Tabs in string" \
    "$(printf '123\t456\t789')" "$(printf '123\t456\t789')" 3

python3 -c "print('A'*100, end='')" > "$TMPDIR_MT/exp100.txt"
send_and_check_file "5. 100 characters" "$TMPDIR_MT/exp100.txt" 5

python3 -c "print('B'*500, end='')" > "$TMPDIR_MT/exp500.txt"
send_and_check_file "6. 500 characters" "$TMPDIR_MT/exp500.txt" 8

python3 -c "print('C'*1000, end='')" > "$TMPDIR_MT/exp1000.txt"
send_and_check_file "7. 1000 characters" "$TMPDIR_MT/exp1000.txt" 10

title "8. Multiple clients (no restart)"
if start_server; then
    run_client 3 "$S_PID" "First";  sleep 0.3
    run_client 3 "$S_PID" "Second"; sleep 0.3
    run_client 3 "$S_PID" "Third";  sleep 0.3
    ACTUAL=$(tail -n +2 "$TMPDIR_MT/srv.txt" | LC_ALL=C tr '\n' '|')
    if echo "$ACTUAL" | grep -q "First" && echo "$ACTUAL" | grep -q "Second" \
       && echo "$ACTUAL" | grep -q "Third"; then ok
    else ko "got='$ACTUAL'"; fi
else ko "server start failed"; fi

title "9. Speed: 100 chars < 1 second"
if start_server; then
    MSG100=$(python3 -c "print('X'*100, end='')")
    ST=$(python3 -c "import time; print(int(time.time()*1000))")
    run_client 3 "$S_PID" "$MSG100"
    EN=$(python3 -c "import time; print(int(time.time()*1000))")
    MS=$((EN - ST)); sleep 0.3
    if [ "$MS" -lt 1000 ]; then ok; printf "                                          (${CYN}%d ms${NC})\n" "$MS"
    else ko "took ${MS}ms"; fi
else ko "server start failed"; fi

python3 -c "print('A'*5000, end='')" > "$TMPDIR_MT/exp5ku.txt"
send_and_check_file "10. 5000 chars (uniform)" "$TMPDIR_MT/exp5ku.txt" 25

python3 -c "
import string; s=string.printable[:94]; print((s*54)[:5000], end='')
" > "$TMPDIR_MT/exp5km.txt"
send_and_check_file "11. 5000 chars (mixed)" "$TMPDIR_MT/exp5km.txt" 25

# ═══════════════════════════════════════════════════════════════════════════
#  Bonus-only tests
# ═══════════════════════════════════════════════════════════════════════════

if [ "$BONUS_MODE" -eq 1 ]; then
    printf "\n${MAG}── Bonus-specific tests ──────────────────────────────${NC}\n\n"

    title "12. Unicode (Korean)"
    if start_server; then
        run_client 5 "$S_PID" "안녕하세요"
        sleep 0.3
        ACTUAL=$(srv_payload)
        if [ "$ACTUAL" = "안녕하세요" ]; then ok
        else ko "exp='안녕하세요' got='$ACTUAL'"; fi
    else ko "server start failed"; fi

    title "13. Unicode (Japanese + emoji)"
    if start_server; then
        run_client 5 "$S_PID" "こんにちは 🎉"
        sleep 0.3
        ACTUAL=$(srv_payload)
        if [ "$ACTUAL" = "こんにちは 🎉" ]; then ok
        else ko "exp='こんにちは 🎉' got='$ACTUAL'"; fi
    else ko "server start failed"; fi

    title "14. Unicode (table flip)"
    if start_server; then
        run_client 5 "$S_PID" "(╯°□°)╯︵ ┻━┻"
        sleep 0.3
        ACTUAL=$(srv_payload)
        if [ "$ACTUAL" = "(╯°□°)╯︵ ┻━┻" ]; then ok
        else ko "exp='(╯°□°)╯︵ ┻━┻' got='$ACTUAL'"; fi
    else ko "server start failed"; fi

    title "15. ACK: client prints char count"
    if start_server; then
        run_client 5 "$S_PID" "Hello"
        sleep 0.3
        CLI_OUT=$(cat "$TMPDIR_MT/cli_out.txt")
        if echo "$CLI_OUT" | grep -q "5 characters received"; then ok
        else ko "client output='$CLI_OUT'"; fi
    else ko "server start failed"; fi

    title "16. ACK: multi-client char count"
    if start_server; then
        run_client 5 "$S_PID" "AB"; sleep 0.3
        C1=$(cat "$TMPDIR_MT/cli_out.txt")
        run_client 5 "$S_PID" "ABCDE"; sleep 0.3
        C2=$(cat "$TMPDIR_MT/cli_out.txt")
        OK1=$(echo "$C1" | grep -c "2 characters received")
        OK2=$(echo "$C2" | grep -c "5 characters received")
        if [ "$OK1" -eq 1 ] && [ "$OK2" -eq 1 ]; then ok
        else ko "c1='$C1' c2='$C2'"; fi
    else ko "server start failed"; fi
fi

# ═══════════════════════════════════════════════════════════════════════════
printf "\n${MAG}══════════════════════════════════════════════════════${NC}\n"
printf "  ${CYN}Mode: ${MODE_LABEL}${NC}\n"
printf "  ${GRN}PASS: %d${NC}  ${RED}FAIL: %d${NC}  TOTAL: %d\n" "$PASS" "$FAIL" "$TOTAL"
if [ "$FAIL" -eq 0 ]; then printf "  ${GRN}All tests passed!${NC}\n"
else
    printf "  ${YEL}Some tests failed.${NC}\n"
    printf "  ${CYN}Tip: 5000ch flaky = signal loss (POSIX limitation).${NC}\n"
    if [ "$BONUS_MODE" -eq 0 ]; then
        printf "  ${CYN}     Try bonus: bash minitalk_test.sh --bonus${NC}\n"
    fi
fi
printf "${MAG}══════════════════════════════════════════════════════${NC}\n"

if [ -n "$PATCHED" ]; then
    mv "${PATCHED}.bak" "$PATCHED"
    printf "\n${YEL}[reverted]${NC} %s restored\n" "$PATCHED"
fi
exit "$FAIL"
