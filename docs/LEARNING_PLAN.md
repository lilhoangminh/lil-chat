# LIL_CHAT — Kế hoạch học-và-làm (M0 → M6)

Bám sát bảng milestone trong `PROGRESS.md`. Mỗi milestone có đủ 4 phần: (a) mục tiêu quan sát được, (b) kiến thức cần học, (c) ánh xạ vào file và luồng dữ liệu, (d) thực hành và kiểm thử.

## Cách dùng tài liệu này

- Tên hàm, kiểu dữ liệu và chữ ký trong phần (c) là **đề xuất**. Theo `AGENTS.md`, giao diện công khai chỉ được chốt khi vào milestone tương ứng và sau khi bạn duyệt.
- Kế hoạch **không chứa code hoàn chỉnh**. Mặc định bạn tự viết, tôi review; hoặc tôi viết mẫu từng hàm nhỏ kèm giải thích nếu bạn yêu cầu.
- Đầu mỗi milestone: tôi giảng lý thuyết và luồng dữ liệu, rồi hỏi bạn chọn **tự viết** hay **xem mẫu từng hàm**. Cuối milestone: kiểm thử theo phần (d), rồi cập nhật `PROGRESS.md` (mục Hiện tại và Quyết định thiết kế) trước khi sang mốc kế tiếp.
- Mỗi lần có file `.c` mới, thêm tên file vào `COMMON_SRCS` / `SERVER_SRCS` / `CLIENT_SRCS` trong Makefile (quyết định M0).

## Ba mức "xong" (áp dụng cho mọi milestone)

| Mức                | Ý nghĩa                                                                                | Bằng chứng                              |
| ------------------ | -------------------------------------------------------------------------------------- | --------------------------------------- |
| 1. Biên dịch được  | `make` không lỗi, không warning dưới `-Wall -Wextra -Wpedantic`                        | Kết quả `make`                          |
| 2. Chạy đúng       | Đạt tiêu chí "Xong khi" bằng test thực tế, gồm cả trường hợp biên                      | Các bước test ở phần (d)                |
| 3. An toàn khi lỗi | Đúng cả khi có lỗi/ngắt kết nối/dữ liệu xấu; `make debug` (ASan + UBSan) không báo lỗi | Test lỗi ở phần (d) + chạy `make debug` |

Chỉ đánh dấu một milestone là xong khi đạt cả ba mức. Chạy được ở trường hợp bình thường là chưa đủ.

## Các quyết định đã chốt (tóm tắt từ `PROGRESS.md`)

- Nguồn liệt kê tường minh trong Makefile; `main()` là điểm vào của hai chương trình.
- Khung gói: `length` (4 byte, network byte order) chỉ tính payload, rồi `type` (1 byte), rồi payload. Header cố định 5 byte.
- `MAX_PAYLOAD` = 4096. Server kiểm tra `length` ngay sau khi đọc header.
- Lỗi giao thức: gửi `MSG_ERROR` rồi đóng kết nối (nếu `send` lỗi vẫn đóng).
- M3 dùng một thread với `poll()`, không dùng thread.

## Quyết định còn mở và mốc sẽ chốt

| Quyết định                                                                                                        | Chốt ở                          |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| Mã số cụ thể của từng `type` (`MSG_JOIN`, `MSG_CHAT`, `MSG_SYSTEM`, `MSG_ERROR`)                                  | Đầu M2                          |
| Cách chạy test: thêm target `make test` vào Makefile (thay đổi build system, cần bạn duyệt)                       | Đầu M2                          |
| `MAX_CLIENTS` (10 hay 32)                                                                                         | Đầu M3                          |
| Gửi tin: đến mọi người hay chỉ người khác; xử lý `send` chặn khi client chậm                                      | Đầu M3                          |
| Lỗi mức ứng dụng (tên trùng, lệnh sai): đóng kết nối hay cho thử lại                                              | Đầu M3 (tên trùng) và M5 (lệnh) |
| Phát hiện kết nối chết: TCP keepalive hay heartbeat ở tầng ứng dụng (heartbeat cần thêm `type`, tức đổi PROTOCOL) | Đầu M6                          |
| `make clean` xóa `build/.gitkeep`                                                                                 | Tùy bạn, lúc nào tiện           |

## Tổng quan luồng giao tiếp (đích cuối)

