# ==============================================================================
# Makefile cho dự án LIL_CHAT (Linux / WSL2 - POSIX Sockets)
# ==============================================================================

CC = gcc
CFLAGS = -Wall -Wextra -g -std=c11 -Iinclude

BUILD_DIR = build

# File thực thi đầu ra trên Linux (không cần đuôi .exe)
SERVER_EXEC = $(BUILD_DIR)/lil_chat_server
CLIENT_EXEC = $(BUILD_DIR)/lil_chat_client

SERVER_SRCS = src/server/main.c \
              src/server/connecti`on.c \
              src/server/client_list.c \
              src/server/broadcast.c \
              src/server/command_handler.c \
              src/common/protocol.c \
              src/common/util.c

CLIENT_SRCS = src/client/main.c \
              src/client/client_net.c \
              src/common/protocol.c \
              src/common/util.c

SERVER_HDRS = include/protocol.h include/util.h include/server.h
CLIENT_HDRS = include/protocol.h include/util.h include/client.h

# ==============================================================================
# Quy tắc biên dịch
# ==============================================================================

all: dir $(SERVER_EXEC) $(CLIENT_EXEC)

dir:
	mkdir -p $(BUILD_DIR)

$(SERVER_EXEC): $(SERVER_SRCS) $(SERVER_HDRS)
	@echo "[Building LIL_CHAT Server...]"
	$(CC) $(CFLAGS) $(SERVER_SRCS) -o $@

$(CLIENT_EXEC): $(CLIENT_SRCS) $(CLIENT_HDRS)
	@echo "[Building LIL_CHAT Client...]"
	$(CC) $(CFLAGS) $(CLIENT_SRCS) -o $@

clean:
	@echo "[Cleaning build artifacts...]"
	rm -rf $(BUILD_DIR)

.PHONY: all dir clean