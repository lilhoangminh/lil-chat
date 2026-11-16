# LIL_CHAT - Protocol

Tài liệu này là nguồn sự thật cho giao thức. Điền từng mục **trước khi** viết `include/protocol.h`.
Mỗi mục nêu quyết định VÀ lý do. Chỗ nào chưa quyết thì để "CHƯA QUYẾT".

## 1. Truyền tải

- Giao thức tầng dưới: TCP.
- Cổng mặc định: 8080.
- Địa chỉ nghe của server: INADDR_ANY (0.0.0.0).

## 2. Đóng khung message

TCP là luồng byte, không có ranh giới message.

- Cách đánh dấu hết một message: Tiền tố gồm 4 bytes (kiểu uint32_t, Network Byte Order) quy định độ dài (payload length) của gói tin tiếp theo.
- Lý do chọn: Tránh hoàn toàn lỗi dính gói (sticky packets) hoặc đứt quãng gói (fragmentation) của TCP, không bị giới hạn bởi ký tự xuống dòng trong nội dung chat.
- Điều gì xảy ra nếu nội dung chứa chính ký hiệu đánh dấu đó: Không ảnh hưởng, vì hệ thống đọc đúng số byte được định nghĩa bởi độ dài ở 4 byte đầu tiên thay vì tìm kiếm ký tự kết thúc.
- Kích thước message tối đa: Ví dụ: 1024 hoặc 4096 bytes (đủ cho một đoạn tin nhắn chat trên terminal).
- Server làm gì khi message vượt quá tối đa: Ngắt kết nối client đó (disconnect) hoặc gửi về gói tin lỗi và bỏ qua payload thừa để tránh tràn bộ nhớ đệm (buffer overflow).
- Cách xử lý một message đến thành nhiều đợt `recv`, và nhiều message đến trong một đợt `recv`: Sử dụng vòng lặp bộ đệm (read buffer/ring buffer) để tích lũy dữ liệu byte cho đến khi nhận đủ số byte của 4-byte header, sau đó tiếp tục đọc đủ phần payload theo đúng chiều dài đã khai báo.

## 3. Cấu trúc message

- Các trường và thứ tự:

* length (4 bytes): Tổng độ dài phần phía sau (hoặc độ dài payload).
* type (1 byte): Loại message (chat, command, join, error...).
* payload (N bytes): Nội dung thông điệp (ví dụ: chuỗi ký tự UTF-8 / ASCII).

- Kiểu và kích thước từng trường: uint32_t cho length, uint8_t cho type, mảng char[] cho payload.
- Nếu có trường số nhiều byte, thứ tự byte (endianness): Bắt buộc dùng Network Byte Order (Big-Endian) thông qua các hàm chuẩn htonl / ntohl, htons / ntohs để đảm bảo tính độc lập kiến trúc (nếu sau này chạy trên các máy khác nhau).
- Mã hóa ký tự của nội dung: UTF-8 hoặc ASCII thuần túy trên terminal.

## 4. Loại message

| Loại       | Hướng (client→server / server→client) | Mục đích                                                |
| ---------- | ------------------------------------- | ------------------------------------------------------- |
| MSG_JOIN   | Client -> Server                      | Gửi tên đăng nhập (username) khi vừa kết nối            |
| MSG_CHAT   | Client -> Server / Server -> Client   | Gửi/Nhận nội dung chat thông thường                     |
| MSG_SYSTEM | Server -> Client                      | Thông báo hệ thống (ví dụ: "A đã tham gia phòng chat"). |
| MSG_ERROR  | Server -> Client                      | Báo lỗi (ví dụ: "Tên đã tồn tại", "Tin nhắn quá dài").  |

- Cách phân biệt lệnh và tin nhắn thường: Tin nhắn bắt đầu bằng tiền tố đặc biệt (ví dụ ký tự / như /quit, /list) sẽ được xử lý ở command_handler.c, còn lại là tin nhắn chat broadcast bình thường.

## 5. Vòng đời kết nối

- Client vào: Có bước chào/đặt tên (MSG_JOIN) ngay sau khi thiết lập kết nối TCP thành công. Server kiểm tra tính hợp lệ của tên.
- Client thoát bình thường (đóng kết nối đàng hoàng): Client gửi lệnh thoát (hoặc đóng socket), server nhận tín hiệu EOF (recv trả về 0), tiến hành dọn dẹp tài nguyên trong client_list.c.
- Client mất kết nối đột ngột. Server phát hiện bằng cách nào: Server phát hiện khi hàm recv() hoặc poll() trả về lỗi/ngắt kết nối bất thường, hoặc khi quá trình gửi (send()) gặp tín hiệu SIGPIPE / lỗi socket.
- Giới hạn số client: Đặt một hằng số cố định ban đầu cho mảng quản lý client (ví dụ: MAX_CLIENTS = 10 hoặc 32) để đơn giản hóa việc quản lý bộ nhớ ở Milestone đầu.

## 6. Lỗi

- Server báo lỗi cho client thế nào: Gửi một gói tin loại MSG_ERROR kèm theo chuỗi mô tả lỗi.
- Message sai định dạng: Server ngắt kết nối client đó ngay lập tức để bảo vệ tính toàn vẹn của tiến trình server khỏi các dữ liệu rác hoặc tấn công tràn bộ nhớ.

## 7. Ví dụ

Sau khi chốt các phần trên, có thể mô tả một chuỗi byte hex/ASCII minh họa gói tin gửi qua lại (ví dụ: 4 byte độ dài + 1 byte type + chuỗi payload "Hello").