```text
Client (main.c, client_net.c)                Server (main.c, connection.c, client_list.c,
                                                     broadcast.c, command_handler.c)
 stdin ──> gói MSG_CHAT ── TCP ──────────────> poll() ──> recv vào buffer riêng của client
                                               ghép đủ gói (protocol.c) ──> chat? ──> broadcast
 màn hình <── gói đến ── TCP <──────────────── lệnh "/..."? ──> command_handler
Dùng chung: protocol.c (mã hóa/giải mã gói, gửi/nhận đủ byte), util.c (hàm phụ dùng chung)
```

Hướng phụ thuộc: `client/` và `server/` được phép dùng `common/`; `common/` không được phụ thuộc ngược lại (theo `docs/ARCHITECTURE.md`).

---

## M0 — Khung dự án (ĐÃ XONG, 2026-11-16)

### a) Mục tiêu chức năng

`make` và `make debug` chạy không lỗi, không warning; `build/lil_chat_server` và `build/lil_chat_client` chạy và thoát với mã 0.

### b) Kiến thức đã dùng

- **Translation unit** và hai giai đoạn **biên dịch** (mỗi `.c` thành `.o`) rồi **link** (ghép các `.o` thành chương trình). Lỗi `undefined reference to main` xảy ra ở giai đoạn link, vì điểm vào `main` không có trong bất kỳ `.o` nào.
- Vì sao `-Wpedantic` cảnh báo file `.c` rỗng: chuẩn C yêu cầu translation unit có ít nhất một khai báo.
- Makefile: quy tắc mẫu `%.o: %.c`, `-MMD -MP` (tự sinh phụ thuộc header), biến `CFLAGS`/`LDFLAGS`, target `debug` với `-fsanitize=address,undefined`.

### c) Ánh xạ file

`Makefile`, `src/server/main.c`, `src/client/main.c` (mỗi file một `main()` tối thiểu). Các file còn lại giữ rỗng đến khi cần.

### d) Kiểm thử đã làm

`make`, chạy hai binary, `make debug`: đạt (WSL2, gcc 11.4). Còn lại: quyết định xử lý `build/.gitkeep` (xem bảng quyết định mở).

---

## M1 — Một client nói chuyện với một server qua TCP (echo)

### a) Mục tiêu chức năng

Chạy `./build/lil_chat_server` ở terminal 1 và `./build/lil_chat_client 127.0.0.1 8080` ở terminal 2. Gõ một dòng ở client: server nhận được, trả lại nguyên văn, client in ra. Client thoát (Ctrl-D) thì server không crash. Cổng mặc định 8080 (theo `docs/PROTOCOL.md` §1).

Giới hạn cố ý của M1: **chưa có framing**. Server và client chỉ chuyển byte thô, nên với dòng ngắn thì chạy được, nhưng chưa đúng với mọi trường hợp TCP. M2 sẽ sửa điều này.

### b) Kiến thức cần học

- **File descriptor** (số nguyên đại diện cho socket) và lỗi hệ thống: `errno`, `perror`/`strerror`. Quy ước dự án: hàm trả `0` thành công, `-1` thất bại.
- **Luồng server:** `socket(AF_INET, SOCK_STREAM, 0)`, `setsockopt(SO_REUSEADDR)` (nếu không có, chạy lại server ngay sẽ gặp "Address already in use" do trạng thái TIME_WAIT), `bind` với `struct sockaddr_in` (`htons` cho cổng, `INADDR_ANY`), `listen`, `accept`.
- **Luồng client:** `socket`, `inet_pton` (đổi chuỗi IP thành nhị phân), `connect`.
- **`send`/`recv`:** `recv` trả số byte đọc được (có thể ít hơn số bạn yêu cầu), `0` nghĩa là bên kia đã đóng kết nối, `-1` là lỗi (`EINTR` thì thử lại). `send` cũng có thể gửi thiếu byte, nên cần vòng lặp gửi đủ.
- **`SIGPIPE`:** ghi vào socket mà bên kia đã đóng sẽ làm tiến trình bị kill, trừ khi bỏ qua tín hiệu (`signal(SIGPIPE, SIG_IGN)`) hoặc dùng cờ `MSG_NOSIGNAL` trong `send`. `AGENTS.md` yêu cầu xử lý việc này.
- **C cơ bản:** `argc`/`argv`, `strtol` để đọc cổng và kiểm tra lỗi, `fgets` đọc stdin, mảng `char` có kích thước cố định và NUL kết thúc chuỗi, `close`.

### c) Ánh xạ vào cây thư mục

