# LIL_CHAT Repository Instructions

These rules apply to work performed in this repository. Claude Project Instructions may add learning and interaction guidance; if the two documents appear to conflict, point out the conflict and ask rather than silently ignoring either one.

## Project Context

LIL_CHAT is a learning-oriented C11 project for a terminal-based chat application using a client-server architecture and TCP.

Long-term goals:

- Multiple clients connect to one server concurrently.
- Messages are framed explicitly and delivered completely at the application-protocol level.
- Clients communicate with the server over a LAN.
- The server remains available while clients join and leave.
- Disconnects and reconnection are handled deliberately.

This is the user's first personal C project. Learning and understanding the implementation are as important as delivering the application.

## Environment and Build

- Target environment: Linux / WSL2.
- Toolchain: GCC, Make, C11, POSIX sockets.
- Do not introduce Windows-specific APIs unless the user explicitly changes the platform direction.
- Intended commands: `make`, `make debug`, `make clean`.
- Intended binaries: `build/lil_chat_server`, `build/lil_chat_client`.
- Compiler warnings: `-Wall -Wextra -Wpedantic`.
- The Makefile currently defines AddressSanitizer and UBSan in the debug target.

Important current-state note: the starter `.c` files in the supplied project snapshot are empty. Running `make` in that snapshot fails at server linking with `undefined reference to main` (and emits empty-translation-unit warnings). Do not claim the initial build passes. Resolve this bootstrap issue as an explicit task before treating M0's build criterion as satisfied; do not silently modify the Makefile or add placeholder implementations without approval.

## Document Map and Sources of Truth

Read relevant documents before substantial work:

- `CLAUDE_PROJECT_INSTRUCTIONS.md`: learning workflow and assistant interaction policy.
- `PROGRESS.md`: current milestone, next work, decisions, and open issues.
- `docs/PROTOCOL.md`: authoritative source for agreed wire-protocol decisions.
- `docs/PROJECT_OVERVIEW.md`: project purpose, scope, and learning outcomes.
- `docs/ARCHITECTURE.md`: intended module responsibilities and known uncertainties.
- `docs/LEARNING_PLAN.md`: roadmap for the entire project.
- `README.md`: human-facing build/run instructions.

The implementation is authoritative for current behavior. `docs/PROTOCOL.md` is authoritative for agreed protocol design. If code and documentation disagree, report the mismatch and ask before changing a protocol or architecture decision. Missing or unresolved documentation is not permission to guess.

## Development Workflow

For each substantial feature:

1. Explain its role in the whole application.
2. Identify prerequisites and dependencies.
3. Describe the proposed design and data flow, including meaningful alternatives and trade-offs.
4. Break implementation into small, sequential tasks.
5. Define observable acceptance criteria and test cases.
6. Let the user implement by default; provide code when explicitly requested.
7. Review the implementation and explain issues before moving on.

Do not implement multiple milestones at once without approval. Do not jump to advanced networking or concurrency before prerequisites are understood.

## Change Control

- Do not modify files unless explicitly asked to implement or given approval.
- Before substantial edits, list intended files and reasons.
- Keep changes focused; preserve unrelated work and existing conventions.
- Ask before architecture, protocol, public API, dependency, build-system, or milestone-scope changes.
- Ask before destructive operations or broad side effects.
- Do not commit, push, merge, or rewrite Git history unless requested.
- Inspect `git status` and diffs before editing; never overwrite uncommitted work.

## C Standards and Conventions

- Use C11 with `_POSIX_C_SOURCE=200809L` as configured by the Makefile, where practical.
- Naming: `snake_case` for functions and variables; `UPPER_CASE` for macros/constants; `lil_` prefix for public functions declared in headers.
- Every header must be self-contained and use include guards.
- Keep public declarations in `include/`; implementation belongs in the appropriate `src/` subdirectory.
- Use explicit ownership. Functions that allocate must document who frees the returned/allocated memory. By default, the caller frees returned allocations unless the declaration says otherwise.
- Prefer bounded operations and clear buffer-size contracts. Avoid unsafe string functions and implicit ownership.
- Handle errors and validate inputs. Avoid undefined behavior, leaks, out-of-bounds access, use-after-free, and double-free.
- Follow the existing return convention where appropriate: `0` for success and `-1` for failure. Explain deliberate exceptions.
- Check return values from system calls and allocations, including `socket`, `bind`, `listen`, `accept`, `connect`, `send`, `recv`, and allocation functions.
- For sockets, account for partial sends/receives, `recv()` returning zero, interrupted calls where relevant, and `SIGPIPE`.
- TCP is a byte stream, not a message transport. Implement framing only according to decisions recorded in `docs/PROTOCOL.md`.
- Do not add dependencies or abstractions without a concrete need and an explanation.

## Verification

- Compile without warnings under the configured warning flags.
- Explain how to test each feature.
- Include normal, boundary, malformed-input, and failure/disconnection cases where relevant.
- Use `make debug` with sanitizers when the relevant build is ready.
- Report what was actually executed and distinguish test evidence from reasoning or inspection.
- Compilation alone does not prove runtime correctness or milestone completion.

## Git and Documentation

- Prefer small, focused commits.
- Commit message format: `module: what changed` (for example, `common: add util_read_line`).
- Work on a feature branch and merge to `main` only when the user requests or approves it.
- At the end of a substantial work session, update `PROGRESS.md` with verified completed work, the next step, decisions and reasons, and open issues.
- Update `docs/PROTOCOL.md` only when decisions are made; include rationale. Leave unresolved items marked `CHƯA QUYẾT`.
- Keep docs consistent with the actual implementation.

## Language

- Discuss in Vietnamese by default.
- Keep identifiers and standard technical terminology in English. Comments may be Vietnamese or English, consistently within a file.
