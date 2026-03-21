# AGENTS.md — Minitalk (42 Project)

This file guides Codex when working on the Minitalk project.
Follow every rule here strictly. When in doubt, be more restrictive.

---

## Project Overview

Build two programs: `server` and `client`.

- **server**: starts first, prints its own PID, then waits for signals. Must handle multiple clients in a row without restarting. Must print received strings without noticeable delay.
- **client**: takes two arguments — the server PID and a string — then sends the string to the server bit by bit using only UNIX signals.

Communication must use **only** `SIGUSR1` and `SIGUSR2`. No other IPC mechanism is allowed.

---

## Allowed Functions

Only the following functions may be used (mandatory part):

```
write, ft_printf (or equivalent coded by the student),
signal, sigemptyset, sigaddset, sigaction,
kill, getpid,
malloc, free,
pause, sleep, usleep,
exit
```

A `libft/` folder may be used to hold helper functions needed by the project. However, every function inside it must be written from scratch — do not copy or import code from any existing libft repository. Only include functions that are actually needed by the project.

---

## Global Variables

Each program may use **at most one** global variable. Its use must be justified (signal handlers cannot receive extra arguments, so a global is the standard justification).

The global variable name must start with `g_` per the Norm.

---

## Bonus Part

Only implement if the mandatory part is fully complete and error-free.

- Server acknowledges each received message by sending a signal back to the client.
- Unicode (multi-byte) character support.

Bonus files must be named `*_bonus.c` / `*_bonus.h`.

**Bonus uses only mandatory allowed functions.** The notification-only ACK approach (server sends signal back, client does not block on it) requires no additional functions beyond the mandatory allowed list. `SA_SIGINFO` flag for `sigaction` and `siginfo_t` struct are part of the standard `sigaction` interface already permitted.

---

## The 42 Norm (Version 4.1) — Enforced Rules

All `.c` and `.h` files must comply with the Norm. A norm error means a score of 0.

### Naming

- Variables, functions, types: `snake_case` only. No uppercase letters.
- `struct` names: prefix `s_`
- `typedef` names: prefix `t_`
- `union` names: prefix `u_`
- `enum` names: prefix `e_`
- Global variable names: prefix `g_`
- File and directory names: `snake_case` only.
- All identifiers must be meaningful English words or mnemonics.
- Non-ASCII characters are forbidden except inside string/char literals.

### Formatting

- Max **25 lines** per function (not counting the opening/closing braces of the function itself).
- Max **80 columns** per line (tabs count as the number of spaces they represent).
- Indent with **real tab characters** (ASCII 9), not spaces.
- Braces `{` and `}` are alone on their own line (except for struct/enum/union declarations).
- Blocks inside braces must be indented one level.
- Empty lines must be truly empty (no spaces or tabs).
- No trailing spaces or tabs at the end of any line.
- No two consecutive empty lines anywhere.
- No two consecutive spaces anywhere.
- Functions must be separated by exactly one empty line.
- One variable declaration per line.
- Declarations must all appear at the top of a function, before any instructions.
- One empty line between declarations and the first instruction inside a function. No other empty lines inside a function.
- All variable names in the same scope must be aligned on the same column.
- Pointer `*` is attached to the variable name, not the type: `char *str`, not `char* str`.
- Declaration and initialisation on the same line is forbidden (except for globals, statics, and constants).
- Only one instruction or control structure per line. No assignment inside a condition. No two assignments on the same line.
- Each comma or semicolon (unless at end of line) must be followed by a space.
- Each operator and operand must be separated by exactly one space.
- Each C keyword (`if`, `while`, `return`, `sizeof`, etc.) must be followed by a space, except type keywords (`int`, `char`, `float`, ...) and `sizeof`.
- Control structures (`if`, `while`) must use braces unless the body is a single instruction on a single line.
- `return` value must be in parentheses: `return (value);`. Void returns: `return ;`.
- Each function must have a single tab between its return type and its name.