- `include/server.h` + `src/server/connection.c`: đề xuất `int lil_server_listen(uint16_t port)` trả listen fd, hoặc `-1`.
- `include/client.h` + `src/client/client_net.c`: đề xuất `int lil_client_connect(const char *ip, uint16_t port)` trả socket fd, hoặc `-1`.
- `src/server/main.c`: gọi `lil_server_listen`, `accept` một client, vòng lặp `recv` rồi `send` lại cho đến khi `recv` trả `0`, rồi `close`.
- `src/client/main.c`: đọc `argv`, gọi `lil_client_connect`, vòng lặp `fgets` rồi `send` rồi `recv` rồi `printf`.
- Makefile: thêm `src/server/connection.c` vào `SERVER_SRCS`, `src/client/client_net.c` vào `CLIENT_SRCS`.

Luồng dữ liệu: `stdin → fgets → send → [TCP] → server recv → send → [TCP] → client recv → stdout`.

### d) Thực hành và kiểm thử

Thứ tự làm: (1) server lắng nghe, kiểm tra bằng `ss -ltn` thấy cổng 8080; (2) kiểm tra server bằng `nc 127.0.0.1 8080` trước khi có client; (3) viết client; (4) kiểm tra client bằng `nc -l 8080` đóng vai server.

Test cần chạy:

- **Bình thường:** gõ `hello`, thấy `hello` trả về.
- **Biên:** dòng rỗng; dòng dài gần kích thước buffer (ghi rõ hành vi thực tế và coi là hạn chế đã biết của M1).
- **Lỗi:** chạy server lần hai khi cổng đang dùng (phải báo lỗi `bind` và thoát mã khác 0); client kết nối khi không có server (báo "connection refused", không crash); client thoát bằng Ctrl-D và Ctrl-C (server không crash); server bị kill khi client đang chờ (client nhận `recv == 0` và thoát gọn).
- `make debug` rồi lặp lại các test trên, không có báo cáo ASan/UBSan.

---

## M2 — Đóng khung message theo `docs/PROTOCOL.md`

### a) Mục tiêu chức năng

Client gửi và nhận các gói theo đúng định dạng `length(4) | type(1) | payload`. Server (vẫn một client, vẫn echo) xử lý đúng: gói dài, hai gói gửi sát nhau trong một lần đến, một gói bị cắt thành nhiều mảnh, và gói lỗi (xem phần d). Hành vi lỗi theo §6: gửi `MSG_ERROR` rồi đóng kết nối.

### b) Kiến thức cần học

- **TCP là luồng byte:** một lần `recv` có thể trả nửa gói, hoặc một gói rưỡi, hoặc nhiều gói. Vì thế cần (1) vòng lặp **gửi đủ** và **đọc đủ** N byte, (2) buffer tích lũy.
- **Mã hóa nhị phân:** `uint32_t`/`uint8_t` (`<stdint.h>`); `htonl`/`ntohl` (`<arpa/inet.h>`) để đổi thứ tự byte; `memcpy` để ghi/đọc từng trường. **Không gửi nguyên `struct` qua mạng**, vì compiler có thể chèn padding và thứ tự byte phụ thuộc máy.
- **Parser tăng dần (incremental):** hàm nhận một buffer đang có `n` byte và trả về một trong ba kết quả: _chưa đủ dữ liệu_, _đã có một gói hoàn chỉnh (kèm số byte đã dùng)_, hoặc _lỗi giao thức_. Thiết kế này không phụ thuộc socket nên test được riêng, và M3 dùng lại nguyên vẹn cho `poll()`.
- **Kiểm tra giới hạn:** so `length` với `MAX_PAYLOAD` ngay khi có đủ 5 byte header, trước khi chờ hay đọc payload. Đây là biện pháp chống `length` vô lý (tới 4 tỷ).
- **Kiểm thử không cần socket:** dùng `assert` từ `<assert.h>`, không thêm thư viện test.

### c) Ánh xạ vào cây thư mục

- `include/protocol.h` + `src/common/protocol.c`. Đề xuất:
  - Hằng số: `LIL_HEADER_SIZE` (5), `LIL_MAX_PAYLOAD` (4096), các mã `type` (chốt đầu M2).
  - `size_t lil_encode_msg(uint8_t *out, size_t cap, uint8_t type, const void *payload, uint32_t len)`: ghi gói vào `out`, trả số byte đã ghi hoặc `0` nếu `cap` không đủ hay `len` quá lớn.
  - `int lil_decode_msg(const uint8_t *buf, size_t n, uint8_t *type, uint32_t *len, size_t *consumed)`: trả `1` đã có gói hoàn chỉnh, `0` chưa đủ, `-1` lỗi giao thức (`length` quá lớn hoặc `type` không hợp lệ). Payload nằm ngay sau header trong `buf`.
