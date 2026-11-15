# LIL_CHAT

Ứng dụng chat chạy trên terminal, viết bằng C, mô hình client-server (TCP). Đây là dự án C đầu tiên của tôi, mục tiêu chính là học lập trình hệ thống.

## Môi trường

- Linux hoặc WSL2
- gcc, make

## Build

```sh
make          # build thường
make debug    # build lại với AddressSanitizer + UBSan
make clean    # xóa thư mục build
```

File chạy nằm trong `build/`: `lil_chat_server` và `lil_chat_client`.

## Chạy

Chưa có. Sẽ cập nhật khi server và client chạy được.

## Cấu trúc

```
include/      header công khai
src/common/   mã dùng chung (giao thức, tiện ích)
src/server/   server
src/client/   client
docs/         tài liệu (PROTOCOL.md)
```

## Tài liệu

- [docs/PROTOCOL.md](docs/PROTOCOL.md): định dạng message và cách đóng khung
- [PROGRESS.md](PROGRESS.md): tiến độ và các quyết định thiết kế
- [AGENTS.md](AGENTS.md): quy tắc làm việc với trợ lý AI

## Trạng thái

M0: khung dự án. Xem [PROGRESS.md](PROGRESS.md).
