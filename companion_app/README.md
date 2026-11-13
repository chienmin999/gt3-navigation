# 📱 GT3 Navigation — Flutter Companion App (Android & iOS)

Ứng dụng đồng hành trên điện thoại dành cho **Huawei Watch GT 3 SE**, tương tự tính năng của **Gnavi (Trần Hùng)**:
- 🗺️ Bản đồ & Định vị trực quan (OpenStreetMap & OSRM Engine miễn phí)
- 🔍 Tìm kiếm địa điểm, địa chỉ tiếng Việt mượt mà (Nominatim Geocoding)
- 🧭 Tính toán lộ trình Turn-by-Turn theo thời gian thực (khoảng cách còn lại, ETA, tên đường tiếp theo)
- ⌚ Bắn tín hiệu điều hướng & rung cảnh báo sang đồng hồ GT 3 SE qua Huawei Wear Engine
- 🍏 **Hỗ trợ đầy đủ iPhone (iOS)** mà **KHÔNG CẦN CÓ MÁY MAC** nhờ build tự động trên Cloud & cài qua Sideloadly!

---

## 📂 Cấu trúc mã nguồn

```
companion_app/
├── lib/
│   ├── config/              # App config, routing, theming
│   ├── models/              # RouteInfo, TurnInstruction, Place, WatchConnection
│   ├── screens/
│   │   ├── home_screen.dart           # Bản đồ chính, chọn điểm đến
│   │   ├── search_screen.dart         # Tìm kiếm địa điểm
│   │   ├── navigation_screen.dart     # Điều hướng Turn-by-Turn trực tiếp
│   │   ├── watch_connect_screen.dart  # Trạng thái kết nối & test ping đồng hồ
│   │   └── settings_screen.dart       # Cấu hình rung, màn hình, ngưỡng cảnh báo
│   ├── services/
│   │   ├── directions_service.dart    # Gọi OSRM & Nominatim API
│   │   ├── location_service.dart      # GPS background & realtime updates
│   │   ├── navigation_service.dart    # Logic tính bước rẽ & thời gian
│   │   └── watch_bridge.dart          # Platform Channel cầu nối Flutter ↔ Native
│   ├── utils/               # Formatters (m/km, thời gian, icons)
│   └── widgets/             # TurnIndicator, ManeuverIcon, RouteSummary, WatchStatusBadge
├── android/                 # Native Android + Huawei Wear Engine SDK
│   └── app/src/main/kotlin/com/gt3nav/app/
│       ├── MainActivity.kt
│       └── WearEnginePlugin.kt
├── ios/                     # Native iOS + Wear Engine Bridge
│   └── Runner/
│       ├── Info.plist       # Cấu hình Background Location & URL Scheme
│       ├── AppDelegate.swift
│       └── WearEnginePlugin.swift
├── codemagic.yaml           # Cấu hình CI/CD tự động build IPA trên macOS cloud
└── pubspec.yaml
```

---

## 🛠️ Hướng dẫn cài đặt & Chạy trên Android (Test trực tiếp)

### 1. Cài Flutter trên Windows
1. Tải Flutter SDK từ [flutter.dev](https://docs.flutter.dev/get-started/install/windows/mobile).
2. Giải nén vào thư mục (ví dụ `C:\src\flutter`) và thêm đường dẫn `C:\src\flutter\bin` vào `PATH` của Windows.
3. Cài **Android Studio** (hoặc Android SDK Command-line Tools) và bật tính năng USB Debugging trên điện thoại Android của bạn.

### 2. Chạy thử nghiệm
Mở terminal tại thư mục `companion_app`:
```bash
flutter pub get
flutter run
```
Ứng dụng sẽ được cài trực tiếp lên điện thoại Android để bạn kiểm tra bản đồ và tìm đường.

---

## 🍎 Hướng dẫn Build iOS & Cài vào iPhone (KHÔNG CẦN MAC)

### Bước 1: Build file `.ipa` miễn phí qua Codemagic
1. Đăng ký tài khoản miễn phí tại [Codemagic.io](https://codemagic.io) (tặng 500 phút build macOS/tháng).
2. Tạo một repository trên GitHub (ví dụ: `gt3-navigation`) và đẩy toàn bộ source code này lên:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/your-username/gt3-navigation.git
   git push -u origin main
   ```
3. Trên giao diện Codemagic:
   - Chọn **Add application** > Chọn repository GitHub của bạn.
   - Chọn kiểu cấu hình: **Codemagic configuration file (`codemagic.yaml`)**.
   - Bấm **Start new build** > Chọn workflow `ios-unsigned-ipa`.
4. Codemagic sẽ tự động bật máy ảo Mac mini trên cloud, cài đặt Flutter, biên dịch mã nguồn và đóng gói thành file **`GT3Nav_unsigned.ipa`**.
5. Khi build xong (~5-7 phút), bạn tải file `GT3Nav_unsigned.ipa` trong mục **Artifacts** về máy tính Windows của bạn.

---

### Bước 2: Sideload file `.ipa` vào iPhone bằng Sideloadly
1. Tải và cài đặt **[Sideloadly](https://sideloadly.io/)** trên Windows.
2. Cài đặt **iTunes** và **iCloud** bản chính thức từ Apple (không dùng bản Microsoft Store nếu Sideloadly yêu cầu).
3. Cắm cáp kết nối iPhone với máy tính Windows, mở iPhone chọn **Tin cậy máy tính này** (Trust This Computer).
4. Mở Sideloadly:
   - Mục **iDevice**: Chọn chiếc iPhone của bạn vừa cắm cáp.
   - Mục **Apple ID**: Nhập tài khoản Apple ID cá nhân của bạn (hoàn toàn miễn phí, không mất tiền).
   - Kéo thả file `GT3Nav_unsigned.ipa` vào ô IPA trong Sideloadly.
   - Bấm nút **Start** để Sideloadly ký chứng chỉ miễn phí 7 ngày và nạp app vào iPhone.
5. Trên iPhone:
   - Vào **Cài đặt > Cài đặt chung > Quản lý VPN & Thiết bị** (VPN & Device Management).
   - Chọn mục Nhà phát triển ứng dụng (Apple ID của bạn) > Bấm **Tin cậy** (Trust).
   - Đối với iOS 16 trở lên: Vào **Cài đặt > Quyền riêng tư & Bảo mật > Chế độ Nhà phát triển** (Developer Mode) > Bật lên và khởi động lại máy nếu được yêu cầu.

---

## 🔄 Quy trình phối hợp giữa Android, iPhone và GT 3 SE

```
[Máy tính Windows] DevEco Studio
         ↓ Build file .hap
[Điện thoại Android] Cài .hap lên GT 3 SE qua Huawei Health Mod / Dev Mode
         ↓ (App đã nằm chắc chắn trong bộ nhớ đồng hồ)
[Đồng hồ GT 3 SE] Vào Cài đặt > Hệ thống > chọn "Ngắt kết nối" (KHÔNG Reset!)
         ↓
[iPhone] Ghép đôi GT 3 SE qua Huawei Health iOS (dùng cùng tài khoản Huawei ID)
         ↓
[iPhone] Mở app GT3 Navigation vừa cài bằng Sideloadly
         ↓ Bấm "Kết nối ngay" và bắt đầu tìm đường
Mũi tên rẽ, khoảng cách, tên đường & rung cảnh báo hiển thị trên mặt đồng hồ! 🎉
```