### Functions

- Max **4 named parameters** per function.
- A function that takes no arguments must be prototyped as `func(void)`.
- All parameters in prototypes must be named.
- Max **5 variable declarations** per function.

### Files

- A `.c` file cannot be included in another `.c` or `.h` file.
- Max **5 function definitions** per `.c` file.

### Headers

- Header files must be protected against double inclusion:
  ```c
  #ifndef FT_FOO_H
  # define FT_FOO_H
  /* content */
  #endif
  ```
- Allowed content in headers: inclusions, declarations, defines, prototypes, macros.
- All `#include` directives must be at the top of the file.
- Unused headers must not be included.
- Structures cannot be declared in a `.c` file (declare in `.h`).

### Macros and Preprocessor

- `#define` constants must only be used for literal/constant values.
- `#define` must not be used to bypass the Norm or obfuscate code.
- Multiline macros are forbidden.
- Macro names must be ALL_UPPERCASE.
- Preprocessor directives inside `#if`/`#ifdef`/`#ifndef` blocks must be indented.
- Preprocessor instructions are forbidden outside global scope.

### Forbidden Constructs

The following are strictly forbidden:

```
for
do...while
switch / case
goto
?: (ternary operator)
VLAs (Variable Length Arrays)
Implicit types in variable declarations
```

### Comments

- Comments are not allowed inside function bodies.
- Comments may appear at the end of a line, or on their own line (outside functions).
- Comments must be in English and must be useful.
- A comment cannot justify a poorly designed or catch-all function.

### 42 Header

Every `.c` and `.h` file must begin with the standard 42 header comment (generated by the editor plugin). It must include the creator's login, student email, creation date, and last-update info.

---

## Makefile Requirements

The Makefile must include at least these rules: `$(NAME)`, `all`, `clean`, `fclean`, `re`.

- `all` must be the default rule (first rule in the file).
- `$(NAME)` for this project means two binaries: `client` and `server`. Define separate rules for each.
- No unnecessary relinking: recompile only what changed.
- No wildcards (`*.c`, `*.o`) — all source files must be listed explicitly.
- If `libft/` is used, the Makefile must compile it automatically via its own Makefile.
- For bonuses, a `bonus` rule must be added. The `bonus` rule compiles `*_bonus.c` files into the same `server` and `client` binaries.

---

## Memory and Error Handling

- All heap-allocated memory must be freed before the program exits.
- No memory leaks are tolerated.
- The program must never crash with a segfault, bus error, double free, or similar under normal usage.
- Error cases must be handled explicitly.

---

## Performance Requirement

Displaying 100 characters must not take 1 second or more. Using `usleep` between each bit send is acceptable as long as it is short enough (typically ≤ 100µs per signal).

---

## Current File Structure

```
minitalk/
├── AGENTS.md
├── Makefile
├── minitalk.h
├── server.c             ← mandatory (complete)
├── client.c             ← mandatory (complete)
├── libft/
│   ├── Makefile
│   ├── libft.h
│   ├── ft_atoi.c
│   └── ft_putnbr_fd.c
├── minitalk_test.sh     ← custom test script (11 tests, macOS/Linux compatible)
├── server_bonus.c       ← bonus (TODO: copy from outputs)
├── client_bonus.c       ← bonus (TODO: copy from outputs)
└── minitalk_bonus.h     ← bonus (TODO: copy from outputs)
```

The `.h` file must contain all shared type definitions, macros, and function prototypes. No struct definitions in `.c` files.

---

## Implementation Status

### Mandatory — COMPLETE

| Component | Status | Notes |
|-----------|--------|-------|
| `server.c` | Done | `sa_handler` + `SA_RESTART`, global `g_data` (struct `t_data`), SIGUSR1/SIGUSR2 mask in `sa.sa_mask` |
| `client.c` | Done | `usleep(100)` blind-send, no ACK, allowed functions only |
| `minitalk.h` | Done | Contains `t_data` struct definition, shared prototypes |
| `libft/` | Done | `ft_atoi`, `ft_putnbr_fd` — written from scratch, minimal set |
| `Makefile` | Done | `all`, `clean`, `fclean`, `re` rules; compiles libft automatically |

