# LIL_CHAT Protocol

Tài liệu này là nguồn sự thật cho giao thức. Điền từng mục **trước khi** viết `include/protocol.h`.
Mỗi mục nêu quyết định VÀ lý do. Chỗ nào chưa quyết thì để "CHƯA QUYẾT".

## 1. Truyền tải

- Giao thức tầng dưới: TCP.
- Cổng mặc định: CHƯA QUYẾT
- Địa chỉ nghe của server: CHƯA QUYẾT

## 2. Đóng khung message

TCP là luồng byte, không có ranh giới message.

- Cách đánh dấu hết một message: CHƯA QUYẾT
- Lý do chọn:
- Điều gì xảy ra nếu nội dung chứa chính ký hiệu đánh dấu đó?
- Kích thước message tối đa:
- Server làm gì khi message vượt quá tối đa?
- Cách xử lý một message đến thành nhiều đợt `recv`, và nhiều message đến trong một đợt `recv`:

## 3. Cấu trúc message

- Các trường và thứ tự:
- Kiểu và kích thước từng trường:
- Nếu có trường số nhiều byte, thứ tự byte (endianness):
- Mã hóa ký tự của nội dung:

## 4. Loại message

| Loại | Hướng (client→server / server→client) | Mục đích |
| ---- | ------------------------------------- | -------- |
|      |                                       |          |

- Cách phân biệt lệnh và tin nhắn thường:

## 5. Vòng đời kết nối

- Client vào: có bước chào/đặt tên không?
- Client thoát bình thường (đóng kết nối đàng hoàng):
- Client mất kết nối đột ngột. Server phát hiện bằng cách nào?
- Giới hạn số client:

## 6. Lỗi

- Server báo lỗi cho client thế nào?
- Message sai định dạng: bỏ qua, báo lỗi, hay ngắt kết nối?

## 7. Ví dụ

(Một đoạn hội thoại mẫu, ghi rõ từng byte gửi trên dây, sau khi đã quyết xong các mục trên.)
