# LIL_CHAT Project Instructions

## Project Context
LIL_CHAT is a learning-oriented C project implementing a terminal-based chat application using a client-server architecture.

The long-term objectives include:
- Multiple clients connecting to one server concurrently.
- Reliable message framing and complete message delivery.
- LAN communication.
- Persistent server operation.
- Handling connection loss and reconnection.

## Environment
- Linux / WSL2, gcc, POSIX sockets. No Windows-specific APIs.
- Build: `make` (normal), `make debug` (AddressSanitizer + UBSan), `make clean`.
- Output binaries: `build/lil_chat_server`, `build/lil_chat_client`.
- Layout: `include/` public headers, `src/common/`, `src/server/`, `src/client/`, `docs/`.

## Document Map (read before answering)
- `docs/PROTOCOL.md`: wire format and framing decisions. Source of truth for the protocol.
- `PROGRESS.md`: current milestone, completed work, design decisions and their reasons.
- `README.md`: build/run instructions for humans.
- If a needed document is missing or still empty, say so. Do not guess its content.

## Development Philosophy
- This is the user's first personal C project.
- The primary objective is to develop programming knowledge and engineering skills, not merely finish the application.
- Prioritize understanding, incremental implementation, and sound engineering decisions.
- Do not jump directly to advanced networking concepts before their prerequisites are understood.

## Development Workflow
For each substantial feature:
1. Explain its role in the overall architecture.
2. Identify dependencies and prerequisites.
3. Break it into sequential implementation tasks.
4. Explain the relevant C concepts, syntax, and APIs.
5. Define expected behavior and test cases.
6. Let the user implement independently unless code is explicitly requested.
7. Review the implementation before proceeding.

At the end of each session, update `PROGRESS.md` (done, next, decisions made).

## Technical Standards
- Use standard C (C11 with `_POSIX_C_SOURCE=200809L`, set in the Makefile) where practical.
- Code must compile without warnings under `-Wall -Wextra -Wpedantic`.
- Run risky changes under `make debug` (sanitizers) before calling them working.
- Prefer explicit ownership and clear memory management.
- Validate inputs and handle errors.
- Avoid undefined behavior, memory leaks, buffer overflows, and unsafe string operations.
- Use appropriate abstractions without overengineering.
- Explain pointers, structures, dynamic memory, processes, threads, sockets, and synchronization when they become relevant.
- Do not introduce unnecessary libraries or dependencies.

## Conventions
- Naming: `snake_case` for functions/variables, `UPPER_CASE` for macros and constants, `lil_` prefix for public functions declared in headers.
- Every header is self-contained and has an include guard.
- Ownership: every function that allocates must document who frees. By default the caller frees what a function returns; any exception must be stated in a comment on the declaration.
- Errors: functions return 0 on success and -1 on failure. Always check the return values of `socket`, `bind`, `listen`, `accept`, `connect`, `send`, `recv`, `malloc`.
- Sockets: handle `recv` returning 0 (peer closed), partial `send`/`recv`, and `SIGPIPE`.
- Language: discussion in Vietnamese; identifiers in English; comments may be Vietnamese.
- Git: small commits, message format `module: what changed` (e.g. `common: add util_read_line`), work on a branch and merge to `main`.

## Scope Control
- Do not implement multiple milestones at once without approval.
- Do not change the architecture without explaining the reason and obtaining approval.
- Do not generate complete implementations unless explicitly requested.
- Keep changes focused and preserve working functionality.

## Verification
- Explain how to test each feature.
- Include relevant normal cases, edge cases, and failure cases.
- Report test results honestly. Distinguish what was run from what was only reasoned about.
- Keep documentation and implementation consistent.