- `include/util.h` + `src/common/util.c`. Đề xuất: `int lil_send_all(int fd, const void *buf, size_t len)` (vòng lặp `send`, xử lý gửi thiếu và `EINTR`) và `int lil_recv_all(int fd, void *buf, size_t len)` (vòng lặp `recv` cho chế độ chặn của M2; cách phân biệt "đóng gọn" với "lỗi" chốt khi viết; M3 sẽ không dùng hàm này vì `poll` chỉ cho phép một `recv` mỗi lần).
- `src/server/main.c`, `src/client/main.c`: thay vòng `recv`/`send` thô bằng "đọc đủ 5 byte header, kiểm tra, đọc đủ payload" (chế độ chặn, một client). Server gặp lỗi giao thức thì gửi `MSG_ERROR` rồi `close`.
- Makefile: thêm `src/common/protocol.c`, `src/common/util.c` vào `COMMON_SRCS`; thêm target `make test` biên dịch và chạy `tests/test_protocol.c` (**cần bạn duyệt**, vì đổi build system).
- `tests/test_protocol.c`: test thuần cho `protocol.c`. (Git không theo dõi thư mục rỗng; nếu chưa có file nào trong `tests/` thì thêm `.gitkeep`.)

Luồng dữ liệu: `stdin → lil_encode_msg → lil_send_all → [TCP] → recv vào buffer → lil_decode_msg → xử lý → lil_encode_msg → lil_send_all → [TCP] → client giải mã → stdout`.

### d) Thực hành và kiểm thử

Thứ tự: (1) viết `lil_encode_msg` và test; (2) viết `lil_decode_msg` và test; (3) `lil_send_all`; (4) nối vào client/server; (5) test bằng `nc`.

**Unit test (không socket), trong `tests/test_protocol.c`:**

- Mã hóa `"Hello"` với type `T` cho đúng chuỗi byte `00 00 00 05 T 48 65 6C 6C 6F`.
- Giải mã: 0 byte; 4 byte (thiếu header); đủ header nhưng thiếu payload; đúng một gói; hai gói liền nhau (trả `consumed` của gói đầu); gói bị cắt ở mọi vị trí (đưa vào từng byte một); payload rỗng (`length = 0`).
- Biên: `length = 4096` hợp lệ; `4097` lỗi; `0xFFFFFFFF` lỗi; `type` không hợp lệ lỗi; `cap` quá nhỏ khi mã hóa.

**Test tích hợp bằng terminal** (server chạy sẵn, dùng `nc` và `xxd` để xem phản hồi nhị phân):

- Một gói: `printf '\x00\x00\x00\x05<T>Hello' | nc 127.0.0.1 8080 | xxd` (thay `<T>` bằng byte type thật).
- Hai gói trong một lần gửi: nối hai chuỗi `printf` trong cùng một lệnh.
- Gói bị cắt: `(printf '\x00\x00\x00'; sleep 1; printf '\x05<T>Hel'; sleep 1; printf 'lo') | nc 127.0.0.1 8080`.
- Gói dài (khoảng 4096 byte payload) và gói vừa quá giới hạn (4097): phải nhận `MSG_ERROR` rồi kết nối bị đóng.
- `type` lạ; client gửi `MSG_SYSTEM`: nhận `MSG_ERROR` rồi đóng.
- Client chết giữa chừng một gói: server không crash, không bị treo.
- Chạy toàn bộ bằng `make debug`.

---

## M3 — Nhiều client đồng thời và phát tin cho mọi người

### a) Mục tiêu chức năng

Mở 3 client cùng lúc. Một client gõ tin thì hai client còn lại nhận được (người gửi không nhận lại tin của chính mình; client tự in tin mình đã gửi). Client gửi `MSG_JOIN` kèm tên ngay sau khi kết nối; tin phát đi mang tên người gửi. Một client gửi dở một gói rồi im lặng không làm server đứng yên với những client khác.

### b) Kiến thức cần học

