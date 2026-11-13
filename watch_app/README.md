# Navigation Watch App - Huawei Watch GT 3 SE

Ứng dụng dẫn đường trên đồng hồ Huawei Watch GT 3 SE, nhận dữ liệu từ điện thoại qua P2P messaging và hiển thị chỉ dẫn navigation trên màn hình tròn 466x466px.

## Tính năng

- **Hiển thị chỉ dẫn rẽ**: Icon mũi tên, khoảng cách, tên đường, ETA
- **Rung cảnh báo**: Rung ngắn khi sắp rẽ, rung dài khi tới nơi
- **Màn hình chờ kết nối**: Animation loading khi chưa nhận data từ phone
- **La bàn**: Hiển thị hướng la bàn sử dụng compass sensor
- **Dark theme**: Giao diện nền đen, chữ trắng/xanh lá/vàng, tối ưu đọc ngoài nắng
- **Đa ngôn ngữ**: Hỗ trợ tiếng Anh (en-US) và tiếng Việt (vi-VN)

## Cấu trúc Project

```
watch_app/
├── config.json                 # App config (deviceType: liteWearable, API 6)
├── app.js                      # App entry point & lifecycle
├── pages/
│   ├── index/                  # Trang dẫn đường chính
│   │   ├── index.hml           # Layout template
│   │   ├── index.css           # Styles (dark theme, high contrast)
│   │   └── index.js            # Logic: nhận P2P messages, cập nhật UI, rung
│   ├── waiting/                # Trang chờ kết nối
│   │   ├── waiting.hml         # Layout với animation dots
│   │   ├── waiting.css         # Styles
│   │   └── waiting.js          # Logic: lắng nghe kết nối, animation
│   └── compass/                # Trang la bàn
│       ├── compass.hml         # Layout với kim la bàn
│       ├── compass.css         # Styles
│       └── compass.js          # Logic: đọc compass sensor
├── common/
│   ├── images/                 # Thư mục icon (xem README bên trong)
│   │   └── README.md           # Danh sách icon cần tạo
│   └── constants.js            # Hằng số, icon mapping, màu sắc
├── i18n/
│   ├── en-US.json              # Chuỗi tiếng Anh
│   └── vi-VN.json              # Chuỗi tiếng Việt
└── README.md                   # File này
```

## Yêu cầu hệ thống

- **Đồng hồ**: Huawei Watch GT 3 SE (hoặc tương thích HarmonyOS Lite Wearable)
- **Điện thoại**: Huawei phone với Huawei Health app & Wear Engine SDK
- **DevEco Studio**: phiên bản hỗ trợ Lite Wearable (DevEco Studio 3.x+)
- **API Level**: 6 trở lên

## Hướng dẫn Build & Deploy

### 1. Cài đặt DevEco Studio

1. Tải [DevEco Studio](https://developer.huawei.com/consumer/en/deveco-studio/) từ Huawei Developer
2. Cài đặt và cấu hình SDK cho **Lite Wearable**

### 2. Mở project

1. Mở DevEco Studio
2. Chọn **File → Open** và navigate tới thư mục `watch_app/`
3. DevEco Studio sẽ tự nhận diện project qua `config.json`

### 3. Thêm icon (tùy chọn)

1. Tạo các file icon PNG 80x80px theo hướng dẫn trong `common/images/README.md`
2. Đặt vào thư mục `common/images/`
3. Hiện tại app dùng Unicode arrows làm fallback nên vẫn chạy được khi chưa có icon

### 4. Build

```bash
# Trong DevEco Studio:
# Build → Build Hap(s)/APP(s) → Build Hap(s)
```

Hoặc sử dụng command line:
```bash
# Chạy từ thư mục project root
hpm build
```

### 5. Deploy lên đồng hồ

#### Cách 1: Qua DevEco Studio (khuyến nghị khi dev)
1. Kết nối đồng hồ qua USB hoặc WiFi debug
2. Chọn **Run → Run 'entry'** trong DevEco Studio
3. Chọn device GT 3 SE từ danh sách

#### Cách 2: Sideload qua adb
```bash
# Kết nối đồng hồ
hdc tconn <device-ip>:5555

# Cài đặt HAP
hdc install <path-to-built-hap>
```

#### Cách 3: Phát hành qua AppGallery Connect
1. Đăng ký tài khoản [AppGallery Connect](https://developer.huawei.com/consumer/en/service/josp/agc/index.html)
2. Tạo project và upload HAP file
3. Submit review và phát hành

## Protocol P2P

### Navigation Update
App nhận JSON từ phone companion qua Wear Engine P2P messaging:

```json
{
  "type": "nav_update",
  "maneuver": "turn_right",
  "distance": "120m",
  "street": "Đường Lê Lợi",
  "eta": "18:45",
  "remaining_km": "3.5",
  "vibrate": true
}
```

**Các giá trị `maneuver`:**

| Giá trị | Mô tả | Icon |
|---------|--------|------|
| `straight` | Đi thẳng | ↑ |
| `turn_left` | Rẽ trái | ← |
| `turn_right` | Rẽ phải | → |
| `slight_left` | Chếch trái | ↖ |
| `slight_right` | Chếch phải | ↗ |
| `sharp_left` | Rẽ gấp trái | ⬅ |
| `sharp_right` | Rẽ gấp phải | ➡ |
| `u_turn` | Quay đầu | ↩ |
| `roundabout` | Vòng xuyến | ⟳ |
| `arrive` | Đã tới | 🏁 |
| `depart` | Xuất phát | 🚀 |

### Connection Status
```json
{
  "type": "connection",
  "status": "connected"
}
```

## Luồng hoạt động

```
App khởi động
    → Hiển thị trang Waiting (animation dots)
    → Lắng nghe P2P message từ phone
    
Nhận "connection: connected"
    → Cập nhật trạng thái kết nối
    
Nhận "nav_update"
    → Chuyển sang trang Index (navigation)
    → Hiển thị icon + khoảng cách + tên đường + ETA
    → Rung nếu vibrate=true
    
Timeout 30s không nhận message
    → Hiển thị cảnh báo "Mất tín hiệu"
    
Timeout 60s
    → Quay về trang Waiting

Swipe sang Compass page
    → Hiển thị la bàn real-time từ sensor
```

## Xử lý Edge Cases

- **Mất kết nối**: Hiển thị thanh cảnh báo đỏ, sau 60s quay về Waiting
- **Data null/undefined**: Hiển thị giá trị mặc định (`--`, `Đường không xác định`)
- **Sensor la bàn lỗi**: Hiển thị thông báo lỗi, giữ giá trị 0°
- **Maneuver không hợp lệ**: Fallback icon `↑` (straight)
- **Chuỗi đường dài**: Text overflow ellipsis

## Ghi chú phát triển

- Toàn bộ comment trong code bằng tiếng Việt
- Dùng Unicode arrows làm fallback cho icon (không cần file ảnh để chạy)
- Config đã khai báo đầy đủ permissions: VIBRATE, INTERNET, BLUETOOTH, NETWORK_INFO
- Thiết kế responsive cho màn hình tròn 466x466px
- Tối ưu dark theme cho đọc dưới ánh nắng
