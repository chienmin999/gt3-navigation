/**
 * Hằng số dùng chung trong ứng dụng Navigation Watch
 * Shared constants for the Navigation Watch App
 */

/**
 * Kích thước màn hình GT 3 SE (tròn)
 */
export const SCREEN_WIDTH = 466;
export const SCREEN_HEIGHT = 466;
export const SCREEN_RADIUS = 233;

/**
 * Các loại điều hướng (maneuver types)
 * Dùng để map với icon và mô tả
 */
export const MANEUVER_TYPES = {
  STRAIGHT: 'straight',
  TURN_LEFT: 'turn_left',
  TURN_RIGHT: 'turn_right',
  SLIGHT_LEFT: 'slight_left',
  SLIGHT_RIGHT: 'slight_right',
  SHARP_LEFT: 'sharp_left',
  SHARP_RIGHT: 'sharp_right',
  U_TURN: 'u_turn',
  ROUNDABOUT: 'roundabout',
  ARRIVE: 'arrive',
  DEPART: 'depart'
};

/**
 * Icon tương ứng với từng loại maneuver
 * Dùng Unicode arrows làm fallback khi không có icon file
 */
export const MANEUVER_ICONS = {
  straight: '↑',
  turn_left: '←',
  turn_right: '→',
  slight_left: '↖',
  slight_right: '↗',
  sharp_left: '⬅',
  sharp_right: '➡',
  u_turn: '↩',
  roundabout: '⟳',
  arrive: '🏁',
  depart: '🚀'
};

/**
 * Tên hiển thị cho maneuver (tiếng Anh)
 */
export const MANEUVER_LABELS_EN = {
  straight: 'Continue straight',
  turn_left: 'Turn left',
  turn_right: 'Turn right',
  slight_left: 'Slight left',
  slight_right: 'Slight right',
  sharp_left: 'Sharp left',
  sharp_right: 'Sharp right',
  u_turn: 'U-turn',
  roundabout: 'Roundabout',
  arrive: 'Arrive',
  depart: 'Depart'
};

/**
 * Tên hiển thị cho maneuver (tiếng Việt)
 */
export const MANEUVER_LABELS_VI = {
  straight: 'Đi thẳng',
  turn_left: 'Rẽ trái',
  turn_right: 'Rẽ phải',
  slight_left: 'Chếch trái',
  slight_right: 'Chếch phải',
  sharp_left: 'Rẽ gấp trái',
  sharp_right: 'Rẽ gấp phải',
  u_turn: 'Quay đầu',
  roundabout: 'Vòng xuyến',
  arrive: 'Đã tới',
  depart: 'Xuất phát'
};

/**
 * Loại message P2P
 */
export const MESSAGE_TYPES = {
  NAV_UPDATE: 'nav_update',
  CONNECTION: 'connection'
};

/**
 * Trạng thái kết nối
 */
export const CONNECTION_STATUS = {
  CONNECTED: 'connected',
  DISCONNECTED: 'disconnected'
};

/**
 * Cấu hình rung (vibration patterns)
 * mode: "short" | "long" (HarmonyOS Lite vibrator)
 */
export const VIBRATION_PATTERNS = {
  // Rung ngắn cho cảnh báo thường
  TURN_ALERT: { mode: 'short' },
  // Rung dài cho đã tới nơi
  ARRIVAL: { mode: 'long' },
  // Rung ngắn cho kết nối thành công
  CONNECTED: { mode: 'short' }
};

/**
 * Thời gian timeout kết nối (ms)
 * Nếu không nhận được data sau khoảng thời gian này → hiển thị lại waiting
 */
export const CONNECTION_TIMEOUT_MS = 30000;

/**
 * Khoảng thời gian polling kiểm tra kết nối (ms)
 */
export const HEARTBEAT_INTERVAL_MS = 10000;

/**
 * Cổng P2P mặc định cho Wear Engine messaging
 */
export const P2P_PORT = 8923;

/**
 * Màu sắc giao diện (Dark theme)
 */
export const COLORS = {
  BACKGROUND: '#000000',
  TEXT_PRIMARY: '#FFFFFF',
  TEXT_SECONDARY: '#CCCCCC',
  ACCENT_GREEN: '#00FF88',
  ACCENT_YELLOW: '#FFD700',
  ACCENT_RED: '#FF4444',
  ACCENT_BLUE: '#4488FF',
  DIVIDER: '#333333'
};