- **Vấn đề gốc:** `accept` và `recv` là lời gọi chặn. Một thread không thể chờ nhiều nơi cùng lúc nếu chỉ dùng chúng.
- **`poll()` (quyết định đã chốt):** `int poll(struct pollfd *fds, nfds_t nfds, int timeout)`. Với mỗi `struct pollfd` (`fd`, `events`, `revents`) bạn đăng ký `POLLIN` ("có dữ liệu để đọc"). Trả về `>0` là số phần tử có sự kiện, `0` là hết thời gian chờ, `-1` là lỗi (`EINTR` thì lặp lại). Phần tử có `fd < 0` bị `poll` bỏ qua, tiện cho ô trống trong mảng. Sau `poll` phải kiểm tra `POLLIN`, và cả `POLLHUP`/`POLLERR`/`POLLNVAL`.
- **Mỗi client cần buffer đọc riêng** (`LIL_HEADER_SIZE + LIL_MAX_PAYLOAD` byte) cùng số byte đang có. Mỗi lần `poll` báo đọc được thì làm **đúng một** `recv` vào buffer, rồi gọi `lil_decode_msg` lặp lại cho đến khi hết gói hoàn chỉnh, rồi dời phần dư về đầu buffer (`memmove`).
- **Quản lý bộ nhớ và sở hữu:** mảng cố định `MAX_CLIENTS`, mỗi phần tử có `fd`, `name`, buffer đọc, số byte đang có. `client_list` sở hữu bản ghi; `close(fd)` chỉ được gọi khi gỡ bản ghi.
- **Chuỗi an toàn:** sao chép tên có giới hạn và đảm bảo kết thúc bằng NUL; dựng chuỗi "tên: nội dung" bằng `snprintf` và kiểm tra giá trị trả về (không để vượt `LIL_MAX_PAYLOAD`).
- **Client cũng phải dùng `poll()`:** client phải chờ cùng lúc bàn phím (`STDIN_FILENO`) và socket, nếu không sẽ không nhận được tin của người khác khi đang chờ gõ. Lưu ý: đừng trộn `poll` với `fgets` (stdio có buffer riêng, `poll` không thấy dữ liệu đã nằm trong buffer đó); dùng `read(STDIN_FILENO, ...)` rồi tự tách dòng.
- **Cần cân nhắc (chốt đầu M3):** `send` cũng có thể chặn nếu client nhận chậm. Chấp nhận hạn chế này ở M3 (ghi rõ) hay thêm hàng đợi gửi cho mỗi client?

### c) Ánh xạ vào cây thư mục

- `include/server.h`: kiểu `lil_client` và `lil_client_list`.
- `src/server/client_list.c`. Đề xuất: `void lil_clients_init(...)`, `int lil_clients_add(..., int fd)` (trả chỉ số, hoặc `-1` nếu đầy), `void lil_clients_remove(..., int index)` (đóng `fd`, đặt ô về trống), `int lil_clients_set_name(...)`, `int lil_clients_name_in_use(...)`.
- `src/server/connection.c`: `lil_server_listen` (từ M1) và `int lil_server_accept(int listen_fd)` (xử lý `EINTR`).
- `src/server/broadcast.c`. Đề xuất: `int lil_broadcast(lil_client_list *list, int except_index, uint8_t type, const void *payload, uint32_t len)` (gọi `lil_encode_msg` một lần, rồi `lil_send_all` cho mỗi client còn hoạt động).
- `src/server/main.c`: vòng lặp chính, mỗi vòng dựng mảng `pollfd` từ listen fd và các client đang hoạt động; xử lý listen fd (chấp nhận client, nếu đầy thì gửi `MSG_ERROR` rồi đóng) và client fd (nhận, giải mã, `MSG_JOIN` đặt tên, `MSG_CHAT` phát đi).
- `src/client/client_net.c`, `src/client/main.c`: vòng lặp `poll` trên `{STDIN_FILENO, sockfd}`; gửi `MSG_JOIN` sau khi kết nối; nhận gói thì in ra.
- Makefile: thêm `client_list.c`, `broadcast.c` vào `SERVER_SRCS`.
- `tests/test_client_list.c`: test thuần cho cấu trúc dữ liệu (thêm, gỡ, đầy, tên trùng).

Luồng dữ liệu: `poll → [listen fd] accept → clients_add` / `poll → [client fd] recv → buffer → lil_decode_msg → MSG_JOIN: đặt tên | MSG_CHAT: lil_broadcast → các client khác`.

### d) Thực hành và kiểm thử

Thứ tự: (1) cấu trúc client_list + unit test; (2) server chấp nhận nhiều client nhưng chưa broadcast (in log); (3) broadcast; (4) client dùng `poll`.

- **Bình thường:** 3 client; tin của A đến B và C, tin của B đến A và C.
- **Tên:** tên trùng và tên quá dài (theo quyết định chốt ở đầu M3).
- **Giới hạn:** mở `MAX_CLIENTS + 1` kết nối (vòng lặp bash chạy nền `nc`): kết nối thừa nhận `MSG_ERROR` rồi bị đóng, các client cũ vẫn chat bình thường.
- **Chống chặn:** một client dùng `nc` gửi nửa gói rồi im lặng; các client khác vẫn chat được.
- **Ghép gói:** một client gửi hai gói liền nhau; một client gửi gói chia nhỏ (dùng `sleep` giữa các phần).
- **Lỗi giao thức:** client gửi `length` vượt giới hạn: client đó nhận `MSG_ERROR` và bị đóng, các client khác không bị ảnh hưởng.
- `make debug` rồi lặp lại các test trên.

