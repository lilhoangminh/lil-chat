# LIL_CHAT

A terminal-based chat application written in C, utilizing a TCP client-server architecture. This is my first C project, with system programming as the primary learning objective.

## Environment

- Linux or WSL2
- gcc, make

## Build

```sh
make          # normal build
make debug    # rebuild with AddressSanitizer + UBSan
make clean    # delete build folder
```

The compiled executables are located in `build/`: `lil_chat_server` and `lil_chat_client`.

## Run

Not yet available. Will be updated once the server and client are up and running.

## Structure

```
include/      public header
src/common/   shared code (protocols, utilities)
src/server/   server
src/client/   client
docs/         documentation (PROTOCOL.md)
```

## Documentation

- [docs/PROTOCOL.md](docs/PROTOCOL.md): message format and framing
- [PROGRESS.md](PROGRESS.md): development progress and design decisions
- [AGENTS.md](AGENTS.md): guidelines for working with AI assistants

## Status

M0: Project scaffolding. See [PROGRESS.md](PROGRESS.md).