### Bonus — IMPLEMENTED, PENDING TESTING

| Component | Status | Notes |
|-----------|--------|-------|
| `server_bonus.c` | Implemented | `SA_SIGINFO` + `siginfo_t->si_pid`; sends `SIGUSR1` ACK per completed character, `SIGUSR2` on null terminator (end of message) |
| `client_bonus.c` | Implemented | Blind-send with `usleep(100)` (same as mandatory); receives server ACK as **notification only** (not synchronization); prints received character count on `SIGUSR2` then `exit(0)` |
| `minitalk_bonus.h` | Implemented | Bonus-specific header with `t_data` struct (includes `pid` field for ACK target) |
| Makefile `bonus` rule | TODO | Needs to be added to current Makefile |
| Unicode support | Expected | UTF-8 is byte-level, so it works inherently with the bit-by-bit protocol; needs verification after integration |

---

## Design Decisions

### Mandatory: blind-send with `usleep(500)`

The mandatory part uses `usleep(500)` between each bit with no ACK mechanism. This is a deliberate choice driven by the allowed functions constraint:

- **Why no ACK in mandatory**: The only way to implement a race-condition-free ACK requires `sigprocmask` + `sigsuspend` (atomic unblock-and-wait), but these are not in the allowed functions list. Using `pause()` for ACK introduces a race condition between the flag check and `pause()` call, which causes deadlocks under ASan/wrapper overhead.
- **Known limitation**: For very long strings (5000+ chars), POSIX signal non-queuing causes intermittent signal loss. The subject explicitly acknowledges this: *"Linux system does NOT queue signals when you already have pending signals of this type! Bonus time?"*
- **Performance**: `usleep(500)` × 8 bits × 100 chars = 400ms — well within the 1-second requirement.

### Bonus: blind-send + server ACK notification

The bonus part keeps the client's blind-send (`usleep(500)`) unchanged and adds a **notification-only** ACK from the server. The client does not wait for ACK before sending the next bit — ACK is purely informational.

- **Server**: Uses `SA_SIGINFO` flag so the handler receives `siginfo_t *info`, which provides `info->si_pid`. On each completed character (8 bits), the server sends `kill(g_data.pid, SIGUSR1)` to notify the client. On null terminator, the server sends `SIGUSR2` to signal end of message, then resets `g_data.pid` to 0 so the next client's PID is captured.
- **Client**: Registers `sigaction` for both `SIGUSR1` and `SIGUSR2`. `SIGUSR1` increments a `static int received` counter. `SIGUSR2` triggers the client to print the received character count and `exit(0)`. After sending all bits (including null terminator), the client enters `while (1) pause()` to wait for the final `SIGUSR2`.
- **Why this approach**: No `sigprocmask`/`sigsuspend` needed — only mandatory allowed functions are used. No race condition risk because the client never blocks on ACK. The subject's bonus requirement ("Server acknowledges each received message by sending a signal back to the client") is satisfied by the per-character `SIGUSR1` and end-of-message `SIGUSR2`.
- **Trade-off vs per-bit ACK**: Signal loss for very long strings is still theoretically possible (same as mandatory), but in practice `usleep(500)` is reliable for typical evaluation scenarios. The advantage is zero risk of deadlock and full compatibility with francinette.

### Signal handler design

