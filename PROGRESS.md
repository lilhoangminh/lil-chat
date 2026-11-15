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

- Milestone đang làm: M0
- Đã xong: Makefile, AGENTS.md, README.md, khung `docs/PROTOCOL.md`
- Việc tiếp theo: xử lý trạng thái build của bộ khung trước; sau đó tiếp tục quyết định protocol trong `docs/PROTOCOL.md` rồi mới thiết kế `include/protocol.h`.

## Kiểm tra trạng thái thực tế (2026-11-15)

- Đã chạy `make` trên snapshot hiện tại trong môi trường Linux/GCC.
- Kết quả: build thất bại ở bước link server với `undefined reference to main`; các translation unit rỗng cũng phát cảnh báo `-Wpedantic`.
- Nguyên nhân trực tiếp: Makefile đưa các file `.c` hiện có vào build dù chúng đang rỗng; chưa có định nghĩa `main()` trong `src/server/main.c` (và client cũng chưa có implementation).
- Chưa sửa Makefile hoặc source code. Cần chọn cách xử lý bootstrap và xác nhận tiêu chí M0 trước khi đánh dấu M0 hoàn thành.

## Quyết định thiết kế

(Ghi theo dạng: ngày, quyết định, lý do. Chưa có.)

## Vấn đề đang mở

(Chưa có.)
