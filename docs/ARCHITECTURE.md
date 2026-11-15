# LIL_CHAT — Architecture Notes

## Status
This document describes the **intended initial organization**, inferred from the current directory and file names. It is not yet a verified call graph: the `.c` and `.h` files in the supplied starter snapshot are empty. Update this document as interfaces and data flow are actually designed and implemented.

## High-Level Model

```text
              TCP connection
    +--------+               +--------+
    | Client | <-----------> | Server |
    +--------+               +--------+
          \\                   /
           \\                 /
            +------ TCP -----+
             (additional clients)

       Shared protocol / utility code
```

The intended system has client and server programs. Both may use shared protocol and utility code. The server accepts multiple client connections and coordinates message delivery. The exact concurrency model is not yet decided by this directory structure alone.

## Current Directory Responsibilities

| Path | Intended responsibility | Status |
|---|---|---|
| `src/client/main.c` | Client program entry point and top-level client lifecycle | Empty placeholder |
| `src/client/client_net.c` | Client-side connection and network I/O | Empty placeholder |
| `include/client.h` | Public client declarations and shared client types | Empty placeholder |
| `src/server/main.c` | Server entry point and top-level server lifecycle | Empty placeholder |
| `src/server/connection.c` | Accepting/handling client connections | Empty placeholder |
| `src/server/client_list.c` | Tracking connected clients | Empty placeholder |
| `src/server/broadcast.c` | Distributing messages to connected clients | Empty placeholder |
| `src/server/command_handler.c` | Handling application commands | Empty placeholder |
| `include/server.h` | Public server declarations and shared server types | Empty placeholder |
| `src/common/protocol.c` | Encoding/decoding or sending/receiving protocol messages, as later designed | Empty placeholder |
| `include/protocol.h` | Protocol types and public declarations | Empty placeholder |
| `src/common/util.c` | Reusable helpers that are not specific to client/server/protocol | Empty placeholder |
| `include/util.h` | Public utility declarations | Empty placeholder |
| `docs/PROTOCOL.md` | Agreed wire format, framing, message types, and error behavior | Draft; unresolved decisions remain |

Do not assume these responsibilities are final. Before adding functions or dependencies between modules, explain the proposed interface and get approval for meaningful architectural changes.

## Intended Dependency Direction
A reasonable initial direction to evaluate is:
- Client and server modules may depend on shared protocol and utility interfaces.
- Shared/common modules should not depend on client- or server-specific modules.
- Public interfaces belong in `include/`; implementations belong under the matching `src/` subdirectory.

This is a design guideline to validate, not a claim that the current code already follows it.

## Decisions Still Open
The following cannot be inferred from the current empty source files and must be decided incrementally:
- Whether the server uses threads, `select()`, `poll()`, or another concurrency strategy.
- The exact ownership and lifetime model for client connection records.
- Which module owns socket reads/writes and protocol framing.
- Whether commands share the chat-message envelope or use distinct message types.
- Buffer sizes, maximum frame size, and malformed-message policy.
- Synchronization rules for shared client state and broadcasts.

Wire-format decisions belong in `docs/PROTOCOL.md`. Architecture decisions and their rationale should be recorded in `PROGRESS.md` and reflected here when they become stable.

## Change Discipline
When proposing an architecture change:
1. Explain the problem it solves.
2. Show the affected modules and data flow.
3. Discuss simpler alternatives and trade-offs.
4. Identify learning prerequisites.
5. Obtain approval before changing established interfaces or module boundaries.