---

## M4 — Xử lý ngắt kết nối

### a) Mục tiêu chức năng

Client thoát bình thường (Ctrl-D, Ctrl-C) hoặc bị `kill -9`: server không crash, không rò rỉ file descriptor, dọn đúng bản ghi trong danh sách client và thông báo cho những người còn lại bằng `MSG_SYSTEM` (ví dụ "A đã rời phòng"). Server nhận Ctrl-C thì đóng mọi kết nối và thoát gọn.

### b) Kiến thức cần học

- **Ba dấu hiệu ngắt kết nối:** `recv` trả `0` (bên kia đóng gọn); `recv` trả `-1` với `ECONNRESET` hoặc lỗi khác; `poll` báo `POLLHUP`/`POLLERR`. `send` thất bại với `EPIPE` (và `SIGPIPE` nếu chưa bỏ qua, xem M1). Mọi trường hợp đều dẫn tới cùng một hàm gỡ client.
- **Gỡ phần tử khi đang duyệt:** khi vòng lặp đang chạy trên mảng client mà một client bị gỡ giữa chừng (ví dụ `send` lỗi trong lúc broadcast), phải đảm bảo không truy cập ô đã gỡ và không bỏ sót ô khác. Cách đơn giản: chỉ đánh dấu ô trống trong lúc duyệt, ô trống có `fd = -1`.
- **`close` đúng một lần:** đóng hai lần một fd có thể đóng nhầm fd của kết nối khác vừa được hệ điều hành cấp lại số đó.
- **Tín hiệu:** `sigaction` (có sẵn nhờ `_POSIX_C_SOURCE`) để bắt `SIGINT`; chỉ đặt cờ kiểu `volatile sig_atomic_t` trong handler, vòng lặp chính kiểm tra cờ rồi tự dọn. `poll` bị ngắt bởi tín hiệu sẽ trả `-1` với `EINTR`; đây không phải lỗi.
- **Phát hiện rò rỉ:** LeakSanitizer đi kèm ASan khi chạy `make debug`; đếm fd của tiến trình bằng `ls /proc/<pid>/fd | wc -l`; `ss -tn` xem trạng thái kết nối.

### c) Ánh xạ vào cây thư mục

- `src/server/client_list.c`: hoàn thiện `lil_clients_remove` (đóng fd đúng một lần, xóa buffer và tên, đánh dấu ô trống).
- `src/server/connection.c`: hàm đóng/gỡ một client (`recv` về `0`/lỗi/`POLLHUP`, và đường "đóng sau `MSG_ERROR`" của M2/M3 dùng chung hàm này).
- `src/server/broadcast.c`: nếu `send` tới một client thất bại thì gỡ client đó mà không làm hỏng vòng duyệt; `MSG_SYSTEM` báo rời phòng.
- `src/server/main.c`: cài `SIGINT`, thoát vòng lặp khi có cờ, dọn tất cả client rồi đóng listen fd.
- `src/client/main.c`: khi `recv` về `0` thì in thông báo mất kết nối rồi thoát gọn (chưa kết nối lại, việc đó thuộc M6).

Luồng dữ liệu: `poll → recv == 0 / lỗi / POLLHUP → lil_clients_remove → lil_broadcast(MSG_SYSTEM "đã rời phòng") → các client còn lại`.

### d) Thực hành và kiểm thử

- **Bình thường:** client Ctrl-D; client Ctrl-C; `kill -9` tiến trình client: server vẫn chạy, các client còn lại nhận thông báo.
- **Giữa chừng:** client gửi nửa gói rồi chết (buffer dở bị bỏ, không crash); client chết đúng lúc server đang broadcast.
- **Rò rỉ:** ghi số fd của server (`ls /proc/$(pidof lil_chat_server)/fd | wc -l`), chạy vòng lặp 100 lần kết nối rồi ngắt, số fd phải trở về mức ban đầu.
- **Dừng server:** Ctrl-C ở server, ASan/LeakSanitizer không báo rò rỉ, các client nhận ngắt kết nối và thoát gọn.
- **Chưa kiểm được ở M4:** mất mạng giả (không có tín hiệu đóng). Để M6.
- `make debug` cho tất cả test trên.