- **Mandatory server**: `sa_handler` (simple handler, no `siginfo_t`). Uses `SA_RESTART` to prevent `pause()` from being interrupted. Both SIGUSR1 and SIGUSR2 are masked during handler execution to prevent interleaving.
- **Bonus server**: `sa_sigaction` (extended handler with `siginfo_t`). Uses `SA_SIGINFO | SA_RESTART`. Same signal masking. Captures client PID from `info->si_pid` on first signal, stores in `g_data.pid`.
- **Mandatory client**: No signal handler. Fire-and-forget with `usleep(500)`.
- **Bonus client**: `sa_handler` for both SIGUSR1 (character count increment) and SIGUSR2 (print stats + exit). Uses `SA_RESTART`.
- **Global variable**: Both mandatory and bonus server use a single global `g_data` of type `t_data` (struct with `bit` counter, `c` character accumulator, and `pid` for bonus). Bonus client uses no global — `received` counter is a `static` local inside the handler.

---

## Test Results

### Mandatory

| Test Environment | Tool | Result |
|-----------------|------|--------|
| macOS (Apple Silicon) | francinette | All tests passed (Leaks, Test string, 5000 chars, Multiple messages, SIGUSR1/SIGUSR2 only) |
| macOS (Apple Silicon) | `minitalk_test.sh` | Tests 1–9 pass; Tests 10–11 (5000 chars) intermittent failure (expected — signal loss) |
| Azure VM (x86_64 Ubuntu) | valgrind | 0 allocs, 0 frees, 0 errors — no memory leaks possible |
| Azure VM (x86_64 Ubuntu) | Manual test | Short strings work; 5000 chars shows signal loss (expected) |
| Docker (`liqsuq/francinette`) | francinette | Fails — `leaks` command is macOS-only, causes `'NoneType' object has no attribute 'group'` crash. This is a structural limitation of the Docker image, not a code issue. |

### Bonus

| Test Environment | Tool | Result |
|-----------------|------|--------|
| macOS (Apple Silicon) | `minitalk_test.sh` | TODO — new notification-only ACK approach, needs testing |
| macOS (Apple Silicon) | Manual test | TODO — verify Unicode (Korean/Japanese/box-drawing), character count output, multi-client |
| macOS (Apple Silicon) | francinette | TODO — bonus should behave identically to mandatory for francinette since client send logic is unchanged |

### Custom test script: `minitalk_test.sh`

An 11-test shell script covering: basic strings, empty string, special characters, tabs, newlines, 100/500/1000/5000-character payloads, multiple sequential clients, and a speed benchmark. Compatible with both macOS and Linux (handles `LC_ALL=C`, macOS `sed -i ''`, `date` differences).

### Francinette + Docker: known incompatibility

The `liqsuq/francinette` Docker image's `Fsoares.py` tester depends on macOS-only `leaks` command and `SIGINFO` signal. On any Linux environment (Docker, Azure VM, etc.), the Leaks test crashes and blocks all subsequent functional tests. This is not fixable without modifying the tester source. Use `minitalk_test.sh` or `valgrind` for Linux-based verification instead.

---

## Remaining Tasks

- [ ] **Integrate bonus files into project directory**: Copy `server_bonus.c`, `client_bonus.c`, `minitalk_bonus.h` from outputs into the project root.
- [ ] **Add `bonus` rule to Makefile**: Compile `server_bonus.c` and `client_bonus.c` into `server` and `client` binaries. Ensure no wildcards, explicit source listing.
- [ ] **Test bonus on macOS**: Run `minitalk_test.sh` with bonus binaries. Verify: basic strings, special chars, 5000 chars, Unicode, multi-client, character count output, end-of-message notification.
- [ ] **Test bonus with francinette**: Since bonus client uses the same `usleep(100)` blind-send, francinette should behave identically to mandatory. Confirm.
- [ ] **Norminette full check**: Run `norminette` on all `.c` and `.h` files (mandatory + bonus) to confirm compliance.
- [ ] **Makefile final review**: Verify both mandatory and bonus builds, no unnecessary relinking, no wildcards.
- [ ] **Evaluation preparation**: Prepare to explain: (1) mandatory usleep trade-off, (2) bonus ACK notification design, (3) why notification-only ACK satisfies the subject requirement while avoiding race conditions.
