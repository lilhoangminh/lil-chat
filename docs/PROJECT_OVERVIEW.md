# LIL_CHAT — Project Overview

## Purpose
LIL_CHAT is a personal, learning-oriented C project: a terminal-based chat application built around a client-server architecture and TCP networking.

The project is intended to teach practical C and systems-programming concepts through a real application. Delivering a working chat program matters, but understanding its memory model, data flow, network behavior, and design decisions is equally important.

## Intended Product
The long-term target is an application in which:
- A server can remain running while clients connect and disconnect.
- Multiple clients can communicate through the server concurrently.
- Messages are framed at the application layer so partial TCP reads and writes are handled correctly.
- Devices on the same LAN can connect to the server.
- Unexpected disconnects do not crash the server or corrupt the client list.
- A client can reconnect after a connection is lost, subject to the behavior eventually specified by the project.
- The application provides a simple terminal interface.

These are goals, not claims about features already implemented.

## Current Technical Direction
- Language standard: C11.
- Platform: Linux / WSL2.
- Compiler/build tools: GCC and Make.
- Networking: POSIX sockets over TCP.
- Intended executables: `build/lil_chat_server` and `build/lil_chat_client`.
- Debugging: compiler warnings plus AddressSanitizer and UndefinedBehaviorSanitizer through the Makefile's debug target.

Any change to this direction should be discussed before implementation.

## Scope and Learning Outcomes
The project is expected to provide practical experience with:
- C functions, pointers, structures, arrays, strings, and dynamic memory.
- Header/source separation and modular program organization.
- Explicit memory ownership and error handling.
- TCP/IP concepts and POSIX socket APIs.
- Application-level message framing and protocol design.
- Concurrent client handling and synchronization when introduced by a milestone.
- Debugging, testing, Make, and Git.
- Technical documentation and incremental engineering decisions.

## Out of Scope Unless Explicitly Added
The following are not implied by the current project goals and should not be added automatically:
- GUI or web interface.
- Internet-scale deployment, cloud hosting, or public authentication infrastructure.
- End-to-end encryption or production-grade security guarantees.
- File transfer, voice/video calls, message history databases, or media attachments.
- Complex user accounts, persistent identity, or distributed server clusters.

These may be considered later, but they require explicit scope decisions.

## Definition of Success
Success is not merely that the code compiles. The application should satisfy the observable acceptance criteria in `PROGRESS.md`, follow the agreed protocol in `docs/PROTOCOL.md`, handle documented failure cases, and be explainable and maintainable by the project owner.