---

## M5 — Lệnh (đổi tên, thoát, danh sách)

### a) Mục tiêu chức năng

Tin nhắn bắt đầu bằng `/` được xử lý như lệnh (theo §4 PROTOCOL: lệnh dùng chung `MSG_CHAT`, phân biệt bằng tiền tố `/`). Tối thiểu ba lệnh: `/nick <tên>` đổi tên (người khác nhận `MSG_SYSTEM` báo đổi tên), `/list` liệt kê người đang online, `/quit` thoát. Lệnh sai hoặc tên không hợp lệ nhận `MSG_ERROR` và kết nối vẫn giữ (chốt lại ở đầu M5).

### b) Kiến thức cần học

- **Xử lý chuỗi an toàn trong C:** tách lệnh và đối số bằng `strncmp`, `strchr` hoặc tự duyệt; sao chép có giới hạn bằng `snprintf`/`memcpy` rồi tự gắn NUL; tránh `strcpy`/`strcat`. Chuỗi nhận từ mạng **không có NUL sẵn**, nên luôn làm việc với cặp (con trỏ, độ dài).
- **Kiểm tra đầu vào:** tên dài từ 1 đến 32 byte (đề xuất, chốt đầu M5), không chứa khoảng trắng/ký tự điều khiển, không trùng với người đang online.
- **Phân loại lỗi:** lỗi giao thức (đóng kết nối, theo §6) khác với lỗi ứng dụng (lệnh sai, tên trùng: báo lại, không đóng). Quyết định này cần xác nhận trước khi viết.
- **Chọn cấu trúc xử lý đơn giản:** với ba lệnh, một chuỗi `if`/`else if` rõ ràng là đủ, không cần bảng con trỏ hàm hay abstraction.

### c) Ánh xạ vào cây thư mục

- `src/server/command_handler.c` (khai báo trong `include/server.h`). Đề xuất: `int lil_handle_command(lil_client_list *list, int client_index, const char *text, size_t len)`. Trả `0` đã xử lý, `-1` nếu không phải lệnh hợp lệ hay cần đóng kết nối (quy ước trả giá trị chốt khi viết).
- `src/server/main.c`: sau khi giải mã `MSG_CHAT`, nếu `text[0] == '/'` thì gọi `lil_handle_command`, ngược lại `lil_broadcast`.
- `src/server/client_list.c`: dùng lại `lil_clients_name_in_use`, `lil_clients_set_name`.
- `src/server/broadcast.c`: `MSG_SYSTEM` cho đổi tên và rời phòng; `/list` trả riêng cho người gõ.
- `tests/test_command.c`: nếu phần tách lệnh được viết thành hàm thuần (nhận chuỗi, trả tên lệnh và đối số), test không cần socket.

Luồng dữ liệu: `MSG_CHAT đến server → text[0] == '/'? → lil_handle_command → (đổi client_list / gửi MSG_SYSTEM / gửi MSG_ERROR) → client(s)`.

### d) Thực hành và kiểm thử

- **Bình thường:** `/nick bob` (người khác nhận thông báo), `/list` (đủ tên), `/quit` (người gõ bị đóng gọn, người khác nhận thông báo rời phòng).
- **Lệnh sai:** `/foo`, `/nick` không đối số, `/nick` với tên rỗng, tên 33 byte, tên có khoảng trắng, tên đã có người dùng: mỗi trường hợp nhận `MSG_ERROR`, server không crash, kết nối giữ nguyên (nếu quyết định đóng kết nối thì kiểm tra đúng như vậy).
- **Biên:** tin chỉ có `/`; tin có độ dài đúng 4096 byte bắt đầu bằng `/`; tin chat thường có chứa `/` ở giữa (không phải lệnh).
- `make debug` cho tất cả test trên; unit test cho phần tách lệnh nếu có.

---

## M6 — LAN, kết nối lại, chạy liên tục

### a) Mục tiêu chức năng

Hai máy khác nhau trong cùng mạng LAN chat được với nhau qua server. Khi mất mạng hoặc server khởi động lại, client tự kết nối lại và vào phòng bằng tên cũ. Server chạy nhiều giờ với vài client mà không rò rỉ bộ nhớ hay fd, và không giữ mãi bản ghi của client đã chết.

### b) Kiến thức cần học

