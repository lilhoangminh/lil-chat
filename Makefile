# ==============================================================================
# Makefile cho dự án LIL_CHAT (Linux / WSL2 - POSIX Sockets)
#
#   make          build thường
#   make debug    build lại từ đầu với AddressSanitizer + UBSan
#   make clean    xóa thư mục build
# ==============================================================================

CC = gcc

# -std=c11 ẩn các khai báo POSIX (getaddrinfo, sigaction...) nên phải bật lại
# bằng _POSIX_C_SOURCE.
STD  = -std=c11 -D_POSIX_C_SOURCE=200809L
WARN = -Wall -Wextra -Wpedantic

# Để trống = build thường. `make debug` sẽ gán giá trị cho biến này.
SANITIZE =

# -MMD -MP: gcc tự sinh file .d liệt kê header mà mỗi .c phụ thuộc.
CFLAGS  = $(STD) $(WARN) -g -Iinclude -MMD -MP $(SANITIZE)
LDFLAGS = $(SANITIZE)
# Khi dùng đa luồng, thêm: -pthread vào cả CFLAGS và LDFLAGS.

BUILD_DIR = build
OBJ_DIR   = $(BUILD_DIR)/obj

SERVER_EXEC = $(BUILD_DIR)/lil_chat_server
CLIENT_EXEC = $(BUILD_DIR)/lil_chat_client

# Liệt kê tường minh các .c đã có nội dung. Không dùng wildcard vì file .c rỗng
# sẽ gây cảnh báo -Wpedantic (empty translation unit) và làm link lỗi.
# Mỗi khi một module có code, thêm đường dẫn của nó vào danh sách tương ứng.
COMMON_SRCS =
SERVER_SRCS = src/server/main.c
CLIENT_SRCS = src/client/main.c

COMMON_OBJS = $(COMMON_SRCS:%.c=$(OBJ_DIR)/%.o)
SERVER_OBJS = $(SERVER_SRCS:%.c=$(OBJ_DIR)/%.o)
CLIENT_OBJS = $(CLIENT_SRCS:%.c=$(OBJ_DIR)/%.o)

# Chỉ build phần nào đã có mã nguồn.
TARGETS =
ifneq ($(strip $(SERVER_SRCS)),)
TARGETS += $(SERVER_EXEC)
endif
ifneq ($(strip $(CLIENT_SRCS)),)
TARGETS += $(CLIENT_EXEC)
endif

# ==============================================================================
# Quy tắc biên dịch
# ==============================================================================

all: $(TARGETS)

$(SERVER_EXEC): $(SERVER_OBJS) $(COMMON_OBJS)
	@echo "[Linking LIL_CHAT Server...]"
	@mkdir -p $(dir $@)
	$(CC) $^ -o $@ $(LDFLAGS)

$(CLIENT_EXEC): $(CLIENT_OBJS) $(COMMON_OBJS)
	@echo "[Linking LIL_CHAT Client...]"
	@mkdir -p $(dir $@)
	$(CC) $^ -o $@ $(LDFLAGS)

# Mỗi .c -> một .o
$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Build lại từ đầu để không trộn file có và không có sanitizer.
debug:
	$(MAKE) clean
	$(MAKE) all SANITIZE="-fsanitize=address,undefined -fno-omit-frame-pointer"

clean:
	@echo "[Cleaning build artifacts...]"
	rm -rf $(BUILD_DIR)

-include $(COMMON_OBJS:.o=.d) $(SERVER_OBJS:.o=.d) $(CLIENT_OBJS:.o=.d)

.PHONY: all debug clean
