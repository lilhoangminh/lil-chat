# PROGRESS

Cập nhật cuối mỗi buổi làm việc. Đây là "bộ nhớ" của dự án: trợ lý AI không nhớ các chat cũ.

## Milestone (bản nháp, sửa theo ý bạn)

Mỗi milestone có tiêu chí "xong" là hành vi quan sát được, không phải "build được".

| # | Nội dung | Xong khi |
|---|----------|----------|
| M0 | Khung dự án: Makefile, docs, header rỗng | `make` chạy không lỗi |
| M1 | 1 client nói chuyện với 1 server qua TCP (echo) | Client gõ một dòng, server nhận và trả lại, client in ra |
| M2 | Đóng khung message theo `docs/PROTOCOL.md` | Message dài, message gửi sát nhau, message bị cắt đôi đều nhận đúng |
| M3 | Nhiều client đồng thời + phát tin cho mọi người | 3 client mở cùng lúc, tin của một người đến hai người còn lại |
| M4 | Xử lý ngắt kết nối | Client thoát hoặc bị kill, server không crash và dọn đúng |
| M5 | Lệnh (ví dụ đổi tên, thoát) | Lệnh chạy đúng, lệnh sai báo lỗi |
| M6 | LAN, kết nối lại, chạy liên tục | Hai máy khác nhau chat được; mất mạng rồi nối lại được |

## Hiện tại

- Milestone đang làm: M1
- Đã xong: M0 (2026-11-16). `make` và `make debug` build sạch, không warning, trên WSL2 (Ubuntu 22.04, gcc 11.4); hai binary chạy và thoát với mã 0. Trước đó: AGENTS.md, README.md, khung `docs/PROTOCOL.md`.
- Việc tiếp theo: giảng lý thuyết M1 (socket TCP, `socket`/`bind`/`listen`/`accept`/`connect`, echo 1 client) rồi cùng chốt cách làm. Các mục trong `docs/PROTOCOL.md` còn là ví dụ/lựa chọn mở (kích thước tối đa, xử lý message quá lớn/sai định dạng) cần chốt trước M2.

## Kiểm tra trạng thái thực tế (2026-11-15)

- Đã chạy `make` trên snapshot hiện tại trong môi trường Linux/GCC.
- Kết quả: build thất bại ở bước link server với `undefined reference to main`; các translation unit rỗng cũng phát cảnh báo `-Wpedantic`.
- Nguyên nhân trực tiếp: Makefile đưa các file `.c` hiện có vào build dù chúng đang rỗng; chưa có định nghĩa `main()` trong `src/server/main.c` (và client cũng chưa có implementation).
- Đã xử lý ngày 2026-11-16: xem "Quyết định thiết kế" bên dưới.

## Quyết định thiết kế

(Ghi theo dạng: ngày, quyết định, lý do.)

- 2026-11-16: Xử lý bootstrap M0 bằng cách liệt kê tường minh nguồn trong Makefile (`SERVER_SRCS = src/server/main.c`, `CLIENT_SRCS = src/client/main.c`, `COMMON_SRCS` rỗng) và viết `main()` tối thiểu cho hai `main.c`. Lý do: file `.c` rỗng gây cảnh báo `-Wpedantic` (empty translation unit) nên không dùng `wildcard`; không nhét code giả vào các file rỗng; giữ nguyên cấu trúc file/thư mục. Mỗi khi một module có code, thêm file đó vào danh sách trong Makefile.
- 2026-11-16: Trường `length` trong khung gói tin chỉ tính **payload** (không gồm `type`). Header cố định 5 byte (`length` 4 byte, `type` 1 byte); payload rỗng là `length = 0`. Lý do: khớp §2 của `docs/PROTOCOL.md`, header cố định dễ cài đặt bằng "đọc đủ N byte, parse, lặp lại".

## Vấn đề đang mở

- `make clean` chạy `rm -rf build` nên xóa cả `build/.gitkeep` (suy ra từ Makefile, chưa quan sát trên repo thật); `make debug` gọi `make clean`.
- `tests/` đang rỗng và Makefile chưa có target test; chốt cách test khi tới M2.
- `docs/PROTOCOL.md` còn các mục chưa chốt: kích thước message tối đa, xử lý message quá lớn, xử lý message sai định dạng (hiện là ví dụ/lựa chọn "hoặc").