- **Địa chỉ trong LAN:** server đã nghe ở `INADDR_ANY` (0.0.0.0), tức nhận kết nối từ mọi giao diện mạng. Client cần IP LAN của máy chạy server (`ip addr`). Nếu muốn nhập tên máy thay vì IP thì học `getaddrinfo` (chỉ làm khi thật cần).
- **WSL2 và mạng:** theo mặc định WSL2 nằm sau NAT của Windows, nên máy khác trong LAN không tới được server chạy trong WSL2 nếu chưa cấu hình. Hai hướng thường dùng: chuyển tiếp cổng từ Windows vào WSL2 (`netsh interface portproxy`) hoặc bật mirrored networking trong `.wslconfig` (Windows 11 phiên bản đủ mới); cả hai cần mở Windows Firewall cho cổng 8080. Hãy kiểm tra lại tài liệu Microsoft hiện hành khi làm, vì cách cấu hình thay đổi theo phiên bản.
- **Kết nối chết im lặng (half-open):** nếu mạng đứt mà không có gói `FIN`/`RST`, server không biết client đã mất; bản ghi cũ còn nằm trong danh sách và tên cũ vẫn bị coi là đang dùng, nên client kết nối lại bằng tên cũ sẽ bị từ chối. Cần cơ chế phát hiện: **TCP keepalive** (`SO_KEEPALIVE`, rồi `TCP_KEEPIDLE`/`TCP_KEEPINTVL`/`TCP_KEEPCNT`) hoặc **heartbeat ở tầng ứng dụng** (thêm `type` mới, tức phải sửa `docs/PROTOCOL.md`). Chốt đầu M6.
- **Kết nối lại phía client:** vòng lặp thử lại `connect` với khoảng chờ tăng dần (backoff) và giới hạn; gửi lại `MSG_JOIN` với tên cũ; xử lý đúng khi bị từ chối. Cần quyết định hành vi khi hết số lần thử.
- **Chạy lâu dài:** theo dõi `RSS` của tiến trình (`ps -o rss`), đếm fd theo thời gian, chạy dưới ASan.

### c) Ánh xạ vào cây thư mục

- `src/client/client_net.c`: hàm kết nối lại (đề xuất `int lil_client_reconnect(...)`) dùng lại `lil_client_connect` (M1); trạng thái "đang kết nối lại" quản lý trong `src/client/main.c`.
- `src/server/connection.c`: đặt tùy chọn keepalive trên mỗi socket client sau `accept` (hoặc xử lý heartbeat nếu chọn hướng đó, kèm đổi `protocol.h`/`protocol.c` và PROTOCOL).
- `src/server/client_list.c`, `src/server/main.c`: gỡ client khi keepalive/heartbeat báo chết, giải phóng tên cũ.
- `docs/PROTOCOL.md`: ghi quyết định phát hiện kết nối chết và hành vi kết nối lại.
- `README.md`: cập nhật mục Run (hiện ghi "Not yet available") khi chạy được.

Luồng dữ liệu: `client recv == 0/lỗi → backoff → connect → MSG_JOIN(tên cũ) → server (đã gỡ bản ghi cũ nhờ keepalive) → vào phòng`.

### d) Thực hành và kiểm thử

- **LAN:** server trên máy A, client trên máy B; chat hai chiều. Ghi lại cấu hình mạng đã dùng để lặp lại được.
- **Kết nối lại:** tắt rồi bật server khi client đang chạy: client tự vào lại trong thời gian giới hạn đã chọn.
- **Mất mạng im lặng:** tắt Wi-Fi của máy client một lúc rồi bật lại; sau thời gian keepalive/heartbeat, server gỡ bản ghi cũ, client vào lại bằng tên cũ được chấp nhận.
- **Giới hạn thử lại:** server tắt hẳn: client dừng sau số lần thử đã quy định và báo rõ, không lặp vô hạn nếu quyết định như vậy.
- **Chạy dài:** 3 client chạy trên 30 phút (script gửi tin định kỳ), RSS và số fd của server ổn định; `make debug` không báo lỗi.

---

## Kết thúc mỗi milestone (quy trình chung)

1. Chạy đủ các test ở phần (d) và `make debug`; ghi lại cái gì đã chạy và kết quả, phân biệt với phần chỉ suy luận.
2. Cập nhật `PROGRESS.md`: mục Hiện tại, Quyết định thiết kế (ngày, quyết định, lý do), Vấn đề đang mở.
3. Nếu có quyết định giao thức mới thì cập nhật `docs/PROTOCOL.md`; nếu đổi thiết kế module thì cập nhật `docs/ARCHITECTURE.md`; cập nhật `README.md` khi cách chạy thay đổi.
4. Commit nhỏ, theo dạng `module: what changed`, làm trên nhánh tính năng; chỉ merge vào `main` khi bạn yêu cầu.
