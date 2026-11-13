# Navigation Icons / Biểu tượng điều hướng

Thư mục này chứa các icon SVG/PNG cho các loại chỉ dẫn rẽ (maneuver).

## Danh sách icon cần tạo

Tất cả icon nên có kích thước **80x80px**, nền trong suốt, màu trắng (#FFFFFF):

| File | Maneuver | Mô tả |
|------|----------|-------|
| `arrow_straight.png` | `straight` | Mũi tên thẳng lên ↑ |
| `arrow_turn_left.png` | `turn_left` | Mũi tên rẽ trái 90° ← |
| `arrow_turn_right.png` | `turn_right` | Mũi tên rẽ phải 90° → |
| `arrow_slight_left.png` | `slight_left` | Mũi tên chếch trái 45° ↖ |
| `arrow_slight_right.png` | `slight_right` | Mũi tên chếch phải 45° ↗ |
| `arrow_sharp_left.png` | `sharp_left` | Mũi tên rẽ gấp trái 135° |
| `arrow_sharp_right.png` | `sharp_right` | Mũi tên rẽ gấp phải 135° |
| `arrow_u_turn.png` | `u_turn` | Mũi tên quay đầu ↩ |
| `arrow_roundabout.png` | `roundabout` | Biểu tượng vòng xuyến ⟳ |
| `icon_arrive.png` | `arrive` | Biểu tượng cờ đích 🏁 |
| `icon_depart.png` | `depart` | Biểu tượng xuất phát 🚀 |
| `icon_compass.png` | N/A | Biểu tượng la bàn cho compass page |
| `icon_waiting.png` | N/A | Biểu tượng loading/connecting |

## Ghi chú thiết kế
- Sử dụng **nét đậm (bold stroke)** để dễ nhìn dưới nắng
- Nền trong suốt (transparent) để phù hợp dark theme
- Stroke width tối thiểu **4px** cho độ rõ nét trên màn hình tròn 466px
- Ưu tiên SVG nếu HarmonyOS Lite Wearable hỗ trợ, fallback PNG
- Lưu ý: HarmonyOS Lite Wearable JS **chỉ hỗ trợ PNG**, không hỗ trợ SVG
