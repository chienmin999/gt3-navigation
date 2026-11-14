/**
 * Index Page - Trang dẫn đường chính
 * Nhận dữ liệu P2P từ phone, hiển thị chỉ dẫn navigation
 * Rung cảnh báo khi sắp tới chỗ rẽ
 */

import vibrator from '@system.vibrator';
import router from '@system.router';
import {
  MANEUVER_ICONS,
  MANEUVER_LABELS_VI,
  MESSAGE_TYPES,
  CONNECTION_STATUS,
  VIBRATION_PATTERNS,
  CONNECTION_TIMEOUT_MS
} from '../../common/constants.js';

export default {
  data: {
    // === Dữ liệu hiển thị ===
    // Icon maneuver (Unicode fallback)
    maneuverIcon: '↑',
    // Khoảng cách đến chỗ rẽ
    distance: '--',
    // Nhãn loại rẽ (Rẽ trái, Đi thẳng...)
    maneuverLabel: 'Đang tải...',
    // Tên đường
    streetName: '',
    // Thời gian đến dự kiến
    eta: '--:--',
    // Quãng đường còn lại (km)
    remainingKm: '--',

    // === Trạng thái kết nối ===
    isConnectionLost: false,
    connectionText: '',

    // === Biến nội bộ ===
    _connectionTimer: null,
    _lastMessageTime: 0
  },

  /**
   * Khởi tạo trang
   * Đọc dữ liệu ban đầu từ app global (nếu có)
   */
  onInit() {
    console.info('[Index] Navigation page initialized');

    // Đọc dữ liệu từ trang waiting truyền qua
    const app = getApp();
    if (app.currentNavData) {
      this.updateNavDisplay(app.currentNavData);
    }
  },

  /**
   * Trang hiển thị
   * Đăng ký listener và bắt đầu kiểm tra kết nối
   */
  onShow() {
    console.info('[Index] Page shown');
    this.registerMessageListener();
    this.startConnectionMonitor();
  },

  /**
   * Trang bị ẩn
   */
  onHide() {
    console.info('[Index] Page hidden');
    this.stopConnectionMonitor();
  },

  /**
   * Hủy trang
   */
  onDestroy() {
    console.info('[Index] Page destroyed');
    this.stopConnectionMonitor();
    this.unregisterMessageListener();
  },

  /**
   * Đăng ký listener nhận P2P message từ phone
   * Được gọi qua app global callback
   */
  registerMessageListener() {
    const app = getApp();
    app._onP2PMessage = (messageData) => {
      this.handleMessage(messageData);
    };
    console.info('[Index] Message listener registered');
  },

  /**
   * Hủy đăng ký listener
   */
  unregisterMessageListener() {
    try {
      const app = getApp();
      app._onP2PMessage = null;
    } catch (error) {
      console.error('[Index] Failed to unregister listener');
    }
  },

  /**
   * Xử lý message nhận từ phone companion
   * @param {Object} data - JSON message
   */
  handleMessage(data) {
    // Kiểm tra data hợp lệ
    if (!data || typeof data !== 'object') {
      console.warn('[Index] Received invalid message data');
      return;
    }

    // Cập nhật thời gian nhận message cuối
    this._lastMessageTime = Date.now();

    switch (data.type) {
      case MESSAGE_TYPES.NAV_UPDATE:
        this.handleNavUpdate(data);
        break;

      case MESSAGE_TYPES.CONNECTION:
        this.handleConnectionUpdate(data);
        break;

      default:
        console.warn('[Index] Unknown message type: ' + data.type);
    }
  },

  /**
   * Xử lý cập nhật navigation
   * Cập nhật UI và rung nếu cần
   * @param {Object} data - { type, maneuver, distance, street, eta, remaining_km, vibrate }
   */
  handleNavUpdate(data) {
    console.info('[Index] Nav update: ' + data.maneuver + ' ' + data.distance);

    // Ẩn thanh mất kết nối
    this.hideConnectionBar();

    // Cập nhật giao diện
    this.updateNavDisplay(data);

    // Rung cảnh báo nếu phone yêu cầu
    if (data.vibrate === true) {
      this.triggerVibration(data.maneuver);
    }
  },

  /**
   * Cập nhật giao diện navigation
   * @param {Object} data - Dữ liệu navigation
   */
  updateNavDisplay(data) {
    // Cập nhật icon maneuver
    const maneuver = data.maneuver || 'straight';
    this.maneuverIcon = MANEUVER_ICONS[maneuver] || '↑';

    // Cập nhật nhãn loại rẽ
    this.maneuverLabel = MANEUVER_LABELS_VI[maneuver] || maneuver;

    // Cập nhật khoảng cách (xử lý null/undefined)
    this.distance = data.distance || '--';

    // Cập nhật tên đường (xử lý chuỗi rỗng)
    this.streetName = data.street || 'Đường không xác định';

    // Cập nhật ETA
    this.eta = data.eta || '--:--';

    // Cập nhật quãng đường còn lại
    this.remainingKm = data.remaining_km || '--';

    // Lưu vào app global
    const app = getApp();
    app.currentNavData = data;
  },

  /**
   * Xử lý cập nhật trạng thái kết nối
   * @param {Object} data - { type: "connection", status: "connected"|"disconnected" }
   */
  handleConnectionUpdate(data) {
    const status = data.status || CONNECTION_STATUS.DISCONNECTED;
    console.info('[Index] Connection status: ' + status);

    const app = getApp();
    app.connectionStatus = status;

    if (status === CONNECTION_STATUS.DISCONNECTED) {
      this.showConnectionBar('Mất kết nối');
    } else {
      this.hideConnectionBar();
      // Rung nhẹ xác nhận kết nối lại
      this.vibrate(VIBRATION_PATTERNS.CONNECTED);
    }
  },

  /**
   * Rung cảnh báo cho maneuver
   * Dùng pattern khác nhau cho arrive vs turn thường
   * @param {string} maneuver - Loại maneuver
   */
  triggerVibration(maneuver) {
    if (maneuver === 'arrive') {
      // Rung dài cho tới nơi
      this.vibrate(VIBRATION_PATTERNS.ARRIVAL);
    } else {
      // Rung ngắn cho các turn thường
      this.vibrate(VIBRATION_PATTERNS.TURN_ALERT);
    }
  },

  /**
   * Thực hiện rung
   * @param {Object} pattern - { mode: "short"|"long" }
   */
  vibrate(pattern) {
    try {
      vibrator.vibrate({
        mode: pattern.mode || 'short',
        success: () => {
          console.info('[Index] Vibration triggered');
        },
        fail: (data, code) => {
          console.error('[Index] Vibration failed: ' + code);
        }
      });
    } catch (error) {
      console.error('[Index] Vibrator error: ' + JSON.stringify(error));
    }
  },

  /**
   * Hiển thị thanh trạng thái kết nối (mất kết nối)
   * @param {string} text - Nội dung hiển thị
   */
  showConnectionBar(text) {
    this.isConnectionLost = true;
    this.connectionText = text;
  },

  /**
   * Ẩn thanh trạng thái kết nối
   */
  hideConnectionBar() {
    this.isConnectionLost = false;
    this.connectionText = '';
  },

  /**
   * Bắt đầu kiểm tra timeout kết nối
   * Nếu quá lâu không nhận message → hiển thị cảnh báo
   */
  startConnectionMonitor() {
    this.stopConnectionMonitor();
    this._lastMessageTime = Date.now();

    this._connectionTimer = setInterval(() => {
      const elapsed = Date.now() - this._lastMessageTime;
      if (elapsed > CONNECTION_TIMEOUT_MS) {
        console.warn('[Index] Connection timeout, no message for ' + elapsed + 'ms');
        this.showConnectionBar('Mất tín hiệu');

        // Nếu timeout quá lâu (gấp đôi), quay về trang waiting
        if (elapsed > CONNECTION_TIMEOUT_MS * 2) {
          this.navigateToWaiting();
        }
      }
    }, CONNECTION_TIMEOUT_MS / 3);
  },

  /**
   * Dừng kiểm tra kết nối
   */
  stopConnectionMonitor() {
    if (this._connectionTimer) {
      clearInterval(this._connectionTimer);
      this._connectionTimer = null;
    }
  },

  /**
   * Quay về trang chờ kết nối
   */
  navigateToWaiting() {
    console.info('[Index] Navigating back to waiting page');
    const app = getApp();
    app.connectionStatus = CONNECTION_STATUS.DISCONNECTED;
    app.currentNavData = null;

    router.replace({
      uri: 'pages/waiting/waiting'
    });
  }
};
